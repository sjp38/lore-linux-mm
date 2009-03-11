Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED246B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:52:52 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2BDqlhS198762
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 13:52:47 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2BDqk7M3510500
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 14:52:47 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2BDqiAt002441
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 14:52:44 +0100
Date: Wed, 11 Mar 2009 14:49:51 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] fix/improve generic page table walker
Message-ID: <20090311144951.58c6ab60@skybase>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matt Mackall <mpm@selenic.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

On s390 the /proc/pid/pagemap interface is currently broken. This is
caused by the unconditional loop over all pgd/pud entries as specified
by the address range passed to walk_page_range. The tricky bit here
is that the pgd++ in the outer loop may only be done if the page table
really has 4 levels. For the pud++ in the second loop the page table needs
to have at least 3 levels. With the dynamic page tables on s390 we can have
page tables with 2, 3 or 4 levels. Which means that the pgd and/or the
pud pointer can get out-of-bounds causing all kinds of mayhem.

The proposed solution is to fast-forward over the hole between the start
address and the first vma and the hole between the last vma and the end
address. The pgd/pud/pmd/pte loops are used only for the address range
between the first and last vma. This guarantees that the page table
pointers stay in range for s390. For the other architectures this is
a small optimization.

As the page walker now accesses the vma list the mmap_sem is required.
All callers of the walk_page_range function needs to acquire the semaphore.

Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 fs/proc/task_mmu.c |    2 ++
 mm/pagewalk.c      |   28 ++++++++++++++++++++++++++--
 2 files changed, 28 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/fs/proc/task_mmu.c linux-2.6-patched/fs/proc/task_mmu.c
--- linux-2.6/fs/proc/task_mmu.c	2009-03-11 13:38:53.000000000 +0100
+++ linux-2.6-patched/fs/proc/task_mmu.c	2009-03-11 13:39:45.000000000 +0100
@@ -716,7 +716,9 @@ static ssize_t pagemap_read(struct file 
 	 * user buffer is tracked in "pm", and the walk
 	 * will stop when we hit the end of the buffer.
 	 */
+	down_read(&mm->mmap_sem);
 	ret = walk_page_range(start_vaddr, end_vaddr, &pagemap_walk);
+	up_read(&mm->mmap_sem);
 	if (ret == PM_END_OF_BUFFER)
 		ret = 0;
 	/* don't need mmap_sem for these, but this looks cleaner */
diff -urpN linux-2.6/mm/pagewalk.c linux-2.6-patched/mm/pagewalk.c
--- linux-2.6/mm/pagewalk.c	2008-12-25 00:26:37.000000000 +0100
+++ linux-2.6-patched/mm/pagewalk.c	2009-03-11 13:39:45.000000000 +0100
@@ -104,6 +104,8 @@ static int walk_pud_range(pgd_t *pgd, un
 int walk_page_range(unsigned long addr, unsigned long end,
 		    struct mm_walk *walk)
 {
+	struct vm_area_struct *vma, *prev;
+	unsigned long stop;
 	pgd_t *pgd;
 	unsigned long next;
 	int err = 0;
@@ -114,9 +116,28 @@ int walk_page_range(unsigned long addr, 
 	if (!walk->mm)
 		return -EINVAL;
 
+	/* Find first valid address contained in a vma. */
+	vma = find_vma(walk->mm, addr);
+	if (!vma)
+		/* One big hole. */
+		return walk->pte_hole(addr, end, walk);
+	if (addr < vma->vm_start) {
+		/* Skip over all ptes in the area before the first vma. */
+		err = walk->pte_hole(addr, vma->vm_start, walk);
+		if (err)
+			return err;
+		addr = vma->vm_start;
+	}
+
+	/* Find last valid address contained in a vma. */
+	stop = end;
+	vma = find_vma_prev(walk->mm, end, &prev);
+	if (!vma)
+		stop = prev->vm_end;
+
 	pgd = pgd_offset(walk->mm, addr);
 	do {
-		next = pgd_addr_end(addr, end);
+		next = pgd_addr_end(addr, stop);
 		if (pgd_none_or_clear_bad(pgd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
@@ -131,7 +152,10 @@ int walk_page_range(unsigned long addr, 
 			err = walk_pud_range(pgd, addr, next, walk);
 		if (err)
 			break;
-	} while (pgd++, addr = next, addr != end);
+	} while (pgd++, addr = next, addr != stop);
 
+	if (stop < end)
+		/* Skip over all ptes in the area after the last vma. */
+		err = walk->pte_hole(stop, end, walk);
 	return err;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
