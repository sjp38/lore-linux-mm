Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 64DE16B02D2
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 22:50:31 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o7Q2oTtS031112
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 19:50:29 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by hpaq2.eem.corp.google.com with ESMTP id o7Q2oRfZ017367
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 19:50:27 -0700
Received: by pzk4 with SMTP id 4so549659pzk.7
        for <linux-mm@kvack.org>; Wed, 25 Aug 2010 19:50:26 -0700 (PDT)
Date: Wed, 25 Aug 2010 19:50:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2][BUGFIX] oom: remove totalpage normalization from
 oom_badness()
In-Reply-To: <20100826101139.eb05fe2d.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008251920510.6227@chino.kir.corp.google.com>
References: <20100825184001.F3EF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1008250300500.13300@chino.kir.corp.google.com> <20100826093923.d4ac29b6.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008251746200.28401@chino.kir.corp.google.com>
 <20100826101139.eb05fe2d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Aug 2010, KAMEZAWA Hiroyuki wrote:

> Hmm. I'll add a text like following to cgroup/memory.txt. O.K. ?
> 
> ==
> Notes on oom_score and oom_score_adj.
> 
> oom_score is calculated as
> 	oom_score = (taks's proportion of memory) + oom_score_adj.
> 

I'd replace "memory" with "memory limit (or memsw limit)" so it's clear 
we're talking about the amount of memory available to task.

> Then, when you use oom_score_adj to control the order of priority of oom,
> you should know about the amount of memory you can use.

Hmm, you need to know the amount of memory that you can use iff you know 
the memcg limit and it's a static value.  Otherwise, you only need to know 
the "memory usage of your application relative to others in the same 
cgroup."  An oom_score_adj of +300 adds 30% of that memcg's limit to the 
task, allowing all other tasks to use 30% more memory than that task with 
it still be killed.  An oom_score_adj of -300 allows that task to use 30% 
more memory than other tasks without getting killed.  These don't need to 
know the actual limit.

> So, an approximate oom_score under memcg can be
> 
>  memcg_oom_score = (oom_score - oom_score_adj) * system_memory/memcg's limit
> 		+ oom_score_adj.
> 

Right, that's the exact score within the memcg.

But, I still wouldn't encourage a formula like this because the memcg 
limit (or cpuset mems, mempolicy nodes, etc) are dynamic and may change 
out from under us.  So it's more important to define oom_score_adj in the 
user's mind as a proportion of memory available to be added (either 
positively or negatively) to its memory use when comparing it to other 
tasks.  The point is that the memcg limit isn't interesting in this 
formula, it's more important to understand the priority of the task 
_compared_ to other tasks memory usage in that memcg.

It probably would be helpful, though, if you know that a vital system task 
uses 1G, for instance, in a 4G memcg that an oom_score_adj of -250 will 
disable oom killing for it.  If that tasks leaks memory or becomes 
significantly large, for whatever reason, it could be killed, but we _can_ 
discount the 1G in comparison to other tasks as the "cost of doing 
business" when it comes to vital system tasks:

	(memory usage) * (memory+swap limit / system memory)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
