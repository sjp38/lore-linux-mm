Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id F0D2E6B0038
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:51:38 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so1866005eaj.12
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:51:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r44si7375196eem.261.2013.11.20.09.51.37
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:51:37 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 7/8] mm/swap.c: reorganize put_compound_page()
Date: Wed, 20 Nov 2013 18:51:15 +0100
Message-Id: <1384969876-6374-8-git-send-email-aarcange@redhat.com>
In-Reply-To: <1384969876-6374-1-git-send-email-aarcange@redhat.com>
References: <1384969876-6374-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

From: Andrew Morton <akpm@linux-foundation.org>

Tweak it so save a tab stop, make code layout slightly less nutty.

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/swap.c | 254 +++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 125 insertions(+), 129 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index b4c49bf..ddb470d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -82,154 +82,150 @@ static void __put_compound_page(struct page *page)
 
 static void put_compound_page(struct page *page)
 {
-	if (unlikely(PageTail(page))) {
-		/* __split_huge_page_refcount can run under us */
-		struct page *page_head = compound_trans_head(page);
+	struct page *page_head;
 
-		/*
-		 * THP can not break up slab pages so avoid taking
-		 * compound_lock() and skip the tail page refcounting
-		 * (in _mapcount) too. Slab performs non-atomic bit
-		 * ops on page->flags for better performance. In
-		 * particular slab_unlock() in slub used to be a hot
-		 * path. It is still hot on arches that do not support
-		 * this_cpu_cmpxchg_double().
-		 *
-		 * If "page" is part of a slab or hugetlbfs page it
-		 * cannot be splitted and the head page cannot change
-		 * from under us. And if "page" is part of a THP page
-		 * under splitting, if the head page pointed by the
-		 * THP tail isn't a THP head anymore, we'll find
-		 * PageTail clear after smp_rmb() and we'll threat it
-		 * as a single page.
-		 */
-		if (!__compound_tail_refcounted(page_head)) {
+	if (likely(!PageTail(page))) {
+		if (put_page_testzero(page)) {
 			/*
-			 * If "page" is a THP tail, we must read the tail page
-			 * flags after the head page flags. The
-			 * split_huge_page side enforces write memory
-			 * barriers between clearing PageTail and before the
-			 * head page can be freed and reallocated.
+			 * By the time all refcounts have been released
+			 * split_huge_page cannot run anymore from under us.
 			 */
-			smp_rmb();
-			if (likely(PageTail(page))) {
-				/*
-				 * __split_huge_page_refcount
-				 * cannot race here.
-				 */
-				VM_BUG_ON(!PageHead(page_head));
-				VM_BUG_ON(page_mapcount(page) != 0);
-				if (put_page_testzero(page_head)) {
-					/*
-					 * If this is the tail of a
-					 * slab compound page, the
-					 * tail pin must not be the
-					 * last reference held on the
-					 * page, because the PG_slab
-					 * cannot be cleared before
-					 * all tail pins (which skips
-					 * the _mapcount tail
-					 * refcounting) have been
-					 * released. For hugetlbfs the
-					 * tail pin may be the last
-					 * reference on the page
-					 * instead, because
-					 * PageHeadHuge will not go
-					 * away until the compound
-					 * page enters the buddy
-					 * allocator.
-					 */
-					VM_BUG_ON(PageSlab(page_head));
-					__put_compound_page(page_head);
-				}
-				return;
-			} else
-				/*
-				 * __split_huge_page_refcount
-				 * run before us, "page" was a
-				 * THP tail. The split
-				 * page_head has been freed
-				 * and reallocated as slab or
-				 * hugetlbfs page of smaller
-				 * order (only possible if
-				 * reallocated as slab on
-				 * x86).
-				 */
-				goto out_put_single;
+			if (PageHead(page))
+				__put_compound_page(page);
+			else
+				__put_single_page(page);
 		}
+		return;
+	}
 
-		if (likely(page != page_head &&
-			   get_page_unless_zero(page_head))) {
-			unsigned long flags;
+	/* __split_huge_page_refcount can run under us */
+	page_head = compound_trans_head(page);
 
+	/*
+	 * THP can not break up slab pages so avoid taking
+	 * compound_lock() and skip the tail page refcounting (in
+	 * _mapcount) too. Slab performs non-atomic bit ops on
+	 * page->flags for better performance. In particular
+	 * slab_unlock() in slub used to be a hot path. It is still
+	 * hot on arches that do not support
+	 * this_cpu_cmpxchg_double().
+	 *
+	 * If "page" is part of a slab or hugetlbfs page it cannot be
+	 * splitted and the head page cannot change from under us. And
+	 * if "page" is part of a THP page under splitting, if the
+	 * head page pointed by the THP tail isn't a THP head anymore,
+	 * we'll find PageTail clear after smp_rmb() and we'll threat
+	 * it as a single page.
+	 */
+	if (!__compound_tail_refcounted(page_head)) {
+		/*
+		 * If "page" is a THP tail, we must read the tail page
+		 * flags after the head page flags. The
+		 * split_huge_page side enforces write memory barriers
+		 * between clearing PageTail and before the head page
+		 * can be freed and reallocated.
+		 */
+		smp_rmb();
+		if (likely(PageTail(page))) {
 			/*
-			 * page_head wasn't a dangling pointer but it
-			 * may not be a head page anymore by the time
-			 * we obtain the lock. That is ok as long as it
-			 * can't be freed from under us.
+			 * __split_huge_page_refcount cannot race
+			 * here.
 			 */
-			flags = compound_lock_irqsave(page_head);
-			if (unlikely(!PageTail(page))) {
-				/* __split_huge_page_refcount run before us */
-				compound_unlock_irqrestore(page_head, flags);
-				if (put_page_testzero(page_head)) {
-					/*
-					 * The head page may have been
-					 * freed and reallocated as a
-					 * compound page of smaller
-					 * order and then freed again.
-					 * All we know is that it
-					 * cannot have become: a THP
-					 * page, a compound page of
-					 * higher order, a tail page.
-					 * That is because we still
-					 * hold the refcount of the
-					 * split THP tail and
-					 * page_head was the THP head
-					 * before the split.
-					 */
-					if (PageHead(page_head))
-						__put_compound_page(page_head);
-					else
-						__put_single_page(page_head);
-				}
-out_put_single:
-				if (put_page_testzero(page))
-					__put_single_page(page);
-				return;
+			VM_BUG_ON(!PageHead(page_head));
+			VM_BUG_ON(page_mapcount(page) != 0);
+			if (put_page_testzero(page_head)) {
+				/*
+				 * If this is the tail of a slab
+				 * compound page, the tail pin must
+				 * not be the last reference held on
+				 * the page, because the PG_slab
+				 * cannot be cleared before all tail
+				 * pins (which skips the _mapcount
+				 * tail refcounting) have been
+				 * released. For hugetlbfs the tail
+				 * pin may be the last reference on
+				 * the page instead, because
+				 * PageHeadHuge will not go away until
+				 * the compound page enters the buddy
+				 * allocator.
+				 */
+				VM_BUG_ON(PageSlab(page_head));
+				__put_compound_page(page_head);
 			}
-			VM_BUG_ON(page_head != page->first_page);
+			return;
+		} else
 			/*
-			 * We can release the refcount taken by
-			 * get_page_unless_zero() now that
-			 * __split_huge_page_refcount() is blocked on
-			 * the compound_lock.
+			 * __split_huge_page_refcount run before us,
+			 * "page" was a THP tail. The split page_head
+			 * has been freed and reallocated as slab or
+			 * hugetlbfs page of smaller order (only
+			 * possible if reallocated as slab on x86).
 			 */
-			if (put_page_testzero(page_head))
-				VM_BUG_ON(1);
-			/* __split_huge_page_refcount will wait now */
-			VM_BUG_ON(page_mapcount(page) <= 0);
-			atomic_dec(&page->_mapcount);
-			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
-			VM_BUG_ON(atomic_read(&page->_count) != 0);
-			compound_unlock_irqrestore(page_head, flags);
+			goto out_put_single;
+	}
+
+	if (likely(page != page_head && get_page_unless_zero(page_head))) {
+		unsigned long flags;
 
+		/*
+		 * page_head wasn't a dangling pointer but it may not
+		 * be a head page anymore by the time we obtain the
+		 * lock. That is ok as long as it can't be freed from
+		 * under us.
+		 */
+		flags = compound_lock_irqsave(page_head);
+		if (unlikely(!PageTail(page))) {
+			/* __split_huge_page_refcount run before us */
+			compound_unlock_irqrestore(page_head, flags);
 			if (put_page_testzero(page_head)) {
+				/*
+				 * The head page may have been freed
+				 * and reallocated as a compound page
+				 * of smaller order and then freed
+				 * again.  All we know is that it
+				 * cannot have become: a THP page, a
+				 * compound page of higher order, a
+				 * tail page.  That is because we
+				 * still hold the refcount of the
+				 * split THP tail and page_head was
+				 * the THP head before the split.
+				 */
 				if (PageHead(page_head))
 					__put_compound_page(page_head);
 				else
 					__put_single_page(page_head);
 			}
-		} else {
-			/* page_head is a dangling pointer */
-			VM_BUG_ON(PageTail(page));
-			goto out_put_single;
+out_put_single:
+			if (put_page_testzero(page))
+				__put_single_page(page);
+			return;
 		}
-	} else if (put_page_testzero(page)) {
-		if (PageHead(page))
-			__put_compound_page(page);
-		else
-			__put_single_page(page);
+		VM_BUG_ON(page_head != page->first_page);
+		/*
+		 * We can release the refcount taken by
+		 * get_page_unless_zero() now that
+		 * __split_huge_page_refcount() is blocked on the
+		 * compound_lock.
+		 */
+		if (put_page_testzero(page_head))
+			VM_BUG_ON(1);
+		/* __split_huge_page_refcount will wait now */
+		VM_BUG_ON(page_mapcount(page) <= 0);
+		atomic_dec(&page->_mapcount);
+		VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
+		VM_BUG_ON(atomic_read(&page->_count) != 0);
+		compound_unlock_irqrestore(page_head, flags);
+
+		if (put_page_testzero(page_head)) {
+			if (PageHead(page_head))
+				__put_compound_page(page_head);
+			else
+				__put_single_page(page_head);
+		}
+	} else {
+		/* page_head is a dangling pointer */
+		VM_BUG_ON(PageTail(page));
+		goto out_put_single;
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
