Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 121346B026A
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 02:59:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x2-v6so1418541plv.0
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 23:59:29 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v17-v6si3767686pgk.135.2018.07.04.23.59.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 23:59:27 -0700 (PDT)
Subject: [PATCH 05/13] mm: Allow an external agent to wait for memmap
 initialization
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jul 2018 23:49:29 -0700
Message-ID: <153077336917.40830.18168280108339589938.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, vishal.l.verma@intel.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now that memmap_init_zone() knows how to split the init work into
multiple threads, allow the tracking for those threads to be handled
via a passed in 'struct memmap_async_state' instance.

This infrastructure allows devm_memremap_pages() users, like the pmem
driver, to track memmap initialization in the backgroud, and use
memmap_sync() when it performs an operation that may result in a
pfn_to_page(), like dax mapping a pfn into userspace.

The approach mirrors what is done for background memmap initialization
and defers waiting for initialization to complete until the first
userspace consumer arrives.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/memmap_async.h |   10 ++++
 include/linux/memremap.h     |   29 ++++++++++++
 kernel/memremap.c            |   65 ++++++++++++++++-----------
 mm/page_alloc.c              |  102 +++++++++++++++++++++++++++++++++++++-----
 4 files changed, 169 insertions(+), 37 deletions(-)

diff --git a/include/linux/memmap_async.h b/include/linux/memmap_async.h
index d2011681a910..4633eca9290e 100644
--- a/include/linux/memmap_async.h
+++ b/include/linux/memmap_async.h
@@ -3,6 +3,9 @@
 #define __LINUX_MEMMAP_ASYNC_H
 #include <linux/async.h>
 #include <linux/ioport.h>
+#include <linux/async.h>
+#include <linux/pfn_t.h>
+#include <linux/radix-tree.h>
 
 struct dev_pagemap;
 struct vmem_altmap;
@@ -32,14 +35,21 @@ struct memmap_init_memmap {
 };
 
 struct memmap_init_pages {
+	int id;
 	struct resource res;
+	async_cookie_t cookie;
 	struct memmap_init_env *env;
 };
 
 struct memmap_async_state {
 	struct memmap_init_env env;
 	struct memmap_init_memmap memmap;
+	struct memmap_init_pages page_init[NR_MEMMAP_THREADS];
+	unsigned long active[BITS_TO_LONGS(NR_MEMMAP_THREADS)];
+	struct radix_tree_root pfn_to_thread;
 };
 
 extern struct async_domain memmap_init_domain;
+extern void memmap_sync(pfn_t pfn, unsigned long nr_pages,
+		struct memmap_async_state *async);
 #endif /* __LINUX_MEMMAP_ASYNC_H */
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index bfdc7363b13b..a2313fadd686 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -1,6 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 #ifndef _LINUX_MEMREMAP_H_
 #define _LINUX_MEMREMAP_H_
+#include <linux/pfn.h>
 #include <linux/ioport.h>
 #include <linux/percpu-refcount.h>
 
@@ -101,6 +102,7 @@ typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
 				pmd_t *pmdp);
 typedef void (*dev_page_free_t)(struct page *page, void *data);
 
+struct memmap_async_state;
 /**
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
  * @page_fault: callback when CPU fault on an unaddressable device page
@@ -112,6 +114,7 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
  * @dev: host device of the mapping for debug
  * @data: private data pointer for page_free()
  * @type: memory type: see MEMORY_* in memory_hotplug.h
+ * @async: async memmap init context
  */
 struct dev_pagemap {
 	dev_page_fault_t page_fault;
@@ -124,8 +127,34 @@ struct dev_pagemap {
 	struct device *dev;
 	void *data;
 	enum memory_type type;
+	struct memmap_async_state *async;
 };
 
+static inline unsigned long order_at(struct resource *res, unsigned long pgoff)
+{
+	unsigned long phys_pgoff = PHYS_PFN(res->start) + pgoff;
+	unsigned long nr_pages, mask;
+
+	nr_pages = PHYS_PFN(resource_size(res));
+	if (nr_pages == pgoff)
+		return ULONG_MAX;
+
+	/*
+	 * What is the largest aligned power-of-2 range available from
+	 * this resource pgoff to the end of the resource range,
+	 * considering the alignment of the current pgoff?
+	 */
+	mask = phys_pgoff | rounddown_pow_of_two(nr_pages - pgoff);
+	if (!mask)
+		return ULONG_MAX;
+
+	return find_first_bit(&mask, BITS_PER_LONG);
+}
+
+#define foreach_order_pgoff(res, order, pgoff) \
+	for (pgoff = 0, order = order_at((res), pgoff); order < ULONG_MAX; \
+			pgoff += 1UL << order, order = order_at((res), pgoff))
+
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
 		void (*kill)(struct percpu_ref *));
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 85e4a7c576b2..18719a596be5 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -7,6 +7,7 @@
 #include <linux/io.h>
 #include <linux/mm.h>
 #include <linux/memory_hotplug.h>
