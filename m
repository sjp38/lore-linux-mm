Received: from localhost (localhost [127.0.0.1])
	by baldur.austin.ibm.com (8.12.6/8.12.6/Debian-3) with ESMTP id g86HK8Hf024529
	for <linux-mm@kvack.org>; Fri, 6 Sep 2002 12:20:08 -0500
Date: Fri, 06 Sep 2002 12:20:08 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Rough cut at shared page tables
Message-ID: <61920000.1031332808@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========908850887=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========908850887==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Here's my initial coding of shared page tables.  It sets the pmd read-only,
so it forks really fast, then unshares it as necessary.  I've tried to keep
the sharing semantics clean so if/when we add pte sharing for shared files
the existing code should handle it just fine.

The few feeble attempts I've made at putting in locks are clearly wrong, so
it only works on UP.

I don't see any reason why swap won't work, but I haven't tested it.

This is also against 2.5.29.  I'm gonna work to merge it forward, but there
are significant changes since then so I figured I'd toss this out for
people to get an early look at it.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========908850887==========
Content-Type: text/plain; charset=iso-8859-1; name="shpte-2.5.29-1.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="shpte-2.5.29-1.diff"; size=20824

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or =
higher.
# This patch includes the following deltas:
#	           ChangeSet	1.511   -> 1.513 =20
#	include/asm-i386/pgalloc.h	1.16    -> 1.17  =20
#	       kernel/fork.c	1.55    -> 1.56  =20
#	            Makefile	1.282   -> 1.283 =20
#	         init/main.c	1.59    -> 1.60  =20
#	         mm/memory.c	1.77    -> 1.79  =20
#	include/asm-generic/rmap.h	1.2     -> 1.3   =20
#	include/asm-i386/pgtable.h	1.17    -> 1.18  =20
#	           mm/rmap.c	1.6     -> 1.7   =20
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/08/28	dmc@baldur.austin.ibm.com	1.512
# Initial changes for shared page tables (non-working)
# --------------------------------------------
# 02/09/06	dmc@baldur.austin.ibm.com	1.513
# Snapshot to send out.
# --------------------------------------------
#
diff -Nru a/Makefile b/Makefile
--- a/Makefile	Fri Sep  6 12:11:08 2002
+++ b/Makefile	Fri Sep  6 12:11:08 2002
@@ -1,7 +1,7 @@
 VERSION =3D 2
 PATCHLEVEL =3D 5
 SUBLEVEL =3D 29
-EXTRAVERSION =3D
+EXTRAVERSION =3D-shpte
=20
 # *DOCUMENTATION*
 # Too see a list of typical targets execute "make help"
diff -Nru a/include/asm-generic/rmap.h b/include/asm-generic/rmap.h
--- a/include/asm-generic/rmap.h	Fri Sep  6 12:11:08 2002
+++ b/include/asm-generic/rmap.h	Fri Sep  6 12:11:08 2002
@@ -16,27 +16,6 @@
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
 static inline struct mm_struct * ptep_to_mm(pte_t * ptep)
 {
 	struct page * page =3D virt_to_page(ptep);
@@ -50,5 +29,9 @@
 	low_bits =3D ((unsigned long)ptep & ~PAGE_MASK) * PTRS_PER_PTE;
 	return page->index + low_bits;
 }
+
+extern void pgtable_add_rmap(struct page * page, struct mm_struct * mm, =
unsigned long address);
+extern void pgtable_remove_rmap(struct page * page, struct mm_struct *mm);
+
=20
 #endif /* _GENERIC_RMAP_H */
diff -Nru a/include/asm-i386/pgalloc.h b/include/asm-i386/pgalloc.h
--- a/include/asm-i386/pgalloc.h	Fri Sep  6 12:11:08 2002
+++ b/include/asm-i386/pgalloc.h	Fri Sep  6 12:11:08 2002
@@ -16,6 +16,13 @@
 		((unsigned long long)(pte - mem_map) <<
 			(unsigned long long) PAGE_SHIFT)));
 }
+
+static inline void pmd_populate_rdonly(struct mm_struct *mm, pmd_t *pmd, =
struct page *pte)
+{
+	set_pmd(pmd, __pmd(_PAGE_TABLE_RDONLY +
+		((unsigned long long)(pte - mem_map) <<
+			(unsigned long long) PAGE_SHIFT)));
+}
 /*
  * Allocate and free page tables.
  */
