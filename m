Message-ID: <20020826194855.3641.qmail@thales.mathematik.uni-ulm.de>
From: "Christian Ehrhardt" <ehrhardt@mathematik.uni-ulm.de>
Date: Mon, 26 Aug 2002 21:48:55 +0200
Subject: Re: MM patches against 2.5.31
References: <3D644C70.6D100EA5@zip.com.au> <E17jKlX-0001i0-00@starship> <20020826152950.9929.qmail@thales.mathematik.uni-ulm.de> <E17jO6g-0002XU-00@starship> <3D6A8082.3775C5AB@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D6A8082.3775C5AB@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Daniel Phillips <phillips@arcor.de>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 26, 2002 at 12:24:50PM -0700, Andrew Morton wrote:
> The flaw is in doing the put_page_testzero() outside of any locking

Well, one could argue that doing the put_page_testzero outside of any
locking is a feature.

>  [ ... ]
> 
> 2.5.31-mm1 has tests which make this race enormously improbable [1],
> but it's still there.

Agreed. Both on the improbable and on the still there part.

> It's that `put' outside the lock which is the culprit.  Normally, we
> handle that with atomic_dec_and_lock() (inodes) or by manipulating
> the refcount inside an area which has exclusion (page presence in
> pagecache).
> 
> The sane, sensible and sucky way is to always take the lock:
> 
> page_cache_release(page)
> {
> 	spin_lock(lru_lock);
> 	if (put_page_testzero(page)) {
> 		lru_cache_del(page);
> 		__free_pages_ok(page, 0);
> 	}
> 	spin_unlock(lru_lock);
> }

That would probably solve the problem.

> Because this provides exclusion from another CPU discovering the page
> via the LRU.
> 
> So taking the above as the design principle, how can we speed it up?
> How to avoid taking the lock in every page_cache_release()?  Maybe:
> 
> page_cache_release(page)
> {
> 	if (page_count(page) == 1) {
> 		spin_lock(lru_lock);
> 		if (put_page_testzero(page)) {
> 			if (PageLRU(page))
> 				__lru_cache_del(page);
> 			__free_pages_ok(page);
> 		}
> 		spin_unlock(lru_lock);
> 	} else {
> 		atomic_dec(&page->count);
> 	}
> }

However, this is an incredibly bad idea if the page is NOT on the lru.
Think of two instances of page_cache_release racing against each other.
This could result in a leaked page which is not on the LRU.

> This is nice and quick, but racy.  Two concurrent page_cache_releases
> will create a zero-ref unfreed page which is on the LRU.  These are
> rare, and can be mopped up in page reclaim.
> 
> The above code will also work for pages which aren't on the LRU.  It will
> take the lock unnecessarily for (say) slab pages.  But if we put slab pages
> on the LRU then I suspect there are so few non-LRU pages left that it isn't
> worth bothering about this.

No it will not work. See above.

> [1] The race requires that the CPU running page_cache_release find a
>     five instruction window against the CPU running shrink_cache.  And
>     that they be operating against the same page.  And that the CPU
>     running __page_cache_release() then take an interrupt in a 3-4
>     instruction window.  And that the interrupt take longer than the
>     runtime for shrink_list.  And that the page be the first page in
>     the pagevec.

The interrupt can also be a preemption which might easily take long
enough. But I agree that the race is now rare. The real problem is
that the locking rules don't guarantee that there are no other racy
paths that we both missed. 

    regards   Christian

-- 
THAT'S ALL FOLKS!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
