Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBBAF6B0289
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 00:27:10 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id 41so3161124qtp.8
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 21:27:10 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id u73sor2355731qki.128.2018.02.21.21.27.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 21:27:09 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 21 Feb 2018 21:26:58 -0800
In-Reply-To: <20180222052659.106016-1-dancol@google.com>
Message-Id: <20180222052659.106016-2-dancol@google.com>
References: <20180222052659.106016-1-dancol@google.com>
Subject: [PATCH 1/2] Bug fixes for smaps_rollup
From: Daniel Colascione <dancol@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Daniel Colascione <dancol@google.com>

Properly account and display pss_locked; behave properly when seq_file
starts and stops multiple times on a single open file description,
when when it issues multiple show calls, and when seq_file seeks to a
non-zero position.

Signed-off-by: Daniel Colascione <dancol@google.com>
---
 fs/proc/task_mmu.c | 102 +++++++++++++++++++++++++++------------------
 1 file changed, 62 insertions(+), 40 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ec6d2983a5cb..5e95f7eaf145 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -188,8 +188,14 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
 
 	m->version = 0;
 	if (pos < mm->map_count) {
+		bool rollup_mode = !!priv->rollup;
 		for (vma = mm->mmap; pos; pos--) {
 			m->version = vma->vm_start;
+			if (rollup_mode) {
+				 /* Accumulate into rollup structure */
+				int show_result = m->op->show(m, vma);
+				VM_BUG_ON(!show_result);
+			}
 			vma = vma->vm_next;
 		}
 		return vma;
@@ -438,7 +444,7 @@ const struct file_operations proc_tid_maps_operations = {
 
 #ifdef CONFIG_PROC_PAGE_MONITOR
 struct mem_size_stats {
-	bool first;
+	struct vm_area_struct *previous_vma;
 	unsigned long resident;
 	unsigned long shared_clean;
 	unsigned long shared_dirty;
@@ -459,11 +465,13 @@ struct mem_size_stats {
 	bool check_shmem_swap;
 };
 
-static void smaps_account(struct mem_size_stats *mss, struct page *page,
+static void smaps_account(struct mem_size_stats *mss,
+		struct vm_area_struct *vma, struct page *page,
 		bool compound, bool young, bool dirty)
 {
 	int i, nr = compound ? 1 << compound_order(page) : 1;
 	unsigned long size = nr * PAGE_SIZE;
+	u64 pss_add = 0;
 
 	if (PageAnon(page)) {
 		mss->anonymous += size;
@@ -486,8 +494,8 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 			mss->private_dirty += size;
 		else
 			mss->private_clean += size;
-		mss->pss += (u64)size << PSS_SHIFT;
-		return;
+		pss_add += (u64)size << PSS_SHIFT;
+		goto done;
 	}
 
 	for (i = 0; i < nr; i++, page++) {
@@ -498,15 +506,20 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 				mss->shared_dirty += PAGE_SIZE;
 			else
 				mss->shared_clean += PAGE_SIZE;
-			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
+			pss_add += (PAGE_SIZE << PSS_SHIFT) / mapcount;
 		} else {
 			if (dirty || PageDirty(page))
 				mss->private_dirty += PAGE_SIZE;
 			else
 				mss->private_clean += PAGE_SIZE;
-			mss->pss += PAGE_SIZE << PSS_SHIFT;
+			pss_add += PAGE_SIZE << PSS_SHIFT;
 		}
 	}
+
+done:
+	mss->pss += pss_add;
+	if (vma->vm_flags & VM_LOCKED)
+		mss->pss_locked += pss_add;
 }
 
 #ifdef CONFIG_SHMEM
@@ -569,7 +582,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 	if (!page)
 		return;
 
-	smaps_account(mss, page, false, pte_young(*pte), pte_dirty(*pte));
+	smaps_account(mss, vma, page, false, pte_young(*pte), pte_dirty(*pte));
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -592,7 +605,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 		/* pass */;
 	else
 		VM_BUG_ON_PAGE(1, page);
-	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
+	smaps_account(mss, vma, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
 }
 #else
 static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
@@ -736,6 +749,37 @@ void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
 {
 }
 
+static void show_smap_accumulate(struct mm_walk *smaps_walk,
+		struct vm_area_struct *vma, struct mem_size_stats *mss)
+{
+#ifdef CONFIG_SHMEM
+	if (vma->vm_file && shmem_mapping(vma->vm_file->f_mapping)) {
+		/*
+		 * For shared or readonly shmem mappings we know that all
+		 * swapped out pages belong to the shmem object, and we can
+		 * obtain the swap value much more efficiently. For private
+		 * writable mappings, we might have COW pages that are
+		 * not affected by the parent swapped out pages of the shmem
+		 * object, so we have to distinguish them during the page walk.
+		 * Unless we know that the shmem object (or the part mapped by
+		 * our VMA) has no swapped out pages at all.
+		 */
+		unsigned long shmem_swapped = shmem_swap_usage(vma);
+
+		if (!shmem_swapped || (vma->vm_flags & VM_SHARED) ||
+					!(vma->vm_flags & VM_WRITE)) {
+			mss->swap += shmem_swapped;
+		} else {
+			mss->check_shmem_swap = true;
+			smaps_walk->pte_hole = smaps_pte_hole;
+		}
+	}
+#endif
+
+	/* mmap_sem is held in m_start */
+	walk_page_vma(vma, smaps_walk);
+}
+
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct proc_maps_private *priv = m->private;
@@ -756,9 +800,9 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 	if (priv->rollup) {
 		rollup_mode = true;
 		mss = priv->rollup;
-		if (mss->first) {
+		if (vma == priv->mm->mmap) { /* First */
+			memset(mss, 0, sizeof (*mss));
 			mss->first_vma_start = vma->vm_start;
-			mss->first = false;
 		}
 		last_vma = !m_next_vma(priv, vma);
 	} else {
@@ -769,34 +813,13 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 
 	smaps_walk.private = mss;
 
-#ifdef CONFIG_SHMEM
-	if (vma->vm_file && shmem_mapping(vma->vm_file->f_mapping)) {
-		/*
-		 * For shared or readonly shmem mappings we know that all
-		 * swapped out pages belong to the shmem object, and we can
-		 * obtain the swap value much more efficiently. For private
-		 * writable mappings, we might have COW pages that are
-		 * not affected by the parent swapped out pages of the shmem
-		 * object, so we have to distinguish them during the page walk.
-		 * Unless we know that the shmem object (or the part mapped by
-		 * our VMA) has no swapped out pages at all.
-		 */
-		unsigned long shmem_swapped = shmem_swap_usage(vma);
-
-		if (!shmem_swapped || (vma->vm_flags & VM_SHARED) ||
-					!(vma->vm_flags & VM_WRITE)) {
-			mss->swap = shmem_swapped;
-		} else {
-			mss->check_shmem_swap = true;
-			smaps_walk.pte_hole = smaps_pte_hole;
-		}
+	/* seq_file is allowed to ask us to show many times for the
+	 * same iterator value, and we don't want to accumulate each
+	 * VMA more than once. */
+	if (mss->previous_vma != vma) {
+		mss->previous_vma = vma;
+		show_smap_accumulate(&smaps_walk, vma, mss);
 	}
-#endif
-
-	/* mmap_sem is held in m_start */
-	walk_page_vma(vma, &smaps_walk);
-	if (vma->vm_flags & VM_LOCKED)
-		mss->pss_locked += mss->pss;
 
 	if (!rollup_mode) {
 		show_map_vma(m, vma, is_pid);
@@ -852,7 +875,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 			   mss->private_hugetlb >> 10,
 			   mss->swap >> 10,
 			   (unsigned long)(mss->swap_pss >> (10 + PSS_SHIFT)),
-			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
+			   (unsigned long)(mss->pss_locked >> (10 + PSS_SHIFT)));
 
 	if (!rollup_mode) {
 		arch_show_smap(m, vma);
@@ -901,12 +924,11 @@ static int pid_smaps_rollup_open(struct inode *inode, struct file *file)
 		return ret;
 	seq = file->private_data;
 	priv = seq->private;
-	priv->rollup = kzalloc(sizeof(*priv->rollup), GFP_KERNEL);
+	priv->rollup = kmalloc(sizeof(*priv->rollup), GFP_KERNEL);
 	if (!priv->rollup) {
 		proc_map_release(inode, file);
 		return -ENOMEM;
 	}
-	priv->rollup->first = true;
 	return 0;
 }
 
-- 
2.16.1.291.g4437f3f132-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