diff -Nru a/include/asm-i386/pgtable.h b/include/asm-i386/pgtable.h
--- a/include/asm-i386/pgtable.h	Fri Sep  6 12:11:08 2002
+++ b/include/asm-i386/pgtable.h	Fri Sep  6 12:11:08 2002
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
@@ -262,6 +265,10 @@
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
diff -Nru a/init/main.c b/init/main.c
--- a/init/main.c	Fri Sep  6 12:11:08 2002
+++ b/init/main.c	Fri Sep  6 12:11:08 2002
@@ -529,7 +529,9 @@
 	extern int migration_init(void);
 	extern int spawn_ksoftirqd(void);
=20
+#if CONFIG_SMP
 	migration_init();
+#endif
 	spawn_ksoftirqd();
 }
=20
diff -Nru a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c	Fri Sep  6 12:11:08 2002
+++ b/kernel/fork.c	Fri Sep  6 12:11:08 2002
@@ -183,6 +183,7 @@
 	struct vm_area_struct * mpnt, *tmp, **pprev;
 	int retval;
 	unsigned long charge =3D 0;
+	pmd_t *prev_pmd =3D 0;
=20
 	flush_cache_mm(current->mm);
 	mm->locked_vm =3D 0;
@@ -249,7 +250,7 @@
 		*pprev =3D tmp;
 		pprev =3D &tmp->vm_next;
 		mm->map_count++;
-		retval =3D copy_page_range(mm, current->mm, tmp);
+		retval =3D share_page_range(mm, current->mm, tmp, &prev_pmd);
 		spin_unlock(&mm->page_table_lock);
=20
 		if (tmp->vm_ops && tmp->vm_ops->open)
diff -Nru a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c	Fri Sep  6 12:11:08 2002
+++ b/mm/memory.c	Fri Sep  6 12:11:08 2002
@@ -92,7 +92,7 @@
 	}
 	page =3D pmd_page(*dir);
 	pmd_clear(dir);
-	pgtable_remove_rmap(page);
+	pgtable_remove_rmap(page, tlb->mm);
 	pte_free_tlb(tlb, page);
 }
=20
@@ -134,6 +134,154 @@
 	} while (--nr);
 }
=20
+static inline int pte_needs_unshare(struct mm_struct *mm, struct =
vm_area_struct *vma,
+				    pmd_t *pmd, unsigned long address, int write_access)
+{
+	struct page *page;
+
+	/* It's not even there */
+	if (!pmd_present(*pmd))
+		return 0;
+
+	/* If it's already writable, then it doesn't need to be unshared. */
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
+	page =3D pmd_page(*pmd);
+	if (((vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) =3D=3D VM_MAYWRITE)
+	    && (vma->vm_start <=3D page->index)
+	    && (vma->vm_end >=3D (page->index + PGDIR_SIZE)))
+		return 0;
+
+	return 1;
+}
+
+static spinlock_t pte_share_lock =3D SPIN_LOCK_UNLOCKED;
+
+static pte_t *pte_unshare(struct mm_struct *mm, pmd_t *pmd, unsigned long =
address)
+{
+	pte_t	*src_ptb, *dst_ptb;
+	struct page *oldpage, *newpage;
+	struct vm_area_struct *vma;
+	int	base, addr;
+	int	end, page_end;
+	int	src_unshare;
+
+	oldpage =3D pmd_page(*pmd);
+	/* If it's already unshared, we just need to set it writeable */
+	if (page_count(oldpage) =3D=3D 1) {
+		pmd_populate(mm, pmd, oldpage);
+		flush_tlb_mm(mm);
+		goto out;
+	}
+
+	base =3D addr =3D oldpage->index;
+	page_end =3D base + PGDIR_SIZE;
+	vma =3D find_vma(mm, base);
+	if (!vma || (page_end <=3D vma->vm_start))
+		BUG(); 		/* No valid pages in this pte page */
+
+	spin_unlock(&mm->page_table_lock);
+	newpage =3D pte_alloc_one(mm, address);
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!newpage))
+		return NULL;
+
+	spin_lock(&pte_share_lock);
+
+	/* See if it got unshared while we dropped the lock */
+	oldpage =3D pmd_page(*pmd);
+	if (page_count(oldpage) =3D=3D 1) {
+		pte_free(newpage);
+		goto out;
+	}
+
+	src_unshare =3D page_count(oldpage) =3D=3D 2;
+	src_ptb =3D pte_page_map(oldpage, base);
+	dst_ptb =3D pte_page_map_nested(newpage, base);
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
+
+			if (!pte_none(pte)) {
+				if (pte_present(pte)) {
+					struct page *page =3D pte_page(pte);
+
+					if (!PageReserved(page)) {
+						get_page(page);
+						pte =3D pte_mkold(pte_mkclean(pte));
+						page_add_rmap(page, dst_pte);
+						mm->rss++;
+						if (cow) {
+							pte =3D pte_wrprotect(pte);
+							if (src_unshare)
+								set_pte(src_pte, pte);
+						}
+					}
+				} else
+					swap_duplicate(pte_to_swp_entry(pte));
+
+				set_pte(dst_pte, pte);
+			}
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
+	pte_unmap_nested(dst_ptb);
+	pte_unmap(src_ptb);
+
+	pgtable_remove_rmap(oldpage, mm);
+	pgtable_add_rmap(newpage, mm, base);
+	pmd_populate(mm, pmd, newpage);
+
+	flush_tlb_mm(mm);
+
+	spin_unlock(&pte_share_lock);
+
+	put_page(oldpage);
+
+out:
+	return pte_offset_map(pmd, address);
+}
+
 pte_t * pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long =
