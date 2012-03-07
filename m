Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 21DBA6B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 10:08:46 -0500 (EST)
Date: Wed, 7 Mar 2012 16:08:40 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH V3] mm: convert rcu_read_lock() to srcu_read_lock(), thus
 allowing to sleep in callbacks
Message-ID: <20120307150840.GR13462@redhat.com>
References: <1328709344-6058-1-git-send-email-sagig@mellanox.co.il>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Ls2Gy6y7jbHLe9Od"
Content-Disposition: inline
In-Reply-To: <1328709344-6058-1-git-send-email-sagig@mellanox.co.il>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sagi Grimberg <sagig@mellanox.com>
Cc: linux-mm@kvack.org, ogrelitz@mellanox.com, Andi Kleen <andi@firstfloor.org>


--Ls2Gy6y7jbHLe9Od
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello Sagi,

On Wed, Feb 08, 2012 at 03:55:43PM +0200, Sagi Grimberg wrote:
> Now that anon_vma lock and i_mmap_mutex are both sleepable mutex, it is possible to schedule inside invalidation callbacks
> (such as invalidate_page, invalidate_range_start/end and change_pte) .
> This is essential for a scheduling HW sync in RDMA drivers which apply on demand paging methods.

Even after this, you still can't schedule in
invalidate_page/change_pte/clear_flush_young yet because the PT lock
is still hold there and that's a spinlock.

You can only schedule in invalidate_range_start/end. It's definitely a
change in the right direction but a few more patches are needed to
make all methods schedule capable.

Originally it started with srcu but then not even
invalidate_range_start/end could schedule because of the i_mmap_lock,
so then we changed to not sleepable rcu in the upstream final version
merged to keep it optimal.

Originally I developed a version of mmu notifier that was capable of
scheduling everywhere to proof the point it was possible, but it was
deferred because of the cost of using mutex instead of spinlocks for
anon-vma and i_mmap_lock (measured by Andi as a double digit percent
snowdown in some workloads in latest upstream, but hey it's upstream
already and unconditional change, so we should at least take advantage
of it in mmu notifier now! total agreement. At least we get the full
advantage of it in terms of easier coding of mmu notifier users).

I archived the missing patches that were deferred back then just
waiting for this moment, so now I'm attaching the ones that are still
missing and that are needed in addition to the srcu change you did to
get full scheduling capability from all mmu notifier methods. They're
unlikely to apply but you can revisit these now that only the PT lock
is a problem left and we should check the free_pgtable shenanigans
too.

The new test_young method used by khugepaged to know if it's worth
collapsing an hugepage (in case it was only accessed by the secondary
MMU), probably is ok to stay non-sleep capable as it's readonly thing
and doesn't need to invalidate but in that case proper docs should be
added on which methods are sleepable and which are not.

Thanks,
Andrea

--Ls2Gy6y7jbHLe9Od
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=outside-pt-lock

Subject: invalidate_page outside PT lock

From: Andrea Arcangeli <andrea@qumranet.com>

Moves all mmu notifier methods outside the PT lock (first and not last
step to make them sleep capable).

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
---

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -193,35 +193,6 @@ static inline void mmu_notifier_mm_destr
 		__mmu_notifier_mm_destroy(mm);
 }
 
-/*
- * These two macros will sometime replace ptep_clear_flush.
- * ptep_clear_flush is impleemnted as macro itself, so this also is
- * implemented as a macro until ptep_clear_flush will converted to an
- * inline function, to diminish the risk of compilation failure. The
- * invalidate_page method over time can be moved outside the PT lock
- * and these two macros can be later removed.
- */
-#define ptep_clear_flush_notify(__vma, __address, __ptep)		\
-({									\
-	pte_t __pte;							\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	__pte = ptep_clear_flush(___vma, ___address, __ptep);		\
-	mmu_notifier_invalidate_page(___vma->vm_mm, ___address);	\
-	__pte;								\
-})
-
-#define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
-({									\
-	int __young;							\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	__young = ptep_clear_flush_young(___vma, ___address, __ptep);	\
-	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
-						  ___address);		\
-	__young;							\
-})
-
 #else /* CONFIG_MMU_NOTIFIER */
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
@@ -257,9 +228,6 @@ static inline void mmu_notifier_mm_destr
 {
 }
 
