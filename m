Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 53C856B0253
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 15:23:06 -0400 (EDT)
Date: Fri, 30 Apr 2010 21:22:35 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
 and rmap_walk() during migration by not migrating temporary stacks
Message-ID: <20100430192235.GL22108@random.random>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
 <1272529930-29505-3-git-send-email-mel@csn.ul.ie>
 <20100429162120.GC22108@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100429162120.GC22108@random.random>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

I'm building a mergeable THP+memory compaction tree ready for mainline
merging based on new anon-vma code, so I'm integrating your patch1 and
this below should be the port of my alternate fix to your patch2 to
fix the longstanding crash in migrate (not a bug in new anon-vma code
but longstanding). patch1 is instead about the bugs introduced by the
new anon-vma code that might crash migrate (even without memory
compaction and/or THP) the same way as the bug fixed by the below.

==
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
 
@@ -515,17 +518,46 @@ static int shift_arg_pages(struct vm_are
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
+	if (unlikely(anon_vma_clone(tmp_vma, vma))) {
+		kmem_cache_free(vm_area_cachep, tmp_vma);
+		return -ENOMEM;
+	}
+
+	/*
 	 * cover the whole range: [new_start, old_end)
+	 *
+	 * The vma is attached only to vma->anon_vma so one lock is
+	 * enough. Even this lock might be removed and we could run it
+	 * out of order but it's nicer to make atomic updates to
+	 * vm_start and so we won't need a smb_wmb() before calling
+	 * move_page_tables.
 	 */
-	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL))
-		return -ENOMEM;
+	spin_lock(&vma->anon_vma->lock);
+	vma->vm_start = new_start;
+	spin_unlock(&vma->anon_vma->lock);
 
 	/*
 	 * move the page tables downwards, on failure we rely on
 	 * process cleanup to remove whatever mess we made.
 	 */
-	if (length != move_page_tables(vma, old_start,
-				       vma, new_start, length))
+	moved_length = move_page_tables(vma, old_start,
+					vma, new_start, length);
+
+	/* rmap walk will already find all pages using the new_start */
+	unlink_anon_vmas(tmp_vma);
+	kmem_cache_free(vm_area_cachep, tmp_vma);
+
+	if (length != moved_length) 
 		return -ENOMEM;
 
 	lru_add_drain();
@@ -551,7 +583,7 @@ static int shift_arg_pages(struct vm_are
 	/*
 	 * Shrink the vma to just the new range.  Always succeeds.
 	 */
-	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
+	vma->vm_end = new_end;
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
