Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id F24B56B003C
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 10:25:43 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id j107so3943711qga.32
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 07:25:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h3si14888372qcf.47.2014.09.15.07.25.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 07:25:42 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [RFC PATCH v2 5/5] mm, shmem: Show location of non-resident shmem pages in smaps
Date: Mon, 15 Sep 2014 16:24:37 +0200
Message-Id: <1410791077-5300-6-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1410791077-5300-1-git-send-email-jmarchan@redhat.com>
References: <1410791077-5300-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

Adds ShmSwap and ShmNotMapped lines to /proc/<pid>/smaps for shmem
mappings.

ShmSwap: amount of memory that is paged out on disk.
ShmNotMapped: amount of memory that is currently resident in memory but
not mapped into any process. This can happens when a process unmaps a
shared mapping or exits and no other process had acccessed the page.
Despite being resident, this memory is not currently accounted to any
process and since it belongs to the mapping of another process, it can
not be discarded.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 Documentation/filesystems/proc.txt |  6 +++++
 fs/proc/task_mmu.c                 | 46 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index ffd4a7f..21eb614 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -426,6 +426,8 @@ Swap:                  0 kB
 KernelPageSize:        4 kB
 MMUPageSize:           4 kB
 Locked:              374 kB
+ShmSwap:              36 kB
+ShmNotMapped:          0 kB
 VmFlags: rd ex mr mw me de
 
 the first of these lines shows the same information as is displayed for the
@@ -441,6 +443,10 @@ a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
 and a page is modified, the file page is replaced by a private anonymous copy.
 "Swap" shows how much would-be-anonymous memory is also used, but out on
 swap.
+The ShmXXX lines only appears for shmem mapping. They show the amount of memory
+from the mapping that is currently:
+ - resident in RAM but not mapped into any process (ShmNotMapped)
+ - paged out on swap (ShmSwap).
 
 "VmFlags" field deserves a separate description. This member represents the kernel
 flags associated with the particular virtual memory area in two letter encoded
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 762257f..b697bf5 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -13,6 +13,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
+#include <linux/shmem_fs.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -455,9 +456,26 @@ struct mem_size_stats {
 	unsigned long anonymous_thp;
 	unsigned long swap;
 	unsigned long nonlinear;
+	unsigned long shmem_swap;
+	unsigned long shmem_notmapped;
 	u64 pss;
 };
 
+void update_shmem_stats(struct mem_size_stats *mss, struct vm_area_struct *vma,
+			pgoff_t pgoff, unsigned long size)
+{
+	int count = 0;
+
+	switch (shmem_locate(vma, pgoff, &count)) {
+	case SHMEM_RESIDENT:
+		if (!count)
+			mss->shmem_notmapped += size;
+		break;
+	case SHMEM_SWAP:
+		mss->shmem_swap += size;
+		break;
+	}
+}
 
 static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 		unsigned long ptent_size, struct mm_walk *walk)
@@ -480,7 +498,8 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 	} else if (pte_file(ptent)) {
 		if (pte_to_pgoff(ptent) != pgoff)
 			mss->nonlinear += ptent_size;
-	}
+	} else if (pte_none(ptent) && shmem_vma(vma))
+		update_shmem_stats(mss, vma, pgoff, ptent_size);
 
 	if (!page)
 		return;
@@ -541,6 +560,21 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
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
@@ -605,6 +639,10 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		.private = &mss,
 	};
 
+	/* Only walk the holes when it'a a shmem mapping */
+	if (shmem_vma(vma))
+		smaps_walk.pte_hole = smaps_pte_hole;
+
 	memset(&mss, 0, sizeof mss);
 	mss.vma = vma;
 	/* mmap_sem is held in m_start */
@@ -647,6 +685,12 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 	if (vma->vm_flags & VM_NONLINEAR)
 		seq_printf(m, "Nonlinear:      %8lu kB\n",
 				mss.nonlinear >> 10);
+	if (shmem_vma(vma))
+		seq_printf(m,
+			   "ShmSwap:        %8lu kB\n"
+			   "ShmNotMapped:   %8lu kB\n",
+			   mss.shmem_swap >> 10,
+			   mss.shmem_notmapped >> 10);
 
 	show_smap_vma_flags(m, vma);
 	m_cache_vma(m, vma);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
