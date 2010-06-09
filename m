Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 560D96B01D2
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:40:54 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o590eoDH019988
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:40:50 -0700
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by kpbe11.cbf.corp.google.com with ESMTP id o590emt5018412
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:40:49 -0700
Received: by pvg2 with SMTP id 2so1589826pvg.30
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 17:40:48 -0700 (PDT)
Date: Tue, 8 Jun 2010 17:40:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 09/18] oom: select task from tasklist for mempolicy
 ooms
In-Reply-To: <20100608164325.a5fcdb39.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006081732080.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061525000.32225@chino.kir.corp.google.com> <20100608164325.a5fcdb39.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > The oom killer presently kills current whenever there is no more memory
> > free or reclaimable on its mempolicy's nodes.  There is no guarantee that
> > current is a memory-hogging task or that killing it will free any
> > substantial amount of memory, however.
> 
> Well OK.  But we don't necesarily *want* to "free a substantial amount
> of memory".  We want to resolve the oom within `current'.  That's the
> sole responsibility of the oom-killer.  It doesn't have to free up
> large amounts of additional memory in the expectation that sometime in
> the future some other task will get an oom as well.  if the oom-killer
> is working well, we can defer those actions until the problem actually
> occurs.
> 

The oom killer has always attempted to kill a task that frees a large 
amount of memory: look at goal #2 in today's badness() heuristic (we 
recover a large amount of memory).  By doing this, we avoid endless loops 
where anything we fork or our bash shell is constantly being oom killed or 
a large number of tasks that only free minimal amounts of memory get 
killed.  The current behavior of killing current rarely works as a single 
remedy without being followed up by additional kills or user intervention.

> Plus: if `current' isn't using much memory then it's probably a
> short-lived or not-very-important process anyway.
> 

That potentially prevents anything bound to that mempolicy from ever 
getting forked.

> > In such situations, it is better to scan the tasklist for nodes that are
> > allowed to allocate on current's set of nodes and kill the task with the
> > highest badness() score.  This ensures that the most memory-hogging task,
> > or the one configured by the user with /proc/pid/oom_adj, is always
> > selected in such scenarios.
> 
> Well... *why* is it better?  Needs more justification/explanation IMO.
> 

This unifies mempolicy oom conditions with the same behavior of cpuset or 
memcg oom conditions: we want to utilize the badness() heuristic to kill 
the best candidate task and not nuke tons of processes for little benefit 
or, for instance, kill all other tasks sharing those same mempolicy nodes 
at the benefit of a memory hogger.  Userspace has the ability to influence 
this heuristic (and even more powerfully with my heuristic rewrite coming 
later in this series) so it can better tune how the kernel reacts to 
mempolicy ooms, which is a key objective of this work.  Simply killing 
current leaves no userspace intervention and can kill meaningful (and 
innocent) tasks which loses work for no reason.

> A long time ago Andrea changed the oom-killer so that it basically
> always killed `current', iirc.  I think that shipped in the Suse
> kernel.

You can do that for the entire oom killer by enabling 
/proc/sys/vm/oom_kill_allocating_task.  SGI wanted that to avoid these 
lengthy tasklist scans.

> Maybe it was only in the case where `current' got an oom when
> satisfying a pagefault, I forget the details.  But according to Andrea,
> this design provided a simple and practical solution to ooms.
> 

Right, VM_FAULT_OOM always killed current and that was recently changed to 
invoke the pagefault oom handler.  Nick has now converted the remaining 
architectures which were not using it to do so, so there is actually no 
difference for pagefaults anymore.  In an earlier revision of this 
rewrite, I wanted pagefault ooms to try killing current first if it were 
killable and then backup to the tasklist scan and heuristic use, but that 
was argued against for not conforming to other memory allocation failures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
