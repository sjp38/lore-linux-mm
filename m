From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199907160024.RAA11667@google.engr.sgi.com>
Subject: [RFC] [PATCH]kanoj-mm15-2.3.10 Fix ia32 SMP/clone pte races
Date: Thu, 15 Jul 1999 17:24:27 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com, Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

This note describes clone/SMP race problems specifically on processors 
like the ia32 that have the "accessed" and "dirty" bits updated by the 
processor while the kernel is reading/modifying the pte, assuming it is 
completely frozen. The problem of "accessed" bit races is probably minor, 
since the worst that happens with this ignorance is that kswapd might 
sometimes decide to steal the wrong page. On the other hand, letting the 
"dirty" bit updates be racy leads kswapd (and possibly other code) to 
unwittingly clear the bit, leading to possible loss of data (eg, when 
kswapd decides to steal a page but not write it out, or when sync() 
misses syncing a page, etc).

In the presence of clones, a few paths need to be fixed, not just for 
ia32, but for all processors. Linux platform independent code sometimes 
lets clones update page data when really, such updates should be 
disallowed. 
1. During munmap, clones should be restricted while the file pages are
being written out to disk, else some writes are not synced to disk at
unmap time.
2. Looking at how often the code does tlb/cache flushes in the sync()
path, this path can be heavily optimized by clumping all the flushes.

On ia32 SMP, clones might lead to "dirty" bit getting updated when the 
kernel does not expect it. These paths are in:
3. fork in copy_page_range.
4. mremap
5. mprotect
6. try_to_swap_out is racy, if the page stealer is stealing for a different
process, or the stealer is a clone, since the "dirty" bit could be getting
changed as the code looks at it.

Most of the other code that invokes set_pte or pte_clear are safe because
they are either setting the dirty bit unconditioanlly, or have made sure
there are no access/updates via the ptes.

For the sake of simplicity, a single macro, pte_freeze_mm_range is used
for 1, 2, 3, 4 and 5  to prevent any clone from updating the data pages or
changing the pte "dirty"/"accessed" bit. This also optimizes on the amount 
of tlb flushes needed. While I have coded an ia32 SMP pte_freeze_mm_range,
it will probably benefit all platforms to implement this macro to fix
problems 1 and 2. For 6, the pte_freeze macro is used, which is nop
for all processors except the ia32. Note that the ia32 pte_freeze_mm_range
makes sure that no clone can update/access the pte, or pull the translation
into its tlb until the kernel has made the pte consistant (since callers 
of pte_freeze_mm_range hold the mmap_sem). Due to the optimized
implementation which twiddles bits in the PDE instead of the PTE, it
is required that a matching pte_unfreeze_mm_range always be made.

The patch also fixes other minor bugs in vmscan.c and mremap.c.

Note that an alternate solution to the ia32 SMP pte race is to change 
PAGE_SHARED in include/asm-i386/pgtable.h to not drop in _PAGE_RW. On a 
write fault, mark the pte dirty, as well as drop in the _PAGE_RW bit into 
the pte. Basically, behave as if the processor does not have a hardware 
dirty bit, and adopt the same strategy as in the alpha/mips code. 
Disadvantage - take an extra fault on shm/file mmap'ed pages when a 
program accesses the page, *then* dirties it (no change if the first 
access is a write).

Kanoj

--- /usr/tmp/p_rdiff_a001U7/smp.c	Wed Jul 14 22:32:00 1999
+++ arch/i386/kernel/smp.c	Wed Jul 14 21:24:37 1999
@@ -2157,3 +2157,45 @@
 
 #undef APIC_DIVISOR
 