address)
 {
 	if (!pmd_present(*pmd)) {
@@ -157,9 +305,7 @@
 		pmd_populate(mm, pmd, new);
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
@@ -181,7 +327,6 @@
 			pte_free_kernel(new);
 			goto out;
 		}
-		pgtable_add_rmap(virt_to_page(new), mm, address);
 		pmd_populate_kernel(mm, pmd, new);
 	}
 out:
@@ -190,6 +335,84 @@
 #define PTE_TABLE_MASK	((PTRS_PER_PTE-1) * sizeof(pte_t))
 #define PMD_TABLE_MASK	((PTRS_PER_PMD-1) * sizeof(pmd_t))
=20
+int share_page_range(struct mm_struct *dst, struct mm_struct *src,
+	struct vm_area_struct *vma, pmd_t **prev_pmd)
+{
+	pgd_t *src_pgd, *dst_pgd;
+	unsigned long address =3D vma->vm_start;
+	unsigned long end =3D vma->vm_end;
+	unsigned long cow =3D (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) =3D=3D =
VM_MAYWRITE;
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
+		/* We did this one already */
+		if (src_pmd =3D=3D *prev_pmd)
+			goto skip_share_pte_range;
+
+		do {
+			pmd_t	pmdval =3D *src_pmd;
+			struct page *page =3D pmd_page(pmdval);
+
+			if (pmd_none(pmdval))
+				goto skip_share_pte_range;
+			if (pmd_bad(pmdval)) {
+				pmd_ERROR(*src_pmd);
+				pmd_clear(src_pmd);
+				goto skip_share_pte_range;
+			}
+
+			get_page(page);
+
+			if (cow) {
+				pmdval =3D pmd_wrprotect(pmdval);
+				set_pmd(src_pmd, pmdval);
+			}
+			set_pmd(dst_pmd, pmdval);
+			pgtable_add_rmap(page, dst, address);
+			*prev_pmd =3D src_pmd;
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
+	return -ENOMEM;
+}
 /*
  * copy one vm_area from one task to the other. Assumes the page tables
  * already present in the new task to be cleared in the whole range
@@ -321,6 +544,7 @@
=20
 static void zap_pte_range(mmu_gather_t *tlb, pmd_t * pmd, unsigned long =
address, unsigned long size)
 {
+	struct page *page;
 	unsigned long offset;
 	pte_t *ptep;
=20
@@ -331,11 +555,30 @@
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
+	page =3D pmd_page(*pmd);
+	if (page_count(page) > 1) {
+		if ((offset =3D=3D 0) && (size =3D=3D PMD_SIZE)) {
+			pmd_clear(pmd);
+			pgtable_remove_rmap(page, tlb->mm);
+			put_page(page);
+			return;
+		}
+		ptep =3D pte_unshare(tlb->mm, pmd, address);
+	} else {
+		ptep =3D pte_offset_map(pmd, address);
+	}
 	for (offset=3D0; offset < size; ptep++, offset +=3D PAGE_SIZE) {
 		pte_t pte =3D *ptep;
 		if (pte_none(pte))
@@ -432,6 +675,19 @@
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
  * Do a quick page-table lookup for a single page.=20
  */
@@ -1430,7 +1686,13 @@
 	pmd =3D pmd_alloc(mm, pgd, address);
=20
 	if (pmd) {
-		pte_t * pte =3D pte_alloc_map(mm, pmd, address);
+		pte_t * pte;
+
+		if (pte_needs_unshare(mm, vma, pmd, address, write_access))
+			pte =3D pte_unshare(mm, pmd, address);
+		else
+			pte =3D pte_alloc_map(mm, pmd, address);
+
 		if (pte)
 			return handle_pte_fault(mm, vma, address, write_access, pte, pmd);
 	}
diff -Nru a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c	Fri Sep  6 12:11:08 2002
+++ b/mm/rmap.c	Fri Sep  6 12:11:08 2002
@@ -52,6 +52,8 @@
 	pte_t * ptep;
 };
