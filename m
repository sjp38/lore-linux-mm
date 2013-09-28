Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id E78A66B0032
	for <linux-mm@kvack.org>; Sat, 28 Sep 2013 16:46:38 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so3950657pbc.3
        for <linux-mm@kvack.org>; Sat, 28 Sep 2013 13:46:38 -0700 (PDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 28 Sep 2013 14:46:35 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 443EE1FF001A
	for <linux-mm@kvack.org>; Sat, 28 Sep 2013 14:46:27 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8SKkXPH369590
	for <linux-mm@kvack.org>; Sat, 28 Sep 2013 14:46:33 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8SKnbIG010982
	for <linux-mm@kvack.org>; Sat, 28 Sep 2013 14:49:37 -0600
Date: Sat, 28 Sep 2013 13:46:30 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130928204630.GG9093@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130925174307.GA3220@laptop.programming.kicks-ass.net>
 <20130925175055.GA25914@redhat.com>
 <20130925184015.GC3657@laptop.programming.kicks-ass.net>
 <20130925212200.GA7959@linux.vnet.ibm.com>
 <20130926111042.GS3081@twins.programming.kicks-ass.net>
 <20130926165840.GA863@redhat.com>
 <20130926175016.GI3657@laptop.programming.kicks-ass.net>
 <20130927181532.GA8401@redhat.com>
 <20130927204116.GJ15690@laptop.programming.kicks-ass.net>
 <20130928124859.GA13425@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130928124859.GA13425@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Sat, Sep 28, 2013 at 02:48:59PM +0200, Oleg Nesterov wrote:
> On 09/27, Peter Zijlstra wrote:
> >
> > On Fri, Sep 27, 2013 at 08:15:32PM +0200, Oleg Nesterov wrote:
> >
> > > > +static bool cpuhp_readers_active_check(void)
> > > >  {
> > > > +	unsigned int seq = per_cpu_sum(cpuhp_seq);
> > > > +
> > > > +	smp_mb(); /* B matches A */
> > > > +
> > > > +	/*
> > > > +	 * In other words, if we see __get_online_cpus() cpuhp_seq increment,
> > > > +	 * we are guaranteed to also see its __cpuhp_refcount increment.
> > > > +	 */
> > > >
> > > > +	if (per_cpu_sum(__cpuhp_refcount) != 0)
> > > > +		return false;
> > > >
> > > > +	smp_mb(); /* D matches C */
> > >
> > > It seems that both barries could be smp_rmb() ? I am not sure the comments
> > > from srcu_readers_active_idx_check() can explain mb(),
> 
> To avoid the confusion, I meant "those comments can't explain mb()s here,
> in cpuhp_readers_active_check()".
> 
> > > note that
> > > __srcu_read_lock() always succeeds unlike get_cpus_online().
> 
> And this cput_hotplug_ and synchronize_srcu() differ, see below.
> 
> > I see what you mean; cpuhp_readers_active_check() is all purely reads;
> > there are no writes to order.
> >
> > Paul; is there any argument for the MB here as opposed to RMB;
> 
> Yes, Paul, please ;)

Sorry to be slow -- I will reply by end of Monday Pacific time at the
latest.  I need to allow myself enough time so that it seems new...

Also I might try some mechanical proofs of parts of it.

							Thanx, Paul

> > and if
> > not should we change both these and SRCU?
> 
> I guess that SRCU is more "complex" in this respect. IIUC,
> cpuhp_readers_active_check() needs "more" barriers because if
> synchronize_srcu() succeeds it needs to synchronize with the new readers
> which call srcu_read_lock/unlock() "right now". Again, unlike cpu-hotplug
> srcu never blocks the readers, srcu_read_*() always succeeds.
> 
> 
> 
> Hmm. I am wondering why __srcu_read_lock() needs ACCESS_ONCE() to increment
> ->c and ->seq. A plain this_cpu_inc() should be fine?
> 
> And since it disables preemption, why it can't use __this_cpu_inc() to inc
> ->c[idx]. OK, in general __this_cpu_inc() is not irq-safe (rmw) so we can't
> do __this_cpu_inc(seq[idx]), c[idx] should be fine? If irq does srcu_read_lock()
> it should also do _unlock.
> 
> But this is minor/offtopic.
> 
> > > >  void cpu_hotplug_done(void)
> > > >  {
> ...
> > > > +	/*
> > > > +	 * Wait for any pending readers to be running. This ensures readers
> > > > +	 * after writer and avoids writers starving readers.
> > > > +	 */
> > > > +	wait_event(cpuhp_writer, !atomic_read(&cpuhp_waitcount));
> > > >  }
> > >
> > > OK, to some degree I can understand "avoids writers starving readers"
> > > part (although the next writer should do synchronize_sched() first),
> > > but could you explain "ensures readers after writer" ?
> >
> > Suppose reader A sees state == BLOCK and goes to sleep; our writer B
> > does cpu_hotplug_done() and wakes all pending readers. If for some
> > reason A doesn't schedule to inc ref until B again executes
> > cpu_hotplug_begin() and state is once again BLOCK, A will not have made
> > any progress.
> 
> Yes, yes, thanks, this is clear. But this explains "writers starving readers".
> And let me repeat, if B again executes cpu_hotplug_begin() it will do
> another synchronize_sched() before it sets BLOCK, so I am not sure we
> need this "in practice".
> 
> I was confused by "ensures readers after writer", I thought this means
> we need the additional synchronization with the readers which are going
> to increment cpuhp_waitcount, say, some sort of barries.
> 
> Please note that this wait_event() adds a problem... it doesn't allow
> to "offload" the final synchronize_sched(). Suppose a 4k cpu machine
> does disable_nonboot_cpus(), we do not want 2 * 4k * synchronize_sched's
> in this case. We can solve this, but this wait_event() complicates
> the problem.
> 
> Oleg.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
