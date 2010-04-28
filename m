Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4E4856B01F4
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 17:05:59 -0400 (EDT)
Date: Wed, 28 Apr 2010 23:05:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] Fix migration races in rmap_walk() V2
Message-ID: <20100428210530.GK510@random.random>
References: <alpine.DEB.2.00.1004271723090.24133@router.home>
 <20100427223242.GG8860@random.random>
 <20100428091345.496ca4c4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100428002056.GH510@random.random>
 <20100428142356.GF15815@csn.ul.ie>
 <20100428145737.GG15815@csn.ul.ie>
 <20100428151614.GQ510@random.random>
 <20100428152354.GH15815@csn.ul.ie>
 <20100428154508.GT510@random.random>
 <20100428204043.GF510@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428204043.GF510@random.random>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 10:40:43PM +0200, Andrea Arcangeli wrote:
> Ok the best idea so far I had is to add a fake temporary fake vma to
> the anon_vma list with the old vm_start and same vm_pgoff before
> shifting down vma->vm_start and calling move_page_tables. Then after
> the move is complete we remove the fake vma. So all the fast paths
> will remain unmodified and no magic is required. I'll try to fix this
> for the old stable anon-vma code and test in aa.git first as the code
> will differ. If it works ok anybody can port it to new anon-vma code.

here the new try for aa.git or 2.6.33 anon-vma code.

----
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
 
@@ -514,16 +517,36 @@ static int shift_arg_pages(struct vm_are
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
+	spin_lock(&vma->anon_vma->lock);
+	/*
 	 * cover the whole range: [new_start, old_end)
 	 */
-	vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
+	vma->vm_start = new_start;
+	__anon_vma_link(tmp_vma);
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
+	anon_vma_unlink(tmp_vma);
+	kmem_cache_free(vm_area_cachep, tmp_vma);
+
+	if (length != moved_length) 
 		return -ENOMEM;
 
 	lru_add_drain();
@@ -549,7 +572,7 @@ static int shift_arg_pages(struct vm_are
 	/*
 	 * shrink the vma to just the new range.
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
