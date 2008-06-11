Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5B08tkF019246
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 20:08:55 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5B06StU241790
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 20:06:28 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5B06SYB003239
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 20:06:28 -0400
Subject: [RFC v3][PATCH 2/2] fix large pages in pagemap
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1213140376.20045.33.camel@calx>
References: <20080606185521.38CA3421@kernel>
	 <20080606185522.89DF8EEE@kernel>  <1213140376.20045.33.camel@calx>
Content-Type: text/plain; charset=UTF-8
Date: Tue, 10 Jun 2008 17:06:27 -0700
Message-Id: <1213142787.7261.27.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Hans Rosenfeld <hans.rosenfeld@amd.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-06-10 at 18:26 -0500, Matt Mackall wrote:
> > +		/*
> > +		 * Remember that find_vma() returns the
> > +		 * first vma with a vm_end > addr, but
> > +		 * has no guarantee about addr and
> > +		 * vm_start.  That means we'll always
> > +		 * find a vma here, unless we're at
> > +		 * an addr higher than the highest vma.
> > +		 */
> 
> I don't like this comment much - I had to read it several times to
> convince myself the code was correct. I think it should instead be three
> pieces and perhaps a new variable name, like this:

I'll agree with you on that.  :)

I think I'll keep the variable name the same, though.  Adding 'target'
doesn't really tell us anything.  I can see if we had a couple of
different vmas in there, but since there's only one, I think I'll just
keep a simple name.  

> i>>?          /* find the first VMA at or after our current address */
> > +	struct vm_area_struct *targetvma = find_vma(walk->mm, addr);
> 
>           	/* find next target VMA if we leave current one */
> > +		if (targetvma && (addr >= targetvma->vm_end))
> > +			targetvma = find_vma(walk->mm, addr);
> 
>           	/* if inside non-huge target VMA, map it */
> > +		if (targetvma && (targetvma->vm_start <= addr) &&
> > +		    !is_vm_hugetlb_page(targetvma)) {

I've tried to incorporate the spirit of these comments.  Let me know
what you think.

> Also, might as well move the map/unmap inside the utility function if
> we're going to have one, no?

Yeah, but then we have to pass 'pmd' and 'addr' in there, too.  I guess
I could do that, but this looked OK as is.

How does this look?

--

We were walking right into huge page areas in the pagemap
walker, and calling the pmds pmd_bad() and clearing them.

That leaked huge pages.  Bad.

This patch at least works around that for now.  It ignores
huge pages in the pagemap walker for the time being, and
won't leak those pages.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/fs/proc/task_mmu.c |   42 ++++++++++++++++++++++++++--------
 1 file changed, 33 insertions(+), 9 deletions(-)

diff -puN fs/proc/task_mmu.c~fix-large-pages-in-pagemap fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~fix-large-pages-in-pagemap	2008-06-10 16:54:48.000000000 -0700
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2008-06-10 17:02:17.000000000 -0700
@@ -563,24 +563,48 @@ static u64 swap_pte_to_pagemap_entry(pte
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
+	struct vm_area_struct *vma;
 	struct pagemapread *pm = walk->private;
 	pte_t *pte;
 	int err = 0;
 
+	/* find the first VMA at or above 'addr' */
+       	vma = find_vma(walk->mm, addr);
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
+		/* check to see if we've left 'vma' behind
+		 * and need a new, higher one */
+		if (vma && (addr >= vma->vm_end))
+			vma = find_vma(walk->mm, addr);
+
+		/* check that 'vma' actually covers this address,
+		 * and that it isn't a huge page vma */
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
_


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
