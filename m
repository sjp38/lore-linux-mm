Message-ID: <3800C2BF.716C9D65@colorfullife.com>
Date: Sun, 10 Oct 1999 18:45:51 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: locking question: do_mmap(), do_munmap()
References: <Pine.GSO.4.10.9910101219370.16317-100000@weyl.math.psu.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alexander Viro wrote:
> 
> On Sun, 10 Oct 1999, Alexander Viro wrote:
> 
> >
> > [Cc'd to mingo]
> >
> > On Sun, 10 Oct 1999, Manfred Spraul wrote:
> >
> > > I've started adding "assert_down()" and "assert_kernellocked()" macros,
> > > and now I don't see the login prompt any more...
> > >
> > > eg. sys_mprotect calls merge_segments without lock_kernel().
> >
> > Manfred, Andrea - please stop it. Yes, it does and yes, it should.

Yes, it should cause oops?

> > Plonking the big lock around every access to VM is _not_ a solution

I never did that, I'll never do that, I only notice that the current
code is filled with races.

> >. If
> > swapper doesn't use mmap_sem - _swapper_ should be fixed. How the hell
> > does lock_kernel() have smaller deadlock potential than
> > down(&mm->mmap_sem)?

lock_kernel() is dropped on thread switch, the semaphore is not dropped.

> 
> OK, folks. Code in swapper (unuse_process(), right?) is called only from
> sys_swapoff(). It's a syscall. Andrea, could you show a scenario for
> deadlock here? OK, some process (but not the process doing swapoff()) may
> have the map locked So?  it is not going to release the thing - we are
> seriously screwed anyway (read: we already are in deadlock). We don't hold
> the semaphore ourselves.

AFAIK the problem is OOM:
* a process accesses a not-present, ie page fault:
...
handle_mm_fault(): this process own mm->mmap_sem.
->handle_pte_fault().
-> (eg.) do_wp_page().
-> get_free_page().
now get_free_page() notices that there is no free memory.
--> wakeup kswapd.

* the swapper runs, and it tries to swap out data from that process.
mm->mmap_sem is already acquired --> lock-up.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
