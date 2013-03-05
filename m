Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 960436B0009
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 08:11:02 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 4/5] memcg: do not call page_cgroup_init at system_boot
Date: Tue,  5 Mar 2013 17:10:57 +0400
Message-Id: <1362489058-3455-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1362489058-3455-1-git-send-email-glommer@parallels.com>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, anton.vorontsov@linaro.org, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

If we are not using memcg, there is no reason why we should allocate
this structure, that will be a memory waste at best. We can do better
at least in the sparsemem case, and allocate it when the first cgroup
is requested. It should now not panic on failure, and we have to handle
this right.

flatmem case is a bit more complicated, so that one is left out for
the moment.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/page_cgroup.h |  28 +++++----
 init/main.c                 |   2 -
 mm/memcontrol.c             |   3 +-
 mm/page_cgroup.c            | 150 ++++++++++++++++++++++++--------------------
 4 files changed, 99 insertions(+), 84 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 777a524..ec9fb05 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -14,6 +14,7 @@ enum {
 
 #ifdef CONFIG_MEMCG
 #include <linux/bit_spinlock.h>
+#include <linux/mmzone.h>
 
 /*
  * Page Cgroup can be considered as an extended mem_map.
@@ -27,19 +28,17 @@ struct page_cgroup {
 	struct mem_cgroup *mem_cgroup;
 };
 
-void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
-
-#ifdef CONFIG_SPARSEMEM
-static inline void __init page_cgroup_init_flatmem(void)
+static inline size_t page_cgroup_table_size(int nid)
 {
-}
-extern void __init page_cgroup_init(void);
+#ifdef CONFIG_SPARSEMEM
+	return sizeof(struct page_cgroup) * PAGES_PER_SECTION;
 #else
-void __init page_cgroup_init_flatmem(void);
-static inline void __init page_cgroup_init(void)
-{
-}
+	return sizeof(struct page_cgroup) * NODE_DATA(nid)->node_spanned_pages;
 #endif
+}
+void pgdat_page_cgroup_init(struct pglist_data *pgdat);
+
+extern int page_cgroup_init(void);
 
 struct page_cgroup *lookup_page_cgroup(struct page *page);
 struct page *lookup_cgroup_page(struct page_cgroup *pc);
@@ -85,7 +84,7 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 #else /* CONFIG_MEMCG */
 struct page_cgroup;
 
-static inline void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
+static inline void pgdat_page_cgroup_init(struct pglist_data *pgdat)
 {
 }
 
@@ -94,7 +93,12 @@ static inline struct page_cgroup *lookup_page_cgroup(struct page *page)
 	return NULL;
 }
 
-static inline void page_cgroup_init(void)
+static inline int page_cgroup_init(void)
+{
+	return 0;
+}
+
+static inline void page_cgroup_destroy(void)
 {
 }
 
diff --git a/init/main.c b/init/main.c
index cee4b5c..1fb3ec0 100644
--- a/init/main.c
+++ b/init/main.c
@@ -457,7 +457,6 @@ static void __init mm_init(void)
 	 * page_cgroup requires contiguous pages,
 	 * bigger than MAX_ORDER unless SPARSEMEM.
 	 */
-	page_cgroup_init_flatmem();
 	mem_init();
 	kmem_cache_init();
 	percpu_init_late();
@@ -592,7 +591,6 @@ asmlinkage void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
-	page_cgroup_init();
 	debug_objects_mem_init();
 	kmemleak_init();
 	setup_per_cpu_pageset();
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 45c1886..6019a32 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6377,7 +6377,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 		res_counter_init(&memcg->res, NULL);
 		res_counter_init(&memcg->memsw, NULL);
 		res_counter_init(&memcg->kmem, NULL);
-	}
+	} else if (page_cgroup_init())
+		goto free_out;
 
 	memcg->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&memcg->oom_notify);
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index a5bd322..6d04c28 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -12,11 +12,50 @@
 #include <linux/kmemleak.h>
 
 static unsigned long total_usage;
+static unsigned long page_cgroup_initialized;
 
-#if !defined(CONFIG_SPARSEMEM)
+static void *alloc_page_cgroup(size_t size, int nid)
+{
+	gfp_t flags = GFP_KERNEL | __GFP_ZERO | __GFP_NOWARN;
+	void *addr = NULL;
+
+	addr = alloc_pages_exact_nid(nid, size, flags);
+	if (addr) {
+		kmemleak_alloc(addr, size, 1, flags);
+		return addr;
+	}
+
+	if (node_state(nid, N_HIGH_MEMORY))
+		addr = vzalloc_node(size, nid);
+	else
+		addr = vzalloc(size);
 
+	return addr;
+}
 
-void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
+static void free_page_cgroup(void *addr)
+{
+	if (is_vmalloc_addr(addr)) {
+		vfree(addr);
+	} else {
+		struct page *page = virt_to_page(addr);
+		int nid = page_to_nid(page);
+		BUG_ON(PageReserved(page));
+		free_pages_exact(addr, page_cgroup_table_size(nid));
+	}
+}
+
+static void page_cgroup_msg(void)
+{
+	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
+	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you "
+			 "don't want memory cgroups.\nAlternatively, consider "
+			 "deferring your memory cgroups creation.\n");
+}
+
+#if !defined(CONFIG_SPARSEMEM)
+
+void pgdat_page_cgroup_init(struct pglist_data *pgdat)
 {
 	pgdat->node_page_cgroup = NULL;
 }
@@ -42,20 +81,16 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 	return base + offset;
 }
 
