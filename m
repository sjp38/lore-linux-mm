Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 320DA6B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 21:40:50 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o4Q1ehn1024205
	for <linux-mm@kvack.org>; Tue, 25 May 2010 18:40:45 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by wpaz24.hot.corp.google.com with ESMTP id o4Q1ee9l031617
	for <linux-mm@kvack.org>; Tue, 25 May 2010 18:40:41 -0700
Received: by pwi9 with SMTP id 9so1528582pwi.7
        for <linux-mm@kvack.org>; Tue, 25 May 2010 18:40:40 -0700 (PDT)
Date: Tue, 25 May 2010 18:40:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oom killer rewrite
In-Reply-To: <20100526091740.953090a7.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1005251818070.23584@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com> <20100520092717.0c3d8f3f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1005250231460.8045@chino.kir.corp.google.com> <20100526091740.953090a7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 May 2010, KAMEZAWA Hiroyuki wrote:

> > The only sane badness heuristic will be one that effectively compares all 
> > eligible tasks for oom kill in a way that are relative to one another; I'm 
> > concerned that a tunable that is based on a pure memory quantity requires 
> > specific knowledge of the system (or memcg, cpuset, etc) capacity before 
> > it is meaningful.  In other words, I opted to use a relative proportion so 
> > that when tasks are constrained to cpusets or memcgs or mempolicies they 
> > become part of a "virtualized system" where the proportion is then used in 
> > calculation of the total amount of system RAM, memcg limit, cpuset mems 
> > capacities, etc, without knowledge of what that value actually is.  So 
> > "echo 3G" may be valid in your example when not constrained to any cgroup 
> > or mempolicy but becomes invalid if I attach it to a cpuset with a single 
> > node of 1G capacity.  When oom_score_adj, we can specify the proportion 
> > "of the resources that the application has access to" in comparison to 
> > other applications that share those resources to determine oom killing 
> > priority.  I think that's a very powerful interface and your suggestion 
> > could easily be implemented in userspace with a simple divide, thus we 
> > don't need kernel support for it.
> > 
> I know admins will be able to write a script. But, my point is
> "please don't force admins to write such a hacky scripts."
> 

It's not necessarily the memory quantity that is interesting in this case 
(or proportion of available memory), it's how the badness() score is 
altered relative to other eligible tasks that end up changing the oom kill 
priority list.  If we were to implement a tunable that only took a memory 
quantity, it would require specific knowledge of the system's capacity to 
make any sense compared to other tasks.  An oom_score_adj of 125MB means 
vastly different things on a 4GB system compared to 64GB system and admins 
do not want to update their script anytime they add (or hotadd) memory or 
run on a variety of systems that don't have the same capacities.  What 
they want to do is specify the priority of an application either to prefer 
it or protect it from oom kill by saying "this application can use 25% 
more memory available to it than everything else" or "this application 
should be killed if it's not leaving at least 25% to everything else."

> For example, an admin uses an application which always use 3G bytes adn it's
> valid and sane use for the application. When he run it on a server with
> 4G system and 8G system, he has to change the value for oom_score_adj.
> 

That's the same if you were to implement a memory quantity instead of a 
proportion for oom_score_adj and depends on how you want to protect or 
prefer that application.  For a 3G application on a 4G machine, an 
oom_score_adj of 250 is legitimate if you want to ensure it never uses 
more than 3G and is always killed first when it does.  For the 8G machine, 
you can't make the same killing choice if another instance of the same 
application is using 5G instead of 3G.  See the difference?  In that case, 
it may not be the correct choice for oom kill and we should kill something 
else: the 5G memory leaker.  That requires userspace intervention to 
identify, but unless we mandate the expected memory use is spelled out for 
every single application (which we can't), there's no way to use a fixed 
memory quantity to determine relative priority.

If you really did always want to kill that 3G task, an oom_score_adj value 
of +1000 would always work just like a value of +15 does for oom_adj.

> One good point of old oom_adj is that it's not influenced by environment.
> Then, X-window applications set it's oom_adj to be fixed value. 
> IIUC, they're hardcoded with fixed value, now. 
> 

It _is_ influenced by environment, just indirectly.  It's a bitshift on 
the badness() score so for any other usecase other than a complete 
polarization of the score to either always prefer or completely disable 
oom killing for a task, it's practically useless.  The bitshift will 
increase or decrease the score but that score will be ranked according to 
the scores of other tasks on the system.  So if a task consuming 400K of 
memory has a badness score of 100 with an oom_adj value of +10, the end 
result is a score of 102400 which would represent about 10% of system 
memory on a 4G system but about 1.5% of system memory on a 64GB system.  
So the actual preference of a task, minus the usecase of polarizing the 
task with oom_adj, is completely dependent on the size of system RAM.

oom_adj must also be altered anytime a task is attached to a cpuset or 
memcg (or even mempolicy now) since its effect on badness will skew how 
the score is compared relative to all other tasks in that cpuset, memcg, 
or attached to the mempolicy nodes.

> Even if my customer may use only OOM_DISABLE, I think using oom_score_adj
> is too difficult for usual users.
> 

How is oom_score_adj, which has a well-defined unit of "proportion of 
available memory" more difficult to use than oom_adj, which exponentially 
increases a tasks badness score with no units other than "badness() 
quantum"?  The typical use case for these users is simply to polarize the 
score, anyway, which is still possible with oom_score_adj: oom_score_adj 
of -1000 is equivalent oom_adj of -17 and oom_score_adj of +1000 is 
equivalent to oom_adj of +15.  That conversion is done automatically for 
existing users of oom_adj, so I find oom_score_adj to be much more 
predicatable and scalable than oom_adj.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
