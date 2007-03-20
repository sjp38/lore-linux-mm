Date: Mon, 19 Mar 2007 18:06:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V3
In-Reply-To: <20070319172142.542c8284.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0703191722110.13927@schroedinger.engr.sgi.com>
References: <20070319233716.13775.45569.sendpatchset@schroedinger.engr.sgi.com>
 <20070319172142.542c8284.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Mar 2007, Andrew Morton wrote:

> > +
> > +#ifdef CONFIG_QUICKLIST
> > +
> > +#ifndef CONFIG_NR_QUICK
> > +#define CONFIG_NR_QUICK 1
> > +#endif
> 
> No, please don't define config items like this.  Do it in Kconfig.

They can be set up in the arch specific Kconfig. Ok. I moved the 
#ifndef .. #endif into mm/Kconfig.

> These guys seem to have multiple callsites for ia64 at least and probably
> would benefit from being uninlined.

Then they would no longer be optimizable. Right now one can compile out 
the constructor / destructor support and provide a constant list number 
as well as constant gfp masks. This can be very small and benefit 
tremendously from inlining.

Many arches do not need some features and there are only a few call 
sites.

> > +void quicklist_check(int nr, void (*dtor)(void *));
> > +unsigned long quicklist_total_size(void);
> > +
> > +#else
> > +void quicklist_check(int nr, void (*dtor)(void *))
> > +{
> > +}
> > +
> > +unsigned long quicklist_total_size(void)
> > +{
> > +	return 0;
> > +}
> > +#endif
> 
> That obviouslty won't link and wasn't tested.  Making these static inline
> will help.

Hmmm... We could drop these conmpletely. If an arch does not use 
quicklists then they should not be calling these.

> > +#include <linux/module.h>
> > +#include <linux/quicklist.h>
> > +
> > +DEFINE_PER_CPU(struct quicklist, quicklist)[CONFIG_NR_QUICK];
> 
> If we uninline those big inlines, this can perhaps be made static.

Yeah but we want the inlines.

> 
> > +#define MIN_PAGES		25
> > +#define MAX_FREES_PER_PASS	16
> > +#define FRACTION_OF_NODE_MEM	16
> 
> Are these constants optimal for all architectures?

I added them as parameters to quicklist_trim so that an arch 
can specify their own settings.

> > +	return min(pages_to_free, (long)MAX_FREES_PER_PASS);
> > +}
> 
> min_t and max_t are the standard way of avoiding that warning.  Or stick a
> UL on the constants (which is probably better).

We do not need those since the constants are now parameters.

> 
> > +void quicklist_check(int nr, void (*dtor)(void *))
> > +{
> > +	long pages_to_free;
> > +	struct quicklist *q;
> > +
> > +	q = &get_cpu_var(quicklist)[nr];
> > +	if (q->nr_pages > MIN_PAGES) {
> > +		pages_to_free = min_pages_to_free(q);
> > +
> > +		while (pages_to_free > 0) {
> > +			void *p = quicklist_alloc(nr, 0, NULL);
> > +
> > +			if (dtor)
> > +				dtor(p);
> > +			free_page((unsigned long)p);
> > +			pages_to_free--;
> > +		}
> > +	}
> > +	put_cpu_var(quicklist);
> > +}
> 
> The use of a literal 0 as a gfp_t is a bit ugly.  I assume that we don't
> care because we should never actually call into the page allocator for this
> caller.  But it's not terribly clear because there is no commentary
> describing what this function is supposed to do.

Right. Will add comments.

> The name foo_check() is unfortunate: it implies that the function checks
> something (ie: has no side-effects).  But this function _does_ change
> things and perhaps should be called quicklist_trim() or something like
> that.

Tradition. Dave initially named it check_pgt_cache it seems.
 
> This function lacks any commentary, but I was able to work it out.  I
> think.  Some nice comments would be, umm, nice.

ok. Here is a fixup patch:

Index: linux-2.6.21-rc3-mm2/include/linux/quicklist.h
===================================================================
--- linux-2.6.21-rc3-mm2.orig/include/linux/quicklist.h	2007-03-19 17:41:42.000000000 -0700
+++ linux-2.6.21-rc3-mm2/include/linux/quicklist.h	2007-03-19 17:47:34.000000000 -0700
@@ -13,10 +13,6 @@
 
 #ifdef CONFIG_QUICKLIST
 
