Date: Sun, 10 Oct 1999 13:48:13 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.LNX.4.10.9910101900210.520-100000@alpha.random>
Message-ID: <Pine.GSO.4.10.9910101327010.16317-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 10 Oct 1999, Andrea Arcangeli wrote:

> On Sun, 10 Oct 1999, Alexander Viro wrote:
> 
> >sys_swapoff(). It's a syscall. Andrea, could you show a scenario for
> 
> do_page_fault -> down() -> GFP -> swap_out() -> down() -> deadlock

Yes, I had realized that I was looking into the wrong place. Unfortunately
after I've sent a posting. My apologies.

> To grab the mm semaphore in swap_out we could swap_out only from kswapd
> doing a kind of wakeup_and_wait_kswapd() ala wakeup_bdflush(1) but it would
> be slow and I don't want to run worse than in 2.2.x in UP to get some more
> SMP scalability in SMP (that won't pay the cost).
> 
> The other option is to make the mmap semaphore recursive checking that GFP
> is not called in the middle of a vma change. I don't like this one it sound
> not robust as the spinlock way to me (see below).
> 
> What I like is to go as in 2.2.x with a proper spinlock for doing vma
> reads (I am _not_ talking about the big kernel lock!).

I'm not sure that it will work (we scan the thing in many places and
quite a few may be blocking ;-/), unless you propose to protect individual
steps of the scan, which will give you lots of overhead. I suspect that
swap_out_mm() needs fixing, not everything else... And it looks like we
can't drop the sucker earlier in handle_mm_fault. Or can we?

As crazy as it may sound, what about keeping a small cache of pages,
taking from that cache and doing refills when we are crossing the boundary
of dangerous area (refusing to enter it until the number of pages in cache
will grow bigger than amount of processes in dangerous part)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
