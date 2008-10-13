Date: Mon, 13 Oct 2008 14:34:04 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 1/1] hugetlbfs: handle pages higher order than MAX_ORDER
Message-ID: <20081013133404.GC15657@brain>
References: <1223458431-12640-1-git-send-email-apw@shadowen.org> <1223458431-12640-2-git-send-email-apw@shadowen.org> <48ECDD37.8050506@linux-foundation.org> <20081008185532.GA13304@brain> <48ED0B68.2060001@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48ED0B68.2060001@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 08, 2008 at 02:35:04PM -0500, Christoph Lameter wrote:
> Andy Whitcroft wrote:
> 
> > With SPARSEMEM turned on and VMEMMAP turned off a valid combination,
> > we will end up scribbling all over memory which is pretty serious so for
> > that reason we should handle this case.  There are cirtain combinations
> > of features which require SPARSMEM but preclude VMEMMAP which trigger this.
> 
> Which configurations are we talking about? 64 bit configs may generally be
> able to use VMEMMAP since they have lots of virtual address space.

Currently memory hot remove is not supported with VMEMMAP.  Obviously
that should be fixed overall and I am assuming it will.  But the fact
remains that the buddy guarentee is that the mem_map is contigious out
to MAX_ORDER-1 order pages only beyond that we may not assume
contiguity.  This code is broken under the guarentees that are set out
by buddy.  Yes it is true that we do only have one memory model combination
currently where a greater guarentee of contigious within a node is
violated, but right now this code violates the current guarentees.

I assume the objection here is the injection of the additional branch
into these loops.  The later rejig patch removes this for the non-giant
cases for the non-huge use cases.  Are we worried about these same
branches in the huge cases?  If so we could make this support dependant
on a new configuration option, or perhaps only have two loop chosen
based on the order of the page.

Something like the patch below?  This patch is not tested as yet, but if
this form is acceptable we can get the pair of patches (this plus the
prep compound update) tested together and I can repost them once that is
done.  This against 2.6.27.

-apw

Author: Andy Whitcroft <apw@shadowen.org>
Date:   Mon Oct 13 14:28:44 2008 +0100

    hugetlbfs: handle pages higher order than MAX_ORDER
    
    When working with hugepages, hugetlbfs assumes that those hugepages
    are smaller than MAX_ORDER.  Specifically it assumes that the mem_map
    is contigious and uses that to optimise access to the elements of the
    mem_map that represent the hugepage.  Gigantic pages (such as 16GB pages
    on powerpc) by definition are of greater order than MAX_ORDER (larger
    than MAX_ORDER_NR_PAGES in size).  This means that we can no longer make
    use of the buddy alloctor guarentees for the contiguity of the mem_map,
    which ensures that the mem_map is at least contigious for maximmally
    aligned areas of MAX_ORDER_NR_PAGES pages.
    
    This patch adds new mem_map accessors and iterator helpers which handle
    any discontiguity at MAX_ORDER_NR_PAGES boundaries.  It then uses these
    to implement gigantic page versions of copy_huge_page and clear_huge_page,
    and to allow follow_hugetlb_page handle gigantic pages.
    
    Signed-off-by: Andy Whitcroft <apw@shadowen.org>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 67a7119..793f52e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -353,11 +353,26 @@ static int vma_has_reserves(struct vm_area_struct *vma)
 	return 0;
 }
 
+static void clear_gigantic_page(struct page *page,
+			unsigned long addr, unsigned long sz)
+{
+	int i;
+	struct page *p = page;
+
+	might_sleep();
+	for (i = 0; i < sz/PAGE_SIZE; i++, p = mem_map_next(p, page, i)) {
+		cond_resched();
+		clear_user_highpage(p, addr + i * PAGE_SIZE);
+	}
+}
 static void clear_huge_page(struct page *page,
 			unsigned long addr, unsigned long sz)
 {
 	int i;
 
+	if (unlikely(sz > MAX_ORDER_NR_PAGES))
+		return clear_gigantic_page(page, addr, sz);
+
 	might_sleep();
 	for (i = 0; i < sz/PAGE_SIZE; i++) {
 		cond_resched();
@@ -365,12 +380,32 @@ static void clear_huge_page(struct page *page,
 	}
 }
 
+static void copy_gigantic_page(struct page *dst, struct page *src,
+			   unsigned long addr, struct vm_area_struct *vma)
+{
+	int i;
+	struct hstate *h = hstate_vma(vma);
+	struct page *dst_base = dst;
+	struct page *src_base = src;
+	might_sleep();
+	for (i = 0; i < pages_per_huge_page(h); ) {
+		cond_resched();
+		copy_user_highpage(dst, src, addr + i*PAGE_SIZE, vma);
+
+		i++;
+		dst = mem_map_next(dst, dst_base, i);
+		src = mem_map_next(src, src_base, i);
+	}
+}
 static void copy_huge_page(struct page *dst, struct page *src,
 			   unsigned long addr, struct vm_area_struct *vma)
 {
 	int i;
 	struct hstate *h = hstate_vma(vma);
 
+	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES))
+		return copy_gigantic_page(dst, src, addr, vma);
+
 	might_sleep();
 	for (i = 0; i < pages_per_huge_page(h); i++) {
 		cond_resched();
@@ -2103,7 +2138,7 @@ int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 same_page:
 		if (pages) {
 			get_page(page);
-			pages[i] = page + pfn_offset;
+			pages[i] = mem_map_offset(page, pfn_offset);
 		}
 
 		if (vmas)
diff --git a/mm/internal.h b/mm/internal.h
index 1f43f74..08b8dea 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -53,6 +53,34 @@ static inline unsigned long page_order(struct page *page)
 }
 
 /*
+ * Return the mem_map entry representing the 'offset' subpage within
+ * the maximally aligned gigantic page 'base'.  Handle any discontiguity
+ * in the mem_map at MAX_ORDER_NR_PAGES boundaries.
+ */
+static inline struct page *mem_map_offset(struct page *base, int offset)
+{
+	if (unlikely(offset >= MAX_ORDER_NR_PAGES))
+		return pfn_to_page(page_to_pfn(base) + offset);
+	return base + offset;
+}
+
+/*
+ * Iterator over all subpages withing the maximally aligned gigantic
+ * page 'base'.  Handle any discontiguity in the mem_map.
+ */
+static inline struct page *mem_map_next(struct page *iter,
+						struct page *base, int offset)
+{
+	if (unlikely((offset & (MAX_ORDER_NR_PAGES - 1)) == 0)) {
+		unsigned long pfn = page_to_pfn(base) + offset;
+		if (!pfn_valid(pfn))
+			return NULL;
+		return pfn_to_page(pfn);
+	}
+	return iter + 1;
+}
+
+/*
  * FLATMEM and DISCONTIGMEM configurations use alloc_bootmem_node,
  * so all functions starting at paging_init should be marked __init
  * in those cases. SPARSEMEM, however, allows for memory hotplug,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
