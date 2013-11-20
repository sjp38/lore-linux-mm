Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 19CEB6B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:51:37 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so1841023eae.19
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:51:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v45si18123430eeg.189.2013.11.20.09.51.36
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:51:37 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/8] mm: hugetlbfs: move the put/get_page slab and hugetlbfs optimization in a faster path
Date: Wed, 20 Nov 2013 18:51:11 +0100
Message-Id: <1384969876-6374-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1384969876-6374-1-git-send-email-aarcange@redhat.com>
References: <1384969876-6374-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

We don't actually need a reference on the head page in the slab and
hugetlbfs paths, as long as we add a smp_rmb() which should be faster
than get_page_unless_zero.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/swap.c | 140 ++++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 78 insertions(+), 62 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 84b26aa..dbf5427 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -86,46 +86,62 @@ static void put_compound_page(struct page *page)
 		/* __split_huge_page_refcount can run under us */
 		struct page *page_head = compound_trans_head(page);
 
+		/*
+		 * THP can not break up slab pages so avoid taking
+		 * compound_lock(). Slab performs non-atomic bit ops
+		 * on page->flags for better performance. In
+		 * particular slab_unlock() in slub used to be a hot
+		 * path. It is still hot on arches that do not support
+		 * this_cpu_cmpxchg_double().
+		 *
+		 * If "page" is part of a slab or hugetlbfs page it
+		 * cannot be splitted and the head page cannot change
+		 * from under us. And if "page" is part of a THP page
+		 * under splitting, if the head page pointed by the
+		 * THP tail isn't a THP head anymore, we'll find
+		 * PageTail clear after smp_rmb() and we'll threat it
+		 * as a single page.
+		 */
+		if (PageSlab(page_head) || PageHeadHuge(page_head)) {
+			/*
+			 * If "page" is a THP tail, we must read the tail page
+			 * flags after the head page flags. The
+			 * split_huge_page side enforces write memory
+			 * barriers between clearing PageTail and before the
+			 * head page can be freed and reallocated.
+			 */
+			smp_rmb();
+			if (likely(PageTail(page))) {
+				/*
+				 * __split_huge_page_refcount
+				 * cannot race here.
+				 */
+				VM_BUG_ON(!PageHead(page_head));
+				VM_BUG_ON(page_mapcount(page) <= 0);
+				atomic_dec(&page->_mapcount);
+				if (put_page_testzero(page_head))
+					__put_compound_page(page_head);
+				return;
+			} else
+				/*
+				 * __split_huge_page_refcount
+				 * run before us, "page" was a
+				 * THP tail. The split
+				 * page_head has been freed
+				 * and reallocated as slab or
+				 * hugetlbfs page of smaller
+				 * order (only possible if
+				 * reallocated as slab on
+				 * x86).
+				 */
+				goto out_put_single;
+		}
+
 		if (likely(page != page_head &&
 			   get_page_unless_zero(page_head))) {
 			unsigned long flags;
 
 			/*
-			 * THP can not break up slab pages so avoid taking
-			 * compound_lock().  Slab performs non-atomic bit ops
-			 * on page->flags for better performance.  In particular
-			 * slab_unlock() in slub used to be a hot path.  It is
-			 * still hot on arches that do not support
-			 * this_cpu_cmpxchg_double().
-			 */
-			if (PageSlab(page_head) || PageHeadHuge(page_head)) {
-				if (likely(PageTail(page))) {
-					/*
-					 * __split_huge_page_refcount
-					 * cannot race here.
-					 */
-					VM_BUG_ON(!PageHead(page_head));
-					atomic_dec(&page->_mapcount);
-					if (put_page_testzero(page_head))
-						VM_BUG_ON(1);
-					if (put_page_testzero(page_head))
-						__put_compound_page(page_head);
-					return;
-				} else
-					/*
-					 * __split_huge_page_refcount
-					 * run before us, "page" was a
-					 * THP tail. The split
-					 * page_head has been freed
-					 * and reallocated as slab or
-					 * hugetlbfs page of smaller
-					 * order (only possible if
-					 * reallocated as slab on
-					 * x86).
-					 */
-					goto skip_lock;
-			}
-			/*
 			 * page_head wasn't a dangling pointer but it
 			 * may not be a head page anymore by the time
 			 * we obtain the lock. That is ok as long as it
@@ -135,7 +151,6 @@ static void put_compound_page(struct page *page)
 			if (unlikely(!PageTail(page))) {
 				/* __split_huge_page_refcount run before us */
 				compound_unlock_irqrestore(page_head, flags);
-skip_lock:
 				if (put_page_testzero(page_head)) {
 					/*
 					 * The head page may have been
@@ -221,36 +236,37 @@ bool __get_page_tail(struct page *page)
 	 * split_huge_page().
 	 */
 	unsigned long flags;
-	bool got = false;
+	bool got;
 	struct page *page_head = compound_trans_head(page);
 
-	if (likely(page != page_head && get_page_unless_zero(page_head))) {
-		/* Ref to put_compound_page() comment. */
-		if (PageSlab(page_head) || PageHeadHuge(page_head)) {
-			if (likely(PageTail(page))) {
-				/*
-				 * This is a hugetlbfs page or a slab
-				 * page. __split_huge_page_refcount
-				 * cannot race here.
-				 */
-				VM_BUG_ON(!PageHead(page_head));
-				__get_page_tail_foll(page, false);
-				return true;
-			} else {
-				/*
-				 * __split_huge_page_refcount run
-				 * before us, "page" was a THP
-				 * tail. The split page_head has been
-				 * freed and reallocated as slab or
-				 * hugetlbfs page of smaller order
-				 * (only possible if reallocated as
-				 * slab on x86).
-				 */
-				put_page(page_head);
-				return false;
-			}
+	/* Ref to put_compound_page() comment. */
+	if (PageSlab(page_head) || PageHeadHuge(page_head)) {
+		smp_rmb();
+		if (likely(PageTail(page))) {
+			/*
+			 * This is a hugetlbfs page or a slab
+			 * page. __split_huge_page_refcount
+			 * cannot race here.
+			 */
+			VM_BUG_ON(!PageHead(page_head));
+			__get_page_tail_foll(page, true);
+			return true;
+		} else {
+			/*
+			 * __split_huge_page_refcount run
+			 * before us, "page" was a THP
+			 * tail. The split page_head has been
+			 * freed and reallocated as slab or
+			 * hugetlbfs page of smaller order
+			 * (only possible if reallocated as
+			 * slab on x86).
+			 */
+			return false;
 		}
+	}
 
+	got = false;
+	if (likely(page != page_head && get_page_unless_zero(page_head))) {
 		/*
 		 * page_head wasn't a dangling pointer but it
 		 * may not be a head page anymore by the time

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
