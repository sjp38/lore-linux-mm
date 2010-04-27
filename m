Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7007C6B01EF
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 06:29:27 -0400 (EDT)
Date: Tue, 27 Apr 2010 11:29:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100427102905.GE4895@csn.ul.ie>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie> <1272321478-28481-3-git-send-email-mel@csn.ul.ie> <20100427090706.7ca68e12.kamezawa.hiroyu@jp.fujitsu.com> <20100427125040.634f56b3.kamezawa.hiroyu@jp.fujitsu.com> <20100427085951.GB4895@csn.ul.ie> <20100427180949.673350f2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100427180949.673350f2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 27, 2010 at 06:09:49PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 27 Apr 2010 09:59:51 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Tue, Apr 27, 2010 at 12:50:40PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 27 Apr 2010 09:07:06 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > On Mon, 26 Apr 2010 23:37:58 +0100
> > > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > > 
> > > > > vma_adjust() is updating anon VMA information without any locks taken.
> > > > > In contrast, file-backed mappings use the i_mmap_lock and this lack of
> > > > > locking can result in races with page migration. During rmap_walk(),
> > > > > vma_address() can return -EFAULT for an address that will soon be valid.
> > > > > This leaves a dangling migration PTE behind which can later cause a BUG_ON
> > > > > to trigger when the page is faulted in.
> > > > > 
> > > > > With the recent anon_vma changes, there can be more than one anon_vma->lock
> > > > > that can be taken in a anon_vma_chain but a second lock cannot be spinned
> > > > > upon in case of deadlock. Instead, the rmap walker tries to take locks of
> > > > > different anon_vma's. If the attempt fails, the operation is restarted.
> > > > > 
> > > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > > 
> > > > Ok, acquiring vma->anon_vma->spin_lock always sounds very safe.
> > > > (but slow.)
> > > > 
> > > > I'll test this, too.
> > > > 
> > > > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > 
> > > 
> > > Sorry. reproduced. It seems the same bug before patch. 
> > > mapcount 1 -> unmap -> remap -> mapcount 0. And it was SwapCache.
> > > 
> > 
> > Same here, reproduced after 18 hours.
> > 
> Hmm. It seems rmap_one() is called and the race is not in vma_address()
> but in remap_migration_pte().

It could have been in both but the vma lock should have been held across
the rmap_one. It still reproduces but it's still the right thing to do.
This is the current version of patch 2/2.

==== CUT HERE ====

[PATCH] mm,migration: Prevent rmap_walk_[anon|ksm] seeing the wrong VMA information

vma_adjust() is updating anon VMA information without any locks taken.
In contrast, file-backed mappings use the i_mmap_lock and this lack of
locking can result in races with page migration. During rmap_walk(),
vma_address() can return -EFAULT for an address that will soon be valid.
This leaves a dangling migration PTE behind which can later cause a BUG_ON
to trigger when the page is faulted in.

With the recent anon_vma changes, there can be more than one anon_vma->lock
that can be taken in a anon_vma_chain but a second lock cannot be spinned
upon in case of deadlock. Instead, the rmap walker tries to take locks of
different anon_vma's. If the attempt fails, the operation is restarted.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/ksm.c  |   19 +++++++++++++++++--
 mm/mmap.c |    6 ++++++
 mm/rmap.c |   27 +++++++++++++++++++++++----
 3 files changed, 46 insertions(+), 6 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 3666d43..87c7531 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1674,9 +1674,19 @@ again:
 		spin_lock(&anon_vma->lock);
 		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
 			vma = vmac->vma;
+
+			/* See comment in mm/rmap.c#rmap_walk_anon on locking */
+			if (anon_vma != vma->anon_vma) {
+				if (!spin_trylock(&vma->anon_vma->lock)) {
+					spin_unlock(&anon_vma->lock);
+					goto again;
+				}
+			}
+
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
-				continue;
+				goto next_vma;
+
 			/*
 			 * Initially we examine only the vma which covers this
 			 * rmap_item; but later, if there is still work to do,
@@ -1684,9 +1694,14 @@ again:
 			 * were forked from the original since ksmd passed.
 			 */
 			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
-				continue;
+				goto next_vma;
 
 			ret = rmap_one(page, vma, rmap_item->address, arg);
+
+next_vma:
+			if (anon_vma != vma->anon_vma)
+				spin_unlock(&vma->anon_vma->lock);
+
 			if (ret != SWAP_AGAIN) {
 				spin_unlock(&anon_vma->lock);
 				goto out;
diff --git a/mm/mmap.c b/mm/mmap.c
index f90ea92..61d6f1d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -578,6 +578,9 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
+	if (vma->anon_vma)
+		spin_lock(&vma->anon_vma->lock);
+
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_remove(vma, root);
@@ -620,6 +623,9 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
+	if (vma->anon_vma)
+		spin_unlock(&vma->anon_vma->lock);
+
 	if (remove_next) {
 		if (file) {
 			fput(file);
diff --git a/mm/rmap.c b/mm/rmap.c
index 85f203e..7c2b7a9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1368,18 +1368,37 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	 * are holding mmap_sem. Users without mmap_sem are required to
 	 * take a reference count to prevent the anon_vma disappearing
 	 */
+retry:
 	anon_vma = page_anon_vma(page);
 	if (!anon_vma)
 		return ret;
 	spin_lock(&anon_vma->lock);
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
 		struct vm_area_struct *vma = avc->vma;
-		unsigned long address = vma_address(page, vma);
-		if (address == -EFAULT)
-			continue;
-		ret = rmap_one(page, vma, address, arg);
+		unsigned long address;
+
+		/*
+		 * Guard against deadlocks by not spinning against
+		 * vma->anon_vma->lock. If contention is found, release our lock and
+		 * try again until VMA list can be traversed without worrying about
+		 * the details of the VMA changing underneath us.
+		 */
+		if (anon_vma != vma->anon_vma) {
+			if (!spin_trylock(&vma->anon_vma->lock)) {
+				spin_unlock(&anon_vma->lock);
+				goto retry;
+			}
+		}
+		address = vma_address(page, vma);
+		if (address != -EFAULT)
+			ret = rmap_one(page, vma, address, arg);
+
+		if (anon_vma != vma->anon_vma)
+			spin_unlock(&vma->anon_vma->lock);
+
 		if (ret != SWAP_AGAIN)
 			break;
+		
 	}
 	spin_unlock(&anon_vma->lock);
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