-#ifndef CONFIG_NR_QUICK
-#define CONFIG_NR_QUICK 1
-#endif
-
 struct quicklist {
 	void *page;
 	int nr_pages;
@@ -77,18 +73,11 @@ static inline void quicklist_free(int nr
 	put_cpu_var(quicklist);
 }
 
-void quicklist_check(int nr, void (*dtor)(void *));
-unsigned long quicklist_total_size(void);
+void quicklist_trim(int nr, void (*dtor)(void *),
+	unsigned long min_pages, unsigned long max_free);
 
-#else
-void quicklist_check(int nr, void (*dtor)(void *))
-{
-}
+unsigned long quicklist_total_size(void);
 
-unsigned long quicklist_total_size(void)
-{
-	return 0;
-}
 #endif
 
 #endif /* LINUX_QUICKLIST_H */
Index: linux-2.6.21-rc3-mm2/mm/Kconfig
===================================================================
--- linux-2.6.21-rc3-mm2.orig/mm/Kconfig	2007-03-19 17:41:42.000000000 -0700
+++ linux-2.6.21-rc3-mm2/mm/Kconfig	2007-03-19 17:42:49.000000000 -0700
@@ -220,3 +220,7 @@ config DEBUG_READAHEAD
 
 	  Say N for production servers.
 
+config NR_QUICK
+	depends on QUICKLIST
+	default 1
+
Index: linux-2.6.21-rc3-mm2/mm/quicklist.c
===================================================================
--- linux-2.6.21-rc3-mm2.orig/mm/quicklist.c	2007-03-19 17:41:42.000000000 -0700
+++ linux-2.6.21-rc3-mm2/mm/quicklist.c	2007-03-19 17:53:45.000000000 -0700
@@ -21,39 +21,46 @@
 
 DEFINE_PER_CPU(struct quicklist, quicklist)[CONFIG_NR_QUICK];
 
-#define MIN_PAGES		25
-#define MAX_FREES_PER_PASS	16
 #define FRACTION_OF_NODE_MEM	16
 
-static unsigned long max_pages(void)
+static unsigned long max_pages(unsigned long min_pages)
 {
 	unsigned long node_free_pages, max;
 
 	node_free_pages = node_page_state(numa_node_id(),
 			NR_FREE_PAGES);
 	max = node_free_pages / FRACTION_OF_NODE_MEM;
-	return max(max, (unsigned long)MIN_PAGES);
+	return max(max, min_pages);
 }
 
-static long min_pages_to_free(struct quicklist *q)
+static long min_pages_to_free(struct quicklist *q,
+	unsigned long min_pages, long max_free)
 {
 	long pages_to_free;
 
-	pages_to_free = q->nr_pages - max_pages();
+	pages_to_free = q->nr_pages - max_pages(min_pages);
 
-	return min(pages_to_free, (long)MAX_FREES_PER_PASS);
+	return min(pages_to_free, max_free);
 }
 
-void quicklist_check(int nr, void (*dtor)(void *))
+/*
+ * Trim down the number of pages in the quicklist
+ */
+void quicklist_trim(int nr, void (*dtor)(void *),
+	unsigned long min_pages, unsigned long max_free)
 {
 	long pages_to_free;
 	struct quicklist *q;
 
 	q = &get_cpu_var(quicklist)[nr];
-	if (q->nr_pages > MIN_PAGES) {
-		pages_to_free = min_pages_to_free(q);
+	if (q->nr_pages > min_pages) {
+		pages_to_free = min_pages_to_free(q, min_pages, max_free);
 
 		while (pages_to_free > 0) {
+			/*
+			 * We pass a gfp_t of 0 to quicklist_alloc here
+			 * because we will never call into the page allocator.
+			 */
 			void *p = quicklist_alloc(nr, 0, NULL);
 
 			if (dtor)
Index: linux-2.6.21-rc3-mm2/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.21-rc3-mm2.orig/arch/i386/mm/pgtable.c	2007-03-19 17:42:44.000000000 -0700
+++ linux-2.6.21-rc3-mm2/arch/i386/mm/pgtable.c	2007-03-19 17:42:49.000000000 -0700
@@ -299,6 +299,6 @@ void pgd_free(pgd_t *pgd)
 
 void check_pgt_cache(void)
 {
-	quicklist_check(QUICK_PGD, pgd_dtor);
-	quicklist_check(QUICK_PMD, NULL);
+	quicklist_trim(QUICK_PGD, pgd_dtor, 25, 16);
+	quicklist_trim(QUICK_PMD, NULL, 25, 16);
 }
Index: linux-2.6.21-rc3-mm2/include/asm-x86_64/pgalloc.h
===================================================================
--- linux-2.6.21-rc3-mm2.orig/include/asm-x86_64/pgalloc.h	2007-03-19 17:42:46.000000000 -0700
+++ linux-2.6.21-rc3-mm2/include/asm-x86_64/pgalloc.h	2007-03-19 17:42:49.000000000 -0700
@@ -121,7 +121,7 @@ static inline void pte_free(struct page 
 
 static inline void check_pgt_cache(void)
 {
-	quicklist_check(QUICK_PGD, pgd_dtor);
-	quicklist_check(QUICK_PT, NULL);
+	quicklist_trim(QUICK_PGD, pgd_dtor, 25, 16);
+	quicklist_trim(QUICK_PT, NULL, 25, 16);
 }
 #endif /* _X86_64_PGALLOC_H */
Index: linux-2.6.21-rc3-mm2/include/asm-sparc64/pgalloc.h
===================================================================
--- linux-2.6.21-rc3-mm2.orig/include/asm-sparc64/pgalloc.h	2007-03-19 17:42:47.000000000 -0700
+++ linux-2.6.21-rc3-mm2/include/asm-sparc64/pgalloc.h	2007-03-19 17:42:49.000000000 -0700
@@ -67,7 +67,7 @@ static inline void pte_free(struct page 
 
 static inline void check_pgt_cache(void)
 {
-	quicklist_check(0, NULL);
+	quicklist_trim(0, NULL, 25, 16);
 }
 
 #endif /* _SPARC64_PGALLOC_H */
Index: linux-2.6.21-rc3-mm2/include/asm-ia64/pgalloc.h
===================================================================
--- linux-2.6.21-rc3-mm2.orig/include/asm-ia64/pgalloc.h	2007-03-19 17:42:43.000000000 -0700
+++ linux-2.6.21-rc3-mm2/include/asm-ia64/pgalloc.h	2007-03-19 17:42:59.000000000 -0700
@@ -106,7 +106,7 @@ static inline void pte_free_kernel(pte_t
 
 static inline void check_pgt_cache(void)
 {
-	quicklist_check(0, NULL);
+	quicklist_trim(0, NULL, 25, 16);
 }
 
 #define __pte_free_tlb(tlb, pte)	pte_free(pte)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
