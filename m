Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C69E46B007B
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 11:43:51 -0500 (EST)
Date: Tue, 24 Nov 2009 16:43:27 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 3/9] ksm: hold anon_vma in rmap_item
In-Reply-To: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911241642180.25288@sister.anvils>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For full functionality, page_referenced_one() and try_to_unmap_one()
need to know the vma: to pass vma down to arch-dependent flushes,
or to observe VM_LOCKED or VM_EXEC.  But KSM keeps no record of vma:
nor can it, since vmas get split and merged without its knowledge.

Instead, note page's anon_vma in its rmap_item when adding to stable
tree: all the vmas which might map that page are listed by its anon_vma.

page_referenced_ksm() and try_to_unmap_ksm() then traverse the anon_vma,
first to find the probable vma, that which matches rmap_item's mm; but
if that is not enough to locate all instances, traverse again to try the
others.  This catches those occasions when fork has duplicated a pte of
a ksm page, but ksmd has not yet come around to assign it an rmap_item.

But each rmap_item in the stable tree which refers to an anon_vma needs
to take a reference to it.  Andrea's anon_vma design cleverly avoided a
reference count (an anon_vma was free when its list of vmas was empty),
but KSM now needs to add that.  Is a 32-bit count sufficient? I believe
so - the anon_vma is only free when both count is 0 and list is empty.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/rmap.h |   24 ++++++
 mm/ksm.c             |  153 ++++++++++++++++++++++++-----------------
 mm/rmap.c            |    5 -
 3 files changed, 120 insertions(+), 62 deletions(-)

