Received: from localhost (localhost [127.0.0.1])
	by baldur.austin.ibm.com (8.12.6/8.12.6/Debian-6) with ESMTP id g99L7b7C019756
	for <linux-mm@kvack.org>; Wed, 9 Oct 2002 16:07:37 -0500
Date: Wed, 09 Oct 2002 16:07:37 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH 2.5.41-mm1] new snapshot of shared page tables
Message-ID: <228900000.1034197657@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1075830887=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========1075830887==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Here's the latest shared page table patch.  Changes are mostly cleanups,
with the added feature that shared page tables are now a config option.
This means the patch should build on other architectures (this is untested).

At Andrew Morton's request, I've moved my development base to the -mm line.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1075830887==========
Content-Type: text/plain; charset=iso-8859-1; name="shpte-2.5.41-mm1-2.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="shpte-2.5.41-mm1-2.diff";
 size=37571

--- 2.5.41-mm1/./include/linux/mm.h	2002-10-09 11:02:57.000000000 -0500
+++ 2.5.41-mm1-shpte/./include/linux/mm.h	2002-10-09 13:53:27.000000000 =
-0500
@@ -163,6 +163,8 @@
 		struct pte_chain *chain;/* Reverse pte mapping pointer.
 					 * protected by PG_chainlock */
 		pte_addr_t direct;
+		struct mm_chain *mmchain;/* Reverse mm_struct mapping pointer */
+		struct mm_struct *mmdirect;
 	} pte;
 	unsigned long private;		/* mapping-private opaque data */
=20
@@ -358,6 +360,7 @@
=20
 extern void zap_page_range(struct vm_area_struct *vma, unsigned long =
address, unsigned long size);
 extern int copy_page_range(struct mm_struct *dst, struct mm_struct *src, =
struct vm_area_struct *vma);
+extern int share_page_range(struct mm_struct *dst, struct mm_struct *src, =
struct vm_area_struct *vma, pmd_t **prev_pmd);
 extern int remap_page_range(struct vm_area_struct *vma, unsigned long =
from, unsigned long to, unsigned long size, pgprot_t prot);
 extern int zeromap_page_range(struct vm_area_struct *vma, unsigned long =
from, unsigned long size, pgprot_t prot);
=20
--- 2.5.41-mm1/./include/linux/rmap-locking.h	2002-10-07 13:23:25.000000000 =
-0500
+++ 2.5.41-mm1-shpte/./include/linux/rmap-locking.h	2002-10-09 =
10:25:52.000000000 -0500
@@ -31,3 +31,6 @@
 #endif
 	preempt_enable();
 }
+
+#define	pte_page_lock	pte_chain_lock
+#define	pte_page_unlock	pte_chain_unlock
--- 2.5.41-mm1/./include/asm-generic/rmap.h	2002-10-07 13:24:40.000000000 =
-0500
+++ 2.5.41-mm1-shpte/./include/asm-generic/rmap.h	2002-10-09 =
10:25:52.000000000 -0500
@@ -26,33 +26,6 @@
  */
 #include <linux/mm.h>
=20
-static inline void pgtable_add_rmap(struct page * page, struct mm_struct * =
mm, unsigned long address)
-{
-#ifdef BROKEN_PPC_PTE_ALLOC_ONE
-	/* OK, so PPC calls pte_alloc() before mem_map[] is setup ... ;( */
-	extern int mem_init_done;
-
-	if (!mem_init_done)
-		return;
-#endif
-	page->mapping =3D (void *)mm;
-	page->index =3D address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
-	inc_page_state(nr_page_table_pages);
-}
-
-static inline void pgtable_remove_rmap(struct page * page)
-{
-	page->mapping =3D NULL;
-	page->index =3D 0;
-	dec_page_state(nr_page_table_pages);
-}
-
-static inline struct mm_struct * ptep_to_mm(pte_t * ptep)
-{
-	struct page * page =3D kmap_atomic_to_page(ptep);
-	return (struct mm_struct *) page->mapping;
-}
-
 static inline unsigned long ptep_to_address(pte_t * ptep)
 {
 	struct page * page =3D kmap_atomic_to_page(ptep);
@@ -87,4 +60,10 @@
 }
 #endif
=20
+extern void pgtable_add_rmap(struct page * page, struct mm_struct * mm, =
unsigned long address);
+extern void pgtable_add_rmap_locked(struct page * page, struct mm_struct * =
mm, unsigned long address);
+extern void pgtable_remove_rmap(struct page * page, struct mm_struct *mm);
+extern void pgtable_remove_rmap_locked(struct page * page, struct =
mm_struct *mm);
+extern void increment_rss(struct page *ptepage);
+
 #endif /* _GENERIC_RMAP_H */
--- 2.5.41-mm1/./include/asm-i386/pgtable.h	2002-10-07 13:24:48.000000000 =
-0500
+++ 2.5.41-mm1-shpte/./include/asm-i386/pgtable.h	2002-10-09 =
10:25:52.000000000 -0500
@@ -124,6 +124,7 @@
 #define _PAGE_PROTNONE	0x080	/* If not present */
=20
 #define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER | =
_PAGE_ACCESSED | _PAGE_DIRTY)
+#define _PAGE_TABLE_RDONLY	(_PAGE_PRESENT | _PAGE_USER | _PAGE_ACCESSED | =
_PAGE_DIRTY)
 #define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED | =
_PAGE_DIRTY)
 #define _PAGE_CHG_MASK	(PTE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY)
=20
@@ -184,8 +185,8 @@
 #define pmd_none(x)	(!pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
 #define pmd_clear(xp)	do { set_pmd(xp, __pmd(0)); } while (0)
-#define	pmd_bad(x)	((pmd_val(x) & (~PAGE_MASK & ~_PAGE_USER)) !=3D =
_KERNPG_TABLE)
-
+#define	pmd_bad(x)	((pmd_val(x) & (~PAGE_MASK & ~_PAGE_USER & ~_PAGE_RW)) =
!=3D \
+			(_KERNPG_TABLE & ~_PAGE_RW))
=20
 #define pages_to_mb(x) ((x) >> (20-PAGE_SHIFT))
