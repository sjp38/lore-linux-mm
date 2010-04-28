Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 08F706B01F4
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 16:58:06 -0400 (EDT)
Date: Wed, 28 Apr 2010 16:57:34 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH -v3] take all anon_vma locks in anon_vma_lock
Message-ID: <20100428165734.6541bab3@annuminas.surriel.com>
In-Reply-To: <20100428161711.5a815fa8@annuminas.surriel.com>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<1272403852-10479-3-git-send-email-mel@csn.ul.ie>
	<20100427231007.GA510@random.random>
	<20100428091555.GB15815@csn.ul.ie>
	<20100428153525.GR510@random.random>
	<20100428155558.GI15815@csn.ul.ie>
	<20100428162305.GX510@random.random>
	<20100428134719.32e8011b@annuminas.surriel.com>
	<20100428142510.09984e15@annuminas.surriel.com>
	<20100428161711.5a815fa8@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Take all the locks for all the anon_vmas in anon_vma_lock, this properly
excludes migration and the transparent hugepage code from VMA changes done
by mmap/munmap/mprotect/expand_stack/etc...

Unfortunately, this requires adding a new lock (mm->anon_vma_chain_lock),
otherwise we have an unavoidable lock ordering conflict.  This changes the
locking rules for the "same_vma" list to be either mm->mmap_sem for write, 
or mm->mmap_sem for read plus the new mm->anon_vma_chain lock.  This limits
the place where the new lock is taken to 2 locations - anon_vma_prepare and
expand_downwards.

Document the locking rules for the same_vma list in the anon_vma_chain and
remove the anon_vma_lock call from expand_upwards, which does not need it.

Signed-off-by: Rik van Riel <riel@redhat.com>

--- 
Posted quickly as an RFC patch, only compile tested so far.
Andrea, Mel, does this look like a reasonable approach?

v3:
 - change anon_vma_unlock into a macro so lockdep works right
 - fix lock ordering in anon_vma_prepare
v2:
 - also change anon_vma_unlock to walk the loop
 - add calls to anon_vma_lock & anon_vma_unlock to vma_adjust
 - introduce a new lock for the vma->anon_vma_chain list, to prevent
   the lock inversion that Andrea pointed out

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index b8bb9a6..a0679c6 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -239,6 +239,7 @@ struct mm_struct {
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
+	spinlock_t anon_vma_chain_lock;		/* Protects vma->anon_vma_chain, with mmap_sem */
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
 						 * together off init_mm.mmlist, and are protected
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index d25bd22..703c472 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -52,11 +52,15 @@ struct anon_vma {
  * all the anon_vmas associated with this VMA.
  * The "same_anon_vma" list contains the anon_vma_chains
  * which link all the VMAs associated with this anon_vma.
+ *
+ * The "same_vma" list is locked by either having mm->mmap_sem
+ * locked for writing, or having mm->mmap_sem locked for reading
+ * AND holding the mm->anon_vma_chain_lock.
  */
 struct anon_vma_chain {
 	struct vm_area_struct *vma;
 	struct anon_vma *anon_vma;
-	struct list_head same_vma;   /* locked by mmap_sem & page_table_lock */
+	struct list_head same_vma;	/* see above */
 	struct list_head same_anon_vma;	/* locked by anon_vma->lock */
 };
 
@@ -90,18 +94,24 @@ static inline struct anon_vma *page_anon_vma(struct page *page)
 	return page_rmapping(page);
 }
 
-static inline void anon_vma_lock(struct vm_area_struct *vma)
-{
-	struct anon_vma *anon_vma = vma->anon_vma;
-	if (anon_vma)
-		spin_lock(&anon_vma->lock);
-}
+#define anon_vma_lock(vma, nest_lock)					\
+({									\
+	struct anon_vma *anon_vma = vma->anon_vma;			\
+	if (anon_vma) {							\
+		struct anon_vma_chain *avc;				\
+		list_for_each_entry(avc, &vma->anon_vma_chain, same_vma) \
+			spin_lock_nest_lock(&avc->anon_vma->lock, nest_lock); \
+	}								\
+})
 
 static inline void anon_vma_unlock(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
-	if (anon_vma)
-		spin_unlock(&anon_vma->lock);
+	if (anon_vma) {
+		struct anon_vma_chain *avc;
+		list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
+			spin_unlock(&avc->anon_vma->lock);
+	}
 }
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index 44b0791..83b1ba2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -468,6 +468,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 	mm->nr_ptes = 0;
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
+	spin_lock_init(&mm->anon_vma_chain_lock);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
 	mm_init_aio(mm);
diff --git a/mm/init-mm.c b/mm/init-mm.c
index 57aba0d..3ce8a1f 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -15,6 +15,7 @@ struct mm_struct init_mm = {
 	.mm_count	= ATOMIC_INIT(1),
 	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
+	.anon_vma_chain_lock =  __SPIN_LOCK_UNLOCKED(init_mm.anon_vma_chain_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
 	.cpu_vm_mask	= CPU_MASK_ALL,
 };
diff --git a/mm/mmap.c b/mm/mmap.c
index f90ea92..4602358 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -452,7 +452,7 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
 		spin_lock(&mapping->i_mmap_lock);
 		vma->vm_truncate_count = mapping->truncate_count;
 	}
-	anon_vma_lock(vma);
+	anon_vma_lock(vma, &mm->mmap_sem);
 
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	__vma_link_file(vma);
@@ -578,6 +578,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
+	anon_vma_lock(vma, &mm->mmap_sem);
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_remove(vma, root);
@@ -599,6 +600,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 		vma_prio_tree_insert(vma, root);
 		flush_dcache_mmap_unlock(mapping);
 	}
