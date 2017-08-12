Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A73846B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 22:22:14 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 83so54229330pgb.14
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 19:22:14 -0700 (PDT)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id g33si1322629plb.220.2017.08.11.19.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 19:22:12 -0700 (PDT)
Received: by mail-pg0-x231.google.com with SMTP id y129so21735854pgy.4
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 19:22:12 -0700 (PDT)
From: Daniel Colascione <dancol@google.com>
Subject: [PATCH v3] Add /proc/pid/smaps_rollup
Date: Fri, 11 Aug 2017 19:21:48 -0700
Message-Id: <20170812022148.178293-1-dancol@google.com>
In-Reply-To: <20170810001557.147285-1-dancol@google.com>
References: <20170810001557.147285-1-dancol@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, timmurray@google.com, joelaf@google.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Daniel Colascione <dancol@google.com>

/proc/pid/smaps_rollup is a new proc file that improves the
performance of user programs that determine aggregate memory
statistics (e.g., total PSS) of a process.

Android regularly "samples" the memory usage of various processes in
order to balance its memory pool sizes. This sampling process involves
opening /proc/pid/smaps and summing certain fields. For very large
processes, sampling memory use this way can take several hundred
milliseconds, due mostly to the overhead of the seq_printf calls in
task_mmu.c.

smaps_rollup improves the situation. It contains most of the fields of
/proc/pid/smaps, but instead of a set of fields for each VMA,
smaps_rollup instead contains one synthetic smaps-format entry
representing the whole process. In the single smaps_rollup synthetic
entry, each field is the summation of the corresponding field in all
of the real-smaps VMAs. Using a common format for smaps_rollup and
smaps allows userspace parsers to repurpose parsers meant for use with
non-rollup smaps for smaps_rollup, and it allows userspace to switch
between smaps_rollup and smaps at runtime (say, based on the
availability of smaps_rollup in a given kernel) with minimal fuss.

By using smaps_rollup instead of smaps, a caller can avoid the
significant overhead of formatting, reading, and parsing each of a
large process's potentially very numerous memory mappings. For
sampling system_server's PSS in Android, we measured a 12x speedup,
representing a savings of several hundred milliseconds.

One alternative to a new per-process proc file would have been
including PSS information in /proc/pid/status. We considered this
option but thought that PSS would be too expensive (by a few orders of
magnitude) to collect relative to what's already emitted as part of
/proc/pid/status, and slowing every user of /proc/pid/status for the
sake of readers that happen to want PSS feels wrong.

The code itself works by reusing the existing VMA-walking framework we
use for regular smaps generation and keeping the mem_size_stats
structure around between VMA walks instead of using a fresh one for
each VMA.  In this way, summation happens automatically.  We let
seq_file walk over the VMAs just as it does for regular smaps and just
emit nothing to the seq_file until we hit the last VMA.

Benchmarks:

    using smaps:
    iterations:1000 pid:1163 pss:220023808
    0m29.46s real 0m08.28s user 0m20.98s system

    using smaps_rollup:
    iterations:1000 pid:1163 pss:220702720
    0m04.39s real 0m00.03s user 0m04.31s system

Patch changelog:

v2: Fix typo in commit message
    Add ABI documentation as requested by gregkh
v3: Fix typo in ABI documentation
    Add benchmarks to commit message

Signed-off-by: Daniel Colascione <dancol@google.com>
---
 Documentation/ABI/testing/procfs-smaps_rollup |  34 +++++
 fs/proc/base.c                                |   2 +
 fs/proc/internal.h                            |   3 +
 fs/proc/task_mmu.c                            | 196 ++++++++++++++++++--------
 4 files changed, 173 insertions(+), 62 deletions(-)
 create mode 100644 Documentation/ABI/testing/procfs-smaps_rollup

