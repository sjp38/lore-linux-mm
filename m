Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 310016B01EE
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 03:32:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3S7Wc0x006578
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 16:32:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0963745DE52
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 16:32:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D337A45DE4E
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 16:32:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AF3CB1DB8042
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 16:32:37 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 510DC1DB803C
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 16:32:37 +0900 (JST)
Date: Wed, 28 Apr 2010 16:28:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs when
 page tables are being moved after the VMA has already moved
Message-Id: <20100428162838.c762fcda.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100428114944.3570105f.kamezawa.hiroyu@jp.fujitsu.com>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<1272403852-10479-4-git-send-email-mel@csn.ul.ie>
	<20100427223004.GF8860@random.random>
	<20100427225852.GH8860@random.random>
	<20100428102928.a3b25066.kamezawa.hiroyu@jp.fujitsu.com>
	<20100428014434.GM510@random.random>
	<20100428111248.2797801c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100428024227.GN510@random.random>
	<20100428114944.3570105f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Apr 2010 11:49:44 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 28 Apr 2010 04:42:27 +0200
> Andrea Arcangeli <aarcange@redhat.com> wrote:
 
> > migrate.c requires rmap to be able to find all ptes mapping a page at
> > all times, otherwise the migration entry can be instantiated, but it
> > can't be removed if the second rmap_walk fails to find the page.
> > 
> > So shift_arg_pages must run atomically with respect of rmap_walk, and
> > it's enough to run it under the anon_vma lock to make it atomic.
> > 
> > And split_huge_page() will have the same requirements as migrate.c
> > already has.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> Seems good.
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I'll test this and report if I see trouble again.
> 
> Unfortunately, I'll have a week of holidays (in Japan) in 4/29-5/05,
> my office is nearly closed. So, please consider no-mail-from-me is
> good information.
> 
Here is bad news. When move_page_tables() fails, "some ptes" are moved
but others are not and....there is no rollback routine.

I bet the best way to fix this mess up is 
 - disable overlap moving of arg pages
 - use do_mremap().

But maybe you guys want to fix this directly.
Here is a temporal fix from me. But don't trust me..
==
Subject: fix race between shift_arg_pages and rmap_walk

From: Andrea Arcangeli <aarcange@redhat.com>

migrate.c requires rmap to be able to find all ptes mapping a page at
all times, otherwise the migration entry can be instantiated, but it
can't be removed if the second rmap_walk fails to find the page.

So shift_arg_pages must run atomically with respect of rmap_walk, and
it's enough to run it under the anon_vma lock to make it atomic.

And split_huge_page() will have the same requirements as migrate.c
already has.

And, when moving overlapping ptes by move_page_tables(), it's cannot
be roll-backed as mremap does. This patch changes move_page_tables()'s
behavior and if it failes, no ptes are moved.

Changelog:
 - modified move_page_tables() to do atomic pte moving because
   "some ptes are moved but others are not" is critical for rmap_walk().
 - free pgtables at failure rather than give it all to do_exit().
   If not, objrmap will be inconsitent until exit() frees all.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

---
 fs/exec.c   |   67 +++++++++++++++++++++++++++++++++++++-----------------------
 mm/mremap.c |   28 ++++++++++++++++++++++---
 2 files changed, 67 insertions(+), 28 deletions(-)

Index: mel-test/fs/exec.c
===================================================================
--- mel-test.orig/fs/exec.c
+++ mel-test/fs/exec.c
@@ -55,6 +55,7 @@
 #include <linux/fsnotify.h>
 #include <linux/fs_struct.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/rmap.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -503,7 +504,10 @@ static int shift_arg_pages(struct vm_are
 	unsigned long length = old_end - old_start;
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
+	unsigned long moved_length;
 	struct mmu_gather *tlb;
+	int ret;
+	unsigned long unused_pgd_start, unused_pgd_end, floor, ceiling;
 
 	BUG_ON(new_start > new_end);
 
@@ -517,41 +521,54 @@ static int shift_arg_pages(struct vm_are
 	/*
 	 * cover the whole range: [new_start, old_end)
 	 */
-	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL))
-		return -ENOMEM;
+	spin_lock(&vma->anon_vma->lock);
+	vma->vm_start = new_start;
 
