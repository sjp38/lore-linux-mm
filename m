Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 994B96B0224
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 14:03:35 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o3TI3U6c006887
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 11:03:30 -0700
Received: from pzk39 (pzk39.prod.google.com [10.243.19.167])
	by wpaz5.hot.corp.google.com with ESMTP id o3TI3RUs011483
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 11:03:29 -0700
Received: by pzk39 with SMTP id 39so3109633pzk.7
        for <linux-mm@kvack.org>; Thu, 29 Apr 2010 11:03:27 -0700 (PDT)
Date: Thu, 29 Apr 2010 11:03:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: fix bugs of mpol_rebind_nodemask()
In-Reply-To: <4BD90529.3090401@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1004291054010.24062@chino.kir.corp.google.com>
References: <4BD05929.8040900@cn.fujitsu.com> <alpine.DEB.2.00.1004221415090.25350@chino.kir.corp.google.com> <4BD0F797.6020704@cn.fujitsu.com> <alpine.DEB.2.00.1004230141400.2190@chino.kir.corp.google.com> <4BD90529.3090401@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Apr 2010, Miao Xie wrote:

> > That's been the behavior for at least three years so changing it from 
> > under the applications isn't acceptable, see 
> > Documentation/vm/numa_memory_policy.txt regarding mempolicy rebinds and 
> > the two flags that are defined that can be used to adjust the behavior.
> 
> Is the flags what you said MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES? 
> But the codes that I changed isn't under MPOL_F_STATIC_NODES or MPOL_F_RELATIVE_NODES.
> The documentation doesn't say what we should do if either of these two flags is not set. 
> 

MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES allow you to adjust the 
behavior of the rebind: the former requires specific nodes to be assigned 
to the mempolicy and could suppress the rebind completely, if necessary; 
the latter ensures the mempolicy nodemask has a certain weight as nodes 
are assigned in a round-robin manner.  The behavior that you're referring 
to is provided via MPOL_F_RELATIVE_NODES, which guarantees whatever weight 
is passed via set_mempolicy() will be preserved when mems are added to a 
cpuset.

Regardless of whether the behavior is documented when either flag is 
passed, we can't change the long-standing default behavior that people use 
when their cpuset mems are rebound: we can only extend the functionality 
and the behavior you're seeking is already available with a 
MPOL_F_RELATIVE_NODES flag modifier.

> Furthermore, in order to fix no node to alloc memory, when we want to update mempolicy
> and mems_allowed, we expand the set of nodes first (set all the newly nodes) and
> shrink the set of nodes lazily(clean disallowed nodes).

That's a cpuset implementation choice, not a mempolicy one; mempolicies 
have nothing to do with an empty current->mems_allowed.

> But remap() breaks the expanding, so if we don't remove remap(), the problem can't be
> fixed. Otherwise, cpuset has to do the rebinding by itself and the code is ugly.
> Like this:
> 
> static void cpuset_change_task_nodemask(struct task_struct *tsk, nodemask_t *newmems)
> {
> 	nodemask_t tmp;
> 	...
> 	/* expand the set of nodes */
> 	if (!mpol_store_user_nodemask(tsk->mempolicy)) {
> 		nodes_remap(tmp, ...);
> 		nodes_or(tsk->mempolicy->v.nodes, tsk->mempolicy->v.nodes, tmp);
> 	}
> 	...
> 
> 	/* shrink the set of nodes */
> 	if (!mpol_store_user_nodemask(tsk->mempolicy))
> 		tsk->mempolicy->v.nodes = tmp;
> }
> 

I don't see why this is even necessary, the mempolicy code could simply 
return numa_node_id() when nodes_empty(current->mempolicy->v.nodes) to 
close the race.

 [ Your pseudo-code is also lacking task_lock(tsk), which is required to 
   safely dereference tsk->mempolicy, and this is only available so far in 
   -mm since the oom killer rewrite. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
