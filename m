Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5D3676B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 22:04:18 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4Q24FNx005413
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 26 May 2010 11:04:15 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2445345DE70
	for <linux-mm@kvack.org>; Wed, 26 May 2010 11:04:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E8ADD45DE6F
	for <linux-mm@kvack.org>; Wed, 26 May 2010 11:04:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BA9BC1DB803F
	for <linux-mm@kvack.org>; Wed, 26 May 2010 11:04:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 62691E38006
	for <linux-mm@kvack.org>; Wed, 26 May 2010 11:04:14 +0900 (JST)
Date: Wed, 26 May 2010 11:00:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: oom killer rewrite
Message-Id: <20100526110008.eea05fd6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1005251818070.23584@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com>
	<20100520092717.0c3d8f3f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1005250231460.8045@chino.kir.corp.google.com>
	<20100526091740.953090a7.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1005251818070.23584@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2010 18:40:36 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 26 May 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > The only sane badness heuristic will be one that effectively compares all 
> > > eligible tasks for oom kill in a way that are relative to one another; I'm 
> > > concerned that a tunable that is based on a pure memory quantity requires 
> > > specific knowledge of the system (or memcg, cpuset, etc) capacity before 
> > > it is meaningful.  In other words, I opted to use a relative proportion so 
> > > that when tasks are constrained to cpusets or memcgs or mempolicies they 
> > > become part of a "virtualized system" where the proportion is then used in 
> > > calculation of the total amount of system RAM, memcg limit, cpuset mems 
> > > capacities, etc, without knowledge of what that value actually is.  So 
> > > "echo 3G" may be valid in your example when not constrained to any cgroup 
> > > or mempolicy but becomes invalid if I attach it to a cpuset with a single 
> > > node of 1G capacity.  When oom_score_adj, we can specify the proportion 
> > > "of the resources that the application has access to" in comparison to 
> > > other applications that share those resources to determine oom killing 
> > > priority.  I think that's a very powerful interface and your suggestion 
> > > could easily be implemented in userspace with a simple divide, thus we 
> > > don't need kernel support for it.
> > > 
> > I know admins will be able to write a script. But, my point is
> > "please don't force admins to write such a hacky scripts."
> > 
> 
> It's not necessarily the memory quantity that is interesting in this case 
> (or proportion of available memory), it's how the badness() score is 
> altered relative to other eligible tasks that end up changing the oom kill 
> priority list.  If we were to implement a tunable that only took a memory 
> quantity, it would require specific knowledge of the system's capacity to 
> make any sense compared to other tasks.  An oom_score_adj of 125MB means 
> vastly different things on a 4GB system compared to 64GB system and admins 
> do not want to update their script anytime they add (or hotadd) memory or 
> run on a variety of systems that don't have the same capacities. 

IMHO, importance of application is consistent under all hosts in the system.
(the system here means a system maintained by a team of admins to do a service.)

It's not be influenced by the amount of memory, other applications, etc..
If influenced, it's a chaos for admins.
It seems that's fundamental difference in ideas among you and me.


> > For example, an admin uses an application which always use 3G bytes adn it's
> > valid and sane use for the application. When he run it on a server with
> > 4G system and 8G system, he has to change the value for oom_score_adj.
> > 
> 
> That's the same if you were to implement a memory quantity instead of a 
> proportion for oom_score_adj and depends on how you want to protect or 
> prefer that application.  For a 3G application on a 4G machine, an 
> oom_score_adj of 250 is legitimate if you want to ensure it never uses 
> more than 3G and is always killed first when it does.  For the 8G machine, 
> you can't make the same killing choice if another instance of the same 
> application is using 5G instead of 3G.  See the difference?  In that case, 
> it may not be the correct choice for oom kill and we should kill something 
> else: the 5G memory leaker.  That requires userspace intervention to 
> identify, but unless we mandate the expected memory use is spelled out for 
> every single application (which we can't), there's no way to use a fixed 
> memory quantity to determine relative priority.
> 

I just don't believe relative priority ;)
Then, my customer will just disable oom or will use panic_on_oom.
That's why I wrote don't take my words serious. 
I wonder if people wants precise control of oom_score_adj, they should
use memcg and put apps into containers. In that case, static priority
and will be useful.

> If you really did always want to kill that 3G task, an oom_score_adj value 
> of +1000 would always work just like a value of +15 does for oom_adj.
> 
> > One good point of old oom_adj is that it's not influenced by environment.
> > Then, X-window applications set it's oom_adj to be fixed value. 
> > IIUC, they're hardcoded with fixed value, now. 
> > 
> 
> It _is_ influenced by environment, just indirectly.  It's a bitshift on 
> the badness() score so for any other usecase other than a complete 
> polarization of the score to either always prefer or completely disable 
> oom killing for a task, it's practically useless.  The bitshift will 
> increase or decrease the score but that score will be ranked according to 
> the scores of other tasks on the system.  So if a task consuming 400K of 
> memory has a badness score of 100 with an oom_adj value of +10, the end 
> result is a score of 102400 which would represent about 10% of system 
> memory on a 4G system but about 1.5% of system memory on a 64GB system.  
> So the actual preference of a task, minus the usecase of polarizing the 
> task with oom_adj, is completely dependent on the size of system RAM.
> 
> oom_adj must also be altered anytime a task is attached to a cpuset or 
> memcg (or even mempolicy now) since its effect on badness will skew how 
> the score is compared relative to all other tasks in that cpuset, memcg, 
> or attached to the mempolicy nodes.
> 

I agree that oom_score_adj is better than current oom_adj.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
