Date: Tue, 17 Sep 2002 13:21:58 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Rollup patch of basic rmap against 2.5.26
Message-ID: <41260000.1032286918@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1845559384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Scalability Effort List <lse-tech@lists.sourceforge.net>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========1845559384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Over the past couple of weeks we've been doing some basic performance
testing of the rmap overhead.  For this I put together a rollup patch
against 2.5.26 that includes what I'd consider basic rmap.  As a reference,
I'm also posting the patch here, so people can see what it consists of.

The list of patches included are:

	minrmap		The original minimal rmap patch
	truncate_leak		A bug fix
	dmc_optimize		Don't allocate pte_chain for one mapping
	vmstat			Add rmap statistics for vmstat
	ptechain slab		Allocate pte_chains from a slab
	daniel_rmap_speedup	Use hashed pte_chain locks
	akpm_rmap_speedup	Make pte_chain hold multiple pte ptrs

Again, this patch applies against 2.5.26, and clearly does not include many
of the recent rmap optimizations.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1845559384==========
Content-Type: text/plain; charset=iso-8859-1; name="rmap-rollup-2.5.26.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="rmap-rollup-2.5.26.diff";
 size=68045

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or =
higher.
# This patch includes the following deltas:
#	           ChangeSet	1.737   -> 1.745 =20
#	include/linux/swap.h	1.47    -> 1.49  =20
#	  include/linux/mm.h	1.56    -> 1.58  =20
#	     mm/page_alloc.c	1.78    -> 1.83  =20
#	       kernel/fork.c	1.49    -> 1.50  =20
#	         mm/vmscan.c	1.81    -> 1.87  =20
#	 fs/proc/proc_misc.c	1.30    -> 1.32  =20
#	include/linux/page-flags.h	1.9     -> 1.14  =20
#	         init/main.c	1.49    -> 1.51  =20
#	       mm/swapfile.c	1.52    -> 1.53  =20
#	        mm/filemap.c	1.108   -> 1.112 =20
#	           fs/exec.c	1.31    -> 1.32  =20
#	           mm/swap.c	1.16    -> 1.18  =20
#	include/linux/kernel_stat.h	1.5     -> 1.6   =20
#	     mm/swap_state.c	1.33    -> 1.35  =20
#	         mm/memory.c	1.74    -> 1.78  =20
#	         mm/mremap.c	1.13    -> 1.14  =20
#	         mm/Makefile	1.11    -> 1.12  =20
#	               (new)	        -> 1.1     include/asm-cris/rmap.h
#	               (new)	        -> 1.1     include/asm-mips/rmap.h
#	               (new)	        -> 1.1     include/asm-sparc/rmap.h
#	               (new)	        -> 1.1     include/asm-ppc/rmap.h
#	               (new)	        -> 1.1     include/asm-sparc64/rmap.h
#	               (new)	        -> 1.3     include/asm-generic/rmap.h
#	               (new)	        -> 1.1     include/linux/rmap-locking.h
#	               (new)	        -> 1.1     include/asm-m68k/rmap.h
#	               (new)	        -> 1.1     include/asm-arm/rmap.h
#	               (new)	        -> 1.1     include/asm-s390/rmap.h
#	               (new)	        -> 1.1     include/asm-mips64/rmap.h
#	               (new)	        -> 1.1     include/asm-i386/rmap.h
#	               (new)	        -> 1.7     mm/rmap.c     =20
#	               (new)	        -> 1.1     include/asm-alpha/rmap.h
#	               (new)	        -> 1.1     include/asm-parisc/rmap.h
#	               (new)	        -> 1.1     include/asm-sh/rmap.h
#	               (new)	        -> 1.1     include/asm-ia64/rmap.h
#	               (new)	        -> 1.1     include/asm-s390x/rmap.h
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/08/15	dmc@baldur.austin.ibm.com	1.738
# 00_minrmap.txt
# --------------------------------------------
# 02/08/15	dmc@baldur.austin.ibm.com	1.739
# 01_truncate_leak.txt
# --------------------------------------------
# 02/08/15	dmc@baldur.austin.ibm.com	1.740
# 02_dmc_optimize.txt
# --------------------------------------------
# 02/08/15	dmc@baldur.austin.ibm.com	1.741
# Merge vmstat patch
# --------------------------------------------
# 02/08/15	dmc@baldur.austin.ibm.com	1.742
# Merge ptechains from slab
# --------------------------------------------
# 02/08/15	dmc@baldur.austin.ibm.com	1.743
# Merge daniel-rmap-speedup
# --------------------------------------------
# 02/08/15	dmc@baldur.austin.ibm.com	1.744
#  Merge akpm rmap-speedup
# --------------------------------------------
# 02/08/15	dmc@baldur.austin.ibm.com	1.745
#  Resolve merge errors
# --------------------------------------------
#
diff -Nru a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c	Fri Aug 16 16:23:23 2002
+++ b/fs/exec.c	Fri Aug 16 16:23:23 2002
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
diff -Nru a/fs/proc/proc_misc.c b/fs/proc/proc_misc.c
--- a/fs/proc/proc_misc.c	Fri Aug 16 16:23:23 2002
+++ b/fs/proc/proc_misc.c	Fri Aug 16 16:23:23 2002
@@ -159,7 +159,9 @@
 		"SwapTotal:    %8lu kB\n"
 		"SwapFree:     %8lu kB\n"
 		"Dirty:        %8lu kB\n"
-		"Writeback:    %8lu kB\n",
+		"Writeback:    %8lu kB\n"
+		"PageTables:   %8lu kB\n"
+		"ReverseMaps:  %8lu\n",
 		K(i.totalram),
 		K(i.freeram),
 		K(i.sharedram),
@@ -174,7 +176,9 @@
 		K(i.totalswap),
 		K(i.freeswap),
 		K(ps.nr_dirty),
-		K(ps.nr_writeback)
+		K(ps.nr_writeback),
+		K(ps.nr_page_table_pages),
+		ps.nr_reverse_maps
 		);
=20
 	return proc_calc_metrics(page, start, off, count, eof, len);
@@ -347,9 +351,29 @@
 	}
=20
 	len +=3D sprintf(page + len,
-		"\nctxt %lu\n"
+		"\npageallocs %u\n"
+		"pagefrees %u\n"
+		"pageactiv %u\n"
+		"pagedeact %u\n"
+		"pagefault %u\n"
+		"majorfault %u\n"
+		"pagescan %u\n"
+		"pagesteal %u\n"
+		"pageoutrun %u\n"
+		"allocstall %u\n"
+		"ctxt %lu\n"
 		"btime %lu\n"
 		"processes %lu\n",
+		kstat.pgalloc,
+		kstat.pgfree,
+		kstat.pgactivate,
+		kstat.pgdeactivate,
+		kstat.pgfault,
+		kstat.pgmajfault,
+		kstat.pgscan,
+		kstat.pgsteal,
+		kstat.pageoutrun,
+		kstat.allocstall,
 		nr_context_switches(),
 		xtime.tv_sec - jif / HZ,
 		total_forks);
diff -Nru a/include/asm-alpha/rmap.h b/include/asm-alpha/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-alpha/rmap.h	Fri Aug 16 16:23:23 2002
@@ -0,0 +1,7 @@
+#ifndef _ALPHA_RMAP_H
+#define _ALPHA_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/asm-arm/rmap.h b/include/asm-arm/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-arm/rmap.h	Fri Aug 16 16:23:23 2002
@@ -0,0 +1,7 @@
+#ifndef _ARM_RMAP_H
+#define _ARM_RMAP_H
+
+/* nothing to see, move along :) */
+#include <asm-generic/rmap.h>
+
+#endif /* _ARM_RMAP_H */
diff -Nru a/include/asm-cris/rmap.h b/include/asm-cris/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-cris/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-generic/rmap.h	Fri Aug 16 16:23:23 2002
@@ -0,0 +1,55 @@
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
+#include <linux/rmap-locking.h>
+
+static inline void pgtable_add_rmap(struct page * page, struct mm_struct * =
mm, unsigned long address)
+{
+#ifdef BROKEN_PPC_PTE_ALLOC_ONE
+	/* OK, so PPC calls pte_alloc() before mem_map[] is setup ... ;( */
+	extern int mem_init_done;
+
+	if (!mem_init_done)
+		return;
+#endif
+	page->mapping =3D (void *)mm;
+	page->index =3D address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
+	inc_page_state(nr_page_table_pages);
+}
+
+static inline void pgtable_remove_rmap(struct page * page)
+{
+	page->mapping =3D NULL;
+	page->index =3D 0;
+	dec_page_state(nr_page_table_pages);
+}
+
+static inline struct mm_struct * ptep_to_mm(pte_t * ptep)
+{
+	struct page * page =3D virt_to_page(ptep);
+	return (struct mm_struct *) page->mapping;
+}
+
+static inline unsigned long ptep_to_address(pte_t * ptep)
+{
+	struct page * page =3D virt_to_page(ptep);
+	unsigned long low_bits;
+	low_bits =3D ((unsigned long)ptep & ~PAGE_MASK) * PTRS_PER_PTE;
+	return page->index + low_bits;
+}
+
+#endif /* _GENERIC_RMAP_H */
diff -Nru a/include/asm-i386/rmap.h b/include/asm-i386/rmap.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-i386/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-ia64/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-m68k/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-mips/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-mips64/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-parisc/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-ppc/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-s390/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-s390x/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-sh/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-sparc/rmap.h	Fri Aug 16 16:23:23 2002
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
+++ b/include/asm-sparc64/rmap.h	Fri Aug 16 16:23:23 2002
@@ -0,0 +1,7 @@
+#ifndef _SPARC64_RMAP_H
+#define _SPARC64_RMAP_H
+
+/* nothing to see, move along */
+#include <asm-generic/rmap.h>
+
+#endif
diff -Nru a/include/linux/kernel_stat.h b/include/linux/kernel_stat.h
--- a/include/linux/kernel_stat.h	Fri Aug 16 16:23:23 2002
+++ b/include/linux/kernel_stat.h	Fri Aug 16 16:23:23 2002
@@ -26,6 +26,11 @@
 	unsigned int dk_drive_wblk[DK_MAX_MAJOR][DK_MAX_DISK];
 	unsigned int pgpgin, pgpgout;
 	unsigned int pswpin, pswpout;
