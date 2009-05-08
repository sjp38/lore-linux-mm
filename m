Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 385626B005C
	for <linux-mm@kvack.org>; Fri,  8 May 2009 00:17:27 -0400 (EDT)
Date: Fri, 8 May 2009 12:17:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH] vmscan: report vm_flags in page_referenced()
Message-ID: <20090508041700.GC8892@localhost>
References: <20090430181340.6f07421d.akpm@linux-foundation.org> <20090430215034.4748e615@riellaptop.surriel.com> <20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com> <20090501123541.7983a8ae.akpm@linux-foundation.org> <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org> <1241709466.11251.164.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1241709466.11251.164.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 07, 2009 at 11:17:46PM +0800, Peter Zijlstra wrote:
> On Thu, 2009-05-07 at 17:10 +0200, Johannes Weiner wrote:
> 
> > > @@ -1269,8 +1270,15 @@ static void shrink_active_list(unsigned 
> > >  
> > >  		/* page_referenced clears PageReferenced */
> > >  		if (page_mapping_inuse(page) &&
> > > -		    page_referenced(page, 0, sc->mem_cgroup))
> > > +		    page_referenced(page, 0, sc->mem_cgroup)) {
> > > +			struct address_space *mapping = page_mapping(page);
> > > +
> > >  			pgmoved++;
> > > +			if (mapping && test_bit(AS_EXEC, &mapping->flags)) {
> > > +				list_add(&page->lru, &l_active);
> > > +				continue;
> > > +			}
> > > +		}
> > 
> > Since we walk the VMAs in page_referenced anyway, wouldn't it be
> > better to check if one of them is executable?  This would even work
> > for executable anon pages.  After all, there are applications that cow
> > executable mappings (sbcl and other language environments that use an
> > executable, run-time modified core image come to mind).
> 
> Hmm, like provide a vm_flags mask along to page_referenced() to only
> account matching vmas... seems like a sensible idea.

Here is a quick patch for your opinions. Compile tested.

With the added vm_flags reporting, the mlock=>unevictable logic can
possibly be made more straightforward.

Thanks,
Fengguang
---
vmscan: report vm_flags in page_referenced()

This enables more informed reclaim heuristics, eg. to protect executable
file pages more aggressively.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/rmap.h |    5 +++--
 mm/rmap.c            |   30 +++++++++++++++++++++---------
 mm/vmscan.c          |    7 +++++--
 3 files changed, 29 insertions(+), 13 deletions(-)

--- linux.orig/include/linux/rmap.h
+++ linux/include/linux/rmap.h
@@ -83,7 +83,8 @@ static inline void page_dup_rmap(struct 
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-int page_referenced(struct page *, int is_locked, struct mem_cgroup *cnt);
+int page_referenced(struct page *, int is_locked,
+			struct mem_cgroup *cnt, unsigned long *vm_flags);
 int try_to_unmap(struct page *, int ignore_refs);
 
 /*
@@ -128,7 +129,7 @@ int page_wrprotect(struct page *page, in
 #define anon_vma_prepare(vma)	(0)
 #define anon_vma_link(vma)	do {} while (0)
 
-#define page_referenced(page,l,cnt) TestClearPageReferenced(page)
+#define page_referenced(page, locked, cnt, flags) TestClearPageReferenced(page)
 #define try_to_unmap(page, refs) SWAP_FAIL
 
 static inline int page_mkclean(struct page *page)
--- linux.orig/mm/rmap.c
+++ linux/mm/rmap.c
@@ -333,7 +333,8 @@ static int page_mapped_in_vma(struct pag
  * repeatedly from either page_referenced_anon or page_referenced_file.
  */
 static int page_referenced_one(struct page *page,
-	struct vm_area_struct *vma, unsigned int *mapcount)
+			       struct vm_area_struct *vma,
+			       unsigned int *mapcount)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -385,7 +386,8 @@ out:
 }
 
 static int page_referenced_anon(struct page *page,
-				struct mem_cgroup *mem_cont)
+				struct mem_cgroup *mem_cont,
+				unsigned long *vm_flags)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
@@ -406,6 +408,7 @@ static int page_referenced_anon(struct p
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
 		referenced += page_referenced_one(page, vma, &mapcount);
+		*vm_flags |= vma->vm_flags;
 		if (!mapcount)
 			break;
 	}