=20
@@ -209,6 +210,8 @@
 static inline pte_t pte_mkdirty(pte_t pte)	{ (pte).pte_low |=3D =
_PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte_low |=3D =
_PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte_low |=3D _PAGE_RW; =
return pte; }
+static inline int pmd_write(pmd_t pmd)		{ return (pmd).pmd & _PAGE_RW; }
+static inline pmd_t pmd_wrprotect(pmd_t pmd)	{ (pmd).pmd &=3D ~_PAGE_RW; =
return pmd; }
=20
 static inline  int ptep_test_and_clear_dirty(pte_t *ptep)	{ return =
test_and_clear_bit(_PAGE_BIT_DIRTY, &ptep->pte_low); }
 static inline  int ptep_test_and_clear_young(pte_t *ptep)	{ return =
test_and_clear_bit(_PAGE_BIT_ACCESSED, &ptep->pte_low); }
@@ -263,6 +266,10 @@
 	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE0) + __pte_offset(address))
 #define pte_offset_map_nested(dir, address) \
 	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE1) + __pte_offset(address))
+#define pte_page_map(__page, address) \
+	((pte_t *)kmap_atomic(__page,KM_PTE0) + __pte_offset(address))
+#define pte_page_map_nested(__page, address) \
+	((pte_t *)kmap_atomic(__page,KM_PTE1) + __pte_offset(address))
 #define pte_unmap(pte) kunmap_atomic(pte, KM_PTE0)
 #define pte_unmap_nested(pte) kunmap_atomic(pte, KM_PTE1)
=20
--- 2.5.41-mm1/./arch/i386/Config.help	2002-10-07 13:23:25.000000000 -0500
+++ 2.5.41-mm1-shpte/./arch/i386/Config.help	2002-10-09 15:49:31.000000000 =
-0500
@@ -143,6 +143,13 @@
   low memory.  Setting this option will put user-space page table
   entries in high memory.
=20
+CONFIG_SHAREPTE
+  Normally each address space has its own complete page table for all
+  its mappings.  This can mean many mappings of a set of shared data
+  pages.  With this option, the VM will attempt to share the bottom
+  level of the page table between address spaces that are sharing data
+  pages.
+
 CONFIG_HIGHMEM4G
   Select this if you have a 32-bit processor and between 1 and 4
   gigabytes of physical RAM.
--- 2.5.41-mm1/./arch/i386/config.in	2002-10-07 13:24:02.000000000 -0500
+++ 2.5.41-mm1-shpte/./arch/i386/config.in	2002-10-09 15:57:18.000000000 =
-0500
@@ -232,6 +232,7 @@
 if [ "$CONFIG_HIGHMEM4G" =3D "y" -o "$CONFIG_HIGHMEM64G" =3D "y" ]; then
    bool 'Allocate 3rd-level pagetables from highmem' CONFIG_HIGHPTE
 fi
+bool 'Share 3rd-level pagetables' CONFIG_SHAREPTE y
=20
 bool 'Math emulation' CONFIG_MATH_EMULATION
 bool 'MTRR (Memory Type Range Register) support' CONFIG_MTRR
--- 2.5.41-mm1/./fs/exec.c	2002-10-09 11:02:54.000000000 -0500
+++ 2.5.41-mm1-shpte/./fs/exec.c	2002-10-09 10:30:54.000000000 -0500
@@ -46,6 +46,7 @@
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
 #include <asm/mmu_context.h>
+#include <asm/rmap.h>
=20
 #ifdef CONFIG_KMOD
 #include <linux/kmod.h>
@@ -308,8 +309,8 @@
 	flush_page_to_ram(page);
 	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(page, PAGE_COPY))));
 	page_add_rmap(page, pte);
+	increment_rss(kmap_atomic_to_page(pte));
 	pte_unmap(pte);
-	tsk->mm->rss++;
 	spin_unlock(&tsk->mm->page_table_lock);
=20
 	/* no need for flush_tlb */
--- 2.5.41-mm1/./kernel/fork.c	2002-10-09 11:02:58.000000000 -0500
+++ 2.5.41-mm1-shpte/./kernel/fork.c	2002-10-09 15:19:16.000000000 -0500
@@ -208,6 +208,9 @@
 	struct vm_area_struct * mpnt, *tmp, **pprev;
 	int retval;
 	unsigned long charge =3D 0;
+#ifdef CONFIG_SHAREPTE
+	pmd_t *prev_pmd =3D 0;
+#endif
=20
 	flush_cache_mm(current->mm);
 	mm->locked_vm =3D 0;
@@ -270,7 +273,11 @@
 		*pprev =3D tmp;
 		pprev =3D &tmp->vm_next;
 		mm->map_count++;
+#ifdef CONFIG_SHAREPTE
+		retval =3D share_page_range(mm, current->mm, tmp, &prev_pmd);
+#else
 		retval =3D copy_page_range(mm, current->mm, tmp);
+#endif
 		spin_unlock(&mm->page_table_lock);
=20
 		if (tmp->vm_ops && tmp->vm_ops->open)
--- 2.5.41-mm1/./mm/mmap.c	2002-10-09 11:02:58.000000000 -0500
+++ 2.5.41-mm1-shpte/./mm/mmap.c	2002-10-09 10:40:09.000000000 -0500
@@ -23,6 +23,7 @@
 #include <asm/tlb.h>
=20
 extern void unmap_page_range(mmu_gather_t *,struct vm_area_struct *vma, =
unsigned long address, unsigned long size);
+extern void unmap_all_pages(mmu_gather_t *tlb, struct mm_struct *mm, =
unsigned long address, unsigned long end);
 extern void clear_page_tables(mmu_gather_t *tlb, unsigned long first, int =
nr);
=20
 /*
@@ -1248,11 +1249,22 @@
 	}
 }
=20
+/*
+ * For small tasks, it's most efficient to unmap the pages for each
+ * vma.  For larger tasks, it's better to just walk the entire address
+ * space in one pass, particularly with shared pte pages.  This
+ * threshold determines the size where we switch from one method to
+ * the other.
+ */
+
+#define	UNMAP_THRESHOLD		500
+
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct * mm)
 {
 	mmu_gather_t *tlb;
 	struct vm_area_struct * mpnt;
+	int unmap_vma =3D mm->total_vm < UNMAP_THRESHOLD;
=20
 	release_segments(mm);
 	spin_lock(&mm->page_table_lock);
@@ -1273,10 +1285,10 @@
 			vm_unacct_memory((end - start) >> PAGE_SHIFT);
=20
 		mm->map_count--;
-		if (!(is_vm_hugetlb_page(mpnt)))
-			unmap_page_range(tlb, mpnt, start, end);
-		else
+		if (is_vm_hugetlb_page(mpnt))
 			mpnt->vm_ops->close(mpnt);
+		else if (unmap_vma)
+			unmap_page_range(tlb, mpnt, start, end);
 		mpnt =3D mpnt->vm_next;
 	}
