From: David Howells <dhowells@redhat.com>
In-Reply-To: <20070413124303.GD966@wotan.suse.de> 
References: <20070413124303.GD966@wotan.suse.de>  <20070413100416.GC31487@wotan.suse.de> <25821.1176466182@redhat.com> 
Subject: Re: [patch] generic rwsems 
Date: Fri, 13 Apr 2007 14:31:52 +0100
Message-ID: <30644.1176471112@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote:

> The other way happens to be better for everyone else, which is why I
> think your suggestion to instead move everyone to the spinlock version
> was weird.

No, you misunderstand me.  My preferred solution is to leave it up to the arch
and not to make it generic, though I'm not averse to providing some prepackaged
solutions for an arch to pick from if it wants to.

> Finally: as I said, even for those 2 architectures, this may not be so
> bad because it is using a different spinlock for the fastpath as it is
> for the slowpath. So your uncontested, cache cold case will get a little
> slower, but the contested case could improve a lot (eg. I saw an order of
> magnitude improvement).

Agreed.  I can see why the spinlock implementation is bad on SMP.  By all means
change those cases, and reduce the spinlock implementation to an interrupt
disablement only version that may only be used on UP only.

> 32-bit machines might indeed overflow, but if it hasn't been a problem
> for i386 or (even 64-bit) powerpc yet, is it a real worry? 

It has happened, I believe.  People have tried having >32766 threads on a
32-bit box.  Mad it may be, but...

> This is what spinlocks and mutexes do, and they're much more common than
> rwsems. I'm just trying to make it consistent, and you can muck around
> with it all you want after that. It is actually very easy to inline
> things now, unlike before my patch.

My original stuff was very easy to inline until Ingo got hold of it.

> > Think about it.  This algorithm is only optimal where XADD is available.  If
> > you don't have XADD, but you do have LL/SC or CMPXCHG, you can do better.
> 
> You keep saying this too, and I have thought about it but I couldn't think
> of a much better way. I'm not saying you're wrong, but why don't you just
> tell me what that better way is?

Look at how the counter works in the spinlock case.  With the addition of an
extra flag in the counter to indicate there's stuff waiting on the queue, you
can manipulate the counter if it appears safe to do so, otherwise you have to
fall back to the slow path and take a spin lock.

Break the counter down like this:

	0x00000000	- not locked; queue empty
	0x40000000	- locked by writer; queue empty
	0xc0000000	- locket by writer; queue occupied
	0x0nnnnnnn	- n readers; queue empty
	0x8nnnnnnn	- n readers; queue occupied

Now here's a rough guide as to how the main operations would work:

 (*) down_read of unlocked

	cmpxchg(0 -> 1) -> 0 [okay - you've got the lock]

 (*) down_read of readlocked.

	cmpxchg(0 -> 1) -> n [failed to get the lock]
	do
	  n = cmpxchg(old_n -> old_n+1)
        until n == old_n

 (*) down_read of writelocked or contented readlocked.

	cmpxchg(0 -> 1) -> 0x80000000|n  [lock contended]
	goto slowpath
	  spinlock
	  try to get lock again
	  if still contended
	    mark counter contended
	    add to queue
            spinunlock
	    sleep
          spinunlock

 (*) down_write of unlocked

	cmpxchg(0 -> 0x40000000) -> 0 [okay - you've got the lock]

 (*) down_write of locked, contended or otherwise

	cmpxchg(0 -> 0x40000000) -> nz [failed]
	goto slowpath
	  spinlock
	  try to get lock again
	  if still unavailable
	    mark counter contended
	    add to queue
            spinunlock
	    sleep
	  else
            spinunlock

 (*) up_read

        x = cmpxchg(1 -> 0)
        if x == 0
	  done
        else
           do
	     x = cmpxchg(old_x -> old_x-1)
	   until x == old_x
           if old_x == 0x80000000
	     wake_up_writer

 (*) up_write

        x = cmpxchg(0x80000000 -> 0)
        if x == 0
	  done
        else
	  wake_up_readers

You can actually do better with LL/SC here because for the initial attempt with
CMPXCHG in each case you have to guess what the numbers will be.  Furthermore,
you might actually be able to do an "atomic increment or set contention flag"
operation.

Note that the contention flag may only be set or cleared in the slow path
whilst you are holding the spinlock.

Doing down_read and up_read with CMPXCHG is a pain.  XADD or LL/SC would be
better, and LOCK INC/ADD/DEC/SUB won't work.  You can't use XADD in down_*() as
you may not change the bottom part of the counter if you're going to end up
queuing.

Actually, looking at it, it might be better to have the counter start off at
0x80000000 for "unlocked, no contention" and clear the no-contention flag when
you queue something.  That way you can check for the counter becoming 0 in the
up_*() functions as a trigger to go and invoke the slowpath.  Then you could
use LOCK DEC/SUB on i386 rather than XADD as you only need to check the Z flag.

Note there is a slight window whereby a reader can jump a writer that's
transiting between the fastpath part of down_write() and the slowpath part if
there are outstanding readers on the rwsem but nothing yet queued.

OTOH, there's a similar window in the current XADD-based rwsems as the spinlock
doesn't implement FIFO semantics, so the first to modify the count and fail to
the slowpath may not be the first to get themselves on the queue.

> > similarly if you are using a UP-compiled kernel.
> 
> Then your UP-compiled kernel's atomic ops are suboptimal, not the rwsem
> implementation.

That's usually a function of the CPU designer.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
