Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C138A6B0253
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 07:40:30 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xr1so38595583wjb.7
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 04:40:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id wj9si87784wjb.8.2016.12.01.04.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 04:40:29 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB1CcWQG066709
	for <linux-mm@kvack.org>; Thu, 1 Dec 2016 07:40:28 -0500
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 272jsuvff6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:40:27 -0500
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 1 Dec 2016 05:40:26 -0700
Date: Thu, 1 Dec 2016 04:40:24 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <29196f89-c35e-f79d-8e4d-2bf73fe930df@molgen.mpg.de>
 <20161130110944.GD18432@dhcp22.suse.cz>
 <20161130115320.GO3924@linux.vnet.ibm.com>
 <20161130131910.GF18432@dhcp22.suse.cz>
 <20161130142955.GS3924@linux.vnet.ibm.com>
 <20161130163820.GQ3092@twins.programming.kicks-ass.net>
 <20161130170557.GK18432@dhcp22.suse.cz>
 <20161130175015.GR3092@twins.programming.kicks-ass.net>
 <20161130194019.GF3924@linux.vnet.ibm.com>
 <20161201053035.GC3092@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201053035.GC3092@twins.programming.kicks-ass.net>
Message-Id: <20161201124024.GB3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Thu, Dec 01, 2016 at 06:30:35AM +0100, Peter Zijlstra wrote:
> On Wed, Nov 30, 2016 at 11:40:19AM -0800, Paul E. McKenney wrote:
> 
> > > See commit:
> > > 
> > >   4a81e8328d37 ("rcu: Reduce overhead of cond_resched() checks for RCU")
> > > 
> > > Someone actually wrote down what the problem was.
> > 
> > Don't worry, it won't happen again.  ;-)
> > 
> > OK, so the regressions were in the "open1" test of Anton Blanchard's
> > "will it scale" suite, and were due to faster (and thus more) grace
> > periods rather than path length.
> > 
> > I could likely counter the grace-period speedup by regulating the rate
> > at which the grace-period machinery pays attention to the rcu_qs_ctr
> > per-CPU variable.  Actually, this looks pretty straightforward (famous
> > last words).  But see patch below, which is untested and probably
> > completely bogus.
> 
> Possible I suppose. Didn't look too hard at it.
> 
> > > > > Also, I seem to have missed, why are we going through this again?
> > > > 
> > > > Well, the point I've brought that up is because having basically two
> > > > APIs for cond_resched is more than confusing. Basically all longer in
> > > > kernel loops do cond_resched() but it seems that this will not help the
> > > > silence RCU lockup detector in rare cases where nothing really wants to
> > > > schedule. I am really not sure whether we want to sprinkle
> > > > cond_resched_rcu_qs at random places just to silence RCU detector...
> > > 
> > > Right.. now, this is obviously all PREEMPT=n code, which therefore also
> > > implies this is rcu-sched.
> > > 
> > > Paul, now doesn't rcu-sched, when the grace-period has been long in
> > > coming, try and force it? And doesn't that forcing include prodding CPUs
> > > with resched_cpu() ?
> > 
> > It does in the v4.8.4 kernel that Boris is running.  It still does in my
> > -rcu tree, but only after an RCU CPU stall (something about people not
> > liking IPIs).  I may need to do a resched_cpu() halfway to stall-warning
> > time or some such.
> 
> Sure, we all dislike IPIs, but I'm thinking this half-way point is
> sensible, no point in issuing user visible annoyance if indeed we can
> prod things back to life, no?
> 
> Only if we utterly fail to make it respond should we bug the user with
> our failure..

Sold!  ;-)

I will put together a patch later today.

My intent is to hold off on the "upgrade cond_resched()" patch, one
step at a time.  Longer term, I do very much like the idea of having
cond_resched() do both scheduling and RCU quiescent states, assuming
that this avoids performance pitfalls.

> > > I'm thinking not, because if it did, that would make cond_resched()
> > > actually schedule, which would then call into rcu_note_context_switch()
> > > which would then make RCU progress, no?
> > 
> > Sounds plausible, but from what I can see some of the loops pointed
> > out by Boris's stall-warning messages don't have cond_resched().
> > There was another workload that apparently worked better when moved from
> > cond_resched() to cond_resched_rcu_qs(), but I don't know what kernel
> > version was running.
> 
> Egads.. cursed if you do, cursed if you dont eh..

Almost like this was real life!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
