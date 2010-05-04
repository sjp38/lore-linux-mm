Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E0EEC6B0292
	for <linux-mm@kvack.org>; Tue,  4 May 2010 08:56:38 -0400 (EDT)
Date: Tue, 4 May 2010 14:56:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
 and rmap_walk() during migration by not migrating temporary stacks
Message-ID: <20100504125606.GK19891@random.random>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
 <1272529930-29505-3-git-send-email-mel@csn.ul.ie>
 <20100429162120.GC22108@random.random>
 <20100504103213.GB20979@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100504103213.GB20979@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 04, 2010 at 11:32:13AM +0100, Mel Gorman wrote:
> Unfortunately, the same bug triggers after about 18 minutes. The objective of
> your fix is very simple - have a VMA covering the new range so that rmap can
> find it. However, no lock is held during move_page_tables() because of the
> need to call the page allocator. Due to the lack of locking, is it possible
> that something like the following is happening?
> 
> Exec Process				Migration Process
> begin move_page_tables
> 					begin rmap walk
> 					take anon_vma locks
> 					find new location of pte (do nothing)
> copy migration pte to new location
> #### Bad PTE now in place
> 					find old location of pte
> 					remove old migration pte
> 					release anon_vma locks
> remove temporary VMA
> some time later, bug on migration pte
> 
> Even with the care taken, a migration PTE got copied and then left behind. What
> I haven't confirmed at this point is if the ordering of the walk in "migration
> process" is correct in the above scenario. The order is important for
> the race as described to happen.

Ok so this seems the ordering dependency on the anon_vma list that
strikes again, I didn't realize the ordering would matter here, but it
does as shown above, great catch! The destination vma of the
move_page_tables has to be at the tail of the anon_vma list like the
child vma have to be at the end to avoid the equivalent race in
fork. This has to be a requirement for mremap too. We just want to
enforce the same invariants that mremap already enforces, to avoid
adding new special cases to the VM.

== for new anon-vma code ==
Subject: fix race between shift_arg_pages and rmap_walk

From: Andrea Arcangeli <aarcange@redhat.com>

migrate.c requires rmap to be able to find all ptes mapping a page at
all times, otherwise the migration entry can be instantiated, but it
can't be removed if the second rmap_walk fails to find the page.

And split_huge_page() will have the same requirements as migrate.c
already has.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -55,6 +55,7 @@
 #include <linux/fsnotify.h>
 #include <linux/fs_struct.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/rmap.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -503,7 +504,9 @@ static int shift_arg_pages(struct vm_are
 	unsigned long length = old_end - old_start;
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
+	unsigned long moved_length;
 	struct mmu_gather *tlb;
+	struct vm_area_struct *tmp_vma;
 
 	BUG_ON(new_start > new_end);
 
@@ -515,17 +518,43 @@ static int shift_arg_pages(struct vm_are
 		return -EFAULT;
 
 	/*
+	 * We need to create a fake temporary vma and index it in the
+	 * anon_vma list in order to allow the pages to be reachable
+	 * at all times by the rmap walk for migrate, while
+	 * move_page_tables() is running.
+	 */
+	tmp_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+	if (!tmp_vma)
+		return -ENOMEM;
+	*tmp_vma = *vma;
+	INIT_LIST_HEAD(&tmp_vma->anon_vma_chain);
+	/*
 	 * cover the whole range: [new_start, old_end)
 	 */
-	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL))
+	tmp_vma->vm_start = new_start;
+	/*
+	 * The tmp_vma destination of the copy (with the new vm_start)
+	 * has to be at the end of the anon_vma list for the rmap_walk
+	 * to find the moved pages at all times.
+	 */
+	if (unlikely(anon_vma_clone(tmp_vma, vma))) {
+		kmem_cache_free(vm_area_cachep, tmp_vma);
 		return -ENOMEM;
+	}
 
 	/*
 	 * move the page tables downwards, on failure we rely on
 	 * process cleanup to remove whatever mess we made.
 	 */
-	if (length != move_page_tables(vma, old_start,
-				       vma, new_start, length))
+	moved_length = move_page_tables(vma, old_start,
+					vma, new_start, length);
+
+	vma->vm_start = new_start;
+	/* rmap walk will already find all pages using the new_start */
+	unlink_anon_vmas(tmp_vma);
+	kmem_cache_free(vm_area_cachep, tmp_vma);
+
+	if (length != moved_length) 
 		return -ENOMEM;
 
 	lru_add_drain();
@@ -551,7 +580,7 @@ static int shift_arg_pages(struct vm_are
 	/*
 	 * Shrink the vma to just the new range.  Always succeeds.
 	 */
-	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
+	vma->vm_end = new_end;
 
 	return 0;
 }


== for old anon-vma code ==
Subject: fix race between shift_arg_pages and rmap_walk

From: Andrea Arcangeli <aarcange@redhat.com>

migrate.c requires rmap to be able to find all ptes mapping a page at
all times, otherwise the migration entry can be instantiated, but it
can't be removed if the second rmap_walk fails to find the page.

And split_huge_page() will have the same requirements as migrate.c
already has.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -55,6 +55,7 @@
 #include <linux/fsnotify.h>
 #include <linux/fs_struct.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/rmap.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -502,7 +503,9 @@ static int shift_arg_pages(struct vm_are
 	unsigned long length = old_end - old_start;
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
+	unsigned long moved_length;
 	struct mmu_gather *tlb;
+	struct vm_area_struct *tmp_vma;
 
 	BUG_ON(new_start > new_end);
 
@@ -514,16 +517,41 @@ static int shift_arg_pages(struct vm_are
 		return -EFAULT;
 
 	/*
+	 * We need to create a fake temporary vma and index it in the
+	 * anon_vma list in order to allow the pages to be reachable
+	 * at all times by the rmap walk for migrate, while
+	 * move_page_tables() is running.
+	 */
+	tmp_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+	if (!tmp_vma)
+		return -ENOMEM;
+	*tmp_vma = *vma;
+
+	/*
 	 * cover the whole range: [new_start, old_end)
 	 */
-	vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
+	tmp_vma->vm_start = new_start;
+
+	/*
+	 * The tmp_vma destination of the copy (with the new vm_start)
+	 * has to be at the end of the anon_vma list for the rmap_walk
+	 * to find the moved pages at all times.
+	 */
+	anon_vma_link(tmp_vma);
 
 	/*
 	 * move the page tables downwards, on failure we rely on
 	 * process cleanup to remove whatever mess we made.
 	 */
-	if (length != move_page_tables(vma, old_start,
-				       vma, new_start, length))
+	moved_length = move_page_tables(vma, old_start,
+					vma, new_start, length);
+
+	vma->vm_start = new_start;
+	/* rmap walk will already find all pages using the new_start */
+	anon_vma_unlink(tmp_vma);
+	kmem_cache_free(vm_area_cachep, tmp_vma);
+
+	if (length != moved_length) 
 		return -ENOMEM;
 
 	lru_add_drain();
@@ -549,7 +577,7 @@ static int shift_arg_pages(struct vm_are
 	/*
 	 * shrink the vma to just the new range.
 	 */
-	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
+	vma->vm_end = new_end;
 
 	return 0;
 }


I'll release new THP-23 and THP-23-anon_vma_chain (prerelease is
already in aa.git but it misses the above bit) soon enough...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
