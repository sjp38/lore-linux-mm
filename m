Date: Wed, 11 Oct 2000 19:52:21 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [RFC] atomic pte updates for x86 smp
In-Reply-To: <200010111838.e9BIc0M02456@trampoline.thunk.org>
Message-ID: <Pine.LNX.4.21.0010111937380.892-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com, tytso@mit.edu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Oct 2000 tytso@mit.edu wrote:

>    > 2. Capable Of Corrupting Your FS/data
>    > 
>    >      * Non-atomic page-map operations can cause loss of dirty bit on
>    >        pages (sct, alan)
> 
>    Is anybody looking into fixing this bug ?
> 
> According to sct (who's sitting next to me in my hotel room at ALS) Ben
> LaHaise has a bugfix for this, but it hasn't been merged.

Here's an updated version of the patch that doesn't do the funky RISC like
dirty bit updates.  It doesn't incur the additional overhead of page
faults on dirty, which actually happens a lot on SHM attaches
(during Oracle runs this is quite noticeable due to their use of
hundreds of MB of SHM).  Ted: Note that there are a couple of other SMP
races that still need fixing: list them under VM threading bug under SMP
(different bug).

		-ben

# v2.4.0-test10-1-smp_pte_fix.diff
diff -ur v2.4.0-test10-pre1/include/asm-i386/pgtable-2level.h work-v2.4.0-test10-pre1/include/asm-i386/pgtable-2level.h
--- v2.4.0-test10-pre1/include/asm-i386/pgtable-2level.h	Fri Dec  3 14:12:23 1999
+++ work-v2.4.0-test10-pre1/include/asm-i386/pgtable-2level.h	Wed Oct 11 16:08:08 2000
@@ -55,4 +55,7 @@
 	return (pmd_t *) dir;
 }
 
+#define __HAVE_ARCH_pte_xchg_clear
+#define pte_xchg_clear(xp)	__pte(xchg(&(xp)->pte, 0))
+
 #endif /* _I386_PGTABLE_2LEVEL_H */
diff -ur v2.4.0-test10-pre1/include/asm-i386/pgtable-3level.h work-v2.4.0-test10-pre1/include/asm-i386/pgtable-3level.h
--- v2.4.0-test10-pre1/include/asm-i386/pgtable-3level.h	Mon Dec  6 19:19:13 1999
+++ work-v2.4.0-test10-pre1/include/asm-i386/pgtable-3level.h	Wed Oct 11 16:14:40 2000
@@ -76,4 +76,17 @@
 #define pmd_offset(dir, address) ((pmd_t *) pgd_page(*(dir)) + \
 			__pmd_offset(address))
 
+#define __HAVE_ARCH_pte_xchg_clear
+extern inline pte_t pte_xchg_clear(pte_t *ptep)
+{
+	long long res = pte_val(*ptep);
+__asm__ __volatile__ (
+        "1: cmpxchg8b (%1);
+                jnz 1b"
+        : "=A" (res)
+	:"D"(ptep), "0" (res), "b"(0), "c"(0)
+        : "memory");
+	return (pte_t){ res };
+}
+
 #endif /* _I386_PGTABLE_3LEVEL_H */
diff -ur v2.4.0-test10-pre1/include/asm-i386/pgtable.h work-v2.4.0-test10-pre1/include/asm-i386/pgtable.h
--- v2.4.0-test10-pre1/include/asm-i386/pgtable.h	Mon Oct  2 14:06:43 2000
+++ work-v2.4.0-test10-pre1/include/asm-i386/pgtable.h	Wed Oct 11 17:44:04 2000
@@ -17,6 +17,10 @@
 #include <asm/fixmap.h>
 #include <linux/threads.h>
 
+#ifndef _I386_BITOPS_H
+#include <asm/bitops.h>
+#endif
+
 extern pgd_t swapper_pg_dir[1024];
 extern void paging_init(void);
 
@@ -145,6 +149,16 @@
  * the page directory entry points directly to a 4MB-aligned block of
  * memory. 
  */
