Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 66E296B0037
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 12:51:39 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so4782694pbb.38
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:51:39 -0700 (PDT)
Date: Tue, 24 Sep 2013 18:51:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130924165121.GQ9326@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130923175052.GA20991@redhat.com>
 <20130924123821.GT12926@twins.programming.kicks-ass.net>
 <20130924160359.GA2739@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130924160359.GA2739@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Tue, Sep 24, 2013 at 06:03:59PM +0200, Oleg Nesterov wrote:
> On 09/24, Peter Zijlstra wrote:
> >
> > +static inline void get_online_cpus(void)
> > +{
> > +	might_sleep();
> > +
> > +	if (current->cpuhp_ref++) {
> > +		barrier();
> > +		return;
> 
> I don't undestand this barrier()... we are going to return if we already
> hold the lock, do we really need it?
> 
> The same for put_online_cpus().

to make {get,put}_online_cpus() always behave like per-cpu lock
sections.

I don't think its ever 'correct' for loads/stores to escape the section,
even if not strictly harmful.

> > +void __get_online_cpus(void)
> >  {
> > -	if (cpu_hotplug.active_writer == current)
> > +	if (cpuhp_writer_task == current)
> >  		return;
> 
> Probably it would be better to simply inc/dec ->cpuhp_ref in
> cpu_hotplug_begin/end and remove this check here and in
> __put_online_cpus().

Oh indeed!

> > +     if (atomic_dec_and_test(&cpuhp_waitcount) && cpuhp_writer_task)
> > +             cpuhp_writer_wake();
> 
> cpuhp_writer_wake() here and in __put_online_cpus() looks racy...

Yeah it is. Paul already said.

> But, Peter, the main question is, why this is better than
> percpu_rw_semaphore performance-wise? (Assuming we add
> task_struct->cpuhp_ref).
> 
> If the writer is pending, percpu_down_read() does
> 
> 	down_read(&brw->rw_sem);
> 	atomic_inc(&brw->slow_read_ctr);
> 	__up_read(&brw->rw_sem);
> 
> is it really much worse than wait_event + atomic_dec_and_test?
> 
> And! please note that with your implementation the new readers will
> be likely blocked while the writer sleeps in synchronize_sched().
> This doesn't happen with percpu_rw_semaphore.

Good points both, no I don't think there's a significant performance gap
there.

I'm still hoping we can come up with something better though :/ I don't
particularly like either.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
