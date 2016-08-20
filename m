Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3236B0253
	for <linux-mm@kvack.org>; Sat, 20 Aug 2016 04:00:25 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id q83so181792982iod.0
        for <linux-mm@kvack.org>; Sat, 20 Aug 2016 01:00:25 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0103.hostedemail.com. [216.40.44.103])
        by mx.google.com with ESMTPS id l66si11295976iof.252.2016.08.20.01.00.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Aug 2016 01:00:25 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] proc: task_mmu: Reduce output processing cpu time
Date: Sat, 20 Aug 2016 01:00:17 -0700
Message-Id: <2c1ea0d8f35fa5ddea477369b273d6d91c5bf2e2.1471679737.git.joe@perches.com>
In-Reply-To: <20160820072927.GA23645@dhcp22.suse.cz>
References: <20160820072927.GA23645@dhcp22.suse.cz>
In-Reply-To: <cover.1471679737.git.joe@perches.com>
References: <cover.1471679737.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org

Use the new __seq_open_private_buffer to estimate the final
output /proc/<pid>/smaps filesize to reduce the number of
reallocations of overflowed buffers.

Use a simpler single-line function to emit various values in kB.

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/proc/task_mmu.c | 94 ++++++++++++++++++++++++++++--------------------------
 1 file changed, 48 insertions(+), 46 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 187d84e..170509b 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -224,19 +224,21 @@ static void m_stop(struct seq_file *m, void *v)
 static int proc_maps_open(struct inode *inode, struct file *file,
 			const struct seq_operations *ops, int psize)
 {
-	struct proc_maps_private *priv = __seq_open_private(file, ops, psize);
+	struct proc_maps_private *priv;
+	struct mm_struct *mm;
+
+	mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	if (IS_ERR(mm))
+		return PTR_ERR(mm);
 
+	priv = __seq_open_private_bufsize(file, ops, psize,
+					  mm && mm->map_count ?
+					  mm->map_count * 0x300 : PAGE_SIZE);
 	if (!priv)
 		return -ENOMEM;
 
 	priv->inode = inode;
-	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
-	if (IS_ERR(priv->mm)) {
-		int err = PTR_ERR(priv->mm);
-
-		seq_release_private(inode, file);
-		return err;
-	}
+	priv->mm = mm;
 
 	return 0;
 }
@@ -721,6 +723,25 @@ void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
 {
 }
 
+static void show_val_kb(struct seq_file *m, const char *s, unsigned long num)
+{
+	char v[32];
+	static const char blanks[7] = {' ', ' ', ' ', ' ',' ', ' ', ' '};
+	int len;
+
+	len = num_to_str(v, sizeof(v), num >> 10);
+
+	seq_write(m, s, 16);
+
+	if (len > 0) {
+		if (len < 8)
+			seq_write(m, blanks, 8 - len);
+
+		seq_write(m, v, len);
+	}
+	seq_write(m, " kB\n", 4);
+}
+
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct vm_area_struct *vma = v;
@@ -765,44 +786,25 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 
 	show_map_vma(m, vma, is_pid);
 
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
+	show_val_kb(m, "Size:           ", vma->vm_end - vma->vm_start);
+	show_val_kb(m, "Rss:            ", mss.resident);
+	show_val_kb(m, "Pss:            ", mss.pss >> PSS_SHIFT);
+	show_val_kb(m, "Shared_Clean:   ", mss.shared_clean);
+	show_val_kb(m, "Shared_Dirty:   ", mss.shared_dirty);
+	show_val_kb(m, "Private_Clean:  ", mss.private_clean);
+	show_val_kb(m, "Private_Dirty:  ", mss.private_dirty);
+	show_val_kb(m, "Referenced:     ", mss.referenced);
+	show_val_kb(m, "Anonymous:      ", mss.anonymous);
+	show_val_kb(m, "AnonHugePages:  ", mss.anonymous_thp);
+	show_val_kb(m, "ShmemPmdMapped: ", mss.shmem_thp);
+	show_val_kb(m, "Shared_Hugetlb: ", mss.shared_hugetlb);
+	seq_printf(m, "Private_Hugetlb: %7lu kB\n",  mss.private_hugetlb >> 10);
+	show_val_kb(m, "Swap:           ", mss.swap);
+	show_val_kb(m, "SwapPss:        ", mss.swap_pss >> PSS_SHIFT);
+	show_val_kb(m, "KernelPageSize: ", vma_kernel_pagesize(vma));
+	show_val_kb(m, "MMUPageSize:    ", vma_mmu_pagesize(vma));
+	show_val_kb(m, "Locked:         ",
+		    vma->vm_flags & VM_LOCKED ? mss.pss >> PSS_SHIFT : 0);
 
 	arch_show_smap(m, vma);
 	show_smap_vma_flags(m, vma);
-- 
2.8.0.rc4.16.g56331f8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
