Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A71556B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 13:47:29 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so4865365pdj.20
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 10:47:29 -0700 (PDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 24 Sep 2013 11:47:26 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id CE54719D804E
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 11:47:22 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8OHlMd2315272
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 11:47:23 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8OHoMPe008215
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 11:50:23 -0600
Date: Tue, 24 Sep 2013 10:47:18 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130924174717.GH9093@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130923175052.GA20991@redhat.com>
 <20130924123821.GT12926@twins.programming.kicks-ass.net>
 <20130924160359.GA2739@redhat.com>
 <20130924124341.64d57912@gandalf.local.home>
 <20130924170631.GB5059@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130924170631.GB5059@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Sep 24, 2013 at 07:06:31PM +0200, Oleg Nesterov wrote:
> On 09/24, Steven Rostedt wrote:
> >
> > On Tue, 24 Sep 2013 18:03:59 +0200
> > Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > > On 09/24, Peter Zijlstra wrote:
> > > >
> > > > +static inline void get_online_cpus(void)
> > > > +{
> > > > +	might_sleep();
> > > > +
> > > > +	if (current->cpuhp_ref++) {
> > > > +		barrier();
> > > > +		return;
> > >
> > > I don't undestand this barrier()... we are going to return if we already
> > > hold the lock, do we really need it?
> >
> > I'm confused too. Unless gcc moves this after the release, but the
> > release uses preempt_disable() which is its own barrier.
> >
> > If anything, it requires a comment.
> 
> And I am still confused even after emails from Paul and Peter...
> 
> If gcc can actually do something wrong, then I suspect this barrier()
> should be unconditional.

If you are saying that there should be a barrier() on all return paths
from get_online_cpus(), I agree.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
