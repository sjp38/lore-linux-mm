Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ED4586B0169
	for <linux-mm@kvack.org>; Sat, 30 Jul 2011 12:15:21 -0400 (EDT)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH] Changes how ref-count of compound pages are managed.
Date: Sat, 30 Jul 2011 18:15:10 +0200
Message-Id: <1312042510-14469-1-git-send-email-mail@smogura.eu>
In-Reply-To: <alpine.LSU.2.00.1107151238390.7803@sister.anvils>
References: <alpine.LSU.2.00.1107151238390.7803@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Radislaw Smogura <mail@rsmogura.eu>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
Cc: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>

WARNING. This change alone may at least break THP splitting.
WARNING. Read end.

Each compound page is made from head and tail of pages. Compound huge page
starts with head ref-count 2^order on head, and ref-count 1 for each tail, but
this is, currently, caller responsibility to ensure this.

If ref-count of tail goes to 0 then ref-count of head is decreased by 1.
This is changes previous behaviour which managed (only partially)
head ref-count as head's individual counts + sum tail's ref-count.

To make this consistent page_count no longer returns count of head, but
only count of tail. Changes has been made to put_page_test_zero,
get_page_unless_zero.

Freeing compound page is protected by compound on head with
double check locking.

This makes
- page splitting for transparent anonymous huge pages, and for transparent huge
pages for page cache (WIP) more securely and simpler. Both of above to fix
head ref-count may subtract values in block of compound lock and if
get_page_unless_zero returned true,
- removes some atomic_inc, and dangling pointers.

WARNING.
This doesn't prevent situations when pages is splitted from larger compound
page to smaller compound page. If this happens (currently no one makes this),
then double-check locking is not enough. Imagine that you have page of order 2,
you put last tail page (4th), some one splits it to two order 1 compound
pages then head of 4th page will change to 3rd (was 1st). If splitting to
smaller compound pages will be possible then, recheck if head doesn't changed
and relocking of head will be required.

This patch doesn't comes with changes for others (see warning), and is
made for preview.
Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 include/linux/mm.h |  101 +++++++++++++++++++++++++-----------
 mm/swap.c          |  142 +++++++++++++++++++++++++---------------------------
 2 files changed, 139 insertions(+), 104 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3172a1c..e51c4f8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -267,18 +267,51 @@ struct inode;
  * routine so they can be sure the page doesn't go away from under them.
  */
 
