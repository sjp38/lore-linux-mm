Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CA68F600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 21:46:32 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o731oIhh023209
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 18:50:18 -0700
Received: from pxi13 (pxi13.prod.google.com [10.243.27.13])
	by hpaq2.eem.corp.google.com with ESMTP id o731oGv4019825
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 18:50:16 -0700
Received: by pxi13 with SMTP id 13so1725248pxi.36
        for <linux-mm@kvack.org>; Mon, 02 Aug 2010 18:50:15 -0700 (PDT)
Date: Mon, 2 Aug 2010 18:50:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008021837370.19184@chino.kir.corp.google.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com> <20100729183809.ca4ed8be.akpm@linux-foundation.org> <20100730195338.4AF6.A69D9226@jp.fujitsu.com> <20100802134312.c0f48615.akpm@linux-foundation.org> <20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com> <20100803093610.f4d30ca7.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021742440.9569@chino.kir.corp.google.com> <20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, KAMEZAWA Hiroyuki wrote:

> Hmm, then, oom_score shows the values for all limitations in array ?
> 

/proc/pid/oom_score will change if a task's cpuset, memcg, or mempolicy 
attachment changes or its mems, nodes, or limit changes because it's a 
proportion of available memory.  /proc/pid/oom_score_adj stays constant 
such that the oom killing priority of that task relative to other tasks 
sharing the same constraints and competing for the same memory is the 
same.  The point is that it doesn't matter how much memory a task has 
available, but rather what it's priority is with the tasks that compete 
with it for memory.

You could, of course, do some simple arithmetic to write a memory quantity 
to oom_score_adj if you really wanted to, but that would force the user to 
recalculate the value anytime the task's cpuset, mempolicy, or memcg 
changes.

> > > Usual disto alreay enables it.
> > > 
> > 
> > Yes, I'm well aware of my 40MB of lost memory on my laptop :)
> > 
> Very sorry ;)
> But it's required to track memory usage from init...
> 

Memcg comes with a cost of ~1% of system memory on x86 since
struct page_cgroup is ~1% of a 4K page.  That means if we were to deploy 
memcg on all of our servers and the number of jobs we can run is 
constrained only by memory, it's equivalent to losing ~1% of our servers.  
That, for us, is very large.

This is a different topic entirely, but it's a very significant 
disadvantage and enough that most people who care about oom killing 
prioritization aren't going to wany to incur such an overhead by enabling 
memcg or setting up individual memcg for each and every job, because that 
requires specific knowledge of all those jobs.

I'm not by any means proposing oom_score_adj as being very popular for the 
usual desktop environments :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