+#include <linux/memmap_async.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/wait_bit.h>
@@ -16,31 +17,6 @@ static RADIX_TREE(pgmap_radix, GFP_KERNEL);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
-static unsigned long order_at(struct resource *res, unsigned long pgoff)
-{
-	unsigned long phys_pgoff = PHYS_PFN(res->start) + pgoff;
-	unsigned long nr_pages, mask;
-
-	nr_pages = PHYS_PFN(resource_size(res));
-	if (nr_pages == pgoff)
-		return ULONG_MAX;
-
-	/*
-	 * What is the largest aligned power-of-2 range available from
-	 * this resource pgoff to the end of the resource range,
-	 * considering the alignment of the current pgoff?
-	 */
-	mask = phys_pgoff | rounddown_pow_of_two(nr_pages - pgoff);
-	if (!mask)
-		return ULONG_MAX;
-
-	return find_first_bit(&mask, BITS_PER_LONG);
-}
-
-#define foreach_order_pgoff(res, order, pgoff) \
-	for (pgoff = 0, order = order_at((res), pgoff); order < ULONG_MAX; \
-			pgoff += 1UL << order, order = order_at((res), pgoff))
-
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
 int device_private_entry_fault(struct vm_area_struct *vma,
 		       unsigned long addr,
@@ -113,15 +89,46 @@ static unsigned long pfn_next(unsigned long pfn)
 #define for_each_device_pfn(pfn, map) \
 	for (pfn = pfn_first(map); pfn < pfn_end(map); pfn = pfn_next(pfn))
 
+static void kill_memmap_async(struct memmap_async_state *async)
+{
+	struct radix_tree_iter iter;
+	void *slot;
+	int i;
+
+	if (!async)
+		return;
+
+	for (i = 0; i < NR_MEMMAP_THREADS; i++) {
+		async_cookie_t cookie;
+
+		if (!test_bit(i, async->active))
+			continue;
+
+		cookie = async->page_init[i].cookie;
+		async_synchronize_cookie_domain(cookie+1, &memmap_init_domain);
+	}
+	radix_tree_for_each_slot(slot, &async->pfn_to_thread, &iter, 0)
+		radix_tree_delete(&async->pfn_to_thread, iter.index);
+}
+
 static void devm_memremap_pages_release(void *data)
 {
 	struct dev_pagemap *pgmap = data;
 	struct device *dev = pgmap->dev;
 	struct resource *res = &pgmap->res;
 	resource_size_t align_start, align_size;
+	struct memmap_async_state *async = pgmap->async;
 	unsigned long pfn;
 
+	/*
+	 * Once the pgmap is killed pgmap owners must disallow new
+	 * direct_access / page mapping requests. I.e. memmap_sync()
+	 * users must not race the teardown of the async->pfn_to_thread
+	 * radix.
+	 */
 	pgmap->kill(pgmap->ref);
+	kill_memmap_async(async);
+
 	for_each_device_pfn(pfn, pgmap)
 		put_page(pfn_to_page(pfn));
 
@@ -240,7 +247,13 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
 		struct zone *zone;
 
 		error = arch_add_memory(nid, align_start, align_size, altmap,
-				false, NULL);
+				false, pgmap->async);
+		if (error == -EWOULDBLOCK) {
+			/* fall back to synchronous */
+			pgmap->async = NULL;
+			error = arch_add_memory(nid, align_start, align_size,
+					altmap, false, NULL);
+		}
 		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
 		if (!error)
 			move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d0ed17cf305..d1466dd82bc2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -68,6 +68,7 @@
 #include <linux/ftrace.h>
 #include <linux/lockdep.h>
 #include <linux/async.h>
+#include <linux/pfn_t.h>
 #include <linux/nmi.h>
 
 #include <asm/sections.h>
@@ -5510,12 +5511,80 @@ static void __ref memmap_init_async(void *data, async_cookie_t cookie)
 {
 	struct memmap_init_pages *args = data;
 	struct memmap_init_env *env = args->env;
+	struct dev_pagemap *pgmap = env->pgmap;
+	struct memmap_async_state *async = pgmap ? pgmap->async : NULL;
 	struct resource *res = &args->res;
 	unsigned long pfn;
 
+	if (async)
+		async_synchronize_cookie_domain(async->memmap.cookie+1,
+				&memmap_init_domain);
+
 	for (pfn = PHYS_PFN(res->start); pfn < PHYS_PFN(res->end+1); pfn++)
 		memmap_init_one(pfn, env->zone, env->nid, env->context,
-				env->pgmap);
+				pgmap);
+	if (async)
+		clear_bit(args->id, async->active);
+}
+
+void memmap_sync(pfn_t pfn, unsigned long nr_pages,
+		struct memmap_async_state *async)
+{
+	struct memmap_init_pages *args, *start, *end;
+	unsigned long raw_pfn = pfn_t_to_pfn(pfn);
+
+	if (!async || !pfn_t_has_page(pfn)
+			|| !bitmap_weight(async->active, NR_MEMMAP_THREADS))
+		return;
+
+	start = radix_tree_lookup(&async->pfn_to_thread, raw_pfn);
+	end = radix_tree_lookup(&async->pfn_to_thread, raw_pfn + nr_pages - 1);
+	if (!start || !end) {
+		WARN_ON_ONCE(1);
+		return;
+	}
+
+	for (args = start; args <= end; args++) {
+		int id = args - &async->page_init[0];
+
+		async_synchronize_cookie_domain(args->cookie+1,
+				&memmap_init_domain);
+		pr_debug("%s: pfn: %#lx nr: %ld thread: %d\n",
+				__func__, raw_pfn, nr_pages, id);
+	}
+}
+EXPORT_SYMBOL_GPL(memmap_sync);
+
+static bool run_memmap_init(struct memmap_init_pages *thread,
+		struct memmap_async_state *async, struct async_domain *domain)
+{
+	struct resource *res = &thread->res;
+	unsigned long pgoff;
+	int order;
+
+	if (!async) {
+		async_schedule_domain(memmap_init_async, thread, domain);
+		return false;
+	}
+
+	thread->cookie = async_schedule_domain(memmap_init_async,
+			thread, domain);
+	set_bit(thread->id, async->active);
+	foreach_order_pgoff(res, order, pgoff) {
+		int rc = __radix_tree_insert(&async->pfn_to_thread,
+				PHYS_PFN(res->start) + pgoff, order, thread);
+		if (rc) {
+			/*
+			 * Mark all threads inactive, and by returning
+			 * false we'll sync all threads before returning
+			 * from memmap_init_zone().
+			 */
+			memset(async->active, 0, sizeof(unsigned long)
+					* BITS_TO_LONGS(NR_MEMMAP_THREADS));
+			return false;
+		}
+	}
+	return true;
 }
 
 /*
@@ -5554,33 +5623,44 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		 * function.  They do not exist on hotplugged memory.
 		 */
 		ASYNC_DOMAIN_EXCLUSIVE(local);
