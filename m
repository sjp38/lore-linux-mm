Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 797D16B0034
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 16:35:24 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so5013549pbc.25
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 13:35:24 -0700 (PDT)
Date: Tue, 24 Sep 2013 22:35:12 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130924203512.GS9326@twins.programming.kicks-ass.net>
References: <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130923175052.GA20991@redhat.com>
 <20130924123821.GT12926@twins.programming.kicks-ass.net>
 <20130924160359.GA2739@redhat.com>
 <20130924124341.64d57912@gandalf.local.home>
 <20130924170631.GB5059@redhat.com>
 <20130924174717.GH9093@linux.vnet.ibm.com>
 <20130924180005.GA7148@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130924180005.GA7148@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Steven Rostedt <rostedt@goodmis.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Sep 24, 2013 at 08:00:05PM +0200, Oleg Nesterov wrote:
> On 09/24, Paul E. McKenney wrote:
> >
> > On Tue, Sep 24, 2013 at 07:06:31PM +0200, Oleg Nesterov wrote:
> > >
> > > If gcc can actually do something wrong, then I suspect this barrier()
> > > should be unconditional.
> >
> > If you are saying that there should be a barrier() on all return paths
> > from get_online_cpus(), I agree.
> 
> Paul, Peter, could you provide any (even completely artificial) example
> to explain me why do we need this barrier() ? I am puzzled. And
> preempt_enable() already has barrier...
> 
> 	get_online_cpus();
> 	do_something();
> 
> Yes, we need to ensure gcc doesn't reorder this code so that
> do_something() comes before get_online_cpus(). But it can't? At least
> it should check current->cpuhp_ref != 0 first? And if it is non-zero
> we do not really care, we are already in the critical section and
> this ->cpuhp_ref has only meaning in put_online_cpus().
> 
> Confused...


So the reason I put it in was because of the inline; it could possibly
make it do:

  test  0, current->cpuhp_ref
  je	label1:
  inc	current->cpuhp_ref

label2:
  do_something();

label1:
  inc	%gs:__preempt_count
  test	0, __cpuhp_writer
  jne	label3
  inc	%gs:__cpuhp_refcount
label5
  dec	%gs:__preempt_count
  je	label4
  jmp	label2
label3:
  call	__get_online_cpus();
  jmp	label5
label4:
  call	____preempt_schedule();
  jmp	label2

In which case the recursive fast path doesn't have a barrier() between
taking the ref and starting do_something().

I wanted to make absolutely sure nothing of do_something leaked before
the label2 thing. The other labels all have barrier() from the
preempt_count ops.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
