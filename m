Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E2FE68D003C
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:53:48 -0500 (EST)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1M1YsAj005320
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:34:54 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1M1rlWL229968
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:53:47 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1M1rkk4010541
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:53:46 -0500
Subject: [PATCH 5/5] have smaps show transparent huge pages
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 21 Feb 2011 17:53:45 -0800
References: <20110222015338.309727CA@kernel>
In-Reply-To: <20110222015338.309727CA@kernel>
Message-Id: <20110222015345.BF949720@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, akpm@osdl.org, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>


Now that the mere act of _looking_ at /proc/$pid/smaps will not
destroy transparent huge pages, tell how much of the VMA is
actually mapped with them.

This way, we can make sure that we're getting THPs where we
expect to see them.

v3 - * changed HPAGE_SIZE to HPAGE_PMD_SIZE, probably more correct
       and also has a nice BUG() in case there was a .config mishap
     * remove direct reference to ->page_table_lock, and used the
       passed-in ptl pointer insteadl

Acked-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/fs/proc/task_mmu.c |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN fs/proc/task_mmu.c~teach-smaps-thp fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~teach-smaps-thp	2011-02-21 15:07:55.707591741 -0800
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2011-02-21 15:07:55.803594580 -0800
@@ -331,6 +331,7 @@ struct mem_size_stats {
 	unsigned long private_dirty;
 	unsigned long referenced;
 	unsigned long anonymous;
+	unsigned long anonymous_thp;
 	unsigned long swap;
 	u64 pss;
 };
@@ -396,6 +397,7 @@ static int smaps_pte_range(pmd_t *pmd, u
 			smaps_pte_entry(*(pte_t *)pmd, addr,
 					HPAGE_PMD_SIZE, walk);
 			spin_unlock(&walk->mm->page_table_lock);
+			mss->anonymous_thp += HPAGE_PMD_SIZE;
 			return 0;
 		}
 	} else {
@@ -444,6 +446,7 @@ static int show_smap(struct seq_file *m,
 		   "Private_Dirty:  %8lu kB\n"
 		   "Referenced:     %8lu kB\n"
 		   "Anonymous:      %8lu kB\n"
+		   "AnonHugePages:  %8lu kB\n"
 		   "Swap:           %8lu kB\n"
 		   "KernelPageSize: %8lu kB\n"
 		   "MMUPageSize:    %8lu kB\n"
@@ -457,6 +460,7 @@ static int show_smap(struct seq_file *m,
 		   mss.private_dirty >> 10,
 		   mss.referenced >> 10,
 		   mss.anonymous >> 10,
+		   mss.anonymous_thp >> 10,
 		   mss.swap >> 10,
 		   vma_kernel_pagesize(vma) >> 10,
 		   vma_mmu_pagesize(vma) >> 10,
diff -puN include/linux/huge_mm.h~teach-smaps-thp include/linux/huge_mm.h
diff -puN mm/memory-failure.c~teach-smaps-thp mm/memory-failure.c
diff -puN mm/huge_memory.c~teach-smaps-thp mm/huge_memory.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
