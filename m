Received: from localhost (localhost [127.0.0.1])
	by baldur.austin.ibm.com (8.12.7/8.12.7/Debian-2) with ESMTP id h1KGDVv4029428
	for <linux-mm@kvack.org>; Thu, 20 Feb 2003 10:13:31 -0600
Date: Thu, 20 Feb 2003 10:13:31 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH 2.5.62] Partial object-based rmap implementation
Message-ID: <8390000.1045757611@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1812679384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========1812679384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


There's been a fair amount of discussion about the advantages of doing
object-based rmap.  I've been looking into it, and we have the pieces to do
it for file-backed objects, ie the ones that have a real address_space
object pointed to from struct page.  The stumbling block has always been
anonymous pages.

At Martin Bligh's suggestion, I coded up an object-based implementation for
non-anon pages while leaving the pte_chain code intact for anon pages.  My
fork/exit microbenchmark shows roughly 50% improvement for tasks that are
composes of file-backed and/or shared pages.  This is the code that Martin
included in 2.5.62-mjb2 and reported his performance results on.

Anyway, here's the patch if anyone wants to check it out.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1812679384==========
Content-Type: text/plain; charset=iso-8859-1; name="objrmap-2.5.62-3.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="objrmap-2.5.62-3.diff"; size=8907

--- 2.5.62/./include/linux/mm.h	2003-02-17 16:55:50.000000000 -0600
+++ 2.5.62-objrmap/./include/linux/mm.h	2003-02-19 12:00:47.000000000 -0600
@@ -171,6 +171,7 @@
 		struct pte_chain *chain;/* Reverse pte mapping pointer.
 					 * protected by PG_chainlock */
 		pte_addr_t direct;
+		atomic_t mapcount;
 	} pte;
 	unsigned long private;		/* mapping-private opaque data */
=20
--- 2.5.62/./include/linux/page-flags.h	2003-02-17 16:56:25.000000000 -0600
+++ 2.5.62-objrmap/./include/linux/page-flags.h	2003-02-18 =
10:22:26.000000000 -0600
@@ -74,6 +74,7 @@
 #define PG_mappedtodisk		17	/* Has blocks allocated on-disk */
 #define PG_reclaim		18	/* To be reclaimed asap */
 #define PG_compound		19	/* Part of a compound page */
+#define PG_anon			20	/* Anonymous page */
=20
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -256,6 +257,10 @@
 #define SetPageCompound(page)	set_bit(PG_compound, &(page)->flags)
 #define ClearPageCompound(page)	clear_bit(PG_compound, &(page)->flags)
=20
+#define PageAnon(page)		test_bit(PG_anon, &(page)->flags)
+#define SetPageAnon(page)	set_bit(PG_anon, &(page)->flags)
+#define ClearPageAnon(page)	clear_bit(PG_anon, &(page)->flags)
+
 /*
  * The PageSwapCache predicate doesn't use a PG_flag at this time,
  * but it may again do so one day.
--- 2.5.62/./fs/exec.c	2003-02-17 16:56:12.000000000 -0600
+++ 2.5.62-objrmap/./fs/exec.c	2003-02-18 11:46:33.000000000 -0600
@@ -316,6 +316,7 @@
 	lru_cache_add_active(page);
 	flush_dcache_page(page);
 	flush_page_to_ram(page);
+	SetPageAnon(page);
 	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(page, PAGE_COPY))));
 	pte_chain =3D page_add_rmap(page, pte, pte_chain);
 	pte_unmap(pte);
--- 2.5.62/./mm/page_alloc.c	2003-02-17 16:55:51.000000000 -0600
+++ 2.5.62-objrmap/./mm/page_alloc.c	2003-02-18 10:22:26.000000000 -0600
@@ -220,6 +220,8 @@
 		bad_page(function, page);
 	if (PageDirty(page))
 		ClearPageDirty(page);
+	if (PageAnon(page))
+		ClearPageAnon(page);
 }
=20
 /*
--- 2.5.62/./mm/swapfile.c	2003-02-17 16:56:01.000000000 -0600
+++ 2.5.62-objrmap/./mm/swapfile.c	2003-02-19 16:39:24.000000000 -0600
@@ -390,6 +390,7 @@
 		return;
 	get_page(page);
 	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
+	SetPageAnon(page);
 	*pte_chainp =3D page_add_rmap(page, dir, *pte_chainp);
 	swap_free(entry);
 	++vma->vm_mm->rss;
--- 2.5.62/./mm/memory.c	2003-02-17 16:56:14.000000000 -0600
+++ 2.5.62-objrmap/./mm/memory.c	2003-02-18 10:22:26.000000000 -0600
@@ -988,6 +988,7 @@
 			++mm->rss;
 		page_remove_rmap(old_page, page_table);
 		break_cow(vma, new_page, address, page_table);
+		SetPageAnon(new_page);
 		pte_chain =3D page_add_rmap(new_page, page_table, pte_chain);
 		lru_cache_add_active(new_page);
=20
@@ -1197,6 +1198,7 @@
 	flush_page_to_ram(page);
 	flush_icache_page(vma, page);
 	set_pte(page_table, pte);
+	SetPageAnon(page);
 	pte_chain =3D page_add_rmap(page, page_table, pte_chain);
=20
 	/* No need to invalidate - it was non-present before */
