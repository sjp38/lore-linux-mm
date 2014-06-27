Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8BAF96B003D
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 08:44:41 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so2788235wib.11
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 05:44:41 -0700 (PDT)
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
        by mx.google.com with ESMTPS id p1si13965292wjx.121.2014.06.27.05.44.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 05:44:40 -0700 (PDT)
Received: by mail-we0-f172.google.com with SMTP id u57so5098698wes.3
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 05:44:39 -0700 (PDT)
Date: Fri, 27 Jun 2014 13:44:37 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH 2/6] arm: mm: Introduce special ptes for LPAE
Message-ID: <20140627124436.GC30585@linaro.org>
References: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
 <1403710824-24340-3-git-send-email-steve.capper@linaro.org>
 <20140627121721.GM26276@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140627121721.GM26276@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Fri, Jun 27, 2014 at 01:17:21PM +0100, Will Deacon wrote:
> On Wed, Jun 25, 2014 at 04:40:20PM +0100, Steve Capper wrote:
> > We need a mechanism to tag ptes as being special, this indicates that
> > no attempt should be made to access the underlying struct page *
> > associated with the pte. This is used by the fast_gup when operating on
> > ptes as it has no means to access VMAs (that also contain this
> > information) locklessly.
> > 
> > The L_PTE_SPECIAL bit is already allocated for LPAE, this patch modifies
> > pte_special and pte_mkspecial to make use of it, and defines
> > __HAVE_ARCH_PTE_SPECIAL.
> > 
> > This patch also excludes special ptes from the icache/dcache sync logic.
> > 
> > Signed-off-by: Steve Capper <steve.capper@linaro.org>
> > ---
> >  arch/arm/include/asm/pgtable-2level.h | 2 ++
> >  arch/arm/include/asm/pgtable-3level.h | 8 ++++++++
> >  arch/arm/include/asm/pgtable.h        | 6 ++----
> >  3 files changed, 12 insertions(+), 4 deletions(-)
> > 
> > diff --git a/arch/arm/include/asm/pgtable-2level.h b/arch/arm/include/asm/pgtable-2level.h
> > index 219ac88..f027941 100644
> > --- a/arch/arm/include/asm/pgtable-2level.h
> > +++ b/arch/arm/include/asm/pgtable-2level.h
> > @@ -182,6 +182,8 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
> >  #define pmd_addr_end(addr,end) (end)
> >  
> >  #define set_pte_ext(ptep,pte,ext) cpu_set_pte_ext(ptep,pte,ext)
> > +#define pte_special(pte)	(0)
> > +static inline pte_t pte_mkspecial(pte_t pte) { return pte; }
> >  
> >  /*
> >   * We don't have huge page support for short descriptors, for the moment
> > diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
> > index 85c60ad..b286ba9 100644
> > --- a/arch/arm/include/asm/pgtable-3level.h
> > +++ b/arch/arm/include/asm/pgtable-3level.h
> > @@ -207,6 +207,14 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
> >  #define pte_huge(pte)		(pte_val(pte) && !(pte_val(pte) & PTE_TABLE_BIT))
> >  #define pte_mkhuge(pte)		(__pte(pte_val(pte) & ~PTE_TABLE_BIT))
> >  
> > +#define pte_special(pte)	(!!(pte_val(pte) & L_PTE_SPECIAL))
> 
> Why the !!? Also, shouldn't this be rebased on your series adding the
> pte_isset macro to ARM?

Yes it should, I had this series logically separate to the pte_isset patch.
I will have the pte_isset patch as a pre-requisite to the ARM fast_gup
activation logic.

> 
> > +static inline pte_t pte_mkspecial(pte_t pte)
> > +{
> > +	pte_val(pte) |= L_PTE_SPECIAL;
> > +	return pte;
> > +}
> 
> If you put this in pgtable.h based on #ifdef __HAVE_ARCH_PTE_SPECIAL, then
> you can use PTE_BIT_FUNC to avoid reinventing the wheel (or define
> L_PTE_SPECIAL as 0 for 2-level and have one function).

Thanks, I'll give this a go.

Cheers,
--
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
