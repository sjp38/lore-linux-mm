Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 812796B0259
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 06:29:03 -0400 (EDT)
Received: by iofh134 with SMTP id h134so195761420iof.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 03:29:03 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j9si11339499ige.71.2015.09.15.03.28.59
        for <linux-mm@kvack.org>;
        Tue, 15 Sep 2015 03:28:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 6/7] mm: use 'unsigned int' for page order
Date: Tue, 15 Sep 2015 13:28:14 +0300
Message-Id: <1442312895-124384-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1442312895-124384-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1442312895-124384-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's try to be consistent about data type of page order.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h |  5 +++--
 mm/hugetlb.c       | 19 ++++++++++---------
 mm/internal.h      |  4 ++--
 mm/page_alloc.c    | 27 +++++++++++++++------------
 4 files changed, 30 insertions(+), 25 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17154f5e1c2a..48a0b821d8ca 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -546,7 +546,7 @@ static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
 	return compound_page_dtors[page[1].compound_dtor];
 }
 
-static inline int compound_order(struct page *page)
+static inline unsigned int compound_order(struct page *page)
 {
 	if (!PageHead(page))
 		return 0;
@@ -1783,7 +1783,8 @@ extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
 
 extern __printf(3, 4)
-void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
+void warn_alloc_failed(gfp_t gfp_mask, unsigned int order,
+		const char *fmt, ...);
 
 extern void setup_per_cpu_pageset(void);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8f751e6eebee..4eca41d69b18 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -994,7 +994,7 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 
 #if defined(CONFIG_CMA) && defined(CONFIG_X86_64)
 static void destroy_compound_gigantic_page(struct page *page,
-					unsigned long order)
+					unsigned int order)
 {
 	int i;
 	int nr_pages = 1 << order;
@@ -1009,7 +1009,7 @@ static void destroy_compound_gigantic_page(struct page *page,
 	__ClearPageHead(page);
 }
 
-static void free_gigantic_page(struct page *page, unsigned order)
+static void free_gigantic_page(struct page *page, unsigned int order)
 {
 	free_contig_range(page_to_pfn(page), 1 << order);
 }
@@ -1053,7 +1053,7 @@ static bool zone_spans_last_pfn(const struct zone *zone,
 	return zone_spans_pfn(zone, last_pfn);
 }
 
-static struct page *alloc_gigantic_page(int nid, unsigned order)
+static struct page *alloc_gigantic_page(int nid, unsigned int order)
 {
 	unsigned long nr_pages = 1 << order;
 	unsigned long ret, pfn, flags;
@@ -1089,7 +1089,7 @@ static struct page *alloc_gigantic_page(int nid, unsigned order)
 }
 
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
-static void prep_compound_gigantic_page(struct page *page, unsigned long order);
+static void prep_compound_gigantic_page(struct page *page, unsigned int order);
 
 static struct page *alloc_fresh_gigantic_page_node(struct hstate *h, int nid)
 {
@@ -1122,9 +1122,9 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
 static inline bool gigantic_page_supported(void) { return true; }
 #else
 static inline bool gigantic_page_supported(void) { return false; }
-static inline void free_gigantic_page(struct page *page, unsigned order) { }
+static inline void free_gigantic_page(struct page *page, unsigned int order) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
-						unsigned long order) { }
+						unsigned int order) { }
 static inline int alloc_fresh_gigantic_page(struct hstate *h,
 					nodemask_t *nodes_allowed) { return 0; }
 #endif
@@ -1250,7 +1250,7 @@ static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
 	put_page(page); /* free it into the hugepage allocator */
 }
 
-static void prep_compound_gigantic_page(struct page *page, unsigned long order)
+static void prep_compound_gigantic_page(struct page *page, unsigned int order)
 {
 	int i;
 	int nr_pages = 1 << order;
@@ -1868,7 +1868,8 @@ found:
 	return 1;
 }
 
