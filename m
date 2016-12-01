Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6878C6B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 00:30:43 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id r94so58725568ioe.7
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 21:30:43 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id b63si50250863iof.217.2016.11.30.21.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 21:30:42 -0800 (PST)
Date: Thu, 1 Dec 2016 06:30:35 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Message-ID: <20161201053035.GC3092@twins.programming.kicks-ass.net>
References: <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
 <29196f89-c35e-f79d-8e4d-2bf73fe930df@molgen.mpg.de>
 <20161130110944.GD18432@dhcp22.suse.cz>
 <20161130115320.GO3924@linux.vnet.ibm.com>
 <20161130131910.GF18432@dhcp22.suse.cz>
 <20161130142955.GS3924@linux.vnet.ibm.com>
 <20161130163820.GQ3092@twins.programming.kicks-ass.net>
 <20161130170557.GK18432@dhcp22.suse.cz>
 <20161130175015.GR3092@twins.programming.kicks-ass.net>
 <20161130194019.GF3924@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130194019.GF3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Wed, Nov 30, 2016 at 11:40:19AM -0800, Paul E. McKenney wrote:

> > See commit:
> > 
> >   4a81e8328d37 ("rcu: Reduce overhead of cond_resched() checks for RCU")
> > 
> > Someone actually wrote down what the problem was.
> 
> Don't worry, it won't happen again.  ;-)
> 
> OK, so the regressions were in the "open1" test of Anton Blanchard's
> "will it scale" suite, and were due to faster (and thus more) grace
> periods rather than path length.
> 
> I could likely counter the grace-period speedup by regulating the rate
> at which the grace-period machinery pays attention to the rcu_qs_ctr
> per-CPU variable.  Actually, this looks pretty straightforward (famous
> last words).  But see patch below, which is untested and probably
> completely bogus.

Possible I suppose. Didn't look too hard at it.

> > > > Also, I seem to have missed, why are we going through this again?
> > > 
> > > Well, the point I've brought that up is because having basically two
> > > APIs for cond_resched is more than confusing. Basically all longer in
> > > kernel loops do cond_resched() but it seems that this will not help the
> > > silence RCU lockup detector in rare cases where nothing really wants to
> > > schedule. I am really not sure whether we want to sprinkle
> > > cond_resched_rcu_qs at random places just to silence RCU detector...
> > 
> > Right.. now, this is obviously all PREEMPT=n code, which therefore also
> > implies this is rcu-sched.
> > 
> > Paul, now doesn't rcu-sched, when the grace-period has been long in
> > coming, try and force it? And doesn't that forcing include prodding CPUs
> > with resched_cpu() ?
> 
> It does in the v4.8.4 kernel that Boris is running.  It still does in my
> -rcu tree, but only after an RCU CPU stall (something about people not
> liking IPIs).  I may need to do a resched_cpu() halfway to stall-warning
> time or some such.

Sure, we all dislike IPIs, but I'm thinking this half-way point is
sensible, no point in issuing user visible annoyance if indeed we can
prod things back to life, no?

Only if we utterly fail to make it respond should we bug the user with
our failure..

> > I'm thinking not, because if it did, that would make cond_resched()
> > actually schedule, which would then call into rcu_note_context_switch()
> > which would then make RCU progress, no?
> 
> Sounds plausible, but from what I can see some of the loops pointed
> out by Boris's stall-warning messages don't have cond_resched().
> There was another workload that apparently worked better when moved from
> cond_resched() to cond_resched_rcu_qs(), but I don't know what kernel
> version was running.

Egads.. cursed if you do, cursed if you dont eh..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
