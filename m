Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBB5440882
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:48:49 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id c132so199832vke.15
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:48:49 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p9si227471uab.257.2017.08.24.13.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 13:48:47 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 6/7] hugetlbfs: parallelize hugetlbfs_fallocate with ktask
Date: Thu, 24 Aug 2017 16:50:03 -0400
Message-Id: <20170824205004.18502-7-daniel.m.jordan@oracle.com>
In-Reply-To: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
References: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

hugetlbfs_fallocate preallocates huge pages to back a file in a
hugetlbfs filesystem.  The time to call this function grows linearly
with size.

ktask performs well with its default thread count of 4; higher thread
counts are given for context only.

Machine: Intel(R) Xeon(R) CPU E7-8895 v3 @ 2.60GHz, 288 cpus, 1T memory
Test:    fallocate(1) a file on a hugetlbfs filesystem

nthread   speedup   size (GiB)   min time (s)   stdev
      1                    200         127.53    2.19
      2     3.09x          200          41.30    2.11
      4     5.72x          200          22.29    0.51
      8     9.45x          200          13.50    2.58
     16     9.74x          200          13.09    1.64

      1                    400         193.09    2.47
      2     2.14x          400          90.31    3.39
      4     3.84x          400          50.32    0.44
      8     5.11x          400          37.75    1.23
     16     6.12x          400          31.54    3.13

Machine: SPARC T7-4, 1024 cpus, 504G memory
Test:    fallocate(1) a file on a hugetlbfs filesystem

nthread   speedup   size (GiB)   min time (s)   stdev

      1                    100          15.55    0.05
      2     1.92x          100           8.08    0.01
      4     3.55x          100           4.38    0.02
      8     5.87x          100           2.65    0.06
     16     6.45x          100           2.41    0.09

      1                    200          31.26    0.02
      2     1.92x          200          16.26    0.02
      4     3.58x          200           8.73    0.04
      8     5.54x          200           5.64    0.16
     16     6.96x          200           4.49    0.35

      1                    400          62.18    0.09
      2     1.98x          400          31.36    0.04
      4     3.55x          400          17.52    0.03
      8     5.53x          400          11.25    0.04
     16     6.61x          400           9.40    0.17

The primary bottleneck for better scaling at higher thread counts is
hugetlb_fault_mutex_table[hash].  perf showed L1-dcache-loads increase
with 8 threads and again sharply with 16 threads, and a cpu counter
profile showed that 31% of the L1d misses were on
hugetlb_fault_mutex_table[hash] in the 16-thread case.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Tim Chen <tim.c.chen@intel.com>
---
 fs/hugetlbfs/inode.c | 117 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 95 insertions(+), 22 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 28d2753be094..7eb8c9f988aa 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -36,6 +36,7 @@
 #include <linux/magic.h>
 #include <linux/migrate.h>
 #include <linux/uio.h>
+#include <linux/ktask.h>
 
 #include <linux/uaccess.h>
 
@@ -86,11 +87,16 @@ static const match_table_t tokens = {
 };
 
 #ifdef CONFIG_NUMA
+static inline struct shared_policy *hugetlb_get_shared_policy(
+							struct inode *inode)
+{
+	return &HUGETLBFS_I(inode)->policy;
+}
+
 static inline void hugetlb_set_vma_policy(struct vm_area_struct *vma,
-					struct inode *inode, pgoff_t index)
+				struct shared_policy *policy, pgoff_t index)
 {
-	vma->vm_policy = mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
-							index);
+	vma->vm_policy = mpol_shared_policy_lookup(policy, index);
 }
 
 static inline void hugetlb_drop_vma_policy(struct vm_area_struct *vma)
@@ -98,8 +104,14 @@ static inline void hugetlb_drop_vma_policy(struct vm_area_struct *vma)
 	mpol_cond_put(vma->vm_policy);
 }
 #else
+static inline struct shared_policy *hugetlb_get_shared_policy(
+							struct inode *inode)
+{
+	return NULL;
+}
+
 static inline void hugetlb_set_vma_policy(struct vm_area_struct *vma,
-					struct inode *inode, pgoff_t index)
+				struct shared_policy *policy, pgoff_t index)
 {
 }
 
@@ -551,19 +563,29 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 	return 0;
 }
 
