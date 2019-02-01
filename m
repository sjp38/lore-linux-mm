Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 169F0C282DA
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:27:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBDB120B1F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:27:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBDB120B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CC488E0003; Fri,  1 Feb 2019 00:27:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67B048E0001; Fri,  1 Feb 2019 00:27:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 592428E0003; Fri,  1 Feb 2019 00:27:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 076C88E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 00:27:58 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a9so4265594pla.2
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 21:27:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=An7uY+A6BJcSgNwEq02Ib5TeQLQgYjhYLH9pddBtHjQ=;
        b=WbogqsGyYIydFq4IqoiHIj0ruECtCXuN/cWOi8vOzNufQ5OBC3/sbyHNTS9hdzkdkQ
         Sl2B/uxQ9sBXU1w1M2pnes3+4O+PCKILNlEwi2GwXg0aSW7sSIjLYppNIUBXjnwg5mEa
         4uL9GJ3BukiW3kp7ZXOQxEAZ7lKaQgvFzhN96Fex5IMxP1YVOeXzHSUbMBjf0Jj9ndDg
         kf389uz9SC+9ctN8wIdBKF607nkAqto9oxA3ER7Idj/o8brauIgTPpZdjspkm8G/jPcM
         UWxF/ioeIgTV2EyPMBWfis3oHqiq72PHrCe2BGFKMiJYiIdQSsKxlTX62s0XvgC9579/
         75jQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYdQzRROs5dqaTvh06vHsgWcOXh965KarfxR6bTflbvugD30J0v
	zjf7vAagJ4y6UEczwGPDVoQPy8GhyT6HjBpXaHNkq8us/IVbBT2g54If7LmZ+iEFaxXrgFDLRXR
	5rfzh5Gu2LuqurLNqsIfDi6F90t5uIN8qg8XkrXR7JEQly9Cn+pUf0HrexmJMXwVaBA==
X-Received: by 2002:a63:fd0a:: with SMTP id d10mr946894pgh.164.1548998877584;
        Thu, 31 Jan 2019 21:27:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ5uXjVwdOhPfwmj67lmgg/aHrhawoCGpuGJ+DIjEvBgJj/iMT0ER8euTFFvZPrLFLlj6Hc
X-Received: by 2002:a63:fd0a:: with SMTP id d10mr946833pgh.164.1548998875502;
        Thu, 31 Jan 2019 21:27:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548998875; cv=none;
        d=google.com; s=arc-20160816;
        b=X70SMPDN6cfUfpnrsxsxHFuego/3cZZ5lIH/07mtcDRDUybOPNblXk21f9mSPpNNrG
         mzJ5j2r0h3M2CSvoGhoOOpJhHcSuvR3SrpNRrsqqk1CqAEj3Hpl9+jOMD7x0VobGYEbv
         N9NFqOdJziqgQqBuEIuAPb0WYYaPLgH7mrDdiXnaionVigelEoB662YjmrVpbZiOVBFT
         Uc6/IQw97rDHpt/ksNHvdPEGq62WPoAUpV+2cXRY85KQMkGK0DMTDP2QeLe7npJpaHZE
         3oCWApRsR5RRlAbMTjr1WCNKCDJW/wLKf1vbq4TUimKuyvuI2YakIvcecFtUKPBUDMXY
         w+fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=An7uY+A6BJcSgNwEq02Ib5TeQLQgYjhYLH9pddBtHjQ=;
        b=tUlDjVYdboFik1pURMQirGF1329GS+uWwEx4ns6weDJzNImxMt7SuUSHS4lttfmbiF
         7HggEk2nkd0msF/dPrbWMr0e+P1d9GrZYrgFGIKFkkXoq/oYEPr35I4Cxm0Iz/YqX/nK
         uD1L72WEyaAu4vP6aTS1tN7426EIlFIQXUSMK9kl70Uj7XnYewxjOTQPNxXwMl70RNny
         vfBeQSEftfS0mPtgctKBqumOzdgmZsiCHFusuP62P2RsMt8D0li4Bzv8zkonjii/D6lI
         Wbl30FGm4OvLp40IGmaxAUIhR69uFDk/XQZq7O1Y7ymgC9PuJv05kf2Szruc4AgU3Joc
         w8Eg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b14si1376437plk.333.2019.01.31.21.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 21:27:55 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 Jan 2019 21:27:54 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,547,1539673200"; 
   d="scan'208";a="130657204"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga002.jf.intel.com with ESMTP; 31 Jan 2019 21:27:54 -0800