=20
@@ -1284,6 +1296,9 @@
 	if (mm->map_count)
 		BUG();
=20
+	if (!unmap_vma)
+		unmap_all_pages(tlb, mm, 0, TASK_SIZE);
+
 	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
 	tlb_finish_mmu(tlb, 0, TASK_SIZE);
=20
--- 2.5.41-mm1/./mm/swapfile.c	2002-10-07 13:23:34.000000000 -0500
+++ 2.5.41-mm1-shpte/./mm/swapfile.c	2002-10-09 10:35:30.000000000 -0500
@@ -17,6 +17,7 @@
 #include <linux/buffer_head.h>
=20
 #include <asm/pgtable.h>
+#include <asm/rmap.h>
 #include <linux/swapops.h>
=20
 spinlock_t swaplock =3D SPIN_LOCK_UNLOCKED;
@@ -371,7 +372,7 @@
  */
 /* mmlist_lock and vma->vm_mm->page_table_lock are held */
 static inline void unuse_pte(struct vm_area_struct * vma, unsigned long =
address,
-	pte_t *dir, swp_entry_t entry, struct page* page)
+	pte_t *dir, swp_entry_t entry, struct page* page, pmd_t *pmd)
 {
 	pte_t pte =3D *dir;
=20
@@ -383,7 +384,7 @@
 	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	page_add_rmap(page, dir);
 	swap_free(entry);
-	++vma->vm_mm->rss;
+	increment_rss(pmd_page(*pmd));
 }
=20
 /* mmlist_lock and vma->vm_mm->page_table_lock are held */
@@ -408,7 +409,7 @@
 	if (end > PMD_SIZE)
 		end =3D PMD_SIZE;
 	do {
-		unuse_pte(vma, offset+address-vma->vm_start, pte, entry, page);
+		unuse_pte(vma, offset+address-vma->vm_start, pte, entry, page, dir);
 		address +=3D PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
--- 2.5.41-mm1/./mm/memory.c	2002-10-09 11:02:58.000000000 -0500
+++ 2.5.41-mm1-shpte/./mm/memory.c	2002-10-09 15:25:18.000000000 -0500
@@ -36,6 +36,18 @@
  *		(Gerhard.Wichert@pdb.siemens.de)
  */
=20
+/*
+ * A note on locking of the page table structure:
+ *
+ *  The top level lock that protects the page table is the =
mm->page_table_lock.
+ *  This lock protects the pgd and pmd layer.  However, with the advent of =
shared
+ *  pte pages, this lock is not sufficient.  The pte layer is now =
protected by the
+ *  pte_page_lock, set in the struct page of the pte page.  Note that with =
this
+ *  locking scheme, once the pgd and pmd layers have been set in the page =
fault
+ *  path and the pte_page_lock has been taken, the page_table_lock can be =
released.
+ *=20
+ */
+
 #include <linux/kernel_stat.h>
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
@@ -45,6 +57,7 @@
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/vcache.h>
+#include <linux/rmap-locking.h>
=20
 #include <asm/pgalloc.h>
 #include <asm/rmap.h>
@@ -84,7 +97,7 @@
  */
 static inline void free_one_pmd(mmu_gather_t *tlb, pmd_t * dir)
 {
-	struct page *page;
+	struct page *ptepage;
=20
 	if (pmd_none(*dir))
 		return;
@@ -93,10 +106,13 @@
 		pmd_clear(dir);
 		return;
 	}
-	page =3D pmd_page(*dir);
+	ptepage =3D pmd_page(*dir);
 	pmd_clear(dir);
-	pgtable_remove_rmap(page);
-	pte_free_tlb(tlb, page);
+	pgtable_remove_rmap(ptepage, tlb->mm);
+	if (page_count(ptepage) =3D=3D 1) {
+		dec_page_state(nr_page_table_pages);
+	}
+	pte_free_tlb(tlb, ptepage);
 }
=20
 static inline void free_one_pgd(mmu_gather_t *tlb, pgd_t * dir)
@@ -137,6 +153,216 @@
 	} while (--nr);
 }
