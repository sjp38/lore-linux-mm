Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A8B248E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 18:10:21 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f3so2776264pgq.13
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 15:10:21 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y3si8064455pfb.152.2019.01.16.15.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 15:10:19 -0800 (PST)
Subject: [PATCH v8 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 16 Jan 2019 14:57:42 -0800
Message-ID: <154767946196.1983228.8172988837680181734.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154767945660.1983228.12167020940431682725.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154767945660.1983228.12167020940431682725.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, keith.busch@intel.com

Randomization of the page allocator improves the average utilization of
a direct-mapped memory-side-cache. Memory side caching is a platform
capability that Linux has been previously exposed to in HPC
(high-performance computing) environments on specialty platforms. In
that instance it was a smaller pool of high-bandwidth-memory relative to
higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
be found on general purpose server platforms where DRAM is a cache in
front of higher latency persistent memory [1].

Robert offered an explanation of the state of the art of Linux
interactions with memory-side-caches [2], and I copy it here:

    It's been a problem in the HPC space:
    http://www.nersc.gov/research-and-development/knl-cache-mode-performance-coe/

    A kernel module called zonesort is available to try to help:
    https://software.intel.com/en-us/articles/xeon-phi-software

    and this abandoned patch series proposed that for the kernel:
    https://lkml.org/lkml/2017/8/23/195

    Dan's patch series doesn't attempt to ensure buffers won't conflict, but
    also reduces the chance that the buffers will. This will make performance
    more consistent, albeit slower than "optimal" (which is near impossible
    to attain in a general-purpose kernel).  That's better than forcing
    users to deploy remedies like:
        "To eliminate this gradual degradation, we have added a Stream
         measurement to the Node Health Check that follows each job;
         nodes are rebooted whenever their measured memory bandwidth
         falls below 300 GB/s."

A replacement for zonesort was merged upstream in commit cc9aec03e58f
"x86/numa_emulation: Introduce uniform split capability". With this
numa_emulation capability, memory can be split into cache sized
("near-memory" sized) numa nodes. A bind operation to such a node, and
disabling workloads on other nodes, enables full cache performance.
However, once the workload exceeds the cache size then cache conflicts
are unavoidable. While HPC environments might be able to tolerate
time-scheduling of cache sized workloads, for general purpose server
platforms, the oversubscribed cache case will be the common case.

The worst case scenario is that a server system owner benchmarks a
workload at boot with an un-contended cache only to see that performance
degrade over time, even below the average cache performance due to
excessive conflicts. Randomization clips the peaks and fills in the
valleys of cache utilization to yield steady average performance.

Here are some performance impact details of the patches:

1/ An Intel internal synthetic memory bandwidth measurement tool, saw a
3X speedup in a contrived case that tries to force cache conflicts. The
contrived cased used the numa_emulation capability to force an instance
of the benchmark to be run in two of the near-memory sized numa nodes.
If both instances were placed on the same emulated they would fit and
cause zero conflicts.  While on separate emulated nodes without
randomization they underutilized the cache and conflicted unnecessarily
due to the in-order allocation per node.

2/ A well known Java server application benchmark was run with a heap
size that exceeded cache size by 3X. The cache conflict rate was 8% for
the first run and degraded to 21% after page allocator aging. With
randomization enabled the rate levelled out at 11%.

3/ A MongoDB workload did not observe measurable difference in
cache-conflict rates, but the overall throughput dropped by 7% with
randomization in one case.

4/ Mel Gorman ran his suite of performance workloads with randomization
enabled on platforms without a memory-side-cache and saw a mix of some
improvements and some losses [3].

While there is potentially significant improvement for applications that
depend on low latency access across a wide working-set, the performance
may be negligible to negative for other workloads. For this reason the
shuffle capability defaults to off unless a direct-mapped
memory-side-cache is detected. Even then, the page_alloc.shuffle=0
parameter can be specified to disable the randomization on those
systems.

Outside of memory-side-cache utilization concerns there is potentially
security benefit from randomization. Some data exfiltration and
return-oriented-programming attacks rely on the ability to infer the
location of sensitive data objects. The kernel page allocator,
especially early in system boot, has predictable first-in-first out
behavior for physical pages. Pages are freed in physical address order
when first onlined.

Quoting Kees:
    "While we already have a base-address randomization
     (CONFIG_RANDOMIZE_MEMORY), attacks against the same hardware and
     memory layouts would certainly be using the predictability of
     allocation ordering (i.e. for attacks where the base address isn't
     important: only the relative positions between allocated memory).
     This is common in lots of heap-style attacks. They try to gain
     control over ordering by spraying allocations, etc.

     I'd really like to see this because it gives us something similar
     to CONFIG_SLAB_FREELIST_RANDOM but for the page allocator."

While SLAB_FREELIST_RANDOM reduces the predictability of some local slab
caches it leaves vast bulk of memory to be predictably in order
allocated.  However, it should be noted, the concrete security benefits
are hard to quantify, and no known CVE is mitigated by this
randomization.

Introduce shuffle_free_memory(), and its helper shuffle_zone(), to
perform a Fisher-Yates shuffle of the page allocator 'free_area' lists
when they are initially populated with free memory at boot and at
hotplug time. Do this based on either the presence of a
page_alloc.shuffle=Y command line parameter, or autodetection of a
memory-side-cache (to be added in a follow-on patch).

The shuffling is done in terms of CONFIG_SHUFFLE_PAGE_ORDER sized free
pages where the default CONFIG_SHUFFLE_PAGE_ORDER is MAX_ORDER-1 i.e.
10, 4MB this trades off randomization granularity for time spent
shuffling.  MAX_ORDER-1 was chosen to be minimally invasive to the page
allocator while still showing memory-side cache behavior improvements,
and the expectation that the security implications of finer granularity
randomization is mitigated by CONFIG_SLAB_FREELIST_RANDOM.

The performance impact of the shuffling appears to be in the noise
compared to other memory initialization work. Also the bulk of the work
is done in the background as a part of deferred_init_memmap().

This initial randomization can be undone over time so a follow-on patch
is introduced to inject entropy on page free decisions. It is reasonable
to ask if the page free entropy is sufficient, but it is not enough due
to the in-order initial freeing of pages. At the start of that process
putting page1 in front or behind page0 still keeps them close together,
page2 is still near page1 and has a high chance of being adjacent. As
more pages are added ordering diversity improves, but there is still
high page locality for the low address pages and this leads to no
significant impact to the cache conflict rate.

[1]: https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
[2]: https://lkml.org/lkml/2018/9/22/54
[3]: https://lkml.org/lkml/2018/10/12/309

Cc: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/list.h    |   17 ++++
 include/linux/mmzone.h  |    4 +
 include/linux/shuffle.h |   48 ++++++++++
 init/Kconfig            |   35 ++++++++
 mm/Makefile             |    7 +-
 mm/memblock.c           |   10 ++
 mm/memory_hotplug.c     |    3 +
 mm/page_alloc.c         |    3 +
 mm/shuffle.c            |  215 +++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 340 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/shuffle.h
 create mode 100644 mm/shuffle.c

diff --git a/include/linux/list.h b/include/linux/list.h
index edb7628e46ed..3dfb8953f241 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -150,6 +150,23 @@ static inline void list_replace_init(struct list_head *old,
 	INIT_LIST_HEAD(old);
 }
 
+/**
+ * list_swap - replace entry1 with entry2 and re-add entry1 at entry2's position
+ * @entry1: the location to place entry2
+ * @entry2: the location to place entry1
+ */
+static inline void list_swap(struct list_head *entry1,
+			     struct list_head *entry2)
+{
+	struct list_head *pos = entry2->prev;
+
+	list_del(entry2);
+	list_replace(entry1, entry2);
+	if (pos == entry1)
+		pos = entry2;
+	list_add(entry1, pos);
+}
+
 /**
  * list_del_init - deletes entry from list and reinitialize it.
  * @entry: the element to delete from the list.
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index cc4a507d7ca4..8c37a023a790 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1272,6 +1272,10 @@ void sparse_init(void);
 #else
 #define sparse_init()	do {} while (0)
 #define sparse_index_init(_sec, _nid)  do {} while (0)
+static inline int pfn_present(unsigned long pfn)
+{
+	return 1;
+}
 #endif /* CONFIG_SPARSEMEM */
 
 /*
diff --git a/include/linux/shuffle.h b/include/linux/shuffle.h
new file mode 100644
index 000000000000..d109161f4a62
--- /dev/null
+++ b/include/linux/shuffle.h
@@ -0,0 +1,48 @@
+// SPDX-License-Identifier: GPL-2.0
+// Copyright(c) 2018 Intel Corporation. All rights reserved.
+#ifndef _MM_SHUFFLE_H
+#define _MM_SHUFFLE_H
+#include <linux/jump_label.h>
+
+enum mm_shuffle_ctl {
+	SHUFFLE_ENABLE,
+	SHUFFLE_FORCE_DISABLE,
+};
+#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
+DECLARE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
+extern void page_alloc_shuffle(enum mm_shuffle_ctl ctl);
+extern void __shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
+		unsigned long end_pfn);
+static inline void shuffle_free_memory(pg_data_t *pgdat,
+		unsigned long start_pfn, unsigned long end_pfn)
+{
+	if (!static_branch_unlikely(&page_alloc_shuffle_key))
+		return;
+	__shuffle_free_memory(pgdat, start_pfn, end_pfn);
+}
+
+extern void __shuffle_zone(struct zone *z, unsigned long start_pfn,
+		unsigned long end_pfn);
+static inline void shuffle_zone(struct zone *z, unsigned long start_pfn,
+		unsigned long end_pfn)
+{
+	if (!static_branch_unlikely(&page_alloc_shuffle_key))
+		return;
+	__shuffle_zone(z, start_pfn, end_pfn);
+}
+#else
+static inline void shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
+		unsigned long end_pfn)
+{
+}
+
+static inline void shuffle_zone(struct zone *z, unsigned long start_pfn,
+		unsigned long end_pfn)
+{
+}
+
+static inline void page_alloc_shuffle(enum mm_shuffle_ctl ctl)
+{
+}
+#endif
+#endif /* _MM_SHUFFLE_H */
diff --git a/init/Kconfig b/init/Kconfig
index d47cb77a220e..d5d574d931ba 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1714,6 +1714,41 @@ config SLAB_FREELIST_HARDENED
 	  sacrifies to harden the kernel slab allocator against common
 	  freelist exploit methods.
 
+config SHUFFLE_PAGE_ALLOCATOR
+	bool "Page allocator randomization"
+	default SLAB_FREELIST_RANDOM
+	help
+	  Randomization of the page allocator improves the average
+	  utilization of a direct-mapped memory-side-cache. See section
+	  5.2.27 Heterogeneous Memory Attribute Table (HMAT) in the ACPI
+	  6.2a specification for an example of how a platform advertises
+	  the presence of a memory-side-cache. There are also incidental
+	  security benefits as it reduces the predictability of page
+	  allocations to compliment SLAB_FREELIST_RANDOM, but the
+	  default granularity of shuffling on 4MB (MAX_ORDER) pages is
+	  selected based on cache utilization benefits.
+
+	  While the randomization improves cache utilization it may
+	  negatively impact workloads on platforms without a cache. For
+	  this reason, by default, the randomization is enabled only
+	  after runtime detection of a direct-mapped memory-side-cache.
+	  Otherwise, the randomization may be force enabled with the
+	  'page_alloc.shuffle' kernel command line parameter.
+
+	  Say Y if unsure.
+
+config SHUFFLE_PAGE_ORDER
+	depends on SHUFFLE_PAGE_ALLOCATOR
+	int "Page allocator shuffle order"
+	range 0 10
+	default 10
+	help
+	  Specify the granularity at which shuffling (randomization) is
+	  performed. By default this is set to MAX_ORDER-1 to minimize
+	  runtime impact of randomization and with the expectation that
+	  SLAB_FREELIST_RANDOM mitigates heap attacks on smaller
+	  object granularities.
+
 config SLUB_CPU_PARTIAL
 	default y
 	depends on SLUB && SMP
diff --git a/mm/Makefile b/mm/Makefile
index d210cc9d6f80..ac5e5ba78874 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -33,7 +33,7 @@ mmu-$(CONFIG_MMU)	+= process_vm_access.o
 endif
 
 obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
-			   maccess.o page_alloc.o page-writeback.o \
+			   maccess.o page-writeback.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
@@ -41,6 +41,11 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   interval_tree.o list_lru.o workingset.o \
 			   debug.o $(mmu-y)
 
+# Give 'page_alloc' its own module-parameter namespace
+page-alloc-y := page_alloc.o
+page-alloc-$(CONFIG_SHUFFLE_PAGE_ALLOCATOR) += shuffle.o
+
+obj-y += page-alloc.o
 obj-y += init-mm.o
 obj-y += memblock.o
 
diff --git a/mm/memblock.c b/mm/memblock.c
index 022d4cbb3618..3602f7a2eab4 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -17,6 +17,7 @@
 #include <linux/poison.h>
 #include <linux/pfn.h>
 #include <linux/debugfs.h>
+#include <linux/shuffle.h>
 #include <linux/kmemleak.h>
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
@@ -1929,9 +1930,16 @@ static unsigned long __init free_low_memory_core_early(void)
 	 *  low ram will be on Node1
 	 */
 	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end,
-				NULL)
+				NULL) {
+		pg_data_t *pgdat;
+
 		count += __free_memory_core(start, end);
 
+		for_each_online_pgdat(pgdat)
+			shuffle_free_memory(pgdat, PHYS_PFN(start),
+					PHYS_PFN(end));
+	}
+
 	return count;
 }
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9a667d36c55..7caffb9a91ab 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -23,6 +23,7 @@
 #include <linux/highmem.h>
 #include <linux/vmalloc.h>
 #include <linux/ioport.h>
