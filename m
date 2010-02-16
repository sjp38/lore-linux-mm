Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 76B446B004D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 16:53:01 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id o1GLqw38026121
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 13:52:58 -0800
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by spaceape14.eur.corp.google.com with ESMTP id o1GLquMP015847
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 13:52:56 -0800
Received: by pwi10 with SMTP id 10so837748pwi.11
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 13:52:55 -0800 (PST)
Date: Tue, 16 Feb 2010 13:52:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/7 -mm] oom: select task from tasklist for mempolicy
 ooms
In-Reply-To: <20100216135240.72EC.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002161343070.23037@chino.kir.corp.google.com>
References: <20100215120924.7281.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1002151407000.26927@chino.kir.corp.google.com> <20100216135240.72EC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, KOSAKI Motohiro wrote:

> > We need to get a refcount on the mempolicy to ensure it doesn't get freed 
> > from under us, tsk is not necessarily current.
> 
> Hm.
> if you explanation is correct, I think your patch have following race.
> 
> 
>  CPU0                            CPU1
> ----------------------------------------------
> mempolicy_nodemask_intersects()
> mempolicy = tsk->mempolicy;
>                                  do_exit()
>                                  mpol_put(tsk_mempolicy)
> mpol_get(mempolicy);
> 

True, good point.  It looks like we'll need to include mempolicy 
detachment in exit_mm() while under task_lock() and then synchronize with 
that.  It's a legitimate place to do it since no memory allocation will be 
done after its mm is detached, anyway.

> > For MPOL_F_LOCAL, we need to check whether the task's cpu is on a node 
> > that is allowed by the zonelist passed to the page allocator.  In the 
> > second revision of this patchset, this was changed to
> > 
> > 	node_isset(cpu_to_node(task_cpu(tsk)), *mask)
> > 
> > to check.  It would be possible for no memory to have been allocated on 
> > that node and it just happens that the tsk is running on it momentarily, 
> > but it's the best indication we have given the mempolicy of whether 
> > killing a task may lead to future memory freeing.
> 
> This calculation is still broken. In general, running cpu and allocation node
> is not bound.

Not sure what you mean, MPOL_F_LOCAL means that allocations will happen on 
the node of the cpu on which it is running.  The cpu-to-node mapping 
doesn't change, only the cpu on which it is running may change.  That may 
be restricted by sched_setaffinity() or cpusets, however, so this task may 
never allocate on any other node (i.e. it may run on another cpu, but 
always one local to a specific node).  That's enough of an indication that 
it should be a candidate for kill: we're trying to eliminate tasks that 
may never allocate on current's nodemask from consideration.  In other 
words, it would be unfair for two tasks that are isolated to their own 
cpus on different physical nodes using MPOL_F_LOCAL for NUMA optimizations 
to have the other needlessly killed when current can't allocate there 
anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
