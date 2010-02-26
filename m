Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D05E66B004D
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:02 -0500 (EST)
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK91pK004844
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:01 -0500
Message-Id: <20100226200859.159424521@redhat.com>
Date: Fri, 26 Feb 2010 21:04:36 +0100
From: aarcange@redhat.com
Subject: [patch 03/35] alter compound get_page/put_page
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=compound_get_put
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Alter compound get_page/put_page to keep references on subpages too, in order
to allow __split_huge_page_refcount to split an hugepage even while subpages
have been pinned by one of the get_user_pages() variants.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 arch/powerpc/mm/gup.c |   12 +++++++
 arch/x86/mm/gup.c     |   12 +++++++
 include/linux/mm.h    |   12 ++++++-
 mm/swap.c             |   79 +++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 106 insertions(+), 9 deletions(-)

--- a/arch/powerpc/mm/gup.c
+++ b/arch/powerpc/mm/gup.c
@@ -16,6 +16,16 @@
 
 #ifdef __HAVE_ARCH_PTE_SPECIAL
 
+static inline void pin_huge_page_tail(struct page *page)
+{
+	/*
+	 * __split_huge_page_refcount() cannot run
+	 * from under us.
+	 */
+	VM_BUG_ON(atomic_read(&page->_count) < 0);
+	atomic_inc(&page->_count);
+}
+
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
@@ -47,6 +57,8 @@ static noinline int gup_pte_range(pmd_t 
 			put_page(page);
 			return 0;
 		}
+		if (PageTail(page))
+			pin_huge_page_tail(page);
 		pages[*nr] = page;
 		(*nr)++;
 
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -105,6 +105,16 @@ static inline void get_head_page_multipl
 	atomic_add(nr, &page->_count);
 }
 
+static inline void pin_huge_page_tail(struct page *page)
+{
+	/*
+	 * __split_huge_page_refcount() cannot run
+	 * from under us.
+	 */
+	VM_BUG_ON(atomic_read(&page->_count) < 0);
+	atomic_inc(&page->_count);
+}
+
 static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
@@ -128,6 +138,8 @@ static noinline int gup_huge_pmd(pmd_t p
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
+		if (PageTail(page))
+			pin_huge_page_tail(page);
 		(*nr)++;
 		page++;
 		refs++;
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -325,9 +325,17 @@ static inline int page_count(struct page
 
 static inline void get_page(struct page *page)
 {
-	page = compound_head(page);
-	VM_BUG_ON(atomic_read(&page->_count) == 0);
+	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
 	atomic_inc(&page->_count);
+	if (unlikely(PageTail(page))) {
+		/*
+		 * This is safe only because
+		 * __split_huge_page_refcount can't run under
+		 * get_page().
+		 */
+		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
+		atomic_inc(&page->first_page->_count);
+	}
 }
 
 static inline struct page *virt_to_head_page(const void *x)
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -55,17 +55,82 @@ static void __page_cache_release(struct 
 		del_page_from_lru(zone, page);
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
+}
+
+static void __put_single_page(struct page *page)
+{
+	__page_cache_release(page);
 	free_hot_cold_page(page, 0);
 }
 
-static void put_compound_page(struct page *page)
+static void __put_compound_page(struct page *page)
 {
-	page = compound_head(page);
-	if (put_page_testzero(page)) {
-		compound_page_dtor *dtor;
+	compound_page_dtor *dtor;
+
+	__page_cache_release(page);
+	dtor = get_compound_page_dtor(page);
+	(*dtor)(page);
+}
 
-		dtor = get_compound_page_dtor(page);
-		(*dtor)(page);
+static void put_compound_page(struct page *page)
+{
+	if (unlikely(PageTail(page))) {
+		/* __split_huge_page_refcount can run under us */
+		struct page *page_head = page->first_page;
+		smp_rmb();
+		if (likely(PageTail(page) && get_page_unless_zero(page_head))) {
+			if (unlikely(!PageHead(page_head))) {
+				/* PageHead is cleared after PageTail */
+				smp_rmb();
+				VM_BUG_ON(PageTail(page));
+				goto out_put_head;
+			}
+			/*
+			 * Only run compound_lock on a valid PageHead,
+			 * after having it pinned with
+			 * get_page_unless_zero() above.
+			 */
+			smp_mb();
+			/* page_head wasn't a dangling pointer */
+			compound_lock(page_head);
+			if (unlikely(!PageTail(page))) {
+				/* __split_huge_page_refcount run before us */
+				compound_unlock(page_head);
+				VM_BUG_ON(PageHead(page_head));
+			out_put_head:
+				if (put_page_testzero(page_head))
+					__put_single_page(page_head);
+			out_put_single:
+				if (put_page_testzero(page))
+					__put_single_page(page);
+				return;
+			}
+			VM_BUG_ON(page_head != page->first_page);
+			/*
+			 * We can release the refcount taken by
+			 * get_page_unless_zero now that
+			 * split_huge_page_refcount is blocked on the
+			 * compound_lock.
+			 */
+			if (put_page_testzero(page_head))
+				VM_BUG_ON(1);
+			/* __split_huge_page_refcount will wait now */
+			VM_BUG_ON(atomic_read(&page->_count) <= 0);
+			atomic_dec(&page->_count);
+			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
+			compound_unlock(page_head);
+			if (put_page_testzero(page_head))
+				__put_compound_page(page_head);
+		} else {
+			/* page_head is a dangling pointer */
+			VM_BUG_ON(PageTail(page));
+			goto out_put_single;
+		}
+	} else if (put_page_testzero(page)) {
+		if (PageHead(page))
+			__put_compound_page(page);
+		else
+			__put_single_page(page);
 	}
 }
 
@@ -74,7 +139,7 @@ void put_page(struct page *page)
 	if (unlikely(PageCompound(page)))
 		put_compound_page(page);
 	else if (put_page_testzero(page))
-		__page_cache_release(page);
+		__put_single_page(page);
 }
 EXPORT_SYMBOL(put_page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
