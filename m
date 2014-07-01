Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA926B0038
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 09:02:18 -0400 (EDT)
Received: by mail-qc0-f175.google.com with SMTP id i8so8245228qcq.20
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 06:02:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p8si14372211qct.15.2014.07.01.06.02.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 06:02:18 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH 4/5] mm, shmem: Add shmem swap memory accounting
Date: Tue,  1 Jul 2014 15:02:00 +0200
Message-Id: <1404219721-32241-5-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1404219721-32241-1-git-send-email-jmarchan@redhat.com>
References: <1404219721-32241-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

Adds get_mm_shswap() which compute the size of swaped out shmem. It
does so by pagewalking the mm and using the new shmem_locate() function
to get the physical location of shmem pages.
The result is displayed in the new VmShSw line of /proc/<pid>/status.
Use mm_walk an shmem_locate() to account paged out shmem pages.

It significantly slows down /proc/<pid>/status acccess speed when
there is a big shmem mapping. If that is an issue, we can drop this
patch and only display this counter in the inherently slower
/proc/<pid>/smaps file (cf. next patch).

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 Documentation/filesystems/proc.txt |  2 +
 fs/proc/task_mmu.c                 | 80 ++++++++++++++++++++++++++++++++++++--
 2 files changed, 79 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 1c49957..1a15c56 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -172,6 +172,7 @@ read the file /proc/PID/status:
   VmPTE:        20 kb
   VmSwap:        0 kB
   VmShm:         0 kB
+  VmShSw:        0 kB
   Threads:        1
   SigQ:   0/28578
   SigPnd: 0000000000000000
@@ -230,6 +231,7 @@ Table 1-2: Contents of the status files (as of 2.6.30-rc7)
  VmPTE                       size of page table entries
  VmSwap                      size of swap usage (the number of referred swapents)
  VmShm	                      size of resident shmem memory
+ VmShSw                      size of paged out shmem memory
  Threads                     number of threads
  SigQ                        number of signals queued/max. number for queue
  SigPnd                      bitmap of pending signals for the thread
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 4e60751..73f0ce4 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -19,9 +19,80 @@
 #include <asm/tlbflush.h>
 #include "internal.h"
 
+struct shswap_stats {
+	struct vm_area_struct *vma;
+	unsigned long shswap;
+};
+
+#ifdef CONFIG_SHMEM
+static int shswap_pte(pte_t *pte, unsigned long addr, unsigned long end,
+		       struct mm_walk *walk)
+{
+	struct shswap_stats *shss = walk->private;
+	struct vm_area_struct *vma = shss->vma;
+	pgoff_t pgoff = linear_page_index(vma, addr);
+	pte_t ptent = *pte;
+
+	if (pte_none(ptent) &&
+	    shmem_locate(vma, pgoff, NULL) == SHMEM_SWAP)
+		shss->shswap += end - addr;
+
+	return 0;
+}
+
+static int shswap_pte_hole(unsigned long addr, unsigned long end,
+			   struct mm_walk *walk)
+{
+	struct shswap_stats *shss = walk->private;
+	struct vm_area_struct *vma = shss->vma;
+	pgoff_t pgoff;
+
+	for (; addr != end; addr += PAGE_SIZE) {
+		pgoff = linear_page_index(vma, addr);
+
+		if (shmem_locate(vma, pgoff, NULL) == SHMEM_SWAP)
+			shss->shswap += PAGE_SIZE;
+	}
+
+	return 0;
+}
+
+static unsigned long get_mm_shswap(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+	struct shswap_stats shss;
+	struct mm_walk shswap_walk = {
+		.pte_entry = shswap_pte,
+		.pte_hole = shswap_pte_hole,
+		.mm = mm,
+		.private = &shss,
+	};
+
+	memset(&shss, 0, sizeof(shss));
+
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next)
+		if (shmem_vma(vma)) {
+			shss.vma = vma;
+			walk_page_range(vma->vm_start, vma->vm_end,
+					&shswap_walk);
+		}
+	up_read(&mm->mmap_sem);
+
+	return shss.shswap;
+}
+
+#else
+
+static unsigned long get_mm_shswap(struct mm_struct *mm)
+{
+	return 0;
+}
+#endif
+
 void task_mem(struct seq_file *m, struct mm_struct *mm)
 {
-	unsigned long data, text, lib, swap, shmem;
+	unsigned long data, text, lib, swap, shmem, shswap;
 	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
 
 	/*
@@ -43,6 +114,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
 	swap = get_mm_counter(mm, MM_SWAPENTS);
 	shmem = get_mm_counter(mm, MM_SHMEMPAGES);
+	shswap = get_mm_shswap(mm);
 	seq_printf(m,
 		"VmPeak:\t%8lu kB\n"
 		"VmSize:\t%8lu kB\n"
@@ -56,7 +128,8 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"VmLib:\t%8lu kB\n"
 		"VmPTE:\t%8lu kB\n"
 		"VmSwap:\t%8lu kB\n"
-		"VmShm:\t%8lu kB\n",
+		"VmShm:\t%8lu kB\n"
+		"VmShSw:\t%8lu kB\n",
 		hiwater_vm << (PAGE_SHIFT-10),
 		total_vm << (PAGE_SHIFT-10),
 		mm->locked_vm << (PAGE_SHIFT-10),
@@ -68,7 +141,8 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		(PTRS_PER_PTE * sizeof(pte_t) *
 		 atomic_long_read(&mm->nr_ptes)) >> 10,
 		swap << (PAGE_SHIFT-10),
-		shmem << (PAGE_SHIFT-10));
+		shmem << (PAGE_SHIFT-10),
+		shswap >> 10);
 }
 
 unsigned long task_vsize(struct mm_struct *mm)
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
