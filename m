Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 07 of 11] i_mmap_rwsem
Message-Id: <58f716ad4d067afb6bdd.1210170957@duo.random>
In-Reply-To: <patchbomb.1210170950@duo.random>
Date: Wed, 07 May 2008 16:35:57 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1210115135 -7200
# Node ID 58f716ad4d067afb6bdd1b5f7042e19d854aae0d
# Parent  0621238970155f8ff2d60ca4996dcdd470f9c6ce
i_mmap_rwsem

The conversion to a rwsem allows notifier callbacks during rmap traversal
for files. A rw style lock also allows concurrent walking of the
reverse map so that multiple processors can expire pages in the same memory
area of the same process. So it increases the potential concurrency.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

diff --git a/Documentation/vm/locking b/Documentation/vm/locking
--- a/Documentation/vm/locking
+++ b/Documentation/vm/locking
@@ -66,7 +66,7 @@ expand_stack(), it is hard to come up wi
 expand_stack(), it is hard to come up with a destructive scenario without 
 having the vmlist protection in this case.
 
-The page_table_lock nests with the inode i_mmap_lock and the kmem cache
+The page_table_lock nests with the inode i_mmap_sem and the kmem cache
 c_spinlock spinlocks.  This is okay, since the kmem code asks for pages after
 dropping c_spinlock.  The page_table_lock also nests with pagecache_lock and
 pagemap_lru_lock spinlocks, and no code asks for memory with these locks
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
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
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
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
diff --git a/fs/inode.c b/fs/inode.c
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -210,7 +210,7 @@ void inode_init_once(struct inode *inode
 	INIT_LIST_HEAD(&inode->i_devices);
 	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
 	rwlock_init(&inode->i_data.tree_lock);
-	spin_lock_init(&inode->i_data.i_mmap_lock);
+	init_rwsem(&inode->i_data.i_mmap_sem);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
 	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
diff --git a/include/linux/fs.h b/include/linux/fs.h
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -502,7 +502,7 @@ struct address_space {
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
-	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
+	struct rw_semaphore	i_mmap_sem;	/* protect tree, count, list */
 	unsigned int		truncate_count;	/* Cover race condition with truncate */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -735,7 +735,7 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
-	spinlock_t *i_mmap_lock;		/* For unmap_mapping_range: */
+	struct rw_semaphore *i_mmap_sem;	/* For unmap_mapping_range: */
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
 };
 
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -297,12 +297,12 @@ static int dup_mmap(struct mm_struct *mm
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
diff --git a/mm/filemap.c b/mm/filemap.c
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -61,16 +61,16 @@ generic_file_direct_IO(int rw, struct ki
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
@@ -87,7 +87,7 @@ generic_file_direct_IO(int rw, struct ki
  *    ->sb_lock			(fs/fs-writeback.c)
  *    ->mapping->tree_lock	(__sync_single_inode)
  *
- *  ->i_mmap_lock
+ *  ->i_mmap_sem
  *    ->anon_vma.lock		(vma_adjust)
  *
  *  ->anon_vma.lock
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -178,7 +178,7 @@ __xip_unmap (struct address_space * mapp
 	if (!page)
 		return;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;
 		address = vma->vm_start +
@@ -198,7 +198,7 @@ __xip_unmap (struct address_space * mapp
 			page_cache_release(page);
 		}
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 }
 
 /*
diff --git a/mm/fremap.c b/mm/fremap.c
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -206,13 +206,13 @@ asmlinkage long sys_remap_file_pages(uns
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
 
 	mmu_notifier_invalidate_range_start(mm, start, start + size);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -814,7 +814,7 @@ void __unmap_hugepage_range(struct vm_ar
 	struct page *page;
 	struct page *tmp;
 	/*
-	 * A page gathering list, protected by per file i_mmap_lock. The
+	 * A page gathering list, protected by per file i_mmap_sem. The
 	 * lock is used to avoid list corruption from multiple unmapping
 	 * of the same page since we are using page->lru.
 	 */
@@ -864,9 +864,9 @@ void unmap_hugepage_range(struct vm_area
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
 
@@ -1111,7 +1111,7 @@ void hugetlb_change_protection(struct vm
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+	down_write(&vma->vm_file->f_mapping->i_mmap_sem);
 	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -1126,7 +1126,7 @@ void hugetlb_change_protection(struct vm
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
-	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+	up_write(&vma->vm_file->f_mapping->i_mmap_sem);
 
 	flush_tlb_range(vma, start, end);
 }
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -874,7 +874,7 @@ unsigned long unmap_vmas(struct vm_area_
 	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
 	int tlb_start_valid = 0;
 	unsigned long start = start_addr;
-	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
+	struct rw_semaphore *i_mmap_sem = details? details->i_mmap_sem: NULL;
 	int fullmm;
 	struct mmu_gather *tlb;
 	struct mm_struct *mm = vma->vm_mm;
@@ -920,8 +920,8 @@ unsigned long unmap_vmas(struct vm_area_
 			tlb_finish_mmu(tlb, tlb_start, start);
 
 			if (need_resched() ||
-				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
-				if (i_mmap_lock) {
+				(i_mmap_sem && rwsem_needbreak(i_mmap_sem))) {
+				if (i_mmap_sem) {
 					tlb = NULL;
 					goto out;
 				}
@@ -1829,7 +1829,7 @@ unwritable_page:
 /*
  * Helper functions for unmap_mapping_range().
  *
- * __ Notes on dropping i_mmap_lock to reduce latency while unmapping __
+ * __ Notes on dropping i_mmap_sem to reduce latency while unmapping __
  *
  * We have to restart searching the prio_tree whenever we drop the lock,
  * since the iterator is only valid while the lock is held, and anyway
@@ -1848,7 +1848,7 @@ unwritable_page:
  * can't efficiently keep all vmas in step with mapping->truncate_count:
  * so instead reset them all whenever it wraps back to 0 (then go to 1).
  * mapping->truncate_count and vma->vm_truncate_count are protected by
- * i_mmap_lock.
+ * i_mmap_sem.
  *
  * In order to make forward progress despite repeatedly restarting some
  * large vma, note the restart_addr from unmap_vmas when it breaks out:
@@ -1898,7 +1898,7 @@ again:
 
 	restart_addr = zap_page_range(vma, start_addr,
 					end_addr - start_addr, details);
-	need_break = need_resched() || spin_needbreak(details->i_mmap_lock);
+	need_break = need_resched() || rwsem_needbreak(details->i_mmap_sem);
 
 	if (restart_addr >= end_addr) {
 		/* We have now completed this vma: mark it so */
@@ -1912,9 +1912,9 @@ again:
 			goto again;
 	}
 
-	spin_unlock(details->i_mmap_lock);
+	up_write(details->i_mmap_sem);
 	cond_resched();
-	spin_lock(details->i_mmap_lock);
+	down_write(details->i_mmap_sem);
 	return -EINTR;
 }
 
@@ -2008,9 +2008,9 @@ void unmap_mapping_range(struct address_
 	details.last_index = hba + hlen - 1;
 	if (details.last_index < details.first_index)
 		details.last_index = ULONG_MAX;
-	details.i_mmap_lock = &mapping->i_mmap_lock;
+	details.i_mmap_sem = &mapping->i_mmap_sem;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_write(&mapping->i_mmap_sem);
 
 	/* Protect against endless unmapping loops */
 	mapping->truncate_count++;
@@ -2025,7 +2025,7 @@ void unmap_mapping_range(struct address_
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
-	spin_unlock(&mapping->i_mmap_lock);
+	up_write(&mapping->i_mmap_sem);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
diff --git a/mm/migrate.c b/mm/migrate.c
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -211,12 +211,12 @@ static void remove_file_migration_ptes(s
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
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -189,7 +189,7 @@ error:
 }
 
 /*
- * Requires inode->i_mapping->i_mmap_lock
+ * Requires inode->i_mapping->i_mmap_sem
  */
 static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		struct file *file, struct address_space *mapping)
@@ -217,9 +217,9 @@ void unlink_file_vma(struct vm_area_stru
 
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		__remove_shared_vm_struct(vma, file, mapping);
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 	}
 }
 
@@ -445,7 +445,7 @@ static void vma_link(struct mm_struct *m
 		mapping = vma->vm_file->f_mapping;
 
 	if (mapping) {
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		vma->vm_truncate_count = mapping->truncate_count;
 	}
 	anon_vma_lock(vma);
@@ -455,7 +455,7 @@ static void vma_link(struct mm_struct *m
 
 	anon_vma_unlock(vma);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 
 	mm->map_count++;
 	validate_mm(mm);
@@ -542,7 +542,7 @@ again:			remove_next = 1 + (end > next->
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR))
 			root = &mapping->i_mmap;
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		if (importer &&
 		    vma->vm_truncate_count != next->vm_truncate_count) {
 			/*
@@ -626,7 +626,7 @@ again:			remove_next = 1 + (end > next->
 	if (anon_vma)
 		spin_unlock(&anon_vma->lock);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 
 	if (remove_next) {
 		if (file) {
@@ -2068,7 +2068,7 @@ void exit_mmap(struct mm_struct *mm)
 
 /* Insert vm structure into process list sorted by address
  * and into the inode's i_mmap tree.  If vm_file is non-NULL
- * then i_mmap_lock is taken here.
+ * then i_mmap_sem is taken here.
  */
 int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 {
diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -88,7 +88,7 @@ static void move_ptes(struct vm_area_str
 		 * and we propagate stale pages into the dst afterward.
 		 */
 		mapping = vma->vm_file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		down_write(&mapping->i_mmap_sem);
 		if (new_vma->vm_truncate_count &&
 		    new_vma->vm_truncate_count != vma->vm_truncate_count)
 			new_vma->vm_truncate_count = 0;
@@ -120,7 +120,7 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_nested(new_pte - 1);
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		up_write(&mapping->i_mmap_sem);
 	mmu_notifier_invalidate_range_end(vma->vm_mm, old_start, old_end);
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -24,7 +24,7 @@
  *   inode->i_alloc_sem (vmtruncate_range)
  *   mm->mmap_sem
  *     page->flags PG_locked (lock_page)
- *       mapping->i_mmap_lock
+ *       mapping->i_mmap_sem
  *         anon_vma->lock
  *           mm->page_table_lock or pte_lock
  *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
@@ -373,14 +373,14 @@ static int page_referenced_file(struct p
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
@@ -403,7 +403,7 @@ static int page_referenced_file(struct p
 			break;
 	}
 
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 	return referenced;
 }
 
@@ -490,12 +490,12 @@ static int page_mkclean_file(struct addr
 
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
 
@@ -930,7 +930,7 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
 
-	spin_lock(&mapping->i_mmap_lock);
+	down_read(&mapping->i_mmap_sem);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
@@ -967,7 +967,6 @@ static int try_to_unmap_file(struct page
 	mapcount = page_mapcount(page);
 	if (!mapcount)
 		goto out;
-	cond_resched_lock(&mapping->i_mmap_lock);
 
 	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
 	if (max_nl_cursor == 0)
@@ -989,7 +988,6 @@ static int try_to_unmap_file(struct page
 			}
 			vma->vm_private_data = (void *) max_nl_cursor;
 		}
-		cond_resched_lock(&mapping->i_mmap_lock);
 		max_nl_cursor += CLUSTER_SIZE;
 	} while (max_nl_cursor <= max_nl_size);
 
@@ -1001,7 +999,7 @@ static int try_to_unmap_file(struct page
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_private_data = NULL;
 out:
-	spin_unlock(&mapping->i_mmap_lock);
+	up_read(&mapping->i_mmap_sem);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