--- ksm2/include/linux/rmap.h	2009-11-22 20:40:04.000000000 +0000
+++ ksm3/include/linux/rmap.h	2009-11-22 20:40:11.000000000 +0000
@@ -26,6 +26,9 @@
  */
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
+#ifdef CONFIG_KSM
+	atomic_t ksm_refcount;
+#endif
 	/*
 	 * NOTE: the LSB of the head.next is set by
 	 * mm_take_all_locks() _after_ taking the above lock. So the
@@ -38,6 +41,26 @@ struct anon_vma {
 };
 
 #ifdef CONFIG_MMU
+#ifdef CONFIG_KSM
+static inline void ksm_refcount_init(struct anon_vma *anon_vma)
+{
+	atomic_set(&anon_vma->ksm_refcount, 0);
+}
+
+static inline int ksm_refcount(struct anon_vma *anon_vma)
+{
+	return atomic_read(&anon_vma->ksm_refcount);
+}
+#else
+static inline void ksm_refcount_init(struct anon_vma *anon_vma)
+{
+}
+
+static inline int ksm_refcount(struct anon_vma *anon_vma)
+{
+	return 0;
+}
+#endif /* CONFIG_KSM */
 
 static inline struct anon_vma *page_anon_vma(struct page *page)
 {
@@ -70,6 +93,7 @@ void __anon_vma_merge(struct vm_area_str
 void anon_vma_unlink(struct vm_area_struct *);
 void anon_vma_link(struct vm_area_struct *);
 void __anon_vma_link(struct vm_area_struct *);
+void anon_vma_free(struct anon_vma *);
 
 /*
  * rmap interfaces called when adding or removing pte of page
--- ksm2/mm/ksm.c	2009-11-22 20:40:04.000000000 +0000
+++ ksm3/mm/ksm.c	2009-11-22 20:40:11.000000000 +0000
@@ -121,7 +121,7 @@ struct stable_node {
 /**
  * struct rmap_item - reverse mapping item for virtual addresses
  * @rmap_list: next rmap_item in mm_slot's singly-linked rmap_list
- * @filler: unused space we're making available in this patch
+ * @anon_vma: pointer to anon_vma for this mm,address, when in stable tree
  * @mm: the memory structure this rmap_item is pointing into
  * @address: the virtual address this rmap_item tracks (+ flags in low bits)
  * @oldchecksum: previous checksum of the page at that virtual address
@@ -131,7 +131,7 @@ struct stable_node {
  */
 struct rmap_item {
 	struct rmap_item *rmap_list;
-	unsigned long filler;
+	struct anon_vma *anon_vma;	/* when stable */
 	struct mm_struct *mm;
 	unsigned long address;		/* + low bits used for flags below */
 	unsigned int oldchecksum;	/* when unstable */
@@ -196,13 +196,6 @@ static DECLARE_WAIT_QUEUE_HEAD(ksm_threa
 static DEFINE_MUTEX(ksm_thread_mutex);
 static DEFINE_SPINLOCK(ksm_mmlist_lock);
 
-/*
- * Temporary hack for page_referenced_ksm() and try_to_unmap_ksm(),
- * later we rework things a little to get the right vma to them.
- */
-static DEFINE_SPINLOCK(ksm_fallback_vma_lock);
-static struct vm_area_struct ksm_fallback_vma;
-
 #define KSM_KMEM_CACHE(__struct, __flags) kmem_cache_create("ksm_"#__struct,\
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL)
@@ -323,6 +316,25 @@ static inline int in_stable_tree(struct
 	return rmap_item->address & STABLE_FLAG;
 }
 
+static void hold_anon_vma(struct rmap_item *rmap_item,
+			  struct anon_vma *anon_vma)
+{
+	rmap_item->anon_vma = anon_vma;
+	atomic_inc(&anon_vma->ksm_refcount);
+}
+
+static void drop_anon_vma(struct rmap_item *rmap_item)
+{
+	struct anon_vma *anon_vma = rmap_item->anon_vma;
+
+	if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->lock)) {
+		int empty = list_empty(&anon_vma->head);
+		spin_unlock(&anon_vma->lock);
+		if (empty)
+			anon_vma_free(anon_vma);
+	}
+}
+
 /*
  * ksmd, and unmerge_and_remove_all_rmap_items(), must not touch an mm's
  * page tables after it has passed through ksm_exit() - which, if necessary,
@@ -472,6 +484,7 @@ static void remove_rmap_item_from_tree(s
 			ksm_pages_shared--;
 		}
 
+		drop_anon_vma(rmap_item);
 		rmap_item->address &= PAGE_MASK;
 
 	} else if (rmap_item->address & UNSTABLE_FLAG) {
@@ -752,6 +765,9 @@ static int try_to_merge_one_page(struct
 	pte_t orig_pte = __pte(0);
 	int err = -EFAULT;
 
+	if (page == kpage)			/* ksm page forked */
+		return 0;
+
 	if (!(vma->vm_flags & VM_MERGEABLE))
 		goto out;
 	if (!PageAnon(page))
@@ -805,9 +821,6 @@ static int try_to_merge_with_ksm_page(st
 	struct vm_area_struct *vma;
 	int err = -EFAULT;
 
-	if (page == kpage)			/* ksm page forked */
-		return 0;
-
 	down_read(&mm->mmap_sem);
 	if (ksm_test_exit(mm))
 		goto out;
@@ -816,6 +829,11 @@ static int try_to_merge_with_ksm_page(st
 		goto out;
 
 	err = try_to_merge_one_page(vma, page, kpage);
+	if (err)
+		goto out;
+
+	/* Must get reference to anon_vma while still holding mmap_sem */
+	hold_anon_vma(rmap_item, vma->anon_vma);
 out:
 	up_read(&mm->mmap_sem);
 	return err;
@@ -869,6 +887,11 @@ static struct page *try_to_merge_two_pag
 	lru_cache_add_lru(kpage, LRU_ACTIVE_ANON);
 
 	err = try_to_merge_one_page(vma, page, kpage);
+	if (err)
+		goto up;
+
+	/* Must get reference to anon_vma while still holding mmap_sem */
+	hold_anon_vma(rmap_item, vma->anon_vma);
 up:
 	up_read(&mm->mmap_sem);
 
@@ -879,8 +902,10 @@ up:
 		 * If that fails, we have a ksm page with only one pte
 		 * pointing to it: so break it.
 		 */
-		if (err)
+		if (err) {
+			drop_anon_vma(rmap_item);
 			break_cow(rmap_item);
+		}
 	}
 	if (err) {
 		put_page(kpage);
@@ -1155,7 +1180,9 @@ static void cmp_and_merge_page(struct pa
 			 * in which case we need to break_cow on both.
 			 */
 			if (!stable_node) {
+				drop_anon_vma(tree_rmap_item);
 				break_cow(tree_rmap_item);
+				drop_anon_vma(rmap_item);
 				break_cow(rmap_item);
 			}
 		}
@@ -1490,7 +1517,7 @@ int page_referenced_ksm(struct page *pag
 	struct hlist_node *hlist;
 	unsigned int mapcount = page_mapcount(page);
 	int referenced = 0;
-	struct vm_area_struct *vma;
+	int search_new_forks = 0;
 
 	VM_BUG_ON(!PageKsm(page));
 	VM_BUG_ON(!PageLocked(page));
@@ -1498,36 +1525,40 @@ int page_referenced_ksm(struct page *pag
 	stable_node = page_stable_node(page);
 	if (!stable_node)
 		return 0;
-
-	/*
-	 * Temporary hack: really we need anon_vma in rmap_item, to
-	 * provide the correct vma, and to find recently forked instances.
-	 * Use zalloc to avoid weirdness if any other fields are involved.
-	 */
-	vma = kmem_cache_zalloc(vm_area_cachep, GFP_ATOMIC);
-	if (!vma) {
-		spin_lock(&ksm_fallback_vma_lock);
-		vma = &ksm_fallback_vma;
-	}
-
+again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
+		struct anon_vma *anon_vma = rmap_item->anon_vma;
+		struct vm_area_struct *vma;
+
 		if (memcg && !mm_match_cgroup(rmap_item->mm, memcg))
 			continue;
 
-		vma->vm_mm = rmap_item->mm;
-		vma->vm_start = rmap_item->address;
-		vma->vm_end = vma->vm_start + PAGE_SIZE;
+		spin_lock(&anon_vma->lock);
+		list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+			if (rmap_item->address < vma->vm_start ||
+			    rmap_item->address >= vma->vm_end)
+				continue;
+			/*
+			 * Initially we examine only the vma which covers this
+			 * rmap_item; but later, if there is still work to do,
+			 * we examine covering vmas in other mms: in case they
+			 * were forked from the original since ksmd passed.
+			 */
+			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
+				continue;
 
-		referenced += page_referenced_one(page, vma,
+			referenced += page_referenced_one(page, vma,
 				rmap_item->address, &mapcount, vm_flags);
+			if (!search_new_forks || !mapcount)
+				break;
+		}
+		spin_unlock(&anon_vma->lock);
 		if (!mapcount)
 			goto out;
 	}
+	if (!search_new_forks++)
+		goto again;
 out:
-	if (vma == &ksm_fallback_vma)
-		spin_unlock(&ksm_fallback_vma_lock);
-	else
-		kmem_cache_free(vm_area_cachep, vma);
 	return referenced;
 }
 
@@ -1537,7 +1568,7 @@ int try_to_unmap_ksm(struct page *page,
 	struct hlist_node *hlist;
 	struct rmap_item *rmap_item;
 	int ret = SWAP_AGAIN;
-	struct vm_area_struct *vma;
+	int search_new_forks = 0;
 
 	VM_BUG_ON(!PageKsm(page));
 	VM_BUG_ON(!PageLocked(page));
@@ -1545,35 +1576,37 @@ int try_to_unmap_ksm(struct page *page,
 	stable_node = page_stable_node(page);
 	if (!stable_node)
 		return SWAP_FAIL;
-
-	/*
-	 * Temporary hack: really we need anon_vma in rmap_item, to
-	 * provide the correct vma, and to find recently forked instances.
-	 * Use zalloc to avoid weirdness if any other fields are involved.
-	 */
-	if (TTU_ACTION(flags) != TTU_UNMAP)
-		return SWAP_FAIL;
-
-	vma = kmem_cache_zalloc(vm_area_cachep, GFP_ATOMIC);
-	if (!vma) {
-		spin_lock(&ksm_fallback_vma_lock);
-		vma = &ksm_fallback_vma;
-	}
-
+again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
-		vma->vm_mm = rmap_item->mm;
-		vma->vm_start = rmap_item->address;
-		vma->vm_end = vma->vm_start + PAGE_SIZE;
+		struct anon_vma *anon_vma = rmap_item->anon_vma;
+		struct vm_area_struct *vma;
 
-		ret = try_to_unmap_one(page, vma, rmap_item->address, flags);
-		if (ret != SWAP_AGAIN || !page_mapped(page))
-			goto out;
+		spin_lock(&anon_vma->lock);
+		list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+			if (rmap_item->address < vma->vm_start ||
+			    rmap_item->address >= vma->vm_end)
+				continue;
+			/*
+			 * Initially we examine only the vma which covers this
+			 * rmap_item; but later, if there is still work to do,
+			 * we examine covering vmas in other mms: in case they
+			 * were forked from the original since ksmd passed.
+			 */
+			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
+				continue;
+
+			ret = try_to_unmap_one(page, vma,
+					rmap_item->address, flags);
+			if (ret != SWAP_AGAIN || !page_mapped(page)) {
+				spin_unlock(&anon_vma->lock);
+				goto out;
+			}
+		}
+		spin_unlock(&anon_vma->lock);
 	}
+	if (!search_new_forks++)
+		goto again;
 out:
-	if (vma == &ksm_fallback_vma)
-		spin_unlock(&ksm_fallback_vma_lock);
-	else
-		kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
 
--- ksm2/mm/rmap.c	2009-11-22 20:40:04.000000000 +0000
+++ ksm3/mm/rmap.c	2009-11-22 20:40:11.000000000 +0000
@@ -68,7 +68,7 @@ static inline struct anon_vma *anon_vma_
 	return kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
 }
 
-static inline void anon_vma_free(struct anon_vma *anon_vma)
+void anon_vma_free(struct anon_vma *anon_vma)
 {
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
@@ -172,7 +172,7 @@ void anon_vma_unlink(struct vm_area_stru
 	list_del(&vma->anon_vma_node);
 
 	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head);
+	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma);
 	spin_unlock(&anon_vma->lock);
 
 	if (empty)
@@ -184,6 +184,7 @@ static void anon_vma_ctor(void *data)
 	struct anon_vma *anon_vma = data;
 
 	spin_lock_init(&anon_vma->lock);
+	ksm_refcount_init(anon_vma);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
