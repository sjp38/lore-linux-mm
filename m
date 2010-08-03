Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 646386008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 00:16:06 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o734KlRk009946
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 21:20:47 -0700
Received: from pwi2 (pwi2.prod.google.com [10.241.219.2])
	by hpaq3.eem.corp.google.com with ESMTP id o734K4sP019556
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 21:20:45 -0700
Received: by pwi2 with SMTP id 2so1543405pwi.4
        for <linux-mm@kvack.org>; Mon, 02 Aug 2010 21:20:45 -0700 (PDT)
Date: Mon, 2 Aug 2010 21:20:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100803121146.cf35b7ed.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008022117200.4146@chino.kir.corp.google.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com> <20100729183809.ca4ed8be.akpm@linux-foundation.org> <20100730195338.4AF6.A69D9226@jp.fujitsu.com> <20100802134312.c0f48615.akpm@linux-foundation.org> <20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com> <20100803093610.f4d30ca7.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021742440.9569@chino.kir.corp.google.com> <20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com>
 <20100803102423.82415a17.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021850400.19184@chino.kir.corp.google.com> <20100803110534.e3e7a697.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021953520.27231@chino.kir.corp.google.com>
 <20100803121146.cf35b7ed.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, KAMEZAWA Hiroyuki wrote:

> > Yes, but this is what oom_score_adj is intended to do: an oom_score_adj of 
> > 300 means task A should be penalized 30% of available memory.  A positive 
> > oom_score_adj typically means "all other competing tasks should be allowed 
> > 30% more memory, cumulatively, compared to this task."  Task A uses ~10% 
> > of available memory and task B uses 50% of available memory.  That's a 40% 
> > difference, which is greater than task A's penalization of 30%, so B is 
> > killed.
> >
> 
> This will confuse LXC(Linux Container) guys. oom_score is unusable anymore.
> 

>From Documentation/filesystems/proc.txt in 2.6.35:

	3.2 /proc/<pid>/oom_score - Display current oom-killer score
	-------------------------------------------------------------

	This file can be used to check the current score used by the 
	oom-killer is for any given <pid>. Use it together with 
	/proc/<pid>/oom_adj to tune which process should be killed in an 
	out-of-memory situation.

That is unchanged with the rewrite.  /proc/pid/oom_score still exports the 
badness() score used by the oom killer to determine which task to kill: 
the highest score will be killed amongst candidate tasks.  The fact that 
the score can be influenced by cpuset, memcg, or mempolicy constraint is 
irrelevant, we cannot assume anything about the badness() heuristic's 
implementation from the score itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
