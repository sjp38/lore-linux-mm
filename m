Date: Fri, 13 Oct 2000 20:17:42 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [RFC] atomic pte updates and pae changes, take 2
Message-ID: <Pine.LNX.4.21.0010132002440.25522-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hey folks

Below is take two of the patch making pte_clear use atomic xchg in an
effort to avoid the loss of dirty bits.  PAE no longer uses cmpxchg8 for
updates; set_pte is two ordered long writes with a barrier.  The use of
long long for ptes is also removed; gcc should generate better code now. A
quick test with filemap_rw shows no measurable difference between pae and
non pae code, as well as no degradation from the original non-atomic
non-pae code.  This code has been tested on a box with 4GB (about 48MB is
above the 4G boundry) in PAE mode, and in non PAE mode on a couple of
other boxes too.  Linus: comments?  Ingo: could you have a look over the
code?  Thanks,

		-ben

diff -ur v2.4.0-test10-pre2/arch/i386/boot/install.sh work-10-2/arch/i386/boot/install.sh
--- v2.4.0-test10-pre2/arch/i386/boot/install.sh	Tue Jan  3 06:57:26 1995
+++ work-10-2/arch/i386/boot/install.sh	Fri Oct 13 17:19:47 2000
@@ -21,6 +21,7 @@
 
 # User may have a custom install script
 
+if [ -x ~/bin/installkernel ]; then exec ~/bin/installkernel "$@"; fi
 if [ -x /sbin/installkernel ]; then exec /sbin/installkernel "$@"; fi
 
 # Default install - same as make zlilo
diff -ur v2.4.0-test10-pre2/include/asm-i386/page.h work-10-2/include/asm-i386/page.h
--- v2.4.0-test10-pre2/include/asm-i386/page.h	Thu Oct 12 17:42:11 2000
+++ work-10-2/include/asm-i386/page.h	Fri Oct 13 17:36:02 2000
@@ -37,20 +37,20 @@
  * These are used to make use of C type-checking..
  */
 #if CONFIG_X86_PAE
-typedef struct { unsigned long long pte; } pte_t;
+typedef struct { unsigned long pte_low, pte_high; } pte_t;
 typedef struct { unsigned long long pmd; } pmd_t;
 typedef struct { unsigned long long pgd; } pgd_t;
-#define PTE_MASK	(~(unsigned long long) (PAGE_SIZE-1))
+#define pte_val(x)	((x).pte_low | ((unsigned long long)(x).pte_high << 32))
 #else
-typedef struct { unsigned long pte; } pte_t;
+typedef struct { unsigned long pte_low; } pte_t;
 typedef struct { unsigned long pmd; } pmd_t;
 typedef struct { unsigned long pgd; } pgd_t;
-#define PTE_MASK	PAGE_MASK
+#define pte_val(x)	((x).pte_low)
 #endif
+#define PTE_MASK	PAGE_MASK
 
 typedef struct { unsigned long pgprot; } pgprot_t;
 
-#define pte_val(x)	((x).pte)
 #define pmd_val(x)	((x).pmd)
 #define pgd_val(x)	((x).pgd)
 #define pgprot_val(x)	((x).pgprot)
diff -ur v2.4.0-test10-pre2/include/asm-i386/pgtable-2level.h work-10-2/include/asm-i386/pgtable-2level.h
--- v2.4.0-test10-pre2/include/asm-i386/pgtable-2level.h	Fri Dec  3 14:12:23 1999
+++ work-10-2/include/asm-i386/pgtable-2level.h	Fri Oct 13 17:41:14 2000
@@ -18,7 +18,7 @@
 #define PTRS_PER_PTE	1024
 
 #define pte_ERROR(e) \
-	printk("%s:%d: bad pte %08lx.\n", __FILE__, __LINE__, pte_val(e))
+	printk("%s:%d: bad pte %08lx.\n", __FILE__, __LINE__, (e).pte_low)
 #define pmd_ERROR(e) \
 	printk("%s:%d: bad pmd %08lx.\n", __FILE__, __LINE__, pmd_val(e))
 #define pgd_ERROR(e) \
@@ -54,5 +54,12 @@
 {
 	return (pmd_t *) dir;
 }
