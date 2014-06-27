Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id EC01A6B0039
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 08:20:56 -0400 (EDT)
Received: by mail-yh0-f53.google.com with SMTP id b6so2934369yha.40
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 05:20:56 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id t15si2896549yha.5.2014.06.27.05.20.55
        for <linux-mm@kvack.org>;
        Fri, 27 Jun 2014 05:20:56 -0700 (PDT)
Date: Fri, 27 Jun 2014 13:20:32 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 6/6] arm64: mm: Enable RCU fast_gup
Message-ID: <20140627122032.GN26276@arm.com>
References: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
 <1403710824-24340-7-git-send-email-steve.capper@linaro.org>
 <20140625165003.GI15240@leverpostej>
 <20140626075605.GB12054@laptop.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140626075605.GB12054@laptop.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mark Rutland <Mark.Rutland@arm.com>, Steve Capper <steve.capper@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Jun 26, 2014 at 08:56:05AM +0100, Peter Zijlstra wrote:
> On Wed, Jun 25, 2014 at 05:50:03PM +0100, Mark Rutland wrote:
> > Hi Steve,
> > 
> > On Wed, Jun 25, 2014 at 04:40:24PM +0100, Steve Capper wrote:
> > > Activate the RCU fast_gup for ARM64. We also need to force THP splits
> > > to broadcast an IPI s.t. we block in the fast_gup page walker. As THP
> > > splits are comparatively rare, this should not lead to a noticeable
> > > performance degradation.
> > > 
> > > Some pre-requisite functions pud_write and pud_page are also added.
> > > 
> > > Signed-off-by: Steve Capper <steve.capper@linaro.org>
> > > ---
> > >  arch/arm64/Kconfig               |  3 +++
> > >  arch/arm64/include/asm/pgtable.h | 11 ++++++++++-
> > >  arch/arm64/mm/flush.c            | 19 +++++++++++++++++++
> > >  3 files changed, 32 insertions(+), 1 deletion(-)
> > 
> > [...]
> > 
> > > diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
> > > index e4193e3..ddf96c1 100644
> > > --- a/arch/arm64/mm/flush.c
> > > +++ b/arch/arm64/mm/flush.c
> > > @@ -103,3 +103,22 @@ EXPORT_SYMBOL(flush_dcache_page);
> > >   */
> > >  EXPORT_SYMBOL(flush_cache_all);
> > >  EXPORT_SYMBOL(flush_icache_range);
> > > +
> > > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > > +#ifdef CONFIG_HAVE_RCU_TABLE_FREE
> > > +static void thp_splitting_flush_sync(void *arg)
> > > +{
> > > +}
> > > +
> > > +void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
> > > +			  pmd_t *pmdp)
> > > +{
> > > +	pmd_t pmd = pmd_mksplitting(*pmdp);
> > > +	VM_BUG_ON(address & ~PMD_MASK);
> > > +	set_pmd_at(vma->vm_mm, address, pmdp, pmd);
> > > +
> > > +	/* dummy IPI to serialise against fast_gup */
> > > +	smp_call_function(thp_splitting_flush_sync, NULL, 1);
> > 
> > Is there some reason we can't use kick_all_cpus_sync()?
> 
> Yes that would be equivalent. But looking at that, I worry about the
> smp_mb(); archs are supposed to make sure IPIs are serializing.

Agreed; smp_call_function would be hopelessly broken if that wasn't true
(at least, everywhere I've used it ;)

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
