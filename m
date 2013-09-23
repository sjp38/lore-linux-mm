Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 38D2F6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:30:15 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so2985978pbb.34
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 02:30:14 -0700 (PDT)
Date: Mon, 23 Sep 2013 11:29:55 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130923092955.GV9326@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130921163404.GA8545@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130921163404.GA8545@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Sat, Sep 21, 2013 at 06:34:04PM +0200, Oleg Nesterov wrote:
> > So the slow path is still per-cpu and mostly uncontended even in the
> > pending writer case.
> 
> Is it really important? I mean, per-cpu/uncontended even if the writer
> is pending?

I think so, once we make {get,put}_online_cpus() really cheap they'll
get in more and more places, and the global count with pending writer
will make things crawl on bigger machines.

> Otherwise we could do

<snip>

> I already sent this code in 2010, it needs some trivial updates.

Yeah, I found that a few days ago.. but per the above I didn't like the
pending writer case.

> But. We already have percpu_rw_semaphore,

Oh urgh, forgot about that one. /me goes read.

/me curses loudly.. that thing has an _expedited() call in it, those
should die.

Also, it suffers the same problem. I think esp. for hotplug we should be
100% geared towards readers and pretty much damn writers.

I'd dread to think what would happen if a 4k cpu machine were to land in
the slow path on that global mutex. Readers would never go-away and
progress would make a glacier seem fast.

> Note also that percpu_down_write/percpu_up_write can be improved wrt
> synchronize_sched(). We can turn the 2nd one into call_rcu(), and the
> 1nd one can be avoided if another percpu_down_write() comes "soon after"
> percpu_down_up().

Write side be damned ;-)

It is anyway with a pure read bias and a large machine..

> As for the patch itself, I am not sure.
> 
> > +static void cpuph_wait_refcount(void)
> 
> It seems, this can succeed while it should not, see below.
> 
> >  void cpu_hotplug_begin(void)
> >  {
> > +	lockdep_assert_held(&cpu_add_remove_lock);
> >
> > +	__cpuhp_writer = current;
> > +
> > +	/* After this everybody will observe _writer and take the slow path. */
> > +	synchronize_sched();
> 
> Yes, the reader should see _writer, but:
> 
> > +	/* Wait for no readers -- reader preference */
> > +	cpuhp_wait_refcount();
> 
> but how we can ensure the writer sees the results of the reader's updates?
> 
> Suppose that we have 2 CPU's, __cpuhp_refcount[0] = 0, __cpuhp_refcount[1] = 1.
> IOW, we have a single R reader which takes this lock on CPU_1 and sleeps.
> 
> Now,
> 
> 	- The writer calls cpuph_wait_refcount()
> 
> 	- cpuph_wait_refcount() does refcnt += __cpuhp_refcount[0].
> 	  refcnt == 0.
> 
> 	- another reader comes on CPU_0, increments __cpuhp_refcount[0].
> 
> 	- this reader migrates to CPU_1 and does put_online_cpus(),
> 	  this decrements __cpuhp_refcount[1] which becomes zero.
> 
> 	- cpuph_wait_refcount() continues and reads __cpuhp_refcount[1]
> 	  which is zero. refcnt == 0, return.
> 
> 	- The writer does cpuhp_set_state(1).
> 
> 	- The reader R (original reader) wakes up, calls get_online_cpus()
> 	  recursively, and sleeps in wait_event(!__cpuhp_writer).

Ah indeed.. 

The best I can come up with is something like:

static unsigned int cpuhp_refcount(void)
{
	unsigned int refcount = 0;
	int cpu;

	for_each_possible_cpu(cpu)
		refcount += per_cpu(__cpuhp_refcount, cpu);
}

static void cpuhp_wait_refcount(void)
{
	for (;;) {
		unsigned int rc1, rc2;

		rc1 = cpuhp_refcount();
		set_current_state(TASK_UNINTERRUPTIBLE); /* MB */
		rc2 = cpuhp_refcount();

		if (rc1 == rc2 && !rc1)
			break;

		schedule();
	}
	__set_current_state(TASK_RUNNING);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
