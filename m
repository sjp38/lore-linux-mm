From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
Subject: [QUICKLIST 1/4] Quicklists for page table pages V5
Date: Mon,  9 Apr 2007 11:25:09 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

Quicklists for page table pages V5

V4->V5
- Change rationale: Justify by performance numbers instead of
  code consolidation.
- Drop i386 patch. Lets deal with that can of worms later.
- x86_64: Also cache pte pages via quicklists.
- Add quicklist_free_page for the cases in which we have
  a page struct instead of an address.

V3->V4
- Rename quicklist_check to quicklist_trim and allow parameters
  to specify how to clean quicklists.
- Remove dead code

V2->V3
- Fix Kconfig issues by setting CONFIG_QUICKLIST explicitly
  and default to one quicklist if NR_QUICK is not set.
- Fix i386 support. (Cannot mix PMD and PTE allocs.)
- Discussion of V2.
  http://marc.info/?l=linux-kernel&m=117391339914767&w=2

V1->V2
- Add sparch64 patch
- Single i386 and x86_64 patch
- Update attribution
- Update justification
- Update approvals
- Earlier discussion of V1 was at
  http://marc.info/?l=linux-kernel&m=117357922219342&w=2

On x86_64 this cuts allocation overhead for page table pages down to
a fraction (kernel compile / editing load. TSC based measurement
of times spend in each function):

no quicklist

pte_alloc               1569048 4.3s(401ns/2.7us/179.7us)
pmd_alloc                780988 2.1s(337ns/2.7us/86.1us)
pud_alloc                780072 2.2s(424ns/2.8us/300.6us)
pgd_alloc                260022 1s(920ns/4us/263.1us)

quicklist:

pte_alloc                452436 573.4ms(8ns/1.3us/121.1us)
pmd_alloc                196204 174.5ms(7ns/889ns/46.1us)
pud_alloc                195688 172.4ms(7ns/881ns/151.3us)
pgd_alloc                 65228 9.8ms(8ns/150ns/6.1us)

pgd allocations are the most complex and there we see the most dramatic
improvement (may be we can cut down the amount of pgds cached somewhat?).
But even the pte allocations still see a doubling of performance.

1. Proven code from the IA64 arch.

	The method used here has been fine tuned for years and
	is NUMA aware. It is based on the knowledge that accesses
	to page table pages are sparse in nature. Taking a page
	off the freelists instead of allocating a zeroed pages
	allows a reduction of number of cachelines touched
	in addition to getting rid of the slab overhead. So
	performance improves. This is particularly useful if pgds
	contain standard mappings. We can save on the teardown
	and setup of such a page if we have some on the quicklists.
	This includes avoiding lists operations that are otherwise
	necessary on alloc and free to track pgds.

2. Light weight alternative to use slab to manage page size pages

	Slab overhead is significant and even page allocator use
	is pretty heavy weight. The use of a per cpu quicklist
	means that we touch only two cachelines for an allocation.
	There is no need to access the page_struct (unless arch code
	needs to fiddle around with it). So the fast past just
	means bringing in one cacheline at the beginning of the
	page. That same cacheline may then be used to store the
	page table entry. Or a second cacheline may be used
	if the page table entry is not in the first cacheline of
	the page. The current code will zero the page which means
	touching 32 cachelines (assuming 128 byte). We get down
	from 32 to 2 cachelines in the fast path.

3. x86_64 gets lightweight page table page management.

	This will allow x86_64 arch code to faster repopulate pgds
	and other page table entries. The list operations for pgds
	are reduced in the same way as for i386 to the point where
	a pgd is allocated from the page allocator and when it is
	freed back to the page allocator. A pgd can pass through
	the quicklists without having to be reinitialized.

64 Consolidation of code from multiple arches

	So far arches have their own implementation of quicklist
	management. This patch moves that feature into the core allowing
	an easier maintenance and consistent management of quicklists.

Page table pages have the characteristics that they are typically zero
or in a known state when they are freed. This is usually the exactly
same state as needed after allocation. So it makes sense to build a list
of freed page table pages and then consume the pages already in use
first. Those pages have already been initialized correctly (thus no
need to zero them) and are likely already cached in such a way that
the MMU can use them most effectively. Page table pages are used in
a sparse way so zeroing them on allocation is not too useful.