+#define _PAGE_BIT_PRESENT	0
+#define _PAGE_BIT_RW		1
+#define _PAGE_BIT_USER		2
+#define _PAGE_BIT_PWT		3
+#define _PAGE_BIT_PCD		4
+#define _PAGE_BIT_ACCESSED	5
+#define _PAGE_BIT_DIRTY		6
+#define _PAGE_BIT_PSE		7	/* 4 MB (or 2MB) page, Pentium+, if present.. */
+#define _PAGE_BIT_GLOBAL	8	/* Global TLB entry PPro+ */
+
 #define _PAGE_PRESENT	0x001
 #define _PAGE_RW	0x002
 #define _PAGE_USER	0x004
@@ -234,6 +248,24 @@
 #define pte_none(x)	(!pte_val(x))
 #define pte_present(x)	(pte_val(x) & (_PAGE_PRESENT | _PAGE_PROTNONE))
 #define pte_clear(xp)	do { set_pte(xp, __pte(0)); } while (0)
+
+#define __HAVE_ARCH_pte_test_and_clear_dirty
+static inline int pte_test_and_clear_dirty(pte_t *page_table, pte_t pte)
+{
+	return test_and_clear_bit(_PAGE_BIT_DIRTY, page_table);
+}
+
+#define __HAVE_ARCH_pte_test_and_clear_young
+static inline int pte_test_and_clear_young(pte_t *page_table, pte_t pte)
+{
+	return test_and_clear_bit(_PAGE_BIT_ACCESSED, page_table);
+}
+
+#define __HAVE_ARCH_atomic_pte_wrprotect
+static inline void atomic_pte_wrprotect(pte_t *page_table, pte_t old_pte)
+{
+	clear_bit(_PAGE_BIT_RW, page_table);
+}
 
 #define pmd_none(x)	(!pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
diff -ur v2.4.0-test10-pre1/include/linux/mm.h work-v2.4.0-test10-pre1/include/linux/mm.h
--- v2.4.0-test10-pre1/include/linux/mm.h	Tue Oct  3 13:40:38 2000
+++ work-v2.4.0-test10-pre1/include/linux/mm.h	Wed Oct 11 17:44:38 2000
@@ -532,6 +532,42 @@
 #define vmlist_modify_lock(mm)		vmlist_access_lock(mm)
 #define vmlist_modify_unlock(mm)	vmlist_access_unlock(mm)
 
+#ifndef __HAVE_ARCH_pte_test_and_clear_young
+static inline int pte_test_and_clear_young(pte_t *page_table, pte_t pte)
+{
+	if (!pte_young(pte))
+		return 0;
+	set_pte(page_table, pte_mkold(pte));
+	return 1;
+}
+#endif
+
+#ifndef __HAVE_ARCH_pte_test_and_clear_dirty
+static inline int pte_test_and_clear_dirty(pte_t *page_table, pte_t pte)
+{
+	if (!pte_dirty(pte))
+		return 0;
+	set_pte(page_table, pte_mkclean(pte));
+	return 1;
+}
+#endif
+
+#ifndef __HAVE_ARCH_pte_xchg_clear
+static pte_t pte_xchg_clear(pte_t *page_table)
+{
+	pte_t pte = *page_table;
+	pte_clear(page_table);
+	return pte;
+}
+#endif
+
+#ifndef __HAVE_ARCH_atomic_pte_wrprotect
+static inline void atomic_pte_wrprotect(pte_t *page_table, pte_t old_pte)
+{
+	set_pte(page_table, pte_wrprotect(old_pte));
+}
+#endif
+
 #endif /* __KERNEL__ */
 
 #endif
diff -ur v2.4.0-test10-pre1/mm/filemap.c work-v2.4.0-test10-pre1/mm/filemap.c
--- v2.4.0-test10-pre1/mm/filemap.c	Tue Oct  3 13:40:38 2000
+++ work-v2.4.0-test10-pre1/mm/filemap.c	Wed Oct 11 18:26:35 2000
@@ -1475,39 +1475,47 @@
 	return retval;
 }
 
