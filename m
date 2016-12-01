Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 906C06B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 11:59:23 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xy5so40108806wjc.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:59:23 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l10si949715wjr.92.2016.12.01.08.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 08:59:22 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB1GsZ8L068800
	for <linux-mm@kvack.org>; Thu, 1 Dec 2016 11:59:21 -0500
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 272kqurrhx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Dec 2016 11:59:20 -0500
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 1 Dec 2016 09:59:20 -0700
Date: Thu, 1 Dec 2016 08:59:18 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161130115320.GO3924@linux.vnet.ibm.com>
 <20161130131910.GF18432@dhcp22.suse.cz>
 <20161130142955.GS3924@linux.vnet.ibm.com>
 <20161130163820.GQ3092@twins.programming.kicks-ass.net>
 <20161130170557.GK18432@dhcp22.suse.cz>
 <20161130175015.GR3092@twins.programming.kicks-ass.net>
 <20161130194019.GF3924@linux.vnet.ibm.com>
 <20161201053035.GC3092@twins.programming.kicks-ass.net>
 <20161201124024.GB3924@linux.vnet.ibm.com>
 <20161201163614.GL3092@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201163614.GL3092@twins.programming.kicks-ass.net>
Message-Id: <20161201165918.GG3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Thu, Dec 01, 2016 at 05:36:14PM +0100, Peter Zijlstra wrote:
> On Thu, Dec 01, 2016 at 04:40:24AM -0800, Paul E. McKenney wrote:
> > On Thu, Dec 01, 2016 at 06:30:35AM +0100, Peter Zijlstra wrote:
> 
> > > Sure, we all dislike IPIs, but I'm thinking this half-way point is
> > > sensible, no point in issuing user visible annoyance if indeed we can
> > > prod things back to life, no?
> > > 
> > > Only if we utterly fail to make it respond should we bug the user with
> > > our failure..
> > 
> > Sold!  ;-)
> > 
> > I will put together a patch later today.
> > 
> > My intent is to hold off on the "upgrade cond_resched()" patch, one
> > step at a time.  Longer term, I do very much like the idea of having
> > cond_resched() do both scheduling and RCU quiescent states, assuming
> > that this avoids performance pitfalls.
> 
> Well, with the above change cond_resched() is already sufficient, no?

Maybe.  Right now, cond_resched_rcu_qs() gets a quiescent state to
the RCU core in less than one jiffy, with my other change, this becomes
a handful of jiffies depending on HZ and NR_CPUS.  I expect this
increase to a handful of jiffies to be a non-event.

After my upcoming patch, cond_resched() will get a quiescent state to
the RCU core in about ten seconds.  While I am am not all that nervous
about the increase from less than a jiffy to a handful of jiffies,
increasing to ten seconds via cond_resched() does make me quite nervous.
Past experience indicates that someone's kernel will likely be fatally
inconvenienced by this magnitude of change.

Or am I misunderstanding what you are proposing?

> In fact, by doing the IPI thing we get the entire cond_resched*()
> family, and we could add the should_resched() guard to
> cond_resched_rcu().

So that cond_resched_rcu_qs() looks something like this, in order
to avoid the function call in the case where the scheduler has nothing
to do?

#define cond_resched_rcu_qs() \
do { \
	if (!should_resched(current) || !cond_resched()) \
		rcu_note_voluntary_context_switch(current); \
} while (0)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