diff --git a/Documentation/ABI/testing/procfs-smaps_rollup b/Documentation/ABI/testing/procfs-smaps_rollup
new file mode 100644
index 000000000000..8c24138a7279
--- /dev/null
+++ b/Documentation/ABI/testing/procfs-smaps_rollup
@@ -0,0 +1,34 @@
+What:		/proc/pid/smaps_rollup
+Date:		August 2017
+Contact:	Daniel Colascione <dancol@google.com>
+Description:
+		This file provides pre-summed memory information for a
+		process.  The format is identical to /proc/pid/smaps,
+		except instead of an entry for each VMA in a process,
+		smaps_rollup has a single entry (tagged "[rollup]")
+		for which each field is the sum of the corresponding
+		fields from all the maps in /proc/pid/smaps.
+		For more details, see the procfs man page.
+
+		Typical output looks like this:
+
+		00100000-ff709000 ---p 00000000 00:00 0		 [rollup]
+		Rss:		     884 kB
+		Pss:		     385 kB
+		Shared_Clean:	     696 kB
+		Shared_Dirty:	       0 kB
+		Private_Clean:	     120 kB
+		Private_Dirty:	      68 kB
+		Referenced:	     884 kB
+		Anonymous:	      68 kB
+		LazyFree:	       0 kB
+		AnonHugePages:	       0 kB
+		ShmemPmdMapped:	       0 kB
+		Shared_Hugetlb:	       0 kB
+		Private_Hugetlb:       0 kB
+		Swap:		       0 kB
+		SwapPss:	       0 kB
+		Locked:		     385 kB
+
+
+		
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 719c2e943ea1..a9587b9cace5 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2930,6 +2930,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_PROC_PAGE_MONITOR
 	REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
 	REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
+	REG("smaps_rollup", S_IRUGO, proc_pid_smaps_rollup_operations),
 	REG("pagemap",    S_IRUSR, proc_pagemap_operations),
 #endif
 #ifdef CONFIG_SECURITY
@@ -3323,6 +3324,7 @@ static const struct pid_entry tid_base_stuff[] = {
 #ifdef CONFIG_PROC_PAGE_MONITOR
 	REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
 	REG("smaps",     S_IRUGO, proc_tid_smaps_operations),
+	REG("smaps_rollup", S_IRUGO, proc_pid_smaps_rollup_operations),
 	REG("pagemap",    S_IRUSR, proc_pagemap_operations),
 #endif
 #ifdef CONFIG_SECURITY
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index aa2b89071630..2cbfcd32e884 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -269,10 +269,12 @@ extern int proc_remount(struct super_block *, int *, char *);
 /*
  * task_[no]mmu.c
  */
+struct mem_size_stats;
 struct proc_maps_private {
 	struct inode *inode;
 	struct task_struct *task;
 	struct mm_struct *mm;
+	struct mem_size_stats *rollup;
 #ifdef CONFIG_MMU
 	struct vm_area_struct *tail_vma;
 #endif
@@ -288,6 +290,7 @@ extern const struct file_operations proc_tid_maps_operations;
 extern const struct file_operations proc_pid_numa_maps_operations;
 extern const struct file_operations proc_tid_numa_maps_operations;
 extern const struct file_operations proc_pid_smaps_operations;
+extern const struct file_operations proc_pid_smaps_rollup_operations;
 extern const struct file_operations proc_tid_smaps_operations;
 extern const struct file_operations proc_clear_refs_operations;
 extern const struct file_operations proc_pagemap_operations;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index b836fd61ed87..02b55df7291c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -252,6 +252,7 @@ static int proc_map_release(struct inode *inode, struct file *file)
 	if (priv->mm)
 		mmdrop(priv->mm);
 
+	kfree(priv->rollup);
 	return seq_release_private(inode, file);
 }
 
@@ -278,6 +279,23 @@ static int is_stack(struct proc_maps_private *priv,
 		vma->vm_end >= vma->vm_mm->start_stack;
 }
 
+static void show_vma_header_prefix(struct seq_file *m,
+				   unsigned long start, unsigned long end,
+				   vm_flags_t flags, unsigned long long pgoff,
+				   dev_t dev, unsigned long ino)
+{
+	seq_setwidth(m, 25 + sizeof(void *) * 6 - 1);
+	seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu ",
+		   start,
+		   end,
+		   flags & VM_READ ? 'r' : '-',
+		   flags & VM_WRITE ? 'w' : '-',
+		   flags & VM_EXEC ? 'x' : '-',
+		   flags & VM_MAYSHARE ? 's' : 'p',
+		   pgoff,
+		   MAJOR(dev), MINOR(dev), ino);
+}
+
 static void
 show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 {
@@ -300,17 +318,7 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 
 	start = vma->vm_start;
 	end = vma->vm_end;
-
-	seq_setwidth(m, 25 + sizeof(void *) * 6 - 1);
-	seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu ",
-			start,
-			end,
-			flags & VM_READ ? 'r' : '-',
-			flags & VM_WRITE ? 'w' : '-',
-			flags & VM_EXEC ? 'x' : '-',
-			flags & VM_MAYSHARE ? 's' : 'p',
-			pgoff,
-			MAJOR(dev), MINOR(dev), ino);
+	show_vma_header_prefix(m, start, end, flags, pgoff, dev, ino);
 
 	/*
 	 * Print the dentry name for named mappings, and a
@@ -429,6 +437,7 @@ const struct file_operations proc_tid_maps_operations = {
 
 #ifdef CONFIG_PROC_PAGE_MONITOR
 struct mem_size_stats {
+	bool first;
 	unsigned long resident;
 	unsigned long shared_clean;
 	unsigned long shared_dirty;
@@ -442,7 +451,9 @@ struct mem_size_stats {
 	unsigned long swap;
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
+	unsigned long first_vma_start;
 	u64 pss;
+	u64 pss_locked;
 	u64 swap_pss;
 	bool check_shmem_swap;
 };
@@ -718,18 +729,36 @@ void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
 
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
+	struct proc_maps_private *priv = m->private;
 	struct vm_area_struct *vma = v;
-	struct mem_size_stats mss;
+	struct mem_size_stats mss_stack;
+	struct mem_size_stats *mss;
 	struct mm_walk smaps_walk = {
 		.pmd_entry = smaps_pte_range,
 #ifdef CONFIG_HUGETLB_PAGE
 		.hugetlb_entry = smaps_hugetlb_range,
 #endif
 		.mm = vma->vm_mm,
-		.private = &mss,
 	};
+	int ret = 0;
+	bool rollup_mode;
+	bool last_vma;
+
+	if (priv->rollup) {
+		rollup_mode = true;
+		mss = priv->rollup;
+		if (mss->first) {
+			mss->first_vma_start = vma->vm_start;
+			mss->first = false;
+		}
+		last_vma = !m_next_vma(priv, vma);
+	} else {
+		rollup_mode = false;
+		memset(&mss_stack, 0, sizeof(mss_stack));
+		mss = &mss_stack;
+	}
 
-	memset(&mss, 0, sizeof mss);
+	smaps_walk.private = mss;
 
 #ifdef CONFIG_SHMEM
 	if (vma->vm_file && shmem_mapping(vma->vm_file->f_mapping)) {
@@ -747,9 +776,9 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 
 		if (!shmem_swapped || (vma->vm_flags & VM_SHARED) ||
 					!(vma->vm_flags & VM_WRITE)) {
-			mss.swap = shmem_swapped;
+			mss->swap = shmem_swapped;
 		} else {
-			mss.check_shmem_swap = true;
+			mss->check_shmem_swap = true;
 			smaps_walk.pte_hole = smaps_pte_hole;
 		}
 	}
@@ -757,54 +786,71 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 
 	/* mmap_sem is held in m_start */
 	walk_page_vma(vma, &smaps_walk);
