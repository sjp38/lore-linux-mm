Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36D6B6B000C
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:19:53 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e1-v6so155982pld.23
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:19:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e132-v6si8626691pfg.171.2018.07.23.04.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 04:19:51 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/4] mm: /proc/pid/*maps remove is_pid and related wrappers
Date: Mon, 23 Jul 2018 13:19:30 +0200
Message-Id: <20180723111933.15443-2-vbabka@suse.cz>
In-Reply-To: <20180723111933.15443-1-vbabka@suse.cz>
References: <20180723111933.15443-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Colascione <dancol@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, linux-api@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Commit b76437579d13 ("procfs: mark thread stack correctly in proc/<pid>/maps")
introduced differences between /proc/PID/maps and /proc/PID/task/TID/maps to
mark thread stacks properly, and this was also done for smaps and numa_maps.
However it didn't work properly and was ultimately removed by commit
b18cb64ead40 ("fs/proc: Stop trying to report thread stacks").

Now the is_pid parameter for the related show_*() functions is unused and we
can remove it together with wrapper functions and ops structures that differ
for PID and TID cases only in this parameter.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 fs/proc/base.c       |   6 +--
 fs/proc/internal.h   |   3 --
 fs/proc/task_mmu.c   | 114 +++++--------------------------------------
 fs/proc/task_nommu.c |  39 ++-------------
 4 files changed, 18 insertions(+), 144 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index aaffc0c30216..ad047977ed04 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -3309,12 +3309,12 @@ static const struct pid_entry tid_base_stuff[] = {
 	REG("cmdline",   S_IRUGO, proc_pid_cmdline_ops),
 	ONE("stat",      S_IRUGO, proc_tid_stat),
 	ONE("statm",     S_IRUGO, proc_pid_statm),
-	REG("maps",      S_IRUGO, proc_tid_maps_operations),
+	REG("maps",      S_IRUGO, proc_pid_maps_operations),
 #ifdef CONFIG_PROC_CHILDREN
 	REG("children",  S_IRUGO, proc_tid_children_operations),
 #endif
 #ifdef CONFIG_NUMA
-	REG("numa_maps", S_IRUGO, proc_tid_numa_maps_operations),
+	REG("numa_maps", S_IRUGO, proc_pid_numa_maps_operations),
 #endif
 	REG("mem",       S_IRUSR|S_IWUSR, proc_mem_operations),
 	LNK("cwd",       proc_cwd_link),
@@ -3324,7 +3324,7 @@ static const struct pid_entry tid_base_stuff[] = {
 	REG("mountinfo",  S_IRUGO, proc_mountinfo_operations),
 #ifdef CONFIG_PROC_PAGE_MONITOR
 	REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
-	REG("smaps",     S_IRUGO, proc_tid_smaps_operations),
+	REG("smaps",     S_IRUGO, proc_pid_smaps_operations),
 	REG("smaps_rollup", S_IRUGO, proc_pid_smaps_rollup_operations),
 	REG("pagemap",    S_IRUSR, proc_pagemap_operations),
 #endif
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index da3dbfa09e79..0c538769512a 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -297,12 +297,9 @@ struct proc_maps_private {
 struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode);
 
 extern const struct file_operations proc_pid_maps_operations;
-extern const struct file_operations proc_tid_maps_operations;
 extern const struct file_operations proc_pid_numa_maps_operations;
-extern const struct file_operations proc_tid_numa_maps_operations;
 extern const struct file_operations proc_pid_smaps_operations;
 extern const struct file_operations proc_pid_smaps_rollup_operations;
-extern const struct file_operations proc_tid_smaps_operations;
 extern const struct file_operations proc_clear_refs_operations;
 extern const struct file_operations proc_pagemap_operations;
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dfd73a4616ce..a3f98ca50981 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -294,7 +294,7 @@ static void show_vma_header_prefix(struct seq_file *m,
 }
 
 static void
-show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
+show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct file *file = vma->vm_file;
@@ -357,35 +357,18 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 	seq_putc(m, '\n');
 }
 
-static int show_map(struct seq_file *m, void *v, int is_pid)
+static int show_map(struct seq_file *m, void *v)
 {
-	show_map_vma(m, v, is_pid);
+	show_map_vma(m, v);
 	m_cache_vma(m, v);
 	return 0;
 }
 
-static int show_pid_map(struct seq_file *m, void *v)
-{
-	return show_map(m, v, 1);
-}
-
-static int show_tid_map(struct seq_file *m, void *v)
-{
-	return show_map(m, v, 0);
-}
-
 static const struct seq_operations proc_pid_maps_op = {
 	.start	= m_start,
 	.next	= m_next,
 	.stop	= m_stop,
-	.show	= show_pid_map
-};
-
-static const struct seq_operations proc_tid_maps_op = {
-	.start	= m_start,
-	.next	= m_next,
-	.stop	= m_stop,
-	.show	= show_tid_map
+	.show	= show_map
 };
 
 static int pid_maps_open(struct inode *inode, struct file *file)
@@ -393,11 +376,6 @@ static int pid_maps_open(struct inode *inode, struct file *file)
 	return do_maps_open(inode, file, &proc_pid_maps_op);
 }
 
-static int tid_maps_open(struct inode *inode, struct file *file)
-{
-	return do_maps_open(inode, file, &proc_tid_maps_op);
-}
-
 const struct file_operations proc_pid_maps_operations = {
 	.open		= pid_maps_open,
 	.read		= seq_read,
@@ -405,13 +383,6 @@ const struct file_operations proc_pid_maps_operations = {
 	.release	= proc_map_release,
 };
 
-const struct file_operations proc_tid_maps_operations = {
-	.open		= tid_maps_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= proc_map_release,
-};
-
 /*
  * Proportional Set Size(PSS): my share of RSS.
  *
@@ -733,7 +704,7 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
 
 #define SEQ_PUT_DEC(str, val) \
 		seq_put_decimal_ull_width(m, str, (val) >> 10, 8)
-static int show_smap(struct seq_file *m, void *v, int is_pid)
+static int show_smap(struct seq_file *m, void *v)
 {
 	struct proc_maps_private *priv = m->private;
 	struct vm_area_struct *vma = v;
@@ -796,7 +767,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		mss->pss_locked += mss->pss;
 
 	if (!rollup_mode) {
-		show_map_vma(m, vma, is_pid);
+		show_map_vma(m, vma);
 	} else if (last_vma) {
 		show_vma_header_prefix(
 			m, mss->first_vma_start, vma->vm_end, 0, 0, 0, 0);
@@ -845,28 +816,11 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 }
 #undef SEQ_PUT_DEC
 
-static int show_pid_smap(struct seq_file *m, void *v)
-{
-	return show_smap(m, v, 1);
-}
-
-static int show_tid_smap(struct seq_file *m, void *v)
-{
-	return show_smap(m, v, 0);
-}
-
 static const struct seq_operations proc_pid_smaps_op = {
 	.start	= m_start,
 	.next	= m_next,
 	.stop	= m_stop,
-	.show	= show_pid_smap
-};
-
-static const struct seq_operations proc_tid_smaps_op = {
-	.start	= m_start,
-	.next	= m_next,
-	.stop	= m_stop,
-	.show	= show_tid_smap
+	.show	= show_smap
 };
 
 static int pid_smaps_open(struct inode *inode, struct file *file)
@@ -893,11 +847,6 @@ static int pid_smaps_rollup_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static int tid_smaps_open(struct inode *inode, struct file *file)
-{
-	return do_maps_open(inode, file, &proc_tid_smaps_op);
-}
-
 const struct file_operations proc_pid_smaps_operations = {
 	.open		= pid_smaps_open,
 	.read		= seq_read,
@@ -912,13 +861,6 @@ const struct file_operations proc_pid_smaps_rollup_operations = {
 	.release	= proc_map_release,
 };
 
-const struct file_operations proc_tid_smaps_operations = {
-	.open		= tid_smaps_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= proc_map_release,
-};
-
 enum clear_refs_types {
 	CLEAR_REFS_ALL = 1,
 	CLEAR_REFS_ANON,
@@ -1728,7 +1670,7 @@ static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 /*
  * Display pages allocated per node and memory policy via /proc.
  */