Subject: [PATCH v10 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>,
 Kees Cook <keescook@chromium.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, keith.busch@intel.com
Date: Thu, 31 Jan 2019 21:15:17 -0800
Message-ID: <154899811738.3165233.12325692939590944259.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
    https://lkml.kernel.org/r/20170823100205.17311-1-lukasz.daniluk@intel.com

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
randomization is mitigated by CONFIG_SLAB_FREELIST_RANDOM. The
performance impact of the shuffling appears to be in the noise compared
to other memory initialization work.

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
[2]: https://lkml.kernel.org/r/AT5PR8401MB1169D656C8B5E121752FC0F8AB120@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM
[3]: https://lkml.org/lkml/2018/10/12/309

Cc: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 Documentation/admin-guide/kernel-parameters.txt |   10 +
 include/linux/list.h                            |   17 ++
 include/linux/mmzone.h                          |    1 
 init/Kconfig                                    |   23 +++
 mm/Makefile                                     |    7 +
 mm/memory_hotplug.c                             |    3 
 mm/page_alloc.c                                 |    6 +
 mm/shuffle.c                                    |  170 +++++++++++++++++++++++
 mm/shuffle.h                                    |   52 +++++++
 9 files changed, 287 insertions(+), 2 deletions(-)
 create mode 100644 mm/shuffle.c
 create mode 100644 mm/shuffle.h

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index b799bcf67d7b..abfd4a325354 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -3080,6 +3080,16 @@
 			This will also cause panics on machine check exceptions.
 			Useful together with panic=30 to trigger a reboot.
 
+	page_alloc.shuffle=
+			[KNL] Boolean flag to control whether the page allocator
+			should randomize its free lists. The randomization may
+			be automatically enabled if the kernel detects it is
+			running on a platform with a direct-mapped memory-side
+			cache, and this parameter can be used to
+			override/disable that behavior. The state of the flag
+			can be read from sysfs at:
+			/sys/module/page_alloc/parameters/shuffle.
+
 	page_owner=	[KNL] Boot-time page_owner enabling option.
 			Storage of the information about who allocated
 			each page is disabled in default. With this switch,
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
index cc4a507d7ca4..c151c87a728a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1272,6 +1272,7 @@ void sparse_init(void);
 #else
 #define sparse_init()	do {} while (0)
 #define sparse_index_init(_sec, _nid)  do {} while (0)
+#define pfn_present pfn_valid
 #endif /* CONFIG_SPARSEMEM */
 
 /*
diff --git a/init/Kconfig b/init/Kconfig
index d47cb77a220e..cfa199f3e9be 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1714,6 +1714,29 @@ config SLAB_FREELIST_HARDENED
 	  sacrifies to harden the kernel slab allocator against common
 	  freelist exploit methods.
 
+config SHUFFLE_PAGE_ALLOCATOR
+	bool "Page allocator randomization"
+	default SLAB_FREELIST_RANDOM && ACPI_NUMA
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
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9a667d36c55..0bb10e132f95 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -39,6 +39,7 @@
 #include <asm/tlbflush.h>
 
 #include "internal.h"
+#include "shuffle.h"
 
 /*
  * online_page_callback contains pointer to current page onlining function.
@@ -895,6 +896,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 
+	shuffle_zone(zone);
+
 	if (onlined_pages) {
 		node_states_set_node(nid, &arg);
 		if (need_zonelists_rebuild)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cde5dac6229a..14ef39445544 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -72,6 +72,7 @@
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
 #include "internal.h"
+#include "shuffle.h"
 
 /* prevent >1 _updater_ of zone percpu pageset ->high and ->batch fields */
 static DEFINE_MUTEX(pcp_batch_high_lock);
@@ -1752,9 +1753,9 @@ _deferred_grow_zone(struct zone *zone, unsigned int order)
 void __init page_alloc_init_late(void)
 {
 	struct zone *zone;
+	int nid;
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-	int nid;
 
 	/* There will be num_node_state(N_MEMORY) threads */
 	atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
@@ -1779,6 +1780,9 @@ void __init page_alloc_init_late(void)
 	memblock_discard();
 #endif
 
+	for_each_node_state(nid, N_MEMORY)
+		shuffle_free_memory(NODE_DATA(nid));
+
 	for_each_populated_zone(zone)
 		set_zone_contiguous(zone);
 }
diff --git a/mm/shuffle.c b/mm/shuffle.c
new file mode 100644
index 000000000000..8badf4f0a852
--- /dev/null
+++ b/mm/shuffle.c
@@ -0,0 +1,170 @@
+// SPDX-License-Identifier: GPL-2.0
+// Copyright(c) 2018 Intel Corporation. All rights reserved.
+
+#include <linux/mm.h>
+#include <linux/init.h>
+#include <linux/mmzone.h>
+#include <linux/random.h>
+#include <linux/moduleparam.h>
+#include "internal.h"
+#include "shuffle.h"
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
+__meminit void page_alloc_shuffle(enum mm_shuffle_ctl ctl)
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
+module_param_call(shuffle, NULL, shuffle_show, &shuffle_param, 0400);
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
+ * Fisher-Yates shuffle the freelist which prescribes iterating through an
+ * array, pfns in this case, and randomly swapping each entry with another in
+ * the span, end_pfn - start_pfn.
+ *
+ * To keep the implementation simple it does not attempt to correct for sources
+ * of bias in the distribution, like modulo bias or pseudo-random number
+ * generator bias. I.e. the expectation is that this shuffling raises the bar
+ * for attacks that exploit the predictability of page allocations, but need not
+ * be a perfect shuffle.
+ */
+#define SHUFFLE_RETRY 10
+void __meminit __shuffle_zone(struct zone *z)
+{
+	unsigned long i, flags;
+	unsigned long start_pfn = z->zone_start_pfn;
+	unsigned long end_pfn = zone_end_pfn(z);
+	const int order = SHUFFLE_ORDER;
+	const int order_pages = 1 << order;
+
+	spin_lock_irqsave(&z->lock, flags);
+	start_pfn = ALIGN(start_pfn, order_pages);
+	for (i = start_pfn; i < end_pfn; i += order_pages) {
+		unsigned long j;
+		int migratetype, retry;
+		struct page *page_i, *page_j;
+
+		/*
+		 * We expect page_i, in the sub-range of a zone being added
+		 * (@start_pfn to @end_pfn), to more likely be valid compared to
+		 * page_j randomly selected in the span @zone_start_pfn to
+		 * @spanned_pages.
+		 */
+		page_i = shuffle_valid_page(i, order);
+		if (!page_i)
+			continue;
+
+		for (retry = 0; retry < SHUFFLE_RETRY; retry++) {
+			/*
+			 * Pick a random order aligned page in the zone span as
+			 * a swap target. If the selected pfn is a hole, retry
+			 * up to SHUFFLE_RETRY attempts find a random valid pfn
+			 * in the zone.
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
+		 * Each migratetype corresponds to its own list, make sure the
+		 * types match otherwise we're moving pages to lists where they
+		 * do not belong.
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
+/**
+ * shuffle_free_memory - reduce the predictability of the page allocator
+ * @pgdat: node page data
+ */
+void __meminit __shuffle_free_memory(pg_data_t *pgdat)
+{
+	struct zone *z;
+
+	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
+		shuffle_zone(z);
+}
diff --git a/mm/shuffle.h b/mm/shuffle.h
new file mode 100644
index 000000000000..644c8ee97b9e
--- /dev/null
+++ b/mm/shuffle.h
@@ -0,0 +1,52 @@
+// SPDX-License-Identifier: GPL-2.0
+// Copyright(c) 2018 Intel Corporation. All rights reserved.
+#ifndef _MM_SHUFFLE_H
+#define _MM_SHUFFLE_H
+#include <linux/jump_label.h>
+
+/*
+ * SHUFFLE_ENABLE is called from the command line enabling path, or by
+ * platform-firmware enabling that indicates the presence of a
+ * direct-mapped memory-side-cache. SHUFFLE_FORCE_DISABLE is called from
+ * the command line path and overrides any previous or future
+ * SHUFFLE_ENABLE.
+ */
+enum mm_shuffle_ctl {
+	SHUFFLE_ENABLE,
+	SHUFFLE_FORCE_DISABLE,
+};
+
+#define SHUFFLE_ORDER (MAX_ORDER-1)
+
+#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
+DECLARE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
+extern void page_alloc_shuffle(enum mm_shuffle_ctl ctl);
+extern void __shuffle_free_memory(pg_data_t *pgdat);
+static inline void shuffle_free_memory(pg_data_t *pgdat)
+{
+	if (!static_branch_unlikely(&page_alloc_shuffle_key))
+		return;
+	__shuffle_free_memory(pgdat);
+}
+
+extern void __shuffle_zone(struct zone *z);
+static inline void shuffle_zone(struct zone *z)
+{
+	if (!static_branch_unlikely(&page_alloc_shuffle_key))
+		return;
+	__shuffle_zone(z);
+}
+#else
+static inline void shuffle_free_memory(pg_data_t *pgdat)
+{
+}
+
+static inline void shuffle_zone(struct zone *z)
+{
+}
+
+static inline void page_alloc_shuffle(enum mm_shuffle_ctl ctl)
+{
+}
+#endif
+#endif /* _MM_SHUFFLE_H */