@@ -418,6 +421,7 @@ static int page_referenced_anon(struct p
  * page_referenced_file - referenced check for object-based rmap
  * @page: the page we're checking references on.
  * @mem_cont: target memory controller
+ * @vm_flags: collect the encountered vma->vm_flags
  *
  * For an object-based mapped page, find all the places it is mapped and
  * check/clear the referenced flag.  This is done by following the page->mapping
@@ -427,7 +431,8 @@ static int page_referenced_anon(struct p
  * This function is only called from page_referenced for object-based pages.
  */
 static int page_referenced_file(struct page *page,
-				struct mem_cgroup *mem_cont)
+				struct mem_cgroup *mem_cont,
+				unsigned long *vm_flags)
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
@@ -468,6 +473,7 @@ static int page_referenced_file(struct p
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
 		referenced += page_referenced_one(page, vma, &mapcount);
+		*vm_flags |= vma->vm_flags;
 		if (!mapcount)
 			break;
 	}
@@ -481,29 +487,35 @@ static int page_referenced_file(struct p
  * @page: the page to test
  * @is_locked: caller holds lock on the page
  * @mem_cont: target memory controller
+ * @vm_flags: collect the encountered vma->vm_flags
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
  */
-int page_referenced(struct page *page, int is_locked,
-			struct mem_cgroup *mem_cont)
+int page_referenced(struct page *page,
+		    int is_locked,
+		    struct mem_cgroup *mem_cont,
+		    unsigned long *vm_flags)
 {
 	int referenced = 0;
 
 	if (TestClearPageReferenced(page))
 		referenced++;
 
+	*vm_flags = 0;
 	if (page_mapped(page) && page->mapping) {
 		if (PageAnon(page))
-			referenced += page_referenced_anon(page, mem_cont);
+			referenced += page_referenced_anon(page, mem_cont,
+								vm_flags);
 		else if (is_locked)
-			referenced += page_referenced_file(page, mem_cont);
+			referenced += page_referenced_file(page, mem_cont,
+								vm_flags);
 		else if (!trylock_page(page))
 			referenced++;
 		else {
 			if (page->mapping)
-				referenced +=
-					page_referenced_file(page, mem_cont);
+				referenced += page_referenced_file(page,
+							mem_cont, vm_flags);
 			unlock_page(page);
 		}
 	}
--- linux.orig/mm/vmscan.c
+++ linux/mm/vmscan.c
@@ -598,6 +598,7 @@ static unsigned long shrink_page_list(st
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
+	unsigned long vm_flags;
 
 	cond_resched();
 
@@ -648,7 +649,8 @@ static unsigned long shrink_page_list(st
 				goto keep_locked;
 		}
 
-		referenced = page_referenced(page, 1, sc->mem_cgroup);
+		referenced = page_referenced(page, 1,
+						sc->mem_cgroup, &vm_flags);
 		/* In active use or really unfreeable?  Activate it. */
 		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
 					referenced && page_mapping_inuse(page))
@@ -1229,6 +1231,7 @@ static void shrink_active_list(unsigned 
 {
 	unsigned long pgmoved;
 	unsigned long pgscanned;
+	unsigned long vm_flags;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_inactive);
 	struct page *page;
@@ -1269,7 +1272,7 @@ static void shrink_active_list(unsigned 
 
 		/* page_referenced clears PageReferenced */
 		if (page_mapping_inuse(page) &&
-		    page_referenced(page, 0, sc->mem_cgroup))
+		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags))
 			pgmoved++;
 
 		list_add(&page->lru, &l_inactive);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
