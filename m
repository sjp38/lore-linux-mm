From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/5] mm: introduce PageHuge() for testing huge/gigantic pages
Date: Tue, 28 Apr 2009 09:09:10 +0800
Message-ID: <20090428014920.517605197@intel.com>
References: <20090428010907.912554629@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 83AA96B00DE
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 21:50:28 -0400 (EDT)
Content-Disposition: inline; filename=giga-page.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Introduce PageHuge(), which identifies huge/gigantic pages
by their dedicated compound destructor functions.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/mm.h |   24 ++++++++++++++++++++++++
 mm/hugetlb.c       |    2 +-
 mm/page_alloc.c    |   11 ++++++++++-
 3 files changed, 35 insertions(+), 2 deletions(-)

--- mm.orig/mm/page_alloc.c
+++ mm/mm/page_alloc.c
@@ -299,13 +299,22 @@ void prep_compound_page(struct page *pag
 }
 
 #ifdef CONFIG_HUGETLBFS
+/*
+ * This (duplicated) destructor function distinguishes gigantic pages from
+ * normal compound pages.
+ */
+void free_gigantic_page(struct page *page)
+{
+	__free_pages_ok(page, compound_order(page));
+}
+
 void prep_compound_gigantic_page(struct page *page, unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;
 	struct page *p = page + 1;
 
-	set_compound_page_dtor(page, free_compound_page);
+	set_compound_page_dtor(page, free_gigantic_page);
 	set_compound_order(page, order);
 	__SetPageHead(page);
 	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
--- mm.orig/mm/hugetlb.c
+++ mm/mm/hugetlb.c
@@ -550,7 +550,7 @@ struct hstate *size_to_hstate(unsigned l
 	return NULL;
 }
 
-static void free_huge_page(struct page *page)
+void free_huge_page(struct page *page)
 {
 	/*
 	 * Can't pass hstate in here because it is called from the
--- mm.orig/include/linux/mm.h
+++ mm/include/linux/mm.h
@@ -355,6 +355,30 @@ static inline void set_compound_order(st
 	page[1].lru.prev = (void *)order;
 }
 
+#ifdef CONFIG_HUGETLBFS
+void free_huge_page(struct page *page);
+void free_gigantic_page(struct page *page);
+
+static inline int PageHuge(struct page *page)
+{
+	compound_page_dtor *dtor;
+
+	if (!PageCompound(page))
+		return 0;
+
+	page = compound_head(page);
+	dtor = get_compound_page_dtor(page);
+
+	return  dtor == free_huge_page ||
+		dtor == free_gigantic_page;
+}
+#else
+static inline int PageHuge(struct page *page)
+{
+	return 0;
+}
+#endif
+
 /*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
