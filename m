Date: Tue, 29 Jun 1999 14:09:30 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <Pine.BSO.4.10.9906282106580.10964-100000@funky.monkey.org>
Message-ID: <Pine.LNX.4.10.9906290412140.11414-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 1999, Chuck Lever wrote:

>yes, that's exactly what i did.  what i can't figure out is why do the
>shrink_mmap in both places?  seems like the shrink_mmap in kswapd is
>overkill if it has just been awoken by try_to_free_pages.

If you remove the shrink_mmap from kswapd then you'll start swapping all
the time. shrink_mmap give us the information about the state of
the VM. So if you run it then you know if you should start swapping or
not.

>faster.  i still need to do more testing, though.

I suggest you to run some memory hog that rotate 20/30mbyte of data in the
swap to check iteractive performances.

>swapping out never blocks a thread, since the swap out I/O request is
>always asynchronous.  line 162 of mm/vmscan.c ::
>
>        /* OK, do a physical asynchronous write to swap.  */
>        rw_swap_page(WRITE, entry, (char *) page, 0);

At some point you must stop. As worse when you go out of request. The rate
at which you eat memory is far higher than the swapout speed.

Since the out-of-request is a too large bank, we have a nr_async_pages
limit after which we do sync I/O (set to SWAP_CLUSTER_MAX as default, 32
pages async than sync I/O).

>stephen also mentioned "rate controlling" a trashing process, but since
>nothing in swap_out spins or sleeps, how could a process be slowed except
>by a little extra CPU time spent behind the global lock?  that will slow
>everyone else down too, yes?

swapout stall. It has to stall since memory is faster than disk.

>> It's only a partial snapshot, but it should show the picture. Basically I
>> am locking down the page with the lock held, then when I have the page
>> locked (I may sleep as well to lock it) I check if kswapd freed the
>> mapping or if I can go ahead without the big kernel lock. It basically
>> works but I had not the time to test it carefully yet.
>
>locking pages is probably the right answer, IMHO.

Happy to hear that :).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
