Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF8D6B0032
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 10:21:34 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so7351148pde.10
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 07:21:34 -0700 (PDT)
Date: Tue, 1 Oct 2013 16:14:29 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131001141429.GA32423@redhat.com>
References: <20130925174307.GA3220@laptop.programming.kicks-ass.net> <20130925175055.GA25914@redhat.com> <20130925184015.GC3657@laptop.programming.kicks-ass.net> <20130925212200.GA7959@linux.vnet.ibm.com> <20130926111042.GS3081@twins.programming.kicks-ass.net> <20130926165840.GA863@redhat.com> <20130926175016.GI3657@laptop.programming.kicks-ass.net> <20130927181532.GA8401@redhat.com> <20130927204116.GJ15690@laptop.programming.kicks-ass.net> <20131001035604.GW19582@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131001035604.GW19582@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On 09/30, Paul E. McKenney wrote:
>
> On Fri, Sep 27, 2013 at 10:41:16PM +0200, Peter Zijlstra wrote:
> > On Fri, Sep 27, 2013 at 08:15:32PM +0200, Oleg Nesterov wrote:
> > > On 09/26, Peter Zijlstra wrote:
>
> [ . . . ]
>
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
> > > from srcu_readers_active_idx_check() can explain mb(), note that
> > > __srcu_read_lock() always succeeds unlike get_cpus_online().
> >
> > I see what you mean; cpuhp_readers_active_check() is all purely reads;
> > there are no writes to order.
> >
> > Paul; is there any argument for the MB here as opposed to RMB; and if
> > not should we change both these and SRCU?
>
> Given that these memory barriers execute only on the semi-slow path,
> why add the complexity of moving from smp_mb() to either smp_rmb()
> or smp_wmb()?  Straight smp_mb() is easier to reason about and more
> robust against future changes.

But otoh this looks misleading, and the comments add more confusion.

But please note another email, it seems to me we can simply kill
cpuhp_seq and all the barriers in cpuhp_readers_active_check().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
