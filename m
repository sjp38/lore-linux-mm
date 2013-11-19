Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id CB11F6B0039
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 18:14:21 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so9126716pbb.28
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 15:14:21 -0800 (PST)
Received: from psmtp.com ([74.125.245.185])
        by mx.google.com with SMTP id dj6si12657758pad.264.2013.11.19.15.14.18
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 15:14:20 -0800 (PST)
Date: Tue, 19 Nov 2013 15:14:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: tail page refcounting optimization for slab and
 hugetlbfs
Message-Id: <20131119151416.9f5b298960db09a21d37418b@linux-foundation.org>
In-Reply-To: <1384537668-10283-4-git-send-email-aarcange@redhat.com>
References: <1384537668-10283-1-git-send-email-aarcange@redhat.com>
	<1384537668-10283-4-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, 15 Nov 2013 18:47:48 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:

> This skips the _mapcount mangling for slab and hugetlbfs pages.
> 
> The main trouble in doing this is to guarantee that PageSlab and
> PageHeadHuge remains constant for all get_page/put_page run on the
> tail of slab or hugetlbfs compound pages. Otherwise if they're set
> during get_page but not set during put_page, the _mapcount of the tail
> page would underflow.
> 
> PageHeadHuge will remain true until the compound page is released and
> enters the buddy allocator so it won't risk to change even if the tail
> page is the last reference left on the page.
> 
> PG_slab instead is cleared before the slab frees the head page with
> put_page, so if the tail pin is released after the slab freed the
> page, we would have a problem. But in the slab case the tail pin
> cannot be the last reference left on the page. This is because the
> slab code is free to reuse the compound page after a
> kfree/kmem_cache_free without having to check if there's any tail pin
> left. In turn all tail pins must be always released while the head is
> still pinned by the slab code and so we know PG_slab will be still set
> too.
> 
> ...
>
> +					if (put_page_testzero(page_head)) {
> +						/*
> +						 * If this is the tail
> +						 * of a a slab
> +						 * compound page, the
> +						 * tail pin must not
> +						 * be the last
> +						 * reference held on
> +						 * the page, because
> +						 * the PG_slab cannot
> +						 * be cleared before
> +						 * all tail pins
> +						 * (which skips the
> +						 * _mapcount tail
> +						 * refcounting) have
> +						 * been released. For
> +						 * hugetlbfs the tail
> +						 * pin may be the last
> +						 * reference on the
> +						 * page instead,
> +						 * because
> +						 * PageHeadHuge will
> +						 * not go away until
> +						 * the compound page
> +						 * enters the buddy
> +						 * allocator.
> +						 */
> +						VM_BUG_ON(PageSlab(page_head));

This looks like it was attacked by Lindent.  How's this look?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/swap.c: reorganize put_compound_page()

Tweak it so save a tab stop, make code layout slightly less nutty.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Pravin Shelar <pshelar@nicira.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Johannes Weiner <jweiner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/swap.c |  238 +++++++++++++++++++++++-----------------------------
 1 file changed, 107 insertions(+), 131 deletions(-)

diff -puN mm/swap.c~mm-swapc-reorganize-put_compound_page mm/swap.c
--- a/mm/swap.c~mm-swapc-reorganize-put_compound_page
+++ a/mm/swap.c
@@ -82,150 +82,126 @@ static void __put_compound_page(struct p
 
 static void put_compound_page(struct page *page)
 {
-	if (unlikely(PageTail(page))) {
-		/* __split_huge_page_refcount can run under us */
-		struct page *page_head = compound_trans_head(page);
-
-		if (likely(page != page_head &&
-			   get_page_unless_zero(page_head))) {
-			unsigned long flags;
-
-			/*
-			 * THP can not break up slab pages or
-			 * hugetlbfs pages so avoid taking
-			 * compound_lock() and skip the tail page
-			 * refcounting (in _mapcount) too. Slab
-			 * performs non-atomic bit ops on page->flags
-			 * for better performance. In particular
-			 * slab_unlock() in slub used to be a hot
-			 * path. It is still hot on arches that do not
-			 * support this_cpu_cmpxchg_double().
-			 */
-			if (PageSlab(page_head) || PageHeadHuge(page_head)) {
-				if (likely(PageTail(page))) {
-					/*
-					 * __split_huge_page_refcount
-					 * cannot race here.
-					 */
-					VM_BUG_ON(!PageHead(page_head));
-					VM_BUG_ON(atomic_read(&page->_mapcount)
-						  != -1);
-					if (put_page_testzero(page_head))
-						VM_BUG_ON(1);
-					if (put_page_testzero(page_head)) {
-						/*
-						 * If this is the tail
-						 * of a a slab
-						 * compound page, the
-						 * tail pin must not
-						 * be the last
-						 * reference held on
-						 * the page, because
-						 * the PG_slab cannot
-						 * be cleared before
-						 * all tail pins
-						 * (which skips the
-						 * _mapcount tail
-						 * refcounting) have
-						 * been released. For
-						 * hugetlbfs the tail
-						 * pin may be the last
-						 * reference on the
-						 * page instead,
-						 * because
-						 * PageHeadHuge will
-						 * not go away until
-						 * the compound page
-						 * enters the buddy
-						 * allocator.
-						 */
-						VM_BUG_ON(PageSlab(page_head));
-						__put_compound_page(page_head);
-					}
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
-			 * page_head wasn't a dangling pointer but it
-			 * may not be a head page anymore by the time
-			 * we obtain the lock. That is ok as long as it
-			 * can't be freed from under us.
-			 */
-			flags = compound_lock_irqsave(page_head);
-			if (unlikely(!PageTail(page))) {
-				/* __split_huge_page_refcount run before us */
-				compound_unlock_irqrestore(page_head, flags);
-skip_lock:
+	struct page *page_head;
+
+	if (likely(PageTail(page))) {
+		if (put_page_testzero(page)) {
+			if (PageHead(page))
+				__put_compound_page(page);
+			else
+				__put_single_page(page);
+		}
+		return;
+	}
+
+	/* __split_huge_page_refcount can run under us */
+	page_head = compound_trans_head(page);
+
+	if (likely(page != page_head && get_page_unless_zero(page_head))) {
+		unsigned long flags;
+
+		/*
+		 * THP can not break up slab pages or hugetlbfs pages so avoid
+		 * taking compound_lock() and skip the tail page refcounting
+		 * (in _mapcount) too. Slab performs non-atomic bit ops on
+		 * page->flags for better performance. In particular
+		 * slab_unlock() in slub used to be a hot path. It is still hot
+		 * on arches that do not support this_cpu_cmpxchg_double().
+		 */
+		if (PageSlab(page_head) || PageHeadHuge(page_head)) {
+			if (likely(PageTail(page))) {
+				/*
+				 * __split_huge_page_refcount cannot race here.
+				 */
+				VM_BUG_ON(!PageHead(page_head));
+				VM_BUG_ON(atomic_read(&page->_mapcount) != -1);
+				if (put_page_testzero(page_head))
+					VM_BUG_ON(1);
 				if (put_page_testzero(page_head)) {
 					/*
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
+					 * If this is the tail of a slab
+					 * compound page, the tail pin must not
+					 * be the last reference held on the
+					 * page, because the PG_slab cannot be
+					 * cleared before all tail pins (which
+					 * skips the _mapcount tail refcounting)
+					 * have been released. For hugetlbfs the
+					 * tail pin may be the last reference on
+					 * the page instead, because
+					 * PageHeadHuge will not go away until
+					 * the compound page enters the buddy
+					 * allocator.
 					 */
-					if (PageHead(page_head))
-						__put_compound_page(page_head);
-					else
-						__put_single_page(page_head);
+					VM_BUG_ON(PageSlab(page_head));
+					__put_compound_page(page_head);
 				}
-out_put_single:
-				if (put_page_testzero(page))
-					__put_single_page(page);
 				return;
-			}
-			VM_BUG_ON(page_head != page->first_page);
-			/*
-			 * We can release the refcount taken by
-			 * get_page_unless_zero() now that
-			 * __split_huge_page_refcount() is blocked on
-			 * the compound_lock.
-			 */
-			if (put_page_testzero(page_head))
-				VM_BUG_ON(1);
-			/* __split_huge_page_refcount will wait now */
-			VM_BUG_ON(page_mapcount(page) <= 0);
-			atomic_dec(&page->_mapcount);
-			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
-			VM_BUG_ON(atomic_read(&page->_count) != 0);
+			} else
+				/*
+				 * __split_huge_page_refcount run before us,
+				 * "page" was a THP tail. The split page_head
+				 * has been freed and reallocated as slab or
+				 * hugetlbfs page of smaller order (only
+				 * possible if reallocated as slab on x86).
+				 */
+				goto skip_lock;
+		}
+		/*
+		 * page_head wasn't a dangling pointer but it may not be a head
+		 * page anymore by the time we obtain the lock. That is ok as
+		 * long as it can't be freed from under us.
+		 */
+		flags = compound_lock_irqsave(page_head);
+		if (unlikely(!PageTail(page))) {
+			/* __split_huge_page_refcount run before us */
 			compound_unlock_irqrestore(page_head, flags);
-
+skip_lock:
 			if (put_page_testzero(page_head)) {
+				/*
+				 * The head page may have been freed and
+				 * reallocated as a compound page of smaller
+				 * order and then freed again.  All we know is
+				 * that it cannot have become: a THP page, a
+				 * compound page of higher order, a tail page.
+				 * That is because we still hold the refcount of
+				 * the split THP tail and page_head was the THP
+				 * head before the split.
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
+		}
+		VM_BUG_ON(page_head != page->first_page);
+		/*
+		 * We can release the refcount taken by get_page_unless_zero()
+		 * now that __split_huge_page_refcount() is blocked on the
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
 		}
-	} else if (put_page_testzero(page)) {
-		if (PageHead(page))
-			__put_compound_page(page);
-		else
-			__put_single_page(page);
+	} else {
+		/* page_head is a dangling pointer */
+		VM_BUG_ON(PageTail(page));
+		goto out_put_single;
 	}
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