+
+#define __HAVE_ARCH_pte_get_and_clear
+#define pte_get_and_clear(xp)	__pte(xchg(&(xp)->pte_low, 0))
+#define pte_same(a, b)		((a).pte_low == (b).pte_low)
+#define pte_page(x)		(mem_map+((unsigned long)(((x).pte_low >> PAGE_SHIFT))))
+#define pte_none(x)		(!(x).pte_low)
+#define __mk_pte(page_nr,pgprot) __pte(((page_nr) << PAGE_SHIFT) | pgprot_val(pgprot))
 
 #endif /* _I386_PGTABLE_2LEVEL_H */
diff -ur v2.4.0-test10-pre2/include/asm-i386/pgtable-3level.h work-10-2/include/asm-i386/pgtable-3level.h
--- v2.4.0-test10-pre2/include/asm-i386/pgtable-3level.h	Mon Dec  6 19:19:13 1999
+++ work-10-2/include/asm-i386/pgtable-3level.h	Fri Oct 13 17:39:53 2000
@@ -27,7 +27,7 @@
 #define PTRS_PER_PTE	512
 
 #define pte_ERROR(e) \
-	printk("%s:%d: bad pte %p(%016Lx).\n", __FILE__, __LINE__, &(e), pte_val(e))
+	printk("%s:%d: bad pte %p(%08lx%08lx).\n", __FILE__, __LINE__, &(e), (e).pte_high, (e).pte_low)
 #define pmd_ERROR(e) \
 	printk("%s:%d: bad pmd %p(%016Lx).\n", __FILE__, __LINE__, &(e), pmd_val(e))
 #define pgd_ERROR(e) \
@@ -45,8 +45,12 @@
 extern inline int pgd_bad(pgd_t pgd)		{ return 0; }
 extern inline int pgd_present(pgd_t pgd)	{ return !pgd_none(pgd); }
 
-#define set_pte(pteptr,pteval) \
-		set_64bit((unsigned long long *)(pteptr),pte_val(pteval))
+extern inline void set_pte(pte_t *ptep, pte_t pte)
+{
+	ptep->pte_high = pte.pte_high;
+	barrier();
+	ptep->pte_low = pte.pte_low;
+}
 #define set_pmd(pmdptr,pmdval) \
 		set_64bit((unsigned long long *)(pmdptr),pmd_val(pmdval))
 #define set_pgd(pgdptr,pgdval) \
@@ -75,5 +79,35 @@
 /* Find an entry in the second-level page table.. */
 #define pmd_offset(dir, address) ((pmd_t *) pgd_page(*(dir)) + \
 			__pmd_offset(address))
+
+#define __HAVE_ARCH_pte_get_and_clear
+extern inline pte_t pte_get_and_clear(pte_t *ptep)
+{
+	pte_t res;
+
+	/* xchg acts as a barrier before the setting of the high bits */
+	res.pte_low = xchg(&ptep->pte_low, 0);
+	res.pte_high = ptep->pte_high;
+	ptep->pte_high = 0;
+
+	return res;
+}
+
+extern inline int pte_same(pte_t a, pte_t b)
+{
+	return a.pte_low == b.pte_low && a.pte_high == b.pte_high;
+}
+
+#define pte_page(x)	(mem_map+(((x).pte_low >> PAGE_SHIFT) | ((x).pte_high << (32 - PAGE_SHIFT))))
+#define pte_none(x)	(!(x).pte_low && !(x).pte_high)
+
+extern inline pte_t __mk_pte(unsigned long page_nr, pgprot_t pgprot)
+{
+	pte_t pte;
+
+	pte.pte_high = page_nr >> (32 - PAGE_SHIFT);
+	pte.pte_low = (page_nr << PAGE_SHIFT) | pgprot_val(pgprot);
+	return pte;
+}
 
 #endif /* _I386_PGTABLE_3LEVEL_H */
diff -ur v2.4.0-test10-pre2/include/asm-i386/pgtable.h work-10-2/include/asm-i386/pgtable.h
--- v2.4.0-test10-pre2/include/asm-i386/pgtable.h	Mon Oct  2 14:06:43 2000
+++ work-10-2/include/asm-i386/pgtable.h	Fri Oct 13 17:41:26 2000
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
@@ -231,10 +245,27 @@
 extern void __handle_bad_pmd(pmd_t * pmd);
 extern void __handle_bad_pmd_kernel(pmd_t * pmd);
 