-static int show_numa_map(struct seq_file *m, void *v, int is_pid)
+static int show_numa_map(struct seq_file *m, void *v)
 {
 	struct numa_maps_private *numa_priv = m->private;
 	struct proc_maps_private *proc_priv = &numa_priv->proc_maps;
@@ -1812,45 +1754,17 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	return 0;
 }
 
-static int show_pid_numa_map(struct seq_file *m, void *v)
-{
-	return show_numa_map(m, v, 1);
-}
-
-static int show_tid_numa_map(struct seq_file *m, void *v)
-{
-	return show_numa_map(m, v, 0);
-}
-
 static const struct seq_operations proc_pid_numa_maps_op = {
 	.start  = m_start,
 	.next   = m_next,
 	.stop   = m_stop,
-	.show   = show_pid_numa_map,
+	.show   = show_numa_map,
 };
 
-static const struct seq_operations proc_tid_numa_maps_op = {
-	.start  = m_start,
-	.next   = m_next,
-	.stop   = m_stop,
-	.show   = show_tid_numa_map,
-};
-
-static int numa_maps_open(struct inode *inode, struct file *file,
-			  const struct seq_operations *ops)
-{
-	return proc_maps_open(inode, file, ops,
-				sizeof(struct numa_maps_private));
-}
-
 static int pid_numa_maps_open(struct inode *inode, struct file *file)
 {
-	return numa_maps_open(inode, file, &proc_pid_numa_maps_op);
-}
-
-static int tid_numa_maps_open(struct inode *inode, struct file *file)
-{
-	return numa_maps_open(inode, file, &proc_tid_numa_maps_op);
+	return proc_maps_open(inode, file, &proc_pid_numa_maps_op,
+				sizeof(struct numa_maps_private));
 }
 
 const struct file_operations proc_pid_numa_maps_operations = {
@@ -1860,10 +1774,4 @@ const struct file_operations proc_pid_numa_maps_operations = {
 	.release	= proc_map_release,
 };
 
-const struct file_operations proc_tid_numa_maps_operations = {
-	.open		= tid_numa_maps_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= proc_map_release,
-};
 #endif /* CONFIG_NUMA */
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 5b62f57bd9bc..0b63d68dedb2 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -142,8 +142,7 @@ static int is_stack(struct vm_area_struct *vma)
 /*
  * display a single VMA to a sequenced file
  */
-static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
-			  int is_pid)
+static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long ino = 0;
@@ -189,22 +188,11 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
 /*
  * display mapping lines for a particular process's /proc/pid/maps
  */
