Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B6D456B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 17:53:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so5658648pfz.19
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 14:53:19 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id 134si783202pgd.709.2018.04.09.14.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 14:53:17 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v3 PATCH] mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct
Date: Tue, 10 Apr 2018 05:52:54 +0800
Message-Id: <1523310774-40300-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adobriyan@gmail.com, mhocko@kernel.org, willy@infradead.org, mguzik@redhat.com, gorcunov@gmail.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mmap_sem is on the hot path of kernel, and it very contended, but it is
abused too. It is used to protect arg_start|end and evn_start|end when
reading /proc/$PID/cmdline and /proc/$PID/environ, but it doesn't make
sense since those proc files just expect to read 4 values atomically and
not related to VM, they could be set to arbitrary values by C/R.

And, the mmap_sem contention may cause unexpected issue like below:

INFO: task ps:14018 blocked for more than 120 seconds.
       Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
 "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
 ps              D    0 14018      1 0x00000004
  ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
  ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
  00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
 Call Trace:
  [<ffffffff817154d0>] ? __schedule+0x250/0x730
  [<ffffffff817159e6>] schedule+0x36/0x80
  [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
  [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
  [<ffffffff81717db0>] down_read+0x20/0x40
  [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
  [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
  [<ffffffff81241d87>] __vfs_read+0x37/0x150
  [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
  [<ffffffff81242266>] vfs_read+0x96/0x130
  [<ffffffff812437b5>] SyS_read+0x55/0xc0
  [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5

Both Alexey Dobriyan and Michal Hocko suggested to use dedicated lock
for them to mitigate the abuse of mmap_sem.

So, introduce a new spinlock in mm_struct to protect the concurrent
access to arg_start|end, env_start|end and others except start_brk and
brk, which are still protected by mmap_sem to avoid concurrent access
from do_brk().

This patch just eliminates the abuse of mmap_sem, but it can't resolve the
above hung task warning completely since the later access_remote_vm() call
needs acquire mmap_sem. The mmap_sem scalability issue will be solved in the
future.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Mateusz Guzik <mguzik@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
---
v2 --> v3:
* Restored down_write in prctl syscall
* Elaborate the limitation of this patch suggested by Michal
* Protect those fields by the new lock except brk and start_brk per Michal's
  suggestion
* Based off Cyrill's non PR_SET_MM_MAP oprations deprecation patch
  (https://lkml.org/lkml/2018/4/5/541)

v1 --> v2:
* Use spinlock instead of rwlock per Mattew's suggestion
* Replace down_write to down_read in prctl_set_mm (see commit log for details)

 fs/proc/base.c           |  8 ++++----
 include/linux/mm_types.h |  2 ++
 kernel/fork.c            |  1 +
 kernel/sys.c             | 13 ++++++++-----
 mm/init-mm.c             |  1 +
 5 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index d532468..aa7ce07 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -239,12 +239,12 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 		goto out_mmput;
 	}
 
-	down_read(&mm->mmap_sem);
+	spin_lock(&mm->arg_lock);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	spin_unlock(&mm->arg_lock);
 
 	BUG_ON(arg_start > arg_end);
 	BUG_ON(env_start > env_end);
@@ -926,10 +926,10 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	if (!mmget_not_zero(mm))
 		goto free;
 
-	down_read(&mm->mmap_sem);
+	spin_lock(&mm->arg_lock);
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	spin_unlock(&mm->arg_lock);
 
 	while (count > 0) {
 		size_t this_len, max_len;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2161234..26ff7bf 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -413,6 +413,8 @@ struct mm_struct {
 	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE & ~VM_STACK */
 	unsigned long stack_vm;		/* VM_STACK */
 	unsigned long def_flags;
+
+	spinlock_t arg_lock; /* protect the below fields, except brk */
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
 	unsigned long arg_start, arg_end, env_start, env_end;
diff --git a/kernel/fork.c b/kernel/fork.c
index 242c8c9..295f903 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -900,6 +900,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->pinned_vm = 0;
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
+	spin_lock_init(&mm->arg_lock);
 	mm_init_cpumask(mm);
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
diff --git a/kernel/sys.c b/kernel/sys.c
index f16725e..cbac235 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2011,8 +2011,6 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 			return error;
 	}
 
-	down_write(&mm->mmap_sem);
-
 	/*
 	 * We don't validate if these members are pointing to
 	 * real present VMAs because application may have correspond
@@ -2025,17 +2023,23 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	 *    to any problem in kernel itself
 	 */
 
+	/* Hold mmap_sem to avoid concurrent access by do_brk */
+	down_write(&mm->mmap_sem);
+	mm->start_brk	= prctl_map.start_brk;
+	mm->brk		= prctl_map.brk;
+	up_write(&mm->mmap_sem);
+
+	spin_lock(&mm->arg_lock);
 	mm->start_code	= prctl_map.start_code;
 	mm->end_code	= prctl_map.end_code;
 	mm->start_data	= prctl_map.start_data;
 	mm->end_data	= prctl_map.end_data;
-	mm->start_brk	= prctl_map.start_brk;
-	mm->brk		= prctl_map.brk;
 	mm->start_stack	= prctl_map.start_stack;
 	mm->arg_start	= prctl_map.arg_start;
 	mm->arg_end	= prctl_map.arg_end;
 	mm->env_start	= prctl_map.env_start;
 	mm->env_end	= prctl_map.env_end;
+	spin_unlock(&mm->arg_lock);
 
 	/*
 	 * Note this update of @saved_auxv is lockless thus
@@ -2048,7 +2052,6 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	if (prctl_map.auxv_size)
 		memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
 
-	up_write(&mm->mmap_sem);
 	return 0;
 }
 #endif /* CONFIG_CHECKPOINT_RESTORE */
diff --git a/mm/init-mm.c b/mm/init-mm.c
index f94d5d1..f0179c9 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -22,6 +22,7 @@ struct mm_struct init_mm = {
 	.mm_count	= ATOMIC_INIT(1),
 	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
+	.arg_lock	=  __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
 	.user_ns	= &init_user_ns,
 	INIT_MM_CONTEXT(init_mm)
-- 
1.8.3.1
