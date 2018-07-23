Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38B7C6B000E
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:19:53 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 31-v6so180248pld.6
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:19:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13-v6si8457409pgb.356.2018.07.23.04.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 04:19:51 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4/4] mm: proc/pid/smaps_rollup: convert to single value seq_file
Date: Mon, 23 Jul 2018 13:19:33 +0200
Message-Id: <20180723111933.15443-5-vbabka@suse.cz>
In-Reply-To: <20180723111933.15443-1-vbabka@suse.cz>
References: <20180723111933.15443-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Colascione <dancol@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, linux-api@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

The /proc/pid/smaps_rollup file is currently implemented via the
m_start/m_next/m_stop seq_file iterators shared with the other maps files,
that iterate over vma's. However, the rollup file doesn't print anything
for each vma, only accumulate the stats.

There are some issues with the current code as reported in [1] - the
accumulated stats can get skewed if seq_file start()/stop() op is called
multiple times, if show() is called multiple times, and after seeks to
non-zero position.

Patch [1] fixed those within existing design, but I believe it is
fundamentally wrong to expose the vma iterators to the seq_file mechanism
when smaps_rollup shows logically a single set of values for the whole
address space.

This patch thus refactors the code to provide a single "value" at offset 0,
with vma iteration to gather the stats done internally. This fixes the
situations where results are skewed, and simplifies the code, especially
in show_smap(), at the expense of somewhat less code reuse.

[1] https://marc.info/?l=linux-mm&m=151927723128134&w=2