+	if (vma->vm_flags & VM_LOCKED)
+		mss->pss_locked += mss->pss;
+
+	if (!rollup_mode) {
+		show_map_vma(m, vma, is_pid);
+	} else if (last_vma) {
+		show_vma_header_prefix(
+			m, mss->first_vma_start, vma->vm_end, 0, 0, 0, 0);
+		seq_pad(m, ' ');
+		seq_puts(m, "[rollup]\n");
+	} else {
+		ret = SEQ_SKIP;
+	}
 
-	show_map_vma(m, vma, is_pid);
-
-	seq_printf(m,
-		   "Size:           %8lu kB\n"
-		   "Rss:            %8lu kB\n"
-		   "Pss:            %8lu kB\n"
-		   "Shared_Clean:   %8lu kB\n"
-		   "Shared_Dirty:   %8lu kB\n"
-		   "Private_Clean:  %8lu kB\n"
-		   "Private_Dirty:  %8lu kB\n"
-		   "Referenced:     %8lu kB\n"
-		   "Anonymous:      %8lu kB\n"
-		   "LazyFree:       %8lu kB\n"
-		   "AnonHugePages:  %8lu kB\n"
-		   "ShmemPmdMapped: %8lu kB\n"
-		   "Shared_Hugetlb: %8lu kB\n"
-		   "Private_Hugetlb: %7lu kB\n"
-		   "Swap:           %8lu kB\n"
-		   "SwapPss:        %8lu kB\n"
-		   "KernelPageSize: %8lu kB\n"
-		   "MMUPageSize:    %8lu kB\n"
-		   "Locked:         %8lu kB\n",
-		   (vma->vm_end - vma->vm_start) >> 10,
-		   mss.resident >> 10,
-		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
-		   mss.shared_clean  >> 10,
-		   mss.shared_dirty  >> 10,
-		   mss.private_clean >> 10,
-		   mss.private_dirty >> 10,
-		   mss.referenced >> 10,
-		   mss.anonymous >> 10,
-		   mss.lazyfree >> 10,
-		   mss.anonymous_thp >> 10,
-		   mss.shmem_thp >> 10,
-		   mss.shared_hugetlb >> 10,
-		   mss.private_hugetlb >> 10,
-		   mss.swap >> 10,
-		   (unsigned long)(mss.swap_pss >> (10 + PSS_SHIFT)),
-		   vma_kernel_pagesize(vma) >> 10,
-		   vma_mmu_pagesize(vma) >> 10,
-		   (vma->vm_flags & VM_LOCKED) ?
-			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
-
-	arch_show_smap(m, vma);
-	show_smap_vma_flags(m, vma);
+	if (!rollup_mode)
+		seq_printf(m,
+			   "Size:           %8lu kB\n"
+			   "KernelPageSize: %8lu kB\n"
+			   "MMUPageSize:    %8lu kB\n",
+			   (vma->vm_end - vma->vm_start) >> 10,
+			   vma_kernel_pagesize(vma) >> 10,
+			   vma_mmu_pagesize(vma) >> 10);
+
+
+	if (!rollup_mode || last_vma)
+		seq_printf(m,
+			   "Rss:            %8lu kB\n"
+			   "Pss:            %8lu kB\n"
+			   "Shared_Clean:   %8lu kB\n"
+			   "Shared_Dirty:   %8lu kB\n"
+			   "Private_Clean:  %8lu kB\n"
+			   "Private_Dirty:  %8lu kB\n"
+			   "Referenced:     %8lu kB\n"
+			   "Anonymous:      %8lu kB\n"
+			   "LazyFree:       %8lu kB\n"
+			   "AnonHugePages:  %8lu kB\n"
+			   "ShmemPmdMapped: %8lu kB\n"
+			   "Shared_Hugetlb: %8lu kB\n"
+			   "Private_Hugetlb: %7lu kB\n"
+			   "Swap:           %8lu kB\n"
+			   "SwapPss:        %8lu kB\n"
+			   "Locked:         %8lu kB\n",
+			   mss->resident >> 10,
+			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)),
+			   mss->shared_clean  >> 10,
+			   mss->shared_dirty  >> 10,
+			   mss->private_clean >> 10,
+			   mss->private_dirty >> 10,
+			   mss->referenced >> 10,
+			   mss->anonymous >> 10,
+			   mss->lazyfree >> 10,
+			   mss->anonymous_thp >> 10,
+			   mss->shmem_thp >> 10,
+			   mss->shared_hugetlb >> 10,
+			   mss->private_hugetlb >> 10,
+			   mss->swap >> 10,
+			   (unsigned long)(mss->swap_pss >> (10 + PSS_SHIFT)),
+			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
+
+	if (!rollup_mode) {
+		arch_show_smap(m, vma);
+		show_smap_vma_flags(m, vma);
+	}
 	m_cache_vma(m, vma);
