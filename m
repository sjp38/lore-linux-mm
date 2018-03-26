Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A74E6B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 17:11:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s8so10064870pgf.0
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:11:21 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id e6si10456200pgt.680.2018.03.26.14.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 14:11:19 -0700 (PDT)
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180326194210.7bf6u2wo44oh4n7z@mguzik>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <81f12069-6ac7-a2c8-a87f-5170a9508780@linux.alibaba.com>
Date: Mon, 26 Mar 2018 17:10:57 -0400
MIME-Version: 1.0
In-Reply-To: <20180326194210.7bf6u2wo44oh4n7z@mguzik>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mateusz Guzik <mguzik@redhat.com>
Cc: adobriyan@gmail.com, mhocko@kernel.org, willy@infradead.org, gorcunov@openvz.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/26/18 3:42 PM, Mateusz Guzik wrote:
> On Tue, Mar 27, 2018 at 02:20:39AM +0800, Yang Shi wrote:
>> mmap_sem is on the hot path of kernel, and it very contended, but it is
>> abused too. It is used to protect arg_start|end and evn_start|end when
>> reading /proc/$PID/cmdline and /proc/$PID/environ, but it doesn't make
>> sense since those proc files just expect to read 4 values atomically and
>> not related to VM, they could be set to arbitrary values by C/R.
>>
> They are not arbitrary - there is basic validation performed when
> setting them.
>
>> And, the mmap_sem contention may cause unexpected issue like below:
>>
>> INFO: task ps:14018 blocked for more than 120 seconds.
>>         Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>>   "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>> message.
>>   ps              D    0 14018      1 0x00000004
>>    ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
>>    ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
>>    00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
>>   Call Trace:
>>    [<ffffffff817154d0>] ? __schedule+0x250/0x730
>>    [<ffffffff817159e6>] schedule+0x36/0x80
>>    [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
>>    [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
>>    [<ffffffff81717db0>] down_read+0x20/0x40
>>    [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
>>    [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
>>    [<ffffffff81241d87>] __vfs_read+0x37/0x150
>>    [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
>>    [<ffffffff81242266>] vfs_read+0x96/0x130
>>    [<ffffffff812437b5>] SyS_read+0x55/0xc0
>>    [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5
>>
>> Both Alexey Dobriyan and Michal Hocko suggested to use dedicated lock
>> for them to mitigate the abuse of mmap_sem.
>>
> While switching to arg spinlock here will relieve mmap_sem to an extent,
> it wont help with the problem you are seeing here.
>
> proc_pid_cmdline_read -> access_process_vm -> __access_remote_vm and you
> got yet another down_read(&mm->mmap_sem);.
>
> i.e. the issue you ran into is well known and predates my change.
>
> The problem does not stem from contention either, but blocking for a
> long time while holding the lock - the most common example is dealing
> with dead nfs mount vs mmaped areas.
>
> I don't have good ideas how to fix the problem. The least bad I came up
> with was to trylock with a timeout - after a failure either return an
> error or resort to returning p_comm. ps/top could be modified to
> fallback to snatching the name from /status.
>
> Since the lock owner is now being stored in the semaphore, perhaps the
> above routine can happily spin until it grabs the lock or the owner is
> detected to have gone into uninterruptible sleep and react accordingly.
>
> I don't know whether it is feasible to somehow avoid the mmap lock
> altogether.
>
> If it has to be there no matter what the code can be refactored to grab
> it once and relock only if copyout would fault. This would in particular
> reduce the number of times it is taken to begin with and still provide
> the current synchronisation against prctl. But the fundamental problem
> will remain.
>
> That said, refactoring above will have the same effect as your patch and
> will avoid growing mm_struct.
>
> That's my $0,03. MM overlords have to comment on what to do with this.

Thanks for the comment. Yes, the spin lock absolutely can't solve all 
the mmap_sem scalability issue. Actually, I already proposed a 
preliminary RFC to try to mitigate the mmap_sem issue. It is still under 
review.

Other than that, we also found mmap_sem is abused somewhere, so this 
patch is proposed to reduce the abuse to mmap_sem.

Yang

>
>> So, introduce a new spinlock in mm_struct to protect the concurrent access
>> to arg_start|end and env_start|end.
>>
>> And, commit ddf1d398e517e660207e2c807f76a90df543a217 ("prctl: take mmap
>> sem for writing to protect against others") changed down_read to
>> down_write to avoid write race condition in prctl_set_mm(). Since we
>> already have dedicated lock to protect them, it is safe to change back
>> to down_read.
>>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> Cc: Alexey Dobriyan <adobriyan@gmail.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Mateusz Guzik <mguzik@redhat.com>
>> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
>> ---
>> v1 --> v2:
>> * Use spinlock instead of rwlock per Mattew's suggestion
>> * Replace down_write to down_read in prctl_set_mm (see commit log for details)
>>
>>   fs/proc/base.c           |  8 ++++----
>>   include/linux/mm_types.h |  2 ++
>>   kernel/fork.c            |  1 +
>>   kernel/sys.c             | 14 ++++++++++----
>>   mm/init-mm.c             |  1 +
>>   5 files changed, 18 insertions(+), 8 deletions(-)
>>
>> diff --git a/fs/proc/base.c b/fs/proc/base.c
>> index 9298324..e0282b6 100644
>> --- a/fs/proc/base.c
>> +++ b/fs/proc/base.c
>> @@ -242,12 +242,12 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
>>   		goto out_mmput;
>>   	}
>>   
>> -	down_read(&mm->mmap_sem);
>> +	spin_lock(&mm->arg_lock);
>>   	arg_start = mm->arg_start;
>>   	arg_end = mm->arg_end;
>>   	env_start = mm->env_start;
>>   	env_end = mm->env_end;
>> -	up_read(&mm->mmap_sem);
>> +	spin_unlock(&mm->arg_lock);
>>   
>>   	BUG_ON(arg_start > arg_end);
>>   	BUG_ON(env_start > env_end);
>> @@ -929,10 +929,10 @@ static ssize_t environ_read(struct file *file, char __user *buf,
>>   	if (!mmget_not_zero(mm))
>>   		goto free;
>>   
>> -	down_read(&mm->mmap_sem);
>> +	spin_lock(&mm->arg_lock);
>>   	env_start = mm->env_start;
>>   	env_end = mm->env_end;
>> -	up_read(&mm->mmap_sem);
>> +	spin_unlock(&mm->arg_lock);
>>   
>>   	while (count > 0) {
>>   		size_t this_len, max_len;
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index fd1af6b..3be4588 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -413,6 +413,8 @@ struct mm_struct {
>>   	unsigned long def_flags;
>>   	unsigned long start_code, end_code, start_data, end_data;
>>   	unsigned long start_brk, brk, start_stack;
>> +
>> +	spinlock_t arg_lock; /* protect concurrent access to arg_* and env_* */
>>   	unsigned long arg_start, arg_end, env_start, env_end;
>>   
>>   	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index e5d9d40..6540ae7 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -898,6 +898,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
>>   	mm->pinned_vm = 0;
>>   	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
>>   	spin_lock_init(&mm->page_table_lock);
>> +	spin_lock_init(&mm->arg_lock);
>>   	mm_init_cpumask(mm);
>>   	mm_init_aio(mm);
>>   	mm_init_owner(mm, p);
>> diff --git a/kernel/sys.c b/kernel/sys.c
>> index f2289de..17bddd2 100644
>> --- a/kernel/sys.c
>> +++ b/kernel/sys.c
>> @@ -1959,7 +1959,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>   			return error;
>>   	}
>>   
>> -	down_write(&mm->mmap_sem);
>> +	down_read(&mm->mmap_sem);
>>   
>>   	/*
>>   	 * We don't validate if these members are pointing to
>> @@ -1980,10 +1980,13 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>   	mm->start_brk	= prctl_map.start_brk;
>>   	mm->brk		= prctl_map.brk;
>>   	mm->start_stack	= prctl_map.start_stack;
>> +
>> +	spin_lock(&mm->arg_lock);
>>   	mm->arg_start	= prctl_map.arg_start;
>>   	mm->arg_end	= prctl_map.arg_end;
>>   	mm->env_start	= prctl_map.env_start;
>>   	mm->env_end	= prctl_map.env_end;
>> +	spin_unlock(&mm->arg_lock);
>>   
>>   	/*
>>   	 * Note this update of @saved_auxv is lockless thus
>> @@ -1996,7 +1999,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>   	if (prctl_map.auxv_size)
>>   		memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
>>   
>> -	up_write(&mm->mmap_sem);
>> +	up_read(&mm->mmap_sem);
>>   	return 0;
>>   }
>>   #endif /* CONFIG_CHECKPOINT_RESTORE */
>> @@ -2063,7 +2066,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
>>   
>>   	error = -EINVAL;
>>   
>> -	down_write(&mm->mmap_sem);
>> +	down_read(&mm->mmap_sem);
>>   	vma = find_vma(mm, addr);
>>   
>>   	prctl_map.start_code	= mm->start_code;
>> @@ -2149,14 +2152,17 @@ static int prctl_set_mm(int opt, unsigned long addr,
>>   	mm->start_brk	= prctl_map.start_brk;
>>   	mm->brk		= prctl_map.brk;
>>   	mm->start_stack	= prctl_map.start_stack;
>> +
>> +	spin_lock(&mm->arg_lock);
>>   	mm->arg_start	= prctl_map.arg_start;
>>   	mm->arg_end	= prctl_map.arg_end;
>>   	mm->env_start	= prctl_map.env_start;
>>   	mm->env_end	= prctl_map.env_end;
>> +	spin_unlock(&mm->arg_lock);
>>   
>>   	error = 0;
>>   out:
>> -	up_write(&mm->mmap_sem);
>> +	up_read(&mm->mmap_sem);
>>   	return error;
>>   }
>>   
>> diff --git a/mm/init-mm.c b/mm/init-mm.c
>> index f94d5d1..66cce4c 100644
>> --- a/mm/init-mm.c
>> +++ b/mm/init-mm.c
>> @@ -23,6 +23,7 @@ struct mm_struct init_mm = {
>>   	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
>>   	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
>>   	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
>> +	.arg_lock	= __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
>>   	.user_ns	= &init_user_ns,
>>   	INIT_MM_CONTEXT(init_mm)
>>   };
>> -- 
>> 1.8.3.1
>>