+
+/** Decreases refcount of page's head. <b>Refcount of {@code page} must be
+ * {@code 0}</b>.
+ * You may pass page head as {@code page} - in this case if {@code page}
+ * refcount is {@code 0} then compound page will be freed.
+ *
+ * @see get_page
+ */
+void put_compound_head_of_page(struct page *page);
+
+static inline struct page *compound_head(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		return page->first_page;
+	return page;
+}
+
 /*
  * Drop a ref, return true if the refcount fell to zero (the page has no users)
  */
 static inline int put_page_testzero(struct page *page)
 {
+	int result;
 	VM_BUG_ON(atomic_read(&page->_count) == 0);
-	return atomic_dec_and_test(&page->_count);
+
+	result = atomic_dec_and_test(&page->_count);
+	if (unlikely(PageTail(page) && result)) {
+		/* If below BUG will be shown, or "null" exception raised
+		 * the page could be splitted from under us (but it should not).
+		 */
+		VM_BUG_ON(atomic_read(&page->first_page->_count) == 0);
+		put_compound_head_of_page(page);
+	} else {
+		/* TODO Free page? - orignally page was not freed.
+		 * Page can be head of compund or "stand alone" page.
+		 */
+	}
+
+	return result;
 }
 
 /*
  * Try to grab a ref unless the page has a refcount of zero, return false if
  * that is the case.
+ * @see get_page
  */
 static inline int get_page_unless_zero(struct page *page)
 {
@@ -349,43 +382,49 @@ static inline void compound_unlock_irqrestore(struct page *page,
 #endif
 }
 
-static inline struct page *compound_head(struct page *page)
-{
-	if (unlikely(PageTail(page)))
-		return page->first_page;
-	return page;
-}
-
+/** Returns usage count of given page.
+ * @see get_page.
+ */
 static inline int page_count(struct page *page)
 {
-	return atomic_read(&compound_head(page)->_count);
-}
-
+	return atomic_read(&page->_count);
+}
+
+/** Increases refcount of page.
+ * <h1>Logic of refcounting pages</h1>
+ * <h2>Normal pages (not compound)</h2>
+ * Getting or putting page will increase refcount of this page, when refcount
+ * falls to {@code 0} then page will be freed.
+ * <h2>Compound pages (transparent huge pages)</h2>
+ * Each compound page is made from {@code 2^order} of pages, 1st page is
+ * <b>head</b> rest pages are <b>tail</b> pages. Compound huge page
+ * starts (when allocated) with refcount {@code 2^order} on head, and refcount
+ * {@code 1} for each tail (developer may need to ensure this by self).<br/>
+ * Getting or putting any of page (head or tail) will increase / decrease
+ * refcount of this page <b>only</b>, but with <b>exceptions:</b>.
+ * <ol>
+ * <li>
+ *      If refcount of tail page will fall to {@code 0}, then compound lock is
+ *      aquired on page head (to prevent splitting by others), if page is still
+ *      compound then refcount of head is decremented by {@code 1}.
+ * </li>
+ * <li>
+ *      If recount of head will fall to {@code 0} then compound lock on head
+ *      is aquired (to prevent background splitting), if page is still compound
+ *      then it will be freed as compound.
+ * </li>
+ * </ol>
+ * This function will not free pages if those has been splitted before head
+ * refcount has been decremented (in particullary, if split occurs, then
+ * splitter is reponsible for freeing pages).
+ */
 static inline void get_page(struct page *page)
 {
-	/*
-	 * Getting a normal page or the head of a compound page
-	 * requires to already have an elevated page->_count. Only if
-	 * we're getting a tail page, the elevated page->_count is
-	 * required only in the head page, so for tail pages the
-	 * bugcheck only verifies that the page->_count isn't
-	 * negative.
-	 */
-	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
+	/* Disallow of getting any page (event tail) if it refcount felt
+	 * to zero */
+	VM_BUG_ON(atomic_read(&page->_count) <= 0);
+
 	atomic_inc(&page->_count);
-	/*
-	 * Getting a tail page will elevate both the head and tail
-	 * page->_count(s).
-	 */
-	if (unlikely(PageTail(page))) {
-		/*
-		 * This is safe only because
-		 * __split_huge_page_refcount can't run under
-		 * get_page().
-		 */
-		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
-		atomic_inc(&page->first_page->_count);
-	}
 }
 
 static inline struct page *virt_to_head_page(const void *x)
