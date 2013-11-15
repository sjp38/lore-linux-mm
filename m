Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id D93026B0036
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 12:48:11 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id xb12so3852687pbc.37
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 09:48:11 -0800 (PST)
Received: from psmtp.com ([74.125.245.148])
        by mx.google.com with SMTP id ru9si2618980pbc.228.2013.11.15.09.48.09
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 09:48:10 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/3] mm: tail page refcounting optimization for slab and hugetlbfs
Date: Fri, 15 Nov 2013 18:47:48 +0100
Message-Id: <1384537668-10283-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1384537668-10283-1-git-send-email-aarcange@redhat.com>
References: <1384537668-10283-1-git-send-email-aarcange@redhat.com>
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

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/hugetlb.h |  6 ------
 include/linux/mm.h      | 30 +++++++++++++++++++++++++++++-
 mm/internal.h           |  3 ++-
 mm/swap.c               | 48 ++++++++++++++++++++++++++++++++++++++++--------
 4 files changed, 71 insertions(+), 16 deletions(-)

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
index 0548eb2..c40bb53 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -414,15 +414,43 @@ static inline int page_count(struct page *page)
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
+	if (PageSlab(page) || PageHeadHuge(page))
+		return false;
+	else
+		return true;
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
index 84b26aa..51bae1d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -91,12 +91,15 @@ static void put_compound_page(struct page *page)
 			unsigned long flags;
 
 			/*
-			 * THP can not break up slab pages so avoid taking
-			 * compound_lock().  Slab performs non-atomic bit ops
-			 * on page->flags for better performance.  In particular
-			 * slab_unlock() in slub used to be a hot path.  It is
-			 * still hot on arches that do not support
-			 * this_cpu_cmpxchg_double().
+			 * THP can not break up slab pages or
+			 * hugetlbfs pages so avoid taking
+			 * compound_lock() and skip the tail page
+			 * refcounting (in _mapcount) too. Slab
+			 * performs non-atomic bit ops on page->flags
+			 * for better performance. In particular
+			 * slab_unlock() in slub used to be a hot
+			 * path. It is still hot on arches that do not
+			 * support this_cpu_cmpxchg_double().
 			 */
 			if (PageSlab(page_head) || PageHeadHuge(page_head)) {
 				if (likely(PageTail(page))) {
@@ -105,11 +108,40 @@ static void put_compound_page(struct page *page)
 					 * cannot race here.
 					 */
 					VM_BUG_ON(!PageHead(page_head));
-					atomic_dec(&page->_mapcount);
+					VM_BUG_ON(atomic_read(&page->_mapcount)
+						  != -1);
 					if (put_page_testzero(page_head))
 						VM_BUG_ON(1);
-					if (put_page_testzero(page_head))
+					if (put_page_testzero(page_head)) {
+						/*
+						 * If this is the tail
+						 * of a a slab
+						 * compound page, the
+						 * tail pin must not
+						 * be the last
+						 * reference held on
+						 * the page, because
+						 * the PG_slab cannot
+						 * be cleared before
+						 * all tail pins
+						 * (which skips the
+						 * _mapcount tail
+						 * refcounting) have
+						 * been released. For
+						 * hugetlbfs the tail
+						 * pin may be the last
+						 * reference on the
+						 * page instead,
+						 * because
+						 * PageHeadHuge will
+						 * not go away until
+						 * the compound page
+						 * enters the buddy
+						 * allocator.
+						 */
+						VM_BUG_ON(PageSlab(page_head));
 						__put_compound_page(page_head);
+					}
 					return;
 				} else
 					/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
