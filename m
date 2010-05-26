Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C3A3B6B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 23:26:25 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o4Q3QGd4008069
	for <linux-mm@kvack.org>; Tue, 25 May 2010 20:26:16 -0700
Received: from pvc7 (pvc7.prod.google.com [10.241.209.135])
	by hpaq3.eem.corp.google.com with ESMTP id o4Q3QExx006274
	for <linux-mm@kvack.org>; Tue, 25 May 2010 20:26:15 -0700
Received: by pvc7 with SMTP id 7so2055962pvc.39
        for <linux-mm@kvack.org>; Tue, 25 May 2010 20:26:14 -0700 (PDT)
Date: Tue, 25 May 2010 20:26:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oom killer rewrite
In-Reply-To: <20100526110008.eea05fd6.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1005252014120.2916@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com> <20100520092717.0c3d8f3f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1005250231460.8045@chino.kir.corp.google.com> <20100526091740.953090a7.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1005251818070.23584@chino.kir.corp.google.com> <20100526110008.eea05fd6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 May 2010, KAMEZAWA Hiroyuki wrote:

> > It's not necessarily the memory quantity that is interesting in this case 
> > (or proportion of available memory), it's how the badness() score is 
> > altered relative to other eligible tasks that end up changing the oom kill 
> > priority list.  If we were to implement a tunable that only took a memory 
> > quantity, it would require specific knowledge of the system's capacity to 
> > make any sense compared to other tasks.  An oom_score_adj of 125MB means 
> > vastly different things on a 4GB system compared to 64GB system and admins 
> > do not want to update their script anytime they add (or hotadd) memory or 
> > run on a variety of systems that don't have the same capacities. 
> 
> IMHO, importance of application is consistent under all hosts in the system.
> (the system here means a system maintained by a team of admins to do a service.)
> 

And it's consistent whether it's unbound to any cgroup, it's attached to a 
cpuset, a memcg, or has a mempolicy restriction.  Its importance in those 
"virtualzied environments" is the same when shared with other tasks, 
that's why proportions work well: I can decide that my application should 
be targeted first by the oom killer when it is using more than 25% of 
system memory, for example.  When I attach that task to a cpuset, the 
priority is the same, I've just adjusted the amount of available memory 
out from under a set of tasks.  The point is that the script or admin that 
sets oom_score_adj need not know what resources the application has, but 
rather its memory expectations relative to other applications that share 
the same resources.

> It's not be influenced by the amount of memory, other applications, etc..
> If influenced, it's a chaos for admins.
> It seems that's fundamental difference in ideas among you and me.
> 

Other than polarizing tasks with oom_score_adj of -1000 or +1000, you must 
consider the relative importance of an application to other applications, 
that's the point of adjusting badness scoring: so we can influence which 
task is killed by the kernel instead of simply the task that is most 
memory hogging.  When an application is using more memory than desired (or 
expected), the cost of business would mandate that the task is killed and 
that threshold is definable in clear units from userspace via 
oom_score_adj and not oom_adj.

> > That's the same if you were to implement a memory quantity instead of a 
> > proportion for oom_score_adj and depends on how you want to protect or 
> > prefer that application.  For a 3G application on a 4G machine, an 
> > oom_score_adj of 250 is legitimate if you want to ensure it never uses 
> > more than 3G and is always killed first when it does.  For the 8G machine, 
> > you can't make the same killing choice if another instance of the same 
> > application is using 5G instead of 3G.  See the difference?  In that case, 
> > it may not be the correct choice for oom kill and we should kill something 
> > else: the 5G memory leaker.  That requires userspace intervention to 
> > identify, but unless we mandate the expected memory use is spelled out for 
> > every single application (which we can't), there's no way to use a fixed 
> > memory quantity to determine relative priority.
> > 
> 
> I just don't believe relative priority ;)

If application A typically consumes 6G on an 8G system and that's an 
important task, it's possible to protect it from being oom killed as the 
result of the memory usage of the remaining applications B and C with 
oom_score_adj; oom_adj does not have a clear interface for being able to 
define when to kill A when it uses more than 7G but not to kill it when it 
uses 6G.  That's the motivation behind developing a relative priority like 
oom_score_adj.

> That's why I wrote don't take my words serious. 
> I wonder if people wants precise control of oom_score_adj, they should
> use memcg and put apps into containers. In that case, static priority
> and will be useful.
> 

Indeed, using a hierarchy of memcgs is another way to do the same thing 
but seems like overkill if I'm running only a webserver and a few 
monitoring applications.  oom_score_adj also applies to cpusets and 
mempolicies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
