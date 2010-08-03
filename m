Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 77FD4600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 23:01:14 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o7335Q74002398
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 20:05:26 -0700
Received: from pwj2 (pwj2.prod.google.com [10.241.219.66])
	by hpaq6.eem.corp.google.com with ESMTP id o7335521000646
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 20:05:24 -0700
Received: by pwj2 with SMTP id 2so1774565pwj.21
        for <linux-mm@kvack.org>; Mon, 02 Aug 2010 20:05:24 -0700 (PDT)
Date: Mon, 2 Aug 2010 20:05:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100803110534.e3e7a697.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008021953520.27231@chino.kir.corp.google.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com> <20100729183809.ca4ed8be.akpm@linux-foundation.org> <20100730195338.4AF6.A69D9226@jp.fujitsu.com> <20100802134312.c0f48615.akpm@linux-foundation.org> <20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com> <20100803093610.f4d30ca7.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021742440.9569@chino.kir.corp.google.com> <20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com>
 <20100803102423.82415a17.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021850400.19184@chino.kir.corp.google.com> <20100803110534.e3e7a697.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, KAMEZAWA Hiroyuki wrote:

> > Sure, a task could be killed with a very low /proc/pid/oom_score, but only 
> > if its cpuset is oom, for example, and it has the highest score of all 
> > tasks attached to that oom_score.  So /proc/pid/oom_score needs to be 
> > considered in the context in which the oom occurs: system-wide, cpuset, 
> > mempolicy, or memcg.  That's unchanged from the old oom killer.
> > 
> 
> unchanged ?
> 

Oh, I meant the fact that a task with a low oom_score compared to other 
system tasks may be killed because a cpuset is oom, for instance, is 
unchanged because we only kill tasks that are constrained to that cpuset.

> Assume 2 proceses A, B which has oom_score_adj of 300 and 0
> And A uses 200M, B uses 1G of memory under 4G system
> 
> Under the system. 
> 	A's socre = (200M *1000)/4G + 300 = 350
> 	B's score = (1G * 1000)/4G = 250.

Right, A is penalized 30% of system memory and its use is ~5%, resulting 
in a score of 350, or 35%.  B's use is 25%.

> In the cpuset, it has 2G of memory.
> 	A's score = (200M * 1000)/2G + 300 = 400
> 	B's socre = (1G * 1000)/2G = 500
> 
> This priority-inversion don't happen in current system.
> 

Yes, but this is what oom_score_adj is intended to do: an oom_score_adj of 
300 means task A should be penalized 30% of available memory.  A positive 
oom_score_adj typically means "all other competing tasks should be allowed 
30% more memory, cumulatively, compared to this task."  Task A uses ~10% 
of available memory and task B uses 50% of available memory.  That's a 40% 
difference, which is greater than task A's penalization of 30%, so B is 
killed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
