Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0156B0039
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 10:18:42 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id g10so1144761pdj.36
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 07:18:42 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id oy9si13015648pbc.166.2014.06.05.07.18.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jun 2014 07:18:41 -0700 (PDT)
Date: Thu, 5 Jun 2014 07:18:33 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] mm/mempolicy: fix sleeping function called from invalid
 context
Message-ID: <20140605141833.GA26830@kroah.com>
References: <53902A44.50005@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53902A44.50005@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, stable@vger.kernel.org

On Thu, Jun 05, 2014 at 04:28:52PM +0800, Gu Zheng wrote:
> When running with the kernel(3.15-rc7+), the follow bug occurs:
> [ 9969.258987] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:586
> [ 9969.359906] in_atomic(): 1, irqs_disabled(): 0, pid: 160655, name: python
> [ 9969.441175] INFO: lockdep is turned off.
> [ 9969.488184] CPU: 26 PID: 160655 Comm: python Tainted: G       A      3.15.0-rc7+ #85
> [ 9969.581032] Hardware name: FUJITSU-SV PRIMEQUEST 1800E/SB, BIOS PRIMEQUEST 1000 Series BIOS Version 1.39 11/16/2012
> [ 9969.706052]  ffffffff81a20e60 ffff8803e941fbd0 ffffffff8162f523 ffff8803e941fd18
> [ 9969.795323]  ffff8803e941fbe0 ffffffff8109995a ffff8803e941fc58 ffffffff81633e6c
> [ 9969.884710]  ffffffff811ba5dc ffff880405c6b480 ffff88041fdd90a0 0000000000002000
> [ 9969.974071] Call Trace:
> [ 9970.003403]  [<ffffffff8162f523>] dump_stack+0x4d/0x66
> [ 9970.065074]  [<ffffffff8109995a>] __might_sleep+0xfa/0x130
> [ 9970.130743]  [<ffffffff81633e6c>] mutex_lock_nested+0x3c/0x4f0
> [ 9970.200638]  [<ffffffff811ba5dc>] ? kmem_cache_alloc+0x1bc/0x210
> [ 9970.272610]  [<ffffffff81105807>] cpuset_mems_allowed+0x27/0x140
> [ 9970.344584]  [<ffffffff811b1303>] ? __mpol_dup+0x63/0x150
> [ 9970.409282]  [<ffffffff811b1385>] __mpol_dup+0xe5/0x150
> [ 9970.471897]  [<ffffffff811b1303>] ? __mpol_dup+0x63/0x150
> [ 9970.536585]  [<ffffffff81068c86>] ? copy_process.part.23+0x606/0x1d40
> [ 9970.613763]  [<ffffffff810bf28d>] ? trace_hardirqs_on+0xd/0x10
> [ 9970.683660]  [<ffffffff810ddddf>] ? monotonic_to_bootbased+0x2f/0x50
> [ 9970.759795]  [<ffffffff81068cf0>] copy_process.part.23+0x670/0x1d40
> [ 9970.834885]  [<ffffffff8106a598>] do_fork+0xd8/0x380
> [ 9970.894375]  [<ffffffff81110e4c>] ? __audit_syscall_entry+0x9c/0xf0
> [ 9970.969470]  [<ffffffff8106a8c6>] SyS_clone+0x16/0x20
> [ 9971.030011]  [<ffffffff81642009>] stub_clone+0x69/0x90
> [ 9971.091573]  [<ffffffff81641c29>] ? system_call_fastpath+0x16/0x1b
> 
> The cause is that cpuset_mems_allowed() try to take mutex_lock(&callback_mutex)
> under the rcu_read_lock(which was hold in __mpol_dup()). And in cpuset_mems_allowed(),
> the access to cpuset is under rcu_read_lock, so in __mpol_dup, we can reduce the
> rcu_read_lock protection region to protect the access to cpuset only in
> current_cpuset_is_being_rebound(). So that we can avoid this bug.
> 
> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> ---
>  kernel/cpuset.c |    8 +++++++-
>  mm/mempolicy.c  |    2 --
>  2 files changed, 7 insertions(+), 3 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
