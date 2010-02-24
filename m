Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 184A76B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 16:06:54 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o1OL6ol4021423
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 21:06:50 GMT
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by wpaz24.hot.corp.google.com with ESMTP id o1OL6mWT028579
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 13:06:48 -0800
Received: by pvg3 with SMTP id 3so1050908pvg.13
        for <linux-mm@kvack.org>; Wed, 24 Feb 2010 13:06:48 -0800 (PST)
Date: Wed, 24 Feb 2010 13:06:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
In-Reply-To: <4B84F645.6030404@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002241253560.30870@chino.kir.corp.google.com>
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop> <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com> <20100222121222.GV9738@laptop>
 <alpine.DEB.2.00.1002221400060.23881@chino.kir.corp.google.com> <4B839103.2060901@cn.fujitsu.com> <alpine.DEB.2.00.1002230041240.12015@chino.kir.corp.google.com> <4B84F645.6030404@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Feb 2010, Miao Xie wrote:

> >> Sorry, Could you explain what you advised?
> >> I think it is hard to fix this problem by adding a variant, because it is
> >> hard to avoid loading a word of the mask before
> >>
> >> 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
> >>
> >> and then loading another word of the mask after
> >>
> >> 	tsk->mems_allowed = *newmems;
> >>
> >> unless we use lock.
> >>
> >> Maybe we need a rw-lock to protect task->mems_allowed.
> >>
> > 
> > I meant that we need to define synchronization only for configurations 
> > that do not do atomic nodemask_t stores, it's otherwise unnecessary.  
> > We'll need to load and store tsk->mems_allowed via a helper function that 
> > is defined to take the rwlock for such configs and only read/write the 
> > nodemask for others.
> > 
> 
> By investigating, we found that it is hard to guarantee the consistent between
> mempolicy and mems_allowed because mempolicy was designed as a self-update function.
> it just can be changed by one's self. Maybe we must change the implement of mempolicy.
> 

Before your change, cpuset nodemask changes were serialized on 
manage_mutex which would, in turn, serialize the rebinding of each 
attached task's mempolicy.  update_nodemask() is now serialized on 
cgroup_lock(), which also protects scan_for_empty_cpusets(), so the cpuset 
code protects it adequately.  If a concurrent mempolicy change from a 
user's set_mempolicy() happens, however, it could introduce an 
inconsistency between them.

If we protect current->mems_allowed with a rwlock or seqlock for configs 
where MAX_NUMNODES > BITS_PER_LONG, then we can always guarantee that we 
get the entire nodemask.  The same problem is present for 
current->cpus_allowed, however, with NR_CPUS > BITS_PER_LONG.  We must be 
able to safely dereference both masks without the chance of returning 
nodes_empty() or cpus_empty().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
