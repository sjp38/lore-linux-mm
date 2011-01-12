Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 78A7F6B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 21:03:55 -0500 (EST)
Date: Wed, 12 Jan 2011 03:02:43 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH mmotm] thp: transparent hugepage core fixlet
Message-ID: <20110112020243.GT9506@random.random>
References: <alpine.LSU.2.00.1101101652200.11559@sister.anvils>
 <20110111015742.GL9506@random.random>
 <AANLkTin=gzZuDBMdGmR5ZY_9f6kggvt0KJA3XK33-z+2@mail.gmail.com>
 <20110111140421.GM9506@random.random>
 <20110111163120.GR9506@random.random>
 <alpine.LSU.2.00.1101111318190.26539@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1101111318190.26539@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Jeremy Fitzhardinge <jeremy@goop.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 11, 2011 at 02:59:43PM -0800, Hugh Dickins wrote:
> On Tue, 11 Jan 2011, Andrea Arcangeli wrote:
> > On Tue, Jan 11, 2011 at 03:04:21PM +0100, Andrea Arcangeli wrote:
> > > architectural bug to me. Why can't pud_huge simply return 0 for
> > > x86_32? Any other place dealing with hugepages and calling pud_huge on
> > > x86 noPAE would be at risk, otherwise, no?
> > 
> > Isn't this better solution?
> 
> [Better solution than my patch to follow_page() in mmotm, to fix crash
> with Transparent Huge Pages by duplicating Andrea's pmd_huge VM_HUGETLB
> check to the pud_huge line too.]
> 
> The truth is, I'm sure one of the solutions is better than the other,
> but I'm too confused by p?d folding to know which is which ;)
> 
> Certainly I don't oppose your patch as a replacement for mine,
> if you're sure yours is better.
> 
> There are only two places which are using pud_huge() anyway:
> follow_page() and apply_to_pmd_range().  Is the latter's
> BUG_ON(pud_huge) safe?  Safe in the THP world?

The latter BUG_ON should be safe in THP world, there's a pmd_huge bug
on too so it can't be a problem in THP world.

> And I never quite understood why we have both pmd_huge and pmd_large,
> pud_huge and pud_large.
> 
> There are answers to these questions, but it would take me hours and
> hours of easily-confused research (across several arches) to decide.
> 
> I'm hoping someone else has a surer grasp: Andi introduced pud_huge(),
> and Jeremy is the most active in the pagetable layers nowadays -
> perhaps they can tell us more quickly.

I'd like their opinion too but for exactly the same reason why you
asked yourself if the latter BUG_ON is safe, I think my patch from
practical prospective reduces the risk.

When THP uses pmd_mkhuge it's counter intuitive that pud_huge returns
1, and there's no benefit to that at all other than risking troubles
like this one. In fact a branch and a block of follow_page is
eliminated at compile time by my patch (as opposed your patch adds one
more branch and can't eliminate a block of code if the second branch
would be taken but we know it can't).

I consider this an arch bug, not common code issue. This is the THP
modifications to the code and I didn't expect having to alter the
pud_huge check in addition to the below one. I thought this shall be
enough if the arch is correct (and optimal).

@@ -1273,11 +1301,32 @@ struct page *follow_page(struct vm_area_
        pmd = pmd_offset(pud, address);
        if (pmd_none(*pmd))
                goto no_page_table;
-       if (pmd_huge(*pmd)) {
+       if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
                BUG_ON(flags & FOLL_GET);
                page = follow_huge_pmd(mm, address, pmd, flags &
        FOLL_WRITE);
                goto out;

I think the x86 3level should work ok with follow_page_pmd (it's
basically identical to follow_page_pud so it won't notice the
difference) so I hope it doesn't break anything, and it will speedup
follow_page too (even when THP is off).

Across the whole tree if you grep for pmd_offset, you'll find all the
places that you've to care for THP, I'd like to still not having to
care about the result of pud_offset (having to care for pmd_offset is
more than enough ;).

Other archs implementing pud_huge should also return 0 if there are
only 3 levels, if they introduce THP, this will have the benefit of
optimizing follow_page when THP is off as well for them.

Your patch is ok if this will not be considered an arch bug (I think
to avoid mistakes pud_huge should be implemented by pgtable-nopud.h
but that's a little bigger cleanup I didn't do myself yet).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