-#define ptep_clear_flush_young_notify ptep_clear_flush_young
-#define ptep_clear_flush_notify ptep_clear_flush
-
 #endif /* CONFIG_MMU_NOTIFIER */
 
 #endif /* _LINUX_MMU_NOTIFIER_H */
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -194,11 +194,13 @@ __xip_unmap (struct address_space * mapp
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
-			pteval = ptep_clear_flush_notify(vma, address, pte);
+			pteval = ptep_clear_flush(vma, address, pte);
 			page_remove_rmap(page, vma);
 			dec_mm_counter(mm, file_rss);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
+			/* must invalidate_page _before_ freeing the page */
+			mmu_notifier_invalidate_page(mm, address);
 			page_cache_release(page);
 		}
 	}
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1636,9 +1636,10 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			page_cache_release(old_page);
+			new_page = NULL;
 			if (!pte_same(*page_table, orig_pte))
 				goto unlock;
+			page_cache_release(old_page);
 
 			page_mkwrite = 1;
 		}
@@ -1654,6 +1655,7 @@ static int do_wp_page(struct mm_struct *
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
 		ret |= VM_FAULT_WRITE;
+		old_page = new_page = NULL;
 		goto unlock;
 	}
 
@@ -1698,7 +1700,7 @@ gotten:
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush_notify(vma, address, page_table);
+		ptep_clear_flush(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		lru_cache_add_active(new_page);
@@ -1710,12 +1712,18 @@ gotten:
 	} else
 		mem_cgroup_uncharge_page(new_page);
 
-	if (new_page)
+unlock:
+	pte_unmap_unlock(page_table, ptl);
+
+	if (new_page) {
+		if (new_page == old_page)
+			/* cow happened, notify before releasing old_page */
+			mmu_notifier_invalidate_page(mm, address);
 		page_cache_release(new_page);
+	}
 	if (old_page)
 		page_cache_release(old_page);
