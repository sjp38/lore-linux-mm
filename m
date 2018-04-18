Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBDAD6B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:48:41 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f3-v6so1491624plf.1
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:48:41 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id z5si1445361pgp.671.2018.04.18.11.48.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 11:48:40 -0700 (PDT)
Subject: Re: [v4 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1523730291-109696-1-git-send-email-yang.shi@linux.alibaba.com>
 <2697a481-b4ea-9d24-5df8-a30cd7dbdb8c@virtuozzo.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <79741293-22de-2f77-ab6b-9ea8f5cd43c5@linux.alibaba.com>
Date: Wed, 18 Apr 2018 11:48:28 -0700
MIME-Version: 1.0
In-Reply-To: <2697a481-b4ea-9d24-5df8-a30cd7dbdb8c@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>, adobriyan@gmail.com, mhocko@kernel.org, willy@infradead.org, mguzik@redhat.com, gorcunov@gmail.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/18/18 3:11 AM, Kirill Tkhai wrote:
> On 14.04.2018 21:24, Yang Shi wrote:
>> mmap_sem is on the hot path of kernel, and it very contended, but it is
>> abused too. It is used to protect arg_start|end and evn_start|end when
>> reading /proc/$PID/cmdline and /proc/$PID/environ, but it doesn't make
>> sense since those proc files just expect to read 4 values atomically and
>> not related to VM, they could be set to arbitrary values by C/R.
>>
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
>> So, introduce a new spinlock in mm_struct to protect the concurrent
>> access to arg_start|end, env_start|end and others, as well as replace
>> write map_sem to read to protect the race condition between prctl and
>> sys_brk which might break check_data_rlimit(), and makes prctl more
>> friendly to other VM operations.
>>
>> This patch just eliminates the abuse of mmap_sem, but it can't resolve the
>> above hung task warning completely since the later access_remote_vm() call
>> needs acquire mmap_sem. The mmap_sem scalability issue will be solved in the
>> future.
>>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> Cc: Alexey Dobriyan <adobriyan@gmail.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Mateusz Guzik <mguzik@redhat.com>
>> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
>> ---
>> v3 --> v4:
>> * Protected values update with down_read + spin_lock to prevent from race
>>    condition between prctl and sys_brk and made prctl more friendly to VM
>>    operations per Michal's suggestion
>>
>> v2 --> v3:
>> * Restored down_write in prctl syscall
>> * Elaborate the limitation of this patch suggested by Michal
>> * Protect those fields by the new lock except brk and start_brk per Michal's
>>    suggestion
>> * Based off Cyrill's non PR_SET_MM_MAP oprations deprecation patch
>>    (https://lkml.org/lkml/2018/4/5/541)
>>
>> v1 --> v2:
>> * Use spinlock instead of rwlock per Mattew's suggestion
>> * Replace down_write to down_read in prctl_set_mm (see commit log for details)
>>   fs/proc/base.c           | 8 ++++----
>>   include/linux/mm_types.h | 2 ++
>>   kernel/fork.c            | 1 +
>>   kernel/sys.c             | 6 ++++--
>>   mm/init-mm.c             | 1 +
>>   5 files changed, 12 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/proc/base.c b/fs/proc/base.c
>> index eafa39a..3551757 100644
>> --- a/fs/proc/base.c
>> +++ b/fs/proc/base.c
>> @@ -239,12 +239,12 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
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
>> index 2161234..49dd59e 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -413,6 +413,8 @@ struct mm_struct {
>>   	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE & ~VM_STACK */
>>   	unsigned long stack_vm;		/* VM_STACK */
>>   	unsigned long def_flags;
>> +
>> +	spinlock_t arg_lock; /* protect the below fields */
> What the reason is spinlock is used to protect this fields?
> There may be several readers, say, doing "ps axf" and it's
> OK for them to access these fields in parallel. Why should
> we delay them by each other?
>
> rw_lock seems be more suitable for here.

Thanks a lot for the suggestion. We did think about using rwlock, but it 
sounds the benefit might be not worth the overhead. If it turns out 
rwlock is worth, we definitely can change it to rwlock later.

>
>>   	unsigned long start_code, end_code, start_data, end_data;
>>   	unsigned long start_brk, brk, start_stack;
>>   	unsigned long arg_start, arg_end, env_start, env_end;
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index 242c8c9..295f903 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -900,6 +900,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
>>   	mm->pinned_vm = 0;
>>   	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
>>   	spin_lock_init(&mm->page_table_lock);
>> +	spin_lock_init(&mm->arg_lock);
>>   	mm_init_cpumask(mm);
>>   	mm_init_aio(mm);
>>   	mm_init_owner(mm, p);
>> diff --git a/kernel/sys.c b/kernel/sys.c
>> index f16725e..0cc5a1c 100644
>> --- a/kernel/sys.c
>> +++ b/kernel/sys.c
>> @@ -2011,7 +2011,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>   			return error;
>>   	}
>>   
>> -	down_write(&mm->mmap_sem);
>> +	down_read(&mm->mmap_sem);
> This down_read() looks confusing for a reader. Comment to spinlock says it protects the fields:
>
> 	+	spinlock_t arg_lock; /* protect the below fields */
>
> but in real life there is not obvious dependence with sys_brk(), which is nowhere described.
> This hunk protects us from "execution of sys_brk()" and this looks very confusing.
>
> The generic locking theory says, we should protect data and not a function execution.
> Protection of function execution prevents their modification in the future, makes it
> more difficult.

Yes, it is used to protect data. As I mentioned in the commit log, 
check_data_rlimit() use brk, start_brk, start_data and end_data to check 
if the address space is beyond the limit. But, prctl may modify them at 
the same time.

>
> Can we take write_lock() (after we introduce it instead of spinlock) in sys_brk()
> and make the locking scheme more visible and intuitive?

Take a lock for what? Do you mean replace mmap_sem to the lock?

Thanks,
Yang

>
>>   
>>   	/*
>>   	 * We don't validate if these members are pointing to
>> @@ -2025,6 +2025,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>   	 *    to any problem in kernel itself
>>   	 */
>>   
>> +	spin_lock(&mm->arg_lock);
>>   	mm->start_code	= prctl_map.start_code;
>>   	mm->end_code	= prctl_map.end_code;
>>   	mm->start_data	= prctl_map.start_data;
>> @@ -2036,6 +2037,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>   	mm->arg_end	= prctl_map.arg_end;
>>   	mm->env_start	= prctl_map.env_start;
>>   	mm->env_end	= prctl_map.env_end;
>> +	spin_unlock(&mm->arg_lock);
>>   
>>   	/*
>>   	 * Note this update of @saved_auxv is lockless thus
>> @@ -2048,7 +2050,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>   	if (prctl_map.auxv_size)
>>   		memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
>>   
>> -	up_write(&mm->mmap_sem);
>> +	up_read(&mm->mmap_sem);
>>   	return 0;
>>   }
>>   #endif /* CONFIG_CHECKPOINT_RESTORE */
>> diff --git a/mm/init-mm.c b/mm/init-mm.c
>> index f94d5d1..f0179c9 100644
>> --- a/mm/init-mm.c
>> +++ b/mm/init-mm.c
>> @@ -22,6 +22,7 @@ struct mm_struct init_mm = {
>>   	.mm_count	= ATOMIC_INIT(1),
>>   	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
>>   	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
>> +	.arg_lock	=  __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
>>   	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
>>   	.user_ns	= &init_user_ns,
>>   	INIT_MM_CONTEXT(init_mm)
> Kirill
