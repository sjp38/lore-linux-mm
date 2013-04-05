Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 13D166B0093
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 06:00:50 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 1/2] memcg: consistently use vmalloc for page_cgroup allocations
Date: Fri,  5 Apr 2013 14:01:11 +0400
Message-Id: <1365156072-24100-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1365156072-24100-1-git-send-email-glommer@parallels.com>
References: <1365156072-24100-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>

Right now, allocation for page_cgroup is a bit complicated, dependent on
a variety of system conditions:

For flat memory, we are likely to need quite big pages, so the page
allocator won't cut. We are forced to init flatmem mappings very early,
because if we run after the page allocator is in place those allocations
will be denied. Flatmem mappings thus resort to the bootmem allocator.

We can fix this by using vmalloc for flatmem mappings. However, we now
have the situation in which flatmem mapping allocate using vmalloc, but
sparsemem may or may not allocate with vmalloc. It will try the
page_allocator first, and retry vmalloc if it fails.

With that change in place, not only we *can* move
page_cgroup_flatmem_init, but we absolutely must move it. It now needs
to run with vmalloc enabled. Instead of just moving it after vmalloc, we
will move it together with the normal page_cgroup initialization. It
becomes then natural to merge them into a single name.

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 include/linux/page_cgroup.h | 15 ---------------
 init/main.c                 |  1 -
 mm/page_cgroup.c            | 24 ++++++++++--------------
 3 files changed, 10 insertions(+), 30 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 777a524..4860eca 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -29,17 +29,7 @@ struct page_cgroup {
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
 
-#ifdef CONFIG_SPARSEMEM
-static inline void __init page_cgroup_init_flatmem(void)
-{
-}
 extern void __init page_cgroup_init(void);
-#else
-void __init page_cgroup_init_flatmem(void);
-static inline void __init page_cgroup_init(void)
-{
-}
-#endif
 
 struct page_cgroup *lookup_page_cgroup(struct page *page);
 struct page *lookup_cgroup_page(struct page_cgroup *pc);
@@ -97,11 +87,6 @@ static inline struct page_cgroup *lookup_page_cgroup(struct page *page)
 static inline void page_cgroup_init(void)
 {
 }
-
-static inline void __init page_cgroup_init_flatmem(void)
-{
-}
-
 #endif /* CONFIG_MEMCG */
 
 #include <linux/swap.h>
diff --git a/init/main.c b/init/main.c
index cee4b5c..494774f 100644
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
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 6d757e3..84bca4b 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -53,9 +53,7 @@ static int __init alloc_node_page_cgroup(int nid)
 		return 0;
 
 	table_size = sizeof(struct page_cgroup) * nr_pages;
-
-	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
-			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	base = vzalloc_node(table_size, nid);
 	if (!base)
 		return -ENOMEM;
 	NODE_DATA(nid)->node_page_cgroup = base;
@@ -63,7 +61,7 @@ static int __init alloc_node_page_cgroup(int nid)
 	return 0;
 }
 
-void __init page_cgroup_init_flatmem(void)
+void __init page_cgroup_init(void)
 {
 
 	int nid, fail;
@@ -105,38 +103,37 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 	return section->page_cgroup + pfn;
 }
 
-static void *__meminit alloc_page_cgroup(size_t size, int nid)
+static void *alloc_page_cgroup(int nid)
 {
 	gfp_t flags = GFP_KERNEL | __GFP_ZERO | __GFP_NOWARN;
 	void *addr = NULL;
+	size_t table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
 
-	addr = alloc_pages_exact_nid(nid, size, flags);
+	addr = alloc_pages_exact_nid(nid, table_size, flags);
 	if (addr) {
-		kmemleak_alloc(addr, size, 1, flags);
+		kmemleak_alloc(addr, table_size, 1, flags);
 		return addr;
 	}
 
 	if (node_state(nid, N_HIGH_MEMORY))
-		addr = vzalloc_node(size, nid);
+		addr = vzalloc_node(table_size, nid);
 	else
-		addr = vzalloc(size);
+		addr = vzalloc(table_size);
 
 	return addr;
 }
 
-static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
+static int init_section_page_cgroup(unsigned long pfn, int nid)
 {
 	struct mem_section *section;
 	struct page_cgroup *base;
-	unsigned long table_size;
 
 	section = __pfn_to_section(pfn);
 
 	if (section->page_cgroup)
 		return 0;
 
-	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
-	base = alloc_page_cgroup(table_size, nid);
+	base = alloc_page_cgroup(nid);
 
 	/*
 	 * The value stored in section->page_cgroup is (base - pfn)
@@ -156,7 +153,6 @@ static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
 	 */
 	pfn &= PAGE_SECTION_MASK;
 	section->page_cgroup = base - pfn;
-	total_usage += table_size;
 	return 0;
 }
 #ifdef CONFIG_MEMORY_HOTPLUG
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
