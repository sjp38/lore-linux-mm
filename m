Date: Mon, 28 Jun 1999 21:29:07 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <Pine.LNX.4.10.9906290032460.1588-100000@laser.random>
Message-ID: <Pine.BSO.4.10.9906282106580.10964-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 1999, Andrea Arcangeli wrote:
> On Mon, 28 Jun 1999, Chuck Lever wrote:
> >that doesn't hurt because try_to_free_page() doesn't acquire anything but
> >the kernel lock in my patch.  it looks something like:
> >
> >int try_to_free_pages(unsigned int gfp_mask)
> >{
> >	int priority = 6;
> >	int count = pager_daemon.swap_cluster;
> > 
> > 	wake_up_process(kswapd_process);
> >
> >	lock_kernel();
> >	do {
> >		while (shrink_mmap(priority, gfp_mask)) {
> >			if (!--count)
> >				goto done;
> >		}
> >
> >		shrink_dcache_memory(priority, gfp_mask);
> >	} while (--priority >= 0);
> >done:
> >	/* maybe slow this thread down while kswapd catches up */
> >	if (gfp_mask & __GFP_WAIT) {
> >		current->policy |= SCHED_YIELD;
> >		schedule();
> >	}
> >	unlock_kernel();
> >	return 1;
> >}
> 
> How do you get the information about "when" to start the swap activities?

try_to_free_pages() still wakes up kswapd whenever it is called.

> Maybe you have a separate try_to_free_pages() that does the plain-current
> try_to_free_pages() and you call it only from kswapd?

yes, that's exactly what i did.  what i can't figure out is why do the
shrink_mmap in both places?  seems like the shrink_mmap in kswapd is
overkill if it has just been awoken by try_to_free_pages.

> My guess is that you'll end with zero cache and you'll have to page-in
> from disk like h*ell when you reach swap with a resulting really bad
> iteractive behaviour.

nope.  it appears to work as well as the old way, maybe even a little
faster.  i still need to do more testing, though.

> I think that being able to swapout from the process context is a very nice
> feature because it cause the trashing task to block. This may looks not
> very important with the current low_on_memory bit, but here I have a
> per-task `trashing_memory' bitflag :).

swapping out never blocks a thread, since the swap out I/O request is
always asynchronous.  line 162 of mm/vmscan.c ::

        /* OK, do a physical asynchronous write to swap.  */
        rw_swap_page(WRITE, entry, (char *) page, 0);

stephen also mentioned "rate controlling" a trashing process, but since
nothing in swap_out spins or sleeps, how could a process be slowed except
by a little extra CPU time spent behind the global lock?  that will slow
everyone else down too, yes?

seems like try_to_free_pages ought to make a clear effort to recognize a
process that is growing quickly and slow it down by causing it to sleep.

> >the eventual goal of my adventure is to drop the kernel lock while doing
> >the page COW in do_wp_page, since in 2.3.6+, the COW is again protected
> >because of race conditions with kswapd.  this "protection" serializes all
> 
> It's only a partial snapshot, but it should show the picture. Basically I
> am locking down the page with the lock held, then when I have the page
> locked (I may sleep as well to lock it) I check if kswapd freed the
> mapping or if I can go ahead without the big kernel lock. It basically
> works but I had not the time to test it carefully yet.

locking pages is probably the right answer, IMHO.

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