+struct hf_args {
+	struct file		*file;
+	struct task_struct	*parent_task;
+	struct mm_struct	*mm;
+	struct shared_policy	*shared_policy;
+	struct hstate		*hstate;
+	struct address_space	*mapping;
+	int			error;
+};
+
+static int hugetlbfs_fallocate_chunk(pgoff_t start, pgoff_t end,
+				     struct hf_args *args);
+
 static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 				loff_t len)
 {
 	struct inode *inode = file_inode(file);
-	struct address_space *mapping = inode->i_mapping;
 	struct hstate *h = hstate_inode(inode);
-	struct vm_area_struct pseudo_vma;
-	struct mm_struct *mm = current->mm;
 	loff_t hpage_size = huge_page_size(h);
 	unsigned long hpage_shift = huge_page_shift(h);
-	pgoff_t start, index, end;
+	pgoff_t start, end;
+	struct hf_args hf_args;
 	int error;
-	u32 hash;
 
 	if (mode & ~(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE))
 		return -EOPNOTSUPP;
@@ -586,16 +608,67 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	if (error)
 		goto out;
 
+	hf_args.file = file;
+	hf_args.parent_task = current;
+	hf_args.mm = current->mm;
+	hf_args.shared_policy = hugetlb_get_shared_policy(inode);
+	hf_args.hstate = h;
+	hf_args.mapping = inode->i_mapping;
+	hf_args.error = 0;
+
+	if (unlikely(hstate_is_gigantic(h))) {
+		/*
+		 * Use multiple threads in clear_gigantic_page instead of here,
+		 * so just do a 1-threaded hugetlbfs_fallocate_chunk.
+		 */
+		error = hugetlbfs_fallocate_chunk(start, end, &hf_args);
+	} else {
+		DEFINE_KTASK_CTL_RANGE(ctl, hugetlbfs_fallocate_chunk,
+				       &hf_args, KTASK_BPGS_MINCHUNK,
+				       0, GFP_KERNEL);
+
+		error = ktask_run((void *)start, end - start, &ctl);
+	}
+
+	if (error == KTASK_RETURN_ERROR && hf_args.error != -EINTR)
+		goto out;
+
+	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
+		i_size_write(inode, offset + len);
+	inode->i_ctime = current_time(inode);
+out:
+	inode_unlock(inode);
+	return error;
+}
+
+static int hugetlbfs_fallocate_chunk(pgoff_t start, pgoff_t end,
+				     struct hf_args *args)
+{
+	struct file		*file		= args->file;
+	struct task_struct	*parent_task	= args->parent_task;
+	struct mm_struct	*mm		= args->mm;
+	struct shared_policy	*shared_policy	= args->shared_policy;
+	struct hstate		*h		= args->hstate;
+	struct address_space	*mapping	= args->mapping;
+	int			error		= 0;
+	pgoff_t			index;
+	struct vm_area_struct	pseudo_vma;
+	loff_t			hpage_size;
+	u32			hash;
+
+	hpage_size = huge_page_size(h);
+
 	/*
 	 * Initialize a pseudo vma as this is required by the huge page
 	 * allocation routines.  If NUMA is configured, use page index
-	 * as input to create an allocation policy.
+	 * as input to create an allocation policy.  Each thread gets its
+	 * own pseudo vma because mempolicies can differ by page.
 	 */
 	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
 	pseudo_vma.vm_file = file;
 
-	for (index = start; index < end; index++) {
+	for (index = start; index < end; ++index) {
 		/*
 		 * This is supposed to be the vaddr where the page is being
 		 * faulted in, but we have no vaddr here.
@@ -610,13 +683,13 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		 * fallocate(2) manpage permits EINTR; we may have been
 		 * interrupted because we are using up too much memory.
 		 */
-		if (signal_pending(current)) {
+		if (signal_pending(parent_task) || signal_pending(current)) {
 			error = -EINTR;
-			break;
+			goto err;
 		}
 
 		/* Set numa allocation policy based on index */
-		hugetlb_set_vma_policy(&pseudo_vma, inode, index);
+		hugetlb_set_vma_policy(&pseudo_vma, shared_policy, index);
 
 		/* addr is the offset within the file (zero based) */
 		addr = index * hpage_size;
@@ -641,7 +714,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		if (IS_ERR(page)) {
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 			error = PTR_ERR(page);
-			goto out;
+			goto err;
 		}
 		clear_huge_page(page, addr, pages_per_huge_page(h));
 		__SetPageUptodate(page);
@@ -649,7 +722,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		if (unlikely(error)) {
 			put_page(page);
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
-			goto out;
+			goto err;
 		}
 
 		mutex_unlock(&hugetlb_fault_mutex_table[hash]);
@@ -662,12 +735,12 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		unlock_page(page);
 	}
 
-	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
-		i_size_write(inode, offset + len);
-	inode->i_ctime = current_time(inode);
-out:
-	inode_unlock(inode);
-	return error;
+	return KTASK_RETURN_SUCCESS;
+
+err:
+	args->error = error;
+
+	return KTASK_RETURN_ERROR;
 }
 
 static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