=20
+spinlock_t mm_ugly_global_lock;
+
 static kmem_cache_t	*pte_chain_cache;
 static inline struct pte_chain * pte_chain_alloc(void);
 static inline void pte_chain_free(struct pte_chain *, struct pte_chain *,
@@ -86,6 +88,73 @@
 	return referenced;
 }
=20
+void pgtable_add_rmap(struct page * page, struct mm_struct * mm, unsigned =
long address)
+{
+	struct pte_chain * pte_chain;
+
+#ifdef BROKEN_PPC_PTE_ALLOC_ONE
+	/* OK, so PPC calls pte_alloc() before mem_map[] is setup ... ;( */
+	extern int mem_init_done;
+
+	if (!mem_init_done)
+		return;
+#endif
+	pte_chain_lock(page);
+
+	if (PageDirect(page)) {
+		pte_chain =3D pte_chain_alloc();
+		pte_chain->ptep =3D page->pte.direct;
+		pte_chain->next =3D NULL;
+		page->pte.chain =3D pte_chain;
+		ClearPageDirect(page);
+	}
+	if (page->pte.chain) {
+		/* Hook up the pte_chain to the page. */
+		pte_chain =3D pte_chain_alloc();
+		pte_chain->ptep =3D (void *)mm;
+		pte_chain->next =3D page->pte.chain;
+		page->pte.chain =3D pte_chain;
+	} else {
+		page->pte.direct =3D (void *)mm;
+		SetPageDirect(page);
+		page->index =3D address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
+	}
+	pte_chain_unlock(page);
+	inc_page_state(nr_page_table_pages);
+}
+
+void pgtable_remove_rmap(struct page * page, struct mm_struct *mm)
+{
+	struct pte_chain * pc, * prev_pc =3D NULL;
+
+	pte_chain_lock(page);
+
+	if (PageDirect(page)) {
+		if (page->pte.direct =3D=3D (void *)mm) {
+			page->pte.direct =3D NULL;
+			ClearPageDirect(page);
+			page->index =3D 0;
+		}
+	} else {
+		for (pc =3D page->pte.chain; pc; prev_pc =3D pc, pc =3D pc->next) {
+			if (pc->ptep =3D=3D (void *)mm) {
+				pte_chain_free(pc, prev_pc, page);
+				/* Check whether we can convert to direct */
+				pc =3D page->pte.chain;
+				if (!pc->next) {
+					page->pte.direct =3D pc->ptep;
+					SetPageDirect(page);
+					pte_chain_free(pc, NULL, NULL);
+				}
+				goto out;
+			}
+		}
+	}
+out:
+	pte_chain_unlock(page);
+	dec_page_state(nr_page_table_pages);
+}
+
 /**
  * page_add_rmap - add reverse mapping entry to a page
  * @page: the page to add the mapping to
@@ -218,6 +287,81 @@
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
+static inline int pgtable_check_mlocked(pte_t *ptep)
+{
+	struct page *page =3D virt_to_page(ptep);
+	unsigned long address =3D ptep_to_address(ptep);
+	struct pte_chain *pc;
+	int ret =3D SWAP_SUCCESS;
+
+	if (PageDirect(page))
+		return pgtable_check_mlocked_mm((void *)page->pte.direct, address);
+
+	for (pc =3D page->pte.chain; pc; pc =3D pc->next) {
+		ret =3D pgtable_check_mlocked_mm((void *)pc->ptep, address);
+		if (ret !=3D SWAP_SUCCESS)
+			break;
+	}
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
+static inline int pgtable_unmap_one(pte_t *ptep)
+{
+	struct page *page =3D virt_to_page(ptep);
+	unsigned long address =3D ptep_to_address(ptep);
+	struct pte_chain *pc;
+	int ret =3D SWAP_SUCCESS;
+
+	if (PageDirect(page))
+		return pgtable_unmap_one_mm((void *)page->pte.direct, address);
+
+	for (pc =3D page->pte.chain; pc; pc =3D pc->next) {
+		ret =3D pgtable_unmap_one_mm((void *)pc->ptep, address);
+		if (ret !=3D SWAP_SUCCESS)
+			break;
+	}
+	return ret;
+}
+
 /**
  * try_to_unmap_one - worker function for try_to_unmap
  * @page: page to unmap
@@ -235,40 +379,20 @@
 static int FASTCALL(try_to_unmap_one(struct page *, pte_t *));
 static int try_to_unmap_one(struct page * page, pte_t * ptep)
 {
-	unsigned long address =3D ptep_to_address(ptep);
-	struct mm_struct * mm =3D ptep_to_mm(ptep);
-	struct vm_area_struct * vma;
 	pte_t pte;
 	int ret;
=20
-	if (!mm)
-		BUG();
-
-	/*
-	 * We need the page_table_lock to protect us from page faults,
-	 * munmap, fork, etc...
-	 */
-	if (!spin_trylock(&mm->page_table_lock))
-		return SWAP_AGAIN;
+	ret =3D pgtable_check_mlocked(ptep);
+	if (ret !=3D SWAP_SUCCESS)
+		goto out;
=20
-	/* During mremap, it's possible pages are not in a VMA. */
-	vma =3D find_vma(mm, address);
-	if (!vma) {
-		ret =3D SWAP_FAIL;
-		goto out_unlock;
-	}
-
-	/* The page is mlock()d, we cannot swap it out. */
-	if (vma->vm_flags & VM_LOCKED) {
-		ret =3D SWAP_FAIL;
-		goto out_unlock;
-	}
-
-	/* Nuke the page table entry. */
 	pte =3D ptep_get_and_clear(ptep);