-#define pte_none(x)	(!pte_val(x))
-#define pte_present(x)	(pte_val(x) & (_PAGE_PRESENT | _PAGE_PROTNONE))
+#define pte_present(x)	((x).pte_low & (_PAGE_PRESENT | _PAGE_PROTNONE))
 #define pte_clear(xp)	do { set_pte(xp, __pte(0)); } while (0)
 
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
+#define __HAVE_ARCH_pte_clear_wrprotect
+static inline void pte_clear_wrprotect(pte_t *page_table)
+{
+	clear_bit(_PAGE_BIT_RW, page_table);
+}
+
 #define pmd_none(x)	(!pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
 #define pmd_clear(xp)	do { set_pmd(xp, __pmd(0)); } while (0)
@@ -246,49 +277,44 @@
  */
 #define page_address(page) ((page)->virtual)
 #define pages_to_mb(x) ((x) >> (20-PAGE_SHIFT))
-#define pte_page(x) (mem_map+((unsigned long)((pte_val(x) >> PAGE_SHIFT))))
 
 /*
  * The following only work if pte_present() is true.
  * Undefined behaviour if not..
  */
-extern inline int pte_read(pte_t pte)		{ return pte_val(pte) & _PAGE_USER; }
-extern inline int pte_exec(pte_t pte)		{ return pte_val(pte) & _PAGE_USER; }
-extern inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
-extern inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
-extern inline int pte_write(pte_t pte)		{ return pte_val(pte) & _PAGE_RW; }
-
-extern inline pte_t pte_rdprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_USER)); return pte; }
-extern inline pte_t pte_exprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_USER)); return pte; }
-extern inline pte_t pte_mkclean(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_DIRTY)); return pte; }
-extern inline pte_t pte_mkold(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_ACCESSED)); return pte; }
-extern inline pte_t pte_wrprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_RW)); return pte; }
-extern inline pte_t pte_mkread(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_USER)); return pte; }
-extern inline pte_t pte_mkexec(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_USER)); return pte; }
-extern inline pte_t pte_mkdirty(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_DIRTY)); return pte; }
-extern inline pte_t pte_mkyoung(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_ACCESSED)); return pte; }
-extern inline pte_t pte_mkwrite(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_RW)); return pte; }
+extern inline int pte_read(pte_t pte)		{ return (pte).pte_low & _PAGE_USER; }
+extern inline int pte_exec(pte_t pte)		{ return (pte).pte_low & _PAGE_USER; }
+extern inline int pte_dirty(pte_t pte)		{ return (pte).pte_low & _PAGE_DIRTY; }
+extern inline int pte_young(pte_t pte)		{ return (pte).pte_low & _PAGE_ACCESSED; }
+extern inline int pte_write(pte_t pte)		{ return (pte).pte_low & _PAGE_RW; }
+
+extern inline pte_t pte_rdprotect(pte_t pte)	{ (pte).pte_low &= ~_PAGE_USER; return pte; }
+extern inline pte_t pte_exprotect(pte_t pte)	{ (pte).pte_low &= ~_PAGE_USER; return pte; }
+extern inline pte_t pte_mkclean(pte_t pte)	{ (pte).pte_low &= ~_PAGE_DIRTY; return pte; }
+extern inline pte_t pte_mkold(pte_t pte)	{ (pte).pte_low &= ~_PAGE_ACCESSED; return pte; }
+extern inline pte_t pte_wrprotect(pte_t pte)	{ (pte).pte_low &= ~_PAGE_RW; return pte; }
+extern inline pte_t pte_mkread(pte_t pte)	{ (pte).pte_low |= _PAGE_USER; return pte; }
+extern inline pte_t pte_mkexec(pte_t pte)	{ (pte).pte_low |= _PAGE_USER; return pte; }
+extern inline pte_t pte_mkdirty(pte_t pte)	{ (pte).pte_low |= _PAGE_DIRTY; return pte; }
+extern inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte_low |= _PAGE_ACCESSED; return pte; }
+extern inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte_low |= _PAGE_RW; return pte; }
 
 /*
  * Conversion functions: convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
  */
 
-#define mk_pte(page,pgprot) \
-({									\
-	pte_t __pte;							\
-									\
-	set_pte(&__pte, __pte(((page)-mem_map) * 			\
-		(unsigned long long)PAGE_SIZE + pgprot_val(pgprot)));	\
-	__pte;								\
-})
+#define mk_pte(page, pgprot)	__mk_pte((page) - mem_map, (pgprot))
 
 /* This takes a physical page address that is used by the remapping functions */
-#define mk_pte_phys(physpage, pgprot) \
-({ pte_t __pte; set_pte(&__pte, __pte(physpage + pgprot_val(pgprot))); __pte; })
+#define mk_pte_phys(physpage, pgprot)	__mk_pte((physpage) >> PAGE_SHIFT, pgprot)
 
 extern inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
