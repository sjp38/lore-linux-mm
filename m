Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 651B16B5FD8
	for <linux-mm@kvack.org>; Sat,  1 Sep 2018 22:21:10 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r20-v6so8862753pgv.20
        for <linux-mm@kvack.org>; Sat, 01 Sep 2018 19:21:10 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x19-v6si12798679pgf.477.2018.09.01.19.21.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Sep 2018 19:21:09 -0700 (PDT)
Message-Id: <20180901124811.530300789@intel.com>
Date: Sat, 01 Sep 2018 19:28:20 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH 2/5] [PATCH 2/5] proc: introduce /proc/PID/idle_bitmap
References: <20180901112818.126790961@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0002-proc-introduce-proc-PID-idle_bitmap.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, Fengguang Wu <fengguang.wu@intel.com>, Peng DongX <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

This will be similar to /sys/kernel/mm/page_idle/bitmap documented in
Documentation/admin-guide/mm/idle_page_tracking.rst, however indexed
by process virtual address.

When using the global PFN indexed idle bitmap, we find 2 kind of
overheads:

- to track a task's working set, Brendan Gregg end up writing wss-v1
  for small tasks and wss-v2 for large tasks:

  https://github.com/brendangregg/wss

  That's because VAs may point to random PAs throughout the physical
  address space. So we either query /proc/pid/pagemap first and access
  the lots of random PFNs (with lots of syscalls) in the bitmap, or
  write+read the whole system idle bitmap beforehand.

- page table walking by PFN has much more overheads than to walk a
  page table in its natural order:
  - rmap queries
  - more locking
  - random memory reads/writes

This interface provides a cheap path for the majority non-shared mapping
pages. To walk 1TB memory of 4k active pages, it costs 2s vs 15s system
time to scan the per-task/global idle bitmaps. Which means ~7x speedup.
The gap will be enlarged if consider

- the extra /proc/pid/pagemap walk
- natural page table walks can skip the whole 512 PTEs if PMD is idle

OTOH, the per-task idle bitmap is not suitable in some situations:

- not accurate for shared pages
- don't work with non-mapped file pages
- don't perform well for sparse page tables (pointed out by Huang Ying)

So it's more about complementing the existing global idle bitmap.

CC: Huang Ying <ying.huang@intel.com>
CC: Brendan Gregg <bgregg@netflix.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 fs/proc/base.c     |  2 ++
 fs/proc/internal.h |  1 +
 fs/proc/task_mmu.c | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index aaffc0c30216..d81322b5b8d2 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2942,6 +2942,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
 	REG("smaps_rollup", S_IRUGO, proc_pid_smaps_rollup_operations),
 	REG("pagemap",    S_IRUSR, proc_pagemap_operations),
+	REG("idle_bitmap", S_IRUSR|S_IWUSR, proc_mm_idle_operations),
 #endif
 #ifdef CONFIG_SECURITY
 	DIR("attr",       S_IRUGO|S_IXUGO, proc_attr_dir_inode_operations, proc_attr_dir_operations),
@@ -3327,6 +3328,7 @@ static const struct pid_entry tid_base_stuff[] = {
 	REG("smaps",     S_IRUGO, proc_tid_smaps_operations),
 	REG("smaps_rollup", S_IRUGO, proc_pid_smaps_rollup_operations),
 	REG("pagemap",    S_IRUSR, proc_pagemap_operations),
+	REG("idle_bitmap", S_IRUSR|S_IWUSR, proc_mm_idle_operations),
 #endif
 #ifdef CONFIG_SECURITY
 	DIR("attr",      S_IRUGO|S_IXUGO, proc_attr_dir_inode_operations, proc_attr_dir_operations),
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index da3dbfa09e79..732a502acc27 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -305,6 +305,7 @@ extern const struct file_operations proc_pid_smaps_rollup_operations;
 extern const struct file_operations proc_tid_smaps_operations;
 extern const struct file_operations proc_clear_refs_operations;
 extern const struct file_operations proc_pagemap_operations;
+extern const struct file_operations proc_mm_idle_operations;
 
 extern unsigned long task_vsize(struct mm_struct *);
 extern unsigned long task_statm(struct mm_struct *,
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dfd73a4616ce..376406a9cf45 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1564,6 +1564,69 @@ const struct file_operations proc_pagemap_operations = {
 	.open		= pagemap_open,
 	.release	= pagemap_release,
 };
+
+/* will be filled when kvm_ept_idle module loads */
+struct file_operations proc_ept_idle_operations = {
+};
+EXPORT_SYMBOL_GPL(proc_ept_idle_operations);
+
+static ssize_t mm_idle_read(struct file *file, char __user *buf,
+			    size_t count, loff_t *ppos)
+{
+	struct task_struct *task = file->private_data;
+	ssize_t ret = -ESRCH;
+
+	// TODO: implement mm_walk for normal tasks
+
+	if (task_kvm(task)) {
+		if (proc_ept_idle_operations.read)
+			return proc_ept_idle_operations.read(file, buf, count, ppos);
+	}
+
+	return ret;
+}
+
+
+static int mm_idle_open(struct inode *inode, struct file *file)
+{
+	struct task_struct *task = get_proc_task(inode);
+
+	if (!task)
+		return -ESRCH;
+
+	file->private_data = task;
+
+	if (task_kvm(task)) {
+		if (proc_ept_idle_operations.open)
+			return proc_ept_idle_operations.open(inode, file);
+	}
+
+	return 0;
+}
+
+static int mm_idle_release(struct inode *inode, struct file *file)
+{
+	struct task_struct *task = file->private_data;
+
+	if (!task)
+		return 0;
+
+	if (task_kvm(task)) {
+		if (proc_ept_idle_operations.release)
+			return proc_ept_idle_operations.release(inode, file);
+	}
+
+	put_task_struct(task);
+	return 0;
+}
+
+const struct file_operations proc_mm_idle_operations = {
+	.llseek		= mem_lseek, /* borrow this */
+	.read		= mm_idle_read,
+	.open		= mm_idle_open,
+	.release	= mm_idle_release,
+};
+
 #endif /* CONFIG_PROC_PAGE_MONITOR */
 
 #ifdef CONFIG_NUMA
-- 
2.15.0