+	unsigned int pgalloc, pgfree;
+	unsigned int pgactivate, pgdeactivate;
+	unsigned int pgfault, pgmajfault;
+	unsigned int pgscan, pgsteal;
+	unsigned int pageoutrun, allocstall;
 #if !defined(CONFIG_ARCH_S390)
 	unsigned int irqs[NR_CPUS][NR_IRQS];
 #endif
@@ -34,6 +39,13 @@
 extern struct kernel_stat kstat;
=20
 extern unsigned long nr_context_switches(void);
+
+/*
+ * Maybe we need to smp-ify kernel_stat some day. It would be nice to do
+ * that without having to modify all the code that increments the stats.
+ */
+#define KERNEL_STAT_INC(x) kstat.x++
+#define KERNEL_STAT_ADD(x, y) kstat.x +=3D y
=20
 #if !defined(CONFIG_ARCH_S390)
 /*
diff -Nru a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h	Fri Aug 16 16:23:23 2002
+++ b/include/linux/mm.h	Fri Aug 16 16:23:23 2002
@@ -130,6 +130,9 @@
 	struct page * (*nopage)(struct vm_area_struct * area, unsigned long =
address, int unused);
 };
=20
+/* forward declaration; pte_chain is meant to be internal to rmap.c */
+struct pte_chain;
+
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -154,6 +157,11 @@
 					   updated asynchronously */
 	struct list_head lru;		/* Pageout list, eg. active_list;
 					   protected by pagemap_lru_lock !! */
+	union {
+		struct pte_chain * chain;	/* Reverse pte mapping pointer.
+					 * protected by PG_chainlock */
+		pte_t		 * direct;
+	} pte;
 	unsigned long private;		/* mapping-private opaque data */
=20
 	/*
diff -Nru a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h	Fri Aug 16 16:23:23 2002
+++ b/include/linux/page-flags.h	Fri Aug 16 16:23:23 2002
@@ -47,7 +47,7 @@
  * locked- and dirty-page accounting.  The top eight bits of page->flags =
are
  * used for page->zone, so putting flag bits there doesn't work.
  */
-#define PG_locked	 0	/* Page is locked. Don't touch. */
+#define PG_locked	 	 0	/* Page is locked. Don't touch. */
 #define PG_error		 1
 #define PG_referenced		 2
 #define PG_uptodate		 3
@@ -64,7 +64,8 @@
=20
 #define PG_private		12	/* Has something at ->private */
 #define PG_writeback		13	/* Page is under writeback */
-#define PG_nosave		15	/* Used for system suspend/resume */
+#define PG_nosave		14	/* Used for system suspend/resume */
+#define PG_direct		15	/* ->pte_chain points directly at pte */
=20
 /*
  * Global page accounting.  One instance per CPU.
@@ -75,6 +76,8 @@
 	unsigned long nr_pagecache;
 	unsigned long nr_active;	/* on active_list LRU */
 	unsigned long nr_inactive;	/* on inactive_list LRU */
+ 	unsigned long nr_page_table_pages;
+	unsigned long nr_reverse_maps;
 } ____cacheline_aligned_in_smp page_states[NR_CPUS];
=20
 extern void get_page_state(struct page_state *ret);
@@ -215,6 +218,12 @@
 #define TestSetPageNosave(page)	test_and_set_bit(PG_nosave, =
&(page)->flags)
 #define ClearPageNosave(page)		clear_bit(PG_nosave, &(page)->flags)
 #define TestClearPageNosave(page)	test_and_clear_bit(PG_nosave, =
&(page)->flags)
+
+#define PageDirect(page)	test_bit(PG_direct, &(page)->flags)
+#define SetPageDirect(page)	set_bit(PG_direct, &(page)->flags)
+#define TestSetPageDirect(page)	test_and_set_bit(PG_direct, =
&(page)->flags)
+#define ClearPageDirect(page)		clear_bit(PG_direct, &(page)->flags)
+#define TestClearPageDirect(page)	test_and_clear_bit(PG_direct, =
&(page)->flags)
=20
 /*
  * The PageSwapCache predicate doesn't use a PG_flag at this time,
diff -Nru a/include/linux/rmap-locking.h b/include/linux/rmap-locking.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/linux/rmap-locking.h	Fri Aug 16 16:23:23 2002
@@ -0,0 +1,109 @@
+/*
+ * include/linux/rmap-locking.h
+ */
+
+#ifdef CONFIG_SMP
+#define NUM_RMAP_LOCKS	256
+#else
+#define NUM_RMAP_LOCKS	1	/* save some RAM */
+#endif
+
+extern spinlock_t rmap_locks[NUM_RMAP_LOCKS];
+
+#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
+/*
+ * Each page has a singly-linked list of pte_chain objects attached to it.
+ * These point back at the pte's which are mapping that page.   Exclusion
+ * is needed while altering that chain, for which we use a hashed lock, =
based
+ * on page->index.  The kernel attempts to ensure that =
virtually-contiguous
+ * pages have similar page->index values.  Using this, several hotpaths =
are
+ * able to hold onto a spinlock across multiple pages, dropping the lock =
and
+ * acquiring a new one only when a page which hashes onto a different lock =
is
+ * encountered.
+ *
+ * The hash tries to ensure that 16 contiguous pages share the same lock.
+ */
+static inline unsigned rmap_lockno(pgoff_t index)
+{
+	return (index >> 4) & (ARRAY_SIZE(rmap_locks) - 1);
+}
+
+static inline spinlock_t *lock_rmap(struct page *page)
+{
+	pgoff_t index =3D page->index;
+	while (1) {
+		spinlock_t *lock =3D rmap_locks + rmap_lockno(index);
+		spin_lock(lock);
+		if (index =3D=3D page->index)
+			return lock;
+		spin_unlock(lock);
+	}	
+}
+
+static inline void unlock_rmap(spinlock_t *lock)
+{
+	spin_unlock(lock);
+}
+
+/*
+ * Need to take the lock while changing ->index because someone else may
+ * be using page->pte.  Changing the index here will change the page's
+ * lock address and would allow someone else to think that they had locked
+ * the pte_chain when it is in fact in use.
+ */
+static inline void set_page_index(struct page *page, pgoff_t index)
+{
+	spinlock_t *lock =3D lock_rmap(page);
+	page->index =3D index;
+	spin_unlock(lock);
+}
+
+static inline void drop_rmap_lock(spinlock_t **lock, unsigned =
*last_lockno)
+{
+	if (*lock) {
+		unlock_rmap(*lock);
+		*lock =3D NULL;
+		*last_lockno =3D -1;
+	}
+}
+
+static inline void
+cached_rmap_lock(struct page *page, spinlock_t **lock, unsigned =
*last_lockno)
+{
+	if (*lock =3D=3D NULL) {
+		*lock =3D lock_rmap(page);
+	} else {
+		if (*last_lockno !=3D rmap_lockno(page->index)) {
+			unlock_rmap(*lock);
+			*lock =3D lock_rmap(page);
+			*last_lockno =3D rmap_lockno(page->index);
+		}
+	}
+}
+#endif	/* defined(CONFIG_SMP) || defined(CONFIG_PREEMPT) */
+
+
+#if !defined(CONFIG_SMP) && !defined(CONFIG_PREEMPT)
+static inline spinlock_t *lock_rmap(struct page *page)
+{
+	return (spinlock_t *)1;
+}
+
+static inline void unlock_rmap(spinlock_t *lock)
+{
+}
+
+static inline void set_page_index(struct page *page, pgoff_t index)
+{
+	page->index =3D index;
+}
+
+static inline void drop_rmap_lock(spinlock_t **lock, unsigned =
*last_lockno)
+{
+}
+
+static inline void
+cached_rmap_lock(struct page *page, spinlock_t **lock, unsigned =
*last_lockno)
+{
+}
+#endif	/* !defined(CONFIG_SMP) && !defined(CONFIG_PREEMPT) */
diff -Nru a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h	Fri Aug 16 16:23:23 2002
+++ b/include/linux/swap.h	Fri Aug 16 16:23:23 2002
@@ -142,6 +142,21 @@
 struct address_space;
 struct zone_t;
