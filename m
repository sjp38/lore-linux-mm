Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C18D89000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 18:13:32 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8LLcL0w015936
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 17:38:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8LMDUaI258340
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 18:13:30 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8LMDUVG029136
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 18:13:30 -0400
Subject: [RFC][PATCH] show page size in /proc/$pid/numa_maps
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Wed, 21 Sep 2011 15:13:29 -0700
Message-Id: <20110921221329.5B7EE5C5@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>


The output of /proc/$pid/numa_maps is in terms of number of pages
like anon=22 or dirty=54.  Here's some output:

7f4680000000 default file=/hugetlb/bigfile anon=50 dirty=50 N0=50
7f7659600000 default file=/anon_hugepage\040(deleted) anon=50 dirty=50 N0=50
7fff8d425000 default stack anon=50 dirty=50 N0=50

Looks like we have a stack and a couple of anonymous hugetlbfs
areas page which both use the same amount of memory.  They don't.

The 'bigfile' uses 1GB pages and takes up ~50GB of space.  The
anon_hugepage uses 2MB pages and takes up ~100MB of space while
the stack uses normal 4k pages.  You can go over to smaps to
figure out what the page size _really_ is with KernelPageSize
or MMUPageSize.  But, I think this is a pretty nasty and
counterintuitive interface as it stands.

The following patch adds a pagemult= field.  It is placed only
in cases where the VMA's page size differs from the base kernel
page size.  I'm calling it pagemult to emphasize that it is
indended to modify the statistics output rather than _really_
show the page size that the kernel or MMU is using.

Signed-off-by: Dave Haneen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/fs/proc/task_mmu.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff -puN fs/proc/task_mmu.c~show-page-size fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~show-page-size	2011-09-21 15:05:49.846739432 -0700
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2011-09-21 15:10:26.798329158 -0700
@@ -1007,6 +1007,7 @@ static int show_numa_map(struct seq_file
 	struct mm_struct *mm = vma->vm_mm;
 	struct mm_walk walk = {};
 	struct mempolicy *pol;
+	unsigned long pagesize_multiplier;
 	int n;
 	char buffer[50];
 
@@ -1044,6 +1045,12 @@ static int show_numa_map(struct seq_file
 	if (!md->pages)
 		goto out;
 
+	/* This will only really do something for hugetlbfs pages.
+	 * Transparent hugepages are still pagemult=1 */
+	pagesize_multiplier = vma_kernel_pagesize(vma) / PAGE_SIZE;
+	if (pagesize_multiplier > 1)
+		seq_printf(m, " pagemult=%lu", pagesize_multiplier);
+
 	if (md->anon)
 		seq_printf(m, " anon=%lu", md->anon);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
