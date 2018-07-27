Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9A16B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:17:40 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id t10-v6so3919702wrs.17
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:17:40 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d12-v6si4610151wra.117.2018.07.27.14.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 14:17:38 -0700 (PDT)
From: Jane Chu <jane.chu@oracle.com>
Subject: [PATCH] ipc/shm.c add ->pagesize function to shm_vm_ops
Date: Fri, 27 Jul 2018 15:17:27 -0600
Message-Id: <20180727211727.5020-1-jane.chu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, mhocko@suse.com, jack@suse.cz, jglisse@redhat.com, mike.kravetz@oracle.com, dave@stgolabs.net, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, jane.chu@oracle.com

Commit 05ea88608d4e13 (mm, hugetlbfs: introduce ->pagesize() to
vm_operations_struct) adds a new ->pagesize() function to
hugetlb_vm_ops, intended to cover all hugetlbfs backed files.

With System V shared memory model, if "huge page" is specified,
the "shared memory" is backed by hugetlbfs files, but the mappings
initiated via shmget/shmat have their original vm_ops overwritten
with shm_vm_ops, so we need to add a ->pagesize function to shm_vm_ops.
Otherwise, vma_kernel_pagesize() returns PAGE_SIZE given a hugetlbfs
backed vma, result in below BUG:

fs/hugetlbfs/inode.c
        443             if (unlikely(page_mapped(page))) {
        444                     BUG_ON(truncate_op);

[  242.268342] hugetlbfs: oracle (4592): Using mlock ulimits for SHM_HUGETLB is deprecated
[  282.653208] ------------[ cut here ]------------
[  282.708447] kernel BUG at fs/hugetlbfs/inode.c:444!
[  282.818957] Modules linked in: nfsv3 rpcsec_gss_krb5 nfsv4 ...
[  284.025873] CPU: 35 PID: 5583 Comm: oracle_5583_sbt Not tainted 4.14.35-1829.el7uek.x86_64 #2
[  284.246609] task: ffff9bf0507aaf80 task.stack: ffffa9e625628000
[  284.317455] RIP: 0010:remove_inode_hugepages+0x3db/0x3e2
....
[  285.292389] Call Trace:
[  285.321630]  hugetlbfs_evict_inode+0x1e/0x3e
[  285.372707]  evict+0xdb/0x1af
[  285.408185]  iput+0x1a2/0x1f7
[  285.443661]  dentry_unlink_inode+0xc6/0xf0
[  285.492661]  __dentry_kill+0xd8/0x18d
[  285.536459]  dput+0x1b5/0x1ed
[  285.571939]  __fput+0x18b/0x216
[  285.609495]  ____fput+0xe/0x10
[  285.646030]  task_work_run+0x90/0xa7
[  285.688788]  exit_to_usermode_loop+0xdd/0x116
[  285.740905]  do_syscall_64+0x187/0x1ae
[  285.785740]  entry_SYSCALL_64_after_hwframe+0x150/0x0

Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Jane Chu <jane.chu@oracle.com>
---
 include/linux/mm.h |  7 +++++++
 ipc/shm.c          | 12 ++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a0fbb9ffe380..0c759379f2d9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -387,6 +387,13 @@ enum page_entry_size {
  * These are the virtual MM functions - opening of an area, closing and
  * unmapping it (needed to keep files on disk up-to-date etc), pointer
  * to the functions called when a no-page or a wp-page exception occurs.
+ *
+ * Note, when a new function is introduced to vm_operations_struct and
+ * added to hugetlb_vm_ops, please consider adding the function to
+ * shm_vm_ops. This is because under System V memory model, though
+ * mappings created via shmget/shmat with "huge page" specified are
+ * backed by hugetlbfs files, their original vm_ops are overwritten with
+ * shm_vm_ops.
  */
 struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
diff --git a/ipc/shm.c b/ipc/shm.c
index 051a3e1fb8df..fefa00d310fb 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -427,6 +427,17 @@ static int shm_split(struct vm_area_struct *vma, unsigned long addr)
 	return 0;
 }
 
+static unsigned long shm_pagesize(struct vm_area_struct *vma)
+{
+	struct file *file = vma->vm_file;
+	struct shm_file_data *sfd = shm_file_data(file);
+
+	if (sfd->vm_ops->pagesize)
+		return sfd->vm_ops->pagesize(vma);
+
+	return PAGE_SIZE;
+}
+
 #ifdef CONFIG_NUMA
 static int shm_set_policy(struct vm_area_struct *vma, struct mempolicy *new)
 {
@@ -554,6 +565,7 @@ static const struct vm_operations_struct shm_vm_ops = {
 	.close	= shm_close,	/* callback for when the vm-area is released */
 	.fault	= shm_fault,
 	.split	= shm_split,
+	.pagesize = shm_pagesize,
 #if defined(CONFIG_NUMA)
 	.set_policy = shm_set_policy,
 	.get_policy = shm_get_policy,
-- 
2.15.GIT
