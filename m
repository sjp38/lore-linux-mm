Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC75A6B000E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 20:36:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p10so7519671pfl.22
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 17:36:36 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id f10-v6si8476329pln.359.2018.03.23.17.36.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 17:36:35 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH] mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct
Date: Sat, 24 Mar 2018 08:36:11 +0800
Message-Id: <1521851771-108673-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adobriyan@gmail.com, mhocko@kernel.org, akpm@linux-foundation.org
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

So, introduce a new rwlock in mm_struct to protect the concurrent access
to arg_start|end and env_start|end.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>
---
 fs/proc/base.c           | 8 ++++----
 include/linux/mm_types.h | 2 ++
 kernel/fork.c            | 1 +
 kernel/sys.c             | 6 ++++++
 mm/init-mm.c             | 1 +
 5 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 28fa852..0bc3107 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -239,12 +239,12 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 		goto out_mmput;
 	}
 
-	down_read(&mm->mmap_sem);
+	read_lock(&mm->arg_lock);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	read_unlock(&mm->arg_lock);
 
 	BUG_ON(arg_start > arg_end);
 	BUG_ON(env_start > env_end);
@@ -926,10 +926,10 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	if (!mmget_not_zero(mm))
 		goto free;
 
-	down_read(&mm->mmap_sem);
+	read_lock(&mm->arg_lock);
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	read_unlock(&mm->arg_lock);
 
 	while (count > 0) {
 		size_t this_len, max_len;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cfd0ac4..92bd9cc 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -419,6 +419,8 @@ struct mm_struct {
 	unsigned long def_flags;
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
+
+	rwlock_t arg_lock; /* protect concurrent access to arg_* and env_* */
 	unsigned long arg_start, arg_end, env_start, env_end;
 
 	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
diff --git a/kernel/fork.c b/kernel/fork.c
index 432eadf..94cdf28 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -823,6 +823,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->pinned_vm = 0;
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
+	rwlock_init(&mm->arg_lock);
 	mm_init_cpumask(mm);
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
diff --git a/kernel/sys.c b/kernel/sys.c
index 83ffd7d..de357e1 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1980,10 +1980,13 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	mm->start_brk	= prctl_map.start_brk;
 	mm->brk		= prctl_map.brk;
 	mm->start_stack	= prctl_map.start_stack;
+
+	write_lock(&mm->arg_lock);
 	mm->arg_start	= prctl_map.arg_start;
 	mm->arg_end	= prctl_map.arg_end;
 	mm->env_start	= prctl_map.env_start;
 	mm->env_end	= prctl_map.env_end;
+	write_unlock(&mm->arg_lock);
 
 	/*
 	 * Note this update of @saved_auxv is lockless thus
@@ -2149,10 +2152,13 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	mm->start_brk	= prctl_map.start_brk;
 	mm->brk		= prctl_map.brk;
 	mm->start_stack	= prctl_map.start_stack;
+
+	write_lock(&mm->arg_lock);
 	mm->arg_start	= prctl_map.arg_start;
 	mm->arg_end	= prctl_map.arg_end;
 	mm->env_start	= prctl_map.env_start;
 	mm->env_end	= prctl_map.env_end;
+	write_unlock(&mm->arg_lock);
 
 	error = 0;
 out:
diff --git a/mm/init-mm.c b/mm/init-mm.c
index f94d5d1..5b2a044 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -23,6 +23,7 @@ struct mm_struct init_mm = {
 	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
+	.arg_lock	= __RW_LOCK_UNLOCKED(init_mm.arg_lock),
 	.user_ns	= &init_user_ns,
 	INIT_MM_CONTEXT(init_mm)
 };
-- 
1.8.3.1
