Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 980B56B0039
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 09:02:21 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id ij19so8871769vcb.23
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 06:02:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n5si29184724qco.32.2014.07.01.06.02.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 06:02:20 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH 5/5] mm, shmem: Show location of non-resident shmem pages in smaps
Date: Tue,  1 Jul 2014 15:02:01 +0200
Message-Id: <1404219721-32241-6-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1404219721-32241-1-git-send-email-jmarchan@redhat.com>
References: <1404219721-32241-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

Adds ShmOther, ShmOrphan, ShmSwapCache and ShmSwap lines to
/proc/<pid>/smaps for shmem mappings.

ShmOther: amount of memory that is currently resident in memory, not
present in the page table of this process but present in the page
table of an other process.
ShmOrphan: amount of memory that is currently resident in memory but
not present in any process page table. This can happens when a process
unmaps a shared mapping it has accessed before or exits. Despite being
resident, this memory is not currently accounted to any process.
ShmSwapcache: amount of memory currently in swap cache
ShmSwap: amount of memory that is paged out on disk.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 Documentation/filesystems/proc.txt | 11 ++++++++
 fs/proc/task_mmu.c                 | 56 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 66 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 1a15c56..a65ab59 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -422,6 +422,10 @@ Swap:                  0 kB
 KernelPageSize:        4 kB
 MMUPageSize:           4 kB
 Locked:              374 kB
+ShmOther:            124 kB
+ShmOrphan:             0 kB
+ShmSwapCache:         12 kB
+ShmSwap:              36 kB
 VmFlags: rd ex mr mw me de
 
 the first of these lines shows the same information as is displayed for the
@@ -437,6 +441,13 @@ a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
 and a page is modified, the file page is replaced by a private anonymous copy.
 "Swap" shows how much would-be-anonymous memory is also used, but out on
 swap.
+The ShmXXX lines only appears for shmem mapping. They show the amount of memory
+from the mapping that is currently:
+ - resident in RAM, not present in the page table of this process but present
+ in the page table of an other process (ShmOther)
+ - resident in RAM but not present in the page table of any process (ShmOrphan)
+ - in swap cache (ShmSwapCache)
+ - paged out on swap (ShmSwap).
 
 "VmFlags" field deserves a separate description. This member represents the kernel
 flags associated with the particular virtual memory area in two letter encoded
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 73f0ce4..9b1de55 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -518,9 +518,33 @@ struct mem_size_stats {
 	unsigned long anonymous_thp;
 	unsigned long swap;
 	unsigned long nonlinear;
+	unsigned long shmem_resident_other;
+	unsigned long shmem_swapcache;
+	unsigned long shmem_swap;
+	unsigned long shmem_orphan;
 	u64 pss;
 };
 
+void update_shmem_stats(struct mem_size_stats *mss, struct vm_area_struct *vma,
+			pgoff_t pgoff, unsigned long size)
+{
+	int count = 0;
+
+	switch (shmem_locate(vma, pgoff, &count)) {
+	case SHMEM_RESIDENT:
+		if (count)
+			mss->shmem_resident_other += size;
+		else
+			mss->shmem_orphan += size;
+		break;
+	case SHMEM_SWAPCACHE:
+		mss->shmem_swapcache += size;
+		break;
+	case SHMEM_SWAP:
+		mss->shmem_swap += size;
+		break;
+	}
+}
 
 static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 		unsigned long ptent_size, struct mm_walk *walk)
@@ -543,7 +567,8 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 	} else if (pte_file(ptent)) {
 		if (pte_to_pgoff(ptent) != pgoff)
 			mss->nonlinear += ptent_size;
-	}
+	} else if (pte_none(ptent) && shmem_vma(vma))
+		update_shmem_stats(mss, vma, pgoff, ptent_size);
 
 	if (!page)
 		return;
@@ -604,6 +629,21 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	return 0;
 }
 
+static int smaps_pte_hole(unsigned long addr, unsigned long end,
+			  struct mm_walk *walk)
+{
+	struct mem_size_stats *mss = walk->private;
+	struct vm_area_struct *vma = mss->vma;
+	pgoff_t pgoff;
+
+	for (; addr != end; addr += PAGE_SIZE) {
+		pgoff = linear_page_index(vma, addr);
+		update_shmem_stats(mss, vma, pgoff, PAGE_SIZE);
+	}
+
+	return 0;
+}
+
 static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 {
 	/*
@@ -670,6 +710,10 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		.private = &mss,
 	};
 
+	/* Only walk the holes when it'a a shmem mapping */
+	if (shmem_vma(vma))
+		smaps_walk.pte_hole = smaps_pte_hole;
+
 	memset(&mss, 0, sizeof mss);
 	mss.vma = vma;
 	/* mmap_sem is held in m_start */
@@ -712,6 +756,16 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 	if (vma->vm_flags & VM_NONLINEAR)
 		seq_printf(m, "Nonlinear:      %8lu kB\n",
 				mss.nonlinear >> 10);
+	if (shmem_vma(vma))
+		seq_printf(m,
+			   "ShmOther:       %8lu kB\n"
+			   "ShmOrphan:      %8lu kB\n"
+			   "ShmSwapCache:   %8lu kB\n"
+			   "ShmSwap:        %8lu kB\n",
+			   mss.shmem_resident_other >> 10,
+			   mss.shmem_orphan >> 10,
+			   mss.shmem_swapcache >> 10,
+			   mss.shmem_swap >> 10);
 
 	show_smap_vma_flags(m, vma);
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