-{ set_pte(&pte, __pte((pte_val(pte) & _PAGE_CHG_MASK) | pgprot_val(newprot))); return pte; }
+{
+	pte.pte_low &= _PAGE_CHG_MASK;
+	pte.pte_low |= pgprot_val(newprot);
+	return pte;
+}
 
 #define page_pte(page) page_pte_prot(page, __pgprot(0))
 
@@ -324,7 +350,7 @@
 #define SWP_TYPE(x)			(((x).val >> 1) & 0x3f)
 #define SWP_OFFSET(x)			((x).val >> 8)
 #define SWP_ENTRY(type, offset)		((swp_entry_t) { ((type) << 1) | ((offset) << 8) })
-#define pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
+#define pte_to_swp_entry(pte)		((swp_entry_t) { (pte).pte_low })
 #define swp_entry_to_pte(x)		((pte_t) { (x).val })
 
 #define module_map      vmalloc
diff -ur v2.4.0-test10-pre2/include/linux/mm.h work-10-2/include/linux/mm.h
--- v2.4.0-test10-pre2/include/linux/mm.h	Tue Oct  3 13:40:38 2000
+++ work-10-2/include/linux/mm.h	Fri Oct 13 17:41:26 2000
@@ -532,6 +532,43 @@
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
+#ifndef __HAVE_ARCH_pte_get_and_clear
+static pte_t pte_get_and_clear(pte_t *page_table)
+{
+	pte_t pte = *page_table;
+	pte_clear(page_table);
+	return pte;
+}
+#endif
+
+#ifndef __HAVE_ARCH_pte_clear_wrprotect
+static inline void pte_clear_wrprotect(pte_t *page_table)
+{
+	pte_t old_pte = *page_table;
+	set_pte(page_table, pte_wrprotect(old_pte));
+}
+#endif
+
 #endif /* __KERNEL__ */
 
 #endif
diff -ur v2.4.0-test10-pre2/mm/filemap.c work-10-2/mm/filemap.c
--- v2.4.0-test10-pre2/mm/filemap.c	Tue Oct  3 13:40:38 2000
+++ work-10-2/mm/filemap.c	Fri Oct 13 17:19:47 2000
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
+		pte = pte_get_and_clear(ptep);
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
 
diff -ur v2.4.0-test10-pre2/mm/highmem.c work-10-2/mm/highmem.c
--- v2.4.0-test10-pre2/mm/highmem.c	Fri Oct 13 17:18:37 2000
+++ work-10-2/mm/highmem.c	Fri Oct 13 17:19:47 2000
@@ -130,10 +130,9 @@
 		if (pkmap_count[i] != 1)
 			continue;
 		pkmap_count[i] = 0;
-		pte = pkmap_page_table[i];
+		pte = pte_get_and_clear(pkmap_page_table+i);
 		if (pte_none(pte))
 			BUG();
-		pte_clear(pkmap_page_table+i);
 		page = pte_page(pte);
 		page->virtual = NULL;
 	}
diff -ur v2.4.0-test10-pre2/mm/memory.c work-10-2/mm/memory.c
--- v2.4.0-test10-pre2/mm/memory.c	Tue Oct  3 13:40:38 2000
+++ work-10-2/mm/memory.c	Fri Oct 13 17:19:47 2000
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
+					pte_clear_wrprotect(src_pte);
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
+		page = pte_get_and_clear(pte);
 		pte++;
 		size--;
-		pte_clear(pte-1);
 		if (pte_none(page))
 			continue;
 		freed += free_pte(page);
