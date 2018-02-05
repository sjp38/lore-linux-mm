Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 420956B02AF
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:57 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id q5so7784449pll.17
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o3-v6si6201721plk.533.2018.02.04.17.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:03 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 13/64] fs/proc: teach about range locking
Date: Mon,  5 Feb 2018 02:27:03 +0100
Message-Id: <20180205012754.23615-14-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

And use mm locking wrappers -- no change in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 fs/proc/base.c       | 33 ++++++++++++++++++++-------------
 fs/proc/task_mmu.c   | 22 +++++++++++-----------
 fs/proc/task_nommu.c | 22 +++++++++++++---------
 3 files changed, 44 insertions(+), 33 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 9298324325ed..c94ee3e54f25 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -220,6 +220,7 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 	unsigned long p;
 	char c;
 	ssize_t rv;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	BUG_ON(*pos < 0);
 
@@ -242,12 +243,12 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 		goto out_mmput;
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	BUG_ON(arg_start > arg_end);
 	BUG_ON(env_start > env_end);
@@ -915,6 +916,7 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	unsigned long src = *ppos;
 	int ret = 0;
 	struct mm_struct *mm = file->private_data;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long env_start, env_end;
 
 	/* Ensure the process spawned far enough to have an environment. */
@@ -929,10 +931,10 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	if (!mmget_not_zero(mm))
 		goto free;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	while (count > 0) {
 		size_t this_len, max_len;
@@ -1962,9 +1964,11 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 		goto out;
 
 	if (!dname_to_vma_addr(dentry, &vm_start, &vm_end)) {
-		down_read(&mm->mmap_sem);
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
+		mm_read_lock(mm, &mmrange);
 		exact_vma_exists = !!find_exact_vma(mm, vm_start, vm_end);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	}
 
 	mmput(mm);
@@ -1995,6 +1999,7 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
 	struct task_struct *task;
 	struct mm_struct *mm;
 	int rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	rc = -ENOENT;
 	task = get_proc_task(d_inode(dentry));
@@ -2011,14 +2016,14 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
 		goto out_mmput;
 
 	rc = -ENOENT;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_exact_vma(mm, vm_start, vm_end);
 	if (vma && vma->vm_file) {
 		*path = vma->vm_file->f_path;
 		path_get(path);
 		rc = 0;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 out_mmput:
 	mmput(mm);
@@ -2091,6 +2096,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 	struct task_struct *task;
 	int result;
 	struct mm_struct *mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	result = -ENOENT;
 	task = get_proc_task(dir);
@@ -2109,7 +2115,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 	if (!mm)
 		goto out_put_task;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_exact_vma(mm, vm_start, vm_end);
 	if (!vma)
 		goto out_no_vma;
@@ -2119,7 +2125,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 				(void *)(unsigned long)vma->vm_file->f_mode);
 
 out_no_vma:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	mmput(mm);
 out_put_task:
 	put_task_struct(task);
@@ -2144,6 +2150,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	struct map_files_info info;
 	struct map_files_info *p;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	ret = -ENOENT;
 	task = get_proc_task(file_inode(file));
@@ -2161,7 +2168,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	mm = get_task_mm(task);
 	if (!mm)
 		goto out_put_task;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	nr_files = 0;
 
@@ -2188,7 +2195,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 			ret = -ENOMEM;
 			if (fa)
 				flex_array_free(fa);
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			mmput(mm);
 			goto out_put_task;
 		}
@@ -2206,7 +2213,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 				BUG();
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	for (i = 0; i < nr_files; i++) {
 		char buf[4 * sizeof(long) + 2];	/* max: %lx-%lx\0 */
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7c0a79a937b5..feb5bd4e5c82 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -136,7 +136,7 @@ static void vma_stop(struct proc_maps_private *priv)
 	struct mm_struct *mm = priv->mm;
 
 	release_task_mempolicy(priv);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &priv->mmrange);
 	mmput(mm);
 }
 
@@ -175,7 +175,7 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
 		return NULL;
 
 	range_lock_init_full(&priv->mmrange);
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &priv->mmrange);
 	hold_task_mempolicy(priv);
 	priv->tail_vma = get_gate_vma(mm);
 