=20
+/* linux/mm/rmap.c */
+extern int FASTCALL(page_referenced(struct page *));
+extern void FASTCALL(__page_add_rmap(struct page *, pte_t *));
+extern void FASTCALL(page_add_rmap(struct page *, pte_t *));
+extern void FASTCALL(__page_remove_rmap(struct page *, pte_t *));
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
@@ -168,6 +183,7 @@
 extern void show_swap_cache_info(void);
 #endif
 extern int add_to_swap_cache(struct page *, swp_entry_t);
+extern int add_to_swap(struct page *);
 extern void __delete_from_swap_cache(struct page *page);
 extern void delete_from_swap_cache(struct page *page);
 extern int move_to_swap_cache(struct page *page, swp_entry_t entry);
diff -Nru a/init/main.c b/init/main.c
--- a/init/main.c	Fri Aug 16 16:23:23 2002
+++ b/init/main.c	Fri Aug 16 16:23:23 2002
@@ -28,6 +28,7 @@
 #include <linux/bootmem.h>
 #include <linux/tty.h>
 #include <linux/percpu.h>
+#include <linux/kernel_stat.h>
=20
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -68,7 +69,7 @@
 extern void sysctl_init(void);
 extern void signals_init(void);
 extern void buffer_init(void);
-
+extern void pte_chain_init(void);
 extern void radix_tree_init(void);
 extern void free_initmem(void);
=20
@@ -384,7 +385,7 @@
 	mem_init();
 	kmem_cache_sizes_init();
 	pgtable_cache_init();
-
+	pte_chain_init();
 	mempages =3D num_physpages;
=20
 	fork_init(mempages);
@@ -501,6 +502,8 @@
 	 */
 	free_initmem();
 	unlock_kernel();
+
+	kstat.pgfree =3D 0;
=20
 	if (open("/dev/console", O_RDWR, 0) < 0)
 		printk("Warning: unable to open an initial console.\n");
diff -Nru a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c	Fri Aug 16 16:23:23 2002
+++ b/kernel/fork.c	Fri Aug 16 16:23:23 2002
@@ -189,7 +189,6 @@
 	mm->map_count =3D 0;
 	mm->rss =3D 0;
 	mm->cpu_vm_mask =3D 0;
-	mm->swap_address =3D 0;
 	pprev =3D &mm->mmap;
=20
 	/*
@@ -308,9 +307,6 @@
 void mmput(struct mm_struct *mm)
 {
 	if (atomic_dec_and_lock(&mm->mm_users, &mmlist_lock)) {
-		extern struct mm_struct *swap_mm;
-		if (swap_mm =3D=3D mm)
-			swap_mm =3D list_entry(mm->mmlist.next, struct mm_struct, mmlist);
 		list_del(&mm->mmlist);
 		mmlist_nr--;
 		spin_unlock(&mmlist_lock);
diff -Nru a/mm/Makefile b/mm/Makefile
--- a/mm/Makefile	Fri Aug 16 16:23:23 2002
+++ b/mm/Makefile	Fri Aug 16 16:23:23 2002
@@ -16,6 +16,6 @@
 	    vmalloc.o slab.o bootmem.o swap.o vmscan.o page_io.o \
 	    page_alloc.o swap_state.o swapfile.o numa.o oom_kill.o \
 	    shmem.o highmem.o mempool.o msync.o mincore.o readahead.o \
-	    pdflush.o page-writeback.o
+	    pdflush.o page-writeback.o rmap.o
=20
 include $(TOPDIR)/Rules.make
diff -Nru a/mm/filemap.c b/mm/filemap.c
--- a/mm/filemap.c	Fri Aug 16 16:23:23 2002
+++ b/mm/filemap.c	Fri Aug 16 16:23:23 2002
@@ -20,6 +20,7 @@
 #include <linux/iobuf.h>
 #include <linux/hash.h>
 #include <linux/writeback.h>
+#include <linux/kernel_stat.h>
 /*
  * This is needed for the following functions:
  *  - try_to_release_page
@@ -50,14 +51,20 @@
 /*
  * Lock ordering:
  *
- *  pagemap_lru_lock
- *  ->i_shared_lock		(vmtruncate)
- *    ->private_lock		(__free_pte->__set_page_dirty_buffers)
+ *  ->i_shared_lock			(vmtruncate)
+ *    ->private_lock			(__free_pte->__set_page_dirty_buffers)
  *      ->swap_list_lock
- *        ->swap_device_lock	(exclusive_swap_page, others)
- *          ->mapping->page_lock
- *      ->inode_lock		(__mark_inode_dirty)
- *        ->sb_lock		(fs/fs-writeback.c)
+ *        ->swap_device_lock		(exclusive_swap_page, others)
+ *	    ->rmap_lock			(to/from swapcache)
+ *            ->mapping->page_lock
+ *		->pagemap_lru_lock	(zap_pte_range)
+ *      ->inode_lock			(__mark_inode_dirty)
+ *        ->sb_lock			(fs/fs-writeback.c)
+ *
+ *  mm->page_table_lock
+ *    ->rmap_lock			(copy_page_range)
+ *    ->mapping->page_lock		(try_to_unmap_one)
+ *
  */
 spinlock_t pagemap_lru_lock __cacheline_aligned_in_smp =3D =
SPIN_LOCK_UNLOCKED;
=20
@@ -176,14 +183,13 @@
  */
 static void truncate_complete_page(struct page *page)
 {
-	/* Leave it on the LRU if it gets converted into anonymous buffers */
-	if (!PagePrivate(page) || do_invalidatepage(page, 0)) {
-		lru_cache_del(page);
-	} else {
+	/* Drop fs-specific data so the page might become freeable. */
+	if (PagePrivate(page) && !do_invalidatepage(page, 0)) {
 		if (current->flags & PF_INVALIDATE)
 			printk("%s: buffer heads were leaked\n",
 				current->comm);
 	}
+
 	ClearPageDirty(page);
 	ClearPageUptodate(page);
 	remove_inode_page(page);
@@ -660,7 +666,7 @@
  * But that's OK - sleepers in wait_on_page_writeback() just go back to =
sleep.
  *
  * The first mb is necessary to safely close the critical section opened =
by the
- * TryLockPage(), the second mb is necessary to enforce ordering between
+ * TestSetPageLocked(), the second mb is necessary to enforce ordering =
between
  * the clear_bit and the read of the waitqueue (to avoid SMP races with a
  * parallel wait_on_page_locked()).
  */
@@ -1534,6 +1540,7 @@
 	return NULL;
=20
 page_not_uptodate:
+	KERNEL_STAT_INC(pgmajfault);
 	lock_page(page);
=20
 	/* Did it get unhashed while we waited for it? */
diff -Nru a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c	Fri Aug 16 16:23:23 2002
+++ b/mm/memory.c	Fri Aug 16 16:23:23 2002
@@ -44,8 +44,10 @@
 #include <linux/iobuf.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/kernel_stat.h>
=20
 #include <asm/pgalloc.h>
+#include <asm/rmap.h>
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
@@ -57,6 +59,22 @@
 void * high_memory;
 struct page *highmem_start_page;
=20
+static unsigned rmap_lock_sequence;
+
+/*
+ * Allocate a non file-backed page which is to be mapped into user page =
tables.
+ * Give it an ->index which will provide good locality of reference for =
the
+ * rmap lock hashing.
+ */
+static struct page *alloc_mapped_page(int gfp_flags)
+{
+	struct page *page =3D alloc_page(gfp_flags);
+
+	if (page)
+		page->index =3D rmap_lock_sequence++;
+	return page;
+}
+
 /*
  * We special-case the C-O-W ZERO_PAGE, because it's such
  * a common occurrence (no need to read the page to know
@@ -79,7 +97,7 @@
  */
 static inline void free_one_pmd(mmu_gather_t *tlb, pmd_t * dir)
 {
-	struct page *pte;
+	struct page *page;
=20
 	if (pmd_none(*dir))
 		return;
@@ -88,9 +106,10 @@
 		pmd_clear(dir);
 		return;
 	}
-	pte =3D pmd_page(*dir);
+	page =3D pmd_page(*dir);
 	pmd_clear(dir);
-	pte_free_tlb(tlb, pte);
+	pgtable_remove_rmap(page);
+	pte_free_tlb(tlb, page);
 }
=20
 static inline void free_one_pgd(mmu_gather_t *tlb, pgd_t * dir)
@@ -150,6 +169,7 @@
 			pte_free(new);
 			goto out;
 		}
+		pgtable_add_rmap(new, mm, address);
 		pmd_populate(mm, pmd, new);
 	}
 out:
@@ -177,6 +197,7 @@
 			pte_free_kernel(new);
 			goto out;
 		}
+		pgtable_add_rmap(virt_to_page(new), mm, address);
 		pmd_populate_kernel(mm, pmd, new);
 	}
 out:
@@ -202,7 +223,11 @@
 	pgd_t * src_pgd, * dst_pgd;
 	unsigned long address =3D vma->vm_start;
 	unsigned long end =3D vma->vm_end;
