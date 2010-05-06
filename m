Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 47A9D6B0245
	for <linux-mm@kvack.org>; Wed,  5 May 2010 20:23:18 -0400 (EDT)
Date: Thu, 6 May 2010 01:22:56 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100506002255.GY20979@csn.ul.ie>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org> <20100505175311.GU20979@csn.ul.ie> <alpine.LFD.2.00.1005051058380.27218@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005051058380.27218@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 11:02:25AM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 5 May 2010, Mel Gorman wrote:
> > 
> > If the same_vma list is properly ordered then maybe something like the
> > following is allowed?
> 
> Heh. This is the same logic I just sent out. However:
> 
> > +	anon_vma = page_rmapping(page);
> > +	if (!anon_vma)
> > +		return NULL;
> > +
> > +	spin_lock(&anon_vma->lock);
> 
> RCU should guarantee that this spin_lock() is valid, but:
> 
> > +	/*
> > +	 * Get the oldest anon_vma on the list by depending on the ordering
> > +	 * of the same_vma list setup by __page_set_anon_rmap
> > +	 */
> > +	avc = list_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
> 
> We're not guaranteed that the 'anon_vma->head' list is non-empty.
> 
> Somebody could have freed the list and the anon_vma and we have a stale 
> 'page->anon_vma' (that has just not been _released_ yet). 
> 
> And shouldn't that be 'list_first_entry'? Or &anon_vma->head.next?
> 
> How did that line actually work for you? Or was it just a "it boots", but 
> no actual testing of the rmap walk?
> 

This is what I just started testing on a 4-core machine. Lockdep didn't
complain but there are two potential sources of badness in anon_vma_lock_root
marked with XXX. The second is the most important because I can't see how the
local and root anon_vma locks can be safely swapped - i.e. release local and
get the root without the root disappearing. I haven't considered the other
possibilities yet such as always locking the root anon_vma. Going to
sleep on it.

Any comments?

==== CUT HERE ====
mm,migration: Prevent rmap_walk_[anon|ksm] seeing the wrong VMA information

vma_adjust() is updating anon VMA information without locks being taken.
In contrast, file-backed mappings use the i_mmap_lock and this lack of
locking can result in races with users of rmap_walk such as page migration.
vma_address() can return -EFAULT for an address that will soon be valid.
For migration, this potentially leaves a dangling migration PTE behind
which can later cause a BUG_ON to trigger when the page is faulted in.

With the recent anon_vma changes, there can be more than one anon_vma->lock to
take in a anon_vma_chain but as the order of anon_vmas cannot be guaranteed,
rmap_walk cannot take multiple locks. This patch has rmap_walk start
by locking the anon_vma lock associated with a page. It then finds the
"root" anon_vma using the anon_vma_chains same_vma list as it is strictly
ordered. The root anon_vma lock is taken and rmap_walk traverses the
list. This allows multiple locks to be taken as the list is always traversed
in the same direction.

For vma_adjust(), the locking behaviour prior to the anon_vma is restored
so that rmap_walk() can be sure of the integrity of the VMA information and
lists when the anon_vma lock is held. With this patch, the vma->anon_vma->lock
is taken if

	a) If there is any overlap with the next VMA due to the adjustment
	b) If there is a new VMA is being inserted into the address space
	c) If the start of the VMA is being changed so that the
	   relationship between vm_start and vm_pgoff is preserved
	   for vma_address()

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/rmap.h |    2 +
 mm/ksm.c             |   20 ++++++++++--
 mm/mmap.c            |    9 +++++
 mm/rmap.c            |   88 +++++++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 108 insertions(+), 11 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 7721674..6d4d5f7 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -121,6 +121,8 @@ int  anon_vma_prepare(struct vm_area_struct *);
 void unlink_anon_vmas(struct vm_area_struct *);
 int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
 int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
+struct anon_vma *anon_vma_lock_root(struct anon_vma *anon_vma);
+struct anon_vma *page_anon_vma_lock_root(struct page *page);
 void __anon_vma_link(struct vm_area_struct *);
 void anon_vma_free(struct anon_vma *);
 
diff --git a/mm/ksm.c b/mm/ksm.c
index 3666d43..d16b459 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1668,15 +1668,24 @@ int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
+		struct anon_vma *locked_vma;
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
-		spin_lock(&anon_vma->lock);
+		anon_vma = anon_vma_lock_root(anon_vma);
 		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
 			vma = vmac->vma;
