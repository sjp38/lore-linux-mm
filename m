Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 814516B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 09:29:43 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id c7so3642935lfk.19
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 06:29:43 -0800 (PST)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id d20si1254016ljc.28.2018.02.11.06.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Feb 2018 06:29:41 -0800 (PST)
Subject: [PATCH v2] mm/huge_memory.c: reorder operations in
 __split_huge_page_tail()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Sun, 11 Feb 2018 17:29:37 +0300
Message-ID: <151835937752.185602.5640977700089242532.stgit@buzz>
In-Reply-To: <4f64569f-b8ce-54f8-33d9-0e67216bb54c@yandex-team.ru>
References: <4f64569f-b8ce-54f8-33d9-0e67216bb54c@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>

THP split makes non-atomic change of tail page flags. This is almost ok
because tail pages are locked and isolated but this breaks recent changes
in page locking: non-atomic operation could clear bit PG_waiters.

As a result concurrent sequence get_page_unless_zero() -> lock_page()
might block forever. Especially if this page was truncated later.

Fix is trivial: clone flags before unfreezing page reference counter.

This race exists since commit 62906027091f ("mm: add PageWaiters indicating
tasks are waiting for a page bit") while unsave unfreeze itself was added
in commit 8df651c7059e ("thp: cleanup split_huge_page()").

clear_compound_head() also must be called before unfreezing page reference
because successful get_page_unless_zero() must stabilize compound_head().

And replace page_ref_inc()/page_ref_add() with page_ref_unfreeze() which
is made especially for that and has semantic of smp_store_release().

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/huge_memory.c |   34 +++++++++++++---------------------
 1 file changed, 13 insertions(+), 21 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 87ab9b8f56b5..fa577aa7ecd8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2355,26 +2355,11 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	struct page *page_tail = head + tail;
 
 	VM_BUG_ON_PAGE(atomic_read(&page_tail->_mapcount) != -1, page_tail);
-	VM_BUG_ON_PAGE(page_ref_count(page_tail) != 0, page_tail);
 
 	/*
-	 * tail_page->_refcount is zero and not changing from under us. But
-	 * get_page_unless_zero() may be running from under us on the
-	 * tail_page. If we used atomic_set() below instead of atomic_inc() or
-	 * atomic_add(), we would then run atomic_set() concurrently with
-	 * get_page_unless_zero(), and atomic_set() is implemented in C not
-	 * using locked ops. spin_unlock on x86 sometime uses locked ops
-	 * because of PPro errata 66, 92, so unless somebody can guarantee
-	 * atomic_set() here would be safe on all archs (and not only on x86),
-	 * it's safer to use atomic_inc()/atomic_add().
+	 * Clone page flags before unfreezing refcount.
+	 * lock_page() after speculative get wants to set PG_waiters.
 	 */
-	if (PageAnon(head) && !PageSwapCache(head)) {
-		page_ref_inc(page_tail);
-	} else {
-		/* Additional pin to radix tree */
-		page_ref_add(page_tail, 2);
-	}
-
 	page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	page_tail->flags |= (head->flags &
 			((1L << PG_referenced) |
@@ -2387,14 +2372,21 @@ static void __split_huge_page_tail(struct page *head, int tail,
 			 (1L << PG_unevictable) |
 			 (1L << PG_dirty)));
 
-	/*
-	 * After clearing PageTail the gup refcount can be released.
-	 * Page flags also must be visible before we make the page non-compound.
-	 */
+	/* Page flags must be visible before we make the page non-compound. */
 	smp_wmb();
 
+	/*
+	 * Clear PageTail before unfreezing page refcount:
+	 * speculative refcount must stabilize compound_head().
+	 */
 	clear_compound_head(page_tail);
 
+	/*
+	 * Finally unfreeze refcount. Additional pin to radix tree.
+	 */
+	page_ref_unfreeze(page_tail, 1 + (!PageAnon(head) ||
+					  PageSwapCache(head)));
+
 	if (page_is_young(head))
 		set_page_young(page_tail);
 	if (page_is_idle(head))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