+	anon_vma_unlock(vma);
 
 	if (remove_next) {
 		/*
@@ -1705,12 +1707,11 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 		return -EFAULT;
 
 	/*
-	 * We must make sure the anon_vma is allocated
-	 * so that the anon_vma locking is not a noop.
+	 * Unlike expand_downwards, we do not need to take the anon_vma lock,
+	 * because we leave vma->vm_start and vma->pgoff untouched. 
+	 * This means rmap lookups of pages inside this VMA stay valid
+	 * throughout the stack expansion.
 	 */
-	if (unlikely(anon_vma_prepare(vma)))
-		return -ENOMEM;
-	anon_vma_lock(vma);
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
@@ -1721,7 +1722,6 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 	if (address < PAGE_ALIGN(address+4))
 		address = PAGE_ALIGN(address+4);
 	else {
-		anon_vma_unlock(vma);
 		return -ENOMEM;
 	}
 	error = 0;
@@ -1737,7 +1737,6 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 		if (!error)
 			vma->vm_end = address;
 	}
-	anon_vma_unlock(vma);
 	return error;
 }
 #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
@@ -1749,6 +1748,7 @@ static int expand_downwards(struct vm_area_struct *vma,
 				   unsigned long address)
 {
 	int error;
+	struct mm_struct *mm = vma->vm_mm;
 
 	/*
 	 * We must make sure the anon_vma is allocated
@@ -1762,7 +1762,8 @@ static int expand_downwards(struct vm_area_struct *vma,
 	if (error)
 		return error;
 
-	anon_vma_lock(vma);
+	spin_lock(&mm->anon_vma_chain_lock);
+	anon_vma_lock(vma, &mm->anon_vma_chain_lock);
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
@@ -1784,6 +1785,8 @@ static int expand_downwards(struct vm_area_struct *vma,
 		}
 	}
 	anon_vma_unlock(vma);
+	spin_unlock(&mm->anon_vma_chain_lock);
+
 	return error;
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 526704e..98d6289 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -23,6 +23,7 @@
  * inode->i_mutex	(while writing or truncating, not reading or faulting)
  *   inode->i_alloc_sem (vmtruncate_range)
  *   mm->mmap_sem
+ *   mm->anon_vma_chain_lock (mmap_sem for read, protects vma->anon_vma_chain)
  *     page->flags PG_locked (lock_page)
  *       mapping->i_mmap_lock
  *         anon_vma->lock
@@ -133,10 +134,11 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 				goto out_enomem_free_avc;
 			allocated = anon_vma;
 		}
+
+		/* anon_vma_chain_lock to protect against threads */
+		spin_lock(&mm->anon_vma_chain_lock);
 		spin_lock(&anon_vma->lock);
 
-		/* page_table_lock to protect against threads */
-		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
 			vma->anon_vma = anon_vma;
 			avc->anon_vma = anon_vma;
@@ -145,9 +147,9 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 			list_add(&avc->same_anon_vma, &anon_vma->head);
 			allocated = NULL;
 		}
-		spin_unlock(&mm->page_table_lock);
-
 		spin_unlock(&anon_vma->lock);
+		spin_unlock(&mm->anon_vma_chain_lock);
+
 		if (unlikely(allocated)) {
 			anon_vma_free(allocated);
 			anon_vma_chain_free(avc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
