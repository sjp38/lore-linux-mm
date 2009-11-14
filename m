Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2F6E96B009D
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:27 -0500 (EST)
Received: from int-mx05.intmail.prod.int.phx2.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.18])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAEIAP56014201
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:25 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 03 of 25] alter compound get_page/put_page
Message-Id: <0349288c3f9b81c4790d.1258220301@v2.random>
In-Reply-To: <patchbomb.1258220298@v2.random>
References: <patchbomb.1258220298@v2.random>
Date: Sat, 14 Nov 2009 17:38:21 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Alter compound get_page/put_page to keep references on subpages too, in order
to allow __split_huge_page_refcount to split an hugepage even while subpages
have been pinned by one of the get_user_pages() variants.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
--- a/arch/powerpc/mm/gup.c
+++ b/arch/powerpc/mm/gup.c
@@ -85,13 +85,26 @@ static noinline int gup_huge_pte(pte_t *
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
+		if (PageTail(page)) {
+			/*
+			 * __split_huge_page_refcount() cannot run
+			 * from under us.
+			 */
+			VM_BUG_ON(atomic_read(&page->_count) < 0);
+			atomic_inc(&page->_count);
+		}
 		(*nr)++;
 		page++;
 		refs++;
 	} while (*addr += PAGE_SIZE, *addr != end);
 
 	if (!page_cache_add_speculative(head, refs)) {
-		*nr -= refs;
+		/* Could be optimized better */
+		while (refs--) {
+			(*nr)--;
+			atomic_dec(pages[*nr]->_count);
+			VM_BUG_ON(atomic_read(&pages[*nr]->_count) < 0);
+		}
 		return 0;
 	}
 	if (unlikely(pte_val(pte) != pte_val(*ptep))) {
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -128,6 +128,14 @@ static noinline int gup_huge_pmd(pmd_t p
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
+		if (PageTail(page)) {
+			/*
+			 * __split_huge_page_refcount() cannot run
+			 * from under us.
+			 */
+			VM_BUG_ON(atomic_read(&page->_count) < 0);
+			atomic_inc(&page->_count);
+		}
 		(*nr)++;
 		page++;
 		refs++;
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -319,9 +319,14 @@ static inline int page_count(struct page
 
 static inline void get_page(struct page *page)
 {
-	page = compound_head(page);
-	VM_BUG_ON(atomic_read(&page->_count) == 0);
+	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
 	atomic_inc(&page->_count);
+	if (unlikely(PageTail(page))) {
+		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
+		atomic_inc(&page->first_page->_count);
+		/* __split_huge_page_refcount can't run under get_page */
+		VM_BUG_ON(!PageTail(page));
+	}
 }
 
 static inline struct page *virt_to_head_page(const void *x)
diff --git a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -55,17 +55,80 @@ static void __page_cache_release(struct 
 		del_page_from_lru(zone, page);
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
+}
+
+static void __put_single_page(struct page *page)
+{
+	__page_cache_release(page);
 	free_hot_page(page);
 }
 
+static void __put_compound_page(struct page *page)
+{
+	compound_page_dtor *dtor;
+
+	__page_cache_release(page);
+	dtor = get_compound_page_dtor(page);
+	(*dtor)(page);
+}
+
 static void put_compound_page(struct page *page)
 {
-	page = compound_head(page);
-	if (put_page_testzero(page)) {
-		compound_page_dtor *dtor;
-
-		dtor = get_compound_page_dtor(page);
-		(*dtor)(page);
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
+			out_put_head:
+				put_page(page_head);
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
+			if (put_page_testzero(page_head))
+				__put_compound_page(page_head);
+			else
+				compound_unlock(page_head);
+			return;
+		} else
+			/* page_head is a dangling pointer */
+			goto out_put_single;
+	} else if (put_page_testzero(page)) {
+		if (PageHead(page))
+			__put_compound_page(page);
+		else
+			__put_single_page(page);
 	}
 }
 
@@ -74,7 +137,7 @@ void put_page(struct page *page)
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
