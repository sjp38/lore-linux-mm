Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31BEC6B026F
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:10:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e7-v6so5425028pfe.10
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:10:53 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a36-v6si30529821pla.207.2018.07.16.10.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 10:10:51 -0700 (PDT)
Subject: [PATCH v2 06/14] mm: Allow an external agent to coordinate memmap
 initialization
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Jul 2018 10:00:53 -0700
Message-ID: <153176045309.12695.12132071237805092489.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Daniel Jordan <daniel.m.jordan@oracle.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, vishal.l.verma@intel.com, linux-mm@kvack.org, jack@suse.cz, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

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

When that consumer does arrive it can take over a portion of the page
initialization in the foreground to minimize delays even further.

Cc: Michal Hocko <mhocko@suse.com>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/memmap_async.h |   32 ++++++++
 include/linux/memremap.h     |    4 +
 kernel/memremap.c            |   40 ++++++++++
 mm/page_alloc.c              |  162 ++++++++++++++++++++++++++++++++++++++----
 4 files changed, 223 insertions(+), 15 deletions(-)

diff --git a/include/linux/memmap_async.h b/include/linux/memmap_async.h
index 2b1a0636d5bb..5a3bfdce94e4 100644
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
@@ -14,6 +17,15 @@ struct vmem_altmap;
  */
 #define NR_MEMMAP_THREADS 8
 
+/*
+ * Number of sub-ranges that can be scrubbed on demand. For example, a
+ * caller of memmap_sync() will attempt to lock out an init thread and
+ * scrub 1/128th of the thread's range itself to satisfy the immediate
+ * request, and then let the background continue initializing the
+ * remainder.
+ */
+#define NR_MEMMAP_RANGE 128
+
 /**
  * struct memmap_init_env - common global data for all async memmap operations
  * @altmap: set-aside / alternative memory for allocating the memmap
@@ -50,29 +62,49 @@ struct memmap_init_memmap {
 
 /**
  * struct memmap_init_pages - arguments for async 'struct page' init
+ * @id: thread id 0..NR_MEMMAP_THREADS (per struct memmap_async_state instance)
+ * @lock: coordinate on-demand vs background initialization
  * @res: range for one instance of memmap_init_async() to operate
+ * @cookie: async cookie for awaiting completion of all thread work
  * @env: link to thread range invariant parameters
+ * @range_pending: track init work in NR_MEMMAP_RANGE sub-ranges
  */
 struct memmap_init_pages {
+	int id;
+	struct mutex lock;
 	struct resource res;
+	async_cookie_t cookie;
 	struct memmap_init_env *env;
+	unsigned long range_pending[BITS_TO_LONGS(NR_MEMMAP_RANGE)];
 };
 
 /**
  * struct memmap_async_state - support and track async memmap operations
  * @env: storage for common memmap init parameters
  * @memmap: storage for background page-table setup operations
+ * @page_init: storage for background 'struct page' init operations
+ * @active: summary status of all threads associated with this async instance
+ * @pfn_to_thread: lookup the thread responsible for initializing @pfn
  *
  * An instance of this object is passed to the memory hotplug
  * infrastructure to indicate that memory hotplug work should be
  * delegated to background threads. The caller takes responsibility for
  * waiting for those threads to complete before calling pfn_to_page() on
  * any new page.
+ *
+ * The memmap_sync() routine allows for on-demand initialization of a
+ * given pfn range when a caller has an immediate need for a page.
  */
 struct memmap_async_state {
 	struct memmap_init_env env;
 	struct memmap_init_memmap memmap;
+	struct memmap_init_pages page_init[NR_MEMMAP_THREADS];
+	unsigned long active[BITS_TO_LONGS(NR_MEMMAP_THREADS)];
+	struct radix_tree_root pfn_to_thread;
 };
 
 extern struct async_domain memmap_init_domain;
+extern struct async_domain memmap_pages_domain;
+extern void memmap_sync(pfn_t pfn, unsigned long nr_pages,
+		struct memmap_async_state *async);
 #endif /* __LINUX_MEMMAP_ASYNC_H */
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index bff314de3f55..a2313fadd686 100644
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
@@ -124,6 +127,7 @@ struct dev_pagemap {
 	struct device *dev;
 	void *data;
 	enum memory_type type;
+	struct memmap_async_state *async;
 };
 
 static inline unsigned long order_at(struct resource *res, unsigned long pgoff)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index fc2f28033460..948826be16b0 100644
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
@@ -88,15 +89,46 @@ static unsigned long pfn_next(unsigned long pfn)
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
+		async_synchronize_cookie_domain(cookie+1, &memmap_pages_domain);
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
 
