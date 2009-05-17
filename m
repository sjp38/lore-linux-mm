Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 793DA6B0055
	for <linux-mm@kvack.org>; Sun, 17 May 2009 09:09:23 -0400 (EDT)
Date: Sun, 17 May 2009 21:09:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/8] mm: introduce PageHuge() for testing huge/gigantic
	pages
Message-ID: <20090517130907.GC3254@localhost>
References: <20090508105320.316173813@intel.com> <20090508111030.264063904@intel.com> <20090513170552.GB18006@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090513170552.GB18006@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 01:05:53AM +0800, Mel Gorman wrote:
> Sorry to join the game so late.
> 
> On Fri, May 08, 2009 at 06:53:21PM +0800, Wu Fengguang wrote:
> > Introduce PageHuge(), which identifies huge/gigantic pages
> > by their dedicated compound destructor functions.
> > 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  include/linux/mm.h |   24 ++++++++++++++++++++++++
> >  mm/hugetlb.c       |    2 +-
> >  mm/page_alloc.c    |   11 ++++++++++-
> >  3 files changed, 35 insertions(+), 2 deletions(-)
> > 
> > --- linux.orig/mm/page_alloc.c
> > +++ linux/mm/page_alloc.c
> > @@ -299,13 +299,22 @@ void prep_compound_page(struct page *pag
> >  }
> >  
> >  #ifdef CONFIG_HUGETLBFS
> > +/*
> > + * This (duplicated) destructor function distinguishes gigantic pages from
> > + * normal compound pages.
> > + */
> > +void free_gigantic_page(struct page *page)
> > +{
> > +	__free_pages_ok(page, compound_order(page));
> > +}
> > +
> >  void prep_compound_gigantic_page(struct page *page, unsigned long order)
> >  {
> >  	int i;
> >  	int nr_pages = 1 << order;
> >  	struct page *p = page + 1;
> >  
> > -	set_compound_page_dtor(page, free_compound_page);
> > +	set_compound_page_dtor(page, free_gigantic_page);
> >  	set_compound_order(page, order);
> 
> This made me raise an eyebrow. gigantic pages can never end up back in the
> page allocator.  It should cause bugs all over the place so I looked closer
> and this free_gigantic_page() looks unnecessary.
> 
> This is what happens for gigantic pages at boot-time
> 
> gather_bootmem_prealloc() called at boot-time to gather gigantic pages
>   -> Find the boot allocated pages and call prep_compound_huge_page()
>     -> For gigantic pages, call prep_compound_gigantic_page(), sets destructor to free_compound_page()
>     -> Call prep_new_huge_page(), sets destructor to free_huge_page()
> 
> So, free_gigantic_page() should never used as such in reality and you can
> just check free_huge_page(). If a gigantic page was really freed that way,
> it would be really bad.
> 
> Does that make sense?

You are right, thanks!

> > +#ifdef CONFIG_HUGETLBFS
> > +void free_huge_page(struct page *page);
> > +void free_gigantic_page(struct page *page);
> > +
> > +static inline int PageHuge(struct page *page)
> > +{
> > +	compound_page_dtor *dtor;
> > +
> > +	if (!PageCompound(page))
> > +		return 0;
> > +
> > +	page = compound_head(page);
> > +	dtor = get_compound_page_dtor(page);
> > +
> > +	return  dtor == free_huge_page ||
> > +		dtor == free_gigantic_page;
> > +}
> > +#else
> > +static inline int PageHuge(struct page *page)
> > +{
> > +	return 0;
> > +}
> > +#endif
> 
> That is fairly hefty function to be inline and it exports free_huge_page
> and free_gigantic_page.  The latter of which is dead code and the former
> which was previously a static function.
> 
> At least make PageHuge a non-inlined function contained in mm/hugetlb.c and
> expose it via mm/internal.h if possible or include/linux/hugetlb.h otherwise.

OK, moved the declaration to hugetlb.h, which will be included by fs/proc/page.c.

Andrew, will you replace the -mm patch
        mm-introduce-pagehuge-for-testing-huge-gigantic-pages.patch
with this one?

---
mm: introduce PageHuge() for testing huge/gigantic pages

Introduce PageHuge(), which identifies huge/gigantic pages
by their dedicated compound destructor functions.

Also move prep_compound_gigantic_page() to hugetlb.c and
move adjust_pool_surplus() close to its caller.

CC: Mel Gorman <mel@csn.ul.ie>
CC: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/proc/page.c          |    1 
 include/linux/hugetlb.h |    7 ++
 mm/hugetlb.c            |   98 ++++++++++++++++++++++++--------------
 mm/internal.h           |    5 -
 mm/page_alloc.c         |   17 ------
 5 files changed, 73 insertions(+), 55 deletions(-)

--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -298,23 +298,6 @@ void prep_compound_page(struct page *pag
 	}
 }
 
