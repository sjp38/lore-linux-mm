Date: Mon, 28 Jun 1999 17:14:17 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <14199.57040.245837.447659@dukat.scot.redhat.com>
Message-ID: <Pine.BSO.4.10.9906281648010.24888-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Andrea Arcangeli <andrea@suse.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 1999, Stephen C. Tweedie wrote:
> On Mon, 28 Jun 1999 15:39:43 -0400 (EDT), Chuck Lever <cel@monkey.org>
> said:
> > i'm already working on a patch that will allow kswapd to grab the
> > mmap_sem for the task that is about to be swapped.  this takes a
> > slightly different approach, since i'm focusing on kswapd and not on
> > swapoff.  
> 
> Don't, it will create a whole pile of new deadlock conditions.  Think
> carefully about what happens when you take a page fault, lock the mm,
> and then need to allocate a new page in memory to satisfy the fault.
> You end up recursively calling try_to_free_page, and if that needs to
> reacquire the mm semaphore then you are in major trouble.

that doesn't hurt because try_to_free_page() doesn't acquire anything but
the kernel lock in my patch.  it looks something like:

int try_to_free_pages(unsigned int gfp_mask)
{
	int priority = 6;
	int count = pager_daemon.swap_cluster;
 
 	wake_up_process(kswapd_process);

	lock_kernel();
	do {
		while (shrink_mmap(priority, gfp_mask)) {
			if (!--count)
				goto done;
		}

		shrink_dcache_memory(priority, gfp_mask);
	} while (--priority >= 0);
done:
	/* maybe slow this thread down while kswapd catches up */
	if (gfp_mask & __GFP_WAIT) {
		current->policy |= SCHED_YIELD;
		schedule();
	}
	unlock_kernel();
	return 1;
}

> The same mechanism can also block kswapd from making progress.

i'm re-using the mmap_sem, not the mm_sem.  only the mmap_sem for the
about-to-be-swapped object is acquired by kswapd.  is that unsafe?
or just silly?

> There's also the fact that
> swapping can deal with multiple mms at the same time: if you fork, you
> can get two mms which share the same COW page in memory or on swap.
> As a result, mm locking doesn't actually buy you enough extra
> protection for data pages to be worth it.

the eventual goal of my adventure is to drop the kernel lock while doing
the page COW in do_wp_page, since in 2.3.6+, the COW is again protected
because of race conditions with kswapd.  this "protection" serializes all
page faults behind a very expensive memory copy.  what other ways are
there to protect the COW operation while allowing some parallelism?  it
seems like this is worth a little complexity, IMO.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
