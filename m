Date: Mon, 23 Dec 2002 12:19:41 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: shared pagetable benchmarking
Message-ID: <66860000.1040667581@baldur.austin.ibm.com>
In-Reply-To: <3E02FACD.5B300794@digeo.com>
References: <3E02FACD.5B300794@digeo.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1871149384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--==========1871149384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--On Friday, December 20, 2002 03:11:09 -0800 Andrew Morton
<akpm@digeo.com> wrote:

> Is there anything we can do to fix all of this up a bit?

Ok, here's my first attempt at optimization.  I track how many pte pages a
task has, and just do the copy if it doesn't have more than 3.  My fork
tests show that for a process with 3 pte pages, this patch produces
performance equal to 2.5.52.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1871149384==========
Content-Type: text/plain; charset=iso-8859-1; name="shpte-2.5.52-mm2-1.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="shpte-2.5.52-mm2-1.diff"; size=3832

--- 2.5.52-mm2-shsent/./include/linux/mm.h	2002-12-20 10:39:44.000000000 =
-0600
+++ 2.5.52-mm2-shpte/./include/linux/mm.h	2002-12-20 11:09:51.000000000 =
-0600
@@ -123,9 +123,6 @@
  * low four bits) to a page protection mask..
  */
 extern pgprot_t protection_map[16];
-#ifdef CONFIG_SHAREPTE
-extern pgprot_t protection_pmd[8];
-#endif
=20
 /*
  * These are the virtual MM functions - opening of an area, closing and
--- 2.5.52-mm2-shsent/./include/linux/sched.h	2002-12-20 10:39:44.000000000 =
-0600
+++ 2.5.52-mm2-shpte/./include/linux/sched.h	2002-12-23 10:18:08.000000000 =
-0600
@@ -183,6 +183,7 @@
 	struct vm_area_struct * mmap_cache;	/* last find_vma result */
 	unsigned long free_area_cache;		/* first hole */
 	pgd_t * pgd;
+	atomic_t ptepages;			/* Number of pte pages allocated */
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users =
count as 1) */
 	int map_count;				/* number of VMAs */
--- 2.5.52-mm2-shsent/./kernel/fork.c	2002-12-20 10:39:44.000000000 -0600
+++ 2.5.52-mm2-shpte/./kernel/fork.c	2002-12-23 10:32:15.000000000 -0600
@@ -238,6 +238,7 @@
 	mm->free_area_cache =3D TASK_UNMAPPED_BASE;
 	mm->map_count =3D 0;
 	mm->rss =3D 0;
+	atomic_set(&mm->ptepages, 0);
 	mm->cpu_vm_mask =3D 0;
 	pprev =3D &mm->mmap;
=20
--- 2.5.52-mm2-shsent/./mm/memory.c	2002-12-20 10:39:45.000000000 -0600
+++ 2.5.52-mm2-shpte/./mm/memory.c	2002-12-23 10:22:52.000000000 -0600
@@ -116,6 +116,7 @@
=20
 	pmd_clear(dir);
 	pgtable_remove_rmap_locked(ptepage, tlb->mm);
+	atomic_dec(&tlb->mm->ptepages);
 	dec_page_state(nr_page_table_pages);
 	ClearPagePtepage(ptepage);
=20
@@ -184,6 +185,7 @@
 		SetPagePtepage(new);
 		pgtable_add_rmap(new, mm, address);
 		pmd_populate(mm, pmd, new);
+		atomic_inc(&mm->ptepages);
 		inc_page_state(nr_page_table_pages);
 	}
 out:
@@ -217,7 +219,6 @@
 #define PTE_TABLE_MASK	((PTRS_PER_PTE-1) * sizeof(pte_t))
 #define PMD_TABLE_MASK	((PTRS_PER_PMD-1) * sizeof(pmd_t))
=20
-#ifndef CONFIG_SHAREPTE
 /*
  * copy one vm_area from one task to the other. Assumes the page tables
  * already present in the new task to be cleared in the whole range
@@ -354,7 +355,6 @@
 nomem:
 	return -ENOMEM;
 }
-#endif
=20
 static void zap_pte_range(mmu_gather_t *tlb, pmd_t * pmd, unsigned long =
address, unsigned long size)
 {
--- 2.5.52-mm2-shsent/./mm/ptshare.c	2002-12-20 10:39:45.000000000 -0600
+++ 2.5.52-mm2-shpte/./mm/ptshare.c	2002-12-23 12:17:23.000000000 -0600
@@ -23,7 +23,7 @@
 /*
  * Protections that can be set on the pmd entry (see discussion in =
mmap.c).
  */
-pgprot_t protection_pmd[8] =3D {
+static pgprot_t protection_pmd[8] =3D {
 	__PMD000, __PMD001, __PMD010, __PMD011, __PMD100, __PMD101, __PMD110, =
__PMD111
 };
=20
@@ -459,6 +459,28 @@
 }
=20
 /**
+ * fork_page_range - Either copy or share a page range at fork time
+ * @dst: the mm_struct of the forked child
+ * @src: the mm_struct of the forked parent
+ * @vma: the vm_area to be shared
+ * @prev_pmd: A pointer to the pmd entry we did at last invocation
+ *
+ * This wrapper decides whether to share page tables on fork or just make
+ * a copy.  The current criterion is whether a page table has more than 3
+ * pte pages, since all forked processes will unshare 3 pte pages after =
fork,
+ * even the ones doing an immediate exec.  Tests indicate that if a page
+ * table has more than 3 pte pages, it's a performance win to share.
+ */
+int fork_page_range(struct mm_struct *dst, struct mm_struct *src,
+		    struct vm_area_struct *vma, pmd_t **prev_pmd)
+{
+	if (atomic_read(&src->ptepages) > 3)
+		return share_page_range(dst, src, vma, prev_pmd);
+
+	return copy_page_range(dst, src, vma);
+}
+
+/**
  * unshare_page_range - Make sure no pte pages are shared in a given range
  * @mm: the mm_struct whose page table we unshare from
  * @address: the base address of the range

--==========1871149384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
