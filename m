Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B70556B0093
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:27 -0500 (EST)
Message-Id: <20100226200859.425316472@redhat.com>
Date: Fri, 26 Feb 2010 21:04:37 +0100
From: aarcange@redhat.com
Subject: [patch 04/35] update futex compound knowledge
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=compound_futex
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Futex code is smarter than most other gup_fast O_DIRECT code and knows about
the compound internals. However now doing a put_page(head_page) will not
release the pin on the tail page taken by gup-fast, leading to all sort of
refcounting bugchecks. Getting a stable head_page is a little tricky.

page_head = page is there because if this is not a tail page it's also the
page_head. Only in case this is a tail page, compound_head is called, otherwise
it's guaranteed unnecessary. And if it's a tail page compound_head has to run
atomically inside irq disabled section __get_user_pages_fast before returning.
Otherwise ->first_page won't be a stable pointer.

Disableing irq before __get_user_page_fast and releasing irq after running
compound_head is needed because if __get_user_page_fast returns == 1, it means
the huge pmd is established and cannot go away from under us.
pmdp_splitting_flush_notify in __split_huge_page_splitting will have to wait
for local_irq_enable before the IPI delivery can return. This means
__split_huge_page_refcount can't be running from under us, and in turn when we
run compound_head(page) we're not reading a dangling pointer from
tailpage->first_page. Then after we get to stable head page, we are always safe
to call compound_lock and after taking the compound lock on head page we can
finally re-check if the page returned by gup-fast is still a tail page. in
which case we're set and we didn't need to split the hugepage in order to take
a futex on it.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
---
 kernel/futex.c |   67 +++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 58 insertions(+), 9 deletions(-)

--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -218,7 +218,7 @@ get_futex_key(u32 __user *uaddr, int fsh
 {
 	unsigned long address = (unsigned long)uaddr;
 	struct mm_struct *mm = current->mm;
-	struct page *page;
+	struct page *page, *page_head;
 	int err;
 
 	/*
@@ -250,10 +250,53 @@ again:
 	if (err < 0)
 		return err;
 
-	page = compound_head(page);
-	lock_page(page);
-	if (!page->mapping) {
-		unlock_page(page);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	page_head = page;
+	if (unlikely(PageTail(page))) {
+		put_page(page);
+		/* serialize against __split_huge_page_splitting() */
+		local_irq_disable();
+		if (likely(__get_user_pages_fast(address, 1, 1, &page) == 1)) {
+			page_head = compound_head(page);
+			/*
+			 * page_head is valid pointer but we must pin
+			 * it before taking the PG_lock and/or
+			 * PG_compound_lock. The moment we re-enable
+			 * irqs __split_huge_page_splitting() can
+			 * return and the head page can be freed from
+			 * under us. We can't take the PG_lock and/or
+			 * PG_compound_lock on a page that could be
+			 * freed from under us.
+			 */
+			if (page != page_head)
+				get_page(page_head);
+			local_irq_enable();
+		} else {
+			local_irq_enable();
+			goto again;
+		}
+	}
+#else
+	page_head = compound_head(page);
+	if (page != page_head)
+		get_page(page_head);
+#endif
+
+	lock_page(page_head);
+	if (unlikely(page_head != page)) {
+		compound_lock(page_head);
+		if (unlikely(!PageTail(page))) {
+			compound_unlock(page_head);
+			unlock_page(page_head);
+			put_page(page_head);
+			put_page(page);
+			goto again;
+		}
+	}
+	if (!page_head->mapping) {
+		unlock_page(page_head);
+		if (page_head != page)
+			put_page(page_head);
 		put_page(page);
 		goto again;
 	}
@@ -265,19 +308,25 @@ again:
 	 * it's a read-only handle, it's expected that futexes attach to
 	 * the object not the particular process.
 	 */
-	if (PageAnon(page)) {
+	if (PageAnon(page_head)) {
 		key->both.offset |= FUT_OFF_MMSHARED; /* ref taken on mm */
 		key->private.mm = mm;
 		key->private.address = address;
 	} else {
 		key->both.offset |= FUT_OFF_INODE; /* inode-based key */
-		key->shared.inode = page->mapping->host;
-		key->shared.pgoff = page->index;
+		key->shared.inode = page_head->mapping->host;
+		key->shared.pgoff = page_head->index;
 	}
 
 	get_futex_key_refs(key);
 
-	unlock_page(page);
+	unlock_page(page_head);
+	if (page != page_head) {
+		VM_BUG_ON(!PageTail(page));
+		/* releasing compound_lock after page_lock won't matter */
+		compound_unlock(page_head);
+		put_page(page_head);
+	}
 	put_page(page);
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