Such an implementation already exits for ia64. Howver, that implementation
did not support constructors and destructors as needed by i386 / x86_64.
It also only supported a single quicklist. The implementation here has
constructor and destructor support as well as the ability for an arch to
specify how many quicklists are needed.

Quicklists are defined by an arch defining CONFIG_QUICKLIST. If more
than one quicklist is necessary then we can define NR_QUICK for additional
lists. F.e. i386 needs two and thus has

config NR_QUICK
	int
	default 2

If an arch has requested quicklist support then pages can be allocated
from the quicklist (or from the page allocator if the quicklist is
empty) via:


quicklist_alloc(<quicklist-nr>, <gfpflags>, <constructor>)


Page table pages can be freed using:


quicklist_free(<quicklist-nr>, <destructor>, <page>)


Pages must have a definite state after allocation and before
they are freed. If no constructor is specified then pages
will be zeroed on allocation and must be zeroed before they are
freed.

If a constructor is used then the constructor will establish
a definite page state. F.e. the i386 and x86_64 pgd constructors
establish certain mappings.

Constructors and destructors can also be used to track the pages.
i386 and x86_64 use a list of pgds in order to be able to dynamically
update standard mappings.

Tested on:
i386 UP / SMP, x86_64 UP, NUMA emulation, IA64 NUMA.

