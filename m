Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5356B0039
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 05:42:40 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kp14so6817818pab.5
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 02:42:40 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id bs8si12271804pad.381.2014.04.29.02.42.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 02:42:39 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so6909646pab.27
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 02:42:39 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 2/3] mm/swap.c: split put_compound_page function
Date: Tue, 29 Apr 2014 17:42:28 +0800
Message-Id: <1fc028045336844fe9ba9ee27c406e6ebe4726f4.1398764420.git.nasa4836@gmail.com>
In-Reply-To: <b1987d6fb09745a5274895efbde79e37ff9557a3.1398764420.git.nasa4836@gmail.com>
References: <b1987d6fb09745a5274895efbde79e37ff9557a3.1398764420.git.nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, aarcange@redhat.com, nasa4836@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, put_compound_page should carefully handle tricky case
to avoid racing with compound page releasing or spliting, which
makes it growing quite lenthy(about 200+ lines) and need deep
tab indention, which makes it quite hard to follow and maintain.

Now based on two helpers introduced in the previous patch
("mm/swap.c: introduce put_[un]refcounted_compound_page helpers
for spliting put_compound_page"), this patch just replaces those
two lenthy code path with these two helpers, respectively.
Also, it has some comment rephrasing.

After this patch, the put_compound_page() will be very compact,
thus easy to read and maintain.

After spliting, the object file is of same size as the original one.
Actually, I've diff'ed put_compound_page()'s orginal disassemble code
and the patched disassemble code, the are 100% the same!

This fact shows that this spliting has no functinal change,
but it brings readability.

This patch and the previous one blow the code by 32 lines, which
mostly credits to comments.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/swap.c | 142 +++++++-------------------------------------------------------
 1 file changed, 16 insertions(+), 126 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index a576449..d8654d8 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -225,6 +225,11 @@ static void put_compound_page(struct page *page)
 {
 	struct page *page_head;
 
+	/*
+	 * We see the PageCompound set and PageTail not set, so @page maybe:
+	 *  1. hugetlbfs head page, or
+	 *  2. THP head page.
+	 */
 	if (likely(!PageTail(page))) {
 		if (put_page_testzero(page)) {
 			/*
@@ -239,135 +244,20 @@ static void put_compound_page(struct page *page)
 		return;
 	}
 
-	/* __split_huge_page_refcount can run under us */
-	page_head = compound_head(page);
-
 	/*
-	 * THP can not break up slab pages so avoid taking
-	 * compound_lock() and skip the tail page refcounting (in
-	 * _mapcount) too. Slab performs non-atomic bit ops on
-	 * page->flags for better performance. In particular
-	 * slab_unlock() in slub used to be a hot path. It is still
-	 * hot on arches that do not support
-	 * this_cpu_cmpxchg_double().
+	 * We see the PageCompound set and PageTail set, so @page maybe:
+	 *  1. a tail hugetlbfs page, or
+	 *  2. a tail THP page, or
+	 *  3. a split THP page.
 	 *
-	 * If "page" is part of a slab or hugetlbfs page it cannot be
-	 * splitted and the head page cannot change from under us. And
-	 * if "page" is part of a THP page under splitting, if the
-	 * head page pointed by the THP tail isn't a THP head anymore,
-	 * we'll find PageTail clear after smp_rmb() and we'll treat
-	 * it as a single page.
+	 *  Case 3 is possible, as we may race with
+	 *  __split_huge_page_refcount tearing down a THP page.
 	 */
-	if (!__compound_tail_refcounted(page_head)) {
-		/*
-		 * If "page" is a THP tail, we must read the tail page
-		 * flags after the head page flags. The
-		 * split_huge_page side enforces write memory barriers
-		 * between clearing PageTail and before the head page
-		 * can be freed and reallocated.
-		 */
-		smp_rmb();
-		if (likely(PageTail(page))) {
-			/*
-			 * __split_huge_page_refcount cannot race
-			 * here.
-			 */
-			VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
-			VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
-			if (put_page_testzero(page_head)) {
-				/*
-				 * If this is the tail of a slab
-				 * compound page, the tail pin must
-				 * not be the last reference held on
-				 * the page, because the PG_slab
-				 * cannot be cleared before all tail
-				 * pins (which skips the _mapcount
-				 * tail refcounting) have been
-				 * released. For hugetlbfs the tail
-				 * pin may be the last reference on
-				 * the page instead, because
-				 * PageHeadHuge will not go away until
-				 * the compound page enters the buddy
-				 * allocator.
-				 */
-				VM_BUG_ON_PAGE(PageSlab(page_head), page_head);
-				__put_compound_page(page_head);
-			}
-			return;
-		} else
-			/*
-			 * __split_huge_page_refcount run before us,
-			 * "page" was a THP tail. The split page_head
-			 * has been freed and reallocated as slab or
-			 * hugetlbfs page of smaller order (only
-			 * possible if reallocated as slab on x86).
-			 */
-			goto out_put_single;
-	}
-
-	if (likely(page != page_head && get_page_unless_zero(page_head))) {
-		unsigned long flags;
-
-		/*
-		 * page_head wasn't a dangling pointer but it may not
-		 * be a head page anymore by the time we obtain the
-		 * lock. That is ok as long as it can't be freed from
-		 * under us.
-		 */
-		flags = compound_lock_irqsave(page_head);
-		if (unlikely(!PageTail(page))) {
-			/* __split_huge_page_refcount run before us */
-			compound_unlock_irqrestore(page_head, flags);
-			if (put_page_testzero(page_head)) {
-				/*
-				 * The head page may have been freed
-				 * and reallocated as a compound page
-				 * of smaller order and then freed
-				 * again.  All we know is that it
-				 * cannot have become: a THP page, a
-				 * compound page of higher order, a
-				 * tail page.  That is because we
-				 * still hold the refcount of the
-				 * split THP tail and page_head was
-				 * the THP head before the split.
-				 */
-				if (PageHead(page_head))
-					__put_compound_page(page_head);
-				else
-					__put_single_page(page_head);
-			}
-out_put_single:
-			if (put_page_testzero(page))
-				__put_single_page(page);
-			return;
-		}
-		VM_BUG_ON_PAGE(page_head != page->first_page, page);
-		/*
-		 * We can release the refcount taken by
-		 * get_page_unless_zero() now that
-		 * __split_huge_page_refcount() is blocked on the
-		 * compound_lock.
-		 */
-		if (put_page_testzero(page_head))
-			VM_BUG_ON_PAGE(1, page_head);
-		/* __split_huge_page_refcount will wait now */
-		VM_BUG_ON_PAGE(page_mapcount(page) <= 0, page);
-		atomic_dec(&page->_mapcount);
-		VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0, page_head);
-		VM_BUG_ON_PAGE(atomic_read(&page->_count) != 0, page);
-		compound_unlock_irqrestore(page_head, flags);
-
-		if (put_page_testzero(page_head)) {
-			if (PageHead(page_head))
-				__put_compound_page(page_head);
-			else
-				__put_single_page(page_head);
-		}
-	} else {
-		/* page_head is a dangling pointer */
-		VM_BUG_ON_PAGE(PageTail(page), page);
-		goto out_put_single;
-	}
+	page_head = compound_head(page);
+	if (!__compound_tail_refcounted(page_head))
+		put_unrefcounted_compound_page(page_head, page);
+	else
+		put_refcounted_compound_page(page_head, page);
 }
 
 void put_page(struct page *page)
-- 
2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