@@ -1263,6 +1265,7 @@
 		entry =3D pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 		lru_cache_add_active(page);
 		mark_page_accessed(page);
+		SetPageAnon(page);
 	}
=20
 	set_pte(page_table, entry);
@@ -1334,6 +1337,7 @@
 		copy_user_highpage(page, new_page, address);
 		page_cache_release(new_page);
 		lru_cache_add_active(page);
+		SetPageAnon(page);
 		new_page =3D page;
 	}
=20
--- 2.5.62/./mm/rmap.c	2003-02-17 16:56:58.000000000 -0600
+++ 2.5.62-objrmap/./mm/rmap.c	2003-02-19 12:05:48.000000000 -0600
@@ -86,6 +86,89 @@
  * If the page has a single-entry pte_chain, collapse that back to a =
PageDirect
  * representation.  This way, it's only done under memory pressure.
  */
+static inline int
+page_referenced_obj_one(struct vm_area_struct *vma, struct page *page)
+{
+	struct mm_struct *mm =3D vma->vm_mm;
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+	unsigned long loffset;
+	unsigned long address;
+	int referenced =3D 0;
+
+	loffset =3D (page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT));
+	if (loffset < vma->vm_pgoff)
+		goto out;
+
+	address =3D vma->vm_start + ((loffset - vma->vm_pgoff) << PAGE_SHIFT);
+
+	if (address >=3D vma->vm_end)
+		goto out;
+
+	if (!spin_trylock(&mm->page_table_lock)) {
+		referenced =3D 1;
+		goto out;
+	}
+	pgd =3D pgd_offset(mm, address);
+	if (!pgd_present(*pgd)) {
+		goto out_unlock;
+	}
+	pmd =3D pmd_offset(pgd, address);
+	if (!pmd_present(*pmd)) {
+		goto out_unlock;
+	}
+	pte =3D pte_offset_map(pmd, address);
+	if (!pte_present(*pte)) {
+		goto out_unmap;
+	}
+	if (page_to_pfn(page) !=3D pte_pfn(*pte)) {
+		goto out_unmap;
+	}
+	if (ptep_test_and_clear_young(pte))
+		referenced++;
+out_unmap:
+	pte_unmap(pte);
+
+out_unlock:
+	spin_unlock(&mm->page_table_lock);
+
+out:
+	return referenced;
+}
+
+static int
+page_referenced_obj(struct page *page)
+{
+	struct address_space *mapping =3D page->mapping;
+	struct vm_area_struct *vma;
+	int referenced =3D 0;
+
+	if (atomic_read(&page->pte.mapcount) =3D=3D 0)
+		return 0;
+
+	if (!mapping)
+		BUG();
+
+	if (PageSwapCache(page))
+		BUG();
+
+	if (down_trylock(&mapping->i_shared_sem))
+		return 1;
+	
+	list_for_each_entry(vma, &mapping->i_mmap, shared) {
+		referenced +=3D page_referenced_obj_one(vma, page);
+	}
+
+	list_for_each_entry(vma, &mapping->i_mmap_shared, shared) {
+		referenced +=3D page_referenced_obj_one(vma, page);
+	}
+
+	up(&mapping->i_shared_sem);
+
+	return referenced;
+}
+
 int page_referenced(struct page * page)
 {
 	struct pte_chain * pc;
@@ -94,6 +177,10 @@
 	if (TestClearPageReferenced(page))
 		referenced++;
=20
+	if (!PageAnon(page)) {
+		referenced +=3D page_referenced_obj(page);
+		goto out;
+	}
 	if (PageDirect(page)) {
 		pte_t *pte =3D rmap_ptep_map(page->pte.direct);
 		if (ptep_test_and_clear_young(pte))
@@ -127,6 +214,7 @@
 			__pte_chain_free(pc);
 		}
 	}
+out:
 	return referenced;
 }
=20
@@ -157,6 +245,15 @@
 	if (!pfn_valid(page_to_pfn(page)) || PageReserved(page))
 		return pte_chain;