diff --git a/mm/swap.c b/mm/swap.c
index 3a442f1..a25f096 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -76,90 +76,86 @@ static void __put_compound_page(struct page *page)
 
 static void put_compound_page(struct page *page)
 {
-	if (unlikely(PageTail(page))) {
-		/* __split_huge_page_refcount can run under us */
-		struct page *page_head = page->first_page;
-		smp_rmb();
-		/*
-		 * If PageTail is still set after smp_rmb() we can be sure
-		 * that the page->first_page we read wasn't a dangling pointer.
-		 * See __split_huge_page_refcount() smp_wmb().
+	if (atomic_dec_and_test(&page->_count)) {
+		/* Some ref fell to zero. It doesn't matter if it was head
+		 * or tail put_compound_head_of_page is greate and deals with
+		 * both cases.
 		 */
-		if (likely(PageTail(page) && get_page_unless_zero(page_head))) {
-			unsigned long flags;
-			/*
-			 * Verify that our page_head wasn't converted
-			 * to a a regular page before we got a
-			 * reference on it.
-			 */
-			if (unlikely(!PageHead(page_head))) {
-				/* PageHead is cleared after PageTail */
-				smp_rmb();
-				VM_BUG_ON(PageTail(page));
-				goto out_put_head;
-			}
-			/*
-			 * Only run compound_lock on a valid PageHead,
-			 * after having it pinned with
-			 * get_page_unless_zero() above.
-			 */
-			smp_mb();
-			/* page_head wasn't a dangling pointer */
-			flags = compound_lock_irqsave(page_head);
-			if (unlikely(!PageTail(page))) {
-				/* __split_huge_page_refcount run before us */
-				compound_unlock_irqrestore(page_head, flags);
-				VM_BUG_ON(PageHead(page_head));
-			out_put_head:
-				if (put_page_testzero(page_head))
-					__put_single_page(page_head);
-			out_put_single:
-				if (put_page_testzero(page))
-					__put_single_page(page);
-				return;
-			}
-			VM_BUG_ON(page_head != page->first_page);
-			/*
-			 * We can release the refcount taken by
-			 * get_page_unless_zero now that
-			 * split_huge_page_refcount is blocked on the
-			 * compound_lock.
-			 */
-			if (put_page_testzero(page_head))
-				VM_BUG_ON(1);
-			/* __split_huge_page_refcount will wait now */
-			VM_BUG_ON(atomic_read(&page->_count) <= 0);
-			atomic_dec(&page->_count);
-			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
-			compound_unlock_irqrestore(page_head, flags);
-			if (put_page_testzero(page_head)) {
-				if (PageHead(page_head))
-					__put_compound_page(page_head);
-				else
-					__put_single_page(page_head);
-			}
-		} else {
-			/* page_head is a dangling pointer */
-			VM_BUG_ON(PageTail(page));
-			goto out_put_single;
-		}
-	} else if (put_page_testzero(page)) {
-		if (PageHead(page))
-			__put_compound_page(page);
-		else
-			__put_single_page(page);
+		put_compound_head_of_page(page);
 	}
 }
 
 void put_page(struct page *page)
 {
-	if (unlikely(PageCompound(page)))
+	if (unlikely(PageCompound(page))) {
 		put_compound_page(page);
-	else if (put_page_testzero(page))
+	} else if (put_page_testzero(page)) {
 		__put_single_page(page);
+	}
 }
 EXPORT_SYMBOL(put_page);
 
+static inline void free_compound_page(struct page *head)
+{
+	VM_BUG_ON(PageTail(head));
+	VM_BUG_ON(!PageCompound(head));
+	/* Debug test if all tails are zero ref - we do not have lock,
+	 * but we shuld not have refcount, so no one should split us!
+	 */
+#if CONFIG_DEBUG_VM
+	do {
+		unsigned long toCheck = 1 << compound_order(head);
+		unsigned long i;
+		for (i = 0; i < toCheck; i++)
+			VM_BUG_ON(atomic_read(&head[i]._count));
+	} while (0);
+#endif
+	__put_compound_page(head);
+}
+
+void put_compound_head_of_page(struct page *page)
+{
+	struct page *head = compound_head(page);
+	int flags;
+
+	VM_BUG_ON(atomic_read(&page->_count));
+
+	/* Lock page to prevent splitting */
+	flags = compound_lock_irqsave(head);
+
+	/* Split impossible right now, is page still tail? Maybe was splitted.
+	 * Desired behaviour is that splitter of compund page (and decraser of
+	 * head refcount) will need to conditionaly aquire page tail
+	 * (get_page_unless_zero) and before putting tail it need to
+	 * decrease head refcount. This SHOULD prevent problems with
+	 * "under us" operations.
+	 *
+	 * Splitter is responsible to free head & tail, if it felt to zero.
+	 */
+	if (PageCompound(page)) {
+		int shouldFree;
+		head = compound_head(page);
+		if (head == page) {
+			/* It's head by call requirements its refcount is 0. */
+			shouldFree = 1;
+		} else if (atomic_dec_and_test(&head->_count)) {
+			/* It's last used tail. */
+			shouldFree = 1;
+		} else {
+			/* It's tail and head refcount is still positive. */
+			shouldFree = 0;
+		}
+
+		compound_unlock_irqrestore(head, flags);
+		if (shouldFree)
+			free_compound_page(head);
+	} else {
+		/* Page is no longer compound splitter decreased head refcount,
+		 * and freed head and tails if needed. No op.
+		 */
+	}
+}
+EXPORT_SYMBOL(put_compound_head_of_page);
 /**
  * put_pages_list() - release a list of pages
  * @pages: list of pages threaded on page->lru
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