+#define PMD_TABLE_MASK ((PTRS_PER_PMD-1) * sizeof(pmd_t))
+
+void pte_range(struct mm_struct *mm, unsigned long start, unsigned long end,
+						int op)
+{
+	pgd_t * dir = pgd_offset(mm, start) - 1;
+
+	for(;;) {
+		pmd_t *pmd;
+
+		dir++;
+		if ((pgd_none(*dir)) || (pgd_bad(*dir))) {
+			start = (start + PGDIR_SIZE) & PGDIR_MASK;
+			if (start >= end)
+				return;
+			continue;
+		}
+
+		pmd = pmd_offset(dir, start);
+		do {
+			if ((pmd_none(*pmd)) || (pmd_bad(*pmd))) {
+				start = (start + PMD_SIZE) & PMD_MASK;
+				if (start >= end)
+					return;
+				pmd++;
+				continue;
+			}
+
+			switch(op) {
+				case 1:
+					pmd_mkabsent(pmd);
+					break;
+				case 0:
+					pmd_mkpresent(pmd);
+					break;
+			}
+			start = (start + PMD_SIZE) & PMD_MASK;
+			if (start >= end)
+				return;
+		} while ((unsigned long)pmd & PMD_TABLE_MASK);
+	}
+}
--- /usr/tmp/p_rdiff_a001SW/pgtable.h	Wed Jul 14 22:32:08 1999
+++ include/asm-alpha/pgtable.h	Wed Jul 14 16:37:51 1999
@@ -636,6 +636,11 @@
 #define module_map	vmalloc
 #define module_unmap	vfree
 
+#define pte_freeze_mm_range(mm, s, e)  0
+#define pte_unfreeze_mm_range(mm, s, e)
+#define pte_freeze_dirty(vma, page_table, pte, wr)
+#define pte_unfreeze_dirty(page_table, wr)
+
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
 #define PageSkip(page)		(0)
 #define kern_addr_valid(addr)	(1)
--- /usr/tmp/p_rdiff_a001Sq/pgtable.h	Wed Jul 14 22:32:14 1999
+++ include/asm-arm/pgtable.h	Wed Jul 14 16:39:13 1999
@@ -7,6 +7,11 @@
 #define module_map	vmalloc
 #define module_unmap	vfree
 
+#define pte_freeze_mm_range(mm, s, e)  0
+#define pte_unfreeze_mm_range(mm, s, e)
+#define pte_freeze_dirty(vma, page_table, pte, wr)
+#define pte_unfreeze_dirty(page_table, wr)
+
 extern int do_check_pgt_cache(int, int);
 
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
--- /usr/tmp/p_rdiff_a001Tf/pgtable.h	Wed Jul 14 22:32:22 1999
+++ include/asm-i386/pgtable.h	Wed Jul 14 18:31:05 1999
@@ -316,9 +316,17 @@
 #define pte_clear(xp)	do { pte_val(*(xp)) = 0; } while (0)
 
 #define pmd_none(x)	(!pmd_val(x))
-#define	pmd_bad(x)	((pmd_val(x) & (~PAGE_MASK & ~_PAGE_USER)) != _KERNPG_TABLE)
+#define	pmd_bad(x)	((pmd_val(x) & (~PAGE_MASK & ~(_PAGE_USER | _PAGE_PRESENT))) != (_KERNPG_TABLE & ~_PAGE_PRESENT))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
 #define pmd_clear(xp)	do { pmd_val(*(xp)) = 0; } while (0)
+#define pmd_mkabsent(pmd) do { \
+				pmd_val(*(pmd)) = \
+					(pmd_val(*(pmd)) & (~_PAGE_PRESENT));\
+			  } while (0)
+#define pmd_mkpresent(pmd) do { \
+				pmd_val(*(pmd)) = \
+					(pmd_val(*(pmd)) | _PAGE_PRESENT); \
+			   } while(0)
 
 /*
  * The "pgd_xxx()" functions here are trivial for a folded two-level
@@ -589,6 +597,50 @@
 
 #define module_map      vmalloc
 #define module_unmap    vfree
+
+
+#ifndef __SMP__
+
+#define pte_freeze_mm_range(mm, s, e)  0
+#define pte_unfreeze_mm_range(mm, s, e)
+#define pte_freeze_dirty(vma, page_table, pte, wr)
+#define pte_unfreeze_dirty(page_table, wr)
+
+#else /* !__SMP__ */
+
+extern void pte_range(struct mm_struct *, unsigned long, unsigned long, int);
+
+#define pte_freeze_mm_range(mm, s, e) \
+		({ \
+			int ret = 1; \
+			if (atomic_read(&(mm)->count) != 1) \
+				pte_range((mm), (s), (e), 1); \
+			flush_tlb_range((mm), (s), (e)); \
+			ret; \
+		})
+	
+#define pte_unfreeze_mm_range(mm, s, e) \
+		do { \
+			if (atomic_read(&(mm)->count) != 1) \
+				pte_range((mm), (s), (e), 0); \
+		} while(0)
+#define pte_freeze_dirty(vma, page_table, pte, wr) \
+		do { \
+			if ((pte_write(*(page_table))) && \
+			    ((current->mm != (vma)->vm_mm) || \
+			    (atomic_read(&(vma)->vm_mm->count) != 1))) { \
+				(wr) = 1; \
+				clear_bit(1, (unsigned long *)(page_table)); \
+				smp_flush_tlb(); \
+				(pte) = *(page_table); \
+			} \
+		} while(0)
+#define pte_unfreeze_dirty(page_table, wr) \
+		do { \
+			if (wr) pte_val(*(page_table)) |= _PAGE_RW; \
+		} while(0)
+
+#endif /* !__SMP__ */
 
 #endif /* !__ASSEMBLY__ */
 