@@ -215,7 +247,13 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
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
index 71e3f01a1548..b9615a59d29d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -68,6 +68,7 @@
 #include <linux/ftrace.h>
 #include <linux/lockdep.h>
 #include <linux/async.h>
+#include <linux/pfn_t.h>
 #include <linux/nmi.h>
 
 #include <asm/sections.h>
@@ -5455,6 +5456,7 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
 }
 
 ASYNC_DOMAIN_EXCLUSIVE(memmap_init_domain);
+ASYNC_DOMAIN_EXCLUSIVE(memmap_pages_domain);
 
 static void __meminit memmap_init_one(unsigned long pfn, unsigned long zone,
 		int nid, enum memmap_context context, struct dev_pagemap *pgmap)
@@ -5506,18 +5508,137 @@ static void __meminit memmap_init_one(unsigned long pfn, unsigned long zone,
 	}
 }
 
-static void __ref memmap_init_async(void *data, async_cookie_t cookie)
+static unsigned long memmap_range_size(struct memmap_init_pages *args)
+{
+	return DIV_ROUND_UP(PHYS_PFN(args->res.end + 1)
+			- PHYS_PFN(args->res.start), NR_MEMMAP_RANGE);
+}
+
+static void __ref memmap_init_range(struct memmap_init_pages *args, int range_id)
 {
-	struct memmap_init_pages *args = data;
 	struct memmap_init_env *env = args->env;
+	unsigned long range_start, range_end;
 	struct resource *res = &args->res;
-	unsigned long pfn, start, end;
+	unsigned long pfn, start, end, range_size;
 
 	start = PHYS_PFN(res->start);
 	end = PHYS_PFN(res->end+1);
-	for (pfn = start; pfn < end; pfn++)
+	range_size = memmap_range_size(args);
+
+	mutex_lock(&args->lock);
+	if (!test_and_clear_bit(range_id, args->range_pending)) {
+		mutex_unlock(&args->lock);
+		return;
+	}
+	range_start = start + range_id * range_size;
+	range_end = min(range_start + range_size, end);
+	for (pfn = range_start; pfn < range_end; pfn++)
 		memmap_init_one(pfn, env->zone, env->nid, env->context,
 				env->pgmap);
+	mutex_unlock(&args->lock);
+}
+
+static void __ref memmap_init_async(void *data, async_cookie_t cookie)
+{
+	int i;
+	struct memmap_init_pages *args = data;
+	struct memmap_init_env *env = args->env;
+	struct dev_pagemap *pgmap = env->pgmap;
+	struct memmap_async_state *async = pgmap ? pgmap->async : NULL;
+
+	if (async)
+		async_synchronize_cookie_domain(async->memmap.cookie+1,
+				&memmap_init_domain);
+
+	for (i = 0; i < NR_MEMMAP_RANGE; i++)
+		memmap_init_range(args, i);
+
+	if (async)
+		clear_bit(args->id, async->active);
+}
+
+static void memmap_sync_range(struct memmap_init_pages *args,
+		unsigned long start, unsigned long end,
+		unsigned long range_size)
+{
+	int i, nr_range, range_id;
+
+	range_id = (start - PHYS_PFN(args->res.start)) / range_size;
+	nr_range = (end - start) / range_size;
+	if ((end - start) % range_size)
+		nr_range++;
+
+	for (i = range_id; i < range_id + nr_range; i++) {
+		memmap_init_range(args, i);
+		pr_debug("%s: thread: %d start: %#lx end: %#lx range: %d\n",
+				__func__, args->id, start, end, i);
+	}
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
+	async_synchronize_cookie_domain(async->memmap.cookie+1,
+			&memmap_init_domain);
+
+	for (args = start; args <= end; args++) {
+		unsigned long range_size = memmap_range_size(args);
+		unsigned long end = min(raw_pfn + nr_pages,
+				PHYS_PFN(args->res.end + 1));
+		unsigned long synced;
+
+		memmap_sync_range(args, raw_pfn, end, range_size);
+		synced = end - raw_pfn;
+		nr_pages -= synced;
+		raw_pfn += synced;
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
@@ -5556,33 +5677,46 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
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
 
+		domain = async ? &memmap_pages_domain : &local;
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
+			mutex_init(&t->lock);
+			bitmap_fill(t->range_pending, NR_MEMMAP_RANGE);
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
 