-static void __init prep_compound_huge_page(struct page *page, int order)
+static void __init prep_compound_huge_page(struct page *page,
+		unsigned int order)
 {
 	if (unlikely(order > (MAX_ORDER - 1)))
 		prep_compound_gigantic_page(page, order);
@@ -2579,7 +2580,7 @@ static int __init hugetlb_init(void)
 module_init(hugetlb_init);
 
 /* Should be called on processing a hugepagesz=... option */
-void __init hugetlb_add_hstate(unsigned order)
+void __init hugetlb_add_hstate(unsigned int order)
 {
 	struct hstate *h;
 	unsigned long i;
diff --git a/mm/internal.h b/mm/internal.h
index 26027c62577b..f9c439536878 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -157,7 +157,7 @@ __find_buddy_index(unsigned long page_idx, unsigned int order)
 extern int __isolate_free_page(struct page *page, unsigned int order);
 extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
 					unsigned int order);
-extern void prep_compound_page(struct page *page, unsigned long order);
+extern void prep_compound_page(struct page *page, unsigned int order);
 #ifdef CONFIG_MEMORY_FAILURE
 extern bool is_free_buddy_page(struct page *page);
 #endif
@@ -215,7 +215,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
  * page cannot be allocated or merged in parallel. Alternatively, it must
  * handle invalid values gracefully, and use page_order_unsafe() below.
  */
-static inline unsigned long page_order(struct page *page)
+static inline unsigned int page_order(struct page *page)
 {
 	/* PageBuddy() must be checked by the caller */
 	return page_private(page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index acd2e9346d6e..cecc56a3767c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -181,7 +181,7 @@ bool pm_suspended_storage(void)
 #endif /* CONFIG_PM_SLEEP */
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
-int pageblock_order __read_mostly;
+unsigned int pageblock_order __read_mostly;
 #endif
 
 static void __free_pages_ok(struct page *page, unsigned int order);
@@ -462,7 +462,7 @@ static void free_compound_page(struct page *page)
 	__free_pages_ok(page, compound_order(page));
 }
 
-void prep_compound_page(struct page *page, unsigned long order)
+void prep_compound_page(struct page *page, unsigned int order)
 {
 	int i;
 	int nr_pages = 1 << order;
@@ -662,7 +662,7 @@ static inline void __free_one_page(struct page *page,
 	unsigned long combined_idx;
 	unsigned long uninitialized_var(buddy_idx);
 	struct page *buddy;
-	int max_order = MAX_ORDER;
+	unsigned int max_order = MAX_ORDER;
 
 	VM_BUG_ON(!zone_is_initialized(zone));
 	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
@@ -1471,7 +1471,7 @@ int move_freepages(struct zone *zone,
 			  int migratetype)
 {
 	struct page *page;
-	unsigned long order;
+	unsigned int order;
 	int pages_moved = 0;
 
 #ifndef CONFIG_HOLES_IN_ZONE
@@ -1584,7 +1584,7 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
 static void steal_suitable_fallback(struct zone *zone, struct page *page,
 							  int start_type)
 {
-	int current_order = page_order(page);
+	unsigned int current_order = page_order(page);
 	int pages;
 
 	/* Take ownership for orders >= pageblock_order */
@@ -2690,7 +2690,7 @@ static DEFINE_RATELIMIT_STATE(nopage_rs,
 		DEFAULT_RATELIMIT_INTERVAL,
 		DEFAULT_RATELIMIT_BURST);
 
-void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
+void warn_alloc_failed(gfp_t gfp_mask, unsigned int order, const char *fmt, ...)
 {
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
 
@@ -2724,7 +2724,7 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 		va_end(args);
 	}
 
-	pr_warn("%s: page allocation failure: order:%d, mode:0x%x\n",
+	pr_warn("%s: page allocation failure: order:%u, mode:0x%x\n",
 		current->comm, order, gfp_mask);
 
 	dump_stack();
@@ -3488,7 +3488,8 @@ void free_kmem_pages(unsigned long addr, unsigned int order)
 	}
 }
 
-static void *make_alloc_exact(unsigned long addr, unsigned order, size_t size)
+static void *make_alloc_exact(unsigned long addr, unsigned int order,
+		size_t size)
 {
 	if (addr) {
 		unsigned long alloc_end = addr + (PAGE_SIZE << order);
@@ -3538,7 +3539,7 @@ EXPORT_SYMBOL(alloc_pages_exact);
  */
 void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
 {
-	unsigned order = get_order(size);
+	unsigned int order = get_order(size);
 	struct page *p = alloc_pages_node(nid, gfp_mask, order);
 	if (!p)
 		return NULL;
@@ -3840,7 +3841,8 @@ void show_free_areas(unsigned int filter)
 	}
 
 	for_each_populated_zone(zone) {
-		unsigned long nr[MAX_ORDER], flags, order, total = 0;
+		unsigned int order;
+		unsigned long nr[MAX_ORDER], flags, total = 0;
 		unsigned char types[MAX_ORDER];
 
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
@@ -4189,7 +4191,7 @@ static void build_zonelists(pg_data_t *pgdat)
 	nodemask_t used_mask;
 	int local_node, prev_node;
 	struct zonelist *zonelist;
-	int order = current_zonelist_order;
+	unsigned int order = current_zonelist_order;
 
 	/* initialize zonelists */
 	for (i = 0; i < MAX_ZONELISTS; i++) {
@@ -6852,7 +6854,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 		       unsigned migratetype)
 {
 	unsigned long outer_start, outer_end;
-	int ret = 0, order;
+	unsigned int order;
+	int ret = 0;
 
 	struct compact_control cc = {
 		.nr_migratepages = 0,
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