-static int show_map(struct seq_file *m, void *_p, int is_pid)
+static int show_map(struct seq_file *m, void *_p)
 {
 	struct rb_node *p = _p;
 
-	return nommu_vma_show(m, rb_entry(p, struct vm_area_struct, vm_rb),
-			      is_pid);
-}
-
-static int show_pid_map(struct seq_file *m, void *_p)
-{
-	return show_map(m, _p, 1);
-}
-
-static int show_tid_map(struct seq_file *m, void *_p)
-{
-	return show_map(m, _p, 0);
+	return nommu_vma_show(m, rb_entry(p, struct vm_area_struct, vm_rb));
 }
 
 static void *m_start(struct seq_file *m, loff_t *pos)
@@ -260,14 +248,7 @@ static const struct seq_operations proc_pid_maps_ops = {
 	.start	= m_start,
 	.next	= m_next,
 	.stop	= m_stop,
-	.show	= show_pid_map
-};
-
-static const struct seq_operations proc_tid_maps_ops = {
-	.start	= m_start,
-	.next	= m_next,
-	.stop	= m_stop,
-	.show	= show_tid_map
+	.show	= show_map
 };
 
 static int maps_open(struct inode *inode, struct file *file,
@@ -308,11 +289,6 @@ static int pid_maps_open(struct inode *inode, struct file *file)
 	return maps_open(inode, file, &proc_pid_maps_ops);
 }
 
-static int tid_maps_open(struct inode *inode, struct file *file)
-{
-	return maps_open(inode, file, &proc_tid_maps_ops);
-}
-
 const struct file_operations proc_pid_maps_operations = {
 	.open		= pid_maps_open,
 	.read		= seq_read,
@@ -320,10 +296,3 @@ const struct file_operations proc_pid_maps_operations = {
 	.release	= map_release,
 };
 
-const struct file_operations proc_tid_maps_operations = {
-	.open		= tid_maps_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= map_release,
-};
-
-- 
2.18.0
