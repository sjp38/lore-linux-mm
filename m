Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id B1CF16B0036
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 13:56:50 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so7403764pbb.20
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 10:56:50 -0700 (PDT)
Date: Tue, 1 Oct 2013 19:56:40 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131001175640.GQ15690@laptop.programming.kicks-ass.net>
References: <20130925175055.GA25914@redhat.com>
 <20130928144720.GL15690@laptop.programming.kicks-ass.net>
 <20130928163104.GA23352@redhat.com>
 <7632387.20FXkuCITr@vostro.rjw.lan>
 <524B0233.8070203@linux.vnet.ibm.com>
 <20131001173615.GW3657@laptop.programming.kicks-ass.net>
 <20131001174508.GA17411@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131001174508.GA17411@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Viresh Kumar <viresh.kumar@linaro.org>

On Tue, Oct 01, 2013 at 07:45:08PM +0200, Oleg Nesterov wrote:
> On 10/01, Peter Zijlstra wrote:
> >
> > On Tue, Oct 01, 2013 at 10:41:15PM +0530, Srivatsa S. Bhat wrote:
> > > However, as Oleg said, its definitely worth considering whether this proposed
> > > change in semantics is going to hurt us in the future. CPU_POST_DEAD has certainly
> > > proved to be very useful in certain challenging situations (commit 1aee40ac9c
> > > explains one such example), so IMHO we should be very careful not to undermine
> > > its utility.
> >
> > Urgh.. crazy things. I've always understood POST_DEAD to mean 'will be
> > called at some time after the unplug' with no further guarantees. And my
> > patch preserves that.
> 
> I tend to agree with Srivatsa... Without a strong reason it would be better
> to preserve the current logic: "some time after" should not be after the
> next CPU_DOWN/UP*. But I won't argue too much.

Nah, I think breaking it is the right thing :-)

> But note that you do not strictly need this change. Just kill cpuhp_waitcount,
> then we can change cpu_hotplug_begin/end to use xxx_enter/exit we discuss in
> another thread, this should likely "join" all synchronize_sched's.

That would still be 4k * sync_sched() == terribly long.

> Or split cpu_hotplug_begin() into 2 helpers which handle FAST -> SLOW and
> SLOW -> BLOCK transitions, then move the first "FAST -> SLOW" handler outside
> of for_each_online_cpu().

Right, that's more messy but would work if we cannot teach cpufreq (and
possibly others) to not rely on state you shouldn't rely on anyway.

I tihnk the only guarnatee POST_DEAD should have is that it should be
called before UP_PREPARE of the same cpu ;-) Nothing more, nothing less.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
