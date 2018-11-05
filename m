Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 190FD6B027B
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:52 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id i64-v6so7714848ywa.22
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:52 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id p1-v6si22935361ybc.133.2018.11.05.08.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:56:50 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v4 13/13] hugetlbfs: parallelize hugetlbfs_fallocate with ktask
Date: Mon,  5 Nov 2018 11:55:58 -0500
Message-Id: <20181105165558.11698-14-daniel.m.jordan@oracle.com>
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, daniel.m.jordan@oracle.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

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

The primary bottleneck for better scaling at higher thread counts is
hugetlb_fault_mutex_table[hash].  perf showed L1-dcache-loads increase
with 8 threads and again sharply with 16 threads, and a CPU counter
profile showed that 31% of the L1d misses were on
hugetlb_fault_mutex_table[hash] in the 16-thread case.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 fs/hugetlbfs/inode.c | 114 +++++++++++++++++++++++++++++++++++--------
 1 file changed, 93 insertions(+), 21 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 762028994f47..a73548a96061 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -37,6 +37,7 @@
 #include <linux/magic.h>
 #include <linux/migrate.h>
 #include <linux/uio.h>
+#include <linux/ktask.h>
 
 #include <linux/uaccess.h>
 
@@ -104,11 +105,16 @@ static const struct fs_parameter_description hugetlb_fs_parameters = {
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
@@ -116,8 +122,14 @@ static inline void hugetlb_drop_vma_policy(struct vm_area_struct *vma)
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
 
@@ -576,20 +588,30 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
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
 	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
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
@@ -617,16 +639,66 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		goto out;
 	}
 
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
+				 &hf_args, KTASK_PMD_MINCHUNK);
+
+		error = ktask_run((void *)start, end - start, &ctl);
+	}
+
+	if (error != KTASK_RETURN_SUCCESS && hf_args.error != -EINTR)
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
 	vma_init(&pseudo_vma, mm);
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
 	pseudo_vma.vm_file = file;
 
-	for (index = start; index < end; index++) {
+	for (index = start; index < end; ++index) {
 		/*
 		 * This is supposed to be the vaddr where the page is being
 		 * faulted in, but we have no vaddr here.
@@ -641,13 +713,13 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
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
@@ -672,7 +744,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		if (IS_ERR(page)) {
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 			error = PTR_ERR(page);
-			goto out;
+			goto err;
 		}
 		clear_huge_page(page, addr, pages_per_huge_page(h));
 		__SetPageUptodate(page);
@@ -680,7 +752,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		if (unlikely(error)) {
 			put_page(page);
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
-			goto out;
+			goto err;
 		}
 
 		mutex_unlock(&hugetlb_fault_mutex_table[hash]);
@@ -693,11 +765,11 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		put_page(page);
 	}
 
-	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
-		i_size_write(inode, offset + len);
-	inode->i_ctime = current_time(inode);
-out:
-	inode_unlock(inode);
+	return KTASK_RETURN_SUCCESS;
+
+err:
+	args->error = error;
+
 	return error;
 }
 
-- 
2.19.1
