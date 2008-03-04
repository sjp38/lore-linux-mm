Date: Mon, 3 Mar 2008 23:34:20 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [Early draft] Conversion of i_mmap_lock to semaphore
In-Reply-To: <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0803032331320.9692@schroedinger.engr.sgi.com>
References: <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de>
 <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random>
 <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random>
 <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random>
 <20080302155457.GK8091@v2.random> <20080303213707.GA8091@v2.random>
 <20080303220502.GA5301@v2.random> <47CC9B57.5050402@qumranet.com>
 <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Not there but the system boots and is usable. Complains about atomic 
contexts because the tlb functions use a get_cpu() and thus disable preempt.

Not sure yet what to do about the cond_resched_lock stuff etc.


Convert i_mmap_lock to i_mmap_sem

The conversion to a rwsemaphore allows callbacks during rmap traversal
for files in a non atomic context. A rw style lock allows concurrent
walking of the reverse map.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 arch/x86/mm/hugetlbpage.c |    4 ++--
 fs/hugetlbfs/inode.c      |    4 ++--
 fs/inode.c                |    2 +-
 include/linux/fs.h        |    2 +-
 include/linux/mm.h        |    2 +-
 kernel/fork.c             |    4 ++--
 mm/filemap.c              |    8 ++++----
 mm/filemap_xip.c          |    4 ++--
 mm/fremap.c               |    4 ++--
 mm/hugetlb.c              |   11 +++++------
 mm/memory.c               |   28 ++++++++--------------------
 mm/migrate.c              |    4 ++--
 mm/mmap.c                 |   16 ++++++++--------
 mm/mremap.c               |    4 ++--
 mm/rmap.c                 |   20 +++++++++-----------
 15 files changed, 51 insertions(+), 66 deletions(-)

