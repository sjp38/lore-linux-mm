Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 74DCC6B02C3
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 06:43:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id w187so164346469pgb.10
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 03:43:34 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b96si1676573pli.366.2017.08.18.03.43.33
        for <linux-mm@kvack.org>;
        Fri, 18 Aug 2017 03:43:33 -0700 (PDT)
Date: Fri, 18 Aug 2017 11:43:28 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v6 4/9] arm64: hugetlb: Add break-before-make logic for
 contiguous entries
Message-ID: <20170818104327.a5yep2p3ntjbffug@armageddon.cambridge.arm.com>
References: <20170810170906.30772-1-punit.agrawal@arm.com>
 <20170810170906.30772-5-punit.agrawal@arm.com>
 <20170817180311.uwrz64g3bkwfdkrn@armageddon.cambridge.arm.com>
 <87shgpnp6p.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87shgpnp6p.fsf@e105922-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: mark.rutland@arm.com, David Woods <dwoods@mellanox.com>, Steve Capper <steve.capper@arm.com>, will.deacon@arm.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Fri, Aug 18, 2017 at 11:30:22AM +0100, Punit Agrawal wrote:
> Catalin Marinas <catalin.marinas@arm.com> writes:
> 
> > On Thu, Aug 10, 2017 at 06:09:01PM +0100, Punit Agrawal wrote:
> >> --- a/arch/arm64/mm/hugetlbpage.c
> >> +++ b/arch/arm64/mm/hugetlbpage.c
> >> @@ -68,6 +68,62 @@ static int find_num_contig(struct mm_struct *mm, unsigned long addr,
> >>  	return CONT_PTES;
> >>  }
> >>  
> >> +/*
> >> + * Changing some bits of contiguous entries requires us to follow a
> >> + * Break-Before-Make approach, breaking the whole contiguous set
> >> + * before we can change any entries. See ARM DDI 0487A.k_iss10775,
> >> + * "Misprogramming of the Contiguous bit", page D4-1762.
> >> + *
> >> + * This helper performs the break step.
> >> + */
> >> +static pte_t get_clear_flush(struct mm_struct *mm,
> >> +			     unsigned long addr,
> >> +			     pte_t *ptep,
> >> +			     unsigned long pgsize,
> >> +			     unsigned long ncontig)
> >> +{
> >> +	unsigned long i, saddr = addr;
> >> +	struct vm_area_struct vma = { .vm_mm = mm };
> >> +	pte_t orig_pte = huge_ptep_get(ptep);
> >> +
> >> +	/*
> >> +	 * If we already have a faulting entry then we don't need
> >> +	 * to break before make (there won't be a tlb entry cached).
> >> +	 */
> >> +	if (!pte_present(orig_pte))
> >> +		return orig_pte;
> >
> > I first thought we could relax this check to pte_valid() as we don't
> > care about the PROT_NONE case for hardware page table updates. However,
> > I realised that we call this where we expect the pte to be entirely
> > cleared but we simply skip it if !present (e.g. swap entry). Is this
> > correct?
> 
> I've checked back and come to the conclusion that get_clear_flush() will
> not get called with swap entries.
> 
> In the case of huge_ptep_get_and_clear() below, the callers
> (__unmap_hugepage_range() and hugetlb_change_protection()) check for
> swap entries before calling. Similarly 
> 
> I'll relax the check to pte_valid().

Thanks for checking but I would still keep the semantics of the generic
huge_ptep_get_and_clear() where the entry is always zeroed. It shouldn't
have any performance impact since this function won't be called for swap
entries, but just in case anyone changes the core code later on.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
