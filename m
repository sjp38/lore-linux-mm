Received: from toip6.srvr.bell.ca ([209.226.175.125])
          by tomts13-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080728200843.LFAM29750.tomts13-srv.bellnexxia.net@toip6.srvr.bell.ca>
          for <linux-mm@kvack.org>; Mon, 28 Jul 2008 16:08:43 -0400
Date: Mon, 28 Jul 2008 16:08:42 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH 1/1] mm: unify pmd_free() implementation ->
	instrumentation
Message-ID: <20080728200841.GA31053@Krystal>
References: <1217260287-13115-1-git-send-email-righi.andrea@gmail.com> <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org> <1217261852.3503.89.camel@localhost.localdomain> <alpine.LFD.1.10.0807280937150.3486@nehalem.linux-foundation.org> <1217264339.3503.97.camel@localhost.localdomain> <alpine.LFD.1.10.0807281000070.3486@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0807281000070.3486@nehalem.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Andrea Righi <righi.andrea@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, "Frank Ch. Eigler" <fche@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

* Linus Torvalds (torvalds@linux-foundation.org) wrote:
> 
> 
> On Mon, 28 Jul 2008, James Bottomley wrote:
> > 
> > Sorry ... should have been clearer.  My main concern is the cost of
> > barrier() which is just a memory clobber ... we have to use barriers to
> > place the probe points correctly in the code.
> 
> Oh, "barrier()" itself has _much_ less cost.
> 
> It still has all the "needs to flush any global/address-taken-of variables 
> to memory" property and can thus cause reloads, but that's kind of the 
> point of it, after all. So in that sense "barrier()" is free: the only 
> cost of a barrier is the cost of what you actually need to get done. It's 
> not really "free", but it's also not any more costly than what your 
> objective was.
> 

The tracing instrumentation objective, the way I see it, is to have the
instrumented registers live at the instrumentation site when tracing is
active. Also, given that tracing probes _could_ modify global variables
(this is kernel code after all, so one could want to use it to provide
specific tuning of the scheduler activity), we would like this
instrumentation point to behave like a normal function call. Doing
otherwise could produce hard to debug compiler related issues when there
is expected interaction between specialized probes and the actual
instrumented function.

Just to make one point clear : tracers such as LTTng simply dumps the
data to a buffer, so such interaction does not exist. However, I've seen
that other "specialized" tracers (ftrace, blktrace, ..) can be much more
tied to the subsystem they trace, and that will problably end up being
used as a feedback-loop tuning hook.

So besides having a behavior consistent with what can be expected by the
C ABI (probes are written in C after all), the major point is to have
minimal side-effect on the instrumented function. The idea is to have
something that 1 - works without weird hard to debug corner cases, so
stable and production-ready _and_ 2 - is very efficient.

The tracepoints proposed, like the Markers, actually add a function call
in an unlikely() branch in the instrumented functions. It therefore uses
the compiler to generate the correct register dependencies at the
instrumentation site, but leaves the stack spilling in a dynamically
disabled region on cache-cold instructions. FWIW, it's actually better
than the Dtrace approach of nopping out a function call, because they
leave the stack setup in cache-hot instructions.

About turning leaf functions into non-leaf functions, we indeed have to
make sure we add them in locations less likely to change the resulting
code. It implies trying to instrument functions that are non-leaf. As a
quick example, let's have a look at the actual location of the proposed
scheduler tracepoints in sched.c :

wait_task_inactive()
  At least calls task_rq_lock, non-leaf.
try_to_wake_up()
  At least calls task_rq_lock, activate_task, ... : non-leaf.
wake_up_new_task()
  At least calls activate_task : non-leaf.
context_switch()
  Static inline, embedded in schedule(), which is itself non leaf : it
  calls, at least, thread_return : non-leaf.
sched_migrate_task()
  static function, inlined in sched_exec, which also calls
  sched_balance_self : non-leaf.

Result : none of these were leaf functions.

Actually, most of the function I have seen that were worth instrumenting
fell in either in those three categories :

- Complex function which includes function calls.
- Simple static inline function, embedded in another more complex
  function, itself including function calls.
- Simple "wrapper" function, taking arguments and passing them to a
  function pointer (VFS system calls provide many examples). These
  include, indeed, a function call.

So my conclusion is that adding a tracepoint should be done with care.
Probably it's worth documenting the side-effect of adding a tracepoint
to a leaf function, thus encouraging developers to add those in
non-leaf functions only, and to place them close to actual use of the
passed variables to minimize the register pressure overhead incurred by
trying to keep the variables live for a longer sequence of instruction.


Mathieu


> In contrast, the "objective" in an empty function call is seldom the 
> serialization, so in that case the serialization is all just unnecessary 
> overhead.
> 
> Also, barrier() avoids the big hit of turning a leaf function into a 
> non-leaf one. It also avoids all the fixed registers and the register 
> clobbers (although for tracing purposes you may end up setting up fixed 
> regs, of course).
> 
> The leaf -> non-leaf thing is actually often the major thing. Yes, the 
> compiler will often inline functions that are simple enough to be leaf 
> functions with no stack frame, so we don't have _that_ many of them, but 
> when it hits, it's often the most noticeable part of an unnecessary 
> function call. And "barrier()" should never trigger that problem.
> 
> 			Linus
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
