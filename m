Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA686B0036
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 15:05:23 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so7873488pad.19
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 12:05:23 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 1 Oct 2013 15:05:20 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 54D2238C8047
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 15:05:17 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r91J5H3H66519048
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 19:05:17 GMT
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r91J8Lsf020594
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 13:08:22 -0600
Date: Tue, 1 Oct 2013 12:05:15 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131001190515.GI5790@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130925175055.GA25914@redhat.com>
 <20130928144720.GL15690@laptop.programming.kicks-ass.net>
 <20130928163104.GA23352@redhat.com>
 <7632387.20FXkuCITr@vostro.rjw.lan>
 <524B0233.8070203@linux.vnet.ibm.com>
 <20131001173615.GW3657@laptop.programming.kicks-ass.net>
 <20131001174508.GA17411@redhat.com>
 <20131001175640.GQ15690@laptop.programming.kicks-ass.net>
 <20131001180750.GA18261@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131001180750.GA18261@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Viresh Kumar <viresh.kumar@linaro.org>, tony.luck@intel.com, bp@alien8.de

On Tue, Oct 01, 2013 at 08:07:50PM +0200, Oleg Nesterov wrote:
> On 10/01, Peter Zijlstra wrote:
> >
> > On Tue, Oct 01, 2013 at 07:45:08PM +0200, Oleg Nesterov wrote:
> > >
> > > I tend to agree with Srivatsa... Without a strong reason it would be better
> > > to preserve the current logic: "some time after" should not be after the
> > > next CPU_DOWN/UP*. But I won't argue too much.
> >
> > Nah, I think breaking it is the right thing :-)
> 
> I don't really agree but I won't argue ;)

The authors of arch/x86/kernel/cpu/mcheck/mce.c would seem to be the
guys who would need to complain, given that they seem to have the only
use in 3.11.

							Thanx, Paul

> > > But note that you do not strictly need this change. Just kill cpuhp_waitcount,
> > > then we can change cpu_hotplug_begin/end to use xxx_enter/exit we discuss in
> > > another thread, this should likely "join" all synchronize_sched's.
> >
> > That would still be 4k * sync_sched() == terribly long.
> 
> No? the next xxx_enter() avoids sync_sched() if rcu callback is still
> pending. Unless __cpufreq_remove_dev_finish() is "too slow" of course.
> 
> > > Or split cpu_hotplug_begin() into 2 helpers which handle FAST -> SLOW and
> > > SLOW -> BLOCK transitions, then move the first "FAST -> SLOW" handler outside
> > > of for_each_online_cpu().
> >
> > Right, that's more messy but would work if we cannot teach cpufreq (and
> > possibly others) to not rely on state you shouldn't rely on anyway.
> 
> Yes,
> 
> > I tihnk the only guarnatee POST_DEAD should have is that it should be
> > called before UP_PREPARE of the same cpu ;-) Nothing more, nothing less.
> 
> See above... This makes POST_DEAD really "special" compared to other
> CPU_* events.
> 
> And again. Something like a global lock taken by CPU_DOWN_PREPARE and
> released by POST_DEAD or DOWN_FAILED does not look "too wrong" to me.
> 
> But I leave this to you and Srivatsa.
> 
> Oleg.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