Index: linux-2.6/arch/x86/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/hugetlbpage.c	2008-03-03 22:59:25.386848427 -0800
+++ linux-2.6/arch/x86/mm/hugetlbpage.c	2008-03-03 22:59:31.174878038 -0800
@@ -69,7 +69,7 @@ static void huge_pmd_share(struct mm_str
 	if (!vma_shareable(vma, addr))
 		return;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -94,7 +94,7 @@ static void huge_pmd_share(struct mm_str
 		put_page(virt_to_page(spte));
 	spin_unlock(&mm->page_table_lock);
 out:
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 }
 
 /*
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2008-03-03 22:59:25.410848010 -0800
+++ linux-2.6/fs/hugetlbfs/inode.c	2008-03-03 22:59:31.174878038 -0800
@@ -454,10 +454,10 @@ static int hugetlb_vmtruncate(struct ino
 	pgoff = offset >> PAGE_SHIFT;
 
 	i_size_write(inode, offset);
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	if (!prio_tree_empty(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 	truncate_hugepages(inode, offset);
 	return 0;
 }
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c	2008-03-03 22:59:25.418848099 -0800
+++ linux-2.6/fs/inode.c	2008-03-03 22:59:31.202878206 -0800
@@ -210,7 +210,7 @@ void inode_init_once(struct inode *inode
 	INIT_LIST_HEAD(&inode->i_devices);
 	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
 	rwlock_init(&inode->i_data.tree_lock);
-	spin_lock_init(&inode->i_data.i_mmap_lock);
+	init_rwsem(&inode->i_data.i_mmap_sem);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
 	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2008-03-03 22:59:25.430848089 -0800
+++ linux-2.6/include/linux/fs.h	2008-03-03 22:59:31.202878206 -0800
@@ -503,7 +503,7 @@ struct address_space {
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
-	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
+	struct rw_semaphore	i_mmap_sem;	/* protect tree, count, list */
 	unsigned int		truncate_count;	/* Cover race condition with truncate */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2008-03-03 22:59:25.442848167 -0800
+++ linux-2.6/include/linux/mm.h	2008-03-03 22:59:31.202878206 -0800
@@ -709,7 +709,7 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
-	spinlock_t *i_mmap_lock;		/* For unmap_mapping_range: */
+	struct rw_semaphore *i_mmap_sem;	/* For unmap_mapping_range: */
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
 };
 
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2008-03-03 22:59:27.230858013 -0800
+++ linux-2.6/kernel/fork.c	2008-03-03 22:59:31.202878206 -0800
@@ -273,12 +273,12 @@ static int dup_mmap(struct mm_struct *mm
 				atomic_dec(&inode->i_writecount);
 
 			/* insert tmp into the share list, just after mpnt */
-			spin_lock(&file->f_mapping->i_mmap_lock);
+			down_write(&file->f_mapping->i_mmap_sem);
 			tmp->vm_truncate_count = mpnt->vm_truncate_count;
 			flush_dcache_mmap_lock(file->f_mapping);
 			vma_prio_tree_add(tmp, mpnt);
 			flush_dcache_mmap_unlock(file->f_mapping);
-			spin_unlock(&file->f_mapping->i_mmap_lock);
+			up_write(&file->f_mapping->i_mmap_sem);
 		}
 
 		/*
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2008-03-03 22:59:25.462848256 -0800
+++ linux-2.6/mm/filemap.c	2008-03-03 22:59:31.206878010 -0800
@@ -62,16 +62,16 @@ generic_file_direct_IO(int rw, struct ki
 /*
  * Lock ordering:
  *
- *  ->i_mmap_lock		(vmtruncate)
+ *  ->i_mmap_sem		(vmtruncate)
  *    ->private_lock		(__free_pte->__set_page_dirty_buffers)
  *      ->swap_lock		(exclusive_swap_page, others)
  *        ->mapping->tree_lock
  *
  *  ->i_mutex
- *    ->i_mmap_lock		(truncate->unmap_mapping_range)
+ *    ->i_mmap_sem		(truncate->unmap_mapping_range)
  *
  *  ->mmap_sem
- *    ->i_mmap_lock
+ *    ->i_mmap_sem
  *      ->page_table_lock or pte_lock	(various, mainly in memory.c)
  *        ->mapping->tree_lock	(arch-dependent flush_dcache_mmap_lock)
  *
@@ -88,7 +88,7 @@ generic_file_direct_IO(int rw, struct ki
  *    ->sb_lock			(fs/fs-writeback.c)
  *    ->mapping->tree_lock	(__sync_single_inode)
  *
- *  ->i_mmap_lock
+ *  ->i_mmap_sem
  *    ->anon_vma.lock		(vma_adjust)
  *
  *  ->anon_vma.lock
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c	2008-03-03 22:59:25.474848348 -0800
+++ linux-2.6/mm/filemap_xip.c	2008-03-03 22:59:31.206878010 -0800
@@ -184,7 +184,7 @@ __xip_unmap (struct address_space * mapp
 	if (!page)
 		return;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;
 		address = vma->vm_start +
@@ -207,7 +207,7 @@ __xip_unmap (struct address_space * mapp
 		emm_notify(mm, emm_invalidate_end,
 					address, address + PAGE_SIZE);
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 }
 
 /*
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c	2008-03-03 22:59:25.482848555 -0800
+++ linux-2.6/mm/fremap.c	2008-03-03 22:59:31.206878010 -0800
@@ -205,13 +205,13 @@ asmlinkage long sys_remap_file_pages(uns
 			}
 			goto out;
 		}
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		flush_dcache_mmap_lock(mapping);
 		vma->vm_flags |= VM_NONLINEAR;
 		vma_prio_tree_remove(vma, &mapping->i_mmap);
 		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		flush_dcache_mmap_unlock(mapping);
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 	}
 
 	emm_notify(mm, emm_invalidate_start, start, end);
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-03-03 22:59:27.230858013 -0800
+++ linux-2.6/mm/hugetlb.c	2008-03-03 22:59:31.206878010 -0800
@@ -746,7 +746,7 @@ void __unmap_hugepage_range(struct vm_ar
 	struct page *page;
 	struct page *tmp;
 	/*
-	 * A page gathering list, protected by per file i_mmap_lock. The
+	 * A page gathering list, protected by per file i_mmap_sem. The
 	 * lock is used to avoid list corruption from multiple unmapping
 	 * of the same page since we are using page->lru.
 	 */
@@ -756,7 +756,6 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(start & ~HPAGE_MASK);
 	BUG_ON(end & ~HPAGE_MASK);
 
