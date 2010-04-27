Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 00F586B01F4
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 20:37:55 -0400 (EDT)
Date: Wed, 28 Apr 2010 00:58:52 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs
 when page tables are being moved after the VMA has already moved
Message-ID: <20100427225852.GH8860@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <1272403852-10479-4-git-send-email-mel@csn.ul.ie>
 <20100427223004.GF8860@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100427223004.GF8860@random.random>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 12:30:04AM +0200, Andrea Arcangeli wrote:
> I'll now evaluate the fix and see if I can find any other
> way to handle this.


I think a better fix for bug mentioned in patch 3, is like below. This
seems to work fine on aa.git with the old (stable) 2.6.33 anon-vma
code. Not sure if this also works with the new anon-vma code in
mainline but at first glance I think it should. At that point we
should be single threaded so it shouldn't matter if anon_vma is
temporary null.

Then you've to re-evaluate the vma_adjust fixes for mainline-only in
patch 2 at the light of the below (I didn't check patch 2 in detail).

Please try to reproduce with the below applied.

----
Subject: fix race between shift_arg_pages and rmap_walk

From: Andrea Arcangeli <aarcange@redhat.com>

migrate.c requires rmap to be able to find all ptes mapping a page at
all times, otherwise the migration entry can be instantiated, but it
can't be removed if the second rmap_walk fails to find the page.

So shift_arg_pages must run atomically with respect of rmap_walk, and
it's enough to run it under the anon_vma lock to make it atomic.

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
@@ -503,6 +504,7 @@ static int shift_arg_pages(struct vm_are
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
 	struct mmu_gather *tlb;
+	struct anon_vma *anon_vma;
 
 	BUG_ON(new_start > new_end);
 
@@ -513,6 +515,12 @@ static int shift_arg_pages(struct vm_are
 	if (vma != find_vma(mm, new_start))
 		return -EFAULT;
 
+	anon_vma = vma->anon_vma;
+	/* stop rmap_walk or it won't find the stack pages */
+	spin_lock(&anon_vma->lock);
+	/* avoid vma_adjust to take any further anon_vma lock */
+	vma->anon_vma = NULL;
+
 	/*
 	 * cover the whole range: [new_start, old_end)
 	 */
@@ -551,6 +559,9 @@ static int shift_arg_pages(struct vm_are
 	 */
 	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
 
+	vma->anon_vma = anon_vma;
+	spin_unlock(&anon_vma->lock);
+
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
