Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 78D9C6B0200
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 00:02:50 -0400 (EDT)
Message-ID: <4BD90529.3090401@cn.fujitsu.com>
Date: Thu, 29 Apr 2010 12:03:53 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: fix bugs of mpol_rebind_nodemask()
References: <4BD05929.8040900@cn.fujitsu.com> <alpine.DEB.2.00.1004221415090.25350@chino.kir.corp.google.com> <4BD0F797.6020704@cn.fujitsu.com> <alpine.DEB.2.00.1004230141400.2190@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1004230141400.2190@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-4-23 16:45, David Rientjes wrote:
> On Fri, 23 Apr 2010, Miao Xie wrote:
> 
>> Suppose the current mempolicy nodes is 0-2, we can remap it from 0-2 to 2,
>> then we can remap it from 2 to 1, but we can't remap it from 2 to 0-2.
>>
>> that is to say it can't be remaped to a large set of allowed nodes, and the task
>> just can use the small set of nodes for ever, even the large set of nodes is allowed,
>> I think it is unreasonable.
>>
> 
> That's been the behavior for at least three years so changing it from 
> under the applications isn't acceptable, see 
> Documentation/vm/numa_memory_policy.txt regarding mempolicy rebinds and 
> the two flags that are defined that can be used to adjust the behavior.

Is the flags what you said MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES? 
But the codes that I changed isn't under MPOL_F_STATIC_NODES or MPOL_F_RELATIVE_NODES.
The documentation doesn't say what we should do if either of these two flags is not set. 

Furthermore, in order to fix no node to alloc memory, when we want to update mempolicy
and mems_allowed, we expand the set of nodes first (set all the newly nodes) and
shrink the set of nodes lazily(clean disallowed nodes).
But remap() breaks the expanding, so if we don't remove remap(), the problem can't be
fixed. Otherwise, cpuset has to do the rebinding by itself and the code is ugly.
Like this:

static void cpuset_change_task_nodemask(struct task_struct *tsk, nodemask_t *newmems)
{
	nodemask_t tmp;
	...
	/* expand the set of nodes */
	if (!mpol_store_user_nodemask(tsk->mempolicy)) {
		nodes_remap(tmp, ...);
		nodes_or(tsk->mempolicy->v.nodes, tsk->mempolicy->v.nodes, tmp);
	}
	...

	/* shrink the set of nodes */
	if (!mpol_store_user_nodemask(tsk->mempolicy))
		tsk->mempolicy->v.nodes = tmp;
}


Thanks
Miao
> 
> The pol->v.nodes = nodes_empty(tmp) ? *nodes : tmp fix is welcome, 
> however, as a standalone patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