Reported-by: Daniel Colascione <dancol@google.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 fs/proc/task_mmu.c | 136 ++++++++++++++++++++++++++++-----------------
 1 file changed, 86 insertions(+), 50 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 1d6d315fd31b..31109e67804c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -404,7 +404,6 @@ const struct file_operations proc_pid_maps_operations = {
 
 #ifdef CONFIG_PROC_PAGE_MONITOR
 struct mem_size_stats {
-	bool first;
 	unsigned long resident;
 	unsigned long shared_clean;
 	unsigned long shared_dirty;
@@ -418,11 +417,12 @@ struct mem_size_stats {
 	unsigned long swap;
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
-	unsigned long first_vma_start;
+	unsigned long last_vma_end;
 	u64 pss;
 	u64 pss_locked;
 	u64 swap_pss;
 	bool check_shmem_swap;
+	bool finished;
 };
 
 static void smaps_account(struct mem_size_stats *mss, struct page *page,
@@ -775,58 +775,57 @@ static void __show_smap(struct seq_file *m, struct mem_size_stats *mss)
 
 static int show_smap(struct seq_file *m, void *v)
 {
-	struct proc_maps_private *priv = m->private;
 	struct vm_area_struct *vma = v;
-	struct mem_size_stats mss_stack;
-	struct mem_size_stats *mss;
-	int ret = 0;
-	bool rollup_mode;
-	bool last_vma;
-
-	if (priv->rollup) {
-		rollup_mode = true;
-		mss = priv->rollup;
-		if (mss->first) {
-			mss->first_vma_start = vma->vm_start;
-			mss->first = false;
-		}
-		last_vma = !m_next_vma(priv, vma);
-	} else {
-		rollup_mode = false;
-		memset(&mss_stack, 0, sizeof(mss_stack));
-		mss = &mss_stack;
-	}
+	struct mem_size_stats mss;
 
-	smap_gather_stats(vma, mss);
+	memset(&mss, 0, sizeof(mss));
 
-	if (!rollup_mode) {
-		show_map_vma(m, vma);
-	} else if (last_vma) {
-		show_vma_header_prefix(
-			m, mss->first_vma_start, vma->vm_end, 0, 0, 0, 0);
-		seq_pad(m, ' ');
-		seq_puts(m, "[rollup]\n");
-	} else {
-		ret = SEQ_SKIP;
-	}
+	smap_gather_stats(vma, &mss);
 
-	if (!rollup_mode) {
-		SEQ_PUT_DEC("Size:           ", vma->vm_end - vma->vm_start);
-		SEQ_PUT_DEC(" kB\nKernelPageSize: ", vma_kernel_pagesize(vma));
-		SEQ_PUT_DEC(" kB\nMMUPageSize:    ", vma_mmu_pagesize(vma));
-		seq_puts(m, " kB\n");
-	}
+	show_map_vma(m, vma);
 
-	if (!rollup_mode || last_vma)
-		__show_smap(m, mss);
+	SEQ_PUT_DEC("Size:           ", vma->vm_end - vma->vm_start);
+	SEQ_PUT_DEC(" kB\nKernelPageSize: ", vma_kernel_pagesize(vma));
+	SEQ_PUT_DEC(" kB\nMMUPageSize:    ", vma_mmu_pagesize(vma));
+	seq_puts(m, " kB\n");
+
+	__show_smap(m, &mss);
+
+	if (arch_pkeys_enabled())
+		seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
+	show_smap_vma_flags(m, vma);
 
-	if (!rollup_mode) {
-		if (arch_pkeys_enabled())
-			seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
-		show_smap_vma_flags(m, vma);
-	}
 	m_cache_vma(m, vma);
-	return ret;
+
+	return 0;
+}
+
+static int show_smaps_rollup(struct seq_file *m, void *v)
+{
+	struct proc_maps_private *priv = m->private;
+	struct mem_size_stats *mss = priv->rollup;
+	struct vm_area_struct *vma;
+
+	/*
+	 * We might be called multiple times when e.g. the seq buffer
+	 * overflows. Gather the stats only once.
+	 */
+	if (!mss->finished) {
+		for (vma = priv->mm->mmap; vma; vma = vma->vm_next) {
+			smap_gather_stats(vma, mss);
+			mss->last_vma_end = vma->vm_end;
+		}
+		mss->finished = true;
+	}
+
+	show_vma_header_prefix(m, priv->mm->mmap->vm_start,
+			       mss->last_vma_end, 0, 0, 0, 0);
+	seq_pad(m, ' ');
+	seq_puts(m, "[rollup]\n");
+
+	__show_smap(m, mss);
+
+	return 0;
 }
 #undef SEQ_PUT_DEC
 
@@ -837,6 +836,44 @@ static const struct seq_operations proc_pid_smaps_op = {
 	.show	= show_smap
 };
 
+static void *smaps_rollup_start(struct seq_file *m, loff_t *ppos)
+{
+	struct proc_maps_private *priv = m->private;
+	struct mm_struct *mm;
+
+	if (*ppos != 0)
+		return NULL;
+
+	priv->task = get_proc_task(priv->inode);
+	if (!priv->task)
+		return ERR_PTR(-ESRCH);
+
+	mm = priv->mm;
+	if (!mm || !mmget_not_zero(mm))
+		return NULL;
+
+	memset(priv->rollup, 0, sizeof(*priv->rollup));
+
+	down_read(&mm->mmap_sem);
+	hold_task_mempolicy(priv);
+
+	return mm;
+}
+
+static void *smaps_rollup_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	(*pos)++;
+	vma_stop(m->private);
+	return NULL;
+}
+
+static const struct seq_operations proc_pid_smaps_rollup_op = {
+	.start	= smaps_rollup_start,
+	.next	= smaps_rollup_next,
+	.stop	= m_stop,
+	.show	= show_smaps_rollup
+};
+
 static int pid_smaps_open(struct inode *inode, struct file *file)
 {
 	return do_maps_open(inode, file, &proc_pid_smaps_op);
@@ -846,18 +883,17 @@ static int pid_smaps_rollup_open(struct inode *inode, struct file *file)
 {
 	struct seq_file *seq;
 	struct proc_maps_private *priv;
-	int ret = do_maps_open(inode, file, &proc_pid_smaps_op);
+	int ret = do_maps_open(inode, file, &proc_pid_smaps_rollup_op);
 
 	if (ret < 0)
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
2.18.0