--- /usr/tmp/p_rdiff_a001Tp/pgtable.h	Wed Jul 14 22:32:30 1999
+++ include/asm-m68k/pgtable.h	Wed Jul 14 16:39:23 1999
@@ -824,6 +824,11 @@
 #define module_map      vmalloc
 #define module_unmap    vfree
 
+#define pte_freeze_mm_range(mm, s, e)  0
+#define pte_unfreeze_mm_range(mm, s, e)
+#define pte_freeze_dirty(vma, page_table, pte, wr)
+#define pte_unfreeze_dirty(page_table, wr)
+
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
 #define PageSkip(page)		(0)
 #define kern_addr_valid(addr)	(1)
--- /usr/tmp/p_rdiff_a001Uf/pgtable.h	Wed Jul 14 22:32:38 1999
+++ include/asm-mips/pgtable.h	Wed Jul 14 16:39:37 1999
@@ -587,6 +587,11 @@
 #define module_map      vmalloc
 #define module_unmap    vfree
 
+#define pte_freeze_mm_range(mm, s, e)  0
+#define pte_unfreeze_mm_range(mm, s, e)
+#define pte_freeze_dirty(vma, page_table, pte, wr)
+#define pte_unfreeze_dirty(page_table, wr)
+
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
 #define PageSkip(page)		(0)
 #define kern_addr_valid(addr)	(1)
--- /usr/tmp/p_rdiff_a001U8/pgtable.h	Wed Jul 14 22:32:46 1999
+++ include/asm-ppc/pgtable.h	Wed Jul 14 16:39:46 1999
@@ -615,6 +615,11 @@
 #define module_map      vmalloc
 #define module_unmap    vfree
 
+#define pte_freeze_mm_range(mm, s, e)  0
+#define pte_unfreeze_mm_range(mm, s, e)
+#define pte_freeze_dirty(vma, page_table, pte, wr)
+#define pte_unfreeze_dirty(page_table, wr)
+
 /* CONFIG_APUS */
 /* For virtual address to physical address conversion */
 extern void cache_clear(__u32 addr, int length);
--- /usr/tmp/p_rdiff_a001UB/pgtable.h	Wed Jul 14 22:32:54 1999
+++ include/asm-sparc/pgtable.h	Wed Jul 14 16:39:56 1999
@@ -576,6 +576,11 @@
 #define module_unmap    vfree
 extern unsigned long *sparc_valid_addr_bitmap;
 
+#define pte_freeze_mm_range(mm, s, e)  0
+#define pte_unfreeze_mm_range(mm, s, e)
+#define pte_freeze_dirty(vma, page_table, pte, wr)
+#define pte_unfreeze_dirty(page_table, wr)
+
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
 #define PageSkip(page)		(test_bit(PG_skip, &(page)->flags))
 #define kern_addr_valid(addr)	(test_bit(__pa((unsigned long)(addr))>>20, sparc_valid_addr_bitmap))
--- /usr/tmp/p_rdiff_a001V6/pgtable.h	Wed Jul 14 22:33:02 1999
+++ include/asm-sparc64/pgtable.h	Wed Jul 14 16:40:07 1999
@@ -648,6 +648,11 @@
 extern void module_unmap (void *addr);
 extern unsigned long *sparc64_valid_addr_bitmap;
 
