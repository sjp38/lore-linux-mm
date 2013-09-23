Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f41.google.com (mail-oa0-f41.google.com [209.85.219.41])
	by kanga.kvack.org (Postfix) with ESMTP id CE5516B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 13:53:53 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id n10so891533oag.0
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 10:53:53 -0700 (PDT)
Date: Mon, 23 Sep 2013 19:32:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130923173203.GA20392@redhat.com>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de> <1378805550-29949-38-git-send-email-mgorman@suse.de> <20130917143003.GA29354@twins.programming.kicks-ass.net> <20130917162050.GK22421@suse.de> <20130917164505.GG12926@twins.programming.kicks-ass.net> <20130918154939.GZ26785@twins.programming.kicks-ass.net> <20130919143241.GB26785@twins.programming.kicks-ass.net> <20130921163404.GA8545@redhat.com> <20130923092955.GV9326@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130923092955.GV9326@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On 09/23, Peter Zijlstra wrote:
>
> On Sat, Sep 21, 2013 at 06:34:04PM +0200, Oleg Nesterov wrote:
> > > So the slow path is still per-cpu and mostly uncontended even in the
> > > pending writer case.
> >
> > Is it really important? I mean, per-cpu/uncontended even if the writer
> > is pending?
>
> I think so, once we make {get,put}_online_cpus() really cheap they'll
> get in more and more places, and the global count with pending writer
> will make things crawl on bigger machines.

Hmm. But the writers should be rare.

> > But. We already have percpu_rw_semaphore,
>
> Oh urgh, forgot about that one. /me goes read.
>
> /me curses loudly.. that thing has an _expedited() call in it, those
> should die.

Probably yes, the original reason for _expedited() has gone away.

> I'd dread to think what would happen if a 4k cpu machine were to land in
> the slow path on that global mutex. Readers would never go-away and
> progress would make a glacier seem fast.

Another problem is that write-lock can never succeed unless it
prevents the new readers, but this needs the per-task counter.

> > Note also that percpu_down_write/percpu_up_write can be improved wrt
> > synchronize_sched(). We can turn the 2nd one into call_rcu(), and the
> > 1nd one can be avoided if another percpu_down_write() comes "soon after"
> > percpu_down_up().
>
> Write side be damned ;-)

Suppose that a 4k cpu machine does disable_nonboot_cpus(), every
_cpu_down() does synchronize_sched()... OK, perhaps the locking can be
changed so that cpu_hotplug_begin/end is called only once in this case.

> > 	- The writer calls cpuph_wait_refcount()
> >
> > 	- cpuph_wait_refcount() does refcnt += __cpuhp_refcount[0].
> > 	  refcnt == 0.
> >
> > 	- another reader comes on CPU_0, increments __cpuhp_refcount[0].
> >
> > 	- this reader migrates to CPU_1 and does put_online_cpus(),
> > 	  this decrements __cpuhp_refcount[1] which becomes zero.
> >
> > 	- cpuph_wait_refcount() continues and reads __cpuhp_refcount[1]
> > 	  which is zero. refcnt == 0, return.
>
> Ah indeed..
>
> The best I can come up with is something like:
>
> static unsigned int cpuhp_refcount(void)
> {
> 	unsigned int refcount = 0;
> 	int cpu;
>
> 	for_each_possible_cpu(cpu)
> 		refcount += per_cpu(__cpuhp_refcount, cpu);
> }
>
> static void cpuhp_wait_refcount(void)
> {
> 	for (;;) {
> 		unsigned int rc1, rc2;
>
> 		rc1 = cpuhp_refcount();
> 		set_current_state(TASK_UNINTERRUPTIBLE); /* MB */
> 		rc2 = cpuhp_refcount();
>
> 		if (rc1 == rc2 && !rc1)

But this only makes the race above "theoretical ** 2". Both
cpuhp_refcount()'s can be equally fooled.

Looks like, cpuhp_refcount() should take all per-cpu cpuhp_lock's
before it reads __cpuhp_refcount.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