=20
+/*
+ * This function makes the decision whether a pte page needs to be =
unshared
+ * or not.  Note that page_count() =3D=3D 1 isn't even tested here.  The =
assumption
+ * is that if the pmd entry is marked writeable, then the page is either =
already
+ * unshared or doesn't need to be unshared.  This catches the situation =
where
+ * task B unshares the pte page, then task A faults and needs to unprotect =
the
+ * pmd entry.  This is actually done in pte_unshare.
+ *
+ * This function should be called with the page_table_lock held.
+ */
+static inline int pte_needs_unshare(struct mm_struct *mm, struct =
vm_area_struct *vma,
+				    pmd_t *pmd, unsigned long address, int write_access)
+{
+#ifdef CONFIG_SHAREPTE
+	struct page *ptepage;
+
+	/* It's not even there, nothing to unshare. */
+	if (!pmd_present(*pmd))
+		return 0;
+
+	/*
+	 * If it's already writable, then it doesn't need to be unshared.
+	 * It's either already not shared or it's part of a large shared
+	 * region that will never need to be unshared.
+	 */
+	if (pmd_write(*pmd))
+		return 0;
+
+	/* If this isn't a write fault we don't need to unshare. */
+	if (!write_access)
+		return 0;
+
+	/*
+	 * If this page fits entirely inside a shared region, don't unshare it.
+	 */
+	ptepage =3D pmd_page(*pmd);
+	if ((vma->vm_flags & VM_SHARED) &&
+	    (vma->vm_start <=3D ptepage->index) &&
+	    (vma->vm_end >=3D (ptepage->index + PMD_SIZE))) {
+		return 0;
+	}
+	/*
+	 * Ok, we have to unshare.
+	 */
+	return 1;
+#else
+	return 0;
+#endif
+}
+
+/*
+ * Here is where a pte page is actually unshared.  It actually covers a =
couple of
+ * possible conditions.  If the page_count() is already 1, then that means =
it just
+ * needs to be set writeable.  Otherwise, a new page needs to be =
allocated.
+ *
+ * When each pte entry is copied, it is evaluated for COW protection, as =
well as
+ * checking whether the swap count needs to be incremented.
+ *
+ * This function must be called with the page_table_lock held.  It
+ * will release and reacquire the lock when it allocates a new page.
+ *
+ * The function must also be called with the pte_page_lock held on the
+ * old page.  This lock will also be dropped, then reacquired when we
+ * allocate a new page.  The pte_page_lock will be taken on the new
+ * page.  Whichever pte page is returned will have its pte_page_lock
+ * held.
+ */
+
+static pte_t *pte_unshare(struct mm_struct *mm, pmd_t *pmd, unsigned long =
address)
+{
+#ifdef CONFIG_SHAREPTE
+	pte_t	*src_ptb, *dst_ptb;
+	struct page *oldpage, *newpage, *tmppage;
+	struct vm_area_struct *vma;
+	int	base, addr;
+	int	end, page_end;
+	int	src_unshare;
+
+	oldpage =3D pmd_page(*pmd);
+
+	/* If it's already unshared, we just need to set it writeable */
+	if (page_count(oldpage) =3D=3D 1) {
+is_unshared:
+		pmd_populate(mm, pmd, oldpage);
+		flush_tlb_mm(mm);
+		goto out_map;
+	}
+
+	pte_page_unlock(oldpage);
+	spin_unlock(&mm->page_table_lock);
+	newpage =3D pte_alloc_one(mm, address);
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!newpage))
+		return NULL;
+
+	pte_page_lock(oldpage);
+	/*
+	 * It's possible some other task using our mm_struct did an unshare
+	 * and we're now supposed to be using a different pte page.  If so,
+	 * switch to it.
+	 */
+	tmppage =3D pmd_page(*pmd);
+	if (oldpage !=3D tmppage) {
+		pte_page_lock(tmppage);
+		pte_page_unlock(oldpage);
+		oldpage =3D tmppage;
+	}
+	/* See if it got unshared while we dropped the lock */
+	if (page_count(oldpage) =3D=3D 1) {
+		pte_free(newpage);
+		goto is_unshared;
+	}
+
+	pte_page_lock(newpage);
+
+	base =3D addr =3D oldpage->index;
+	page_end =3D base + PMD_SIZE;
+	vma =3D find_vma(mm, base);
+	if (!vma || (page_end <=3D vma->vm_start))
+		BUG(); 		/* No valid pages in this pte page */
+
+	src_unshare =3D page_count(oldpage) =3D=3D 2;
+	dst_ptb =3D pte_page_map(newpage, base);
+	src_ptb =3D pte_page_map_nested(oldpage, base);
+
+	if (vma->vm_start > addr)
+		addr =3D vma->vm_start;
+
+	if (vma->vm_end < page_end)
+		end =3D vma->vm_end;
+	else
+		end =3D page_end;
+
+	do {
+		unsigned int cow =3D (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) =3D=3D =
VM_MAYWRITE;
+		pte_t *src_pte =3D src_ptb + __pte_offset(addr);
+		pte_t *dst_pte =3D dst_ptb + __pte_offset(addr);
+
+		do {
+			pte_t pte =3D *src_pte;
+			struct page *page;
+
+			if (pte_none(pte))
+				goto unshare_skip_set;
+
+			if (!pte_present(pte)) {
+				swap_duplicate(pte_to_swp_entry(pte));
+				set_pte(dst_pte, pte);
+				goto unshare_skip_set;
+			}
+			page =3D pte_page(pte);
+			if (!PageReserved(page)) {
+				/* COW mappings require write protecting both sides */
+				if (cow) {
+					pte =3D pte_wrprotect(pte);
+					if (src_unshare)
+						set_pte(src_pte, pte);
+				}
+				/* If it's a shared mapping,
+				 *  mark it clean in the new mapping
+				 */
+				if (vma->vm_flags & VM_SHARED)
+					pte =3D pte_mkclean(pte);
+				pte =3D pte_mkold(pte);
+				get_page(page);
+			}
+			set_pte(dst_pte, pte);
+			page_add_rmap(page, dst_pte);
+unshare_skip_set:
+			src_pte++;
+			dst_pte++;
+			addr +=3D PAGE_SIZE;
+		} while (addr < end);
+
+		if (addr >=3D page_end)
+			break;
+
+		vma =3D vma->vm_next;
+		if (!vma)
+			break;
+
+		if (page_end <=3D vma->vm_start)
+			break;
+
+		addr =3D vma->vm_start;
+		if (vma->vm_end < page_end)
+			end =3D vma->vm_end;
+		else
+			end =3D page_end;
+	} while (1);
+
+	pte_unmap_nested(src_ptb);
+
+	pgtable_remove_rmap_locked(oldpage, mm);
+	pgtable_add_rmap_locked(newpage, mm, base);
+	pmd_populate(mm, pmd, newpage);
+	inc_page_state(nr_page_table_pages);
+
+	flush_tlb_mm(mm);
+
+	put_page(oldpage);
+	pte_page_unlock(oldpage);
+
+	return dst_ptb + __pte_offset(address);
+
+out_map:
+#endif
+	return pte_offset_map(pmd, address);
+}
+
 pte_t * pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long =
address)
 {
 	if (!pmd_present(*pmd)) {
@@ -158,11 +384,10 @@
 		}
 		pgtable_add_rmap(new, mm, address);
 		pmd_populate(mm, pmd, new);
+		inc_page_state(nr_page_table_pages);
 	}
 out:
-	if (pmd_present(*pmd))
-		return pte_offset_map(pmd, address);
-	return NULL;
+	return pte_offset_map(pmd, address);
 }
=20
 pte_t * pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, unsigned long =
address)
@@ -184,7 +409,6 @@
 			pte_free_kernel(new);
 			goto out;
 		}
-		pgtable_add_rmap(virt_to_page(new), mm, address);
 		pmd_populate_kernel(mm, pmd, new);
 	}
 out:
@@ -193,6 +417,98 @@
 #define PTE_TABLE_MASK	((PTRS_PER_PTE-1) * sizeof(pte_t))
 #define PMD_TABLE_MASK	((PTRS_PER_PMD-1) * sizeof(pmd_t))
