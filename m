Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16CD88E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:38:44 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id d3so15186482pgv.23
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:38:44 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p11si31508288plk.191.2018.12.26.05.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Message-Id: <20181226133352.076749877@intel.com>
Date: Wed, 26 Dec 2018 21:15:03 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 17/21] proc: introduce /proc/PID/idle_pages
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0008-proc-introduce-proc-PID-idle_pages.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

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
 fs/proc/base.c     |    2 +
 fs/proc/internal.h |    1 
 fs/proc/task_mmu.c |   54 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 57 insertions(+)

--- linux.orig/fs/proc/base.c	2018-12-23 20:08:14.228919325 +0800
+++ linux/fs/proc/base.c	2018-12-23 20:08:14.224919327 +0800
@@ -2969,6 +2969,7 @@ static const struct pid_entry tgid_base_
 	REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
 	REG("smaps_rollup", S_IRUGO, proc_pid_smaps_rollup_operations),
 	REG("pagemap",    S_IRUSR, proc_pagemap_operations),
+	REG("idle_pages", S_IRUSR|S_IWUSR, proc_mm_idle_operations),
 #endif
 #ifdef CONFIG_SECURITY
 	DIR("attr",       S_IRUGO|S_IXUGO, proc_attr_dir_inode_operations, proc_attr_dir_operations),
@@ -3357,6 +3358,7 @@ static const struct pid_entry tid_base_s
 	REG("smaps",     S_IRUGO, proc_pid_smaps_operations),
 	REG("smaps_rollup", S_IRUGO, proc_pid_smaps_rollup_operations),
 	REG("pagemap",    S_IRUSR, proc_pagemap_operations),
+	REG("idle_pages", S_IRUSR|S_IWUSR, proc_mm_idle_operations),
 #endif
 #ifdef CONFIG_SECURITY
 	DIR("attr",      S_IRUGO|S_IXUGO, proc_attr_dir_inode_operations, proc_attr_dir_operations),
--- linux.orig/fs/proc/internal.h	2018-12-23 20:08:14.228919325 +0800
+++ linux/fs/proc/internal.h	2018-12-23 20:08:14.224919327 +0800
@@ -298,6 +298,7 @@ extern const struct file_operations proc
 extern const struct file_operations proc_pid_smaps_rollup_operations;
 extern const struct file_operations proc_clear_refs_operations;
 extern const struct file_operations proc_pagemap_operations;
+extern const struct file_operations proc_mm_idle_operations;
 
 extern unsigned long task_vsize(struct mm_struct *);
 extern unsigned long task_statm(struct mm_struct *,
--- linux.orig/fs/proc/task_mmu.c	2018-12-23 20:08:14.228919325 +0800
+++ linux/fs/proc/task_mmu.c	2018-12-23 20:08:14.224919327 +0800
@@ -1559,6 +1559,60 @@ const struct file_operations proc_pagema
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
+	if (proc_ept_idle_operations.read)
+		return proc_ept_idle_operations.read(file, buf, count, ppos);
+
+	return 0;
+}
+
+
+static int mm_idle_open(struct inode *inode, struct file *file)
+{
+	struct mm_struct *mm = proc_mem_open(inode, PTRACE_MODE_READ);
+
+	if (IS_ERR(mm))
+		return PTR_ERR(mm);
+
+	file->private_data = mm;
+
+	if (proc_ept_idle_operations.open)
+		return proc_ept_idle_operations.open(inode, file);
+
+	return 0;
+}
+
+static int mm_idle_release(struct inode *inode, struct file *file)
+{
+	struct mm_struct *mm = file->private_data;
+
+	if (mm) {
+		if (!mm_kvm(mm))
+			flush_tlb_mm(mm);
+		mmdrop(mm);
+	}
+
+	if (proc_ept_idle_operations.release)
+		return proc_ept_idle_operations.release(inode, file);
+
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