-#ifdef CONFIG_HUGETLBFS
-void prep_compound_gigantic_page(struct page *page, unsigned long order)
-{
-	int i;
-	int nr_pages = 1 << order;
-	struct page *p = page + 1;
-
-	set_compound_page_dtor(page, free_compound_page);
-	set_compound_order(page, order);
-	__SetPageHead(page);
-	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
-		__SetPageTail(p);
-		p->first_page = page;
-	}
-}
-#endif
-
 static int destroy_compound_page(struct page *page, unsigned long order)
 {
 	int i;
--- linux.orig/mm/hugetlb.c
+++ linux/mm/hugetlb.c
@@ -578,41 +578,6 @@ static void free_huge_page(struct page *
 		hugetlb_put_quota(mapping, 1);
 }
 
-/*
- * Increment or decrement surplus_huge_pages.  Keep node-specific counters
- * balanced by operating on them in a round-robin fashion.
- * Returns 1 if an adjustment was made.
- */
-static int adjust_pool_surplus(struct hstate *h, int delta)
-{
-	static int prev_nid;
-	int nid = prev_nid;
-	int ret = 0;
-
-	VM_BUG_ON(delta != -1 && delta != 1);
-	do {
-		nid = next_node(nid, node_online_map);
-		if (nid == MAX_NUMNODES)
-			nid = first_node(node_online_map);
-
-		/* To shrink on this node, there must be a surplus page */
-		if (delta < 0 && !h->surplus_huge_pages_node[nid])
-			continue;
-		/* Surplus cannot exceed the total number of pages */
-		if (delta > 0 && h->surplus_huge_pages_node[nid] >=
-						h->nr_huge_pages_node[nid])
-			continue;
-
-		h->surplus_huge_pages += delta;
-		h->surplus_huge_pages_node[nid] += delta;
-		ret = 1;
-		break;
-	} while (nid != prev_nid);
-
-	prev_nid = nid;
-	return ret;
-}
-
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
 {
 	set_compound_page_dtor(page, free_huge_page);
@@ -623,6 +588,34 @@ static void prep_new_huge_page(struct hs
 	put_page(page); /* free it into the hugepage allocator */
 }
 
+static void prep_compound_gigantic_page(struct page *page, unsigned long order)
+{
+	int i;
+	int nr_pages = 1 << order;
+	struct page *p = page + 1;
+
+	/* we rely on prep_new_huge_page to set the destructor */
+	set_compound_order(page, order);
+	__SetPageHead(page);
+	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
+		__SetPageTail(p);
+		p->first_page = page;
+	}
+}
+
+int PageHuge(struct page *page)
+{
+	compound_page_dtor *dtor;
+
+	if (!PageCompound(page))
+		return 0;
+
+	page = compound_head(page);
+	dtor = get_compound_page_dtor(page);
+
+	return dtor == free_huge_page;
+}
+
 static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
@@ -1140,6 +1133,41 @@ static inline void try_to_free_low(struc
 }
 #endif
 
+/*
+ * Increment or decrement surplus_huge_pages.  Keep node-specific counters
+ * balanced by operating on them in a round-robin fashion.
+ * Returns 1 if an adjustment was made.
+ */
+static int adjust_pool_surplus(struct hstate *h, int delta)
+{
+	static int prev_nid;
+	int nid = prev_nid;
+	int ret = 0;
+
+	VM_BUG_ON(delta != -1 && delta != 1);
+	do {
+		nid = next_node(nid, node_online_map);
+		if (nid == MAX_NUMNODES)
+			nid = first_node(node_online_map);
+
+		/* To shrink on this node, there must be a surplus page */
+		if (delta < 0 && !h->surplus_huge_pages_node[nid])
+			continue;
+		/* Surplus cannot exceed the total number of pages */
+		if (delta > 0 && h->surplus_huge_pages_node[nid] >=
+						h->nr_huge_pages_node[nid])
+			continue;
+
+		h->surplus_huge_pages += delta;
+		h->surplus_huge_pages_node[nid] += delta;
+		ret = 1;
+		break;
+	} while (nid != prev_nid);
+
+	prev_nid = nid;
+	return ret;
+}
+
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
 static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
 {
--- linux.orig/mm/internal.h
+++ linux/mm/internal.h
@@ -16,9 +16,6 @@
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
-extern void prep_compound_page(struct page *page, unsigned long order);
-extern void prep_compound_gigantic_page(struct page *page, unsigned long order);
-
 static inline void set_page_count(struct page *page, int v)
 {
 	atomic_set(&page->_count, v);
@@ -51,6 +48,8 @@ extern void putback_lru_page(struct page
  */
 extern unsigned long highest_memmap_pfn;
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
+extern void prep_compound_page(struct page *page, unsigned long order);
+
 
 /*
  * function for dealing with page's order in buddy system.
--- linux.orig/include/linux/hugetlb.h
+++ linux/include/linux/hugetlb.h
@@ -11,6 +11,8 @@
 
 struct ctl_table;
 
+int PageHuge(struct page *page);
+
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 {
 	return vma->vm_flags & VM_HUGETLB;
@@ -61,6 +63,11 @@ void hugetlb_change_protection(struct vm
 
 #else /* !CONFIG_HUGETLB_PAGE */
 
+static inline int PageHuge(struct page *page)
+{
+	return 0;
+}
+
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 {
 	return 0;
--- linux.orig/fs/proc/page.c
+++ linux/fs/proc/page.c
@@ -6,6 +6,7 @@
 #include <linux/mmzone.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <linux/hugetlb.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
