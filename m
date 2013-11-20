Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 126E96B003A
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:51:38 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id hm4so1897226wib.6
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:51:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lm19si2910786wic.26.2013.11.20.09.51.37
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:51:38 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 5/8] mm: tail page refcounting optimization for slab and hugetlbfs
Date: Wed, 20 Nov 2013 18:51:13 +0100
Message-Id: <1384969876-6374-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1384969876-6374-1-git-send-email-aarcange@redhat.com>
References: <1384969876-6374-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

This skips the _mapcount mangling for slab and hugetlbfs pages.

The main trouble in doing this is to guarantee that PageSlab and
PageHeadHuge remains constant for all get_page/put_page run on the
tail of slab or hugetlbfs compound pages. Otherwise if they're set
during get_page but not set during put_page, the _mapcount of the tail
page would underflow.

PageHeadHuge will remain true until the compound page is released and
enters the buddy allocator so it won't risk to change even if the tail
page is the last reference left on the page.

PG_slab instead is cleared before the slab frees the head page with
put_page, so if the tail pin is released after the slab freed the
page, we would have a problem. But in the slab case the tail pin
cannot be the last reference left on the page. This is because the
slab code is free to reuse the compound page after a
kfree/kmem_cache_free without having to check if there's any tail pin
left. In turn all tail pins must be always released while the head is
still pinned by the slab code and so we know PG_slab will be still set
too.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/hugetlb.h |  6 ------
 include/linux/mm.h      | 32 +++++++++++++++++++++++++++++++-
 mm/internal.h           |  3 ++-
 mm/swap.c               | 33 +++++++++++++++++++++++++++------
 4 files changed, 60 insertions(+), 14 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index d4f3dbf..acd2010 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -31,7 +31,6 @@ struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
 void hugepage_put_subpool(struct hugepage_subpool *spool);
 
 int PageHuge(struct page *page);
-int PageHeadHuge(struct page *page_head);
 
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
@@ -105,11 +104,6 @@ static inline int PageHuge(struct page *page)
 	return 0;
 }
 
-static inline int PageHeadHuge(struct page *page_head)
-{
-	return 0;
-}
-
 static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0548eb2..6b20b34 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -414,15 +414,45 @@ static inline int page_count(struct page *page)
 	return atomic_read(&compound_head(page)->_count);
 }
 
+#ifdef CONFIG_HUGETLB_PAGE
+extern int PageHeadHuge(struct page *page_head);
+#else /* CONFIG_HUGETLB_PAGE */
+static inline int PageHeadHuge(struct page *page_head)
+{
+	return 0;
+}
+#endif /* CONFIG_HUGETLB_PAGE */
+
+static inline bool __compound_tail_refcounted(struct page *page)
+{
+	return !PageSlab(page) && !PageHeadHuge(page);
+}
+
+/*
+ * This takes a head page as parameter and tells if the
+ * tail page reference counting can be skipped.
+ *
+ * For this to be safe, PageSlab and PageHeadHuge must remain true on
+ * any given page where they return true here, until all tail pins
+ * have been released.
+ */
+static inline bool compound_tail_refcounted(struct page *page)
+{
+	VM_BUG_ON(!PageHead(page));
+	return __compound_tail_refcounted(page);
+}
+
 static inline void get_huge_page_tail(struct page *page)
 {
 	/*
 	 * __split_huge_page_refcount() cannot run
 	 * from under us.
+	 * In turn no need of compound_trans_head here.
 	 */
 	VM_BUG_ON(page_mapcount(page) < 0);
 	VM_BUG_ON(atomic_read(&page->_count) != 0);
-	atomic_inc(&page->_mapcount);
+	if (compound_tail_refcounted(compound_head(page)))
+		atomic_inc(&page->_mapcount);
 }
 
 extern bool __get_page_tail(struct page *page);
diff --git a/mm/internal.h b/mm/internal.h
index 684f7aa..a85a3ab 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -51,7 +51,8 @@ static inline void __get_page_tail_foll(struct page *page,
 	VM_BUG_ON(page_mapcount(page) < 0);
 	if (get_page_head)
 		atomic_inc(&page->first_page->_count);
-	atomic_inc(&page->_mapcount);
+	if (compound_tail_refcounted(page->first_page))
+		atomic_inc(&page->_mapcount);
 }
 
 /*
diff --git a/mm/swap.c b/mm/swap.c
index dbf5427..b4c49bf 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -88,8 +88,9 @@ static void put_compound_page(struct page *page)
 
 		/*
 		 * THP can not break up slab pages so avoid taking
-		 * compound_lock(). Slab performs non-atomic bit ops
-		 * on page->flags for better performance. In
+		 * compound_lock() and skip the tail page refcounting
+		 * (in _mapcount) too. Slab performs non-atomic bit
+		 * ops on page->flags for better performance. In
 		 * particular slab_unlock() in slub used to be a hot
 		 * path. It is still hot on arches that do not support
 		 * this_cpu_cmpxchg_double().
@@ -102,7 +103,7 @@ static void put_compound_page(struct page *page)
 		 * PageTail clear after smp_rmb() and we'll threat it
 		 * as a single page.
 		 */
-		if (PageSlab(page_head) || PageHeadHuge(page_head)) {
+		if (!__compound_tail_refcounted(page_head)) {
 			/*
 			 * If "page" is a THP tail, we must read the tail page
 			 * flags after the head page flags. The
@@ -117,10 +118,30 @@ static void put_compound_page(struct page *page)
 				 * cannot race here.
 				 */
 				VM_BUG_ON(!PageHead(page_head));
-				VM_BUG_ON(page_mapcount(page) <= 0);
-				atomic_dec(&page->_mapcount);
-				if (put_page_testzero(page_head))
+				VM_BUG_ON(page_mapcount(page) != 0);
+				if (put_page_testzero(page_head)) {
+					/*
+					 * If this is the tail of a
+					 * slab compound page, the
+					 * tail pin must not be the
+					 * last reference held on the
+					 * page, because the PG_slab
+					 * cannot be cleared before
+					 * all tail pins (which skips
+					 * the _mapcount tail
+					 * refcounting) have been
+					 * released. For hugetlbfs the
+					 * tail pin may be the last
+					 * reference on the page
+					 * instead, because
+					 * PageHeadHuge will not go
+					 * away until the compound
+					 * page enters the buddy
+					 * allocator.
+					 */
+					VM_BUG_ON(PageSlab(page_head));
 					__put_compound_page(page_head);
+				}
 				return;
 			} else
 				/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
