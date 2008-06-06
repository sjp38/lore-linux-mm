Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m56IjN8F025750
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 14:45:23 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m56IjN2e208278
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 14:45:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m56IjMmj005785
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 14:45:22 -0400
Subject: Re: [RFC][PATCH 2/2] fix large pages in pagemap
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1212776056.14718.21.camel@calx>
References: <20080606173137.24513039@kernel>
	 <20080606173138.9BFE6272@kernel>  <1212776056.14718.21.camel@calx>
Content-Type: text/plain
Date: Fri, 06 Jun 2008 11:45:11 -0700
Message-Id: <1212777911.7837.32.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Hans Rosenfeld <hans.rosenfeld@amd.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-06-06 at 13:14 -0500, Matt Mackall wrote:
> On Fri, 2008-06-06 at 10:31 -0700, Dave Hansen wrote:
> > We were walking right into huge page areas in the pagemap
> > walker, and calling the pmds pmd_bad() and clearing them.
> > 
> > That leaked huge pages.  Bad.
> > 
> > This patch at least works around that for now.  It ignores
> > huge pages in the pagemap walker for the time being, and
> > won't leak those pages.
> > 
> > Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> > ---
> > 
> >  linux-2.6.git-dave/fs/proc/task_mmu.c |    8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff -puN fs/proc/task_mmu.c~fix-large-pages-in-pagemap fs/proc/task_mmu.c
> > --- linux-2.6.git/fs/proc/task_mmu.c~fix-large-pages-in-pagemap	2008-06-06 09:44:45.000000000 -0700
> > +++ linux-2.6.git-dave/fs/proc/task_mmu.c	2008-06-06 09:48:44.000000000 -0700
> > @@ -567,12 +567,19 @@ static u64 swap_pte_to_pagemap_entry(pte
> >  static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> >  			     struct mm_walk *walk)
> >  {
> > +	struct vm_area_struct *vma = NULL;
> >  	struct pagemapread *pm = walk->private;
> >  	pte_t *pte;
> >  	int err = 0;
> >  
> >  	for (; addr != end; addr += PAGE_SIZE) {
> >  		u64 pfn = PM_NOT_PRESENT;
> > +
> > +		if (!vma || addr >= vma->vm_end)
> > +			vma = find_vma(walk->mm, addr);
> > +		if (vma && is_vm_hugetlb_page(vma)) {
> > +			goto add:
> >
> >  		pte = pte_offset_map(pmd, addr);
> >  		if (is_swap_pte(*pte))
> >  			pfn = PM_PFRAME(swap_pte_to_pagemap_entry(*pte))
> > @@ -582,6 +589,7 @@ static int pagemap_pte_range(pmd_t *pmd,
> >  				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
> >  		/* unmap so we're not in atomic when we copy to userspace */
> >  		pte_unmap(pte);
> > +	add:
> >  		err = add_to_pagemap(addr, pfn, pm);
> >  		if (err)
> >  			return err;
> 
> This makes me frown a bit. First, there's a spurious '{' before 'goto
> add'.

Huh.  I must have managed to stick that in there after I compiled.  Will
fix.

> Second, it'd be cleaner to invert the sense of the if and do the
> pte junk in the body, rather than have a goto, no?

Sure thing.  Updated patch attached.

> I'm also worried that calling find_vma for every pte in an unmapped
> space is going to be slow.

You just reminded me that I forgot a check on find_vma() since it can
return vmas which are actually above 'addr'.  This code (I think
correctly) assumes that once find_vma() starts returning NULL, it will
keep returning NULL.  So, once we stop seeing VMAs, we stop doing
find_vma().

This code should be limited to calling find_vma() once per "pmd
entry"/"pte page" or when the vma actually changes.

--

We were walking right into huge page areas in the pagemap
walker, and calling the pmds pmd_bad() and clearing them.

That leaked huge pages.  Bad.

This patch at least works around that for now.  It ignores
huge pages in the pagemap walker for the time being, and
won't leak those pages.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/fs/proc/task_mmu.c |   43 ++++++++++++++++++++++++++--------
 1 file changed, 34 insertions(+), 9 deletions(-)

diff -puN fs/proc/task_mmu.c~fix-large-pages-in-pagemap fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~fix-large-pages-in-pagemap	2008-06-06 11:31:48.000000000 -0700
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2008-06-06 11:41:22.000000000 -0700
@@ -563,24 +563,49 @@ static u64 swap_pte_to_pagemap_entry(pte
 	return swp_type(e) | (swp_offset(e) << MAX_SWAPFILES_SHIFT);
 }
 
+static unsigned long pte_to_pagemap_entry(pte_t pte)
+{
+	unsigned long pme = 0;
+	if (is_swap_pte(pte))
+		pme = PM_PFRAME(swap_pte_to_pagemap_entry(pte))
+			| PM_PSHIFT(PAGE_SHIFT) | PM_SWAP;
+	else if (pte_present(pte))
+		pme = PM_PFRAME(pte_pfn(pte))
+			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
+	return pme;
+}
+
 static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			     struct mm_walk *walk)
 {
+	struct vm_area_struct *vma = find_vma(walk->mm, addr);
 	struct pagemapread *pm = walk->private;
 	pte_t *pte;
 	int err = 0;
 
 	for (; addr != end; addr += PAGE_SIZE) {
 		u64 pfn = PM_NOT_PRESENT;
-		pte = pte_offset_map(pmd, addr);
-		if (is_swap_pte(*pte))
-			pfn = PM_PFRAME(swap_pte_to_pagemap_entry(*pte))
-				| PM_PSHIFT(PAGE_SHIFT) | PM_SWAP;
-		else if (pte_present(*pte))
-			pfn = PM_PFRAME(pte_pfn(*pte))
-				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
-		/* unmap so we're not in atomic when we copy to userspace */
-		pte_unmap(pte);
+
+		/*
+		 * Remember that find_vma() returns the
+		 * first vma with a vm_end > addr, but
+		 * has no guarantee about addr and
+		 * vm_start.  That means we'll always
+		 * find a vma here, unless we're at
+		 * an addr higher than the highest vma.
+		 */
+		if (vma && (addr >= vma->vm_end))
+			vma = find_vma(walk->mm, addr);
+		if (vma && (vma->vm_start <= addr) &&
+		    !is_vm_hugetlb_page(vma)) {
+			pte = pte_offset_map(pmd, addr);
+			pfn = pte_to_pagemap_entry(*pte);
+			/*
+			 * unmap so we're not in atomic
+			 * when we copy to userspace
+			 */
+			pte_unmap(pte);
+		}
 		err = add_to_pagemap(addr, pfn, pm);
 		if (err)
 			return err;
diff -puN mm/pagewalk.c~fix-large-pages-in-pagemap mm/pagewalk.c
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