=20
+int share_page_range(struct mm_struct *dst, struct mm_struct *src,
+	struct vm_area_struct *vma, pmd_t **prev_pmd)
+{
+#ifdef CONFIG_SHAREPTE
+	pgd_t *src_pgd, *dst_pgd;
+	unsigned long address =3D vma->vm_start;
+	unsigned long end =3D vma->vm_end;
+	
+	if (is_vm_hugetlb_page(vma))
+		return copy_hugetlb_page_range(dst, src, vma);
+
+	src_pgd =3D pgd_offset(src, address)-1;
+	dst_pgd =3D pgd_offset(dst, address)-1;
+
+	for (;;) {
+		pmd_t * src_pmd, * dst_pmd;
+
+		src_pgd++; dst_pgd++;
+		
+		if (pgd_none(*src_pgd))
+			goto skip_share_pmd_range;
+		if (pgd_bad(*src_pgd)) {
+			pgd_ERROR(*src_pgd);
+			pgd_clear(src_pgd);
+skip_share_pmd_range:	address =3D (address + PGDIR_SIZE) & PGDIR_MASK;
+			if (!address || (address >=3D end))
+				goto out;
+			continue;
+		}
+
+		src_pmd =3D pmd_offset(src_pgd, address);
+		dst_pmd =3D pmd_alloc(dst, dst_pgd, address);
+		if (!dst_pmd)
+			goto nomem;
+
+		spin_lock(&src->page_table_lock);
+
+		do {
+			pmd_t	pmdval =3D *src_pmd;
+			struct page *ptepage =3D pmd_page(pmdval);
+
+			if (pmd_none(pmdval))
+				goto skip_share_pte_range;
+			if (pmd_bad(pmdval)) {
+				pmd_ERROR(*src_pmd);
+				pmd_clear(src_pmd);
+				goto skip_share_pte_range;
+			}
+
+			/*
+			 * We set the pmd read-only in both the parent and the
+			 * child unless it's a writeable shared region that
+			 * spans the entire pte page.
+			 */
+			if ((((vma->vm_flags & (VM_SHARED|VM_MAYWRITE)) !=3D
+			    (VM_SHARED|VM_MAYWRITE)) ||
+			    (ptepage->index < vma->vm_start) ||
+			    ((ptepage->index + PMD_SIZE) > vma->vm_end)) &&
+			    pmd_write(pmdval)) {
+				pmdval =3D pmd_wrprotect(pmdval);
+				set_pmd(src_pmd, pmdval);
+			}
+			set_pmd(dst_pmd, pmdval);
+
+			/* Only do this if we haven't seen this pte page before */
+			if (src_pmd !=3D *prev_pmd) {
+				get_page(ptepage);
+				pgtable_add_rmap(ptepage, dst, address);
+				*prev_pmd =3D src_pmd;
+				dst->rss +=3D ptepage->private;
+			}
+
+skip_share_pte_range:	address =3D (address + PMD_SIZE) & PMD_MASK;
+			if (address >=3D end)
+				goto out_unlock;
+
+			src_pmd++;
+			dst_pmd++;
+		} while ((unsigned long)src_pmd & PMD_TABLE_MASK);
+		spin_unlock(&src->page_table_lock);
+	}
+
+out_unlock:
+	spin_unlock(&src->page_table_lock);
+
+out:
+	return 0;
+nomem:
+#endif
+	return -ENOMEM;
+}
+
 /*
  * copy one vm_area from one task to the other. Assumes the page tables
  * already present in the new task to be cleared in the whole range
@@ -327,6 +643,7 @@
=20
 static void zap_pte_range(mmu_gather_t *tlb, pmd_t * pmd, unsigned long =
address, unsigned long size)
 {
+	struct page *ptepage;
 	unsigned long offset;
 	pte_t *ptep;
=20
@@ -337,11 +654,34 @@
 		pmd_clear(pmd);
 		return;
 	}
-	ptep =3D pte_offset_map(pmd, address);
+
 	offset =3D address & ~PMD_MASK;
 	if (offset + size > PMD_SIZE)
 		size =3D PMD_SIZE - offset;
 	size &=3D PAGE_MASK;
+
+	/*
+	 * Check to see if the pte page is shared.  If it is and we're unmapping
+	 * the entire page, just decrement the reference count and we're done.
+	 * If we're only unmapping part of the page we'll have to unshare it the
+	 * slow way.
+	 */
+	ptepage =3D pmd_page(*pmd);
+	pte_page_lock(ptepage);
+	if (page_count(ptepage) > 1) {
+		if ((offset =3D=3D 0) && (size =3D=3D PMD_SIZE)) {
+			pmd_clear(pmd);
+			pgtable_remove_rmap_locked(ptepage, tlb->mm);
+			tlb->mm->rss -=3D ptepage->private;
+			put_page(ptepage);
+			pte_page_unlock(ptepage);
+			return;
+		}
+		ptep =3D pte_unshare(tlb->mm, pmd, address);
+		ptepage =3D pmd_page(*pmd);
+	} else {
+		ptep =3D pte_offset_map(pmd, address);
+	}
 	for (offset=3D0; offset < size; ptep++, offset +=3D PAGE_SIZE) {
 		pte_t pte =3D *ptep;
 		if (pte_none(pte))
@@ -369,6 +709,7 @@
 			pte_clear(ptep);
 		}
 	}
+	pte_page_unlock(ptepage);
 	pte_unmap(ptep-1);
 }
=20
@@ -464,6 +805,19 @@
 	spin_unlock(&mm->page_table_lock);
 }
=20
+void unmap_all_pages(mmu_gather_t *tlb, struct mm_struct *mm, unsigned =
long address, unsigned long end)
+{
+	pgd_t * dir;
+
+	if (address >=3D end)
+		BUG();
+	dir =3D pgd_offset(mm, address);
+	do {
+		zap_pmd_range(tlb, dir, address, end - address);
+		address =3D (address + PGDIR_SIZE) & PGDIR_MASK;
+		dir++;
+	} while (address && (address < end));
+}
 /*
  * Do a quick page-table lookup for a single page.
  * mm->page_table_lock must be held.
@@ -1009,6 +1363,7 @@
 	unsigned long address, pte_t *page_table, pmd_t *pmd, pte_t pte)
 {
 	struct page *old_page, *new_page;
+	struct page *ptepage =3D pmd_page(*pmd);
 	unsigned long pfn =3D pte_pfn(pte);
=20
 	if (!pfn_valid(pfn))
@@ -1022,7 +1377,7 @@
 			flush_cache_page(vma, address);
 			establish_pte(vma, address, page_table, =
pte_mkyoung(pte_mkdirty(pte_mkwrite(pte))));
 			pte_unmap(page_table);
-			spin_unlock(&mm->page_table_lock);
+			pte_page_unlock(ptepage);
 			return VM_FAULT_MINOR;
 		}
 	}
@@ -1032,7 +1387,7 @@
 	 * Ok, we need to copy. Oh, well..
 	 */
 	page_cache_get(old_page);
-	spin_unlock(&mm->page_table_lock);
+	pte_page_unlock(ptepage);
=20
 	new_page =3D alloc_page(GFP_HIGHUSER);
 	if (!new_page)
