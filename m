Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C144B8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:25:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id n194-v6so5454798itn.0
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:25:04 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id l9-v6si1300698ioj.255.2018.09.12.13.25.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 13:25:03 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [PATCH V2 2/6] Add /proc/<pid>/numa_vamaps file for numa node information
Date: Wed, 12 Sep 2018 13:24:00 -0700
Message-Id: <1536783844-4145-3-git-send-email-prakash.sangappa@oracle.com>
In-Reply-To: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: dave.hansen@intel.com, mhocko@suse.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com, prakash.sangappa@oracle.com

Introduce supporting data structures and file operations. Later
patch will provide changes for generating file content.

Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
---
 fs/proc/base.c     |  2 ++
 fs/proc/internal.h |  1 +
 fs/proc/task_mmu.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 45 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index ccf86f1..1af99ae 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2927,6 +2927,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("maps",       S_IRUGO, proc_pid_maps_operations),
 #ifdef CONFIG_NUMA
 	REG("numa_maps",  S_IRUGO, proc_pid_numa_maps_operations),
+	REG("numa_vamaps",  S_IRUGO, proc_numa_vamaps_operations),
 #endif
 	REG("mem",        S_IRUSR|S_IWUSR, proc_mem_operations),
 	LNK("cwd",        proc_cwd_link),
@@ -3313,6 +3314,7 @@ static const struct pid_entry tid_base_stuff[] = {
 #endif
 #ifdef CONFIG_NUMA
 	REG("numa_maps", S_IRUGO, proc_pid_numa_maps_operations),
+	REG("numa_vamaps",  S_IRUGO, proc_numa_vamaps_operations),
 #endif
 	REG("mem",       S_IRUSR|S_IWUSR, proc_mem_operations),
 	LNK("cwd",       proc_cwd_link),
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 5185d7f..994c7fd 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -298,6 +298,7 @@ extern const struct file_operations proc_pid_smaps_operations;
 extern const struct file_operations proc_pid_smaps_rollup_operations;
 extern const struct file_operations proc_clear_refs_operations;
 extern const struct file_operations proc_pagemap_operations;
+extern const struct file_operations proc_numa_vamaps_operations;
 
 extern unsigned long task_vsize(struct mm_struct *);
 extern unsigned long task_statm(struct mm_struct *,
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 0e2095c..02b553c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1583,6 +1583,16 @@ struct numa_maps_private {
 	struct numa_maps md;
 };
 
+#define NUMA_VAMAPS_BUFSZ      1024
+struct numa_vamaps_private {
+	struct mm_struct *mm;
+	struct numa_maps md;
+	u64 vm_start;
+	size_t from;
+	size_t count; /* residual bytes in buf at offset 'from' */
+	char buf[NUMA_VAMAPS_BUFSZ]; /* buffer */
+};
+
 static void gather_stats(struct page *page, struct numa_maps *md, int pte_dirty,
 			unsigned long nr_pages)
 {
@@ -1848,6 +1858,34 @@ static int pid_numa_maps_open(struct inode *inode, struct file *file)
 				sizeof(struct numa_maps_private));
 }
 
+static int numa_vamaps_open(struct inode *inode, struct file *file)
+{
+	struct mm_struct *mm;
+	struct numa_vamaps_private *nvm;
+	nvm = kzalloc(sizeof(struct numa_vamaps_private), GFP_KERNEL);
+	if (!nvm)
+		return -ENOMEM;
+
+	mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	if (IS_ERR(mm)) {
+		kfree(nvm);
+		return PTR_ERR(mm);
+	}
+	nvm->mm = mm;
+	file->private_data = nvm;
+	return 0;
+}
+
+static int numa_vamaps_release(struct inode *inode, struct file *file)
+{
+	struct numa_vamaps_private *nvm = file->private_data;
+
+	if (nvm->mm)
+		mmdrop(nvm->mm);
+	kfree(nvm);
+	return 0;
+}
+
 const struct file_operations proc_pid_numa_maps_operations = {
 	.open		= pid_numa_maps_open,
 	.read		= seq_read,
@@ -1855,4 +1893,8 @@ const struct file_operations proc_pid_numa_maps_operations = {
 	.release	= proc_map_release,
 };
 
+const struct file_operations proc_numa_vamaps_operations = {
+	.open		= numa_vamaps_open,
+	.release	= numa_vamaps_release,
+};
 #endif /* CONFIG_NUMA */
-- 
2.7.4
