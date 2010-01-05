Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 640186B00F6
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 14:30:39 -0500 (EST)
Date: Tue, 5 Jan 2010 11:28:57 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.DEB.2.00.1001051301060.5119@router.home>
Message-ID: <alpine.LFD.2.00.1001051120430.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com> <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain> <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com> <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
 <alpine.LFD.2.00.1001050810380.3630@localhost.localdomain> <87wrzwbh0z.fsf@basil.nowhere.org> <alpine.LFD.2.00.1001050950500.3630@localhost.localdomain> <alpine.DEB.2.00.1001051211000.2246@router.home> <alpine.LFD.2.00.1001051019280.3630@localhost.localdomain>
 <alpine.DEB.2.00.1001051235200.2246@router.home> <alpine.LFD.2.00.1001051052150.3630@localhost.localdomain> <alpine.DEB.2.00.1001051301060.5119@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Tue, 5 Jan 2010, Christoph Lameter wrote:
> 
> The wait state is the processor being stopped due to not being able to
> access the cacheline. Not the processor spinning in the xadd loop. That
> only occurs if the critical section is longer than the timeout.

You don't know what you're talking about, do you?

Just go and read the source code.

The process is spinning currently in the spin_lock loop. Here, I'll quote 
it to you:

                LOCK_PREFIX "xaddw %w0, %1\n"
                "1:\t"
                "cmpb %h0, %b0\n\t"
                "je 2f\n\t"
                "rep ; nop\n\t"
                "movb %1, %b0\n\t"
                /* don't need lfence here, because loads are in-order */
                "jmp 1b\n"

note the loop that spins - reading the thing over and over - waiting for 
_that_ CPU to be the owner of the xadd ticket?

That's the one you have now, only because x86-64 uses the STUPID FALLBACK 
CODE for the rwsemaphores!

In contrast, look at what the non-stupid rwsemaphore code does (which 
triggers on x86-32):

                     LOCK_PREFIX "  incl      (%%eax)\n\t"
                     /* adds 0x00000001, returns the old value */
                     "  jns        1f\n"
                     "  call call_rwsem_down_read_failed\n"

(that's a "down_read()", which happens to be the op we care most about. 
See? That's a single locked "inc" (it avoids the xadd on the read side 
because of how we've biased things). In particular, notice how this means 
that we do NOT have fifty million CPU's all trying to read the same 
location while one writes to it successfully.

Spot the difference?

Here's putting it another way. Which of these schenarios do you think 
should result in less cross-node traffic:

 - multiple CPU's that - one by one - get the cacheline for exclusive 
   access.

 - multiple CPU's that - one by one - get the cacheline for exclusive 
   access, while other CPU's are all trying to read the same cacheline at 
   the same time, over and over again, in a loop.

See the shared part? See the difference? If you look at just a single lock 
acquire, it boils down to these two scenarios

 - one CPU gets the cacheline exclusively

 - one CPU gets the cacheline exclusively while <n> other CPU's are all 
   trying to read the old and the new value.

It really is that simple.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