-	/* i_mmap_lock held */
 	emm_notify(mm, emm_invalidate_start, start, end);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += HPAGE_SIZE) {
@@ -797,9 +796,9 @@ void unmap_hugepage_range(struct vm_area
 	 * do nothing in this case.
 	 */
 	if (vma->vm_file) {
-		spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+		down_write(&vma->vm_file->f_mapping->i_mmap_sem);
 		__unmap_hugepage_range(vma, start, end);
-		spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+		up_write(&vma->vm_file->f_mapping->i_mmap_sem);
 	}
 }
 
@@ -1042,7 +1041,7 @@ void hugetlb_change_protection(struct vm
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+	down_read(&vma->vm_file->f_mapping->i_mmap_sem);
 	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -1057,7 +1056,7 @@ void hugetlb_change_protection(struct vm
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
-	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+	up_read(&vma->vm_file->f_mapping->i_mmap_sem);
 
 	flush_tlb_range(vma, start, end);
 }
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-03-03 22:59:25.502849006 -0800
+++ linux-2.6/mm/memory.c	2008-03-03 22:59:31.206878010 -0800
@@ -830,7 +830,6 @@ unsigned long unmap_vmas(struct mmu_gath
 	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
 	int tlb_start_valid = 0;
 	unsigned long start = start_addr;
-	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	int fullmm = (*tlbp)->fullmm;
 
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
@@ -868,21 +867,11 @@ unsigned long unmap_vmas(struct mmu_gath
 
 			tlb_finish_mmu(*tlbp, tlb_start, start);
 
-			if (need_resched() ||
-				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
-				if (i_mmap_lock) {
-					*tlbp = NULL;
-					goto out;
-				}
-				cond_resched();
-			}
-
 			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
 			tlb_start_valid = 0;
 			zap_work = ZAP_BLOCK_SIZE;
 		}
 	}
-out:
 	return start;	/* which is now the end (or restart) address */
 }
 
@@ -905,7 +894,6 @@ unsigned long zap_page_range(struct vm_a
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
 
-	/* i_mmap_lock may be held */
 	emm_notify(mm, emm_invalidate_start, address, end);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
 	emm_notify(mm, emm_invalidate_end, address, end);
@@ -1749,7 +1737,7 @@ unwritable_page:
 /*
  * Helper functions for unmap_mapping_range().
  *
- * __ Notes on dropping i_mmap_lock to reduce latency while unmapping __
+ * __ Notes on dropping i_mmap_sem to reduce latency while unmapping __
  *
  * We have to restart searching the prio_tree whenever we drop the lock,
  * since the iterator is only valid while the lock is held, and anyway
@@ -1768,7 +1756,7 @@ unwritable_page:
  * can't efficiently keep all vmas in step with mapping->truncate_count:
  * so instead reset them all whenever it wraps back to 0 (then go to 1).
  * mapping->truncate_count and vma->vm_truncate_count are protected by
- * i_mmap_lock.
+ * i_mmap_sem.
  *
  * In order to make forward progress despite repeatedly restarting some
  * large vma, note the restart_addr from unmap_vmas when it breaks out:
@@ -1818,7 +1806,7 @@ again:
 
 	restart_addr = zap_page_range(vma, start_addr,
 					end_addr - start_addr, details);
-	need_break = need_resched() || spin_needbreak(details->i_mmap_lock);
+	need_break = need_resched();
 
 	if (restart_addr >= end_addr) {
 		/* We have now completed this vma: mark it so */
@@ -1832,9 +1820,9 @@ again:
 			goto again;
 	}
 
-	spin_unlock(details->i_mmap_lock);
+	up_write(details->i_mmap_sem);
 	cond_resched();
-	spin_lock(details->i_mmap_lock);
+	down_write(details->i_mmap_sem);
 	return -EINTR;
 }
 
@@ -1928,9 +1916,9 @@ void unmap_mapping_range(struct address_
 	details.last_index = hba + hlen - 1;
 	if (details.last_index < details.first_index)
 		details.last_index = ULONG_MAX;
-	details.i_mmap_lock = &mapping->i_mmap_lock;
+	details.i_mmap_sem = &mapping->i_mmap_sem;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_write(&mapping->i_mmap_sem);
 
 	/* Protect against endless unmapping loops */
 	mapping->truncate_count++;
@@ -1945,7 +1933,7 @@ void unmap_mapping_range(struct address_
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
-	spin_unlock(&mapping->i_mmap_lock);
+	up_write(&mapping->i_mmap_sem);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2008-03-03 22:59:25.510849324 -0800
+++ linux-2.6/mm/migrate.c	2008-03-03 22:59:31.206878010 -0800
@@ -202,12 +202,12 @@ static void remove_file_migration_ptes(s
 	if (!mapping)
 		return;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)
 		remove_migration_pte(vma, old, new);
 
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 }
 
 /*
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-03-03 22:59:25.522848812 -0800
+++ linux-2.6/mm/mmap.c	2008-03-03 22:59:31.210878368 -0800
@@ -186,7 +186,7 @@ error:
 }
 
 /*
- * Requires inode->i_mapping->i_mmap_lock
+ * Requires inode->i_mapping->i_mmap_sem
  */
 static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		struct file *file, struct address_space *mapping)
