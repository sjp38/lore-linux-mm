Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A37F56B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 06:36:23 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2CAaKIF186942
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:36:20 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CAaJri3023040
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:36:19 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2CAaJl8030768
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:36:19 +0100
Date: Thu, 12 Mar 2009 11:33:08 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] acquire mmap semaphore in pagemap_read.
Message-ID: <20090312113308.6fe18a93@skybase>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matt Mackall <mpm@selenic.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

The walk_page_range function may only be called while holding the mmap
semaphore. Otherwise a concurrent munmap could free a page table that
is read by the generic page table walker.

Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 fs/proc/task_mmu.c |    2 ++
 1 file changed, 2 insertions(+)

diff -urpN linux-2.6/fs/proc/task_mmu.c linux-2.6-patched/fs/proc/task_mmu.c
--- linux-2.6/fs/proc/task_mmu.c	2009-03-12 11:32:51.000000000 +0100
+++ linux-2.6-patched/fs/proc/task_mmu.c	2009-03-12 11:33:16.000000000 +0100
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
