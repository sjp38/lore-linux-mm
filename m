Date: Sun, 10 Oct 1999 12:25:33 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910101202240.16317-100000@weyl.math.psu.edu>
Message-ID: <Pine.GSO.4.10.9910101219370.16317-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 10 Oct 1999, Alexander Viro wrote:

> 
> [Cc'd to mingo]
> 
> On Sun, 10 Oct 1999, Manfred Spraul wrote:
> 
> > I've started adding "assert_down()" and "assert_kernellocked()" macros,
> > and now I don't see the login prompt any more...
> > 
> > eg. sys_mprotect calls merge_segments without lock_kernel().
> 
> Manfred, Andrea - please stop it. Yes, it does and yes, it should.
> Plonking the big lock around every access to VM is _not_ a solution. If
> swapper doesn't use mmap_sem - _swapper_ should be fixed. How the hell
> does lock_kernel() have smaller deadlock potential than
> down(&mm->mmap_sem)?

OK, folks. Code in swapper (unuse_process(), right?) is called only from
sys_swapoff(). It's a syscall. Andrea, could you show a scenario for
deadlock here? OK, some process (but not the process doing swapoff()) may
have the map locked So?  it is not going to release the thing - we are
seriously screwed anyway (read: we already are in deadlock). We don't hold
the semaphore ourselves.

Andrea, post a deadlock scenario, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
