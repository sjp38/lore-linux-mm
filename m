Message-ID: <41822D75.3090802@yahoo.com.au>
Date: Fri, 29 Oct 2004 21:45:57 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] abstract pagetable locking and pte updates
References: <4181EF2D.5000407@yahoo.com.au>
In-Reply-To: <4181EF2D.5000407@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------080309000008010300090801"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080309000008010300090801
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:
> Hello,
> 
> Following are patches that abstract page table operations to
> allow lockless implementations by using cmpxchg or per-pte locks.
> 

One more patch - this provides a generic framework for pte
locks, and a basic i386 reference implementation (which just
ifdefs out the cmpxchg version). Boots, runs, and has taken
some stressing.

I should have sorted this out before sending the patches for
RFC. The generic code actually did need a few lines of changes,
but not much as you can see. Needs some tidying up though, but
I only just wrote it in a few minutes.

And now before anyone gets a chance to shoot down the whole thing,
I just have to say

	"look ma, no page_table_lock!"

--------------080309000008010300090801
Content-Type: text/x-patch;
 name="vm-i386-locked-pte.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-i386-locked-pte.patch"




---

 linux-2.6-npiggin/include/asm-generic/pgtable.h |  128 +++++++++++++++++++++++-
 linux-2.6-npiggin/include/asm-i386/pgtable.h    |   33 ++++++
 linux-2.6-npiggin/include/linux/mm.h            |    7 -
 linux-2.6-npiggin/kernel/futex.c                |    5 
 linux-2.6-npiggin/mm/memory.c                   |   13 +-
 5 files changed, 174 insertions(+), 12 deletions(-)

diff -puN include/asm-i386/pgtable.h~vm-i386-locked-pte include/asm-i386/pgtable.h
--- linux-2.6/include/asm-i386/pgtable.h~vm-i386-locked-pte	2004-10-29 19:12:15.000000000 +1000
+++ linux-2.6-npiggin/include/asm-i386/pgtable.h	2004-10-29 20:38:38.000000000 +1000
@@ -106,6 +106,8 @@ void paging_init(void);
 #define _PAGE_BIT_UNUSED3	11
 #define _PAGE_BIT_NX		63
 
+#define _PAGE_BIT_LOCKED	9
+
 #define _PAGE_PRESENT	0x001
 #define _PAGE_RW	0x002
 #define _PAGE_USER	0x004
@@ -119,6 +121,8 @@ void paging_init(void);
 #define _PAGE_UNUSED2	0x400
 #define _PAGE_UNUSED3	0x800
 
+#define _PAGE_LOCKED	0x200
+
 #define _PAGE_FILE	0x040	/* set:pagecache unset:swap */
 #define _PAGE_PROTNONE	0x080	/* If not present */
 #ifdef CONFIG_X86_PAE
