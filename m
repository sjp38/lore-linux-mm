Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3D8B46B02A7
	for <linux-mm@kvack.org>; Thu,  6 May 2010 03:42:50 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o467gkpN000483
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 May 2010 16:42:46 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D7AAA45DE62
	for <linux-mm@kvack.org>; Thu,  6 May 2010 16:42:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B3DE745DE4E
	for <linux-mm@kvack.org>; Thu,  6 May 2010 16:42:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 959771DB8040
	for <linux-mm@kvack.org>; Thu,  6 May 2010 16:42:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A40E1DB803C
	for <linux-mm@kvack.org>; Thu,  6 May 2010 16:42:44 +0900 (JST)
Date: Thu, 6 May 2010 16:38:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-Id: <20100506163837.bf6587ef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1273065281-13334-2-git-send-email-mel@csn.ul.ie>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie>
	<1273065281-13334-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed,  5 May 2010 14:14:40 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> vma_adjust() is updating anon VMA information without locks being taken.
> In contrast, file-backed mappings use the i_mmap_lock and this lack of
> locking can result in races with users of rmap_walk such as page migration.
> vma_address() can return -EFAULT for an address that will soon be valid.
> For migration, this potentially leaves a dangling migration PTE behind
> which can later cause a BUG_ON to trigger when the page is faulted in.
> 
> With the recent anon_vma changes, there can be more than one anon_vma->lock
> to take in a anon_vma_chain but a second lock cannot be spinned upon in case
> of deadlock. The rmap walker tries to take locks of different anon_vma's
> but if the attempt fails, locks are released and the operation is restarted.
> 
> For vma_adjust(), the locking behaviour prior to the anon_vma is restored
> so that rmap_walk() can be sure of the integrity of the VMA information and
> lists when the anon_vma lock is held. With this patch, the vma->anon_vma->lock
> is taken if
> 
> 	a) If there is any overlap with the next VMA due to the adjustment
> 	b) If there is a new VMA is being inserted into the address space
> 	c) If the start of the VMA is being changed so that the
> 	   relationship between vm_start and vm_pgoff is preserved
> 	   for vma_address()
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

I'm sorry I couldn't catch all details but can I make a question ?
Why seq_counter is bad finally ? I can't understand why we have
to lock anon_vma with risks of costs, which is mysterious struct now.

Adding a new to mm_struct is too bad ?

Thanks,
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

At treating rmap, there is no guarantee that "rmap is always correct"
because vma->vm_start, vma->vm_pgoff are modified without any lock.

In usual, it's not a problem that we see incosistent rmap at 
try_to_unmap() etc...But, at migration, this temporal inconsistency
makes rmap_walk() to do wrong decision and leaks migration_pte.
This causes BUG later.

This patch adds seq_counter to mm-struct(not vma because inconsistency
information should cover multiple vmas.). By this, rmap_walk()
can always see consistent [start, end. pgoff] information at checking
page's pte in a vma.

In exec()'s failure case, rmap is left as broken but we don't have to
take care of it.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/exec.c                |   20 +++++++++++++++-----
 include/linux/mm_types.h |    2 ++
 mm/mmap.c                |    3 +++
 mm/rmap.c                |   13 ++++++++++++-
 4 files changed, 32 insertions(+), 6 deletions(-)

Index: linux-2.6.34-rc5-mm1/include/linux/mm_types.h
===================================================================
--- linux-2.6.34-rc5-mm1.orig/include/linux/mm_types.h
+++ linux-2.6.34-rc5-mm1/include/linux/mm_types.h
@@ -14,6 +14,7 @@
 #include <linux/page-debug-flags.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
+#include <linux/seqlock.h>
 
 #ifndef AT_VECTOR_SIZE_ARCH
 #define AT_VECTOR_SIZE_ARCH 0
@@ -310,6 +311,7 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+	seqcount_t	rmap_consistent;
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
Index: linux-2.6.34-rc5-mm1/mm/rmap.c
===================================================================
--- linux-2.6.34-rc5-mm1.orig/mm/rmap.c
+++ linux-2.6.34-rc5-mm1/mm/rmap.c
@@ -332,8 +332,19 @@ vma_address(struct page *page, struct vm
 {
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	unsigned long address;
+	unsigned int seq;
+
+	/*
+ 	 * Because we don't take mm->mmap_sem, we have race with
+ 	 * vma adjusting....we'll be able to see broken rmap. To avoid
+ 	 * that, check consistency of rmap by seqcounter.
+ 	 */
+	do {
+		seq = read_seqcount_begin(&vma->vm_mm->rmap_consistent);
+		address = vma->vm_start
+			+ ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+	} while (read_seqcount_retry(&vma->vm_mm->rmap_consistent, seq));
 
-	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 	if (unlikely(address < vma->vm_start || address >= vma->vm_end)) {
 		/* page should be within @vma mapping range */
 		return -EFAULT;
Index: linux-2.6.34-rc5-mm1/fs/exec.c
===================================================================
--- linux-2.6.34-rc5-mm1.orig/fs/exec.c
+++ linux-2.6.34-rc5-mm1/fs/exec.c
@@ -517,16 +517,25 @@ static int shift_arg_pages(struct vm_are
 	/*
 	 * cover the whole range: [new_start, old_end)
 	 */
-	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL))
-		return -ENOMEM;
-
+	write_seqcount_begin(&mm->rmap_consistent);
 	/*
 	 * move the page tables downwards, on failure we rely on
 	 * process cleanup to remove whatever mess we made.
 	 */
+	/*
+	 * vma->vm_start should be updated always for freeing pgds.
+	 * after failure.
+ 	 */
+	vma->vm_start = new_start;
 	if (length != move_page_tables(vma, old_start,
-				       vma, new_start, length))
+				       vma, new_start, length)) {
+		/*
+		 * We have broken rmap here. But we can unlock this becauase
+ 		 * no one will do page-fault to ptes in this range more.
+ 		 */
+		write_seqcount_end(&mm->rmap_consistent);
 		return -ENOMEM;
+	}
 
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
@@ -551,7 +560,8 @@ static int shift_arg_pages(struct vm_are
 	/*
 	 * Shrink the vma to just the new range.  Always succeeds.
 	 */
-	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
+	vma->vm_end = new_end;
+	write_seqcount_end(&mm->rmap_consistent);
 
 	return 0;
 }
Index: linux-2.6.34-rc5-mm1/mm/mmap.c
===================================================================
--- linux-2.6.34-rc5-mm1.orig/mm/mmap.c
+++ linux-2.6.34-rc5-mm1/mm/mmap.c
@@ -585,6 +585,7 @@ again:			remove_next = 1 + (end > next->
 			vma_prio_tree_remove(next, root);
 	}
 
+	write_seqcount_begin(&mm->rmap_consistent);
 	vma->vm_start = start;
 	vma->vm_end = end;
 	vma->vm_pgoff = pgoff;
@@ -620,6 +621,8 @@ again:			remove_next = 1 + (end > next->
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
+	write_seqcount_end(&mm->rmap_consistent);
+
 	if (remove_next) {
 		if (file) {
 			fput(file);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