-	flush_tlb_page(vma, address);
-	flush_cache_page(vma, address);
=20
+	ret =3D pgtable_unmap_one(ptep);
+	if (ret !=3D SWAP_SUCCESS) {
+		set_pte(ptep, pte);
+		goto out;
+	}
 	/* Store the swap location in the pte. See handle_pte_fault() ... */
 	if (PageSwapCache(page)) {
 		swp_entry_t entry;
@@ -281,12 +405,10 @@
 	if (pte_dirty(pte))
 		set_page_dirty(page);
=20
-	mm->rss--;
 	page_cache_release(page);
 	ret =3D SWAP_SUCCESS;
=20
-out_unlock:
-	spin_unlock(&mm->page_table_lock);
+out:
 	return ret;
 }
=20
@@ -317,6 +439,7 @@
 	if (!page->mapping)
 		BUG();
=20
+	spin_lock(&mm_ugly_global_lock);
 	if (PageDirect(page)) {
 		ret =3D try_to_unmap_one(page, page->pte.direct);
 		if (ret =3D=3D SWAP_SUCCESS) {
@@ -338,12 +461,13 @@
 					continue;
 				case SWAP_FAIL:
 					ret =3D SWAP_FAIL;
-					break;
+					goto check_direct;
 				case SWAP_ERROR:
 					ret =3D SWAP_ERROR;
-					break;
+					goto check_direct;
 			}
 		}
+check_direct:
 		/* Check whether we can convert to direct pte pointer */
 		pc =3D page->pte.chain;
 		if (pc && !pc->next) {
@@ -352,6 +476,7 @@
 			pte_chain_free(pc, NULL, NULL);
 		}
 	}
+	spin_unlock(&mm_ugly_global_lock);
 	return ret;
 }
=20
@@ -397,6 +522,8 @@
=20
 void __init pte_chain_init(void)
 {
+	spin_lock_init(&mm_ugly_global_lock);
+
 	pte_chain_cache =3D kmem_cache_create(	"pte_chain",
 						sizeof(struct pte_chain),
 						0,

--==========908850887==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
