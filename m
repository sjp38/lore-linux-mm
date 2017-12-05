Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB24A6B0261
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 14:49:34 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id a45so690740wra.14
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 11:49:34 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id u54si883361edm.140.2017.12.05.11.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 11:49:33 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v3 6/7] hugetlbfs: parallelize hugetlbfs_fallocate with ktask
Date: Tue,  5 Dec 2017 14:52:19 -0500
Message-Id: <20171205195220.28208-7-daniel.m.jordan@oracle.com>
In-Reply-To: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

hugetlbfs_fallocate preallocates huge pages to back a file in a
hugetlbfs filesystem.  The time to call this function grows linearly
with size.

ktask performs well with its default thread count of 4; higher thread
counts are given for context only.

Machine: Intel(R) Xeon(R) CPU E7-8895 v3 @ 2.60GHz, 288 CPUs, 1T memory
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

Machine: SPARC T7-4, 1024 CPUs, 504G memory
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
with 8 threads and again sharply with 16 threads, and a CPU counter
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
 fs/hugetlbfs/inode.c | 116 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 94 insertions(+), 22 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 8a85f3f53446..b027ba917239 100644
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
 
@@ -535,19 +547,29 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
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
@@ -570,16 +592,66 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
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
+		DEFINE_KTASK_CTL(ctl, hugetlbfs_fallocate_chunk,
+				 &hf_args, KTASK_BPGS_MINCHUNK);
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
@@ -594,13 +666,13 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
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
@@ -625,7 +697,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		if (IS_ERR(page)) {
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 			error = PTR_ERR(page);
-			goto out;
+			goto err;
 		}
 		clear_huge_page(page, addr, pages_per_huge_page(h));
 		__SetPageUptodate(page);
@@ -633,7 +705,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		if (unlikely(error)) {
 			put_page(page);
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
-			goto out;
+			goto err;
 		}
 
 		mutex_unlock(&hugetlb_fault_mutex_table[hash]);
@@ -646,12 +718,12 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		put_page(page);
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
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