+
+			locked_vma = NULL;
+			if (anon_vma != vma->anon_vma) {
+				locked_vma = vma->anon_vma;
+				spin_lock_nested(&locked_vma->lock, SINGLE_DEPTH_NESTING);
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
@@ -1684,9 +1693,14 @@ again:
 			 * were forked from the original since ksmd passed.
 			 */
 			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
-				continue;
+				goto next_vma;
 
 			ret = rmap_one(page, vma, rmap_item->address, arg);
+
+next_vma:
+			if (locked_vma)
+				spin_unlock(&locked_vma->lock);
+
 			if (ret != SWAP_AGAIN) {
 				spin_unlock(&anon_vma->lock);
 				goto out;
diff --git a/mm/mmap.c b/mm/mmap.c
index f90ea92..d635132 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -505,6 +505,7 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	struct vm_area_struct *next = vma->vm_next;
 	struct vm_area_struct *importer = NULL;
 	struct address_space *mapping = NULL;
+	struct anon_vma *anon_vma = NULL;
 	struct prio_tree_root *root = NULL;
 	struct file *file = vma->vm_file;
 	long adjust_next = 0;
@@ -578,6 +579,11 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
+	if (vma->anon_vma && (insert || importer || start != vma->vm_start)) {
+		anon_vma = vma->anon_vma;
+		spin_lock(&anon_vma->lock);
+	}
+
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_remove(vma, root);
@@ -620,6 +626,9 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
+	if (anon_vma)
+		spin_unlock(&anon_vma->lock);
+
 	if (remove_next) {
 		if (file) {
 			fput(file);
diff --git a/mm/rmap.c b/mm/rmap.c
index 85f203e..0d8db6d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -236,6 +236,69 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	return -ENOMEM;
 }
 
+/* Given an anon_vma, find the root of the chain, lock it and return the root */
+struct anon_vma *anon_vma_lock_root(struct anon_vma *anon_vma)
+{
+	struct anon_vma *root_anon_vma;
+	struct anon_vma_chain *avc, *root_avc;
+	struct vm_area_struct *vma;
+
+	/* Lock the same_anon_vma list and make sure we are on a chain */
+	spin_lock(&anon_vma->lock);
+	if (list_empty(&anon_vma->head)) {
+		spin_unlock(&anon_vma->lock);
+		return NULL;
+	}
+
+	/*
+	 * Get the root anon_vma on the list by depending on the ordering
+	 * of the same_vma list setup by __page_set_anon_rmap. Basically
+	 * we are doing
+	 *
+	 * local anon_vma -> local vma -> deepest vma -> anon_vma
+	 */
+	avc = list_first_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
+	vma = avc->vma;
+	root_avc = list_entry(vma->anon_vma_chain.prev, struct anon_vma_chain, same_vma);
+	root_anon_vma = root_avc->anon_vma;
+	if (!root_anon_vma) {
+		/* XXX: Can this happen? Don't think so but get confirmation */
+		WARN_ON_ONCE(1);
+		return anon_vma;
+	}
+
+	/* Get the lock of the root anon_vma */
+	if (anon_vma != root_anon_vma) {
+		/*
+		 * XXX: This doesn't seem safe. What prevents root_anon_vma
+		 * getting freed from underneath us? Not much but if
+		 * we take the second lock first, there is a deadlock
+		 * possibility if there are multiple callers of rmap_walk
+		 */
+		spin_unlock(&anon_vma->lock);
+		spin_lock(&root_anon_vma->lock);
+	}
+
+	return root_anon_vma;
+}
+
+/*
+ * From the anon_vma associated with this page, find and lock the
+ * deepest anon_vma on the list. This allows multiple anon_vma locks
+ * to be taken by guaranteeing the locks are taken in the same order
+ */
+struct anon_vma *page_anon_vma_lock_root(struct page *page)
+{
+	struct anon_vma *anon_vma;
+
+	/* Get the local anon_vma */
+	anon_vma = page_anon_vma(page);
+	if (!anon_vma)
+		return NULL;
+
+	return anon_vma_lock_root(anon_vma);
+}
+
 static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
 {
 	struct anon_vma *anon_vma = anon_vma_chain->anon_vma;
@@ -326,7 +389,7 @@ void page_unlock_anon_vma(struct anon_vma *anon_vma)
  * Returns virtual address or -EFAULT if page's index/offset is not
  * within the range mapped the @vma.
  */
-static inline unsigned long
+static noinline unsigned long
 vma_address(struct page *page, struct vm_area_struct *vma)
 {
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -1358,7 +1421,7 @@ int try_to_munlock(struct page *page)
 static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 		struct vm_area_struct *, unsigned long, void *), void *arg)
 {
-	struct anon_vma *anon_vma;
+	struct anon_vma *anon_vma, *locked_vma;
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
@@ -1368,16 +1431,25 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	 * are holding mmap_sem. Users without mmap_sem are required to
 	 * take a reference count to prevent the anon_vma disappearing
 	 */
-	anon_vma = page_anon_vma(page);
+	anon_vma = page_anon_vma_lock_root(page);
 	if (!anon_vma)
 		return ret;
-	spin_lock(&anon_vma->lock);
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
 		struct vm_area_struct *vma = avc->vma;
-		unsigned long address = vma_address(page, vma);
-		if (address == -EFAULT)
-			continue;
-		ret = rmap_one(page, vma, address, arg);
+		unsigned long address;
+
+		locked_vma = NULL;
+		if (anon_vma != vma->anon_vma) {
+			locked_vma = vma->anon_vma;
+			spin_lock_nested(&locked_vma->lock, SINGLE_DEPTH_NESTING);
+		}
+		address = vma_address(page, vma);
+		if (address != -EFAULT)
+			ret = rmap_one(page, vma, address, arg);
+
+		if (locked_vma)
+			spin_unlock(&locked_vma->lock);
+
 		if (ret != SWAP_AGAIN)
 			break;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