+#define pte_freeze_mm_range(mm, s, e)  0
+#define pte_unfreeze_mm_range(mm, s, e)
+#define pte_freeze_dirty(vma, page_table, pte, wr)
+#define pte_unfreeze_dirty(page_table, wr)
+
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
 #define PageSkip(page)		(test_bit(PG_skip, &(page)->flags))
 #define kern_addr_valid(addr)	(test_bit(__pa((unsigned long)(addr))>>22, sparc64_valid_addr_bitmap))
--- /usr/tmp/p_rdiff_a001VU/fork.c	Wed Jul 14 22:33:11 1999
+++ kernel/fork.c	Wed Jul 14 21:03:46 1999
@@ -231,9 +231,10 @@
 static inline int dup_mmap(struct mm_struct * mm)
 {
 	struct vm_area_struct * mpnt, *tmp, **pprev;
-	int retval;
+	int retval, ret;
 
 	flush_cache_mm(current->mm);
+	ret = pte_freeze_mm_range(mm, 0, TASK_SIZE);
 	pprev = &mm->mmap;
 	for (mpnt = current->mm->mmap ; mpnt ; mpnt = mpnt->vm_next) {
 		struct file *file;
@@ -284,7 +285,9 @@
 		build_mmap_avl(mm);
 
 fail_nomem:
-	flush_tlb_mm(current->mm);
+	if (ret == 0)
+		flush_tlb_mm(current->mm);
+	pte_unfreeze_mm_range(mm, 0, TASK_SIZE);
 	return retval;
 }
 
--- /usr/tmp/p_rdiff_a001VB/filemap.c	Wed Jul 14 22:33:22 1999
+++ mm/filemap.c	Wed Jul 14 18:08:37 1999
@@ -1604,13 +1604,11 @@
 	int error = 0;
 
 	dir = pgd_offset(vma->vm_mm, address);
-	flush_cache_range(vma->vm_mm, end - size, end);
 	while (address < end) {
 		error |= filemap_sync_pmd_range(dir, address, end - address, vma, flags);
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	}
-	flush_tlb_range(vma->vm_mm, end - size, end);
 	return error;
 }
 
@@ -1688,7 +1686,10 @@
 	unsigned long start, unsigned long end, int flags)
 {
 	if (vma->vm_file && vma->vm_ops && vma->vm_ops->sync) {
-		int error;
+		int error, ret;
+
+		flush_cache_range(vma->vm_mm, start, end);
+		ret = pte_freeze_mm_range(vma->vm_mm, start, end);
 		error = vma->vm_ops->sync(vma, start, end-start, flags);
 		if (!error && (flags & MS_SYNC)) {
 			struct file * file = vma->vm_file;
@@ -1697,6 +1698,9 @@
 				error = file_fsync(file, dentry);
 			}
 		}
+		if (ret == 0)
+			flush_tlb_range(vma->vm_mm, start, end);
+		pte_unfreeze_mm_range(vma->vm_mm, start, end);
 		return error;
 	}
 	return 0;