@@ -231,11 +235,13 @@ static inline pte_t pte_exprotect(pte_t 
 static inline pte_t pte_mkclean(pte_t pte)	{ (pte).pte_low &= ~_PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkold(pte_t pte)	{ (pte).pte_low &= ~_PAGE_ACCESSED; return pte; }
 static inline pte_t pte_wrprotect(pte_t pte)	{ (pte).pte_low &= ~_PAGE_RW; return pte; }
+static inline pte_t pte_mkunlocked(pte_t pte)	{ (pte).pte_low &= ~_PAGE_LOCKED; return pte; }
 static inline pte_t pte_mkread(pte_t pte)	{ (pte).pte_low |= _PAGE_USER; return pte; }
 static inline pte_t pte_mkexec(pte_t pte)	{ (pte).pte_low |= _PAGE_USER; return pte; }
 static inline pte_t pte_mkdirty(pte_t pte)	{ (pte).pte_low |= _PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte_low |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte_low |= _PAGE_RW; return pte; }
+static inline pte_t pte_mklocked(pte_t pte)	{ (pte).pte_low |= _PAGE_LOCKED; return pte; }
 
 #ifdef CONFIG_X86_PAE
 # include <asm/pgtable-3level.h>
@@ -398,7 +404,32 @@ extern pte_t *lookup_address(unsigned lo
 		}							  \
 	} while (0)
 
-#define __HAVE_ARCH_PTEP_CMPXCHG
+#define __HAVE_ARCH_PTEP_LOCK
+#define ptep_xchg(__ptep, __newval)					\
+({									\
+ 	pte_t ret;							\
+	/* Just need to make sure we keep the _PAGE_BIT_LOCKED bit */	\
+	ret.pte_low = xchg(&(__ptep)->pte_low, (__newval).pte_low);	\
+	ret.pte_high = (__ptep)->pte_high;				\
+	(__ptep)->pte_high = (__newval).pte_high;			\
+	ret;								\
+})
+
+#define ptep_lock(__ptep)						\
+do {									\
+	preempt_disable();						\
+	while (unlikely(test_and_set_bit(_PAGE_BIT_LOCKED, &(__ptep)->pte_low))) \
+		cpu_relax();						\
+} while (0)
+
+#define ptep_unlock(__ptep)						\
+do {									\
+	if (unlikely(!test_and_clear_bit(_PAGE_BIT_LOCKED, &(__ptep)->pte_low))) \
+		BUG();							\
+	preempt_enable();						\
+} while (0)
+
+//#define __HAVE_ARCH_PTEP_CMPXCHG
 
 #ifdef CONFIG_X86_PAE
 #define __HAVE_ARCH_PTEP_ATOMIC_READ
diff -puN include/asm-generic/pgtable.h~vm-i386-locked-pte include/asm-generic/pgtable.h
--- linux-2.6/include/asm-generic/pgtable.h~vm-i386-locked-pte	2004-10-29 19:35:14.000000000 +1000
+++ linux-2.6-npiggin/include/asm-generic/pgtable.h	2004-10-29 20:54:56.000000000 +1000
@@ -135,7 +135,7 @@ static inline void ptep_mkdirty(pte_t *p
 #endif
 
 #ifndef __ASSEMBLY__
-#ifdef __HAVE_ARCH_PTEP_CMPXCHG
+#if defined(__HAVE_ARCH_PTEP_CMPXCHG)
 #define mm_lock_page_table(__mm)					\
 do {									\
 } while (0);
@@ -254,7 +254,130 @@ do {} while (0)
 #define ptep_verify_finish(__pmod, __mm, __ptep)			\
 	ptep_verify(__pmod, __mm, __ptep)
 
-#else /* __HAVE_ARCH_PTEP_CMPXCHG */ /* GENERIC_PTEP_LOCKING follows */
+#elif defined(__HAVE_ARCH_PTEP_LOCK)
+
+#define mm_lock_page_table(__mm)					\
+do {									\
+} while (0);
+
+#define mm_unlock_page_table(__mm)					\
+do {									\
+} while (0);
+
+#define mm_pin_pages(__mm)						\
+do {									\
+} while (0)
+
+#define mm_unpin_pages(__mm)						\
+do {									\
+} while (0)
+
+#define ptep_pin_pages(__mm, __ptep)					\
+do {									\
+	ptep_lock(__ptep);						\
+} while (0)
+
+#define ptep_unpin_pages(__mm, __ptep)					\
+do {									\
+	ptep_unlock(__ptep);						\
+} while (0)
+
+/* mm_lock_page_table doesn't actually take a lock, so this can be 0 */
+#define MM_RELOCK_CHECK 0
+
+struct pte_modify {
+};
+
+#ifndef __HAVE_ARCH_PTEP_ATOMIC_READ
+#define ptep_atomic_read(__ptep)					\
+({									\
+	*__ptep;							\
+})
+#endif
+
+#define ptep_begin_modify(__pmod, __mm, __ptep)				\
+({									\
+ 	(void)__pmod;							\
+ 	(void)__mm;							\
+ 	ptep_lock(__ptep);						\
+ 	pte_mkunlocked(*(__ptep));					\
+})
+
+#define ptep_abort(__pmod, __mm, __ptep)				\
+do { ptep_unlock(__ptep); } while (0)
+
+#define ptep_commit(__pmod, __mm, __ptep, __newval)			\
+({									\
+ 	*(__ptep) = pte_mklocked(__newval);				\
+ 	ptep_unlock(__ptep);						\
+ 	0;								\
+})
+
+#define ptep_commit_flush(__pmod, __mm, __vma, __address, __ptep, __newval) \
+({									\
+ 	ptep_commit(__pmod, __mm, __ptep, __newval);			\
+	flush_tlb_page(__vma, __address);				\
+ 	0;								\
+})
+
+#define ptep_commit_access_flush(__pmod, __mm, __vma, __address, __ptep, __newval, __dirty) \
+({									\
+ 	ptep_set_access_flags(__vma, __address, __ptep,			\
+				pte_mklocked(__newval), __dirty);	\
+ 	ptep_unlock(__ptep);						\
+	flush_tlb_page(__vma, __address);				\
+ 	0;								\
+})
+
+#define ptep_commit_establish_flush(__pmod, __mm, __vma, __address, __ptep, __newval) \
+({									\
+ 	ptep_establish(__vma, __address, __ptep, pte_mklocked(__newval)); \
+ 	ptep_unlock(__ptep);						\
+	flush_tlb_page(__vma, __address);				\
+	0;								\
+})
+
+#define ptep_commit_clear(__pmod, __mm, __ptep, __newval, __oldval) 	\
+({									\
+ 	__oldval = ptep_xchg(__ptep, pte_mklocked(__newval));		\
+ 	__oldval = pte_mkunlocked(__oldval);				\
+ 	ptep_unlock(__ptep);						\
+ 	0;								\
+})
+
+#define ptep_commit_clear_flush(__pmod, __mm, __vma, __address, __ptep, __newval, __oldval) \
+({									\
+ 	ptep_commit_clear(__pmod, __mm, __ptep, __newval, __oldval);	\
+	flush_tlb_page(__vma, __address);				\
+ 	0;								\
+})
+
+#define ptep_commit_clear_flush_young(__pmod, __mm, __vma, __address, __ptep, __young) \
+({									\
+ 	*__young = ptep_clear_flush_young(__vma, __address, __ptep);    \
+ 	ptep_unlock(__ptep);						\
+ 	0;								\
+})
+
+#define ptep_commit_clear_flush_dirty(__pmod, __mm, __vma, __address, __ptep, __dirty) \
+({									\
+ 	*__dirty = ptep_clear_flush_dirty(__vma, __address, __ptep);    \
+ 	ptep_unlock(__ptep);						\
+ 	0;								\
+})
+
+#define ptep_verify(__pmod, __mm, __ptep)				\
+({									\
+ 	0;								\
+})
+
+#define ptep_verify_finish(__pmod, __mm, __ptep)			\
+({									\
+ 	ptep_unlock(__ptep);						\
+ 	0;								\
+})
+
+#else /* __HAVE_ARCH_PTEP_LOCK */ /* GENERIC_PTEP_LOCKING follows */
 /* Use the generic mm->page_table_lock serialised scheme */
 /*
  * XXX: can we make use of this?
@@ -339,6 +462,7 @@ struct pte_modify {
 ({									\
  	(void)__pmod;							\
  	(void)__mm;							\
+ 	/* XXX: needn't be atomic? */					\
  	ptep_atomic_read(__ptep);					\
 })
 
