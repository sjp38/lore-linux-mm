Message-ID: <41C80086.7080904@yahoo.com.au>
Date: Tue, 21 Dec 2004 21:52:54 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain> <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org> <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org>
Content-Type: multipart/mixed;
 boundary="------------090909010609010407080100"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090909010609010407080100
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Linus Torvalds wrote:

> Nick, can you see if such a patch is possible? I'll test ppc64 still 
> working..
> 

OK I seem to have got something working after fumbling around in the
dark for a bit. I apologise if it blows up straight away for you, which
isn't unlikely.

Tested only on i386 2-levels for now (not much point in testing i386
3 levels really). I'll do some testing on ia64 and x86-64 tomorrow, but
I've run out of time tonight.

You'll want the full rollup here (against 2.6.10-rc3):
http://www.kerneltrap.org/~npiggin/vm/4level.patch.gz

And attached is the broken out patch (included in the above). An arch
only needs to include this in asm/pgtable.h, and no other changes. As
you see it wasn't _quite_ as clean as Hugh had hoped, but not too bad.

Nick

--------------090909010609010407080100
Content-Type: text/plain;
 name="4level-fallback.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4level-fallback.patch"




---

 linux-2.6-npiggin/include/asm-generic/4level-fixup.h |   32 +++++++++++++++++++
 linux-2.6-npiggin/include/linux/mm.h                 |    6 +++
 linux-2.6-npiggin/mm/memory.c                        |   25 ++++++++++++++
 3 files changed, 63 insertions(+)

diff -puN /dev/null include/asm-generic/4level-fixup.h
--- /dev/null	2004-09-06 19:38:39.000000000 +1000
+++ linux-2.6-npiggin/include/asm-generic/4level-fixup.h	2004-12-21 20:27:48.000000000 +1100
@@ -0,0 +1,32 @@
+#ifndef _4LEVEL_FIXUP_H
+#define _4LEVEL_FIXUP_H
+
+#define __ARCH_HAS_4LEVEL_HACK
+
+#define PUD_SIZE			PGDIR_SIZE
+#define PUD_MASK			PGDIR_MASK
+#define PTRS_PER_PUD			1
+
+#define pud_t				pgd_t
+
+#define pmd_alloc(mm, pud, address)			\
+({	pmd_t *ret;					\
+	if (pgd_none(*pud))				\
+ 		ret = __pmd_alloc(mm, pud, address);	\
+ 	else						\
+		ret = pmd_offset(pud, address);		\
+ 	ret;						\
+})
+
+#define pud_alloc(mm, pgd, address)	(pgd)
+#define pud_offset(pgd, start)		(pgd)
+#define pud_none(pud)			0
+#define pud_bad(pud)			0
+#define pud_present(pud)		1
+#define pud_ERROR(pud)			do { printk("pud_ERROR\n"); BUG(); } while (0)
+#define pud_clear(pud)			do { } while (0)
+
+#define pud_free(x)			do { } while (0)
+#define __pud_free_tlb(tlb, x)		do { } while (0)
+
+#endif
diff -puN include/linux/mm.h~4level-fallback include/linux/mm.h
--- linux-2.6/include/linux/mm.h~4level-fallback	2004-12-21 20:27:48.000000000 +1100
+++ linux-2.6-npiggin/include/linux/mm.h	2004-12-21 20:27:48.000000000 +1100
@@ -631,6 +631,11 @@ extern void remove_shrinker(struct shrin
  * the inlining and the symmetry break with pte_alloc_map() that does all
  * of this out-of-line.
  */
+/*
+ * The following ifdef needed to get the 4level-fixup.h header to work.
+ * Remove it when 4level-fixup.h has been removed.
+ */
+#ifndef __ARCH_HAS_4LEVEL_HACK 
 static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 {
 	if (pgd_none(*pgd))
@@ -644,6 +649,7 @@ static inline pmd_t *pmd_alloc(struct mm
 		return __pmd_alloc(mm, pud, address);
 	return pmd_offset(pud, address);
 }
+#endif
 
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, pg_data_t *pgdat,
diff -puN mm/memory.c~4level-fallback mm/memory.c
--- linux-2.6/mm/memory.c~4level-fallback	2004-12-21 20:27:48.000000000 +1100
+++ linux-2.6-npiggin/mm/memory.c	2004-12-21 20:27:48.000000000 +1100
@@ -1940,6 +1940,7 @@ int handle_mm_fault(struct mm_struct *mm
 	return VM_FAULT_OOM;
 }
 
+#ifndef __ARCH_HAS_4LEVEL_HACK
 #if (PTRS_PER_PGD > 1)
 /*
  * Allocate page upper directory.
@@ -2007,6 +2008,30 @@ out:
 	return pmd_offset(pud, address);
 }
 #endif
+#else
+pmd_t fastcall *__pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+{
+	pmd_t *new;
+
+	spin_unlock(&mm->page_table_lock);
+	new = pmd_alloc_one(mm, address);
+	spin_lock(&mm->page_table_lock);
+	if (!new)
+		return NULL;
+
+	/*
+	 * Because we dropped the lock, we should re-check the
+	 * entry, as somebody else could have populated it..
+	 */
+	if (pgd_present(*pud)) {
+		pmd_free(new);
+		goto out;
+	}
+	pgd_populate(mm, pud, new);
+out:
+	return pmd_offset(pud, address);
+}
+#endif
 
 int make_pages_present(unsigned long addr, unsigned long end)
 {

_

--------------090909010609010407080100--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