@@ -1042,11 +1397,12 @@
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	spin_lock(&mm->page_table_lock);
+	ptepage =3D pmd_page(*pmd);
+	pte_page_lock(ptepage);
 	page_table =3D pte_offset_map(pmd, address);
 	if (pte_same(*page_table, pte)) {
 		if (PageReserved(old_page))
-			++mm->rss;
+			increment_rss(ptepage);
 		page_remove_rmap(old_page, page_table);
 		break_cow(vma, new_page, address, page_table);
 		page_add_rmap(new_page, page_table);
@@ -1056,14 +1412,14 @@
 		new_page =3D old_page;
 	}
 	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+	pte_page_unlock(ptepage);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
 	return VM_FAULT_MINOR;
=20
 bad_wp_page:
 	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+	pte_page_unlock(ptepage);
 	printk(KERN_ERR "do_wp_page: bogus page at address %08lx\n", address);
 	/*
 	 * This should really halt the system so it can be debugged or
@@ -1192,12 +1548,13 @@
 	pte_t *page_table, pmd_t *pmd, pte_t orig_pte, int write_access)
 {
 	struct page *page;
+	struct page *ptepage =3D pmd_page(*pmd);
 	swp_entry_t entry =3D pte_to_swp_entry(orig_pte);
 	pte_t pte;
 	int ret =3D VM_FAULT_MINOR;
=20
 	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+	pte_page_unlock(ptepage);
 	page =3D lookup_swap_cache(entry);
 	if (!page) {
 		swapin_readahead(entry);
@@ -1207,14 +1564,15 @@
 			 * Back out if somebody else faulted in this pte while
 			 * we released the page table lock.
 			 */
-			spin_lock(&mm->page_table_lock);
+			ptepage =3D pmd_page(*pmd);
+			pte_page_lock(ptepage);
 			page_table =3D pte_offset_map(pmd, address);
 			if (pte_same(*page_table, orig_pte))
 				ret =3D VM_FAULT_OOM;
 			else
 				ret =3D VM_FAULT_MINOR;
 			pte_unmap(page_table);
-			spin_unlock(&mm->page_table_lock);
+			pte_page_unlock(ptepage);
 			return ret;
 		}
=20
@@ -1230,11 +1588,12 @@
 	 * Back out if somebody else faulted in this pte while we
 	 * released the page table lock.
 	 */
-	spin_lock(&mm->page_table_lock);
+	ptepage =3D pmd_page(*pmd);
+	pte_page_lock(ptepage);
 	page_table =3D pte_offset_map(pmd, address);
 	if (!pte_same(*page_table, orig_pte)) {
 		pte_unmap(page_table);
-		spin_unlock(&mm->page_table_lock);
+		pte_page_unlock(ptepage);
 		unlock_page(page);
 		page_cache_release(page);
 		return VM_FAULT_MINOR;
@@ -1246,7 +1605,7 @@
 	if (vm_swap_full())
 		remove_exclusive_swap_page(page);
=20
-	mm->rss++;
+	increment_rss(ptepage);
 	pte =3D mk_pte(page, vma->vm_page_prot);
 	if (write_access && can_share_swap_page(page))
 		pte =3D pte_mkdirty(pte_mkwrite(pte));
@@ -1260,7 +1619,7 @@
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
 	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+	pte_page_unlock(ptepage);
 	return ret;
 }
=20
@@ -1273,6 +1632,7 @@
 {
 	pte_t entry;
 	struct page * page =3D ZERO_PAGE(addr);
+	struct page *ptepage =3D pmd_page(*pmd);
=20
 	/* Read-only mapping of ZERO_PAGE. */
 	entry =3D pte_wrprotect(mk_pte(ZERO_PAGE(addr), vma->vm_page_prot));
@@ -1281,23 +1641,24 @@
 	if (write_access) {
 		/* Allocate our own private page. */
 		pte_unmap(page_table);
-		spin_unlock(&mm->page_table_lock);
+		pte_page_unlock(ptepage);
=20
 		page =3D alloc_page(GFP_HIGHUSER);
 		if (!page)
 			goto no_mem;
 		clear_user_highpage(page, addr);
=20
-		spin_lock(&mm->page_table_lock);
+		ptepage =3D pmd_page(*pmd);
+		pte_page_lock(ptepage);
 		page_table =3D pte_offset_map(pmd, addr);
=20
 		if (!pte_none(*page_table)) {
 			pte_unmap(page_table);
 			page_cache_release(page);
-			spin_unlock(&mm->page_table_lock);
+			pte_page_unlock(ptepage);
 			return VM_FAULT_MINOR;
 		}
-		mm->rss++;
+		increment_rss(ptepage);
 		flush_page_to_ram(page);
 		entry =3D pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 		lru_cache_add(page);
@@ -1310,7 +1671,7 @@
=20
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, entry);
-	spin_unlock(&mm->page_table_lock);
+	pte_page_unlock(ptepage);
 	return VM_FAULT_MINOR;
=20
 no_mem:
@@ -1333,12 +1694,13 @@
 	unsigned long address, int write_access, pte_t *page_table, pmd_t *pmd)
 {
 	struct page * new_page;
+	struct page *ptepage =3D pmd_page(*pmd);
 	pte_t entry;
=20
 	if (!vma->vm_ops || !vma->vm_ops->nopage)
 		return do_anonymous_page(mm, vma, page_table, pmd, write_access, =
address);
 	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+	pte_page_unlock(ptepage);
=20
 	new_page =3D vma->vm_ops->nopage(vma, address & PAGE_MASK, 0);
=20
@@ -1363,7 +1725,8 @@
 		new_page =3D page;
 	}
=20
-	spin_lock(&mm->page_table_lock);
+	ptepage =3D pmd_page(*pmd);
+	pte_page_lock(ptepage);
 	page_table =3D pte_offset_map(pmd, address);
=20
 	/*
@@ -1378,7 +1741,7 @@
 	 */
 	/* Only go through if we didn't race with anybody else... */
 	if (pte_none(*page_table)) {
-		++mm->rss;
+		increment_rss(ptepage);
 		flush_page_to_ram(new_page);
 		flush_icache_page(vma, new_page);
 		entry =3D mk_pte(new_page, vma->vm_page_prot);
@@ -1391,13 +1754,13 @@
 		/* One of our sibling threads was faster, back out. */
 		pte_unmap(page_table);
 		page_cache_release(new_page);
-		spin_unlock(&mm->page_table_lock);
+		pte_page_unlock(ptepage);
 		return VM_FAULT_MINOR;
 	}
=20
 	/* no need to invalidate: a not-present page shouldn't be cached */
 	update_mmu_cache(vma, address, entry);
-	spin_unlock(&mm->page_table_lock);
+	pte_page_unlock(ptepage);
 	return VM_FAULT_MAJOR;
 }
