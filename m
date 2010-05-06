Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5FA6B02B5
	for <linux-mm@kvack.org>; Thu,  6 May 2010 11:33:21 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing the wrong VMA information
Date: Thu,  6 May 2010 16:33:06 +0100
Message-Id: <1273159987-10167-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1273159987-10167-1-git-send-email-mel@csn.ul.ie>
References: <1273159987-10167-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

vma_adjust() is updating anon VMA information without locks being taken
unlike what happened in 2.6.33.  In contrast, file-backed mappings use
the i_mmap_lock and this lack of locking can result in races with users of
rmap_walk such as page migration.  vma_address() can return -EFAULT for an
address that will soon be valid.  For migration, this potentially leaves
a dangling migration PTE behind which can later cause a BUG_ON to trigger
when the page is faulted in.

With the recent anon_vma changes, there can be more than one anon_vma->lock
to take when walking a list of anon_vma_chains. As rmap_walk begins with
the anon_vma a page is associated with, the order of anon_vmas cannot be
guaranteed and multiple locks cannot be taken without potentially deadlocking.

To resolve this problem, this patch has rmap_walk walk the anon_vma_chain
list but always starting from the "root" anon_vma which is the oldest
anon_vma in the list. It starts by locking the anon_vma lock associated
with a page. It then finds the "root" anon_vma using the anon_vma_chains
"same_vma" list as it is strictly ordered. The root anon_vma lock is taken
and rmap_walk traverses the list. This allows multiple locks to be taken
as the list is always traversed in the same direction.

As spotted by Rik, to avoid any deadlocks versus mmu_notify, the order that
anon_vmas is locked in by mm_take_all_locks is reversed by this patch so that
both rmap_walk and mm_take_all_locks lock anon_vmas in the order of
old to new.

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
 mm/mmap.c            |   14 +++++++-
 mm/rmap.c            |   81 +++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 104 insertions(+), 13 deletions(-)

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
index f90ea92..b447d5b 100644
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
@@ -2556,8 +2565,9 @@ int mm_take_all_locks(struct mm_struct *mm)
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (signal_pending(current))
 			goto out_unlock;
+		/* Lock the anon_vmas in the same order rmap_walk would */
 		if (vma->anon_vma)
-			list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
+			list_for_each_entry_reverse(avc, &vma->anon_vma_chain, same_vma)
 				vm_lock_anon_vma(mm, avc->anon_vma);
 	}
 
@@ -2620,7 +2630,7 @@ void mm_drop_all_locks(struct mm_struct *mm)
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->anon_vma)
-			list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
+			list_for_each_entry_reverse(avc, &vma->anon_vma_chain, same_vma)
 				vm_unlock_anon_vma(avc->anon_vma);
 		if (vma->vm_file && vma->vm_file->f_mapping)
 			vm_unlock_mapping(vma->vm_file->f_mapping);
diff --git a/mm/rmap.c b/mm/rmap.c
index 85f203e..b511710 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -236,6 +236,62 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	return -ENOMEM;
 }
 
+/*
+ * Given an anon_vma, find the root of the chain, lock it and return it.
+ * This must be called with the rcu_read_lock held
+ */
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
+	 * local anon_vma -> local vma -> root vma -> root anon_vma
+	 */
+	avc = list_first_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
+	vma = avc->vma;
+	root_avc = list_entry(vma->anon_vma_chain.prev, struct anon_vma_chain, same_vma);
+	root_anon_vma = root_avc->anon_vma;
+
+	/* Get the lock of the root anon_vma */
+	if (anon_vma != root_anon_vma) {
+		VM_BUG_ON(!rcu_read_lock_held());
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
@@ -1358,7 +1414,7 @@ int try_to_munlock(struct page *page)
 static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 		struct vm_area_struct *, unsigned long, void *), void *arg)
 {
-	struct anon_vma *anon_vma;
+	struct anon_vma *anon_vma, *locked_vma;
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
@@ -1368,16 +1424,25 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
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
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
