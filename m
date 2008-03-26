Subject: [PATCH] smaps: account swap entries
From: Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain
Date: Wed, 26 Mar 2008 16:28:24 +0100
Message-Id: <1206545304.8514.494.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Subject: smaps: account swap entries
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mpm <mpm@selenic.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Show the amount of swap for each vma. This can be used to see where all the
swap goes.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/proc/task_mmu.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

Index: linux-2.6/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.orig/fs/proc/task_mmu.c
+++ linux-2.6/fs/proc/task_mmu.c
@@ -313,6 +313,7 @@ struct mem_size_stats
 	unsigned long private_clean;
 	unsigned long private_dirty;
 	unsigned long referenced;
+	unsigned long swap;
 	u64 pss;
 };
 
@@ -329,6 +330,12 @@ static int smaps_pte_range(pmd_t *pmd, u
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
 		ptent = *pte;
+
+		if (is_swap_pte(ptent)) {
+			mss->swap += PAGE_SIZE;
+			continue;
+		}
+
 		if (!pte_present(ptent))
 			continue;
 
@@ -387,7 +394,8 @@ static int show_smap(struct seq_file *m,
 		   "Shared_Dirty:   %8lu kB\n"
 		   "Private_Clean:  %8lu kB\n"
 		   "Private_Dirty:  %8lu kB\n"
-		   "Referenced:     %8lu kB\n",
+		   "Referenced:     %8lu kB\n"
+		   "Swap:           %8lu kB\n",
 		   (vma->vm_end - vma->vm_start) >> 10,
 		   mss.resident >> 10,
 		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
@@ -395,7 +403,8 @@ static int show_smap(struct seq_file *m,
 		   mss.shared_dirty  >> 10,
 		   mss.private_clean >> 10,
 		   mss.private_dirty >> 10,
-		   mss.referenced >> 10);
+		   mss.referenced >> 10,
+		   mss.swap >> 10);
 
 	return ret;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