-unlock:
-	pte_unmap_unlock(page_table, ptl);
+
 	if (dirty_page) {
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -275,7 +275,7 @@ static int page_referenced_one(struct pa
 	unsigned long address;
 	pte_t *pte;
 	spinlock_t *ptl;
-	int referenced = 0;
+	int referenced = 0, clear_flush_young = 0;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
@@ -288,8 +288,11 @@ static int page_referenced_one(struct pa
 	if (vma->vm_flags & VM_LOCKED) {
 		referenced++;
 		*mapcount = 1;	/* break early from loop */
-	} else if (ptep_clear_flush_young_notify(vma, address, pte))
-		referenced++;
+	} else {
+		clear_flush_young = 1;
+		if (ptep_clear_flush_young(vma, address, pte))
+			referenced++;
+	}
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
@@ -299,6 +302,10 @@ static int page_referenced_one(struct pa
 
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
+
+	if (clear_flush_young)
+		referenced += mmu_notifier_clear_flush_young(mm, address);
+
 out:
 	return referenced;
 }
@@ -458,7 +465,7 @@ static int page_mkclean_one(struct page 
 		pte_t entry;
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		entry = ptep_clear_flush_notify(vma, address, pte);
+		entry = ptep_clear_flush(vma, address, pte);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -466,6 +473,10 @@ static int page_mkclean_one(struct page 
 	}
 
 	pte_unmap_unlock(pte, ptl);
+
+	if (ret)
+		mmu_notifier_invalidate_page(mm, address);
+
 out:
 	return ret;
 }
@@ -718,15 +729,14 @@ static int try_to_unmap_one(struct page 
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young_notify(vma, address, pte)))) {
+	if (!migration && (vma->vm_flags & VM_LOCKED)) {
 		ret = SWAP_FAIL;
 		goto out_unmap;
 	}
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush_notify(vma, address, pte);
+	pteval = ptep_clear_flush(vma, address, pte);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
@@ -781,6 +791,8 @@ static int try_to_unmap_one(struct page 
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+	if (ret != SWAP_FAIL)
+		mmu_notifier_invalidate_page(mm, address);
 out:
 	return ret;
 }
@@ -819,7 +831,7 @@ static void try_to_unmap_cluster(unsigne
 	spinlock_t *ptl;
 	struct page *page;
 	unsigned long address;
-	unsigned long end;
+	unsigned long start, end;
 
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
 	end = address + CLUSTER_SIZE;
@@ -840,6 +852,8 @@ static void try_to_unmap_cluster(unsigne
 	if (!pmd_present(*pmd))
 		return;
 
+	start = address;
+	mmu_notifier_invalidate_range_start(mm, start, end);
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 
 	/* Update high watermark before we lower rss */
@@ -851,12 +865,12 @@ static void try_to_unmap_cluster(unsigne
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
 
-		if (ptep_clear_flush_young_notify(vma, address, pte))
+		if (ptep_clear_flush_young(vma, address, pte))
 			continue;
 
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		pteval = ptep_clear_flush_notify(vma, address, pte);
+		pteval = ptep_clear_flush(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))
@@ -872,6 +886,7 @@ static void try_to_unmap_cluster(unsigne
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 }
 
 static int try_to_unmap_anon(struct page *page, int migration)

--Ls2Gy6y7jbHLe9Od
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=free_pgtables

Subject: free-pgtables

From: Christoph Lameter <clameter@sgi.com>

Move the tlb flushing into free_pgtables. The conversion of the locks
taken for reverse map scanning would require taking sleeping locks
in free_pgtables() and we cannot sleep while gathering pages for a tlb
flush.

Move the tlb_gather/tlb_finish call to free_pgtables() to be done
for each vma. This may add a number of tlb flushes depending on the
number of vmas that cannot be coalesced into one.

The first pointer argument to free_pgtables() can then be dropped.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
---

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -773,8 +773,8 @@ int walk_page_range(unsigned long addr, 
 		struct mm_walk *walk);
 void free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *start_vma,
-		unsigned long floor, unsigned long ceiling);
+void free_pgtables(struct vm_area_struct *start_vma, unsigned long floor,
+						unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -272,9 +272,11 @@ void free_pgd_range(struct mmu_gather **
 	} while (pgd++, addr = next, addr != end);
 }
 
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
-		unsigned long floor, unsigned long ceiling)
+void free_pgtables(struct vm_area_struct *vma, unsigned long floor,
+							unsigned long ceiling)
 {
+	struct mmu_gather *tlb;
+
 	while (vma) {
 		struct vm_area_struct *next = vma->vm_next;
 		unsigned long addr = vma->vm_start;
@@ -286,7 +288,8 @@ void free_pgtables(struct mmu_gather **t
 		unlink_file_vma(vma);
 
 		if (is_vm_hugetlb_page(vma)) {
-			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
+			tlb = tlb_gather_mmu(vma->vm_mm, 0);
+			hugetlb_free_pgd_range(&tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
 		} else {
 			/*
@@ -299,9 +302,11 @@ void free_pgtables(struct mmu_gather **t
 				anon_vma_unlink(vma);
 				unlink_file_vma(vma);
 			}
-			free_pgd_range(tlb, addr, vma->vm_end,
+			tlb = tlb_gather_mmu(vma->vm_mm, 0);
+			free_pgd_range(&tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
 		}
+		tlb_finish_mmu(tlb, addr, vma->vm_end);
 		vma = next;
 	}
 }
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1763,9 +1763,9 @@ static void unmap_region(struct mm_struc
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
+	tlb_finish_mmu(tlb, start, end);
+	free_pgtables(vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
-	tlb_finish_mmu(tlb, start, end);
 }
 
 /*
@@ -2064,8 +2064,8 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
+	free_pgtables(vma, FIRST_USER_ADDRESS, 0);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,

--Ls2Gy6y7jbHLe9Od
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=unmap_vmas

Subject: unmap vmas tlb flushing

From: Christoph Lameter <clameter@sgi.com>

Move the tlb flushing inside of unmap vmas. This saves us from passing
a pointer to the TLB structure around and simplifies the callers.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
---

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -744,8 +744,7 @@ struct page *vm_normal_page(struct vm_ar
 
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-unsigned long unmap_vmas(struct mmu_gather **tlb,
-		struct vm_area_struct *start_vma, unsigned long start_addr,
+unsigned long unmap_vmas(struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
 
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -849,7 +849,6 @@ static unsigned long unmap_page_range(st
 
 /**
  * unmap_vmas - unmap a range of memory covered by a list of vma's
- * @tlbp: address of the caller's struct mmu_gather
  * @vma: the starting vma
  * @start_addr: virtual address at which to start unmapping
  * @end_addr: virtual address at which to end unmapping
@@ -861,20 +860,13 @@ static unsigned long unmap_page_range(st
  * Unmap all pages in the vma list.
  *
  * We aim to not hold locks for too long (for scheduling latency reasons).
- * So zap pages in ZAP_BLOCK_SIZE bytecounts.  This means we need to
- * return the ending mmu_gather to the caller.
+ * So zap pages in ZAP_BLOCK_SIZE bytecounts.
  *
  * Only addresses between `start' and `end' will be unmapped.
  *
  * The VMA list must be sorted in ascending virtual address order.
- *
- * unmap_vmas() assumes that the caller will flush the whole unmapped address
- * range after unmap_vmas() returns.  So the only responsibility here is to
- * ensure that any thus-far unmapped pages are flushed before unmap_vmas()
- * drops the lock and schedules.
  */
-unsigned long unmap_vmas(struct mmu_gather **tlbp,
-		struct vm_area_struct *vma, unsigned long start_addr,
+unsigned long unmap_vmas(struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
 {
@@ -883,9 +875,14 @@ unsigned long unmap_vmas(struct mmu_gath
 	int tlb_start_valid = 0;
 	unsigned long start = start_addr;
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
-	int fullmm = (*tlbp)->fullmm;
+	int fullmm;
+	struct mmu_gather *tlb;
 	struct mm_struct *mm = vma->vm_mm;
 
+	lru_add_drain();
+	tlb = tlb_gather_mmu(mm, 0);
+	update_hiwater_rss(mm);
+	fullmm = tlb->fullmm;
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
@@ -912,7 +909,7 @@ unsigned long unmap_vmas(struct mmu_gath
 						(HPAGE_SIZE / PAGE_SIZE);
 				start = end;
 			} else
-				start = unmap_page_range(*tlbp, vma,
+				start = unmap_page_range(tlb, vma,
 						start, end, &zap_work, details);
 
 			if (zap_work > 0) {
@@ -920,22 +917,23 @@ unsigned long unmap_vmas(struct mmu_gath
 				break;
 			}
 
-			tlb_finish_mmu(*tlbp, tlb_start, start);
+			tlb_finish_mmu(tlb, tlb_start, start);
 
 			if (need_resched() ||
 				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
 				if (i_mmap_lock) {
-					*tlbp = NULL;
+					tlb = NULL;
 					goto out;
 				}
 				cond_resched();
 			}
 
-			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
+			tlb = tlb_gather_mmu(vma->vm_mm, fullmm);
 			tlb_start_valid = 0;
 			zap_work = ZAP_BLOCK_SIZE;
 		}
 	}
+	tlb_finish_mmu(tlb, start_addr, end_addr);
 out:
 	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
 	return start;	/* which is now the end (or restart) address */
@@ -951,18 +949,10 @@ unsigned long zap_page_range(struct vm_a
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *details)
 {
-	struct mm_struct *mm = vma->vm_mm;
-	struct mmu_gather *tlb;
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
 
-	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
-	update_hiwater_rss(mm);
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	if (tlb)
-		tlb_finish_mmu(tlb, address, end);
-	return end;
+	return unmap_vmas(vma, address, end, &nr_accounted, details);
 }
 
 /*
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1751,15 +1751,10 @@ static void unmap_region(struct mm_struc
 		unsigned long start, unsigned long end)
 {
 	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
-	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
-	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
-	update_hiwater_rss(mm);
-	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
+	unmap_vmas(vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	tlb_finish_mmu(tlb, start, end);
 	free_pgtables(vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 }
@@ -2044,7 +2039,6 @@ EXPORT_SYMBOL(do_brk);
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct *mm)
 {
-	struct mmu_gather *tlb;
 	struct vm_area_struct *vma = mm->mmap;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
@@ -2055,12 +2049,11 @@ void exit_mmap(struct mm_struct *mm)
 
 	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb = tlb_gather_mmu(mm, 1);
+
 	/* Don't update_hiwater_rss(mm) here, do_exit already did */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+	end = unmap_vmas(vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	tlb_finish_mmu(tlb, 0, end);
 	free_pgtables(vma, FIRST_USER_ADDRESS, 0);
 
 	/*

--Ls2Gy6y7jbHLe9Od--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