@@ -214,9 +214,9 @@ void unlink_file_vma(struct vm_area_stru
 
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		__remove_shared_vm_struct(vma, file, mapping);
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 	}
 }
 
@@ -439,7 +439,7 @@ static void vma_link(struct mm_struct *m
 		mapping = vma->vm_file->f_mapping;
 
 	if (mapping) {
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		vma->vm_truncate_count = mapping->truncate_count;
 	}
 	anon_vma_lock(vma);
@@ -449,7 +449,7 @@ static void vma_link(struct mm_struct *m
 
 	anon_vma_unlock(vma);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 
 	mm->map_count++;
 	validate_mm(mm);
@@ -536,7 +536,7 @@ again:			remove_next = 1 + (end > next->
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR))
 			root = &mapping->i_mmap;
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		if (importer &&
 		    vma->vm_truncate_count != next->vm_truncate_count) {
 			/*
@@ -620,7 +620,7 @@ again:			remove_next = 1 + (end > next->
 	if (anon_vma)
 		spin_unlock(&anon_vma->lock);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 
 	if (remove_next) {
 		if (file)
@@ -2064,7 +2064,7 @@ void exit_mmap(struct mm_struct *mm)
 
 /* Insert vm structure into process list sorted by address
  * and into the inode's i_mmap tree.  If vm_file is non-NULL
- * then i_mmap_lock is taken here.
+ * then i_mmap_sem is taken here.
  */
 int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 {
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c	2008-03-03 22:59:25.530848880 -0800
+++ linux-2.6/mm/mremap.c	2008-03-03 22:59:31.210878368 -0800
@@ -86,7 +86,7 @@ static void move_ptes(struct vm_area_str
 		 * and we propagate stale pages into the dst afterward.
 		 */
 		mapping = vma->vm_file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		if (new_vma->vm_truncate_count &&
 		    new_vma->vm_truncate_count != vma->vm_truncate_count)
 			new_vma->vm_truncate_count = 0;
@@ -119,7 +119,7 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_nested(new_pte - 1);
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 	emm_notify(mm, emm_invalidate_end, old_start, old_end);
 }
 
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2008-03-03 22:59:25.542848702 -0800
+++ linux-2.6/mm/rmap.c	2008-03-03 22:59:31.210878368 -0800
@@ -24,7 +24,7 @@
  *   inode->i_alloc_sem (vmtruncate_range)
  *   mm->mmap_sem
  *     page->flags PG_locked (lock_page)
- *       mapping->i_mmap_lock
+ *       mapping->i_mmap_sem
  *         anon_vma->lock
  *           mm->page_table_lock or pte_lock
  *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
@@ -368,14 +368,14 @@ static int page_referenced_file(struct p
 	 * The page lock not only makes sure that page->mapping cannot
 	 * suddenly be NULLified by truncation, it makes sure that the
 	 * structure at mapping cannot be freed and reused yet,
-	 * so we can safely take mapping->i_mmap_lock.
+	 * so we can safely take mapping->i_mmap_sem.
 	 */
 	BUG_ON(!PageLocked(page));
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 
 	/*
-	 * i_mmap_lock does not stabilize mapcount at all, but mapcount
+	 * i_mmap_sem does not stabilize mapcount at all, but mapcount
 	 * is more likely to be accurate if we note it after spinning.
 	 */
 	mapcount = page_mapcount(page);
@@ -398,7 +398,7 @@ static int page_referenced_file(struct p
 			break;
 	}
 
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 	return referenced;
 }
 
@@ -482,12 +482,12 @@ static int page_mkclean_file(struct addr
 
 	BUG_ON(PageAnon(page));
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED)
 			ret += page_mkclean_one(page, vma);
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 	return ret;
 }
 
@@ -923,7 +923,7 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
@@ -960,7 +960,6 @@ static int try_to_unmap_file(struct page
 	mapcount = page_mapcount(page);
 	if (!mapcount)
 		goto out;
-	cond_resched_lock(&mapping->i_mmap_lock);
 
 	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
 	if (max_nl_cursor == 0)
@@ -982,7 +981,6 @@ static int try_to_unmap_file(struct page
 			}
 			vma->vm_private_data = (void *) max_nl_cursor;
 		}
-		cond_resched_lock(&mapping->i_mmap_lock);
 		max_nl_cursor += CLUSTER_SIZE;
 	} while (max_nl_cursor <= max_nl_size);
 
@@ -994,7 +992,7 @@ static int try_to_unmap_file(struct page
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_private_data = NULL;
 out:
-	spin_unlock(&mapping->i_mmap_lock);
+	up_write(&mapping->i_mmap_sem);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
