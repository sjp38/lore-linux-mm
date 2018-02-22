Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id D72D06B028B
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 00:27:12 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id v19so2427874ywg.3
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 21:27:12 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id k196sor134681ybk.115.2018.02.21.21.27.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 21:27:11 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 21 Feb 2018 21:26:59 -0800
In-Reply-To: <20180222052659.106016-1-dancol@google.com>
Message-Id: <20180222052659.106016-3-dancol@google.com>
References: <20180222052659.106016-1-dancol@google.com>
Subject: [PATCH 2/2] Add LockedRss/LockedPrivate to smaps and smaps_rollup
From: Daniel Colascione <dancol@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Daniel Colascione <dancol@google.com>

These additional fields in smaps make it easy to analyze a processes's
contribution to locked memory without having to manually filter and
sum entries from smaps. VmLck from /proc/pid/status isn't quite right,
because it reflects the number of potentially locked pages in lockable
VMAs, not the number of pages actually pinned.

Signed-off-by: Daniel Colascione <dancol@google.com>
---
 Documentation/filesystems/proc.txt |  7 ++++++-
 fs/proc/task_mmu.c                 | 20 +++++++++++++++++---
 2 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 2a84bb334894..e87350400cd9 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -425,6 +425,7 @@ SwapPss:               0 kB
 KernelPageSize:        4 kB
 MMUPageSize:           4 kB
 Locked:                0 kB
+LockedRss:             0 kB
 VmFlags: rd ex mr mw me dw
 
 the first of these lines shows the same information as is displayed for the
@@ -461,7 +462,11 @@ For shmem mappings, "Swap" includes also the size of the mapped (and not
 replaced by copy-on-write) part of the underlying shmem object out on swap.
 "SwapPss" shows proportional swap share of this mapping. Unlike "Swap", this
 does not take into account swapped out page of underlying shmem objects.
-"Locked" indicates whether the mapping is locked in memory or not.
+"Locked" contains the PSS for locked mappings; "LockedRss" contains the
+amount resident and locked memory in the given mapping. That is, "Locked"
+depends on other processes also potentially mapping the given memory, while
+"LockedRss" is invariant. "LockedPrivate" is like "LockedRss", but counts only
+the pages unique to the process.
 
 "VmFlags" field deserves a separate description. This member represents the kernel
 flags associated with the particular virtual memory area in two letter encoded
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 5e95f7eaf145..598a7f855ad1 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -459,6 +459,8 @@ struct mem_size_stats {
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
 	unsigned long first_vma_start;
+	unsigned long resident_locked;
+	unsigned long private_locked;
 	u64 pss;
 	u64 pss_locked;
 	u64 swap_pss;
@@ -472,6 +474,7 @@ static void smaps_account(struct mem_size_stats *mss,
 	int i, nr = compound ? 1 << compound_order(page) : 1;
 	unsigned long size = nr * PAGE_SIZE;
 	u64 pss_add = 0;
+	bool locked = vma->vm_flags & VM_LOCKED;
 
 	if (PageAnon(page)) {
 		mss->anonymous += size;
@@ -480,6 +483,9 @@ static void smaps_account(struct mem_size_stats *mss,
 	}
 
 	mss->resident += size;
+	if (locked)
+		mss->resident_locked += size;
+
 	/* Accumulate the size in pages that have been accessed. */
 	if (young || page_is_young(page) || PageReferenced(page))
 		mss->referenced += size;
@@ -495,6 +501,8 @@ static void smaps_account(struct mem_size_stats *mss,
 		else
 			mss->private_clean += size;
 		pss_add += (u64)size << PSS_SHIFT;
+		if (locked)
+			mss->private_locked += size;
 		goto done;
 	}
 
@@ -513,12 +521,14 @@ static void smaps_account(struct mem_size_stats *mss,
 			else
 				mss->private_clean += PAGE_SIZE;
 			pss_add += PAGE_SIZE << PSS_SHIFT;
+			if (locked)
+				mss->private_locked += size;
 		}
 	}
 
 done:
 	mss->pss += pss_add;
-	if (vma->vm_flags & VM_LOCKED)
+	if (locked)
 		mss->pss_locked += pss_add;
 }
 
@@ -859,7 +869,9 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 			   "Private_Hugetlb: %7lu kB\n"
 			   "Swap:           %8lu kB\n"
 			   "SwapPss:        %8lu kB\n"
-			   "Locked:         %8lu kB\n",
+			   "Locked:         %8lu kB\n"
+			   "LockedRss:      %8lu kB\n"
+			   "LockedPrivate:  %8lu kB\n",
 			   mss->resident >> 10,
 			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)),
 			   mss->shared_clean  >> 10,
@@ -875,7 +887,9 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 			   mss->private_hugetlb >> 10,
 			   mss->swap >> 10,
 			   (unsigned long)(mss->swap_pss >> (10 + PSS_SHIFT)),
-			   (unsigned long)(mss->pss_locked >> (10 + PSS_SHIFT)));
+			   (unsigned long)(mss->pss_locked >> (10 + PSS_SHIFT)),
+			   mss->resident_locked >> 10,
+			   mss->private_locked >> 10);
 
 	if (!rollup_mode) {
 		arch_show_smap(m, vma);
-- 
2.16.1.291.g4437f3f132-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
