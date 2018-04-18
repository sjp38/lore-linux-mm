Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA2A46B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 18:59:28 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g12-v6so2953201ioc.3
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 15:59:28 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20118.outbound.protection.outlook.com. [40.107.2.118])
        by mx.google.com with ESMTPS id z62-v6si1997469iod.271.2018.04.18.15.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 15:59:26 -0700 (PDT)
Subject: Re: [v4 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1523730291-109696-1-git-send-email-yang.shi@linux.alibaba.com>
 <2697a481-b4ea-9d24-5df8-a30cd7dbdb8c@virtuozzo.com>
 <79741293-22de-2f77-ab6b-9ea8f5cd43c5@linux.alibaba.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <fec524e9-4299-bd0f-8a21-a7bb6b5d4acc@virtuozzo.com>
Date: Thu, 19 Apr 2018 01:59:10 +0300
MIME-Version: 1.0
In-Reply-To: <79741293-22de-2f77-ab6b-9ea8f5cd43c5@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, adobriyan@gmail.com, mhocko@kernel.org, willy@infradead.org, mguzik@redhat.com, gorcunov@gmail.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 18.04.2018 21:48, Yang Shi wrote:
> 
> 
> On 4/18/18 3:11 AM, Kirill Tkhai wrote:
>> On 14.04.2018 21:24, Yang Shi wrote:
>>> mmap_sem is on the hot path of kernel, and it very contended, but it is
>>> abused too. It is used to protect arg_start|end and evn_start|end when
>>> reading /proc/$PID/cmdline and /proc/$PID/environ, but it doesn't make
>>> sense since those proc files just expect to read 4 values atomically and
>>> not related to VM, they could be set to arbitrary values by C/R.
>>>
>>> And, the mmap_sem contention may cause unexpected issue like below:
>>>
>>> INFO: task ps:14018 blocked for more than 120 seconds.
>>> A A A A A A A  Tainted: GA A A A A A A A A A A  E 4.9.79-009.ali3000.alios7.x86_64 #1
>>> A  "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>>> message.
>>> A  psA A A A A A A A A A A A A  DA A A  0 14018A A A A A  1 0x00000004
>>> A A  ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
>>> A A  ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
>>> A A  00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
>>> A  Call Trace:
>>> A A  [<ffffffff817154d0>] ? __schedule+0x250/0x730
>>> A A  [<ffffffff817159e6>] schedule+0x36/0x80
>>> A A  [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
>>> A A  [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
>>> A A  [<ffffffff81717db0>] down_read+0x20/0x40
>>> A A  [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
>>> A A  [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
>>> A A  [<ffffffff81241d87>] __vfs_read+0x37/0x150
>>> A A  [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
>>> A A  [<ffffffff81242266>] vfs_read+0x96/0x130
>>> A A  [<ffffffff812437b5>] SyS_read+0x55/0xc0
>>> A A  [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5
>>>
>>> Both Alexey Dobriyan and Michal Hocko suggested to use dedicated lock
>>> for them to mitigate the abuse of mmap_sem.
>>>
>>> So, introduce a new spinlock in mm_struct to protect the concurrent
>>> access to arg_start|end, env_start|end and others, as well as replace
>>> write map_sem to read to protect the race condition between prctl and
>>> sys_brk which might break check_data_rlimit(), and makes prctl more
>>> friendly to other VM operations.
>>>
>>> This patch just eliminates the abuse of mmap_sem, but it can't resolve the
>>> above hung task warning completely since the later access_remote_vm() call
>>> needs acquire mmap_sem. The mmap_sem scalability issue will be solved in the
>>> future.
>>>
>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> Cc: Alexey Dobriyan <adobriyan@gmail.com>
>>> Cc: Michal Hocko <mhocko@kernel.org>
>>> Cc: Matthew Wilcox <willy@infradead.org>
>>> Cc: Mateusz Guzik <mguzik@redhat.com>
>>> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
>>> ---
>>> v3 --> v4:
>>> * Protected values update with down_read + spin_lock to prevent from race
>>> A A  condition between prctl and sys_brk and made prctl more friendly to VM
>>> A A  operations per Michal's suggestion
>>>
>>> v2 --> v3:
>>> * Restored down_write in prctl syscall
>>> * Elaborate the limitation of this patch suggested by Michal
>>> * Protect those fields by the new lock except brk and start_brk per Michal's
>>> A A  suggestion
>>> * Based off Cyrill's non PR_SET_MM_MAP oprations deprecation patch
>>> A A  (https://lkml.org/lkml/2018/4/5/541)
>>>
>>> v1 --> v2:
>>> * Use spinlock instead of rwlock per Mattew's suggestion
>>> * Replace down_write to down_read in prctl_set_mm (see commit log for details)
>>> A  fs/proc/base.cA A A A A A A A A A  | 8 ++++----
>>> A  include/linux/mm_types.h | 2 ++
>>> A  kernel/fork.cA A A A A A A A A A A  | 1 +
>>> A  kernel/sys.cA A A A A A A A A A A A  | 6 ++++--
>>> A  mm/init-mm.cA A A A A A A A A A A A  | 1 +
>>> A  5 files changed, 12 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/fs/proc/base.c b/fs/proc/base.c
>>> index eafa39a..3551757 100644
>>> --- a/fs/proc/base.c
>>> +++ b/fs/proc/base.c
>>> @@ -239,12 +239,12 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
>>> A A A A A A A A A  goto out_mmput;
>>> A A A A A  }
>>> A  -A A A  down_read(&mm->mmap_sem);
>>> +A A A  spin_lock(&mm->arg_lock);
>>> A A A A A  arg_start = mm->arg_start;
>>> A A A A A  arg_end = mm->arg_end;
>>> A A A A A  env_start = mm->env_start;
>>> A A A A A  env_end = mm->env_end;
>>> -A A A  up_read(&mm->mmap_sem);
>>> +A A A  spin_unlock(&mm->arg_lock);
>>> A  A A A A A  BUG_ON(arg_start > arg_end);
>>> A A A A A  BUG_ON(env_start > env_end);
>>> @@ -929,10 +929,10 @@ static ssize_t environ_read(struct file *file, char __user *buf,
>>> A A A A A  if (!mmget_not_zero(mm))
>>> A A A A A A A A A  goto free;
>>> A  -A A A  down_read(&mm->mmap_sem);
>>> +A A A  spin_lock(&mm->arg_lock);
>>> A A A A A  env_start = mm->env_start;
>>> A A A A A  env_end = mm->env_end;
>>> -A A A  up_read(&mm->mmap_sem);
>>> +A A A  spin_unlock(&mm->arg_lock);
>>> A  A A A A A  while (count > 0) {
>>> A A A A A A A A A  size_t this_len, max_len;
>>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>>> index 2161234..49dd59e 100644
>>> --- a/include/linux/mm_types.h
>>> +++ b/include/linux/mm_types.h
>>> @@ -413,6 +413,8 @@ struct mm_struct {
>>> A A A A A  unsigned long exec_vm;A A A A A A A  /* VM_EXEC & ~VM_WRITE & ~VM_STACK */
>>> A A A A A  unsigned long stack_vm;A A A A A A A  /* VM_STACK */
>>> A A A A A  unsigned long def_flags;
>>> +
>>> +A A A  spinlock_t arg_lock; /* protect the below fields */
>> What the reason is spinlock is used to protect this fields?
>> There may be several readers, say, doing "ps axf" and it's
>> OK for them to access these fields in parallel. Why should
>> we delay them by each other?
>>
>> rw_lock seems be more suitable for here.
> 
> Thanks a lot for the suggestion. We did think about using rwlock, but it sounds the benefit might be not worth the overhead. If it turns out rwlock is worth, we definitely can change it to rwlock later.

I missed your discussion, and failed to find the overhead details.
Could you please to point that or shortly describe, what is the overhead
of rwlock in comparison to plain spinlock?

>>
>>> A A A A A  unsigned long start_code, end_code, start_data, end_data;
>>> A A A A A  unsigned long start_brk, brk, start_stack;
>>> A A A A A  unsigned long arg_start, arg_end, env_start, env_end;
>>> diff --git a/kernel/fork.c b/kernel/fork.c
>>> index 242c8c9..295f903 100644
>>> --- a/kernel/fork.c
>>> +++ b/kernel/fork.c
>>> @@ -900,6 +900,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
>>> A A A A A  mm->pinned_vm = 0;
>>> A A A A A  memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
>>> A A A A A  spin_lock_init(&mm->page_table_lock);
>>> +A A A  spin_lock_init(&mm->arg_lock);
>>> A A A A A  mm_init_cpumask(mm);
>>> A A A A A  mm_init_aio(mm);
>>> A A A A A  mm_init_owner(mm, p);
>>> diff --git a/kernel/sys.c b/kernel/sys.c
>>> index f16725e..0cc5a1c 100644
>>> --- a/kernel/sys.c
>>> +++ b/kernel/sys.c
>>> @@ -2011,7 +2011,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>> A A A A A A A A A A A A A  return error;
>>> A A A A A  }
>>> A  -A A A  down_write(&mm->mmap_sem);
>>> +A A A  down_read(&mm->mmap_sem);
>> This down_read() looks confusing for a reader. Comment to spinlock says it protects the fields:
>>
>> A A A A +A A A  spinlock_t arg_lock; /* protect the below fields */
>>
>> but in real life there is not obvious dependence with sys_brk(), which is nowhere described.
>> This hunk protects us from "execution of sys_brk()" and this looks very confusing.
>>
>> The generic locking theory says, we should protect data and not a function execution.
>> Protection of function execution prevents their modification in the future, makes it
>> more difficult.
> 
> Yes, it is used to protect data. As I mentioned in the commit log, check_data_rlimit() use brk, start_brk, start_data and end_data to check if the address space is beyond the limit. But, prctl may modify them at the same time.

But sys_brk() does not take the new lock. Prctl protects against sys_brk() via
down_read(), so it's impossible to say a single lock, which protects brk/etc.
This will be a problem if someone decides to implement something on top of this.
Which lock should he/she use to get consistent brk? Both of them.

> 
>>
>> Can we take write_lock() (after we introduce it instead of spinlock) in sys_brk()
>> and make the locking scheme more visible and intuitive?
> 
> Take a lock for what? Do you mean replace mmap_sem to the lock?

No, we should take both of the locks there. mmap_sem will protect
more variables, of course, while the new lock will protect only
brk/etc fields the comment in structure says. Then we'll have the
clear synchronization scheme, and all the locks will protect data,
but not one function against the function execution.

What problems we have to insert the new lock into sys_brk()? Is this
because it's sleepable?

> 
> Thanks,
> Yang
> 
>>
>>> A  A A A A A  /*
>>> A A A A A A  * We don't validate if these members are pointing to
>>> @@ -2025,6 +2025,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>> A A A A A A  *A A A  to any problem in kernel itself
>>> A A A A A A  */
>>> A  +A A A  spin_lock(&mm->arg_lock);
>>> A A A A A  mm->start_codeA A A  = prctl_map.start_code;
>>> A A A A A  mm->end_codeA A A  = prctl_map.end_code;
>>> A A A A A  mm->start_dataA A A  = prctl_map.start_data;
>>> @@ -2036,6 +2037,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>> A A A A A  mm->arg_endA A A  = prctl_map.arg_end;
>>> A A A A A  mm->env_startA A A  = prctl_map.env_start;
>>> A A A A A  mm->env_endA A A  = prctl_map.env_end;
>>> +A A A  spin_unlock(&mm->arg_lock);
>>> A  A A A A A  /*
>>> A A A A A A  * Note this update of @saved_auxv is lockless thus
>>> @@ -2048,7 +2050,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>> A A A A A  if (prctl_map.auxv_size)
>>> A A A A A A A A A  memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
>>> A  -A A A  up_write(&mm->mmap_sem);
>>> +A A A  up_read(&mm->mmap_sem);
>>> A A A A A  return 0;
>>> A  }
>>> A  #endif /* CONFIG_CHECKPOINT_RESTORE */
>>> diff --git a/mm/init-mm.c b/mm/init-mm.c
>>> index f94d5d1..f0179c9 100644
>>> --- a/mm/init-mm.c
>>> +++ b/mm/init-mm.c
>>> @@ -22,6 +22,7 @@ struct mm_struct init_mm = {
>>> A A A A A  .mm_countA A A  = ATOMIC_INIT(1),
>>> A A A A A  .mmap_semA A A  = __RWSEM_INITIALIZER(init_mm.mmap_sem),
>>> A A A A A  .page_table_lock =A  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
>>> +A A A  .arg_lockA A A  =A  __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
>>> A A A A A  .mmlistA A A A A A A  = LIST_HEAD_INIT(init_mm.mmlist),
>>> A A A A A  .user_nsA A A  = &init_user_ns,
>>> A A A A A  INIT_MM_CONTEXT(init_mm)
>> Kirill

Kirill