+/* Called with mm->page_table_lock held to protect against other
+ * threads/the swapper from ripping pte's out from under us.
+ */
 static inline int filemap_sync_pte(pte_t * ptep, struct vm_area_struct *vma,
 	unsigned long address, unsigned int flags)
 {
 	unsigned long pgoff;
-	pte_t pte = *ptep;
+	pte_t pte;
 	struct page *page;
 	int error;
 
+	pte = *ptep;
+
 	if (!(flags & MS_INVALIDATE)) {
 		if (!pte_present(pte))
-			return 0;
-		if (!pte_dirty(pte))
-			return 0;
+			goto out;
+		if (!pte_test_and_clear_dirty(ptep, pte))
+			goto out;
 		flush_page_to_ram(pte_page(pte));
 		flush_cache_page(vma, address);
-		set_pte(ptep, pte_mkclean(pte));
 		flush_tlb_page(vma, address);
 		page = pte_page(pte);
 		page_cache_get(page);
 	} else {
 		if (pte_none(pte))
-			return 0;
+			goto out;
 		flush_cache_page(vma, address);
-		pte_clear(ptep);
+
+		pte = pte_xchg_clear(ptep);
 		flush_tlb_page(vma, address);
+
 		if (!pte_present(pte)) {
+			spin_unlock(&vma->vm_mm->page_table_lock);
 			swap_free(pte_to_swp_entry(pte));
-			return 0;
+			spin_lock(&vma->vm_mm->page_table_lock);
+			goto out;
 		}
 		page = pte_page(pte);
 		if (!pte_dirty(pte) || flags == MS_INVALIDATE) {
 			page_cache_free(page);
-			return 0;
+			goto out;
 		}
 	}
 	pgoff = (address - vma->vm_start) >> PAGE_CACHE_SHIFT;
@@ -1516,11 +1524,18 @@
 		printk("weirdness: pgoff=%lu index=%lu address=%lu vm_start=%lu vm_pgoff=%lu\n",
 			pgoff, page->index, address, vma->vm_start, vma->vm_pgoff);
 	}
+
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	lock_page(page);
 	error = filemap_write_page(vma->vm_file, page, 1);
 	UnlockPage(page);
 	page_cache_free(page);
+
+	spin_lock(&vma->vm_mm->page_table_lock);
 	return error;
+
+out:
+	return 0;
 }
 
 static inline int filemap_sync_pte_range(pmd_t * pmd,
@@ -1590,6 +1605,11 @@
 	unsigned long end = address + size;
 	int error = 0;
 
+	/* Aquire the lock early; it may be possible to avoid dropping
+	 * and reaquiring it repeatedly.
+	 */
+	spin_lock(&vma->vm_mm->page_table_lock);
+
 	dir = pgd_offset(vma->vm_mm, address);
 	flush_cache_range(vma->vm_mm, end - size, end);
 	if (address >= end)
@@ -1600,6 +1620,9 @@
 		dir++;
 	} while (address && (address < end));
 	flush_tlb_range(vma->vm_mm, end - size, end);
+
+	spin_unlock(&vma->vm_mm->page_table_lock);
+
 	return error;
 }
 
diff -ur v2.4.0-test10-pre1/mm/highmem.c work-v2.4.0-test10-pre1/mm/highmem.c
--- v2.4.0-test10-pre1/mm/highmem.c	Tue Oct 10 16:57:31 2000
+++ work-v2.4.0-test10-pre1/mm/highmem.c	Tue Oct 10 18:13:44 2000
@@ -130,10 +130,10 @@
 		if (pkmap_count[i] != 1)
 			continue;
 		pkmap_count[i] = 0;
-		pte = pkmap_page_table[i];
+		//pte = pkmap_page_table[i]; pte_clear(pkmap_page_table+i);
+		pte = pte_xchg_clear(pkmap_page_table+i);
 		if (pte_none(pte))
 			BUG();
-		pte_clear(pkmap_page_table+i);
 		page = pte_page(pte);
 		page->virtual = NULL;
 	}