Index: linux-2.6.21-rc5-mm4/include/linux/quicklist.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.21-rc5-mm4/include/linux/quicklist.h	2007-04-07 22:11:11.000000000 -0700
@@ -0,0 +1,94 @@
+#ifndef LINUX_QUICKLIST_H
+#define LINUX_QUICKLIST_H
+/*
+ * Fast allocations and disposal of pages. Pages must be in the condition
+ * as needed after allocation when they are freed. Per cpu lists of pages
+ * are kept that only contain node local pages.
+ *
+ * (C) 2007, SGI. Christoph Lameter <clameter@sgi.com>
+ */
+#include <linux/kernel.h>
+#include <linux/gfp.h>
+#include <linux/percpu.h>
+
+#ifdef CONFIG_QUICKLIST
+
+struct quicklist {
+	void *page;
+	int nr_pages;
+};
+
+DECLARE_PER_CPU(struct quicklist, quicklist)[CONFIG_NR_QUICK];
+
+/*
+ * The two key functions quicklist_alloc and quicklist_free are inline so
+ * that they may be custom compiled for the platform.
+ * Specifying a NULL ctor can remove constructor support. Specifying
+ * a constant quicklist allows the determination of the exact address
+ * in the per cpu area.
+ *
+ * The fast patch in quicklist_alloc touched only a per cpu cacheline and
+ * the first cacheline of the page itself. There is minmal overhead involved.
+ */
+static inline void *quicklist_alloc(int nr, gfp_t flags, void (*ctor)(void *))
+{
+	struct quicklist *q;
+	void **p = NULL;
+
+	q =&get_cpu_var(quicklist)[nr];
+	p = q->page;
+	if (likely(p)) {
+		q->page = p[0];
+		p[0] = NULL;
+		q->nr_pages--;
+	}
+	put_cpu_var(quicklist);
+	if (likely(p))
+		return p;
+
+	p = (void *)__get_free_page(flags | __GFP_ZERO);
+	if (ctor && p)
+		ctor(p);
+	return p;
+}
+
+static inline void __quicklist_free(int nr, void (*dtor)(void *), void *p,
+	struct page *page)
+{
+	struct quicklist *q;
+	int nid = page_to_nid(page);
+
+	if (unlikely(nid != numa_node_id())) {
+		if (dtor)
+			dtor(p);
+		free_page((unsigned long)p);
+		return;
+	}
+
+	q = &get_cpu_var(quicklist)[nr];
+	*(void **)p = q->page;
+	q->page = p;
+	q->nr_pages++;
+	put_cpu_var(quicklist);
+}
+
+static inline void quicklist_free(int nr, void (*dtor)(void *), void *pp)
+{
+	__quicklist_free(nr, dtor, pp, virt_to_page(pp));
+}
+
+static inline void quicklist_free_page(int nr, void (*dtor)(void *),
+							struct page *page)
+{
+	__quicklist_free(nr, dtor, page_address(page), page);
+}
+
+void quicklist_trim(int nr, void (*dtor)(void *),
+	unsigned long min_pages, unsigned long max_free);
+
+unsigned long quicklist_total_size(void);
+
+#endif
+
+#endif /* LINUX_QUICKLIST_H */
+
Index: linux-2.6.21-rc5-mm4/mm/Makefile
===================================================================
--- linux-2.6.21-rc5-mm4.orig/mm/Makefile	2007-04-07 20:00:19.000000000 -0700
+++ linux-2.6.21-rc5-mm4/mm/Makefile	2007-04-07 20:02:03.000000000 -0700
@@ -31,3 +31,5 @@
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
+obj-$(CONFIG_QUICKLIST) += quicklist.o
+
Index: linux-2.6.21-rc5-mm4/mm/quicklist.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.21-rc5-mm4/mm/quicklist.c	2007-04-07 22:11:24.000000000 -0700
@@ -0,0 +1,88 @@
+/*
+ * Quicklist support.
+ *
+ * Quicklists are light weight lists of pages that have a defined state
+ * on alloc and free. Pages must be in the quicklist specific defined state
+ * (zero by default) when the page is freed. It seems that the initial idea
+ * for such lists first came from Dave Miller and then various other people
+ * improved on it.
+ *
+ * Copyright (C) 2007 SGI,
+ * 	Christoph Lameter <clameter@sgi.com>
+ * 		Generalized, added support for multiple lists and
+ * 		constructors / destructors.
+ */
+#include <linux/kernel.h>
+
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/module.h>
+#include <linux/quicklist.h>
+
+DEFINE_PER_CPU(struct quicklist, quicklist)[CONFIG_NR_QUICK];
+
+#define FRACTION_OF_NODE_MEM	16
+
+static unsigned long max_pages(unsigned long min_pages)
+{
+	unsigned long node_free_pages, max;
+
+	node_free_pages = node_page_state(numa_node_id(),
+			NR_FREE_PAGES);
+	max = node_free_pages / FRACTION_OF_NODE_MEM;
+	return max(max, min_pages);
+}
+
+static long min_pages_to_free(struct quicklist *q,
+	unsigned long min_pages, long max_free)
+{
+	long pages_to_free;
+
+	pages_to_free = q->nr_pages - max_pages(min_pages);
+
+	return min(pages_to_free, max_free);
+}
+
+/*
+ * Trim down the number of pages in the quicklist
+ */
+void quicklist_trim(int nr, void (*dtor)(void *),
+	unsigned long min_pages, unsigned long max_free)
+{
+	long pages_to_free;
+	struct quicklist *q;
+
+	q = &get_cpu_var(quicklist)[nr];
+	if (q->nr_pages > min_pages) {
+		pages_to_free = min_pages_to_free(q, min_pages, max_free);
+
+		while (pages_to_free > 0) {
+			/*
+			 * We pass a gfp_t of 0 to quicklist_alloc here
+			 * because we will never call into the page allocator.
+			 */
+			void *p = quicklist_alloc(nr, 0, NULL);
+
+			if (dtor)
+				dtor(p);
+			free_page((unsigned long)p);
+			pages_to_free--;
+		}
+	}
+	put_cpu_var(quicklist);
+}
+
+unsigned long quicklist_total_size(void)
+{
+	unsigned long count = 0;
+	int cpu;
+	struct quicklist *ql, *q;
+
+	for_each_online_cpu(cpu) {
+		ql = per_cpu(quicklist, cpu);
+		for (q = ql; q < ql + CONFIG_NR_QUICK; q++)
+			count += q->nr_pages;
+	}
+	return count;
+}
+
Index: linux-2.6.21-rc5-mm4/mm/Kconfig
===================================================================
--- linux-2.6.21-rc5-mm4.orig/mm/Kconfig	2007-04-07 20:00:19.000000000 -0700
+++ linux-2.6.21-rc5-mm4/mm/Kconfig	2007-04-07 20:02:03.000000000 -0700
@@ -220,3 +220,8 @@
 
 	  Say N for production servers.
 
+config NR_QUICK
+	int
+	depends on QUICKLIST
+	default "1"
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