@@ -1135,7 +1135,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		};
 
 		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
-			if (down_write_killable(&mm->mmap_sem)) {
+			if (mm_write_lock_killable(mm, &mmrange)) {
 				count = -EINTR;
 				goto out_mm;
 			}
@@ -1145,18 +1145,18 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			 * resident set size to this mm's current rss value.
 			 */
 			reset_mm_hiwater_rss(mm);
-			up_write(&mm->mmap_sem);
+			mm_write_unlock(mm, &mmrange);
 			goto out_mm;
 		}
 
-		down_read(&mm->mmap_sem);
+	        mm_read_lock(mm, &mmrange);
 		tlb_gather_mmu(&tlb, mm, 0, -1);
 		if (type == CLEAR_REFS_SOFT_DIRTY) {
 			for (vma = mm->mmap; vma; vma = vma->vm_next) {
 				if (!(vma->vm_flags & VM_SOFTDIRTY))
 					continue;
-				up_read(&mm->mmap_sem);
-				if (down_write_killable(&mm->mmap_sem)) {
+				mm_read_unlock(mm, &mmrange);
+				if (mm_write_lock_killable(mm, &mmrange)) {
 					count = -EINTR;
 					goto out_mm;
 				}
@@ -1164,7 +1164,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 					vma->vm_flags &= ~VM_SOFTDIRTY;
 					vma_set_page_prot(vma);
 				}
-				downgrade_write(&mm->mmap_sem);
+				mm_downgrade_write(mm, &mmrange);
 				break;
 			}
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
@@ -1174,7 +1174,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
 		tlb_finish_mmu(&tlb, 0, -1);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 out_mm:
 		mmput(mm);
 	}
@@ -1528,10 +1528,10 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 		/* overflow ? */
 		if (end < start_vaddr || end > end_vaddr)
 			end = end_vaddr;
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, mmrange);
 		ret = walk_page_range(start_vaddr, end, &pagemap_walk,
 				      mmrange);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 		start_vaddr = end;
 
 		len = min(count, PM_ENTRY_BYTES * pm.pos);
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 5b62f57bd9bc..50a21813f926 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -23,9 +23,10 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	struct vm_region *region;
 	struct rb_node *p;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long bytes = 0, sbytes = 0, slack = 0, size;
         
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 
@@ -77,7 +78,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"Shared:\t%8lu bytes\n",
 		bytes, slack, sbytes);
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 }
 
 unsigned long task_vsize(struct mm_struct *mm)
@@ -85,13 +86,14 @@ unsigned long task_vsize(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	struct rb_node *p;
 	unsigned long vsize = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 		vsize += vma->vm_end - vma->vm_start;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return vsize;
 }
 
@@ -103,8 +105,9 @@ unsigned long task_statm(struct mm_struct *mm,
 	struct vm_region *region;
 	struct rb_node *p;
 	unsigned long size = kobjsize(mm);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 		size += kobjsize(vma);
@@ -119,7 +122,7 @@ unsigned long task_statm(struct mm_struct *mm,
 		>> PAGE_SHIFT;
 	*data = (PAGE_ALIGN(mm->start_stack) - (mm->start_data & PAGE_MASK))
 		>> PAGE_SHIFT;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	size >>= PAGE_SHIFT;
 	size += *text + *data;
 	*resident = size;
@@ -223,13 +226,14 @@ static void *m_start(struct seq_file *m, loff_t *pos)
 	if (!mm || !mmget_not_zero(mm))
 		return NULL;
 
-	down_read(&mm->mmap_sem);
+	range_lock_init_full(&priv->mmrange);
+	mm_read_lock(mm, &priv->mmrange);
 	/* start from the Nth VMA */
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p))
 		if (n-- == 0)
 			return p;
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &priv->mmrange);
 	mmput(mm);
 	return NULL;
 }
@@ -239,7 +243,7 @@ static void m_stop(struct seq_file *m, void *_vml)
 	struct proc_maps_private *priv = m->private;
 
 	if (!IS_ERR_OR_NULL(_vml)) {
-		up_read(&priv->mm->mmap_sem);
+		mm_read_unlock(priv->mm, &priv->mmrange);
 		mmput(priv->mm);
 	}
 	if (priv->task) {
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