diff -puN mm/memory.c~vm-i386-locked-pte mm/memory.c
--- linux-2.6/mm/memory.c~vm-i386-locked-pte	2004-10-29 20:01:32.000000000 +1000
+++ linux-2.6-npiggin/mm/memory.c	2004-10-29 21:18:31.000000000 +1000
@@ -689,8 +689,9 @@ void zap_page_range(struct vm_area_struc
 	unmap_vmas(mm, vma, address, end, &nr_accounted, details);
 }
 
-void follow_page_finish(struct mm_struct *mm, unsigned long address)
+void follow_page_finish(struct mm_struct *mm, pte_t *p, unsigned long address)
 {
+	ptep_unpin_pages(mm, p);
 	mm_unpin_pages(mm);
 	mm_unlock_page_table(mm);
 }
@@ -699,7 +700,7 @@ void follow_page_finish(struct mm_struct
  * Do a quick page-table lookup for a single page.
  */
 struct page *
-follow_page(struct mm_struct *mm, unsigned long address, int write) 
+follow_page(struct mm_struct *mm, pte_t **p, unsigned long address, int write)
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
@@ -732,6 +733,7 @@ follow_page(struct mm_struct *mm, unsign
 	 * page with get_page? 
 	 */
 	mm_pin_pages(mm);
+	ptep_pin_pages(mm, ptep);
 	pte = ptep_atomic_read(ptep);
 	pte_unmap(ptep);
 
@@ -744,11 +746,13 @@ follow_page(struct mm_struct *mm, unsign
 			if (write && !pte_dirty(pte) && !PageDirty(page))
 				set_page_dirty(page);
 			mark_page_accessed(page);
+			*p = ptep;
 			return page;
 		}
 	}
 
 out_unpin:
+	ptep_unpin_pages(mm, ptep);
 	mm_unpin_pages(mm);
 out:
 	mm_unlock_page_table(mm);
@@ -850,9 +854,10 @@ int get_user_pages(struct task_struct *t
 			continue;
 		}
 		do {
+			pte_t *p;
 			struct page *page;
 			int lookup_write = write;
-			while (!(page = follow_page(mm, start, lookup_write))) {
+			while (!(page = follow_page(mm, &p, start, lookup_write))) {
 				/*
 				 * Shortcut for anonymous pages. We don't want
 				 * to force the creation of pages tables for
@@ -896,7 +901,7 @@ int get_user_pages(struct task_struct *t
 					page_cache_get(page);
 			}
 			if (page)
-				follow_page_finish(mm, start);
+				follow_page_finish(mm, p, start);
 set_vmas:
 			if (vmas)
 				vmas[i] = vma;
diff -puN kernel/futex.c~vm-i386-locked-pte kernel/futex.c
--- linux-2.6/kernel/futex.c~vm-i386-locked-pte	2004-10-29 21:13:50.000000000 +1000
+++ linux-2.6-npiggin/kernel/futex.c	2004-10-29 21:18:11.000000000 +1000
@@ -144,6 +144,7 @@ static int get_futex_key(unsigned long u
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	struct page *page;
+	pte_t *p;
 	int err;
 
 	/*
@@ -204,11 +205,11 @@ static int get_futex_key(unsigned long u
 	/*
 	 * Do a quick atomic lookup first - this is the fastpath.
 	 */
-	page = follow_page(mm, uaddr, 0);
+	page = follow_page(mm, &p, uaddr, 0);
 	if (likely(page != NULL)) {
 		key->shared.pgoff =
 			page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-		follow_page_finish(mm, uaddr);
+		follow_page_finish(mm, p, uaddr);
 		return 0;
 	}
 
diff -puN include/linux/mm.h~vm-i386-locked-pte include/linux/mm.h
--- linux-2.6/include/linux/mm.h~vm-i386-locked-pte	2004-10-29 21:14:05.000000000 +1000
+++ linux-2.6-npiggin/include/linux/mm.h	2004-10-29 21:17:48.000000000 +1000
@@ -756,9 +756,10 @@ static inline unsigned long vma_pages(st
 extern struct vm_area_struct *find_extend_vma(struct mm_struct *mm, unsigned long addr);
 
 extern struct page * vmalloc_to_page(void *addr);
-extern struct page * follow_page(struct mm_struct *mm, unsigned long address,
-		int write);
-extern void follow_page_finish(struct mm_struct *mm, unsigned long address);
+extern struct page * follow_page(struct mm_struct *mm, pte_t **p,
+				unsigned long address, int write);
+extern void follow_page_finish(struct mm_struct *mm, pte_t *p,
+				unsigned long address);
 int remap_pfn_range(struct vm_area_struct *, unsigned long,
 		unsigned long, unsigned long, pgprot_t);
 

_

--------------080309000008010300090801--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
