Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BCCB26B0033
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 11:18:54 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so3320825pde.23
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:18:54 -0700 (PDT)
Date: Mon, 23 Sep 2013 11:13:03 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130923111303.04b99db8@gandalf.local.home>
In-Reply-To: <20130923145446.GX9326@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
	<1378805550-29949-38-git-send-email-mgorman@suse.de>
	<20130917143003.GA29354@twins.programming.kicks-ass.net>
	<20130917162050.GK22421@suse.de>
	<20130917164505.GG12926@twins.programming.kicks-ass.net>
	<20130918154939.GZ26785@twins.programming.kicks-ass.net>
	<20130919143241.GB26785@twins.programming.kicks-ass.net>
	<20130923105017.030e0aef@gandalf.local.home>
	<20130923145446.GX9326@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, 23 Sep 2013 16:54:46 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Mon, Sep 23, 2013 at 10:50:17AM -0400, Steven Rostedt wrote:
> > On Thu, 19 Sep 2013 16:32:41 +0200
> > Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > 
> > > +extern void __get_online_cpus(void);
> > > +
> > > +static inline void get_online_cpus(void)
> > > +{
> > > +	might_sleep();
> > > +
> > > +	preempt_disable();
> > > +	if (likely(!__cpuhp_writer || __cpuhp_writer == current))
> > > +		this_cpu_inc(__cpuhp_refcount);
> > > +	else
> > > +		__get_online_cpus();
> > > +	preempt_enable();
> > > +}
> > 
> > 
> > This isn't much different than srcu_read_lock(). What about doing
> > something like this:
> > 
> > static inline void get_online_cpus(void)
> > {
> > 	might_sleep();
> > 
> > 	srcu_read_lock(&cpuhp_srcu);
> > 	if (unlikely(__cpuhp_writer || __cpuhp_writer != current)) {
> > 		srcu_read_unlock(&cpuhp_srcu);
> > 		__get_online_cpus();
> > 		current->online_cpus_held++;
> > 	}
> > }
> 
> There's a full memory barrier in srcu_read_lock(), while there was no
> such thing in the previous fast path.

Yeah, I mentioned this to Paul, and we talked about making
srcu_read_lock() work with no mb's. But currently, doesn't
get_online_cpus() just take a mutex? What's wrong with a mb() as it
still kicks ass over what is currently there today?

> 
> Also, why current->online_cpus_held()? That would make the write side
> O(nr_tasks) instead of O(nr_cpus).

?? I'm not sure I understand this. The online_cpus_held++ was there for
recursion. Can't get_online_cpus() nest? I was thinking it can. If so,
once the "__cpuhp_writer" is set, we need to do __put_online_cpus() as
many times as we did a __get_online_cpus(). I don't know where the
O(nr_tasks) comes from. The ref here was just to account for doing the
old "get_online_cpus" instead of a srcu_read_lock().

> 
> > static inline void put_online_cpus(void)
> > {
> > 	if (unlikely(current->online_cpus_held)) {
> > 		current->online_cpus_held--;
> > 		__put_online_cpus();
> > 		return;
> > 	}
> > 
> > 	srcu_read_unlock(&cpuhp_srcu);
> > }
> 
> Also, you might not have noticed but, srcu_read_{,un}lock() have an
> extra idx thing to pass about. That doesn't fit with the hotplug api.

I'll have to look a that, as I'm not exactly sure about the idx thing.

> 
> > 
> > Then have the writer simply do:
> > 
> > 	__cpuhp_write = current;
> > 	synchronize_srcu(&cpuhp_srcu);
> > 
> > 	<grab the mutex here>
> 
> How does that do reader preference?

Well, the point I was trying to do was to let readers go very fast
(well, with a mb instead of a mutex), and then when the CPU hotplug
happens, it goes back to the current method.

That is, once we set __cpuhp_write, and then run synchronize_srcu(),
the system will be in a state that does what it does today (grabbing
mutexes, and upping refcounts).

I thought the whole point was to speed up the get_online_cpus() when no
hotplug is happening. This does that, and is rather simple. It only
gets slow when hotplug is in effect.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