diff -ur v2.4.0-test10-pre1/mm/memory.c work-v2.4.0-test10-pre1/mm/memory.c
--- v2.4.0-test10-pre1/mm/memory.c	Tue Oct  3 13:40:38 2000
+++ work-v2.4.0-test10-pre1/mm/memory.c	Wed Oct 11 18:30:17 2000
@@ -215,30 +215,30 @@
 				/* copy_one_pte */
 
 				if (pte_none(pte))
-					goto cont_copy_pte_range;
+					goto cont_copy_pte_range_noset;
 				if (!pte_present(pte)) {
 					swap_duplicate(pte_to_swp_entry(pte));
-					set_pte(dst_pte, pte);
 					goto cont_copy_pte_range;
 				}
 				ptepage = pte_page(pte);
 				if ((!VALID_PAGE(ptepage)) || 
-				    PageReserved(ptepage)) {
-					set_pte(dst_pte, pte);
+				    PageReserved(ptepage))
 					goto cont_copy_pte_range;
-				}
+
 				/* If it's a COW mapping, write protect it both in the parent and the child */
 				if (cow) {
-					pte = pte_wrprotect(pte);
-					set_pte(src_pte, pte);
+					atomic_pte_wrprotect(src_pte, pte);
+					pte = *src_pte;
 				}
+
 				/* If it's a shared mapping, mark it clean in the child */
 				if (vma->vm_flags & VM_SHARED)
 					pte = pte_mkclean(pte);
-				set_pte(dst_pte, pte_mkold(pte));
+				pte = pte_mkold(pte);
 				get_page(ptepage);
-			
-cont_copy_pte_range:		address += PAGE_SIZE;
+
+cont_copy_pte_range:		set_pte(dst_pte, pte);
+cont_copy_pte_range_noset:	address += PAGE_SIZE;
 				if (address >= end)
 					goto out;
 				src_pte++;
@@ -306,10 +306,9 @@
 		pte_t page;
 		if (!size)
 			break;
-		page = *pte;
+		page = pte_xchg_clear(pte);
 		pte++;
 		size--;
-		pte_clear(pte-1);
 		if (pte_none(page))
 			continue;
 		freed += free_pte(page);
@@ -712,8 +711,8 @@
 		end = PMD_SIZE;
 	do {
 		struct page *page;
-		pte_t oldpage = *pte;
-		pte_clear(pte);
+		pte_t oldpage;
+		oldpage = pte_xchg_clear(pte);
 
 		page = virt_to_page(__va(phys_addr));
 		if ((!VALID_PAGE(page)) || PageReserved(page))
@@ -746,6 +745,7 @@
 	return 0;
 }
 
