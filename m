Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 91CE26B0211
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 13:36:40 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o38HaXTC001251
	for <linux-mm@kvack.org>; Thu, 8 Apr 2010 10:36:33 -0700
Received: from pzk13 (pzk13.prod.google.com [10.243.19.141])
	by kpbe11.cbf.corp.google.com with ESMTP id o38HaE33008107
	for <linux-mm@kvack.org>; Thu, 8 Apr 2010 12:36:31 -0500
Received: by pzk13 with SMTP id 13so1960380pzk.13
        for <linux-mm@kvack.org>; Thu, 08 Apr 2010 10:36:31 -0700 (PDT)
Date: Thu, 8 Apr 2010 10:36:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1004081018310.25592@chino.kir.corp.google.com>
References: <20100405154923.23228529.akpm@linux-foundation.org> <alpine.DEB.2.00.1004051552400.27040@chino.kir.corp.google.com> <20100406201645.7E69.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
 <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Apr 2010, KAMEZAWA Hiroyuki wrote:

> > > oom-badness-heuristic-rewrite.patch
> > 
> > Do you have any specific feedback that you could offer on why you decided 
> > to nack this?
> > 
> 
> I like this patch. But I think no one can't Ack this because there is no
> "correct" answer. At least, this show good behavior on my environment.
> 

Agreed.  I think the new oom_badness() function is much better than the 
current heuristic and should prevent X from being killed as we've 
discussed fairly often on LKML over the past six months.

> > Keeping /proc/pid/oom_adj around indefinitely isn't very helpful if 
> > there's a finer grained alternative available already unless you want 
> > /proc/pid/oom_adj to actually mean something in which case you'll never be 
> > able to seperate oom badness scores from bitshifts.  I believe everyone 
> > agrees that a more understood and finer grained tunable is necessary as 
> > compared to the current implementation that has very limited functionality 
> > other than polarizing tasks.
> > 
> 
> If oom-badness-heuristic-rewrite.patch will go ahead, this should go.
> But my concern is administorator has to check all oom_score_adj and
> tune it again if he adds more memory to the system.
> 
> Now, not-small amount of people use Virtual Machine or Contaienr. So, this
> oom_score_adj's sensivity to the size of memory can put admins to hell.
> 

Would you necessarily want to change oom_score_adj when you add or remove 
memory?  I see the currently available pool of memory available (whether 
it is system-wide, constrained to a cpuset mems, mempolicy nodes, or memcg 
limits) as a shared resource so if you want to bias a task by 25% of 
available memory by using an oom_score_adj of 250, that doesn't change if 
we add or remove memory.  It still means that the task should be biased by 
that amount in comparison to other tasks.

My perspective is that we should define oom killing priorities is terms of 
how much memory tasks are using compared to others and that the actual 
capacity itself is irrelevant if its a shared resource.  So when tasks are 
moved into a memcg, for example, that becomes a "virtualized system" with 
a more limited shared memory resource and has the same bias (or 
preference) that it did when it was in the root cgroup.

In other words, I think it would be more inconvenient to update 
oom_score_adj anytime a task changes memcg, is attached to a different 
cpuset, or is bound to nodes by way of a mempolicy.  In these scenarios, I 
see them as simply having a restricted set of allowed memory yet the bias 
can remain the same.

Users who do actually want to bias a task by a memory quantity can easily 
do so, but I think they would be in the minority and we hope to avoid 
adding unnecessary tunables when a conversion to the appropriate 
oom_score_adj value is possible with a simple divide.

> > > oom-replace-sysctls-with-quick-mode.patch
> > > 
> > > IIRC, alan and nick and I NAKed such patch. everybody explained the reason.
> > 
> > Which patch of the four you listed are you referring to here?
> > 
> replacing used sysctl is bad idea, in general.
> 

I agree, but since the audience for both of these sysctls will need to do 
echo 0 > /proc/sys/vm/oom_dump_tasks as the result of this patchset since 
it is now enabled by default, do you think we can take this as an 
opportunity to consolidate them down into one?  Otherwise, we're obliged 
to continue to support them indefinitely even though their only users are 
the exact same systems.

> I have no _strong_ opinion. I welcome the patch series. But aboves are my concern.
> Thank you for your work.
> 

Thanks, Kame, I appreciate that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
