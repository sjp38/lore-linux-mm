Date: Sun, 10 Oct 1999 19:12:58 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910101219370.16317-100000@weyl.math.psu.edu>
Message-ID: <Pine.LNX.4.10.9910101900210.520-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Oct 1999, Alexander Viro wrote:

>sys_swapoff(). It's a syscall. Andrea, could you show a scenario for

do_page_fault -> down() -> GFP -> swap_out() -> down() -> deadlock

To grab the mm semaphore in swap_out we could swap_out only from kswapd
doing a kind of wakeup_and_wait_kswapd() ala wakeup_bdflush(1) but it would
be slow and I don't want to run worse than in 2.2.x in UP to get some more
SMP scalability in SMP (that won't pay the cost).

The other option is to make the mmap semaphore recursive checking that GFP
is not called in the middle of a vma change. I don't like this one it sound
not robust as the spinlock way to me (see below).

What I like is to go as in 2.2.x with a proper spinlock for doing vma
reads (I am _not_ talking about the big kernel lock!).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
