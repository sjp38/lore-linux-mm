Date: Fri, 5 Jul 2002 23:35:04 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] minimal rmap for 2.5.25
Message-ID: <Pine.LNX.4.44L.0207052329020.8346-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hi,

below is a minimal rmap patch for 2.5.25, unfortunately
untested because the hard disk on my test box died ;(

This patch is based on Craig Kulesa's minimal rmap patch
for 2.5.24, with a few changes:
- removed a few unrelated changes
- updated armv/rmap.h for new pagetable layout of linux/arm
- dropped per-zone pte_chain freelists, we want to make per-cpu
  ones for SMP scalability
- ported to 2.5.25 (PF_NOWARN instead of PF_RADIX_TREE)
- drop spelling and whitespace fixes (should be merged separately)

This patch should be pretty much ready to push to Linus, but I
won't be able to test it for a while because of the broken
hard disk. If you have some time this weekend, please test
this patch...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.623   -> 1.625
#	include/linux/mmzone.h	1.11    -> 1.13
#	include/linux/swap.h	1.47    -> 1.48
#	  include/linux/mm.h	1.55.1.1 -> 1.57
#	     mm/page_alloc.c	1.73.1.5 -> 1.76
#	       kernel/fork.c	1.49    -> 1.50
#	            Makefile	1.273   -> 1.274
#	 mm/page-writeback.c	1.23.1.3 -> 1.26
#	          fs/dquot.c	1.43    -> 1.45
#	         fs/dcache.c	1.28    -> 1.30
#	         mm/vmscan.c	1.78.1.3 -> 1.81
#	include/linux/page-flags.h	1.9     -> 1.10
#	       mm/swapfile.c	1.51.1.1 -> 1.53
#	        mm/filemap.c	1.102.1.4 -> 1.105
#	           fs/exec.c	1.31    -> 1.32
#	           mm/swap.c	1.16    -> 1.18
#	     mm/swap_state.c	1.31.1.2 -> 1.34
#	         mm/memory.c	1.72.1.2 -> 1.74
#	         mm/mremap.c	1.13    -> 1.14
#	         mm/Makefile	1.11    -> 1.12
#	          fs/inode.c	1.65.1.1 -> 1.68
#	        mm/pdflush.c	1.8.1.1 -> 1.11
#	               (new)	        -> 1.1     include/asm-sh/rmap.h
#	               (new)	        -> 1.2     include/asm-arm/proc-armv/rmap.h
#	               (new)	        -> 1.1     include/asm-mips/rmap.h
#	               (new)	        -> 1.1     include/asm-m68k/rmap.h
#	               (new)	        -> 1.1     include/asm-arm/rmap.h
#	               (new)	        -> 1.2     mm/rmap.c
#	               (new)	        -> 1.1     include/asm-s390x/rmap.h
#	               (new)	        -> 1.1     include/asm-cris/rmap.h
#	               (new)	        -> 1.1     include/asm-s390/rmap.h
#	               (new)	        -> 1.1     include/asm-ia64/rmap.h
#	               (new)	        -> 1.1     include/asm-sparc64/rmap.h
#	               (new)	        -> 1.1     include/asm-alpha/rmap.h
#	               (new)	        -> 1.1     include/asm-ppc/rmap.h
#	               (new)	        -> 1.1     include/asm-i386/rmap.h
#	               (new)	        -> 1.1     include/asm-sparc/rmap.h
#	               (new)	        -> 1.1     include/asm-mips64/rmap.h
#	               (new)	        -> 1.1     include/asm-generic/rmap.h
#	               (new)	        -> 1.1     include/asm-parisc/rmap.h
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/07/05	riel@imladris.surriel.com	1.604.14.10
# get rid of per-zone pte_chain stuff & fixed typo
# --------------------------------------------
# 02/07/05	riel@imladris.surriel.com	1.624
# merged
# --------------------------------------------
# 02/07/05	riel@imladris.surriel.com	1.625
# s/PF_RADIX_TREE/PF_NOWARN/ ... but in swap_state.c
# --------------------------------------------
#
diff -Nru a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c	Fri Jul  5 23:28:01 2002
+++ b/fs/exec.c	Fri Jul  5 23:28:01 2002
@@ -36,6 +36,7 @@
 #include <linux/spinlock.h>
 #include <linux/personality.h>
 #include <linux/binfmts.h>
+#include <linux/swap.h>
 #define __NO_VERSION__
 #include <linux/module.h>
 #include <linux/namei.h>
@@ -283,6 +284,7 @@
 	flush_dcache_page(page);
 	flush_page_to_ram(page);
 	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(page, PAGE_COPY))));
+	page_add_rmap(page, pte);
 	pte_unmap(pte);
 	tsk->mm->rss++;
 	spin_unlock(&tsk->mm->page_table_lock);
