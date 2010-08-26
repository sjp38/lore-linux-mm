Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 96DD76B01F1
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 23:25:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7Q3PQVI027331
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Aug 2010 12:25:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 63A6D45DE4C
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 12:25:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 44FEE45DE50
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 12:25:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A8431DB8014
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 12:25:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A83861DB8012
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 12:25:25 +0900 (JST)
Date: Thu, 26 Aug 2010 12:20:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2][BUGFIX] oom: remove totalpage normalization from
 oom_badness()
Message-Id: <20100826122025.38112f79.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008251920510.6227@chino.kir.corp.google.com>
References: <20100825184001.F3EF.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1008250300500.13300@chino.kir.corp.google.com>
	<20100826093923.d4ac29b6.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008251746200.28401@chino.kir.corp.google.com>
	<20100826101139.eb05fe2d.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008251920510.6227@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010 19:50:22 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 26 Aug 2010, KAMEZAWA Hiroyuki wrote:
> 
> > Hmm. I'll add a text like following to cgroup/memory.txt. O.K. ?
> > 
> > ==
> > Notes on oom_score and oom_score_adj.
> > 
> > oom_score is calculated as
> > 	oom_score = (taks's proportion of memory) + oom_score_adj.
> > 
> 
> I'd replace "memory" with "memory limit (or memsw limit)" so it's clear 
> we're talking about the amount of memory available to task.
> 
ok.

> > Then, when you use oom_score_adj to control the order of priority of oom,
> > you should know about the amount of memory you can use.
> 
> Hmm, you need to know the amount of memory that you can use iff you know 
> the memcg limit and it's a static value.  Otherwise, you only need to know 
> the "memory usage of your application relative to others in the same 
> cgroup."  An oom_score_adj of +300 adds 30% of that memcg's limit to the 
> task, allowing all other tasks to use 30% more memory than that task with 
> it still be killed.  An oom_score_adj of -300 allows that task to use 30% 
> more memory than other tasks without getting killed.  These don't need to 
> know the actual limit.
> 

Hmm. What's complicated is oom_score_adj's behavior.


> > So, an approximate oom_score under memcg can be
> > 
> >  memcg_oom_score = (oom_score - oom_score_adj) * system_memory/memcg's limit
> > 		+ oom_score_adj.
> > 
> 
> Right, that's the exact score within the memcg.
> 
> But, I still wouldn't encourage a formula like this because the memcg 
> limit (or cpuset mems, mempolicy nodes, etc) are dynamic and may change 
> out from under us.  So it's more important to define oom_score_adj in the 
> user's mind as a proportion of memory available to be added (either 
> positively or negatively) to its memory use when comparing it to other 
> tasks.  The point is that the memcg limit isn't interesting in this 
> formula, it's more important to understand the priority of the task 
> _compared_ to other tasks memory usage in that memcg.
> 

yes. For defineing/understanding priority, oom_score_adj is that.
But it's priority isn't static.

> It probably would be helpful, though, if you know that a vital system task 
> uses 1G, for instance, in a 4G memcg that an oom_score_adj of -250 will 
> disable oom killing for it.  

yes.

> If that tasks leaks memory or becomes 
> significantly large, for whatever reason, it could be killed, but we _can_ 
> discount the 1G in comparison to other tasks as the "cost of doing 
> business" when it comes to vital system tasks:
> 
> 	(memory usage) * (memory+swap limit / system memory)
> 

yes. under 8G system, -250 will allow ingnoring 2G of usage.

== How about this text ? ==

When you set a task's oom_score_adj, it can get priority not to be oom-killed.
oom_score_adj gives priority proportional to the memory limitation.

Assuming you set -250 to oom_score_adj.

Under 4G memory limit, it gets 25% of bonus...1G memory bonus for avoiding OOM.
Under 8G memory limit, it gets 25% of bonus...2G memory bonus for avoiding OOM.

Then, what bonus a task can get depends on the context of OOM. If you use
oom_score_adj and want to give bonus to a task, setting it in regard with
minimum memory limitation which a task is under will work well.
==

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