+#include <linux/shuffle.h>
 #include <linux/delay.h>
 #include <linux/migrate.h>
 #include <linux/page-isolation.h>
@@ -895,6 +896,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 
+	shuffle_zone(zone, pfn, zone_end_pfn(zone));
+
 	if (onlined_pages) {
 		node_states_set_node(nid, &arg);
 		if (need_zonelists_rebuild)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cde5dac6229a..2adcd6da8a07 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -61,6 +61,7 @@
 #include <linux/sched/rt.h>
 #include <linux/sched/mm.h>
 #include <linux/page_owner.h>
+#include <linux/shuffle.h>
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
 #include <linux/ftrace.h>
@@ -1634,6 +1635,8 @@ static int __init deferred_init_memmap(void *data)
 	}
 	pgdat_resize_unlock(pgdat, &flags);
 
+	shuffle_zone(zone, first_init_pfn, zone_end_pfn(zone));
+
 	/* Sanity check that the next zone really is unpopulated */
 	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
 
diff --git a/mm/shuffle.c b/mm/shuffle.c
new file mode 100644
index 000000000000..5d39e8cb50f7
--- /dev/null
+++ b/mm/shuffle.c
@@ -0,0 +1,215 @@
+// SPDX-License-Identifier: GPL-2.0
+// Copyright(c) 2018 Intel Corporation. All rights reserved.
+
+#include <linux/mm.h>
+#include <linux/init.h>
+#include <linux/mmzone.h>
+#include <linux/random.h>
+#include <linux/shuffle.h>
+#include <linux/moduleparam.h>
+#include "internal.h"
+
+DEFINE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
+static unsigned long shuffle_state __ro_after_init;
+
+/*
+ * Depending on the architecture, module parameter parsing may run
+ * before, or after the cache detection. SHUFFLE_FORCE_DISABLE prevents,
+ * or reverts the enabling of the shuffle implementation. SHUFFLE_ENABLE
+ * attempts to turn on the implementation, but aborts if it finds
+ * SHUFFLE_FORCE_DISABLE already set.
+ */
+void page_alloc_shuffle(enum mm_shuffle_ctl ctl)
+{
+	if (ctl == SHUFFLE_FORCE_DISABLE)
+		set_bit(SHUFFLE_FORCE_DISABLE, &shuffle_state);
+
+	if (test_bit(SHUFFLE_FORCE_DISABLE, &shuffle_state)) {
+		if (test_and_clear_bit(SHUFFLE_ENABLE, &shuffle_state))
+			static_branch_disable(&page_alloc_shuffle_key);
+	} else if (ctl == SHUFFLE_ENABLE
+			&& !test_and_set_bit(SHUFFLE_ENABLE, &shuffle_state))
+		static_branch_enable(&page_alloc_shuffle_key);
+}
+
+static bool shuffle_param;
+extern int shuffle_show(char *buffer, const struct kernel_param *kp)
+{
+	return sprintf(buffer, "%c\n", test_bit(SHUFFLE_ENABLE, &shuffle_state)
+			? 'Y' : 'N');
+}
+static int shuffle_store(const char *val, const struct kernel_param *kp)
+{
+	int rc = param_set_bool(val, kp);
+
+	if (rc < 0)
+		return rc;
+	if (shuffle_param)
+		page_alloc_shuffle(SHUFFLE_ENABLE);
+	else
+		page_alloc_shuffle(SHUFFLE_FORCE_DISABLE);
+	return 0;
+}
+module_param_call(shuffle, shuffle_store, shuffle_show, &shuffle_param, 0400);
+
+/*
+ * For two pages to be swapped in the shuffle, they must be free (on a
+ * 'free_area' lru), have the same order, and have the same migratetype.
+ */
+static struct page * __meminit shuffle_valid_page(unsigned long pfn, int order)
+{
+	struct page *page;
+
+	/*
+	 * Given we're dealing with randomly selected pfns in a zone we
+	 * need to ask questions like...
+	 */
+
+	/* ...is the pfn even in the memmap? */
+	if (!pfn_valid_within(pfn))
+		return NULL;
+
+	/* ...is the pfn in a present section or a hole? */
+	if (!pfn_present(pfn))
+		return NULL;
+
+	/* ...is the page free and currently on a free_area list? */
+	page = pfn_to_page(pfn);
+	if (!PageBuddy(page))
+		return NULL;
+
+	/*
+	 * ...is the page on the same list as the page we will
+	 * shuffle it with?
+	 */
+	if (page_order(page) != order)
+		return NULL;
+
+	return page;
+}
+
+/*
+ * Fisher-Yates shuffle the freelist which prescribes iterating through
+ * an array, pfns in this case, and randomly swapping each entry with
+ * another in the span, end_pfn - start_pfn.
+ *
+ * To keep the implementation simple it does not attempt to correct for
+ * sources of bias in the distribution, like modulo bias or
+ * pseudo-random number generator bias. I.e. the expectation is that
+ * this shuffling raises the bar for attacks that exploit the
+ * predictability of page allocations, but need not be a perfect
+ * shuffle.
+ *
+ * Note that we don't use @z->zone_start_pfn and zone_end_pfn(@z)
+ * directly since the caller may be aware of holes in the zone and can
+ * improve the accuracy of the random pfn selection.
+ */
+#define SHUFFLE_RETRY 10
+static void __meminit shuffle_zone_order(struct zone *z, unsigned long start_pfn,
+		unsigned long end_pfn, const int order)
+{
+	unsigned long i, flags;
+	const int order_pages = 1 << order;
+
+	if (start_pfn < z->zone_start_pfn)
+		start_pfn = z->zone_start_pfn;
+	if (end_pfn > zone_end_pfn(z))
+		end_pfn = zone_end_pfn(z);
+
+	/* probably means that start/end were outside the zone */
+	if (end_pfn <= start_pfn)
+		return;
+	spin_lock_irqsave(&z->lock, flags);
+	start_pfn = ALIGN(start_pfn, order_pages);
+	for (i = start_pfn; i < end_pfn; i += order_pages) {
+		unsigned long j;
+		int migratetype, retry;
+		struct page *page_i, *page_j;
+
+		/*
+		 * We expect page_i, in the sub-range of a zone being
+		 * added (@start_pfn to @end_pfn), to more likely be
+		 * valid compared to page_j randomly selected in the
+		 * span @zone_start_pfn to @spanned_pages.
+		 */
+		page_i = shuffle_valid_page(i, order);
+		if (!page_i)
+			continue;
+
+		for (retry = 0; retry < SHUFFLE_RETRY; retry++) {
+			/*
+			 * Pick a random order aligned page from the
+			 * start of the zone. Use the *whole* zone here
+			 * so that if it is freed in tiny pieces that we
+			 * randomize in the whole zone, not just within
+			 * those fragments.
+			 *
+			 * Since page_j comes from a potentially sparse
+			 * address range we want to try a bit harder to
+			 * find a shuffle point for page_i.
+			 */
+			j = z->zone_start_pfn +
+				ALIGN_DOWN(get_random_long() % z->spanned_pages,
+						order_pages);
+			page_j = shuffle_valid_page(j, order);
+			if (page_j && page_j != page_i)
+				break;
+		}
+		if (retry >= SHUFFLE_RETRY) {
+			pr_debug("%s: failed to swap %#lx\n", __func__, i);
+			continue;
+		}
+
+		/*
+		 * Each migratetype corresponds to its own list, make
+		 * sure the types match otherwise we're moving pages to
+		 * lists where they do not belong.
+		 */
+		migratetype = get_pageblock_migratetype(page_i);
+		if (get_pageblock_migratetype(page_j) != migratetype) {
+			pr_debug("%s: migratetype mismatch %#lx\n", __func__, i);
+			continue;
+		}
+
+		list_swap(&page_i->lru, &page_j->lru);
+
+		pr_debug("%s: swap: %#lx -> %#lx\n", __func__, i, j);
+
+		/* take it easy on the zone lock */
+		if ((i % (100 * order_pages)) == 0) {
+			spin_unlock_irqrestore(&z->lock, flags);
+			cond_resched();
+			spin_lock_irqsave(&z->lock, flags);
+		}
+	}
+	spin_unlock_irqrestore(&z->lock, flags);
+}
+
+void __meminit __shuffle_zone(struct zone *z, unsigned long start_pfn,
+               unsigned long end_pfn)
+{
+       int i;
+
+       /* shuffle all the orders at the specified order and higher */
+       for (i = CONFIG_SHUFFLE_PAGE_ORDER; i < MAX_ORDER; i++)
+               shuffle_zone_order(z, start_pfn, end_pfn, i);
+}
+
+/**
+ * shuffle_free_memory - reduce the predictability of the page allocator
+ * @pgdat: node page data
+ * @start_pfn: Limit the shuffle to the greater of this value or zone start
+ * @end_pfn: Limit the shuffle to the less of this value or zone end
+ *
+ * While shuffle_zone() attempts to avoid holes with pfn_valid() and
+ * pfn_present() they can not report sub-section sized holes. @start_pfn
+ * and @end_pfn limit the shuffle to the exact memory pages being freed.
+ */
+void __meminit __shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
+		unsigned long end_pfn)
+{
+	struct zone *z;
+
+	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
+		shuffle_zone(z, start_pfn, end_pfn);
+}