--- /usr/tmp/p_rdiff_a001Uj/mmap.c	Wed Jul 14 22:33:30 1999
+++ mm/mmap.c	Wed Jul 14 21:21:23 1999
@@ -671,6 +671,7 @@
 	 */
 	while ((mpnt = free) != NULL) {
 		unsigned long st, end, size;
+		int ret;
 
 		free = free->vm_next;
 
@@ -679,6 +680,8 @@
 		end = end > mpnt->vm_end ? mpnt->vm_end : end;
 		size = end - st;
 
+		flush_cache_range(mm, st, end);
+		ret = pte_freeze_mm_range(mm, st, end);
 		lock_kernel();
 		if (mpnt->vm_ops && mpnt->vm_ops->unmap)
 			mpnt->vm_ops->unmap(mpnt, st, size);
@@ -687,9 +690,10 @@
 		remove_shared_vm_struct(mpnt);
 		mm->map_count--;
 
-		flush_cache_range(mm, st, end);
 		zap_page_range(mm, st, size);
-		flush_tlb_range(mm, st, end);
+		if (ret == 0)
+			flush_tlb_range(mm, st, end);
+		pte_unfreeze_mm_range(mm, st, end);
 
 		/*
 		 * Fix the mapping, and free the old area if it wasn't reused.
--- /usr/tmp/p_rdiff_a001T3/mprotect.c	Wed Jul 14 22:33:37 1999
+++ mm/mprotect.c	Wed Jul 14 18:02:45 1999
@@ -67,15 +67,19 @@
 {
 	pgd_t *dir;
 	unsigned long beg = start;
+	int ret;
 
 	dir = pgd_offset(current->mm, start);
 	flush_cache_range(current->mm, beg, end);
+	ret = pte_freeze_mm_range(current->mm, beg, end);
 	while (start < end) {
 		change_pmd_range(dir, start, end - start, newprot);
 		start = (start + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	}
-	flush_tlb_range(current->mm, beg, end);
+	if (ret == 0)
+		flush_tlb_range(current->mm, beg, end);
+	pte_unfreeze_mm_range(current->mm, beg, end);
 	return;
 }
 
--- /usr/tmp/p_rdiff_a001W8/mremap.c	Wed Jul 14 22:33:44 1999
+++ mm/mremap.c	Wed Jul 14 18:26:01 1999
@@ -91,9 +91,10 @@
 	unsigned long new_addr, unsigned long old_addr, unsigned long len)
 {
 	unsigned long offset = len;
+	int ret;
 
 	flush_cache_range(mm, old_addr, old_addr + len);
-	flush_tlb_range(mm, old_addr, old_addr + len);
+	ret = pte_freeze_mm_range(mm, old_addr, old_addr + len);
 
 	/*
 	 * This is not the clever way to do this, but we're taking the
@@ -105,6 +106,9 @@
 		if (move_one_page(mm, old_addr + offset, new_addr + offset))
 			goto oops_we_failed;
 	}
+	if (ret == 0)
+		flush_tlb_range(mm, old_addr, old_addr + len);
+	pte_unfreeze_mm_range(mm, old_addr, old_addr + len);
 	return 0;
 
 	/*
@@ -115,10 +119,10 @@
 	 * the old page tables)
 	 */
 oops_we_failed:
+	pte_unfreeze_mm_range(mm, old_addr, old_addr + len);
 	flush_cache_range(mm, new_addr, new_addr + len);
 	while ((offset += PAGE_SIZE) < len)
 		move_one_page(mm, new_addr + offset, old_addr + offset);
-	zap_page_range(mm, new_addr, new_addr + len);
 	flush_tlb_range(mm, new_addr, new_addr + len);
 	return -1;
 }
--- /usr/tmp/p_rdiff_a001TW/vmscan.c	Wed Jul 14 22:33:51 1999
+++ mm/vmscan.c	Wed Jul 14 16:02:44 1999
@@ -38,6 +38,7 @@
 	unsigned long entry;
 	unsigned long page_addr;
 	struct page * page;
+	int writable;
 
 	pte = *page_table;
 	if (!pte_present(pte))
@@ -49,8 +50,9 @@
 	page = mem_map + MAP_NR(page_addr);
 	spin_lock(&tsk->mm->page_table_lock);
 	if (pte_val(pte) != pte_val(*page_table))
-		goto out_failed_unlock;
+		goto out_failed_unlock_nofreeze;
 
+	pte_freeze_dirty(vma, page_table, pte, writable);
 	/*
 	 * Dont be too eager to get aging right if
 	 * memory is dangerously low.
@@ -155,7 +157,7 @@
 	 */
 	entry = get_swap_page();
 	if (!entry)
-		goto out_failed; /* No swap space left */
+		goto out_failed_unlock; /* No swap space left */
 		
 	vma->vm_mm->rss--;
 	tsk->nswap++;
@@ -175,6 +177,8 @@
 	__free_page(page);
 	return 1;
 out_failed_unlock:
+	pte_unfreeze_dirty(page_table, writable);
+out_failed_unlock_nofreeze:
 	spin_unlock(&tsk->mm->page_table_lock);
 out_failed:
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