diff -Nru a/include/asm-alpha/rmap.h b/include/asm-alpha/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-alpha/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _ALPHA_RMAP_H
+#define _ALPHA_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-arm/proc-armv/rmap.h b/include/asm-arm/proc-armv/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-arm/proc-armv/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,49 @@
+#ifndef _ARMV_RMAP_H
+#define _ARMV_RMAP_H
+/*
+ * linux/include/asm-arm/proc-armv/rmap.h
+ *
+ * Architecture dependant parts of the reverse mapping code,
+ *
+ * ARM is different since hardware page tables are smaller than
+ * the page size and Linux uses a "duplicate" one with extra info.
+ * For rmap this means that the first 2 kB of a page are the hardware
+ * page tables and the last 2 kB are the software page tables.
+ */
+
+static inline void pgtable_add_rmap(pte_t * ptep, struct mm_struct * mm, unsigned long address)
+{
+	struct page * page = virt_to_page(ptep);
+
+	page->mm = mm;
+	page->index = address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
+}
+
+static inline void pgtable_remove_rmap(pte_t * ptep)
+{
+	struct page * page = virt_to_page(ptep);
+
+	page->mm = NULL;
+	page->index = 0;
+}
+
+static inline struct mm_struct * ptep_to_mm(pte_t * ptep)
+{
+	struct page * page = virt_to_page(ptep);
+
+	return page->mm;
+}
+
+/* The page table takes half of the page */
+#define PTE_MASK  ((PAGE_SIZE / 2) - 1)
+
+static inline unsigned long ptep_to_address(pte_t * ptep)
+{
+	struct page * page = virt_to_page(ptep);
+	unsigned long low_bits;
+
+	low_bits = ((unsigned long)ptep & PTE_MASK) * PTRS_PER_PTE;
+	return page->index + low_bits;
+}
+
+#endif /* _ARMV_RMAP_H */
diff -Nru a/include/asm-arm/rmap.h b/include/asm-arm/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-arm/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,6 @@
+#ifndef _ARM_RMAP_H
+#define _ARM_RMAP_H
+
+#include <asm/proc/rmap.h>
+
+#endif /* _ARM_RMAP_H */
diff -Nru a/include/asm-cris/rmap.h b/include/asm-cris/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-cris/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _CRIS_RMAP_H
+#define _CRIS_RMAP_H
+
+/* nothing to see, move along :) */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-generic/rmap.h b/include/asm-generic/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-generic/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,52 @@
+#ifndef _GENERIC_RMAP_H
+#define _GENERIC_RMAP_H
+/*
+ * linux/include/asm-generic/rmap.h
+ *
+ * Architecture dependant parts of the reverse mapping code,
+ * this version should work for most architectures with a
+ * 'normal' page table layout.
+ *
+ * We use the struct page of the page table page to find out
+ * the process and full address of a page table entry:
+ * - page->mapping points to the process' mm_struct
+ * - page->index has the high bits of the address
+ * - the lower bits of the address are calculated from the
+ *   offset of the page table entry within the page table page
+ */
+#include <linux/mm.h>
+
+static inline void pgtable_add_rmap(struct page * page, struct mm_struct * mm, unsigned long address)
+{
+#ifdef BROKEN_PPC_PTE_ALLOC_ONE
+	/* OK, so PPC calls pte_alloc() before mem_map[] is setup ... ;( */
+	extern int mem_init_done;
+
+	if (!mem_init_done)
+		return;
+#endif
+	page->mapping = (void *)mm;
+	page->index = address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
+}
+
+static inline void pgtable_remove_rmap(struct page * page)
+{
+	page->mapping = NULL;
+	page->index = 0;
+}
+
+static inline struct mm_struct * ptep_to_mm(pte_t * ptep)
+{
+	struct page * page = virt_to_page(ptep);
+	return (struct mm_struct *) page->mapping;
+}
+
+static inline unsigned long ptep_to_address(pte_t * ptep)
+{
+	struct page * page = virt_to_page(ptep);
+	unsigned long low_bits;
+	low_bits = ((unsigned long)ptep & ~PAGE_MASK) * PTRS_PER_PTE;
+	return page->index + low_bits;
+}
+
+#endif /* _GENERIC_RMAP_H */
diff -Nru a/include/asm-i386/rmap.h b/include/asm-i386/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-i386/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _I386_RMAP_H
+#define _I386_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-ia64/rmap.h b/include/asm-ia64/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-ia64/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _IA64_RMAP_H
+#define _IA64_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-m68k/rmap.h b/include/asm-m68k/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-m68k/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _M68K_RMAP_H
+#define _M68K_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-mips/rmap.h b/include/asm-mips/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-mips/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _MIPS_RMAP_H
+#define _MIPS_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-mips64/rmap.h b/include/asm-mips64/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-mips64/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _MIPS64_RMAP_H
+#define _MIPS64_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-parisc/rmap.h b/include/asm-parisc/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-parisc/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _PARISC_RMAP_H
+#define _PARISC_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-ppc/rmap.h b/include/asm-ppc/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-ppc/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,9 @@
+#ifndef _PPC_RMAP_H
+#define _PPC_RMAP_H
+
+/* PPC calls pte_alloc() before mem_map[] is setup ... */
+#define BROKEN_PPC_PTE_ALLOC_ONE
+
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-s390/rmap.h b/include/asm-s390/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-s390/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _S390_RMAP_H
+#define _S390_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-s390x/rmap.h b/include/asm-s390x/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-s390x/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _S390X_RMAP_H
+#define _S390X_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-sh/rmap.h b/include/asm-sh/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-sh/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _SH_RMAP_H
+#define _SH_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-sparc/rmap.h b/include/asm-sparc/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-sparc/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _SPARC_RMAP_H
+#define _SPARC_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-sparc64/rmap.h b/include/asm-sparc64/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-sparc64/rmap.h	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,7 @@
+#ifndef _SPARC64_RMAP_H
+#define _SPARC64_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h	Fri Jul  5 23:28:00 2002
+++ b/include/linux/mm.h	Fri Jul  5 23:28:00 2002
@@ -130,6 +130,9 @@
 	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int unused);
 };

+/* forward declaration; pte_chain is meant to be internal to rmap.c */
+struct pte_chain;
+
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -154,6 +157,8 @@
 					   updated asynchronously */
 	struct list_head lru;		/* Pageout list, eg. active_list;
 					   protected by pagemap_lru_lock !! */
+	struct pte_chain * pte_chain;	/* Reverse pte mapping pointer.
+					 * protected by PG_chainlock */
 	unsigned long private;		/* mapping-private opaque data */

 	/*
diff -Nru a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h	Fri Jul  5 23:28:00 2002
+++ b/include/linux/page-flags.h	Fri Jul  5 23:28:00 2002
@@ -47,7 +47,7 @@
  * locked- and dirty-page accounting.  The top eight bits of page->flags are
  * used for page->zone, so putting flag bits there doesn't work.
  */
-#define PG_locked	 0	/* Page is locked. Don't touch. */
+#define PG_locked	 	 0	/* Page is locked. Don't touch. */
 #define PG_error		 1
 #define PG_referenced		 2
 #define PG_uptodate		 3
@@ -65,6 +65,7 @@
 #define PG_private		12	/* Has something at ->private */
 #define PG_writeback		13	/* Page is under writeback */
 #define PG_nosave		15	/* Used for system suspend/resume */
+#define PG_chainlock		16	/* lock bit for ->pte_chain */

 /*
  * Global page accounting.  One instance per CPU.
@@ -215,6 +216,31 @@
 #define TestSetPageNosave(page)	test_and_set_bit(PG_nosave, &(page)->flags)
 #define ClearPageNosave(page)		clear_bit(PG_nosave, &(page)->flags)
 #define TestClearPageNosave(page)	test_and_clear_bit(PG_nosave, &(page)->flags)
+
+/*
+ * inlines for acquisition and release of PG_chainlock
+ */
+static inline void pte_chain_lock(struct page *page)
+{
+	/*
+	 * Assuming the lock is uncontended, this never enters
+	 * the body of the outer loop. If it is contended, then
+	 * within the inner loop a non-atomic test is used to
+	 * busywait with less bus contention for a good time to
+	 * attempt to acquire the lock bit.
+	 */
+	preempt_disable();
+	while (test_and_set_bit(PG_chainlock, &page->flags)) {
+		while (test_bit(PG_chainlock, &page->flags))
+			cpu_relax();
+	}
+}
+
+static inline void pte_chain_unlock(struct page *page)
+{
+	clear_bit(PG_chainlock, &page->flags);
+	preempt_enable();
+}

 /*
  * The PageSwapCache predicate doesn't use a PG_flag at this time,
diff -Nru a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h	Fri Jul  5 23:28:00 2002
+++ b/include/linux/swap.h	Fri Jul  5 23:28:00 2002
@@ -142,6 +142,19 @@
 struct address_space;
 struct zone_t;

+/* linux/mm/rmap.c */
+extern int FASTCALL(page_referenced(struct page *));
+extern void FASTCALL(page_add_rmap(struct page *, pte_t *));
+extern void FASTCALL(page_remove_rmap(struct page *, pte_t *));
+extern int FASTCALL(try_to_unmap(struct page *));
+extern int FASTCALL(page_over_rsslimit(struct page *));
+
+/* return values of try_to_unmap */
+#define	SWAP_SUCCESS	0
+#define	SWAP_AGAIN	1
+#define	SWAP_FAIL	2
+#define	SWAP_ERROR	3
+
 /* linux/mm/swap.c */
 extern void FASTCALL(lru_cache_add(struct page *));
 extern void FASTCALL(__lru_cache_del(struct page *));
