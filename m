Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 26CA36B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 05:21:57 -0400 (EDT)
Received: by paccq16 with SMTP id cq16so110050692pac.1
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 02:21:56 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id v11si170258pbs.14.2015.08.19.02.21.53
        for <linux-mm@kvack.org>;
        Wed, 19 Aug 2015 02:21:54 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 3/5] mm: pack compound_dtor and compound_order into one word in struct page
Date: Wed, 19 Aug 2015 12:21:44 +0300
Message-Id: <1439976106-137226-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch halves space occupied by compound_dtor and compound_order in
struct page.

For compound_order, it's trivial long -> int/short conversion.

For get_compound_page_dtor(), we now use hardcoded table for destructor
lookup and store its index in the struct page instead of direct pointer
to destructor. It shouldn't be a big trouble to maintain the table: we
have only two destructor and NULL currently.

This patch free up one word in tail pages for reuse. This is preparation
for the next patch.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h       | 24 +++++++++++++++++++-----
 include/linux/mm_types.h | 11 +++++++----
 mm/hugetlb.c             |  8 ++++----
 mm/page_alloc.c          | 11 ++++++++++-
 4 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2e872f92dbac..0735bc0a351a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -575,18 +575,32 @@ int split_free_page(struct page *page);
 /*
  * Compound pages have a destructor function.  Provide a
  * prototype for that function and accessor functions.
- * These are _only_ valid on the head of a PG_compound page.
+ * These are _only_ valid on the head of a compound page.
  */
+typedef void compound_page_dtor(struct page *);
+
+/* Keep the enum in sync with compound_page_dtors array in mm/page_alloc.c */
+enum {
+	NULL_COMPOUND_DTOR,
+	COMPOUND_PAGE_DTOR,
+#ifdef CONFIG_HUGETLB_PAGE
+	HUGETLB_PAGE_DTOR,
+#endif
+	NR_COMPOUND_DTORS,
+};
+extern compound_page_dtor * const compound_page_dtors[];
 
 static inline void set_compound_page_dtor(struct page *page,
-						compound_page_dtor *dtor)
+		unsigned int compound_dtor)
 {
-	page[1].compound_dtor = dtor;
+	VM_BUG_ON_PAGE(compound_dtor >= NR_COMPOUND_DTORS, page);
+	page[1].compound_dtor = compound_dtor;
 }
 
 static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
 {
-	return page[1].compound_dtor;
+	VM_BUG_ON_PAGE(page[1].compound_dtor >= NR_COMPOUND_DTORS, page);
+	return compound_page_dtors[page[1].compound_dtor];
 }
 
 static inline int compound_order(struct page *page)
@@ -596,7 +610,7 @@ static inline int compound_order(struct page *page)
 	return page[1].compound_order;
 }
 
-static inline void set_compound_order(struct page *page, unsigned long order)
+static inline void set_compound_order(struct page *page, unsigned int order)
 {
 	page[1].compound_order = order;
 }
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 58620ac7f15c..63cdfe7ec336 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -28,8 +28,6 @@ struct mem_cgroup;
 		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK))
 #define ALLOC_SPLIT_PTLOCKS	(SPINLOCK_SIZE > BITS_PER_LONG/8)
 
-typedef void compound_page_dtor(struct page *);
-
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -145,8 +143,13 @@ struct page {
 						 */
 		/* First tail page of compound page */
 		struct {
-			compound_page_dtor *compound_dtor;
-			unsigned long compound_order;
+#ifdef CONFIG_64BIT
+			unsigned int compound_dtor;
+			unsigned int compound_order;
+#else
+			unsigned short int compound_dtor;
+			unsigned short int compound_order;
+#endif
 		};
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a8c3087089d8..8ea74caa1fa8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -969,7 +969,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 				1 << PG_writeback);
 	}
 	VM_BUG_ON_PAGE(hugetlb_cgroup_from_page(page), page);
-	set_compound_page_dtor(page, NULL);
+	set_compound_page_dtor(page, NULL_COMPOUND_DTOR);
 	set_page_refcounted(page);
 	if (hstate_is_gigantic(h)) {
 		destroy_compound_gigantic_page(page, huge_page_order(h));
@@ -1065,7 +1065,7 @@ void free_huge_page(struct page *page)
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
 {
 	INIT_LIST_HEAD(&page->lru);
-	set_compound_page_dtor(page, free_huge_page);
+	set_compound_page_dtor(page, HUGETLB_PAGE_DTOR);
 	spin_lock(&hugetlb_lock);
 	set_hugetlb_cgroup(page, NULL);
 	h->nr_huge_pages++;
@@ -1117,7 +1117,7 @@ int PageHuge(struct page *page)
 		return 0;
 
 	page = compound_head(page);
-	return get_compound_page_dtor(page) == free_huge_page;
+	return page[1].compound_dtor == HUGETLB_PAGE_DTOR;
 }
 EXPORT_SYMBOL_GPL(PageHuge);
 
@@ -1314,7 +1314,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 	if (page) {
 		INIT_LIST_HEAD(&page->lru);
 		r_nid = page_to_nid(page);
-		set_compound_page_dtor(page, free_huge_page);
+		set_compound_page_dtor(page, HUGETLB_PAGE_DTOR);
 		set_hugetlb_cgroup(page, NULL);
 		/*
 		 * We incremented the global counters already
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df959b7d6085..c6733cc3cbce 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -208,6 +208,15 @@ static char * const zone_names[MAX_NR_ZONES] = {
 	 "Movable",
 };
 
+static void free_compound_page(struct page *page);
+compound_page_dtor * const compound_page_dtors[] = {
+	NULL,
+	free_compound_page,
+#ifdef CONFIG_HUGETLB_PAGE
+	free_huge_page,
+#endif
+};
+
 int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
 
@@ -437,7 +446,7 @@ void prep_compound_page(struct page *page, unsigned long order)
 	int i;
 	int nr_pages = 1 << order;
 
-	set_compound_page_dtor(page, free_compound_page);
+	set_compound_page_dtor(page, COMPOUND_PAGE_DTOR);
 	set_compound_order(page, order);
 	__SetPageHead(page);
 	for (i = 1; i < nr_pages; i++) {
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
