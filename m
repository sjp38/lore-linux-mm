Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0C49C6B003B
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 21:09:53 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so2435096pac.11
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 18:09:53 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id hp1si7535046pad.83.2014.06.25.18.09.52
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 18:09:53 -0700 (PDT)
Message-ID: <53AB7030.3030905@cn.fujitsu.com>
Date: Thu, 26 Jun 2014 08:58:24 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] mm/mempolicy: fix sleeping function called from invalid
 context
References: <53AA2C7E.3050707@cn.fujitsu.com> <20140625134345.GA26883@htj.dyndns.org>
In-Reply-To: <20140625134345.GA26883@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, stable@vger.kernel.org, Li Zefan <lizefan@huawei.com>, David Rientjes <rientjes@google.com>

On 06/25/2014 09:43 PM, Tejun Heo wrote:

> On Wed, Jun 25, 2014 at 09:57:18AM +0800, Gu Zheng wrote:
>> When runing with the kernel(3.15-rc7+), the follow bug occurs:
>> [ 9969.258987] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:586
>> [ 9969.359906] in_atomic(): 1, irqs_disabled(): 0, pid: 160655, name: python
>> [ 9969.441175] INFO: lockdep is turned off.
>> [ 9969.488184] CPU: 26 PID: 160655 Comm: python Tainted: G       A      3.15.0-rc7+ #85
>> [ 9969.581032] Hardware name: FUJITSU-SV PRIMEQUEST 1800E/SB, BIOS PRIMEQUEST 1000 Series BIOS Version 1.39 11/16/2012
>> [ 9969.706052]  ffffffff81a20e60 ffff8803e941fbd0 ffffffff8162f523 ffff8803e941fd18
>> [ 9969.795323]  ffff8803e941fbe0 ffffffff8109995a ffff8803e941fc58 ffffffff81633e6c
>> [ 9969.884710]  ffffffff811ba5dc ffff880405c6b480 ffff88041fdd90a0 0000000000002000
>> [ 9969.974071] Call Trace:
>> [ 9970.003403]  [<ffffffff8162f523>] dump_stack+0x4d/0x66
>> [ 9970.065074]  [<ffffffff8109995a>] __might_sleep+0xfa/0x130
>> [ 9970.130743]  [<ffffffff81633e6c>] mutex_lock_nested+0x3c/0x4f0
>> [ 9970.200638]  [<ffffffff811ba5dc>] ? kmem_cache_alloc+0x1bc/0x210
>> [ 9970.272610]  [<ffffffff81105807>] cpuset_mems_allowed+0x27/0x140
>> [ 9970.344584]  [<ffffffff811b1303>] ? __mpol_dup+0x63/0x150
>> [ 9970.409282]  [<ffffffff811b1385>] __mpol_dup+0xe5/0x150
>> [ 9970.471897]  [<ffffffff811b1303>] ? __mpol_dup+0x63/0x150
>> [ 9970.536585]  [<ffffffff81068c86>] ? copy_process.part.23+0x606/0x1d40
>> [ 9970.613763]  [<ffffffff810bf28d>] ? trace_hardirqs_on+0xd/0x10
>> [ 9970.683660]  [<ffffffff810ddddf>] ? monotonic_to_bootbased+0x2f/0x50
>> [ 9970.759795]  [<ffffffff81068cf0>] copy_process.part.23+0x670/0x1d40
>> [ 9970.834885]  [<ffffffff8106a598>] do_fork+0xd8/0x380
>> [ 9970.894375]  [<ffffffff81110e4c>] ? __audit_syscall_entry+0x9c/0xf0
>> [ 9970.969470]  [<ffffffff8106a8c6>] SyS_clone+0x16/0x20
>> [ 9971.030011]  [<ffffffff81642009>] stub_clone+0x69/0x90
>> [ 9971.091573]  [<ffffffff81641c29>] ? system_call_fastpath+0x16/0x1b
>>
>> The cause is that cpuset_mems_allowed() try to take mutex_lock(&callback_mutex)
>> under the rcu_read_lock(which was hold in __mpol_dup()). And in cpuset_mems_allowed(),
>> the access to cpuset is under rcu_read_lock, so in __mpol_dup, we can reduce the
>> rcu_read_lock protection region to protect the access to cpuset only in
>> current_cpuset_is_being_rebound(). So that we can avoid this bug.
>> This patch is a temporary solution that just addresses the bug mentioned above,
>> can not fix the long-standing issue about cpuset.mems rebinding on fork():
>> "
>> When the forker's task_struct is duplicated (which includes ->mems_allowed)
>> and it races with an update to cpuset_being_rebound in update_tasks_nodemask()
>> then the task's mems_allowed doesn't get updated. And the child task's
>> mems_allowed can be wrong if the cpuset's nodemask changes before the
>> child has been added to the cgroup's tasklist.
>> "
>>
>> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
>> Cc: stable <stable@vger.kernel.org>
> 
> Applied to cgroup/for-3.16-fixes w/ minor updates to patch subject and
> description.  Please format the text to 80 columns.  The error
> messages are fine but it's usually nicer to remove the timestamps.

Got it, and thanks for your reminder and suggestion.

Best regards,
Gu

> 
> Thanks.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
