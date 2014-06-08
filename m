Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7EF6B0031
	for <linux-mm@kvack.org>; Sun,  8 Jun 2014 18:47:05 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id rl12so5126538iec.35
        for <linux-mm@kvack.org>; Sun, 08 Jun 2014 15:47:05 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id o8si30451321ick.58.2014.06.08.15.47.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 08 Jun 2014 15:47:04 -0700 (PDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so3203950igb.14
        for <linux-mm@kvack.org>; Sun, 08 Jun 2014 15:47:04 -0700 (PDT)
Date: Sun, 8 Jun 2014 15:47:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/mempolicy: fix sleeping function called from invalid
 context
In-Reply-To: <539192F1.7050308@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1406081539140.21744@chino.kir.corp.google.com>
References: <53902A44.50005@cn.fujitsu.com> <20140605132339.ddf6df4a0cf5c14d17eb8691@linux-foundation.org> <539192F1.7050308@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, stable@vger.kernel.org, Li Zefan <lizefan@huawei.com>

On Fri, 6 Jun 2014, Gu Zheng wrote:

> >> When running with the kernel(3.15-rc7+), the follow bug occurs:
> >> [ 9969.258987] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:586
> >> [ 9969.359906] in_atomic(): 1, irqs_disabled(): 0, pid: 160655, name: python
> >> [ 9969.441175] INFO: lockdep is turned off.
> >> [ 9969.488184] CPU: 26 PID: 160655 Comm: python Tainted: G       A      3.15.0-rc7+ #85
> >> [ 9969.581032] Hardware name: FUJITSU-SV PRIMEQUEST 1800E/SB, BIOS PRIMEQUEST 1000 Series BIOS Version 1.39 11/16/2012
> >> [ 9969.706052]  ffffffff81a20e60 ffff8803e941fbd0 ffffffff8162f523 ffff8803e941fd18
> >> [ 9969.795323]  ffff8803e941fbe0 ffffffff8109995a ffff8803e941fc58 ffffffff81633e6c
> >> [ 9969.884710]  ffffffff811ba5dc ffff880405c6b480 ffff88041fdd90a0 0000000000002000
> >> [ 9969.974071] Call Trace:
> >> [ 9970.003403]  [<ffffffff8162f523>] dump_stack+0x4d/0x66
> >> [ 9970.065074]  [<ffffffff8109995a>] __might_sleep+0xfa/0x130
> >> [ 9970.130743]  [<ffffffff81633e6c>] mutex_lock_nested+0x3c/0x4f0
> >> [ 9970.200638]  [<ffffffff811ba5dc>] ? kmem_cache_alloc+0x1bc/0x210
> >> [ 9970.272610]  [<ffffffff81105807>] cpuset_mems_allowed+0x27/0x140
> >> [ 9970.344584]  [<ffffffff811b1303>] ? __mpol_dup+0x63/0x150
> >> [ 9970.409282]  [<ffffffff811b1385>] __mpol_dup+0xe5/0x150
> >> [ 9970.471897]  [<ffffffff811b1303>] ? __mpol_dup+0x63/0x150
> >> [ 9970.536585]  [<ffffffff81068c86>] ? copy_process.part.23+0x606/0x1d40
> >> [ 9970.613763]  [<ffffffff810bf28d>] ? trace_hardirqs_on+0xd/0x10
> >> [ 9970.683660]  [<ffffffff810ddddf>] ? monotonic_to_bootbased+0x2f/0x50
> >> [ 9970.759795]  [<ffffffff81068cf0>] copy_process.part.23+0x670/0x1d40
> >> [ 9970.834885]  [<ffffffff8106a598>] do_fork+0xd8/0x380
> >> [ 9970.894375]  [<ffffffff81110e4c>] ? __audit_syscall_entry+0x9c/0xf0
> >> [ 9970.969470]  [<ffffffff8106a8c6>] SyS_clone+0x16/0x20
> >> [ 9971.030011]  [<ffffffff81642009>] stub_clone+0x69/0x90
> >> [ 9971.091573]  [<ffffffff81641c29>] ? system_call_fastpath+0x16/0x1b
> >>
> >> The cause is that cpuset_mems_allowed() try to take mutex_lock(&callback_mutex)
> >> under the rcu_read_lock(which was hold in __mpol_dup()). And in cpuset_mems_allowed(),
> >> the access to cpuset is under rcu_read_lock, so in __mpol_dup, we can reduce the
> >> rcu_read_lock protection region to protect the access to cpuset only in
> >> current_cpuset_is_being_rebound(). So that we can avoid this bug.
> >>
> >> ...
> >>
> >> --- a/kernel/cpuset.c
> >> +++ b/kernel/cpuset.c
> >> @@ -1188,7 +1188,13 @@ done:
> >>  
> >>  int current_cpuset_is_being_rebound(void)
> >>  {
> >> -	return task_cs(current) == cpuset_being_rebound;
> >> +	int ret;
> >> +
> >> +	rcu_read_lock();
> >> +	ret = task_cs(current) == cpuset_being_rebound;
> >> +	rcu_read_unlock();
> >> +
> >> +	return ret;
> >>  }
> > 
> > Looks fishy to me.  If the rcu_read_lock() stabilizes
> > cpuset_being_rebound then cpuset_being_rebound can change immediately
> > after rcu_read_unlock() and `ret' is now wrong.
> 
> IMO, whether cpuset_being_rebound changed or not is immaterial here, we
> just want to know whether the cpuset is being rebound at that point.
> 

I think your patch addresses the problem that you're reporting but misses 
the larger problem with cpuset.mems rebinding on fork().  When the 
forker's task_struct is duplicated (which includes ->mems_allowed) and it 
races with an update to cpuset_being_rebound in update_tasks_nodemask() 
then the task's mems_allowed doesn't get updated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
