From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004082139.OAA06375@google.engr.sgi.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
Date: Sat, 8 Apr 2000 14:39:06 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.21.0004081514470.559-100000@alpha.random> from "Andrea Arcangeli" at Apr 08, 2000 03:20:25 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

As I said before, unless you have a _good_ reason, I don't see any point
in changing the code, just because it appears cleaner. As you note, there
are ample races with the swapdeletion code removing the page from the
swapcache, while a lookup is in progress, the PageLock _might_ be used
to fix those. In any case, after we agree that the races have been fixed
(and that's theoretically, there will probably be races observed under
real stress), it would be okay to then go and change the find_lock_page 
to find_get_page in lookup_swap_cache(). IMO, of course ...

> 
> On Fri, 7 Apr 2000, Kanoj Sarcar wrote:
> 
> >Okay, I think I found at least one reason why the lockpage was being done
> >in lookup_swap_cache(). It was effectively to check the PageSwapCache bit,
> >since shrink_mmap:__delete_from_swap_cache could race with a 
> >lookup_swap_cache.
> 
> shrink_mmap can't race with a find_get_cache. find_get_page increments the
> reference count within the critical section and shrink_mmap checks the
> page count and drop the page in one whole transaction within a mutually
> exclusive critical section.

Okay, how's this (from pre3):

shrink_mmap
--------------						__find_get_page
get pagemap_lru_lock					----------------
LockPage					
drop pagemap_lru_lock
Fail if page_count(page) > 1
get pagecache_lock
get_page
Fail if page_count(page) != 2
if PageSwapCache, drop pagecache_lock
							get pagecache_lock
							Finds page in swapcache,
								does get_page
							drop pagecache_lock
	and __delete_from_swap_cache,
	which releases PageLock.
							LockPage succeeds,
							erronesouly believes he
							has swapcache page.

Did I miss some interlocking step that would prevent this from happening?
	
> 
> >Yes, I did notice the recent shrink_mmap SMP race fixes that you posted,
> 
> They weren't relative to the cache, but only to the LRU list
> inserction/deletion. There wasn't races between shrink_mmap and
> find_get_page and friends.

Ok, so that's irrelevant ...

> 
> >now it _*might*_ be unneccesary to do a find_lock_page() in 
> >lookup_swap_cache() (just for this race). I will have to look at the 
> 
> It isn't. Checking PageSwapCache while the page is locked is not
> necessary. The only thing which can drop the page from the swap cache is
> swapoff that will do that as soon as you do the unlock before returning
> from lookup_swap_cache anyway.

Yes, see above too. Its probably better to have overenthusiastic locking,
than having lesser locking. As I mentioned before, the shrink_mmap race
is probably one of the reasons I did the PageLocking in lookup_swap_cache(),
I was probably thinking of swapdeletion too ...

Kanoj

> 
> Andrea
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