=20
@@ -1449,7 +1812,7 @@
 	entry =3D pte_mkyoung(entry);
 	establish_pte(vma, address, pte, entry);
 	pte_unmap(pte);
-	spin_unlock(&mm->page_table_lock);
+	pte_page_unlock(pmd_page(*pmd));
 	return VM_FAULT_MINOR;
 }
=20
@@ -1474,9 +1837,20 @@
 	pmd =3D pmd_alloc(mm, pgd, address);
=20
 	if (pmd) {
-		pte_t * pte =3D pte_alloc_map(mm, pmd, address);
-		if (pte)
+		pte_t * pte;
+
+		if (pte_needs_unshare(mm, vma, pmd, address, write_access)) {
+			pte_page_lock(pmd_page(*pmd));
+			pte =3D pte_unshare(mm, pmd, address);
+		} else {
+			pte =3D pte_alloc_map(mm, pmd, address);
+			pte_page_lock(pmd_page(*pmd));
+		}
+
+		if (pte) {
+			spin_unlock(&mm->page_table_lock);
 			return handle_pte_fault(mm, vma, address, write_access, pte, pmd);
+		}
 	}
 	spin_unlock(&mm->page_table_lock);
 	return VM_FAULT_OOM;
--- 2.5.41-mm1/./mm/rmap.c	2002-10-07 13:25:15.000000000 -0500
+++ 2.5.41-mm1-shpte/./mm/rmap.c	2002-10-09 10:25:52.000000000 -0500
@@ -45,11 +45,17 @@
  */
 #define NRPTE ((L1_CACHE_BYTES - sizeof(void *))/sizeof(pte_addr_t))
=20
+struct mm_chain {
+	struct mm_chain *next;
+	struct mm_struct *mm;
+};
+
 struct pte_chain {
 	struct pte_chain *next;
 	pte_addr_t ptes[NRPTE];
 };
=20
+static kmem_cache_t	*mm_chain_cache;
 static kmem_cache_t	*pte_chain_cache;
=20
 /*
@@ -102,6 +108,25 @@
 	kmem_cache_free(pte_chain_cache, pte_chain);
 }
=20
+static inline struct mm_chain *mm_chain_alloc(void)
+{
+	struct mm_chain *ret;
+
+	ret =3D kmem_cache_alloc(mm_chain_cache, GFP_ATOMIC);
+	return ret;
+}
+
+static void mm_chain_free(struct mm_chain *mc,
+		struct mm_chain *prev_mc, struct page *page)
+{
+	if (prev_mc)
+		prev_mc->next =3D mc->next;
+	else if (page)
+		page->pte.mmchain =3D mc->next;
+
+	kmem_cache_free(mm_chain_cache, mc);
+}
+
 /**
  ** VM stuff below this comment
  **/
@@ -161,6 +186,94 @@
 	return referenced;
 }