-	/*
-	 * move the page tables downwards, on failure we rely on
-	 * process cleanup to remove whatever mess we made.
-	 */
 	if (length != move_page_tables(vma, old_start,
-				       vma, new_start, length))
-		return -ENOMEM;
-
-	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
-	if (new_end > old_start) {
+				       vma, new_start, length)) {
+		vma->vm_start = old_start;
 		/*
-		 * when the old and new regions overlap clear from new_end.
-		 */
-		free_pgd_range(tlb, new_end, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+ 		 * we have to free [new_start, new_start+length] pgds
+ 		 * which we've allocated above.
+ 		 */
+		if (new_end > old_start) {
+			unused_pgd_start = new_start;
+			unused_pgd_end = old_start;
+		} else {
+			unused_pgd_start = new_start;
+			unused_pgd_end = new_end;
+		}
+		floor = new_start;
+		ceiling = old_start;
+		ret = -ENOMEM:
 	} else {
-		/*
-		 * otherwise, clean from old_start; this is done to not touch
-		 * the address space in [new_end, old_start) some architectures
-		 * have constraints on va-space that make this illegal (IA64) -
-		 * for the others its just a little faster.
-		 */
-		free_pgd_range(tlb, old_start, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+		if (new_end > old_start) {
+			unused_pgd_start = new_end;
+			unused_pgd_end = old_end;
+		} else {
+			unused_pgd_start = old_start;
+			unused_pgd_end = old_end;
+		}
+		floor = new_end;
+		if (vma->vm_next)
+			ceiling = vma->vm_next->vm_start;
+		else
+			ceiling = 0;
+		ret = 0;
 	}
+	spin_unlock(&vma->anon_vma->lock);
+
+	lru_add_drain();
+	tlb = tlb_gather_mmu(mm, 0);
+	/* Free unnecessary PGDS */
+	free_pgd_range(tlb, unused_pgd_start, unused_pgd_end, floor, ceiling);
 	tlb_finish_mmu(tlb, new_end, old_end);
 
 	/*
 	 * Shrink the vma to just the new range.  Always succeeds.
 	 */
-	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
+	if (!ret)
+		vma->vm_end = new_end;
 
 	return 0;
 }
Index: mel-test/mm/mremap.c
===================================================================
--- mel-test.orig/mm/mremap.c
+++ mel-test/mm/mremap.c
@@ -134,22 +134,44 @@ unsigned long move_page_tables(struct vm
 {
 	unsigned long extent, next, old_end;
 	pmd_t *old_pmd, *new_pmd;
+	unsigned long from_addr, to_addr;
 
 	old_end = old_addr + len;
 	flush_cache_range(vma, old_addr, old_end);
 
-	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
+	/* At first, copy required pmd in the range */
+	for (from_addr = old_addr, to_addr = new_addr;
+	     from_addr < old_end; from_addr += extent, to_addr += extent) {
 		cond_resched();
 		next = (old_addr + PMD_SIZE) & PMD_MASK;
 		if (next - 1 > old_end)
 			next = old_end;
 		extent = next - old_addr;
-		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
+		old_pmd = get_old_pmd(vma->vm_mm, from_addr);
 		if (!old_pmd)
 			continue;
-		new_pmd = alloc_new_pmd(vma->vm_mm, new_addr);
+		new_pmd = alloc_new_pmd(vma->vm_mm, to_addr);
 		if (!new_pmd)
 			break;
+		next = (to_addr + PMD_SIZE) & PMD_MASK;
+		if (extent > next - to_addr)
+			extent = next - to_addr;
+	}
+	/* -ENOMEM ? */
+	if (from_addr < old_end) /* the caller must free remaining pmds. */
+		return 0;
+
+	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
+		cond_resched();
+		next = (old_addr + PMD_SIZE) & PMD_MASK;
+		if (next - 1 > old_end)
+			next = old_end;
+		extent = next - old_addr;
+		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
+		if (!old_pmd)
+			continue;
+		new_pmd = get_new_pmd(vma->vm_mm, new_addr);
+		BUG_ON(!new_pmd);
 		next = (new_addr + PMD_SIZE) & PMD_MASK;
 		if (extent > next - new_addr)
 			extent = next - new_addr;









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
