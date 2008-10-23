From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/2] hugetlb: pull gigantic page initialisation out of the default path
Date: Thu, 23 Oct 2008 15:19:19 +0100
Message-Id: <1224771559-19363-3-git-send-email-apw@shadowen.org>
In-Reply-To: <1224771559-19363-1-git-send-email-apw@shadowen.org>
References: <1224771559-19363-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <cl@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

As we can determine exactly when a gigantic page is in use we can optimise
the common regular page cases by pulling out gigantic page initialisation
into its own function.  As gigantic pages are never released to buddy we
do not need a destructor.  This effectivly reverts the previous change
to the main buddy allocator.  It also adds a paranoid check to ensure we
never release gigantic pages from hugetlbfs to the main buddy.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/hugetlb.c    |   12 +++++++++++-
 mm/internal.h   |    1 +
 mm/page_alloc.c |   28 +++++++++++++++++++++-------
 3 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 793f52e..77427c8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -490,6 +490,8 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 {
 	int i;
 
+	VM_BUG_ON(h->order >= MAX_ORDER);
+
 	h->nr_huge_pages--;
 	h->nr_huge_pages_node[page_to_nid(page)]--;
 	for (i = 0; i < pages_per_huge_page(h); i++) {
@@ -1004,6 +1006,14 @@ found:
 	return 1;
 }
 
+static void prep_compound_huge_page(struct page *page, int order)
+{
+	if (unlikely(order > (MAX_ORDER - 1)))
+		prep_compound_gigantic_page(page, order);
+	else
+		prep_compound_page(page, order);
+}
+
 /* Put bootmem huge pages into the standard lists after mem_map is up */
 static void __init gather_bootmem_prealloc(void)
 {
@@ -1014,7 +1024,7 @@ static void __init gather_bootmem_prealloc(void)
 		struct hstate *h = m->hstate;
 		__ClearPageReserved(page);
 		WARN_ON(page_count(page) != 1);
-		prep_compound_page(page, h->order);
+		prep_compound_huge_page(page, h->order);
 		prep_new_huge_page(h, page, page_to_nid(page));
 	}
 }
diff --git a/mm/internal.h b/mm/internal.h
index 08b8dea..92729ea 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -17,6 +17,7 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
 extern void prep_compound_page(struct page *page, unsigned long order);
+extern void prep_compound_gigantic_page(struct page *page, unsigned long order);
 
 static inline void set_page_count(struct page *page, int v)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 27b8681..b40d9b8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -268,24 +268,39 @@ void prep_compound_page(struct page *page, unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;
+
+	set_compound_page_dtor(page, free_compound_page);
+	set_compound_order(page, order);
+	__SetPageHead(page);
+	for (i = 1; i < nr_pages; i++) {
+		struct page *p = page + i;
+
+		__SetPageTail(p);
+		p->first_page = page;
+	}
+}
+
+#ifdef CONFIG_HUGETLBFS
+void prep_compound_gigantic_page(struct page *page, unsigned long order)
+{
+	int i;
+	int nr_pages = 1 << order;
 	struct page *p = page + 1;
 
 	set_compound_page_dtor(page, free_compound_page);
 	set_compound_order(page, order);
 	__SetPageHead(page);
-	for (i = 1; i < nr_pages; i++, p++) {
-		if (unlikely((i & (MAX_ORDER_NR_PAGES - 1)) == 0))
-			p = pfn_to_page(page_to_pfn(page) + i);
+	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
 		__SetPageTail(p);
 		p->first_page = page;
 	}
 }
+#endif 
 
 static void destroy_compound_page(struct page *page, unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;
-	struct page *p = page + 1;
 
 	if (unlikely(compound_order(page) != order))
 		bad_page(page);
@@ -293,9 +308,8 @@ static void destroy_compound_page(struct page *page, unsigned long order)
 	if (unlikely(!PageHead(page)))
 			bad_page(page);
 	__ClearPageHead(page);
-	for (i = 1; i < nr_pages; i++, p++) {
-		if (unlikely((i & (MAX_ORDER_NR_PAGES - 1)) == 0))
-			p = pfn_to_page(page_to_pfn(page) + i);
+	for (i = 1; i < nr_pages; i++) {
+		struct page *p = page + i;
 
 		if (unlikely(!PageTail(p) |
 				(p->first_page != page)))
-- 
1.6.0.2.711.gf1ba4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