+/*  Note: this is only safe if the mm semaphore is held when called. */
 int remap_page_range(unsigned long from, unsigned long phys_addr, unsigned long size, pgprot_t prot)
 {
 	int error = 0;
diff -ur v2.4.0-test10-pre1/mm/mremap.c work-v2.4.0-test10-pre1/mm/mremap.c
--- v2.4.0-test10-pre1/mm/mremap.c	Tue Oct  3 13:40:38 2000
+++ work-v2.4.0-test10-pre1/mm/mremap.c	Wed Oct 11 02:38:41 2000
@@ -63,14 +63,14 @@
 	pte_t pte;
 
 	spin_lock(&mm->page_table_lock);
-	pte = *src;
+	pte = pte_xchg_clear(src);
 	if (!pte_none(pte)) {
-		error++;
-		if (dst) {
-			pte_clear(src);
-			set_pte(dst, pte);
-			error--;
+		if (!dst) {
+			/* No dest?  We must put it back. */
+			dst = src;
+			error++;
 		}
+		set_pte(dst, pte);
 	}
 	spin_unlock(&mm->page_table_lock);
 	return error;
diff -ur v2.4.0-test10-pre1/mm/vmalloc.c work-v2.4.0-test10-pre1/mm/vmalloc.c
--- v2.4.0-test10-pre1/mm/vmalloc.c	Tue Oct  3 13:40:38 2000
+++ work-v2.4.0-test10-pre1/mm/vmalloc.c	Wed Oct 11 16:38:21 2000
@@ -34,14 +34,15 @@
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
 	do {
-		pte_t page = *pte;
-		pte_clear(pte);
+		pte_t page;
+		page = pte_xchg_clear(pte);
 		address += PAGE_SIZE;
 		pte++;
 		if (pte_none(page))
 			continue;
 		if (pte_present(page)) {
 			struct page *ptpage = pte_page(page);
+			/* FIXME: i am an ugly little race condition */
 			if (VALID_PAGE(ptpage) && (!PageReserved(ptpage)))
 				__free_page(ptpage);
 			continue;
diff -ur v2.4.0-test10-pre1/mm/vmscan.c work-v2.4.0-test10-pre1/mm/vmscan.c
--- v2.4.0-test10-pre1/mm/vmscan.c	Tue Oct 10 16:57:31 2000
+++ work-v2.4.0-test10-pre1/mm/vmscan.c	Wed Oct 11 18:17:17 2000
@@ -55,8 +55,7 @@
 
 	onlist = PageActive(page);
 	/* Don't look at this pte if it's been accessed recently. */
-	if (pte_young(pte)) {
-		set_pte(page_table, pte_mkold(pte));
+	if (pte_test_and_clear_young(page_table, pte)) {
 		if (onlist) {
 			/*
 			 * Transfer the "accessed" bit from the page
@@ -99,6 +98,10 @@
 	if (PageSwapCache(page)) {
 		entry.val = page->index;
 		swap_duplicate(entry);
+		if (pte_dirty(pte))
+			BUG();
+		if (pte_write(pte))
+			BUG();
 		set_pte(page_table, swp_entry_to_pte(entry));
 drop_pte:
 		UnlockPage(page);
@@ -109,6 +112,13 @@
 		goto out_failed;
 	}
 
+	/* From this point on, the odds are that we're going to
+	 * nuke this pte, so read and clear the pte.  This hook
+	 * is needed on CPUs which update the accessed and dirty
+	 * bits in hardware.
+	 */
+	pte = pte_xchg_clear(page_table);
+
 	/*
 	 * Is it a clean page? Then it must be recoverable
 	 * by just paging it in again, and we can just drop
@@ -124,7 +134,6 @@
 	 */
 	if (!pte_dirty(pte)) {
 		flush_cache_page(vma, address);
-		pte_clear(page_table);
 		goto drop_pte;
 	}
 
@@ -134,7 +143,7 @@
 	 * locks etc.
 	 */
 	if (!(gfp_mask & __GFP_IO))
-		goto out_unlock;
+		goto out_unlock_restore;
 
 	/*
 	 * Don't do any of the expensive stuff if
@@ -143,7 +152,7 @@
 	if (page->zone->free_pages + page->zone->inactive_clean_pages
 					+ page->zone->inactive_dirty_pages
 		      	> page->zone->pages_high + inactive_target)
-		goto out_unlock;
+		goto out_unlock_restore;
 
 	/*
 	 * Ok, it's really dirty. That means that
@@ -169,7 +178,7 @@
 		int error;
 		struct file *file = vma->vm_file;
 		if (file) get_file(file);
-		pte_clear(page_table);
+
 		mm->rss--;
 		flush_tlb_page(vma, address);
 		vmlist_access_unlock(mm);
@@ -191,10 +200,12 @@
 	 */
 	entry = get_swap_page();
 	if (!entry.val)
-		goto out_unlock; /* No swap space left */
+		goto out_unlock_restore; /* No swap space left */
 
-	if (!(page = prepare_highmem_swapout(page)))
+	if (!(page = prepare_highmem_swapout(page))) {
+		set_pte(page_table, pte);
 		goto out_swap_free;
+	}
 
 	swap_duplicate(entry);	/* One for the process, one for the swap cache */
 
@@ -218,7 +229,8 @@
 	swap_free(entry);
 out_failed:
 	return 0;
-out_unlock:
+out_unlock_restore:
+	set_pte(page_table, pte);
 	UnlockPage(page);
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