=20
+	if (!PageAnon(page)) {
+		if (!page->mapping)
+			BUG();
+		if (PageSwapCache(page))
+			BUG();
+		atomic_inc(&page->pte.mapcount);
+		return pte_chain;
+	}
+
 	pte_chain_lock(page);
=20
 #ifdef DEBUG_RMAP
@@ -245,6 +342,17 @@
 	if (!page_mapped(page))
 		return;		/* remap_page_range() from a driver? */
=20
+	if (!PageAnon(page)) {
+		if (!page->mapping)
+			BUG();
+		if (PageSwapCache(page))
+			BUG();
+		if (atomic_read(&page->pte.mapcount) =3D=3D 0)
+			BUG();
+		atomic_dec(&page->pte.mapcount);
+		return;
+	}
+
 	pte_chain_lock(page);
=20
 	if (PageDirect(page)) {
@@ -310,6 +418,112 @@
 	return;
 }
=20
+static inline int
+try_to_unmap_obj_one(struct vm_area_struct *vma, struct page *page)
+{
+	struct mm_struct *mm =3D vma->vm_mm;
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+	pte_t pteval;
+	unsigned long loffset;
+	unsigned long address;
+	int ret =3D SWAP_SUCCESS;
+
+	loffset =3D (page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT));
+	if (loffset < vma->vm_pgoff)
+		goto out;
+
+	address =3D vma->vm_start + ((loffset - vma->vm_pgoff) << PAGE_SHIFT);
+
+	if (address >=3D vma->vm_end)
+		goto out;
+
+	if (!spin_trylock(&mm->page_table_lock)) {
+		ret =3D SWAP_AGAIN;
+		goto out;
+	}
+	pgd =3D pgd_offset(mm, address);
+	if (!pgd_present(*pgd)) {
+		goto out_unlock;
+	}
+	pmd =3D pmd_offset(pgd, address);
+	if (!pmd_present(*pmd)) {
+		goto out_unlock;
+	}
+	pte =3D pte_offset_map(pmd, address);
+	if (!pte_present(*pte)) {
+		goto out_unmap;
+	}
+	if (page_to_pfn(page) !=3D pte_pfn(*pte)) {
+		goto out_unmap;
+	}
+
+	if (vma->vm_flags & VM_LOCKED) {
+		ret =3D  SWAP_FAIL;
+		goto out_unmap;
+	}
+
+	flush_cache_page(vma, address);
+	pteval =3D ptep_get_and_clear(pte);
+	flush_tlb_page(vma, address);
+
+	if (pte_dirty(pteval))
+		set_page_dirty(page);
+
+	if (atomic_read(&page->pte.mapcount) =3D=3D 0)
+		BUG();
+
+	mm->rss--;
+	atomic_dec(&page->pte.mapcount);
+	page_cache_release(page);
+
+out_unmap:
+	pte_unmap(pte);
+
+out_unlock:
+	spin_unlock(&mm->page_table_lock);
+
+out:
+	return ret;
+}
+
+static int
+try_to_unmap_obj(struct page *page)
+{
+	struct address_space *mapping =3D page->mapping;
+	struct vm_area_struct *vma;
+	int ret =3D SWAP_SUCCESS;
+
+	if (!mapping)
+		BUG();
+
+	if (PageSwapCache(page))
+		BUG();
+
+	if (down_trylock(&mapping->i_shared_sem))
+		return SWAP_AGAIN;
+	
+	list_for_each_entry(vma, &mapping->i_mmap, shared) {
+		ret =3D try_to_unmap_obj_one(vma, page);
+		if (ret !=3D SWAP_SUCCESS)
+			goto out;
+	}
+
+	list_for_each_entry(vma, &mapping->i_mmap_shared, shared) {
+		ret =3D try_to_unmap_obj_one(vma, page);
+		if (ret !=3D SWAP_SUCCESS)
+			goto out;
+	}
+
+	if (atomic_read(&page->pte.mapcount) !=3D 0)
+		BUG();
+
+out:
+	up(&mapping->i_shared_sem);
+	return ret;
+}
+
 /**
  * try_to_unmap_one - worker function for try_to_unmap
  * @page: page to unmap
@@ -414,6 +628,11 @@
 	if (!page->mapping)
 		BUG();
=20
+	if (!PageAnon(page)) {
+		ret =3D try_to_unmap_obj(page);
+		goto out;
+	}
+
 	if (PageDirect(page)) {
 		ret =3D try_to_unmap_one(page, page->pte.direct);
 		if (ret =3D=3D SWAP_SUCCESS) {

--==========1812679384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
