Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id D7BBA6B0069
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:21:15 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id i14so4546695dad.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 02:21:15 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 3/7] mm anon rmap: remove anon_vma_moveto_tail
Date: Tue,  4 Sep 2012 02:20:53 -0700
Message-Id: <1346750457-12385-4-git-send-email-walken@google.com>
In-Reply-To: <1346750457-12385-1-git-send-email-walken@google.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org

mremap() had a clever optimization where move_ptes() did not take the
anon_vma lock to avoid a race with anon rmap users such as page migration.
Instead, the avc's were ordered in such a way that the origin vma was
always visited by rmap before the destination. This ordering and the use
of page table locks rmap usage safe. However, we want to replace the
use of linked lists in anon rmap with an interval tree, and this will
make it harder to impose such ordering as the interval tree will always
be sorted by the avc->vma->vm_pgoff value. For now, let's replace the
anon_vma_moveto_tail() ordering function with proper anon_vma locking
in move_ptes(). Once we have the anon interval tree in place, we will
re-introduce an optimization to avoid taking these locks in the most
common cases.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/rmap.h |    1 -
 mm/mmap.c            |    3 +--
 mm/mremap.c          |   14 +++++---------
 mm/rmap.c            |   45 ---------------------------------------------
 4 files changed, 6 insertions(+), 57 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 3fce545df394..7f32cec57e67 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -120,7 +120,6 @@ void anon_vma_init(void);	/* create anon_vma_cachep */
 int  anon_vma_prepare(struct vm_area_struct *);
 void unlink_anon_vmas(struct vm_area_struct *);
 int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
-void anon_vma_moveto_tail(struct vm_area_struct *);
 int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
 
 static inline void anon_vma_merge(struct vm_area_struct *vma,
diff --git a/mm/mmap.c b/mm/mmap.c
index 5e64c7dfc090..ea647255d763 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2397,8 +2397,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			 */
 			VM_BUG_ON(faulted_in_anon_vma);
 			*vmap = new_vma;
-		} else
-			anon_vma_moveto_tail(new_vma);
+		}
 	} else {
 		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (new_vma) {
diff --git a/mm/mremap.c b/mm/mremap.c
index 21fed202ddad..95fb2e024ced 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -74,6 +74,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		unsigned long new_addr)
 {
 	struct address_space *mapping = NULL;
+	struct anon_vma *anon_vma = vma->anon_vma;
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
@@ -88,6 +89,8 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		mapping = vma->vm_file->f_mapping;
 		mutex_lock(&mapping->i_mmap_mutex);
 	}
+	if (anon_vma)
+		anon_vma_lock(anon_vma);
 
 	/*
 	 * We don't have to worry about the ordering of src and dst
@@ -114,6 +117,8 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		spin_unlock(new_ptl);
 	pte_unmap(new_pte - 1);
 	pte_unmap_unlock(old_pte - 1, old_ptl);
+	if (anon_vma)
+		anon_vma_unlock(anon_vma);
 	if (mapping)
 		mutex_unlock(&mapping->i_mmap_mutex);
 }
@@ -221,15 +226,6 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len);
 	if (moved_len < old_len) {
 		/*
-		 * Before moving the page tables from the new vma to
-		 * the old vma, we need to be sure the old vma is
-		 * queued after new vma in the same_anon_vma list to
-		 * prevent SMP races with rmap_walk (that could lead
-		 * rmap_walk to miss some page table).
-		 */
-		anon_vma_moveto_tail(vma);
-
-		/*
 		 * On error, move entries back from new area to old,
 		 * which will succeed since page tables still there,
 		 * and then proceed to unmap new area instead of old.
diff --git a/mm/rmap.c b/mm/rmap.c
index 7b5b51d25fc5..8cbd62fde0f1 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -269,51 +269,6 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 }
 
 /*
- * Some rmap walk that needs to find all ptes/hugepmds without false
- * negatives (like migrate and split_huge_page) running concurrent
- * with operations that copy or move pagetables (like mremap() and
- * fork()) to be safe. They depend on the anon_vma "same_anon_vma"
- * list to be in a certain order: the dst_vma must be placed after the
- * src_vma in the list. This is always guaranteed by fork() but
- * mremap() needs to call this function to enforce it in case the
- * dst_vma isn't newly allocated and chained with the anon_vma_clone()
- * function but just an extension of a pre-existing vma through
- * vma_merge.
- *
- * NOTE: the same_anon_vma list can still be changed by other
- * processes while mremap runs because mremap doesn't hold the
- * anon_vma mutex to prevent modifications to the list while it
- * runs. All we need to enforce is that the relative order of this
- * process vmas isn't changing (we don't care about other vmas
- * order). Each vma corresponds to an anon_vma_chain structure so
- * there's no risk that other processes calling anon_vma_moveto_tail()
- * and changing the same_anon_vma list under mremap() will screw with
- * the relative order of this process vmas in the list, because we
- * they can't alter the order of any vma that belongs to this
- * process. And there can't be another anon_vma_moveto_tail() running
- * concurrently with mremap() coming from this process because we hold
- * the mmap_sem for the whole mremap(). fork() ordering dependency
- * also shouldn't be affected because fork() only cares that the
- * parent vmas are placed in the list before the child vmas and
- * anon_vma_moveto_tail() won't reorder vmas from either the fork()
- * parent or child.
- */
-void anon_vma_moveto_tail(struct vm_area_struct *dst)
-{
-	struct anon_vma_chain *pavc;
-	struct anon_vma *root = NULL;
-
-	list_for_each_entry_reverse(pavc, &dst->anon_vma_chain, same_vma) {
-		struct anon_vma *anon_vma = pavc->anon_vma;
-		VM_BUG_ON(pavc->vma != dst);
-		root = lock_anon_vma_root(root, anon_vma);
-		list_del(&pavc->same_anon_vma);
-		list_add_tail(&pavc->same_anon_vma, &anon_vma->head);
-	}
-	unlock_anon_vma_root(root);
-}
-
-/*
  * Attach vma to its own anon_vma, as well as to the anon_vmas that
  * the corresponding VMA in the parent process is attached to.
  * Returns 0 on success, non-zero on failure.
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
