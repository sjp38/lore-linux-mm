Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6063B62007F
	for <linux-mm@kvack.org>; Fri,  7 May 2010 00:23:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o474NqCC017157
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 May 2010 13:23:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 57B5B45DE5A
	for <linux-mm@kvack.org>; Fri,  7 May 2010 13:23:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ED75645DE51
	for <linux-mm@kvack.org>; Fri,  7 May 2010 13:23:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CADE91DB8043
	for <linux-mm@kvack.org>; Fri,  7 May 2010 13:23:51 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 35F901DB803E
	for <linux-mm@kvack.org>; Fri,  7 May 2010 13:23:51 +0900 (JST)
Date: Fri, 7 May 2010 13:19:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm,migration: Fix race between shift_arg_pages and
 rmap_walk by guaranteeing rmap_walk finds PTEs created within the temporary
 stack
Message-Id: <20100507131924.e75db6fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LFD.2.00.1005061905230.901@i5.linux-foundation.org>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie>
	<1273188053-26029-3-git-send-email-mel@csn.ul.ie>
	<alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org>
	<20100507105712.18fc90c4.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1005061905230.901@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 6 May 2010 19:12:59 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Fri, 7 May 2010, KAMEZAWA Hiroyuki wrote:
> > 
> > IIUC, move_page_tables() may call "page table allocation" and it cannot be
> > done under spinlock.
> 
> Bah. It only does a "alloc_new_pmd()", and we could easily move that out 
> of the loop and pre-allocate the pmd's.
> 
> If that's the only reason, then it's a really weak one, methinks.
> 
Hmm, is this too slow ? This is the simplest one I have.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

exec()'s shift_arg_pages calls adjust_vma and move_page_table() directly.
During this, rmap information (i.e. page <-> pte <-> address <-> vma)
information is inconsistent. This causes a bug in rmap_walk() which
rmap_walk cannot find valid ptes it must visit.

Considering the race, move_vma() does valid things. So, making use of
move_vma() instead of bare move_page_tables() is a choice.

Pros.
 - all races are handled under /mm. very simple.
Cons.
 - This may makes exec() slow a bit.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/exec.c          |   64 +++++++++++++++--------------------------------------
 include/linux/mm.h |    6 ++--
 mm/mremap.c        |    4 +--
 3 files changed, 24 insertions(+), 50 deletions(-)

Index: linux-2.6.34-rc5-mm1/fs/exec.c
===================================================================
--- linux-2.6.34-rc5-mm1.orig/fs/exec.c
+++ linux-2.6.34-rc5-mm1/fs/exec.c
@@ -486,14 +486,7 @@ EXPORT_SYMBOL(copy_strings_kernel);
 /*
  * During bprm_mm_init(), we create a temporary stack at STACK_TOP_MAX.  Once
  * the binfmt code determines where the new stack should reside, we shift it to
- * its final location.  The process proceeds as follows:
- *
- * 1) Use shift to calculate the new vma endpoints.
- * 2) Extend vma to cover both the old and new ranges.  This ensures the
- *    arguments passed to subsequent functions are consistent.
- * 3) Move vma's page tables to the new range.
- * 4) Free up any cleared pgd range.
- * 5) Shrink the vma to cover only the new range.
+ * its final location.
  */
 static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 {
@@ -503,7 +496,7 @@ static int shift_arg_pages(struct vm_are
 	unsigned long length = old_end - old_start;
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
-	struct mmu_gather *tlb;
+	unsigned long ret;
 
 	BUG_ON(new_start > new_end);
 
@@ -514,45 +507,23 @@ static int shift_arg_pages(struct vm_are
 	if (vma != find_vma(mm, new_start))
 		return -EFAULT;
 
-	/*
-	 * cover the whole range: [new_start, old_end)
-	 */
-	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL))
-		return -ENOMEM;
-
-	/*
-	 * move the page tables downwards, on failure we rely on
-	 * process cleanup to remove whatever mess we made.
-	 */
-	if (length != move_page_tables(vma, old_start,
-				       vma, new_start, length))
-		return -ENOMEM;
+	if (new_end > old_start) { /* overlap */
+		unsigned long part_len = new_end - old_start;
+		ret = move_vma(vma, old_start, part_len, part_len, new_start);
 
-	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
-	if (new_end > old_start) {
-		/*
-		 * when the old and new regions overlap clear from new_end.
-		 */
-		free_pgd_range(tlb, new_end, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+		if (ret != new_start)
+			return -ENOMEM;
+		/* old_vma is splitted.. */
+		vma = find_vma(mm, old_start + part_len);
+		ret = move_vma(vma, old_start + part_len, length - part_len,
+			length - part_len, new_start + part_len);
+		if (ret != new_start + part_len)
+			return -ENOMEM;
 	} else {
-		/*
-		 * otherwise, clean from old_start; this is done to not touch
-		 * the address space in [new_end, old_start) some architectures
-		 * have constraints on va-space that make this illegal (IA64) -
-		 * for the others its just a little faster.
-		 */
-		free_pgd_range(tlb, old_start, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+		ret = move_vma(vma, old_start, length, length, new_start);
+		if (ret != new_start)
+			return -ENOMEM;
 	}
-	tlb_finish_mmu(tlb, new_end, old_end);
-
-	/*
-	 * Shrink the vma to just the new range.  Always succeeds.
-	 */
-	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
-
 	return 0;
 }
 
@@ -625,9 +596,12 @@ int setup_arg_pages(struct linux_binprm 
 
 	/* Move stack pages down in memory. */
 	if (stack_shift) {
+		unsigned long new_start = vma->vm_start - stack_shift;
 		ret = shift_arg_pages(vma, stack_shift);
 		if (ret)
 			goto out_unlock;
+		vma = find_vma(mm, new_start);
+		bprm->vma = vma;
 	}
 
 	stack_expand = 131072UL; /* randomly 32*4k (or 2*64k) pages */
Index: linux-2.6.34-rc5-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.34-rc5-mm1.orig/include/linux/mm.h
+++ linux-2.6.34-rc5-mm1/include/linux/mm.h
@@ -856,9 +856,9 @@ int set_page_dirty_lock(struct page *pag
 int set_page_dirty_notag(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
 
-extern unsigned long move_page_tables(struct vm_area_struct *vma,
-		unsigned long old_addr, struct vm_area_struct *new_vma,
-		unsigned long new_addr, unsigned long len);
+extern unsigned long move_vma(struct vm_area_struct *vma,
+		unsigned long old_addr, unsigned long old_length,
+		unsigned long new_length, unsigned long new_addr);
 extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long old_len, unsigned long new_len,
 			       unsigned long flags, unsigned long new_addr);
Index: linux-2.6.34-rc5-mm1/mm/mremap.c
===================================================================
--- linux-2.6.34-rc5-mm1.orig/mm/mremap.c
+++ linux-2.6.34-rc5-mm1/mm/mremap.c
@@ -128,7 +128,7 @@ static void move_ptes(struct vm_area_str
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
 
-unsigned long move_page_tables(struct vm_area_struct *vma,
+static unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len)
 {
@@ -162,7 +162,7 @@ unsigned long move_page_tables(struct vm
 	return len + old_addr - old_end;	/* how much done */
 }
 
-static unsigned long move_vma(struct vm_area_struct *vma,
+unsigned long move_vma(struct vm_area_struct *vma,
 		unsigned long old_addr, unsigned long old_len,
 		unsigned long new_len, unsigned long new_addr)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
