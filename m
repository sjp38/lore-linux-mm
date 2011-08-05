Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 78E5F6B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 11:53:26 -0400 (EDT)
Date: Fri, 5 Aug 2011 17:52:59 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] THP: mremap support and TLB optimization #2
Message-ID: <20110805155259.GW9770@redhat.com>
References: <20110728142631.GI3087@redhat.com>
 <20110805105047.GA32064@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110805105047.GA32064@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Fri, Aug 05, 2011 at 12:50:47PM +0200, Johannes Weiner wrote:
> On Thu, Jul 28, 2011 at 04:26:31PM +0200, Andrea Arcangeli wrote:
> > Hello,
> > 
> > this is the latest version of the mremap THP native implementation
> > plus optimizations.
> > 
> > So first question is: am I right, the "- 1" that I am removing below
> > was buggy? It's harmless because these old_end/next are page aligned,
> > but if PAGE_SIZE would be 1, it'd break, right? It's really confusing
> > to read even if it happens to work. Please let me know because that "-
> > 1" ironically it's the thing I'm less comfortable about in this patch.
> 
> > @@ -134,14 +126,17 @@ unsigned long move_page_tables(struct vm
> >  {
> >  	unsigned long extent, next, old_end;
> >  	pmd_t *old_pmd, *new_pmd;
> > +	bool need_flush = false;
> >  
> >  	old_end = old_addr + len;
> >  	flush_cache_range(vma, old_addr, old_end);
> >  
> > +	mmu_notifier_invalidate_range_start(vma->vm_mm, old_addr, old_end);
> > +
> >  	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
> >  		cond_resched();
> >  		next = (old_addr + PMD_SIZE) & PMD_MASK;
> > -		if (next - 1 > old_end)
> > +		if (next > old_end)
> >  			next = old_end;
> 
> If old_addr + PMD_SIZE overflows, next will be zero, thus smaller than
> old_end and not fixed up.  This results in a bogus extent length here:

So basically this -1 is to prevent an overflow and it's relaying on
PAGE_SIZE > 1 to be safe, which is safe assumption.

> >  		extent = next - old_addr;
> 
> which I think can overrun old_addr + len if the extent should have
> actually been smaller than the distance between new_addr and the next
> PMD as well as that LATENCY_LIMIT to which extent is capped a few
> lines below.  I haven't checked all the possibilities, though.
> 
> It could probably be
> 
> 	if (next > old_end || next - 1 > old_end)
> 		next = old_end
> 
> to catch the theoretical next == old_end + 1 case, but PAGE_SIZE > 1
> looks like a sensible assumption to me.

However if old_end == 0, I doubt it could still work safe because next
would be again zero leading to an extreme high extent. It looks like
the last page must not be allowed to be mapped for this to work
safe. sparc is using 0xf0000000 as TASK_SIZE. But being safe on the
PMD is better in case it spans more than 32-4 bits. The pmd_shift on
sparc32 seems at most 23, so it doesn't look problematic. Maybe some
other arch would lead to trouble, but it's possible it never happens
to be problematic and it was just an off by one error as I thought?
For this to break the userland must end less than a PMD_SIZE before
the end of the address space and it's possible no arch is like
that. x86 has pgd_size of 4m on 32bit nopae, and 2m pmd_size for pae
32/64bit and address space 32bit ends at 3g... leaving 1g vs 4m or
>=1g vs 2m.

But hey I prefer to be safe against overflow even if no arch is
actually going to be in trouble and if TASK_SIZE is always set at
least one PMD away from the overflowing point like it seems to happen
on sparc32 too.

So rather than doing -1 which looks more like an off by one error,
it's cleaner to do an explicit overflow check.

This first calculates the next pmd start which may be 0 if it
overflows. Then does 0 - old_addr and stores it in extent. Then
comares old_end-old_addr with extent (where extent is from old_addr to
the next pmd start). If old_end-old_addr is smaller than extent it
stores that into extent to stop at old_end instead of at the next pmd
start. So the -1 goes away.

diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -136,9 +136,10 @@ unsigned long move_page_tables(struct vm
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
 		next = (old_addr + PMD_SIZE) & PMD_MASK;
-		if (next > old_end)
-			next = old_end;
+		/* even if next overflowed, extent below will be ok */
 		extent = next - old_addr;
+		if (extent > old_end - old_addr)
+			extent = old_end - old_addr;
 		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
 		if (!old_pmd)
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