@@ -642,7 +641,7 @@
 		end = PMD_SIZE;
 	do {
 		pte_t zero_pte = pte_wrprotect(mk_pte(ZERO_PAGE(address), prot));
-		pte_t oldpage = *pte;
+		pte_t oldpage = pte_get_and_clear(pte);
 		set_pte(pte, zero_pte);
 		forget_pte(oldpage);
 		address += PAGE_SIZE;
@@ -712,8 +711,8 @@
 		end = PMD_SIZE;
 	do {
 		struct page *page;
-		pte_t oldpage = *pte;
-		pte_clear(pte);
+		pte_t oldpage;
+		oldpage = pte_get_and_clear(pte);
 
 		page = virt_to_page(__va(phys_addr));
 		if ((!VALID_PAGE(page)) || PageReserved(page))
@@ -746,6 +745,7 @@
 	return 0;
 }
 
+/*  Note: this is only safe if the mm semaphore is held when called. */
 int remap_page_range(unsigned long from, unsigned long phys_addr, unsigned long size, pgprot_t prot)
 {
 	int error = 0;
@@ -867,7 +867,7 @@
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	if (pte_val(*page_table) == pte_val(pte)) {
+	if (pte_same(*page_table, pte)) {
 		if (PageReserved(old_page))
 			++mm->rss;
 		break_cow(vma, old_page, new_page, address, page_table);
@@ -1214,7 +1214,7 @@
 	 * didn't change from under us..
 	 */
 	spin_lock(&mm->page_table_lock);
-	if (pte_val(entry) == pte_val(*pte)) {
+	if (pte_same(entry, *pte)) {
 		if (write_access) {
 			if (!pte_write(entry))
 				return do_wp_page(mm, vma, address, pte, entry);
diff -ur v2.4.0-test10-pre2/mm/mprotect.c work-10-2/mm/mprotect.c
--- v2.4.0-test10-pre2/mm/mprotect.c	Tue Mar 14 20:45:21 2000
+++ work-10-2/mm/mprotect.c	Fri Oct 13 17:19:47 2000
@@ -30,9 +30,16 @@
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
 	do {
-		pte_t entry = *pte;
-		if (pte_present(entry))
+		if (pte_present(*pte)) {
+			pte_t entry;
+
+			/* Avoid an SMP race with hardware updated dirty/clean
+			 * bits by wiping the pte and then setting the new pte
+			 * into place.
+			 */
+			entry = pte_get_and_clear(pte);
 			set_pte(pte, pte_modify(entry, newprot));
+		}
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
diff -ur v2.4.0-test10-pre2/mm/mremap.c work-10-2/mm/mremap.c
--- v2.4.0-test10-pre2/mm/mremap.c	Tue Oct  3 13:40:38 2000
+++ work-10-2/mm/mremap.c	Fri Oct 13 17:19:47 2000
@@ -63,14 +63,14 @@
 	pte_t pte;
 
 	spin_lock(&mm->page_table_lock);
-	pte = *src;
+	pte = pte_get_and_clear(src);
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
diff -ur v2.4.0-test10-pre2/mm/swapfile.c work-10-2/mm/swapfile.c
--- v2.4.0-test10-pre2/mm/swapfile.c	Tue Aug  8 00:01:36 2000
+++ work-10-2/mm/swapfile.c	Fri Oct 13 17:19:47 2000
@@ -223,10 +223,11 @@
 		if (pte_page(pte) != page)
 			return;
 		/* We will be removing the swap cache in a moment, so... */
+		pte = pte_get_and_clear(dir);
 		set_pte(dir, pte_mkdirty(pte));
 		return;
 	}
-	if (pte_val(pte) != entry.val)
+	if (pte_to_swp_entry(pte).val != entry.val)
 		return;
 	set_pte(dir, pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 	swap_free(entry);
diff -ur v2.4.0-test10-pre2/mm/vmalloc.c work-10-2/mm/vmalloc.c
--- v2.4.0-test10-pre2/mm/vmalloc.c	Fri Oct 13 17:18:37 2000
+++ work-10-2/mm/vmalloc.c	Fri Oct 13 17:19:47 2000
@@ -34,8 +34,8 @@
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
 	do {
-		pte_t page = *pte;
-		pte_clear(pte);
+		pte_t page;
+		page = pte_get_and_clear(pte);
 		address += PAGE_SIZE;
 		pte++;
 		if (pte_none(page))
diff -ur v2.4.0-test10-pre2/mm/vmscan.c work-10-2/mm/vmscan.c
--- v2.4.0-test10-pre2/mm/vmscan.c	Fri Oct 13 17:18:37 2000
+++ work-10-2/mm/vmscan.c	Fri Oct 13 17:19:47 2000
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
+	pte = pte_get_and_clear(page_table);
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
@@ -191,7 +200,7 @@
 	 */
 	entry = get_swap_page();
 	if (!entry.val)
-		goto out_unlock; /* No swap space left */
+		goto out_unlock_restore; /* No swap space left */
 
 	if (!(page = prepare_highmem_swapout(page)))
 		goto out_swap_free;
@@ -215,10 +224,12 @@
 	page_cache_release(page);
 	return 1;
 out_swap_free:
+	set_pte(page_table, pte);
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