-	return 0;
+	return ret;
 }
 
 static int show_pid_smap(struct seq_file *m, void *v)
@@ -836,6 +882,25 @@ static int pid_smaps_open(struct inode *inode, struct file *file)
 	return do_maps_open(inode, file, &proc_pid_smaps_op);
 }
 
+static int pid_smaps_rollup_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	struct proc_maps_private *priv;
+	int ret = do_maps_open(inode, file, &proc_pid_smaps_op);
+
+	if (ret < 0)
+		return ret;
+	seq = file->private_data;
+	priv = seq->private;
+	priv->rollup = kzalloc(sizeof(*priv->rollup), GFP_KERNEL);
+	if (!priv->rollup) {
+		proc_map_release(inode, file);
+		return -ENOMEM;
+	}
+	priv->rollup->first = true;
+	return 0;
+}
+
 static int tid_smaps_open(struct inode *inode, struct file *file)
 {
 	return do_maps_open(inode, file, &proc_tid_smaps_op);
@@ -848,6 +913,13 @@ const struct file_operations proc_pid_smaps_operations = {
 	.release	= proc_map_release,
 };
 
+const struct file_operations proc_pid_smaps_rollup_operations = {
+	.open		= pid_smaps_rollup_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= proc_map_release,
+};
+
 const struct file_operations proc_tid_smaps_operations = {
 	.open		= tid_smaps_open,
 	.read		= seq_read,
-- 
2.14.0.434.g98096fd7a8-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