@@ -168,6 +181,7 @@
 extern void show_swap_cache_info(void);
 #endif
 extern int add_to_swap_cache(struct page *, swp_entry_t);
+extern int add_to_swap(struct page *);
 extern void __delete_from_swap_cache(struct page *page);
 extern void delete_from_swap_cache(struct page *page);
 extern int move_to_swap_cache(struct page *page, swp_entry_t entry);
diff -Nru a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c	Fri Jul  5 23:28:00 2002
+++ b/kernel/fork.c	Fri Jul  5 23:28:00 2002
@@ -189,7 +189,6 @@
 	mm->map_count = 0;
 	mm->rss = 0;
 	mm->cpu_vm_mask = 0;
-	mm->swap_address = 0;
 	pprev = &mm->mmap;

 	/*
@@ -308,9 +307,6 @@
 void mmput(struct mm_struct *mm)
 {
 	if (atomic_dec_and_lock(&mm->mm_users, &mmlist_lock)) {
-		extern struct mm_struct *swap_mm;
-		if (swap_mm == mm)
-			swap_mm = list_entry(mm->mmlist.next, struct mm_struct, mmlist);
 		list_del(&mm->mmlist);
 		mmlist_nr--;
 		spin_unlock(&mmlist_lock);
diff -Nru a/mm/Makefile b/mm/Makefile
--- a/mm/Makefile	Fri Jul  5 23:28:01 2002
+++ b/mm/Makefile	Fri Jul  5 23:28:01 2002
@@ -16,6 +16,6 @@
 	    vmalloc.o slab.o bootmem.o swap.o vmscan.o page_io.o \
 	    page_alloc.o swap_state.o swapfile.o numa.o oom_kill.o \
 	    shmem.o highmem.o mempool.o msync.o mincore.o readahead.o \
-	    pdflush.o page-writeback.o
+	    pdflush.o page-writeback.o rmap.o

 include $(TOPDIR)/Rules.make
diff -Nru a/mm/filemap.c b/mm/filemap.c
--- a/mm/filemap.c	Fri Jul  5 23:28:01 2002
+++ b/mm/filemap.c	Fri Jul  5 23:28:01 2002
@@ -176,6 +176,10 @@
  */
 static void truncate_complete_page(struct page *page)
 {
+	/* Page has already been removed from processes, by vmtruncate()  */
+	if (page->pte_chain)
+		BUG();
+
 	/* Leave it on the LRU if it gets converted into anonymous buffers */
 	if (!PagePrivate(page) || do_invalidatepage(page, 0)) {
 		lru_cache_del(page);
@@ -660,7 +664,7 @@
  * But that's OK - sleepers in wait_on_page_writeback() just go back to sleep.
  *
  * The first mb is necessary to safely close the critical section opened by the
- * TryLockPage(), the second mb is necessary to enforce ordering between
+ * TestSetPageLocked(), the second mb is necessary to enforce ordering between
  * the clear_bit and the read of the waitqueue (to avoid SMP races with a
  * parallel wait_on_page_locked()).
  */
diff -Nru a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c	Fri Jul  5 23:28:01 2002
+++ b/mm/memory.c	Fri Jul  5 23:28:01 2002
@@ -46,6 +46,7 @@
 #include <linux/pagemap.h>

 #include <asm/pgalloc.h>
+#include <asm/rmap.h>
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
@@ -79,7 +80,7 @@
  */
 static inline void free_one_pmd(mmu_gather_t *tlb, pmd_t * dir)
 {
-	struct page *pte;
+	struct page *page;

 	if (pmd_none(*dir))
 		return;
@@ -88,9 +89,10 @@
 		pmd_clear(dir);
 		return;
 	}
-	pte = pmd_page(*dir);
+	page = pmd_page(*dir);
 	pmd_clear(dir);
-	pte_free_tlb(tlb, pte);
+	pgtable_remove_rmap(page);
+	pte_free_tlb(tlb, page);
 }

 static inline void free_one_pgd(mmu_gather_t *tlb, pgd_t * dir)
@@ -150,6 +152,7 @@
 			pte_free(new);
 			goto out;
 		}
+		pgtable_add_rmap(new, mm, address);
 		pmd_populate(mm, pmd, new);
 	}
 out:
@@ -177,6 +180,7 @@
 			pte_free_kernel(new);
 			goto out;
 		}
+		pgtable_add_rmap(virt_to_page(new), mm, address);
 		pmd_populate_kernel(mm, pmd, new);
 	}
 out:
@@ -260,10 +264,13 @@

 				if (pte_none(pte))
 					goto cont_copy_pte_range_noset;
+				/* pte contains position in swap, so copy. */
 				if (!pte_present(pte)) {
 					swap_duplicate(pte_to_swp_entry(pte));
-					goto cont_copy_pte_range;
+					set_pte(dst_pte, pte);
+					goto cont_copy_pte_range_noset;
 				}
+				ptepage = pte_page(pte);
 				pfn = pte_pfn(pte);
 				if (!pfn_valid(pfn))
 					goto cont_copy_pte_range;
@@ -272,7 +279,7 @@
 					goto cont_copy_pte_range;

 				/* If it's a COW mapping, write protect it both in the parent and the child */
-				if (cow && pte_write(pte)) {
+				if (cow) {
 					ptep_set_wrprotect(src_pte);
 					pte = *src_pte;
 				}
@@ -285,6 +292,7 @@
 				dst->rss++;

 cont_copy_pte_range:		set_pte(dst_pte, pte);
+				page_add_rmap(ptepage, dst_pte);
 cont_copy_pte_range_noset:	address += PAGE_SIZE;
 				if (address >= end) {
 					pte_unmap_nested(src_pte);
@@ -342,6 +350,7 @@
 					if (pte_dirty(pte))
 						set_page_dirty(page);
 					tlb->freed++;
+					page_remove_rmap(page, ptep);
 					tlb_remove_page(tlb, page);
 				}
 			}
