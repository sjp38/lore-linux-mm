Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 794DD6B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:08:37 -0400 (EDT)
Received: by oiev17 with SMTP id v17so16209367oie.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 22:08:37 -0700 (PDT)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id 136si13359011oik.17.2015.09.29.22.08.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Sep 2015 22:08:36 -0700 (PDT)
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 29 Sep 2015 23:08:36 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 680BD19D8026
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 22:59:26 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8U57MnI9896246
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 22:07:22 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8U58X5v025063
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 23:08:33 -0600
Date: Tue, 29 Sep 2015 22:08:33 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC v2 00/18] kthread: Use kthread worker API more widely
Message-ID: <20150930050833.GA4412@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 21, 2015 at 03:03:41PM +0200, Petr Mladek wrote:
> My intention is to make it easier to manipulate kthreads. This RFC tries
> to use the kthread worker API. It is based on comments from the
> first attempt. See https://lkml.org/lkml/2015/7/28/648 and
> the list of changes below.
> 
> 1st..8th patches: improve the existing kthread worker API
> 
> 9th, 12th, 17th patches: convert three kthreads into the new API,
>      namely: khugepaged, ring buffer benchmark, RCU gp kthreads[*]
> 
> 10th, 11th patches: fix potential problems in the ring buffer
>       benchmark; also sent separately
> 
> 13th patch: small fix for RCU kthread; also sent separately;
>      being tested by Paul
> 
> 14th..16th patches: preparation steps for the RCU threads
>      conversion; they are needed _only_ if we split GP start
>      and QS handling into separate works[*]
> 
> 18th patch: does a possible improvement of the kthread worker API;
>      it adds an extra parameter to the create*() functions, so I
>      rather put it into this draft
>      
> 
> [*] IMPORTANT: I tried to split RCU GP start and GS state handling
>     into separate works this time. But there is a problem with
>     a race in rcu_gp_kthread_worker_poke(). It might queue
>     the wrong work. It can be detected and fixed by the work
>     itself but it is a bit ugly. Alternative solution is to
>     do both operations in one work. But then we sleep too much
>     in the work which is ugly as well. Any idea is appreciated.

I think that the kernel is trying really hard to tell you that splitting
up the RCU grace-period kthreads in this manner is not such a good idea.

So what are we really trying to accomplish here?  I am guessing something
like the following:

1.	Get each grace-period kthread to a known safe state within a
	short time of having requested a safe state.  If I recall
	correctly, the point of this is to allow no-downtime kernel
	patches to the functions executed by the grace-period kthreads.

2.	At the same time, if someone suddenly needs a grace period
	at some point in this process, the grace period kthreads are
	going to have to wake back up and handle the grace period.
	Or do you have some tricky way to guarantee that no one is
	going to need a grace period beyond the time you freeze
	the grace-period kthreads?

3.	The boost kthreads should not be a big problem because failing
	to boost simply lets the grace period run longer.

4.	The callback-offload kthreads are likely to be a big problem,
	because in systems configured with them, they need to be running
	to invoke the callbacks, and if the callbacks are not invoked,
	the grace period might just as well have failed to end.

5.	The per-CPU kthreads are in the same boat as the callback-offload
	kthreads.  One approach is to offline all the CPUs but one, and
	that will park all but the last per-CPU kthread.  But handling
	that last per-CPU kthread would likely be "good clean fun"...

6.	Other requirements?

One approach would be to simply say that the top-level rcu_gp_kthread()
function cannot be patched, and arrange for the grace-period kthreads
to park at some point within this function.  Or is there some requirement
that I am missing?

							Thanx, Paul

> Changes against v1:
> 
> + remove wrappers to manipulate the scheduling policy and priority
> 
> + remove questionable wakeup_and_destroy_kthread_worker() variant
> 
> + do not check for chained work when draining the queue
> 
> + allocate struct kthread worker in create_kthread_work() and
>   use more simple checks for running worker
> 
> + add support for delayed kthread works and use them instead
>   of waiting inside the works
> 
> + rework the "unrelated" fixes for the ring buffer benchmark
>   as discussed in the 1st RFC; also sent separately
> 
> + convert also the consumer in the ring buffer benchmark
> 
> 
> I have tested this patch set against the stable Linus tree
> for 4.3-rc2.
> 
> Petr Mladek (18):
>   kthread: Allow to call __kthread_create_on_node() with va_list args
>   kthread: Add create_kthread_worker*()
>   kthread: Add drain_kthread_worker()
>   kthread: Add destroy_kthread_worker()
>   kthread: Add pending flag to kthread work
>   kthread: Initial support for delayed kthread work
>   kthread: Allow to cancel kthread work
>   kthread: Allow to modify delayed kthread work
>   mm/huge_page: Convert khugepaged() into kthread worker API
>   ring_buffer: Do no not complete benchmark reader too early
>   ring_buffer: Fix more races when terminating the producer in the
>     benchmark
>   ring_buffer: Convert benchmark kthreads into kthread worker API
>   rcu: Finish folding ->fqs_state into ->gp_state
>   rcu: Store first_gp_fqs into struct rcu_state
>   rcu: Clean up timeouts for forcing the quiescent state
>   rcu: Check actual RCU_GP_FLAG_FQS when handling quiescent state
>   rcu: Convert RCU gp kthreads into kthread worker API
>   kthread: Better support freezable kthread workers
> 
>  include/linux/kthread.h              |  67 +++++
>  kernel/kthread.c                     | 544 ++++++++++++++++++++++++++++++++---
>  kernel/rcu/tree.c                    | 407 ++++++++++++++++----------
>  kernel/rcu/tree.h                    |  24 +-
>  kernel/rcu/tree_plugin.h             |  16 +-
>  kernel/rcu/tree_trace.c              |   2 +-
>  kernel/trace/ring_buffer_benchmark.c | 194 ++++++-------
>  mm/huge_memory.c                     | 116 ++++----
>  8 files changed, 1017 insertions(+), 353 deletions(-)
> 
> -- 
> 1.8.5.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
