Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 3A47B6B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 12:45:22 -0400 (EDT)
Date: Tue, 17 Sep 2013 18:45:05 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130917164505.GG12926@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130917162050.GK22421@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Tue, Sep 17, 2013 at 05:20:50PM +0100, Mel Gorman wrote:
> > +extern struct task_struct *__cpuhp_writer;
> > +DECLARE_PER_CPU(unsigned int, __cpuhp_refcount);
> > +
> > +extern void __get_online_cpus(void);
> > +
> > +static inline void get_online_cpus(void)
> > +{
> > +	might_sleep();
> > +
> > +	this_cpu_inc(__cpuhp_refcount);
> > +	/*
> > +	 * Order the refcount inc against the writer read; pairs with the full
> > +	 * barrier in cpu_hotplug_begin().
> > +	 */
> > +	smp_mb();
> > +	if (unlikely(__cpuhp_writer))
> > +		__get_online_cpus();
> > +}
> > +
> 
> If the problem with get_online_cpus() is the shared global state then a
> full barrier in the fast path is still going to hurt. Granted, it will hurt
> a lot less and there should be no lock contention.

I went for a lot less, I wasn't smart enough to get rid of it. Also,
since its a lock op we should at least provide an ACQUIRE barrier.

> However, what barrier in cpu_hotplug_begin is the comment referring to? 

set_current_state() implies a full barrier and nicely separates the
write to __cpuhp_writer and the read of __cpuph_refcount.

> The
> other barrier is in the slowpath __get_online_cpus. Did you mean to do
> a rmb here and a wmb after __cpuhp_writer is set in cpu_hotplug_begin?

No, since we're ordering LOADs and STORES (see below) we must use full
barriers.

> I'm assuming you are currently using a full barrier to guarantee that an
> update if cpuhp_writer will be visible so get_online_cpus blocks but I'm
> not 100% sure because of the comments.

I'm ordering:

  CPU0 -- get_online_cpus()	CPU1 -- cpu_hotplug_begin()

  STORE __cpuhp_refcount        STORE __cpuhp_writer

  MB				MB

  LOAD __cpuhp_writer		LOAD __cpuhp_refcount

Such that neither can miss the state of the other and we get proper
mutual exclusion.

> > +extern void __put_online_cpus(void);
> > +
> > +static inline void put_online_cpus(void)
> > +{
> > +	barrier();
> 
> Why is this barrier necessary? 

To ensure the compiler keeps all loads/stores done before the
read-unlock before it.

Arguably it should be a complete RELEASE barrier. I should've put an XXX
comment here but the brain gave out completely for the day.

> I could not find anything that stated if an
> inline function is an implicit compiler barrier but whether it is or not,
> it's not clear why it's necessary at all.

It is not, only actual function calls are an implied sync point for the
compiler.

> > +	this_cpu_dec(__cpuhp_refcount);
> > +	if (unlikely(__cpuhp_writer))
> > +		__put_online_cpus();
> > +}
> > +

> > +struct task_struct *__cpuhp_writer = NULL;
> > +EXPORT_SYMBOL_GPL(__cpuhp_writer);
> > +
> > +DEFINE_PER_CPU(unsigned int, __cpuhp_refcount);
> > +EXPORT_PER_CPU_SYMBOL_GPL(__cpuhp_refcount);
> >  
> > +static DECLARE_WAIT_QUEUE_HEAD(cpuhp_wq);
> > +
> > +void __get_online_cpus(void)
> >  {
> > +	if (__cpuhp_writer == current)
> >  		return;
> >  
> > +again:
> > +	/*
> > +	 * Ensure a pending reading has a 0 refcount.
> > +	 *
> > +	 * Without this a new reader that comes in before cpu_hotplug_begin()
> > +	 * reads the refcount will deadlock.
> > +	 */
> > +	this_cpu_dec(__cpuhp_refcount);
> > +	wait_event(cpuhp_wq, !__cpuhp_writer);
> > +
> > +	this_cpu_inc(__cpuhp_refcount);
> > +	/*
> > +	 * See get_online_cpu().
> > +	 */
> > +	smp_mb();
> > +	if (unlikely(__cpuhp_writer))
> > +		goto again;
> >  }
> 
> If CPU hotplug operations are very frequent (or a stupid stress test) then
> it's possible for a new hotplug operation to start (updating __cpuhp_writer)
> before a caller to __get_online_cpus can update the refcount. Potentially
> a caller to __get_online_cpus gets starved although as it only affects a
> CPU hotplug stress test it may not be a serious issue.

Right.. If that ever becomes a problem we should fix it, but aside from
stress tests hotplug should be extremely rare.

Initially I kept the reference over the wait_event() but realized (as
per the comment) that that would deadlock cpu_hotplug_begin() for it
would never observe !refcount.

One solution for this problem is having refcount as an array of 2 and
flipping the index at the appropriate times.

> > +EXPORT_SYMBOL_GPL(__get_online_cpus);
> >  
> > +void __put_online_cpus(void)
> >  {
> > +	unsigned int refcnt = 0;
> > +	int cpu;
> >  
> > +	if (__cpuhp_writer == current)
> > +		return;
> >  
> > +	for_each_possible_cpu(cpu)
> > +		refcnt += per_cpu(__cpuhp_refcount, cpu);
> >  
> 
> This can result in spurious wakeups if CPU N calls get_online_cpus after
> its refcnt has been checked but I could not think of a case where it
> matters.

Right and right.. too many wakeups aren't a correctness issue. One
should try and minimize them for performance reasons though :-)

> > +	if (!refcnt)
> > +		wake_up_process(__cpuhp_writer);
> >  }


> >  /*
> >   * This ensures that the hotplug operation can begin only when the
> >   * refcount goes to zero.
> >   *
> >   * Since cpu_hotplug_begin() is always called after invoking
> >   * cpu_maps_update_begin(), we can be sure that only one writer is active.
> >   */
> >  void cpu_hotplug_begin(void)
> >  {
> > +	__cpuhp_writer = current;
> >  
> >  	for (;;) {
> > +		unsigned int refcnt = 0;
> > +		int cpu;
> > +
> > +		/*
> > +		 * Order the setting of writer against the reading of refcount;
> > +		 * pairs with the full barrier in get_online_cpus().
> > +		 */
> > +
> > +		set_current_state(TASK_UNINTERRUPTIBLE);
> > +
> > +		for_each_possible_cpu(cpu)
> > +			refcnt += per_cpu(__cpuhp_refcount, cpu);
> > +
> 
> CPU 0					CPU 1
> get_online_cpus
> refcnt++
> 					__cpuhp_writer = current
> 					refcnt > 0
> 					schedule
> __get_online_cpus slowpath
> refcnt--
> wait_event(!__cpuhp_writer)
> 
> What wakes up __cpuhp_writer to recheck the refcnts and see that they're
> all 0?

The wakeup in __put_online_cpus() you just commented on?
put_online_cpus() will drop into the slow path __put_online_cpus() if
there's a writer and compute the refcount and perform the wakeup when
!refcount.

> > +		if (!refcnt)
> >  			break;
> > +
> >  		schedule();
> >  	}
> > +	__set_current_state(TASK_RUNNING);
> >  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