=20
+void pgtable_add_rmap_locked(struct page * page, struct mm_struct * mm,
+			     unsigned long address)
+{
+	struct mm_chain *mc;
+
+#ifdef BROKEN_PPC_PTE_ALLOC_ONE
+	/* OK, so PPC calls pte_alloc() before mem_map[] is setup ... ;( */
+	extern int mem_init_done;
+
+	if (!mem_init_done)
+		return;
+#endif
+#ifdef RMAP_DEBUG
+	BUG_ON(mm =3D=3D NULL);
+#endif
+	
+	if (PageDirect(page)) {
+		mc =3D mm_chain_alloc();
+		mc->mm =3D page->pte.mmdirect;
+		mc->next =3D NULL;
+		page->pte.mmchain =3D mc;
+		ClearPageDirect(page);
+	}
+	if (page->pte.mmchain) {
+		/* Hook up the mm_chain to the page. */
+		mc =3D mm_chain_alloc();
+		mc->mm =3D mm;
+		mc->next =3D page->pte.mmchain;
+		page->pte.mmchain =3D mc;
+	} else {
+		page->pte.mmdirect =3D mm;
+		SetPageDirect(page);
+		page->index =3D address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
+	}
+}
+
+void pgtable_remove_rmap_locked(struct page * page, struct mm_struct *mm)
+{
+	struct mm_chain * mc, * prev_mc =3D NULL;
+
+#ifdef DEBUG_RMAP
+	BUG_ON(mm =3D=3D NULL);
+#endif
+
+	if (PageDirect(page)) {
+		if (page->pte.mmdirect =3D=3D mm) {
+			page->pte.mmdirect =3D NULL;
+			ClearPageDirect(page);
+			page->index =3D 0;
+			goto out;
+		}
+	} else {
+#ifdef DEBUG_RMAP
+		BUG_ON(page->pte.mmchain->next =3D=3D NULL);
+#endif
+		for (mc =3D page->pte.mmchain; mc; prev_mc =3D mc, mc =3D mc->next) {
+			if (mc->mm =3D=3D mm) {
+				mm_chain_free(mc, prev_mc, page);
+				/* Check whether we can convert to direct */
+				mc =3D page->pte.mmchain;
+				if (!mc->next) {
+					page->pte.mmdirect =3D mc->mm;
+					SetPageDirect(page);
+					mm_chain_free(mc, NULL, NULL);
+				}
+				goto out;
+			}
+		}
+	}
+	BUG();
+out:
+}
+
+void pgtable_add_rmap(struct page * page, struct mm_struct * mm,
+			     unsigned long address)
+{
+	pte_page_lock(page);
+	pgtable_add_rmap_locked(page, mm, address);
+	pte_page_unlock(page);
+}
+
+void pgtable_remove_rmap(struct page * page, struct mm_struct *mm)
+{
+	pte_page_lock(page);
+	pgtable_remove_rmap_locked(page, mm);
+	pte_page_unlock(page);
+}
+
 /**
  * page_add_rmap - add reverse mapping entry to a page
  * @page: the page to add the mapping to
@@ -180,8 +293,6 @@
 		BUG();
 	if (!pte_present(*ptep))
 		BUG();
-	if (!ptep_to_mm(ptep))
-		BUG();
 #endif
=20
 	if (!pfn_valid(page_to_pfn(page)) || PageReserved(page))
@@ -199,12 +310,15 @@
 			if (page->pte.direct =3D=3D pte_paddr)
 				BUG();
 		} else {
+			int count =3D 0;
 			for (pc =3D page->pte.chain; pc; pc =3D pc->next) {
-				for (i =3D 0; i < NRPTE; i++) {
+				for (i =3D 0; i < NRPTE; i++, count++) {
 					pte_addr_t p =3D pc->ptes[i];
=20
-					if (p && p =3D=3D pte_paddr)
+					if (p && p =3D=3D pte_paddr) {
+						printk(KERN_ERR "page_add_rmap: page %08lx (count %d), ptep %08lx, =
rmap count %d\n", page, page_count(page), ptep, count);
 						BUG();
+					}
 				}
 			}
 		}
@@ -342,6 +456,98 @@
 	return;
 }
=20
+static inline int pgtable_check_mlocked_mm(struct mm_struct *mm, unsigned =
long address)
+{
+	struct vm_area_struct *vma;
+	int ret =3D SWAP_SUCCESS;
+
+	/* During mremap, it's possible pages are not in a VMA. */
+	vma =3D find_vma(mm, address);
+	if (!vma) {
+		ret =3D SWAP_FAIL;
+		goto out;
+	}
+
+	/* The page is mlock()d, we cannot swap it out. */
+	if (vma->vm_flags & VM_LOCKED) {
+		ret =3D SWAP_FAIL;
+	}
+out:
+	return ret;
+}
+
+static inline int pgtable_check_mlocked(struct page *ptepage, unsigned =
long address)
+{
+	struct mm_chain *mc;
+	int ret =3D SWAP_SUCCESS;
+
+	if (PageDirect(ptepage)) {
+		ret =3D pgtable_check_mlocked_mm(ptepage->pte.mmdirect, address);
+		goto out;
+	}
+
+	for (mc =3D ptepage->pte.mmchain; mc; mc =3D mc->next) {
+#ifdef DEBUG_RMAP
+		BUG_ON(mc->mm =3D=3D NULL);
+#endif
+		ret =3D pgtable_check_mlocked_mm(mc->mm, address);
+		if (ret !=3D SWAP_SUCCESS)
+			goto out;
+	}
+out:
+	return ret;
+}
+
+static inline int pgtable_unmap_one_mm(struct mm_struct *mm, unsigned long =
address)
+{
+	struct vm_area_struct *vma;
+	int ret =3D SWAP_SUCCESS;
+
+	/* During mremap, it's possible pages are not in a VMA. */
+	vma =3D find_vma(mm, address);
+	if (!vma) {
+		ret =3D SWAP_FAIL;
+		goto out;
+	}
+	flush_tlb_page(vma, address);
+	flush_cache_page(vma, address);
+	mm->rss--;
+
+out:
+	return ret;
+}
+
+static inline int pgtable_unmap_one(struct page *ptepage, unsigned long =
address)
+{
+	struct mm_chain *mc;
+	int ret =3D SWAP_SUCCESS;
+
+	if (PageDirect(ptepage)) {
+		ret =3D pgtable_unmap_one_mm(ptepage->pte.mmdirect, address);
+		if (ret !=3D SWAP_SUCCESS)
+			goto out;
+	} else for (mc =3D ptepage->pte.mmchain; mc; mc =3D mc->next) {
+		ret =3D pgtable_unmap_one_mm(mc->mm, address);
+		if (ret !=3D SWAP_SUCCESS)
+			goto out;
+	}
+	ptepage->private--;
+out:
+	return ret;
+}
+
+void increment_rss(struct page *ptepage)
+{
+	struct mm_chain *mc;
+
+	if (PageDirect(ptepage))
+		ptepage->pte.mmdirect->rss++;
+	else for (mc =3D ptepage->pte.mmchain; mc; mc =3D mc->next)
+		mc->mm->rss++;
+
+	ptepage->private++;
+}
+
 /**
  * try_to_unmap_one - worker function for try_to_unmap
  * @page: page to unmap
@@ -360,42 +566,24 @@
 static int try_to_unmap_one(struct page * page, pte_addr_t paddr)
 {
 	pte_t *ptep =3D rmap_ptep_map(paddr);
-	unsigned long address =3D ptep_to_address(ptep);
-	struct mm_struct * mm =3D ptep_to_mm(ptep);
-	struct vm_area_struct * vma;
 	pte_t pte;
+	struct page *ptepage =3D kmap_atomic_to_page(ptep);
+	unsigned long address =3D ptep_to_address(ptep);
 	int ret;
=20
-	if (!mm)
-		BUG();
-
-	/*
-	 * We need the page_table_lock to protect us from page faults,
-	 * munmap, fork, etc...
-	 */
-	if (!spin_trylock(&mm->page_table_lock)) {
-		rmap_ptep_unmap(ptep);
-		return SWAP_AGAIN;
-	}
-
+	pte_page_lock(ptepage);
=20
-	/* During mremap, it's possible pages are not in a VMA. */
-	vma =3D find_vma(mm, address);
-	if (!vma) {
-		ret =3D SWAP_FAIL;
+	ret =3D pgtable_check_mlocked(ptepage, address);
+	if (ret !=3D SWAP_SUCCESS)
 		goto out_unlock;
-	}
+	pte =3D ptep_get_and_clear(ptep);
=20
-	/* The page is mlock()d, we cannot swap it out. */
-	if (vma->vm_flags & VM_LOCKED) {
-		ret =3D SWAP_FAIL;
+	ret =3D pgtable_unmap_one(ptepage, address);
+	if (ret !=3D SWAP_SUCCESS) {
+		set_pte(ptep, pte);
 		goto out_unlock;
 	}
-
-	/* Nuke the page table entry. */
-	pte =3D ptep_get_and_clear(ptep);
-	flush_tlb_page(vma, address);
-	flush_cache_page(vma, address);
+	pte_page_unlock(ptepage);
=20
 	/* Store the swap location in the pte. See handle_pte_fault() ... */
 	if (PageSwapCache(page)) {
@@ -408,13 +596,15 @@
 	if (pte_dirty(pte))
 		set_page_dirty(page);
=20
-	mm->rss--;
 	page_cache_release(page);
 	ret =3D SWAP_SUCCESS;
+	goto out;
=20
 out_unlock:
+	pte_page_unlock(ptepage);
+
+out:
 	rmap_ptep_unmap(ptep);
-	spin_unlock(&mm->page_table_lock);
 	return ret;
 }
=20
@@ -523,6 +713,17 @@
=20
 void __init pte_chain_init(void)
 {
+
+	mm_chain_cache =3D kmem_cache_create(	"mm_chain",
+						sizeof(struct mm_chain),
+						0,
+						0,
+						NULL,
+						NULL);
+
+	if (!mm_chain_cache)
+		panic("failed to create mm_chain cache!\n");
+
 	pte_chain_cache =3D kmem_cache_create(	"pte_chain",
 						sizeof(struct pte_chain),
 						0,

--==========1075830887==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
