Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 960FD6B01CC
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 01:32:20 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o5H5WFgA016344
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 22:32:15 -0700
Received: from pvc7 (pvc7.prod.google.com [10.241.209.135])
	by kpbe19.cbf.corp.google.com with ESMTP id o5H5WCNf023810
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 22:32:13 -0700
Received: by pvc7 with SMTP id 7so238048pvc.14
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 22:32:12 -0700 (PDT)
Date: Wed, 16 Jun 2010 22:32:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 16/18] oom: badness heuristic rewrite
In-Reply-To: <20100608155802.cdd4aff3.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006162215280.19549@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061526540.32225@chino.kir.corp.google.com> <20100608155802.cdd4aff3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > This a complete rewrite of the oom killer's badness() heuristic which is
> > used to determine which task to kill in oom conditions.  The goal is to
> > make it as simple and predictable as possible so the results are better
> > understood and we end up killing the task which will lead to the most
> > memory freeing while still respecting the fine-tuning from userspace.
> 
> It's not obvious from this description that then end result is better! 

I think it's fairly obvious that predictablility is an important part of 
any heuristic that will determine whether your task survives or dies.

> Have you any testcases or scenarios which got improved?
> 

Yes, as cited below in the changelog with the KDE example.

> > Instead of basing the heuristic on mm->total_vm for each task, the task's
> > rss and swap space is used instead.  This is a better indication of the
> > amount of memory that will be freeable if the oom killed task is chosen
> > and subsequently exits.
> 
> Again, why should we optimise for the amount of memory which a killing
> will yield (if that's what you mean).  We only need to free enough
> memory to unblock the oom condition then proceed.
> 

That's what the oom killer has always done simply because we want to avoid 
subsequent oom conditions in the near future that will require additional 
tasks to be killed.  It seems far better to kill a large memory-hogging 
task[*] than ten smaller tasks that total the same amount of memory usage.

 [*] And, with this rewrite, "memory-hogging" can be defined for the first
     time from userspace with a tunable, oom_score_adj, that actually has
     units so that within a cpuset, for example, we can bias a task by
     25% of available memory or bias other tasks against it by 25%.  For
     the first time ever, we can say "this task should be able to use 25%
     more memory than other tasks without getting killed first."

> The last thing we want to do is to kill a process which has consumed
> 1000 CPU hours, or which is providing some system-critical service or
> whatever.  Amount-of-memory-freeable is a relatively minor criterion.
> 

What would you suggest otherwise?  Cputime?  Then we may never be able to 
fork our bash shell or ssh into our machines.

> >  This helps specifically in cases where KDE or
> > GNOME is chosen for oom kill on desktop systems instead of a memory
> > hogging task.
> 
> It helps how?  Examples and test cases?
> 

Because KDE and GNOME typically have very large mm->total_vm values but 
the amount of resident memory in RAM is consumed by other tasks, even 
memory leakers.  mm->total_vm is agreed to be a very poor heursitic 
baseline by just about everyone.

> > The baseline for the heuristic is a proportion of memory that each task is
> > currently using in memory plus swap compared to the amount of "allowable"
> > memory.
> 
> What does "swap" mean?  swapspace includes swap-backed swapcache,
> un-swap-backed swapcache and non-resident swap.  Which of all these is
> being used here and for what reason?
> 

This is swap cache, the number of swap entries for the task which could be 
freeable if the task is killed that could subsequently be used for page 
allocations that triggered the oom killer.  We want to add hints to the 
oom killer so that memory which cannot be used on blockable memory 
allocations may be freed so we don't call into the oom killer again in the 
near future.

> > /proc/pid/oom_adj is changed so that its meaning is rescaled into the
> > units used by /proc/pid/oom_score_adj, and vice versa.  Changing one of
> > these per-task tunables will rescale the value of the other to an
> > equivalent meaning.  Although /proc/pid/oom_adj was originally defined as
> > a bitshift on the badness score, it now shares the same linear growth as
> > /proc/pid/oom_score_adj but with different granularity.  This is required
> > so the ABI is not broken with userspace applications and allows oom_adj to
> > be deprecated for future removal.
> 
> It was a mistake to add oom_adj in the first place.  Because it's a
> user-visible knob which us tied to a particular in-kernel
> implementation.  As we're seeing now, the presence of that knob locks
> us into a particular implementation.
> 

Agreed.

> Given that oom_score_adj is just a rescaled version of oom_adj
> (correct?), I guess things haven't got a lot worse on that front as a
> result of these changes.
> 

No, it's not a rescaled version at all, we merely rescale oom_adj to 
oom_score_adj units because everyone objected to removing oom_adj without 
deprecation first.  oom_score_adj has units: a proportion of memory 
available to the application, meaning how much of the system, memcg, 
cpuset, or mempolicy it should be biased or favored by.  Please see the 
change to Documentation/filesystems/proc.txt which explain this pretty 
elaborately.

> General observation regarding the patch description: I'm not seeing a
> lot of reason for merging the patch!  What value does it bring to our
> users?  What problems got solved?
> 

It significantly improves the oom killer's predictability, it protects 
vital system tasks like KDE and GNOME on the desktop, it allows users to 
tune each task with a bias or preference in units they understand to 
affect its score, and it allows that interface to remain constant and 
valid even when those tasks are subsequently attached to a cgroup or bound 
to a mempolicy (or their limits or set of allowed nodes are changed).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
