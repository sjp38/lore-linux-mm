Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6276B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 00:02:23 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so6439532pbc.8
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 21:02:23 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 30 Sep 2013 23:56:09 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id BDE3838C8042
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 23:56:06 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r913u6kr1442064
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 03:56:06 GMT
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r913xBNx014290
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 21:59:11 -0600
Date: Mon, 30 Sep 2013 20:56:04 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131001035604.GW19582@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130925155515.GA17447@redhat.com>
 <20130925174307.GA3220@laptop.programming.kicks-ass.net>
 <20130925175055.GA25914@redhat.com>
 <20130925184015.GC3657@laptop.programming.kicks-ass.net>
 <20130925212200.GA7959@linux.vnet.ibm.com>
 <20130926111042.GS3081@twins.programming.kicks-ass.net>
 <20130926165840.GA863@redhat.com>
 <20130926175016.GI3657@laptop.programming.kicks-ass.net>
 <20130927181532.GA8401@redhat.com>
 <20130927204116.GJ15690@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130927204116.GJ15690@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Fri, Sep 27, 2013 at 10:41:16PM +0200, Peter Zijlstra wrote:
> On Fri, Sep 27, 2013 at 08:15:32PM +0200, Oleg Nesterov wrote:
> > On 09/26, Peter Zijlstra wrote:

[ . . . ]

> > > +static bool cpuhp_readers_active_check(void)
> > >  {
> > > +	unsigned int seq = per_cpu_sum(cpuhp_seq);
> > > +
> > > +	smp_mb(); /* B matches A */
> > > +
> > > +	/*
> > > +	 * In other words, if we see __get_online_cpus() cpuhp_seq increment,
> > > +	 * we are guaranteed to also see its __cpuhp_refcount increment.
> > > +	 */
> > >  
> > > +	if (per_cpu_sum(__cpuhp_refcount) != 0)
> > > +		return false;
> > >  
> > > +	smp_mb(); /* D matches C */
> > 
> > It seems that both barries could be smp_rmb() ? I am not sure the comments
> > from srcu_readers_active_idx_check() can explain mb(), note that
> > __srcu_read_lock() always succeeds unlike get_cpus_online().
> 
> I see what you mean; cpuhp_readers_active_check() is all purely reads;
> there are no writes to order.
> 
> Paul; is there any argument for the MB here as opposed to RMB; and if
> not should we change both these and SRCU?

Given that these memory barriers execute only on the semi-slow path,
why add the complexity of moving from smp_mb() to either smp_rmb()
or smp_wmb()?  Straight smp_mb() is easier to reason about and more
robust against future changes.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