@@ -992,7 +1001,9 @@
 	if (pte_same(*page_table, pte)) {
 		if (PageReserved(old_page))
 			++mm->rss;
+		page_remove_rmap(old_page, page_table);
 		break_cow(vma, new_page, address, page_table);
+		page_add_rmap(new_page, page_table);
 		lru_cache_add(new_page);

 		/* Free the old page.. */
@@ -1199,6 +1210,7 @@
 	flush_page_to_ram(page);
 	flush_icache_page(vma, page);
 	set_pte(page_table, pte);
+	page_add_rmap(page, page_table);

 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
@@ -1215,14 +1227,13 @@
 static int do_anonymous_page(struct mm_struct * mm, struct vm_area_struct * vma, pte_t *page_table, pmd_t *pmd, int write_access, unsigned long addr)
 {
 	pte_t entry;
+	struct page * page = ZERO_PAGE(addr);

 	/* Read-only mapping of ZERO_PAGE. */
 	entry = pte_wrprotect(mk_pte(ZERO_PAGE(addr), vma->vm_page_prot));

 	/* ..except if it's a write access */
 	if (write_access) {
-		struct page *page;
-
 		/* Allocate our own private page. */
 		pte_unmap(page_table);
 		spin_unlock(&mm->page_table_lock);
@@ -1248,6 +1259,7 @@
 	}

 	set_pte(page_table, entry);
+	page_add_rmap(page, page_table); /* ignores ZERO_PAGE */
 	pte_unmap(page_table);

 	/* No need to invalidate - it was non-present before */
@@ -1327,6 +1339,7 @@
 		if (write_access)
 			entry = pte_mkwrite(pte_mkdirty(entry));
 		set_pte(page_table, entry);
+		page_add_rmap(new_page, page_table);
 		pte_unmap(page_table);
 	} else {
 		/* One of our sibling threads was faster, back out. */
diff -Nru a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c	Fri Jul  5 23:28:01 2002
+++ b/mm/mremap.c	Fri Jul  5 23:28:01 2002
@@ -68,8 +68,14 @@
 {
 	int error = 0;
 	pte_t pte;
+	struct page * page = NULL;
+
+	if (pte_present(*src))
+		page = pte_page(*src);

 	if (!pte_none(*src)) {
+		if (page)
+			page_remove_rmap(page, src);
 		pte = ptep_get_and_clear(src);
 		if (!dst) {
 			/* No dest?  We must put it back. */
@@ -77,6 +83,8 @@
 			error++;
 		}
 		set_pte(dst, pte);
+		if (page)
+			page_add_rmap(page, dst);
 	}
 	return error;
 }
diff -Nru a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	Fri Jul  5 23:28:00 2002
+++ b/mm/page_alloc.c	Fri Jul  5 23:28:00 2002
@@ -92,6 +92,7 @@
 	BUG_ON(PageLRU(page));
 	BUG_ON(PageActive(page));
 	BUG_ON(PageWriteback(page));
+	BUG_ON(page->pte_chain != NULL);
 	if (PageDirty(page))
 		ClearPageDirty(page);
 	BUG_ON(page_count(page) != 0);
diff -Nru a/mm/rmap.c b/mm/rmap.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/mm/rmap.c	Fri Jul  5 23:28:01 2002
@@ -0,0 +1,394 @@
+/*
+ * mm/rmap.c - physical to virtual reverse mappings
+ *
+ * Copyright 2001, Rik van Riel <riel@conectiva.com.br>
+ * Released under the General Public License (GPL).
+ *
+ *
+ * Simple, low overhead pte-based reverse mapping scheme.
+ * This is kept modular because we may want to experiment
+ * with object-based reverse mapping schemes. Please try
+ * to keep this thing as modular as possible.
+ */
+
+/*
+ * Locking:
+ * - the page->pte_chain is protected by the PG_chainlock bit,
+ *   which nests within the pagemap_lru_lock, then the
+ *   mm->page_table_lock, and then the page lock.
+ * - because swapout locking is opposite to the locking order
+ *   in the page fault path, the swapout path uses trylocks
+ *   on the mm->page_table_lock
+ */
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/swapops.h>
+
+#include <asm/pgalloc.h>
+#include <asm/rmap.h>
+#include <asm/smplock.h>
+#include <asm/tlb.h>
+#include <asm/tlbflush.h>
+
+/* #define DEBUG_RMAP */
+
+/*
+ * Shared pages have a chain of pte_chain structures, used to locate
+ * all the mappings to this page. We only need a pointer to the pte
+ * here, the page struct for the page table page contains the process
+ * it belongs to and the offset within that process.
+ *
+ * A singly linked list should be fine for most, if not all, workloads.
+ * On fork-after-exec the mapping we'll be removing will still be near
+ * the start of the list, on mixed application systems the short-lived
+ * processes will have their mappings near the start of the list and
+ * in systems with long-lived applications the relative overhead of
+ * exit() will be lower since the applications are long-lived.
+ */
+struct pte_chain {
+	struct pte_chain * next;
+	pte_t * ptep;
+};
+
+static inline struct pte_chain * pte_chain_alloc(void);
+static inline void pte_chain_free(struct pte_chain *, struct pte_chain *,
+		struct page *);
+static void alloc_new_pte_chains(void);
+
+/**
+ * page_referenced - test if the page was referenced
+ * @page: the page to test
+ *
+ * Quick test_and_clear_referenced for all mappings to a page,
+ * returns the number of processes which referenced the page.
+ * Caller needs to hold the pte_chain_lock.
+ */
+int page_referenced(struct page * page)
+{
+	struct pte_chain * pc;
+	int referenced = 0;
+
+	if (TestClearPageReferenced(page))
+		referenced++;
+
+	/* Check all the page tables mapping this page. */
+	for (pc = page->pte_chain; pc; pc = pc->next) {
+		if (ptep_test_and_clear_young(pc->ptep))
+			referenced++;
+	}
+	return referenced;
+}
+
+/**
+ * page_add_rmap - add reverse mapping entry to a page
+ * @page: the page to add the mapping to
+ * @ptep: the page table entry mapping this page
+ *
+ * Add a new pte reverse mapping to a page.
+ * The caller needs to hold the mm->page_table_lock.
+ */
+void page_add_rmap(struct page * page, pte_t * ptep)
+{
+	struct pte_chain * pte_chain;
+	unsigned long pfn = pte_pfn(*ptep);
+
+#ifdef DEBUG_RMAP
+	if (!page || !ptep)
+		BUG();
+	if (!pte_present(*ptep))
+		BUG();
+	if (!ptep_to_mm(ptep))
+		BUG();
+#endif
+
+	if (!pfn_valid(pfn) || PageReserved(page))
+		return;
+
+#ifdef DEBUG_RMAP
+	pte_chain_lock(page);
+	{
+		struct pte_chain * pc;
+		for (pc = page->pte_chain; pc; pc = pc->next) {
+			if (pc->ptep == ptep)
+				BUG();
+		}
+	}
+	pte_chain_unlock(page);
+#endif
+
+	pte_chain = pte_chain_alloc();
+
+	pte_chain_lock(page);
+
+	/* Hook up the pte_chain to the page. */
+	pte_chain->ptep = ptep;
+	pte_chain->next = page->pte_chain;
+	page->pte_chain = pte_chain;
+
+	pte_chain_unlock(page);
+}
+
+/**
+ * page_remove_rmap - take down reverse mapping to a page
+ * @page: page to remove mapping from
+ * @ptep: page table entry to remove
+ *
+ * Removes the reverse mapping from the pte_chain of the page,
+ * after that the caller can clear the page table entry and free
+ * the page.
+ * Caller needs to hold the mm->page_table_lock.
+ */
+void page_remove_rmap(struct page * page, pte_t * ptep)
+{
+	struct pte_chain * pc, * prev_pc = NULL;
+	unsigned long pfn = pte_pfn(*ptep);
+
+	if (!page || !ptep)
+		BUG();
+	if (!pfn_valid(pfn) || PageReserved(page))
+		return;
+
+	pte_chain_lock(page);
+	for (pc = page->pte_chain; pc; prev_pc = pc, pc = pc->next) {
+		if (pc->ptep == ptep) {
+			pte_chain_free(pc, prev_pc, page);
+			goto out;
+		}
+	}
+#ifdef DEBUG_RMAP
+	/* Not found. This should NEVER happen! */
+	printk(KERN_ERR "page_remove_rmap: pte_chain %p not present.\n", ptep);
+	printk(KERN_ERR "page_remove_rmap: only found: ");
+	for (pc = page->pte_chain; pc; pc = pc->next)
+		printk("%p ", pc->ptep);
+	printk("\n");
+	printk(KERN_ERR "page_remove_rmap: driver cleared PG_reserved ?\n");
+#endif
+
+out:
+	pte_chain_unlock(page);
+	return;
+
+}
+
+/**
+ * try_to_unmap_one - worker function for try_to_unmap
+ * @page: page to unmap
+ * @ptep: page table entry to unmap from page
+ *
+ * Internal helper function for try_to_unmap, called for each page
+ * table entry mapping a page. Because locking order here is opposite
+ * to the locking order used by the page fault path, we use trylocks.
+ * Locking:
+ *	pagemap_lru_lock		page_launder()
+ *	    page lock			page_launder(), trylock
+ *		pte_chain_lock		page_launder()
+ *		    mm->page_table_lock	try_to_unmap_one(), trylock
+ */
+static int FASTCALL(try_to_unmap_one(struct page *, pte_t *));
+static int try_to_unmap_one(struct page * page, pte_t * ptep)
+{
+	unsigned long address = ptep_to_address(ptep);
+	struct mm_struct * mm = ptep_to_mm(ptep);
+	struct vm_area_struct * vma;
+	pte_t pte;
+	int ret;
+
+	if (!mm)
+		BUG();
+
+	/*
+	 * We need the page_table_lock to protect us from page faults,
+	 * munmap, fork, etc...
+	 */
+	if (!spin_trylock(&mm->page_table_lock))
+		return SWAP_AGAIN;
+
+	/* During mremap, it's possible pages are not in a VMA. */
+	vma = find_vma(mm, address);
+	if (!vma) {
+		ret = SWAP_FAIL;
+		goto out_unlock;
+	}
+
+	/* The page is mlock()d, we cannot swap it out. */
+	if (vma->vm_flags & VM_LOCKED) {
+		ret = SWAP_FAIL;
+		goto out_unlock;
+	}
+
+	/* Nuke the page table entry. */
+	pte = ptep_get_and_clear(ptep);
+	flush_tlb_page(vma, address);
+	flush_cache_page(vma, address);
+
+	/* Store the swap location in the pte. See handle_pte_fault() ... */
+	if (PageSwapCache(page)) {
+		swp_entry_t entry;
+		entry.val = page->index;
+		swap_duplicate(entry);
+		set_pte(ptep, swp_entry_to_pte(entry));
+	}
+
+	/* Move the dirty bit to the physical page now the pte is gone. */
+	if (pte_dirty(pte))
+		set_page_dirty(page);
+
+	mm->rss--;
+	page_cache_release(page);
+	ret = SWAP_SUCCESS;
+
+out_unlock:
+	spin_unlock(&mm->page_table_lock);
+	return ret;
+}
+
+/**
+ * try_to_unmap - try to remove all page table mappings to a page
+ * @page: the page to get unmapped
+ *
+ * Tries to remove all the page table entries which are mapping this
+ * page, used in the pageout path.  Caller must hold pagemap_lru_lock
+ * and the page lock.  Return values are:
+ *
+ * SWAP_SUCCESS	- we succeeded in removing all mappings
+ * SWAP_AGAIN	- we missed a trylock, try again later
+ * SWAP_FAIL	- the page is unswappable
+ * SWAP_ERROR	- an error occurred
+ */
+int try_to_unmap(struct page * page)
+{
+	struct pte_chain * pc, * next_pc, * prev_pc = NULL;
+	int ret = SWAP_SUCCESS;
+
+	/* This page should not be on the pageout lists. */
+	if (PageReserved(page))
+		BUG();
+	if (!PageLocked(page))
+		BUG();
+	/* We need backing store to swap out a page. */
+	if (!page->mapping)
+		BUG();
+
+	for (pc = page->pte_chain; pc; pc = next_pc) {
+		next_pc = pc->next;
+		switch (try_to_unmap_one(page, pc->ptep)) {
+			case SWAP_SUCCESS:
+				/* Free the pte_chain struct. */
+				pte_chain_free(pc, prev_pc, page);
+				break;
+			case SWAP_AGAIN:
+				/* Skip this pte, remembering status. */
+				prev_pc = pc;
+				ret = SWAP_AGAIN;
+				continue;
+			case SWAP_FAIL:
+				return SWAP_FAIL;
+			case SWAP_ERROR:
+				return SWAP_ERROR;
+		}
+	}
+
+	return ret;
+}
+
+/**
+ ** No more VM stuff below this comment, only pte_chain helper
+ ** functions.
+ **/
+
+struct pte_chain * pte_chain_freelist;
+spinlock_t pte_chain_freelist_lock = SPIN_LOCK_UNLOCKED;
+
+/* Maybe we should have standard ops for singly linked lists ... - Rik */
+static inline void pte_chain_push(struct pte_chain * pte_chain)
+{
+	pte_chain->ptep = NULL;
+	pte_chain->next = pte_chain_freelist;
+	pte_chain_freelist = pte_chain;
+}
+
+static inline struct pte_chain * pte_chain_pop(void)
+{
+	struct pte_chain *pte_chain;
+
+	pte_chain = pte_chain_freelist;
+	pte_chain_freelist = pte_chain->next;
+	pte_chain->next = NULL;
+
+	return pte_chain;
+}
+
+/**
+ * pte_chain_free - free pte_chain structure
+ * @pte_chain: pte_chain struct to free
+ * @prev_pte_chain: previous pte_chain on the list (may be NULL)
+ * @page: page this pte_chain hangs off (may be NULL)
+ *
+ * This function unlinks pte_chain from the singly linked list it
+ * may be on and adds the pte_chain to the free list. May also be
+ * called for new pte_chain structures which aren't on any list yet.
+ * Caller needs to hold the pte_chain_lock if the page is non-NULL.
+ */
+static inline void pte_chain_free(struct pte_chain * pte_chain,
+		struct pte_chain * prev_pte_chain, struct page * page)
+{
+	if (prev_pte_chain)
+		prev_pte_chain->next = pte_chain->next;
+	else if (page)
+		page->pte_chain = pte_chain->next;
+
+	spin_lock(pte_chain_freelist_lock);
+	pte_chain_push(pte_chain);
+	spin_unlock(pte_chain_freelist_lock);
+}
+
+/**
+ * pte_chain_alloc - allocate a pte_chain struct
+ *
+ * Returns a pointer to a fresh pte_chain structure. Allocates new
+ * pte_chain structures as required.
+ * Caller needs to hold the page's pte_chain_lock.
+ */
+static inline struct pte_chain * pte_chain_alloc()
+{
+	struct pte_chain * pte_chain;
+
+	spin_lock(&pte_chain_freelist_lock);
+
+	/* Allocate new pte_chain structs as needed. */
+	if (!pte_chain_freelist)
+		alloc_new_pte_chains();
+
+	/* Grab the first pte_chain from the freelist. */
+	pte_chain = pte_chain_pop();
+
+	spin_unlock(&pte_chain_freelist_lock);
+
+	return pte_chain;
+}
+
+/**
+ * alloc_new_pte_chains - convert a free page to pte_chain structures
+ *
+ * Grabs a free page and converts it to pte_chain structures. We really
+ * should pre-allocate these earlier in the pagefault path or come up
+ * with some other trick.
+ *
+ * Note that we cannot use the slab cache because the pte_chain structure
+ * is way smaller than the minimum size of a slab cache allocation.
+ * Caller needs to hold the pte_chain_freelist_lock
+ */
+static void alloc_new_pte_chains()
+{
+	struct pte_chain * pte_chain = (void *) get_zeroed_page(GFP_ATOMIC);
+	int i = PAGE_SIZE / sizeof(struct pte_chain);
+
+	if (pte_chain) {
+		for (; i-- > 0; pte_chain++)
+			pte_chain_push(pte_chain);
+	} else {
+		/* Yeah yeah, I'll fix the pte_chain allocation ... */
+		panic("Fix pte_chain allocation, you lazy bastard!\n");
+	}
+}
diff -Nru a/mm/swap_state.c b/mm/swap_state.c
--- a/mm/swap_state.c	Fri Jul  5 23:28:01 2002
+++ b/mm/swap_state.c	Fri Jul  5 23:28:01 2002
@@ -105,6 +105,69 @@
 	INC_CACHE_INFO(del_total);
 }

+/**
+ * add_to_swap - allocate swap space for a page
+ * @page: page we want to move to swap
+ *
+ * Allocate swap space for the page and add the page to the
+ * swap cache.  Caller needs to hold the page lock.
+ */
+int add_to_swap(struct page * page)
+{
+	swp_entry_t entry;
+	int flags;
+
+	if (!PageLocked(page))
+		BUG();
+
+	for (;;) {
+		entry = get_swap_page();
+		if (!entry.val)
+			return 0;
+
+		/* Radix-tree node allocations are performing
+		 * GFP_ATOMIC allocations under PF_MEMALLOC.
+		 * They can completely exhaust the page allocator.
+		 *
+		 * So PF_MEMALLOC is dropped here.  This causes the slab
+		 * allocations to fail earlier, so radix-tree nodes will
+		 * then be allocated from the mempool reserves.
+		 *
+		 * We're still using __GFP_HIGH for radix-tree node
+		 * allocations, so some of the emergency pools are available,
+		 * just not all of them.
+		 */
+
+		flags = current->flags;
+		current->flags &= ~PF_MEMALLOC;
+		current->flags |= PF_NOWARN;
+		ClearPageUptodate(page);		/* why? */
+
+		/*
+		 * Add it to the swap cache and mark it dirty
+		 * (adding to the page cache will clear the dirty
+		 * and uptodate bits, so we need to do it again)
+		 */
+		switch (add_to_swap_cache(page, entry)) {
+		case 0:				/* Success */
+			current->flags = flags;
+			SetPageUptodate(page);
+			set_page_dirty(page);
+			swap_free(entry);
+			return 1;
+		case -ENOMEM:			/* radix-tree allocation */
+			current->flags = flags;
+			swap_free(entry);
+			return 0;
+		default:			/* ENOENT: raced */
+			break;
+		}
+		/* Raced with "speculative" read_swap_cache_async */
+		current->flags = flags;
+		swap_free(entry);
+	}
+}
+
 /*
  * This must be called only on pages that have
  * been verified to be in the swap cache and locked.
diff -Nru a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c	Fri Jul  5 23:28:00 2002
+++ b/mm/swapfile.c	Fri Jul  5 23:28:00 2002
@@ -383,6 +383,7 @@
 		return;
 	get_page(page);
 	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
+	page_add_rmap(page, dir);
 	swap_free(entry);
 	++vma->vm_mm->rss;
 }
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Fri Jul  5 23:28:00 2002
+++ b/mm/vmscan.c	Fri Jul  5 23:28:00 2002
@@ -42,347 +42,23 @@
 	return page_count(page) - !!PagePrivate(page) == 1;
 }

-/*
- * On the swap_out path, the radix-tree node allocations are performing
- * GFP_ATOMIC allocations under PF_MEMALLOC.  They can completely
- * exhaust the page allocator.  This is bad; some pages should be left
- * available for the I/O system to start sending the swapcache contents
- * to disk.
- *
- * So PF_MEMALLOC is dropped here.  This causes the slab allocations to fail
- * earlier, so radix-tree nodes will then be allocated from the mempool
- * reserves.
- *
- * We're still using __GFP_HIGH for radix-tree node allocations, so some of
- * the emergency pools are available - just not all of them.
- */
-static inline int
-swap_out_add_to_swap_cache(struct page *page, swp_entry_t entry)
-{
-	int flags = current->flags;
-	int ret;
-
-	current->flags &= ~PF_MEMALLOC;
-	current->flags |= PF_NOWARN;
-	ClearPageUptodate(page);		/* why? */
-	ClearPageReferenced(page);		/* why? */
-	ret = add_to_swap_cache(page, entry);
-	current->flags = flags;
-	return ret;
-}
-
-/*
- * The swap-out function returns 1 if it successfully
- * scanned all the pages it was asked to (`count').
- * It returns zero if it couldn't do anything,
- *
- * rss may decrease because pages are shared, but this
- * doesn't count as having freed a page.
- */
-
-/* mm->page_table_lock is held. mmap_sem is not held */
-static inline int try_to_swap_out(struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, struct page *page, zone_t * classzone)
+/* Must be called with page's pte_chain_lock held. */
+static inline int page_mapping_inuse(struct page * page)
 {
-	pte_t pte;
-	swp_entry_t entry;
-
-	/* Don't look at this pte if it's been accessed recently. */
-	if ((vma->vm_flags & VM_LOCKED) || ptep_test_and_clear_young(page_table)) {
-		mark_page_accessed(page);
-		return 0;
-	}
-
-	/* Don't bother unmapping pages that are active */
-	if (PageActive(page))
-		return 0;
+	struct address_space *mapping = page->mapping;

-	/* Don't bother replenishing zones not under pressure.. */
-	if (!memclass(page_zone(page), classzone))
-		return 0;
+	/* Page is in somebody's page tables. */
+	if (page->pte_chain)
+		return 1;

-	if (TestSetPageLocked(page))
+	/* XXX: does this happen ? */
+	if (!mapping)
 		return 0;

-	if (PageWriteback(page))
-		goto out_unlock;
-
-	/* From this point on, the odds are that we're going to
-	 * nuke this pte, so read and clear the pte.  This hook
-	 * is needed on CPUs which update the accessed and dirty
-	 * bits in hardware.
-	 */
-	flush_cache_page(vma, address);
-	pte = ptep_get_and_clear(page_table);
-	flush_tlb_page(vma, address);
-
-	if (pte_dirty(pte))
-		set_page_dirty(page);
-
-	/*
-	 * Is the page already in the swap cache? If so, then
-	 * we can just drop our reference to it without doing
-	 * any IO - it's already up-to-date on disk.
-	 */
-	if (PageSwapCache(page)) {
-		entry.val = page->index;
-		swap_duplicate(entry);
-set_swap_pte:
-		set_pte(page_table, swp_entry_to_pte(entry));
-drop_pte:
-		mm->rss--;
-		unlock_page(page);
-		{
-			int freeable = page_count(page) -
-				!!PagePrivate(page) <= 2;
-			page_cache_release(page);
-			return freeable;
-		}
-	}
-
-	/*
-	 * Is it a clean page? Then it must be recoverable
-	 * by just paging it in again, and we can just drop
-	 * it..  or if it's dirty but has backing store,
-	 * just mark the page dirty and drop it.
-	 *
-	 * However, this won't actually free any real
-	 * memory, as the page will just be in the page cache
-	 * somewhere, and as such we should just continue
-	 * our scan.
-	 *
-	 * Basically, this just makes it possible for us to do
-	 * some real work in the future in "refill_inactive()".
-	 */
-	if (page->mapping)
-		goto drop_pte;
-	if (!PageDirty(page))
-		goto drop_pte;
-
-	/*
-	 * Anonymous buffercache pages can be left behind by
-	 * concurrent truncate and pagefault.
-	 */
-	if (PagePrivate(page))
-		goto preserve;
-
-	/*
-	 * This is a dirty, swappable page.  First of all,
-	 * get a suitable swap entry for it, and make sure
-	 * we have the swap cache set up to associate the
-	 * page with that swap entry.
-	 */
-	for (;;) {
-		entry = get_swap_page();
-		if (!entry.val)
-			break;
-		/* Add it to the swap cache and mark it dirty
-		 * (adding to the page cache will clear the dirty
-		 * and uptodate bits, so we need to do it again)
-		 */
-		switch (swap_out_add_to_swap_cache(page, entry)) {
-		case 0:				/* Success */
-			SetPageUptodate(page);
-			set_page_dirty(page);
-			goto set_swap_pte;
-		case -ENOMEM:			/* radix-tree allocation */
-			swap_free(entry);
-			goto preserve;
-		default:			/* ENOENT: raced */
-			break;
-		}
-		/* Raced with "speculative" read_swap_cache_async */
-		swap_free(entry);
-	}
+	/* File is mmap'd by somebody. */
+	if (!list_empty(&mapping->i_mmap) || !list_empty(&mapping->i_mmap_shared))
+		return 1;

-	/* No swap space left */
-preserve:
-	set_pte(page_table, pte);
-out_unlock:
-	unlock_page(page);
-	return 0;
-}
-
-/* mm->page_table_lock is held. mmap_sem is not held */
-static inline int swap_out_pmd(struct mm_struct * mm, struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int count, zone_t * classzone)
-{
-	pte_t * pte;
-	unsigned long pmd_end;
-
-	if (pmd_none(*dir))
-		return count;
-	if (pmd_bad(*dir)) {
-		pmd_ERROR(*dir);
-		pmd_clear(dir);
-		return count;
-	}
-
-	pte = pte_offset_map(dir, address);
-
-	pmd_end = (address + PMD_SIZE) & PMD_MASK;
-	if (end > pmd_end)
-		end = pmd_end;
-
-	do {
-		if (pte_present(*pte)) {
-			unsigned long pfn = pte_pfn(*pte);
-			struct page *page = pfn_to_page(pfn);
-
-			if (pfn_valid(pfn) && !PageReserved(page)) {
-				count -= try_to_swap_out(mm, vma, address, pte, page, classzone);
-				if (!count) {
-					address += PAGE_SIZE;
-					pte++;
-					break;
-				}
-			}
-		}
-		address += PAGE_SIZE;
-		pte++;
-	} while (address && (address < end));
-	pte_unmap(pte - 1);
-	mm->swap_address = address;
-	return count;
-}
-
-/* mm->page_table_lock is held. mmap_sem is not held */
-static inline int swap_out_pgd(struct mm_struct * mm, struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int count, zone_t * classzone)
-{
-	pmd_t * pmd;
-	unsigned long pgd_end;
-
-	if (pgd_none(*dir))
-		return count;
-	if (pgd_bad(*dir)) {
-		pgd_ERROR(*dir);
-		pgd_clear(dir);
-		return count;
-	}
-
-	pmd = pmd_offset(dir, address);
-
-	pgd_end = (address + PGDIR_SIZE) & PGDIR_MASK;
-	if (pgd_end && (end > pgd_end))
-		end = pgd_end;
-
-	do {
-		count = swap_out_pmd(mm, vma, pmd, address, end, count, classzone);
-		if (!count)
-			break;
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address && (address < end));
-	return count;
-}
-
-/* mm->page_table_lock is held. mmap_sem is not held */
-static inline int swap_out_vma(struct mm_struct * mm, struct vm_area_struct * vma, unsigned long address, int count, zone_t * classzone)
-{
-	pgd_t *pgdir;
-	unsigned long end;
-
-	/* Don't swap out areas which are reserved */
-	if (vma->vm_flags & VM_RESERVED)
-		return count;
-
-	pgdir = pgd_offset(mm, address);
-
-	end = vma->vm_end;
-	if (address >= end)
-		BUG();
-	do {
-		count = swap_out_pgd(mm, vma, pgdir, address, end, count, classzone);
-		if (!count)
-			break;
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		pgdir++;
-	} while (address && (address < end));
-	return count;
-}
-
-/* Placeholder for swap_out(): may be updated by fork.c:mmput() */
-struct mm_struct *swap_mm = &init_mm;
-
-/*
- * Returns remaining count of pages to be swapped out by followup call.
- */
-static inline int swap_out_mm(struct mm_struct * mm, int count, int * mmcounter, zone_t * classzone)
-{
-	unsigned long address;
-	struct vm_area_struct* vma;
-
-	/*
-	 * Find the proper vm-area after freezing the vma chain
-	 * and ptes.
-	 */
-	spin_lock(&mm->page_table_lock);
-	address = mm->swap_address;
-	if (address == TASK_SIZE || swap_mm != mm) {
-		/* We raced: don't count this mm but try again */
-		++*mmcounter;
-		goto out_unlock;
-	}
-	vma = find_vma(mm, address);
-	if (vma) {
-		if (address < vma->vm_start)
-			address = vma->vm_start;
-
-		for (;;) {
-			count = swap_out_vma(mm, vma, address, count, classzone);
-			vma = vma->vm_next;
-			if (!vma)
-				break;
-			if (!count)
-				goto out_unlock;
-			address = vma->vm_start;
-		}
-	}
-	/* Indicate that we reached the end of address space */
-	mm->swap_address = TASK_SIZE;
-
-out_unlock:
-	spin_unlock(&mm->page_table_lock);
-	return count;
-}
-
-static int FASTCALL(swap_out(unsigned int priority, unsigned int gfp_mask, zone_t * classzone));
-static int swap_out(unsigned int priority, unsigned int gfp_mask, zone_t * classzone)
-{
-	int counter, nr_pages = SWAP_CLUSTER_MAX;
-	struct mm_struct *mm;
-
-	counter = mmlist_nr;
-	do {
-		if (need_resched()) {
-			__set_current_state(TASK_RUNNING);
-			schedule();
-		}
-
-		spin_lock(&mmlist_lock);
-		mm = swap_mm;
-		while (mm->swap_address == TASK_SIZE || mm == &init_mm) {
-			mm->swap_address = 0;
-			mm = list_entry(mm->mmlist.next, struct mm_struct, mmlist);
-			if (mm == swap_mm)
-				goto empty;
-			swap_mm = mm;
-		}
-
-		/* Make sure the mm doesn't disappear when we drop the lock.. */
-		atomic_inc(&mm->mm_users);
-		spin_unlock(&mmlist_lock);
-
-		nr_pages = swap_out_mm(mm, nr_pages, &counter, classzone);
-
-		mmput(mm);
-
-		if (!nr_pages)
-			return 1;
-	} while (--counter >= 0);
-
-	return 0;
-
-empty:
-	spin_unlock(&mmlist_lock);
 	return 0;
 }

@@ -392,7 +68,6 @@
 {
 	struct list_head * entry;
 	struct address_space *mapping;
-	int max_mapped = nr_pages << (9 - priority);

 	spin_lock(&pagemap_lru_lock);
 	while (--max_scan >= 0 &&
@@ -428,10 +103,6 @@
 		if (!memclass(page_zone(page), classzone))
 			continue;

-		/* Racy check to avoid trylocking when not worthwhile */
-		if (!PagePrivate(page) && (page_count(page) != 1 || !page->mapping))
-			goto page_mapped;
-
 		/*
 		 * swap activity never enters the filesystem and is safe
 		 * for GFP_NOFS allocations.
@@ -461,6 +132,59 @@
 			continue;
 		}

+		/*
+		 * The page is in active use or really unfreeable. Move to
+		 * the active list.
+		 */
+		pte_chain_lock(page);
+		if (page_referenced(page) && page_mapping_inuse(page)) {
+			del_page_from_inactive_list(page);
+			add_page_to_active_list(page);
+			pte_chain_unlock(page);
+			unlock_page(page);
+			continue;
+		}
+
+		/*
+		 * Anonymous process memory without backing store. Try to
+		 * allocate it some swap space here.
+		 *
+		 * XXX: implement swap clustering ?
+		 */
+		if (page->pte_chain && !page->mapping && !PagePrivate(page)) {
+			page_cache_get(page);
+			pte_chain_unlock(page);
+			spin_unlock(&pagemap_lru_lock);
+			if (!add_to_swap(page)) {
+				activate_page(page);
+				unlock_page(page);
+				page_cache_release(page);
+				spin_lock(&pagemap_lru_lock);
+				continue;
+			}
+			page_cache_release(page);
+			spin_lock(&pagemap_lru_lock);
+			pte_chain_lock(page);
+		}
+
+		/*
+		 * The page is mapped into the page tables of one or more
+		 * processes. Try to unmap it here.
+		 */
+		if (page->pte_chain) {
+			switch (try_to_unmap(page)) {
+				case SWAP_ERROR:
+				case SWAP_FAIL:
+					goto page_active;
+				case SWAP_AGAIN:
+					pte_chain_unlock(page);
+					unlock_page(page);
+					continue;
+				case SWAP_SUCCESS:
+					; /* try to free the page below */
+			}
+		}
+		pte_chain_unlock(page);
 		mapping = page->mapping;

 		if (PageDirty(page) && is_page_cache_freeable(page) &&
@@ -469,7 +193,7 @@
 			 * It is not critical here to write it only if
 			 * the page is unmapped beause any direct writer
 			 * like O_DIRECT would set the page's dirty bitflag
-			 * on the phisical page after having successfully
+			 * on the physical page after having successfully
 			 * pinned it and after the I/O to the page is finished,
 			 * so the direct writes to the page cannot get lost.
 			 */
@@ -557,18 +281,7 @@
 			write_unlock(&mapping->page_lock);
 		}
 		unlock_page(page);
-page_mapped:
-		if (--max_mapped >= 0)
-			continue;
-
-		/*
-		 * Alert! We've found too many mapped pages on the
-		 * inactive list, so we start swapping out now!
-		 */
-		spin_unlock(&pagemap_lru_lock);
-		swap_out(priority, gfp_mask, classzone);
-		return nr_pages;
-
+		continue;
 page_freeable:
 		/*
 		 * It is critical to check PageDirty _after_ we made sure
@@ -597,13 +310,21 @@

 		/* effectively free the page here */
 		page_cache_release(page);
-
 		if (--nr_pages)
 			continue;
-		break;
+		goto out;
+page_active:
+		/*
+		 * OK, we don't know what to do with the page.
+		 * It's no use keeping it here, so we move it to
+		 * the active list.
+		 */
+		del_page_from_inactive_list(page);
+		add_page_to_active_list(page);
+		pte_chain_unlock(page);
+		unlock_page(page);
 	}
-	spin_unlock(&pagemap_lru_lock);
-
+out:	spin_unlock(&pagemap_lru_lock);
 	return nr_pages;
 }

@@ -611,8 +332,8 @@
  * This moves pages from the active list to
  * the inactive list.
  *
- * We move them the other way when we see the
- * reference bit on the page.
+ * We move them the other way if the page is
+ * referenced by one or more processes, from rmap
  */
 static void refill_inactive(int nr_pages)
 {
@@ -625,15 +346,17 @@

 		page = list_entry(entry, struct page, lru);
 		entry = entry->prev;
-		if (TestClearPageReferenced(page)) {
+
+		pte_chain_lock(page);
+		if (page->pte_chain && page_referenced(page)) {
 			list_del(&page->lru);
 			list_add(&page->lru, &active_list);
+			pte_chain_unlock(page);
 			continue;
 		}
-
 		del_page_from_active_list(page);
 		add_page_to_inactive_list(page);
-		SetPageReferenced(page);
+		pte_chain_unlock(page);
 	}
 	spin_unlock(&pagemap_lru_lock);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