-		struct memmap_init_pages args[NR_MEMMAP_THREADS];
-		struct memmap_init_env env = {
-			.nid = nid,
-			.zone = zone,
-			.pgmap = pgmap,
-			.context = context,
-		};
+		struct memmap_async_state *async = pgmap ? pgmap->async : NULL;
+		struct memmap_init_pages _args[NR_MEMMAP_THREADS];
+		struct memmap_init_pages *args = async ? async->page_init : _args;
+		struct async_domain *domain;
+		struct memmap_init_env _env;
+		struct memmap_init_env *env = async ? &async->env : &_env;
 		unsigned long step, rem;
+		bool sync = !async;
 		int i;
 
+		domain = async ? &memmap_init_domain : &local;
+		env->pgmap = pgmap;
+		env->nid = nid;
+		env->zone = zone;
+		env->context = context;
+
 		size = end_pfn - start_pfn;
 		step = size / NR_MEMMAP_THREADS;
 		rem = size % NR_MEMMAP_THREADS;
+		if (async)
+			INIT_RADIX_TREE(&async->pfn_to_thread, GFP_KERNEL);
 		for (i = 0; i < NR_MEMMAP_THREADS; i++) {
 			struct memmap_init_pages *t = &args[i];
 
-			t->env = &env;
+			t->id = i;
+			t->env = env;
 			t->res.start = PFN_PHYS(start_pfn);
 			t->res.end = PFN_PHYS(start_pfn + step) - 1;
 			if (i == NR_MEMMAP_THREADS-1)
 				t->res.end += PFN_PHYS(rem);
 
-			async_schedule_domain(memmap_init_async, t, &local);
+			if (!run_memmap_init(t, async, domain))
+				sync = true;
 
 			start_pfn += step;
 		}
-		async_synchronize_full_domain(&local);
+		if (sync)
+			async_synchronize_full_domain(domain);
 		return;
 	}
 
