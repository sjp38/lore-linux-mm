From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14200.46326.332605.961051@dukat.scot.redhat.com>
Date: Tue, 29 Jun 1999 12:58:46 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <Pine.BSO.4.10.9906282106580.10964-100000@funky.monkey.org>
References: <Pine.LNX.4.10.9906290032460.1588-100000@laser.random>
	<Pine.BSO.4.10.9906282106580.10964-100000@funky.monkey.org>
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.3.96.990629093002.7614F@mole.spellcast.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 21:29:07 -0400 (EDT), Chuck Lever <cel@monkey.org>
said:

> yes, that's exactly what i did.  what i can't figure out is why do the
> shrink_mmap in both places?  seems like the shrink_mmap in kswapd is
> overkill if it has just been awoken by try_to_free_pages.

It hasn't necessarily.  It may have been woken by networking activity.
If the memory requirements are being driven by interrupts, not
processes, then kswapd is the only chance for shrink_mmap to be called.

> stephen also mentioned "rate controlling" a trashing process, but since
> nothing in swap_out spins or sleeps, how could a process be slowed except
> by a little extra CPU time spent behind the global lock?  that will slow
> everyone else down too, yes?

There are IO queue limits which will eventually stall the process.  The
ll_rw_block itself one rate limiter.  We also have a test in
rw_swap_page_base:

	/* Don't allow too many pending pages in flight.. */
	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
		wait = 1;

which causes the swapout to become synchronous once we have filled the
swapper queues.

> seems like try_to_free_pages ought to make a clear effort to recognize a
> process that is growing quickly and slow it down by causing it to sleep.

It does. 

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
