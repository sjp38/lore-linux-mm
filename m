Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6E26B026F
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:02:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so36580599pgc.1
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:02:57 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w17si65128498pgf.262.2016.11.30.09.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 09:02:56 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAUGwixO083534
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:02:55 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2721hk4cpd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:02:54 -0500
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 30 Nov 2016 10:02:53 -0700
Date: Wed, 30 Nov 2016 09:02:49 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161124101525.GB20668@dhcp22.suse.cz>
 <583AA50A.9010608@molgen.mpg.de>
 <20161128110449.GK14788@dhcp22.suse.cz>
 <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
 <29196f89-c35e-f79d-8e4d-2bf73fe930df@molgen.mpg.de>
 <20161130110944.GD18432@dhcp22.suse.cz>
 <20161130115320.GO3924@linux.vnet.ibm.com>
 <20161130131910.GF18432@dhcp22.suse.cz>
 <20161130142955.GS3924@linux.vnet.ibm.com>
 <20161130163820.GQ3092@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130163820.GQ3092@twins.programming.kicks-ass.net>
Message-Id: <20161130170249.GZ3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Wed, Nov 30, 2016 at 05:38:20PM +0100, Peter Zijlstra wrote:
> On Wed, Nov 30, 2016 at 06:29:55AM -0800, Paul E. McKenney wrote:
> > We can, and you are correct that cond_resched() does not unconditionally
> > supply RCU quiescent states, and never has.  Last time I tried to add
> > cond_resched_rcu_qs() semantics to cond_resched(), I got told "no",
> > but perhaps it is time to try again.
> 
> Well, you got told: "ARRGH my benchmark goes all regress", or something
> along those lines. Didn't we recently dig out those commits for some
> reason or other?

Were "those commits" the benchmark or putting cond_resched_rcu_qs()
functionality into cond_resched()?  Either way, no idea.

> Finding out what benchmark that was and running it against this patch
> would make sense.

Agreed, especially given that I believe cond_resched_rcu_qs() is lighter
weight than it used to be.  No idea what benchmarks they were, though.

> Also, I seem to have missed, why are we going through this again?

People are running workloads that force long-running loops in the kernel,
which get them RCU CPU stall warning messages.  My reaction has been
to insert cond_resched_rcu_qs() as needed, and Michal wondered why
cond_resched() couldn't just handle both scheduling latency and RCU
quiescent states.  I remembered trying it, but not what the issue was.

So I posted the patch assuming that I would eventually either find out
what the issue was or that the issue no longer applied.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