-static int __init alloc_node_page_cgroup(int nid)
+static int alloc_node_page_cgroup(int nid)
 {
 	struct page_cgroup *base;
 	unsigned long table_size;
-	unsigned long nr_pages;
 
-	nr_pages = NODE_DATA(nid)->node_spanned_pages;
-	if (!nr_pages)
+	table_size = page_cgroup_table_size(nid);
+	if (!table_size)
 		return 0;
 
-	table_size = sizeof(struct page_cgroup) * nr_pages;
-
-	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
-			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	base = alloc_page_cgroup(table_size, nid);
 	if (!base)
 		return -ENOMEM;
 	NODE_DATA(nid)->node_page_cgroup = base;
@@ -63,27 +98,29 @@ static int __init alloc_node_page_cgroup(int nid)
 	return 0;
 }
 
-void __init page_cgroup_init_flatmem(void)
+int page_cgroup_init(void)
 {
+	int nid, fail, tmpnid;
 
-	int nid, fail;
-
-	if (mem_cgroup_subsys_disabled())
-		return;
+	/* only initialize it once */
+	if (test_and_set_bit(0, &page_cgroup_initialized))
+		return 0;
 
 	for_each_online_node(nid)  {
 		fail = alloc_node_page_cgroup(nid);
 		if (fail)
 			goto fail;
 	}
-	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you"
-	" don't want memory cgroups\n");
-	return;
+	page_cgroup_msg();
+	return 0;
 fail:
-	printk(KERN_CRIT "allocation of page_cgroup failed.\n");
-	printk(KERN_CRIT "please try 'cgroup_disable=memory' boot option\n");
-	panic("Out of memory");
+	for_each_online_node(tmpnid)  {
+		if (tmpnid >= nid)
+			break;
+		free_page_cgroup(NODE_DATA(tmpnid)->node_page_cgroup);
+	}
+
+	return -ENOMEM;
 }
 
 #else /* CONFIG_FLAT_NODE_MEM_MAP */
@@ -105,26 +142,7 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 	return section->page_cgroup + pfn;
 }
 
-static void *__meminit alloc_page_cgroup(size_t size, int nid)
-{
-	gfp_t flags = GFP_KERNEL | __GFP_ZERO | __GFP_NOWARN;
-	void *addr = NULL;
-
-	addr = alloc_pages_exact_nid(nid, size, flags);
-	if (addr) {
-		kmemleak_alloc(addr, size, 1, flags);
-		return addr;
-	}
-
-	if (node_state(nid, N_HIGH_MEMORY))
-		addr = vzalloc_node(size, nid);
-	else
-		addr = vzalloc(size);
-
-	return addr;
-}
-
-static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
+static int init_section_page_cgroup(unsigned long pfn, int nid)
 {
 	struct mem_section *section;
 	struct page_cgroup *base;
@@ -135,7 +153,7 @@ static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
 	if (section->page_cgroup)
 		return 0;
 
-	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
+	table_size = page_cgroup_table_size(nid);
 	base = alloc_page_cgroup(table_size, nid);
 
 	/*
@@ -159,20 +177,6 @@ static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
 	total_usage += table_size;
 	return 0;
 }
-#ifdef CONFIG_MEMORY_HOTPLUG
-static void free_page_cgroup(void *addr)
-{
-	if (is_vmalloc_addr(addr)) {
-		vfree(addr);
-	} else {
-		struct page *page = virt_to_page(addr);
-		size_t table_size =
-			sizeof(struct page_cgroup) * PAGES_PER_SECTION;
-
-		BUG_ON(PageReserved(page));
-		free_pages_exact(addr, table_size);
-	}
-}
 
 void __free_page_cgroup(unsigned long pfn)
 {
@@ -187,6 +191,7 @@ void __free_page_cgroup(unsigned long pfn)
 	ms->page_cgroup = NULL;
 }
 
+#ifdef CONFIG_MEMORY_HOTPLUG
 int __meminit online_page_cgroup(unsigned long start_pfn,
 			unsigned long nr_pages,
 			int nid)
@@ -266,16 +271,16 @@ static int __meminit page_cgroup_callback(struct notifier_block *self,
 
 #endif
 
-void __init page_cgroup_init(void)
+int page_cgroup_init(void)
 {
 	unsigned long pfn;
-	int nid;
+	unsigned long start_pfn, end_pfn;
+	int nid, tmpnid;
 
-	if (mem_cgroup_subsys_disabled())
-		return;
+	if (test_and_set_bit(0, &page_cgroup_initialized))
+		return 0;
 
 	for_each_node_state(nid, N_MEMORY) {
-		unsigned long start_pfn, end_pfn;
 
 		start_pfn = node_start_pfn(nid);
 		end_pfn = node_end_pfn(nid);
@@ -303,16 +308,23 @@ void __init page_cgroup_init(void)
 		}
 	}
 	hotplug_memory_notifier(page_cgroup_callback, 0);
-	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you "
-			 "don't want memory cgroups\n");
-	return;
+	page_cgroup_msg();
+	return 0;
 oom:
-	printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
-	panic("Out of memory");
+	for_each_node_state(tmpnid, N_MEMORY) {
+		if (tmpnid >= nid)
+			break;
+
+		start_pfn = node_start_pfn(tmpnid);
+		end_pfn = node_end_pfn(tmpnid);
+
+		for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION)
+			__free_page_cgroup(pfn);
+	}
+	return -ENOMEM;
 }
 
-void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
+void pgdat_page_cgroup_init(struct pglist_data *pgdat)
 {
 	return;
 }
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