-	unsigned long cow =3D (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) =3D=3D =
VM_MAYWRITE;
+	unsigned last_lockno =3D -1;
+	spinlock_t *rmap_lock =3D NULL;
+	unsigned long cow;
+
+	cow =3D (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) =3D=3D VM_MAYWRITE;
=20
 	src_pgd =3D pgd_offset(src, address)-1;
 	dst_pgd =3D pgd_offset(dst, address)-1;
@@ -251,6 +276,7 @@
 				goto nomem;
 			spin_lock(&src->page_table_lock);			
 			src_pte =3D pte_offset_map_nested(src_pmd, address);
+			BUG_ON(rmap_lock !=3D NULL);
 			do {
 				pte_t pte =3D *src_pte;
 				struct page *ptepage;
@@ -260,10 +286,13 @@
=20
 				if (pte_none(pte))
 					goto cont_copy_pte_range_noset;
+				/* pte contains position in swap, so copy. */
 				if (!pte_present(pte)) {
 					swap_duplicate(pte_to_swp_entry(pte));
-					goto cont_copy_pte_range;
+					set_pte(dst_pte, pte);
+					goto cont_copy_pte_range_noset;
 				}
+				ptepage =3D pte_page(pte);
 				pfn =3D pte_pfn(pte);
 				if (!pfn_valid(pfn))
 					goto cont_copy_pte_range;
@@ -271,13 +300,19 @@
 				if (PageReserved(ptepage))
 					goto cont_copy_pte_range;
=20
-				/* If it's a COW mapping, write protect it both in the parent and the =
child */
-				if (cow && pte_write(pte)) {
+				/*
+				 * If it's a COW mapping, write protect it both
+				 * in the parent and the child
+				 */
+				if (cow) {
 					ptep_set_wrprotect(src_pte);
 					pte =3D *src_pte;
 				}
=20
-				/* If it's a shared mapping, mark it clean in the child */
+				/*
+				 * If it's a shared mapping, mark it clean in
+				 * the child
+				 */
 				if (vma->vm_flags & VM_SHARED)
 					pte =3D pte_mkclean(pte);
 				pte =3D pte_mkold(pte);
@@ -285,8 +320,12 @@
 				dst->rss++;
=20
 cont_copy_pte_range:		set_pte(dst_pte, pte);
+				cached_rmap_lock(ptepage, &rmap_lock,
+						&last_lockno);
+				__page_add_rmap(ptepage, dst_pte);
 cont_copy_pte_range_noset:	address +=3D PAGE_SIZE;
 				if (address >=3D end) {
+					drop_rmap_lock(&rmap_lock,&last_lockno);
 					pte_unmap_nested(src_pte);
 					pte_unmap(dst_pte);
 					goto out_unlock;
@@ -294,6 +333,7 @@
 				src_pte++;
 				dst_pte++;
 			} while ((unsigned long)src_pte & PTE_TABLE_MASK);
+			drop_rmap_lock(&rmap_lock, &last_lockno);
 			pte_unmap_nested(src_pte-1);
 			pte_unmap(dst_pte-1);
 			spin_unlock(&src->page_table_lock);
@@ -314,6 +354,8 @@
 {
 	unsigned long offset;
 	pte_t *ptep;
+	spinlock_t *rmap_lock =3D NULL;
+	unsigned last_lockno =3D -1;
=20
 	if (pmd_none(*pmd))
 		return;
@@ -329,27 +371,40 @@
 	size &=3D PAGE_MASK;
 	for (offset=3D0; offset < size; ptep++, offset +=3D PAGE_SIZE) {
 		pte_t pte =3D *ptep;
+		unsigned long pfn;
+		struct page *page;
+
 		if (pte_none(pte))
 			continue;
-		if (pte_present(pte)) {
-			unsigned long pfn =3D pte_pfn(pte);
-
-			pte =3D ptep_get_and_clear(ptep);
-			tlb_remove_tlb_entry(tlb, pte, address+offset);
-			if (pfn_valid(pfn)) {
-				struct page *page =3D pfn_to_page(pfn);
-				if (!PageReserved(page)) {
-					if (pte_dirty(pte))
-						set_page_dirty(page);
-					tlb->freed++;
-					tlb_remove_page(tlb, page);
-				}
-			}
-		} else {
+		if (!pte_present(pte)) {
 			free_swap_and_cache(pte_to_swp_entry(pte));
 			pte_clear(ptep);
+			continue;
+		}
+
+		pfn =3D pte_pfn(pte);
+		pte =3D ptep_get_and_clear(ptep);
+		tlb_remove_tlb_entry(tlb, ptep, address+offset);
+		if (!pfn_valid(pfn))
+			continue;
+		page =3D pfn_to_page(pfn);
+		if (!PageReserved(page)) {
+			/*
+			 * rmap_lock nests outside mapping->page_lock
+			 */
+			if (pte_dirty(pte))
+				set_page_dirty(page);
+			tlb->freed++;
+			cached_rmap_lock(page, &rmap_lock, &last_lockno);
+			__page_remove_rmap(page, ptep);
+			/*
+			 * This will take pagemap_lru_lock.  Which nests inside
+			 * rmap_lock
+			 */
+			tlb_remove_page(tlb, page);
 		}
 	}
+	drop_rmap_lock(&rmap_lock, &last_lockno);
 	pte_unmap(ptep-1);
 }
=20
@@ -979,7 +1034,7 @@
 	page_cache_get(old_page);
 	spin_unlock(&mm->page_table_lock);
=20
-	new_page =3D alloc_page(GFP_HIGHUSER);
+	new_page =3D alloc_mapped_page(GFP_HIGHUSER);
 	if (!new_page)
 		goto no_mem;
 	copy_cow_page(old_page,new_page,address);
@@ -992,7 +1047,9 @@
 	if (pte_same(*page_table, pte)) {
 		if (PageReserved(old_page))
 			++mm->rss;
+		page_remove_rmap(old_page, page_table);
 		break_cow(vma, new_page, address, page_table);
+		page_add_rmap(new_page, page_table);
 		lru_cache_add(new_page);
=20
 		/* Free the old page.. */
@@ -1166,6 +1223,7 @@
=20
 		/* Had to read the page from swap area: Major fault */
 		ret =3D VM_FAULT_MAJOR;
+		KERNEL_STAT_INC(pgmajfault);
 	}
=20
 	lock_page(page);
@@ -1199,6 +1257,7 @@
 	flush_page_to_ram(page);
 	flush_icache_page(vma, page);
 	set_pte(page_table, pte);
+	page_add_rmap(page, page_table);
=20
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
@@ -1215,19 +1274,18 @@
 static int do_anonymous_page(struct mm_struct * mm, struct vm_area_struct =
* vma, pte_t *page_table, pmd_t *pmd, int write_access, unsigned long addr)
 {
 	pte_t entry;
+	struct page * page =3D ZERO_PAGE(addr);
=20
 	/* Read-only mapping of ZERO_PAGE. */
 	entry =3D pte_wrprotect(mk_pte(ZERO_PAGE(addr), vma->vm_page_prot));
=20
 	/* ..except if it's a write access */
 	if (write_access) {
-		struct page *page;
-
 		/* Allocate our own private page. */
 		pte_unmap(page_table);
 		spin_unlock(&mm->page_table_lock);
=20
-		page =3D alloc_page(GFP_HIGHUSER);
+		page =3D alloc_mapped_page(GFP_HIGHUSER);
 		if (!page)
 			goto no_mem;
 		clear_user_highpage(page, addr);
@@ -1248,6 +1306,7 @@
 	}
=20
 	set_pte(page_table, entry);
+	page_add_rmap(page, page_table); /* ignores ZERO_PAGE */
 	pte_unmap(page_table);
=20
 	/* No need to invalidate - it was non-present before */
@@ -1294,7 +1353,7 @@
 	 * Should we do an early C-O-W break?
 	 */
 	if (write_access && !(vma->vm_flags & VM_SHARED)) {
-		struct page * page =3D alloc_page(GFP_HIGHUSER);
+		struct page * page =3D alloc_mapped_page(GFP_HIGHUSER);
 		if (!page) {
 			page_cache_release(new_page);
 			return VM_FAULT_OOM;
@@ -1327,6 +1386,7 @@
 		if (write_access)
 			entry =3D pte_mkwrite(pte_mkdirty(entry));
 		set_pte(page_table, entry);
+		page_add_rmap(new_page, page_table);
 		pte_unmap(page_table);
 	} else {
 		/* One of our sibling threads was faster, back out. */
@@ -1406,6 +1466,7 @@
 	current->state =3D TASK_RUNNING;
 	pgd =3D pgd_offset(mm, address);
=20
+	KERNEL_STAT_INC(pgfault);
 	/*
 	 * We need the page table lock to synchronize with kswapd
 	 * and the SMP-safe atomic PTE updates.
diff -Nru a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c	Fri Aug 16 16:23:23 2002
+++ b/mm/mremap.c	Fri Aug 16 16:23:23 2002
@@ -68,8 +68,14 @@
 {
 	int error =3D 0;
 	pte_t pte;
+	struct page * page =3D NULL;
+
+	if (pte_present(*src))
+		page =3D pte_page(*src);
=20
 	if (!pte_none(*src)) {
+		if (page)
+			page_remove_rmap(page, src);
 		pte =3D ptep_get_and_clear(src);
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
--- a/mm/page_alloc.c	Fri Aug 16 16:23:23 2002
+++ b/mm/page_alloc.c	Fri Aug 16 16:23:23 2002
@@ -21,6 +21,7 @@
 #include <linux/compiler.h>
 #include <linux/module.h>
 #include <linux/suspend.h>
+#include <linux/kernel_stat.h>
=20
 unsigned long totalram_pages;
 unsigned long totalhigh_pages;
@@ -86,12 +87,19 @@
 	struct page *base;
 	zone_t *zone;
=20
+	if (PageLRU(page)) {
+		BUG_ON(in_interrupt());
+		lru_cache_del(page);
+	}
+
+	KERNEL_STAT_ADD(pgfree, 1<<order);
+
 	BUG_ON(PagePrivate(page));
 	BUG_ON(page->mapping !=3D NULL);
 	BUG_ON(PageLocked(page));
-	BUG_ON(PageLRU(page));
 	BUG_ON(PageActive(page));
 	BUG_ON(PageWriteback(page));
+	BUG_ON(page->pte.chain !=3D NULL);
 	if (PageDirty(page))
 		ClearPageDirty(page);
 	BUG_ON(page_count(page) !=3D 0);
@@ -236,6 +244,8 @@
 	int order;
 	list_t *curr;
=20
+	KERNEL_STAT_ADD(pgalloc, 1<<order);
+
 	/*
 	 * Should not matter as we need quiescent system for
 	 * suspend anyway, but...
@@ -448,11 +458,8 @@
=20
 void page_cache_release(struct page *page)
 {
-	if (!PageReserved(page) && put_page_testzero(page)) {
-		if (PageLRU(page))
-			lru_cache_del(page);
+	if (!PageReserved(page) && put_page_testzero(page))
 		__free_pages_ok(page, 0);
-	}
 }
=20
 void __free_pages(struct page *page, unsigned int order)
@@ -562,6 +569,8 @@
 		ret->nr_pagecache +=3D ps->nr_pagecache;
 		ret->nr_active +=3D ps->nr_active;
 		ret->nr_inactive +=3D ps->nr_inactive;
+		ret->nr_page_table_pages +=3D ps->nr_page_table_pages;
+		ret->nr_reverse_maps +=3D ps->nr_reverse_maps;
 	}
 }
=20
diff -Nru a/mm/rmap.c b/mm/rmap.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/mm/rmap.c	Fri Aug 16 16:23:23 2002
@@ -0,0 +1,529 @@
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
+ * - the page->pte.chain is protected by the PG_chainlock bit,
+ *   which nests within the pagemap_lru_lock, then the
+ *   mm->page_table_lock, and then the page lock.
+ * - because swapout locking is opposite to the locking order
+ *   in the page fault path, the swapout path uses trylocks
+ *   on the mm->page_table_lock
+ */
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/swapops.h>
+#include <linux/slab.h>
+#include <linux/init.h>
+#include <linux/kernel_stat.h>
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
+ * We use an array of pte pointers in this structure to minimise cache =
misses
+ * while traversing reverse maps.
+ */
+#define NRPTE (L1_CACHE_BYTES/sizeof(void *) - 1)
+
+struct pte_chain {
+	struct pte_chain * next;
+	pte_t *ptes[NRPTE];
+};
+
+spinlock_t rmap_locks[NUM_RMAP_LOCKS];
+
+static kmem_cache_t	*pte_chain_cache;
+static inline struct pte_chain * pte_chain_alloc(void);
+static void pte_chain_free(struct pte_chain *pte_chain);
+
+/*
+ * pte_chain list management policy:
+ *
+ * - If a page has a pte_chain list then it is shared by at least two =
processes,
+ *   because a single sharing uses PageDirect. (Well, this isn't true yet,
+ *   coz this code doesn't collapse singletons back to PageDirect on the =
remove
+ *   path).
+ * - A pte_chain list has free space only in the head member - all =
succeeding
+ *   members are 100% full.
+ * - If the head element has free space, it occurs in its leading slots.
+ * - All free space in the pte_chain is at the start of the head member.
+ * - Insertion into the pte_chain puts a pte pointer in the last free slot =
of
+ *   the head member.
+ * - Removal from a pte chain moves the head pte of the head member onto =
the
+ *   victim pte and frees the head member if it became empty.
+ */
+
+
+/**
+ * page_referenced - test if the page was referenced
+ * @page: the page to test
+ *
+ * Quick test_and_clear_referenced for all mappings to a page,
+ * returns the number of processes which referenced the page.
+ * Caller needs to hold the page's rmap lock.
+ *
+ * If the page has a single-entry pte_chain, collapse that back to a =
PageDirect
+ * representation.  This way, it's only done under memory pressure.
+ */
+int page_referenced(struct page * page)
+{
+	struct pte_chain * pc;
+	int referenced =3D 0;
+
+	if (TestClearPageReferenced(page))
+		referenced++;
+
+	if (PageDirect(page)) {
+		if (ptep_test_and_clear_young(page->pte.direct))
+			referenced++;
+	} else {
+		int nr_chains =3D 0;
+
+		/* Check all the page tables mapping this page. */
+		for (pc =3D page->pte.chain; pc; pc =3D pc->next) {
+			int i;
+
+			for (i =3D NRPTE-1; i >=3D 0; i--) {
+				pte_t *p =3D pc->ptes[i];
+				if (!p)
+					break;
+				if (ptep_test_and_clear_young(p))
+					referenced++;
+				nr_chains++;
+			}
+		}
+		if (nr_chains =3D=3D 1) {
+			pc =3D page->pte.chain;
+			page->pte.direct =3D pc->ptes[NRPTE-1];
+			SetPageDirect(page);
+			pte_chain_free(pc);
+			dec_page_state(nr_reverse_maps);
+		}
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
+void __page_add_rmap(struct page *page, pte_t *ptep)
+{
+	struct pte_chain * pte_chain;
+	int i;
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
+	if (!pfn_valid(pte_pfn(*ptep)) || PageReserved(page))
+		return;
+
+#ifdef DEBUG_RMAP
+	{
+		struct pte_chain * pc;
+		if (PageDirect(page)) {
+			if (page->pte.direct =3D=3D ptep)
+				BUG();
+		} else {
+			for (pc =3D page->pte.chain; pc; pc =3D pc->next) {
+				for (i =3D 0; i < NRPTE; i++) {
+					pte_t *p =3D pc->ptes[i];
+
+					if (p && p =3D=3D ptep)
+						BUG();
+				}
+			}
+		}
+	}
+#endif
+
+	if (page->pte.chain =3D=3D NULL) {
+		page->pte.direct =3D ptep;
+		SetPageDirect(page);
+		goto out;
+	}
+	
+	if (PageDirect(page)) {
+		/* Convert a direct pointer into a pte_chain */
+		ClearPageDirect(page);
+		pte_chain =3D pte_chain_alloc();
+		pte_chain->ptes[NRPTE-1] =3D page->pte.direct;
+		pte_chain->ptes[NRPTE-2] =3D ptep;
+		mod_page_state(nr_reverse_maps, 2);
+		page->pte.chain =3D pte_chain;
+		goto out;
+	}
+
+	pte_chain =3D page->pte.chain;
+	if (pte_chain->ptes[0]) {	/* It's full */
+		struct pte_chain *new;
+
+		new =3D pte_chain_alloc();
+		new->next =3D pte_chain;
+		page->pte.chain =3D new;
+		new->ptes[NRPTE-1] =3D ptep;
+		inc_page_state(nr_reverse_maps);
+		goto out;
+	}
+
+	BUG_ON(pte_chain->ptes[NRPTE-1] =3D=3D NULL);
+
+	for (i =3D NRPTE-2; i >=3D 0; i--) {
+		if (pte_chain->ptes[i] =3D=3D NULL) {
+			pte_chain->ptes[i] =3D ptep;
+			inc_page_state(nr_reverse_maps);
+			goto out;
+		}
+	}
+	BUG();
+
+out:
+}
+
+void page_add_rmap(struct page *page, pte_t *ptep)
+{
+	if (pfn_valid(pte_pfn(*ptep)) && !PageReserved(page)) {
+		spinlock_t *rmap_lock;
+
+		rmap_lock =3D lock_rmap(page);
+		__page_add_rmap(page, ptep);
+		unlock_rmap(rmap_lock);
+	}
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
+void __page_remove_rmap(struct page *page, pte_t *ptep)
+{
+	struct pte_chain *pc;
+
+	if (!page || !ptep)
+		BUG();
+	if (!pfn_valid(pte_pfn(*ptep)) || PageReserved(page))
+		return;
+
+	if (PageDirect(page)) {
+		if (page->pte.direct =3D=3D ptep) {
+			page->pte.direct =3D NULL;
+			ClearPageDirect(page);
+			goto out;
+		}
+	} else {
+		struct pte_chain *start =3D page->pte.chain;
+		int victim_i =3D -1;
+
+		for (pc =3D start; pc; pc =3D pc->next) {
+			int i;
+
+			if (pc->next)
+				prefetch(pc->next);
+			for (i =3D 0; i < NRPTE; i++) {
+				pte_t *p =3D pc->ptes[i];
+
+				if (!p)
+					continue;
+				if (victim_i =3D=3D -1)
+					victim_i =3D i;
+				if (p !=3D ptep)
+					continue;
+				pc->ptes[i] =3D start->ptes[victim_i];
+				start->ptes[victim_i] =3D NULL;
+				dec_page_state(nr_reverse_maps);
+				if (victim_i =3D=3D NRPTE-1) {
+					/* Emptied a pte_chain */
+					page->pte.chain =3D start->next;
+					pte_chain_free(start);
+				} else {
+					/* Do singleton->PageDirect here */
+				}
+				goto out;
+			}
+		}
+	}
+#ifdef DEBUG_RMAP
+	/* Not found. This should NEVER happen! */
+	printk(KERN_ERR "page_remove_rmap: pte_chain %p not present.\n", ptep);
+	printk(KERN_ERR "page_remove_rmap: only found: ");
+	if (PageDirect(page)) {
+		printk("%p ", page->pte.direct);
+	} else {
+		for (pc =3D page->pte.chain; pc; pc =3D pc->next)
+			printk("%p ", pc->ptep);
+	}
+	printk("\n");
+	printk(KERN_ERR "page_remove_rmap: driver cleared PG_reserved ?\n");
+#endif
+	return;
+
+out:
+	return;
+}
+
+void page_remove_rmap(struct page *page, pte_t *ptep)
+{
+	if (pfn_valid(pte_pfn(*ptep)) && !PageReserved(page)) {
+		spinlock_t *rmap_lock;
+
+		rmap_lock =3D lock_rmap(page);
+		__page_remove_rmap(page, ptep);
+		unlock_rmap(rmap_lock);
+	}
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
+ *		rmap_lock		page_launder()
+ *		    mm->page_table_lock	try_to_unmap_one(), trylock
+ */
+static int FASTCALL(try_to_unmap_one(struct page *, pte_t *));
+static int try_to_unmap_one(struct page * page, pte_t * ptep)
+{
+	unsigned long address =3D ptep_to_address(ptep);
+	struct mm_struct * mm =3D ptep_to_mm(ptep);
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
+	vma =3D find_vma(mm, address);
+	if (!vma) {
+		ret =3D SWAP_FAIL;
+		goto out_unlock;
+	}
+
+	/* The page is mlock()d, we cannot swap it out. */
+	if (vma->vm_flags & VM_LOCKED) {
+		ret =3D SWAP_FAIL;
+		goto out_unlock;
+	}
+
+	/* Nuke the page table entry. */
+	pte =3D ptep_get_and_clear(ptep);
+	flush_tlb_page(vma, address);
+	flush_cache_page(vma, address);
+
+	/* Store the swap location in the pte. See handle_pte_fault() ... */
+	if (PageSwapCache(page)) {
+		swp_entry_t entry;
+		entry.val =3D page->index;
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
+	ret =3D SWAP_SUCCESS;
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
+	struct pte_chain *pc, *next_pc, *start;
+	int ret =3D SWAP_SUCCESS;
+	int victim_i =3D -1;
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
+	if (PageDirect(page)) {
+		ret =3D try_to_unmap_one(page, page->pte.direct);
+		if (ret =3D=3D SWAP_SUCCESS) {
+			page->pte.direct =3D NULL;
+			ClearPageDirect(page);
+		}
+		goto out;
+	}		
+
+	start =3D page->pte.chain;
+	for (pc =3D start; pc; pc =3D next_pc) {
+		int i;
+
+		next_pc =3D pc->next;
+		if (next_pc)
+			prefetch(next_pc);
+		for (i =3D 0; i < NRPTE; i++) {
+			pte_t *p =3D pc->ptes[i];
+
+			if (!p)
+				continue;
+			if (victim_i =3D=3D -1)=20
+				victim_i =3D i;
+
+			switch (try_to_unmap_one(page, p)) {
+			case SWAP_SUCCESS:
+				/*
+				 * Release a slot.  If we're releasing the
+				 * first pte in the first pte_chain then
+				 * pc->ptes[i] and start->ptes[victim_i] both
+				 * refer to the same thing.  It works out.
+				 */
+				pc->ptes[i] =3D start->ptes[victim_i];
+				start->ptes[victim_i] =3D NULL;
+				dec_page_state(nr_reverse_maps);
+				victim_i++;
+				if (victim_i =3D=3D NRPTE) {
+					page->pte.chain =3D start->next;
+					pte_chain_free(start);
+					start =3D page->pte.chain;
+					victim_i =3D 0;
+				}
+				break;
+			case SWAP_AGAIN:
+				/* Skip this pte, remembering status. */
+				ret =3D SWAP_AGAIN;
+				continue;
+			case SWAP_FAIL:
+				ret =3D SWAP_FAIL;
+				goto out;
+			case SWAP_ERROR:
+				ret =3D SWAP_ERROR;
+				goto out;
+			}
+		}
+	}
+out:
+	return ret;
+}
+
+/**
+ ** No more VM stuff below this comment, only pte_chain helper
+ ** functions.
+ **/
+
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
+ * Caller needs to hold the rmap_lock if the page is non-NULL.
+ */
+static void pte_chain_free(struct pte_chain *pte_chain)
+{
+	pte_chain->next =3D NULL;
+	kmem_cache_free(pte_chain_cache, pte_chain);
+}
+
+/**
+ * pte_chain_alloc - allocate a pte_chain struct
+ *
+ * Returns a pointer to a fresh pte_chain structure. Allocates new
+ * pte_chain structures as required.
+ */
+static inline struct pte_chain *pte_chain_alloc(void)
+{
+	return kmem_cache_alloc(pte_chain_cache, GFP_ATOMIC);
+}
+
+static void pte_chain_ctor(void *p, kmem_cache_t *cachep, unsigned long =
flags)
+{
+	struct pte_chain *pc =3D p;
+
+	memset(pc, 0, sizeof(*pc));
+}
+
+void __init pte_chain_init(void)
+{
+	int i;
+
+	for (i =3D 0; i < ARRAY_SIZE(rmap_locks); i++)
+		spin_lock_init(&rmap_locks[i]);
+
+	pte_chain_cache =3D kmem_cache_create(	"pte_chain",
+						sizeof(struct pte_chain),
+						0,
+						0,
+						pte_chain_ctor,
+						NULL);
+
+	if (!pte_chain_cache)
+		panic("failed to create pte_chain cache!\n");
+}
diff -Nru a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c	Fri Aug 16 16:23:23 2002
+++ b/mm/swap.c	Fri Aug 16 16:23:23 2002
@@ -14,11 +14,11 @@
  */
=20
 #include <linux/mm.h>
-#include <linux/kernel_stat.h>
 #include <linux/swap.h>
 #include <linux/swapctl.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
+#include <linux/kernel_stat.h>
=20
 #include <asm/dma.h>
 #include <asm/uaccess.h> /* for copy_to/from_user */
@@ -41,6 +41,7 @@
 	if (PageLRU(page) && !PageActive(page)) {
 		del_page_from_inactive_list(page);
 		add_page_to_active_list(page);
+		KERNEL_STAT_INC(pgactivate);
 	}
 }
=20
diff -Nru a/mm/swap_state.c b/mm/swap_state.c
--- a/mm/swap_state.c	Fri Aug 16 16:23:23 2002
+++ b/mm/swap_state.c	Fri Aug 16 16:23:23 2002
@@ -16,6 +16,7 @@
 #include <linux/smp_lock.h>
 #include <linux/buffer_head.h>	/* block_sync_page() */
=20
+#include <asm/rmap.h>
 #include <asm/pgtable.h>
=20
 /*
@@ -76,6 +77,12 @@
 		return -ENOENT;
 	}
=20
+
+	/*
+	 * Sneakily do this here so we don't add cost to add_to_page_cache().
+	 */
+	set_page_index(page, entry.val);
+
 	error =3D add_to_page_cache_unique(page, &swapper_space, entry.val);
 	if (error !=3D 0) {
 		swap_free(entry);
@@ -105,6 +112,69 @@
 	INC_CACHE_INFO(del_total);
 }
=20
+/**
+ * add_to_swap - allocate swap space for a page
+ * @page: page we want to move to swap
+ *
+ * Allocate swap space for the page and add the page to the
+ * swap cache.  Caller needs to hold the page lock.=20
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
+		entry =3D get_swap_page();
+		if (!entry.val)
+			return 0;
+
+		/* Radix-tree node allocations are performing
+		 * GFP_ATOMIC allocations under PF_MEMALLOC. =20
+		 * They can completely exhaust the page allocator. =20
+		 *
+		 * So PF_MEMALLOC is dropped here.  This causes the slab=20
+		 * allocations to fail earlier, so radix-tree nodes will=20
+		 * then be allocated from the mempool reserves.
+		 *
+		 * We're still using __GFP_HIGH for radix-tree node
+		 * allocations, so some of the emergency pools are available,
+		 * just not all of them.
+		 */
+
+		flags =3D current->flags;
+		current->flags &=3D ~PF_MEMALLOC;
+		current->flags |=3D PF_NOWARN;
+		ClearPageUptodate(page);		/* why? */
+
+		/*
+		 * Add it to the swap cache and mark it dirty
+		 * (adding to the page cache will clear the dirty
+		 * and uptodate bits, so we need to do it again)
+		 */
+		switch (add_to_swap_cache(page, entry)) {
+		case 0:				/* Success */
+			current->flags =3D flags;
+			SetPageUptodate(page);
+			set_page_dirty(page);
+			swap_free(entry);
+			return 1;
+		case -ENOMEM:			/* radix-tree allocation */
+			current->flags =3D flags;
+			swap_free(entry);
+			return 0;
+		default:			/* ENOENT: raced */
+			break;
+		}
+		/* Raced with "speculative" read_swap_cache_async */
+		current->flags =3D flags;
+		swap_free(entry);
+	}
+}
+
 /*
  * This must be called only on pages that have
  * been verified to be in the swap cache and locked.
@@ -143,6 +213,7 @@
 		return -ENOENT;
 	}
=20
+	set_page_index(page, entry.val);
 	write_lock(&swapper_space.page_lock);
 	write_lock(&mapping->page_lock);
=20
@@ -159,7 +230,6 @@
 		 */
 		ClearPageUptodate(page);
 		ClearPageReferenced(page);
-
 		SetPageLocked(page);
 		ClearPageDirty(page);
 		___add_to_page_cache(page, &swapper_space, entry.val);
@@ -191,6 +261,7 @@
 	BUG_ON(PageWriteback(page));
 	BUG_ON(page_has_buffers(page));
=20
+	set_page_index(page, index);
 	write_lock(&swapper_space.page_lock);
 	write_lock(&mapping->page_lock);
=20
diff -Nru a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c	Fri Aug 16 16:23:23 2002
+++ b/mm/swapfile.c	Fri Aug 16 16:23:23 2002
@@ -383,6 +383,7 @@
 		return;
 	get_page(page);
 	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
+	page_add_rmap(page, dir);
 	swap_free(entry);
 	++vma->vm_mm->rss;
 }
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Fri Aug 16 16:23:23 2002
+++ b/mm/vmscan.c	Fri Aug 16 16:23:23 2002
@@ -13,7 +13,6 @@
=20
 #include <linux/mm.h>
 #include <linux/slab.h>
-#include <linux/kernel_stat.h>
 #include <linux/swap.h>
 #include <linux/swapctl.h>
 #include <linux/smp_lock.h>
@@ -24,7 +23,9 @@
 #include <linux/writeback.h>
 #include <linux/suspend.h>
 #include <linux/buffer_head.h>		/* for try_to_release_page() */
+#include <linux/kernel_stat.h>
=20
+#include <asm/rmap.h>
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 #include <linux/swapops.h>
@@ -42,347 +43,23 @@
 	return page_count(page) - !!PagePrivate(page) =3D=3D 1;
 }
=20
-/*
- * On the swap_out path, the radix-tree node allocations are performing
- * GFP_ATOMIC allocations under PF_MEMALLOC.  They can completely
- * exhaust the page allocator.  This is bad; some pages should be left
- * available for the I/O system to start sending the swapcache contents
- * to disk.
- *
- * So PF_MEMALLOC is dropped here.  This causes the slab allocations to =
fail
- * earlier, so radix-tree nodes will then be allocated from the mempool
- * reserves.
- *
- * We're still using __GFP_HIGH for radix-tree node allocations, so some =
of
- * the emergency pools are available - just not all of them.
- */
-static inline int
-swap_out_add_to_swap_cache(struct page *page, swp_entry_t entry)
+/* Must be called with page's rmap_lock held. */
+static inline int page_mapping_inuse(struct page * page)
 {
-	int flags =3D current->flags;
-	int ret;
-
-	current->flags &=3D ~PF_MEMALLOC;
-	current->flags |=3D PF_NOWARN;
-	ClearPageUptodate(page);		/* why? */
-	ClearPageReferenced(page);		/* why? */
-	ret =3D add_to_swap_cache(page, entry);
-	current->flags =3D flags;
-	return ret;
-}
+	struct address_space *mapping =3D page->mapping;
=20
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
-static inline int try_to_swap_out(struct mm_struct * mm, struct =
vm_area_struct* vma, unsigned long address, pte_t * page_table, struct page =
*page, zone_t * classzone)
-{
-	pte_t pte;
-	swp_entry_t entry;
+	/* Page is in somebody's page tables. */
+	if (page->pte.chain)
+		return 1;
=20
-	/* Don't look at this pte if it's been accessed recently. */
-	if ((vma->vm_flags & VM_LOCKED) || ptep_test_and_clear_young(page_table)) =
{
-		mark_page_accessed(page);
+	/* XXX: does this happen ? */
+	if (!mapping)
 		return 0;
-	}
=20
-	/* Don't bother unmapping pages that are active */
-	if (PageActive(page))
-		return 0;
+	/* File is mmap'd by somebody. */
+	if (!list_empty(&mapping->i_mmap) || =
!list_empty(&mapping->i_mmap_shared))
+		return 1;
=20
-	/* Don't bother replenishing zones not under pressure.. */
-	if (!memclass(page_zone(page), classzone))
-		return 0;
-
-	if (TestSetPageLocked(page))
-		return 0;
-
-	if (PageWriteback(page))
-		goto out_unlock;
-
-	/* From this point on, the odds are that we're going to
-	 * nuke this pte, so read and clear the pte.  This hook
-	 * is needed on CPUs which update the accessed and dirty
-	 * bits in hardware.
-	 */
-	flush_cache_page(vma, address);
-	pte =3D ptep_get_and_clear(page_table);
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
-		entry.val =3D page->index;
-		swap_duplicate(entry);
-set_swap_pte:
-		set_pte(page_table, swp_entry_to_pte(entry));
-drop_pte:
-		mm->rss--;
-		unlock_page(page);
-		{
-			int freeable =3D page_count(page) -
-				!!PagePrivate(page) <=3D 2;
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
-		entry =3D get_swap_page();
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
-
-	/* No swap space left */
-preserve:
-	set_pte(page_table, pte);
-out_unlock:
-	unlock_page(page);
-	return 0;
-}
-
-/* mm->page_table_lock is held. mmap_sem is not held */
-static inline int swap_out_pmd(struct mm_struct * mm, struct =
vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, =
int count, zone_t * classzone)
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
-	pte =3D pte_offset_map(dir, address);
-	
-	pmd_end =3D (address + PMD_SIZE) & PMD_MASK;
-	if (end > pmd_end)
-		end =3D pmd_end;
-
-	do {
-		if (pte_present(*pte)) {
-			unsigned long pfn =3D pte_pfn(*pte);
-			struct page *page =3D pfn_to_page(pfn);
-
-			if (pfn_valid(pfn) && !PageReserved(page)) {
-				count -=3D try_to_swap_out(mm, vma, address, pte, page, classzone);
-				if (!count) {
-					address +=3D PAGE_SIZE;
-					pte++;
-					break;
-				}
-			}
-		}
-		address +=3D PAGE_SIZE;
-		pte++;
-	} while (address && (address < end));
-	pte_unmap(pte - 1);
-	mm->swap_address =3D address;
-	return count;
-}
-
-/* mm->page_table_lock is held. mmap_sem is not held */
-static inline int swap_out_pgd(struct mm_struct * mm, struct =
vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, =
int count, zone_t * classzone)
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
-	pmd =3D pmd_offset(dir, address);
-
-	pgd_end =3D (address + PGDIR_SIZE) & PGDIR_MASK;	
-	if (pgd_end && (end > pgd_end))
-		end =3D pgd_end;
-	
-	do {
-		count =3D swap_out_pmd(mm, vma, pmd, address, end, count, classzone);
-		if (!count)
-			break;
-		address =3D (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address && (address < end));
-	return count;
-}
-
-/* mm->page_table_lock is held. mmap_sem is not held */
-static inline int swap_out_vma(struct mm_struct * mm, struct =
vm_area_struct * vma, unsigned long address, int count, zone_t * classzone)
-{
-	pgd_t *pgdir;
-	unsigned long end;
-
-	/* Don't swap out areas which are reserved */
-	if (vma->vm_flags & VM_RESERVED)
-		return count;
-
-	pgdir =3D pgd_offset(mm, address);
-
-	end =3D vma->vm_end;
-	if (address >=3D end)
-		BUG();
-	do {
-		count =3D swap_out_pgd(mm, vma, pgdir, address, end, count, classzone);
-		if (!count)
-			break;
-		address =3D (address + PGDIR_SIZE) & PGDIR_MASK;
-		pgdir++;
-	} while (address && (address < end));
-	return count;
-}
-
-/* Placeholder for swap_out(): may be updated by fork.c:mmput() */
-struct mm_struct *swap_mm =3D &init_mm;
-
-/*
- * Returns remaining count of pages to be swapped out by followup call.
- */
-static inline int swap_out_mm(struct mm_struct * mm, int count, int * =
mmcounter, zone_t * classzone)
-{
-	unsigned long address;
-	struct vm_area_struct* vma;
-
-	/*
-	 * Find the proper vm-area after freezing the vma chain=20
-	 * and ptes.
-	 */
-	spin_lock(&mm->page_table_lock);
-	address =3D mm->swap_address;
-	if (address =3D=3D TASK_SIZE || swap_mm !=3D mm) {
-		/* We raced: don't count this mm but try again */
-		++*mmcounter;
-		goto out_unlock;
-	}
-	vma =3D find_vma(mm, address);
-	if (vma) {
-		if (address < vma->vm_start)
-			address =3D vma->vm_start;
-
-		for (;;) {
-			count =3D swap_out_vma(mm, vma, address, count, classzone);
-			vma =3D vma->vm_next;
-			if (!vma)
-				break;
-			if (!count)
-				goto out_unlock;
-			address =3D vma->vm_start;
-		}
-	}
-	/* Indicate that we reached the end of address space */
-	mm->swap_address =3D TASK_SIZE;
-
-out_unlock:
-	spin_unlock(&mm->page_table_lock);
-	return count;
-}
-
-static int FASTCALL(swap_out(unsigned int priority, unsigned int gfp_mask, =
zone_t * classzone));
-static int swap_out(unsigned int priority, unsigned int gfp_mask, zone_t * =
classzone)
-{
-	int counter, nr_pages =3D SWAP_CLUSTER_MAX;
-	struct mm_struct *mm;
-
-	counter =3D mmlist_nr;
-	do {
-		if (need_resched()) {
-			__set_current_state(TASK_RUNNING);
-			schedule();
-		}
-
-		spin_lock(&mmlist_lock);
-		mm =3D swap_mm;
-		while (mm->swap_address =3D=3D TASK_SIZE || mm =3D=3D &init_mm) {
-			mm->swap_address =3D 0;
-			mm =3D list_entry(mm->mmlist.next, struct mm_struct, mmlist);
-			if (mm =3D=3D swap_mm)
-				goto empty;
-			swap_mm =3D mm;
-		}
-
-		/* Make sure the mm doesn't disappear when we drop the lock.. */
-		atomic_inc(&mm->mm_users);
-		spin_unlock(&mmlist_lock);
-
-		nr_pages =3D swap_out_mm(mm, nr_pages, &counter, classzone);
-
-		mmput(mm);
-
-		if (!nr_pages)
-			return 1;
-	} while (--counter >=3D 0);
-
-	return 0;
-
-empty:
-	spin_unlock(&mmlist_lock);
 	return 0;
 }
=20
@@ -392,13 +69,13 @@
 {
 	struct list_head * entry;
 	struct address_space *mapping;
-	int max_mapped =3D nr_pages << (9 - priority);
=20
 	spin_lock(&pagemap_lru_lock);
 	while (--max_scan >=3D 0 &&
 			(entry =3D inactive_list.prev) !=3D &inactive_list) {
 		struct page *page;
 		int may_enter_fs;
+		spinlock_t *rmap_lock;
=20
 		if (need_resched()) {
 			spin_unlock(&pagemap_lru_lock);
@@ -417,6 +94,7 @@
=20
 		list_del(entry);
 		list_add(entry, &inactive_list);
+		KERNEL_STAT_INC(pgscan);
=20
 		/*
 		 * Zero page counts can happen because we unlink the pages
@@ -428,10 +106,6 @@
 		if (!memclass(page_zone(page), classzone))
 			continue;
=20
-		/* Racy check to avoid trylocking when not worthwhile */
-		if (!PagePrivate(page) && (page_count(page) !=3D 1 || !page->mapping))
-			goto page_mapped;
-
 		/*
 		 * swap activity never enters the filesystem and is safe
 		 * for GFP_NOFS allocations.
@@ -448,6 +122,7 @@
 				spin_unlock(&pagemap_lru_lock);
 				wait_on_page_writeback(page);
 				page_cache_release(page);
+				KERNEL_STAT_INC(pgsteal);
 				spin_lock(&pagemap_lru_lock);
 			}
 			continue;
@@ -461,6 +136,60 @@
 			continue;
 		}
=20
+		/*
+		 * The page is in active use or really unfreeable. Move to
+		 * the active list.
+		 */
+		rmap_lock =3D lock_rmap(page);
+		if (page_referenced(page) && page_mapping_inuse(page)) {
+			del_page_from_inactive_list(page);
+			add_page_to_active_list(page);
+			unlock_rmap(rmap_lock);
+			unlock_page(page);
+			KERNEL_STAT_INC(pgactivate);
+			continue;
+		}
+
+		/*
+		 * Anonymous process memory without backing store. Try to
+		 * allocate it some swap space here.
+		 *
+		 * XXX: implement swap clustering ?
+		 */
+		if (page->pte.chain && !page->mapping && !PagePrivate(page)) {
+			page_cache_get(page);
+			unlock_rmap(rmap_lock);
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
+			rmap_lock =3D lock_rmap(page);
+		}
+
+		/*
+		 * The page is mapped into the page tables of one or more
+		 * processes. Try to unmap it here.
+		 */
+		if (page->pte.chain) {
+			switch (try_to_unmap(page)) {
+				case SWAP_ERROR:
+				case SWAP_FAIL:
+					goto page_active;
+				case SWAP_AGAIN:
+					unlock_rmap(rmap_lock);
+					unlock_page(page);
+					continue;
+				case SWAP_SUCCESS:
+					; /* try to free the page below */
+			}
+		}
+		unlock_rmap(rmap_lock);
 		mapping =3D page->mapping;
=20
 		if (PageDirty(page) && is_page_cache_freeable(page) &&
@@ -469,13 +198,12 @@
 			 * It is not critical here to write it only if
 			 * the page is unmapped beause any direct writer
 			 * like O_DIRECT would set the page's dirty bitflag
-			 * on the phisical page after having successfully
+			 * on the physical page after having successfully
 			 * pinned it and after the I/O to the page is finished,
 			 * so the direct writes to the page cannot get lost.
 			 */
 			int (*writeback)(struct page *, int *);
-			const int nr_pages =3D SWAP_CLUSTER_MAX;
-			int nr_to_write =3D nr_pages;
+			int nr_to_write =3D SWAP_CLUSTER_MAX;
=20
 			writeback =3D mapping->a_ops->vm_writeback;
 			if (writeback =3D=3D NULL)
@@ -483,7 +211,7 @@
 			page_cache_get(page);
 			spin_unlock(&pagemap_lru_lock);
 			(*writeback)(page, &nr_to_write);
-			max_scan -=3D (nr_pages - nr_to_write);
+			max_scan -=3D (SWAP_CLUSTER_MAX - nr_to_write);
 			page_cache_release(page);
 			spin_lock(&pagemap_lru_lock);
 			continue;
@@ -511,19 +239,11 @@
=20
 			if (try_to_release_page(page, gfp_mask)) {
 				if (!mapping) {
-					/*
-					 * We must not allow an anon page
-					 * with no buffers to be visible on
-					 * the LRU, so we unlock the page after
-					 * taking the lru lock
-					 */
-					spin_lock(&pagemap_lru_lock);
-					unlock_page(page);
-					__lru_cache_del(page);
-
 					/* effectively free the page here */
+					unlock_page(page);
 					page_cache_release(page);
=20
+					spin_lock(&pagemap_lru_lock);
 					if (--nr_pages)
 						continue;
 					break;
@@ -557,18 +277,7 @@
 			write_unlock(&mapping->page_lock);
 		}
 		unlock_page(page);
-page_mapped:
-		if (--max_mapped >=3D 0)
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
@@ -597,13 +306,22 @@
=20
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
+		unlock_rmap(rmap_lock);
+		unlock_page(page);
+		KERNEL_STAT_INC(pgactivate);
 	}
-	spin_unlock(&pagemap_lru_lock);
-
+out:	spin_unlock(&pagemap_lru_lock);
 	return nr_pages;
 }
=20
@@ -611,12 +329,14 @@
  * This moves pages from the active list to
  * the inactive list.
  *
- * We move them the other way when we see the
- * reference bit on the page.
+ * We move them the other way if the page is=20
+ * referenced by one or more processes, from rmap
  */
 static void refill_inactive(int nr_pages)
 {
 	struct list_head * entry;
+	spinlock_t *rmap_lock =3D NULL;
+	unsigned last_lockno =3D -1;
=20
 	spin_lock(&pagemap_lru_lock);
 	entry =3D active_list.prev;
@@ -625,16 +345,19 @@
=20
 		page =3D list_entry(entry, struct page, lru);
 		entry =3D entry->prev;
-		if (TestClearPageReferenced(page)) {
-			list_del(&page->lru);
-			list_add(&page->lru, &active_list);
-			continue;
-		}
=20
+  		if (page->pte.chain) {
+			cached_rmap_lock(page, &rmap_lock, &last_lockno);
+			if (page->pte.chain && page_referenced(page)) {
+				list_del(&page->lru);
+				list_add(&page->lru, &active_list);
+				continue;
+			}
+		}
 		del_page_from_active_list(page);
 		add_page_to_inactive_list(page);
-		SetPageReferenced(page);
 	}
+	drop_rmap_lock(&rmap_lock, &last_lockno);
 	spin_unlock(&pagemap_lru_lock);
 }
=20

--==========1845559384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
