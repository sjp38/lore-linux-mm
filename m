Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 90E886008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 00:32:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o734bkAJ010546
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 13:37:46 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A25445DE50
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:37:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6142045DE52
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:37:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D3521DB803B
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:37:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D3ED71DB8044
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:37:45 +0900 (JST)
Date: Tue, 3 Aug 2010 13:32:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
Message-Id: <20100803133255.deb5c208.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008022117200.4146@chino.kir.corp.google.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com>
	<20100729183809.ca4ed8be.akpm@linux-foundation.org>
	<20100730195338.4AF6.A69D9226@jp.fujitsu.com>
	<20100802134312.c0f48615.akpm@linux-foundation.org>
	<20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com>
	<20100803093610.f4d30ca7.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021742440.9569@chino.kir.corp.google.com>
	<20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com>
	<20100803102423.82415a17.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021850400.19184@chino.kir.corp.google.com>
	<20100803110534.e3e7a697.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021953520.27231@chino.kir.corp.google.com>
	<20100803121146.cf35b7ed.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008022117200.4146@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Aug 2010 21:20:40 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 3 Aug 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > Yes, but this is what oom_score_adj is intended to do: an oom_score_adj of 
> > > 300 means task A should be penalized 30% of available memory.  A positive 
> > > oom_score_adj typically means "all other competing tasks should be allowed 
> > > 30% more memory, cumulatively, compared to this task."  Task A uses ~10% 
> > > of available memory and task B uses 50% of available memory.  That's a 40% 
> > > difference, which is greater than task A's penalization of 30%, so B is 
> > > killed.
> > >
> > 
> > This will confuse LXC(Linux Container) guys. oom_score is unusable anymore.
> > 
> 
> From Documentation/filesystems/proc.txt in 2.6.35:
> 
> 	3.2 /proc/<pid>/oom_score - Display current oom-killer score
> 	-------------------------------------------------------------
> 
> 	This file can be used to check the current score used by the 
> 	oom-killer is for any given <pid>. Use it together with 
> 	/proc/<pid>/oom_adj to tune which process should be killed in an 
> 	out-of-memory situation.
> 
> That is unchanged with the rewrite.  /proc/pid/oom_score still exports the 
> badness() score used by the oom killer to determine which task to kill: 
> the highest score will be killed amongst candidate tasks.  The fact that 
> the score can be influenced by cpuset, memcg, or mempolicy constraint is 
> irrelevant, we cannot assume anything about the badness() heuristic's 
> implementation from the score itself.
> 

In old behavior, oom_score order is synchronous both in the system and
container. High-score one will be killed.
IOW, oom_score have worked as oom_score.

But, after the patch,  the user (of LXC at el.) can't trust oom_score. 
Especially with memcg, it just shows a _broken_ value.

And user has to caluculate oom_score by himself as

real_oom_score = (oom_score - oom_score_adj) *
	system_memory/container_memory + oom_score_adj.

I'm wrong ? Anyway, I think you should take care of this issue.
Maybe this breaks google's oom-killer+cpuset system.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
