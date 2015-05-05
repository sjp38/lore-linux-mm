Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id D94D66B0032
	for <linux-mm@kvack.org>; Tue,  5 May 2015 10:05:43 -0400 (EDT)
Received: by oiko83 with SMTP id o83so148466878oik.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 07:05:43 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id wd5si10242254obc.21.2015.05.05.07.05.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 07:05:43 -0700 (PDT)
Message-ID: <1430833596.23761.245.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 1/7] mm, x86: Document return values of mapping funcs
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 05 May 2015 07:46:36 -0600
In-Reply-To: <20150505111913.GH3910@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-2-git-send-email-toshi.kani@hp.com>
	 <20150505111913.GH3910@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, 2015-05-05 at 13:19 +0200, Borislav Petkov wrote:
> On Tue, Mar 24, 2015 at 04:08:35PM -0600, Toshi Kani wrote:
> > Document the return values of KVA mapping functions,
> 
> KVA?
> Please write it out.

Will expand it as Kernel Virtual Address.

> > pud_set_huge(), pmd_set_huge, pud_clear_huge() and
> > pmd_clear_huge().
> > 
> > Simplify the conditions to select HAVE_ARCH_HUGE_VMAP
> > in the Kconfig, since X86_PAE depends on X86_32.
> > 
> > There is no functional change in this patch.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > ---
> >  arch/x86/Kconfig      |    2 +-
> >  arch/x86/mm/pgtable.c |   36 ++++++++++++++++++++++++++++--------
> >  2 files changed, 29 insertions(+), 9 deletions(-)
> > 
> > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> > index cb23206..2ea27da 100644
> > --- a/arch/x86/Kconfig
> > +++ b/arch/x86/Kconfig
> > @@ -99,7 +99,7 @@ config X86
> >  	select IRQ_FORCED_THREADING
> >  	select HAVE_BPF_JIT if X86_64
> >  	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
> > -	select HAVE_ARCH_HUGE_VMAP if X86_64 || (X86_32 && X86_PAE)
> > +	select HAVE_ARCH_HUGE_VMAP if X86_64 || X86_PAE
> >  	select ARCH_HAS_SG_CHAIN
> >  	select CLKEVT_I8253
> >  	select ARCH_HAVE_NMI_SAFE_CMPXCHG
> 
> This is an unrelated change, please carve it out in a separate patch.

Will do.

> > diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> > index 0b97d2c..4891fa1 100644
> > --- a/arch/x86/mm/pgtable.c
> > +++ b/arch/x86/mm/pgtable.c
> > @@ -563,14 +563,19 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
> >  }
> >  
> >  #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
> > +/**
> > + * pud_set_huge - setup kernel PUD mapping
> > + *
> > + * MTRR can override PAT memory types with 4KB granularity.  Therefore,
> > + * it does not set up a huge page when the range is covered by a non-WB
> 
> "it" is what exactly?

Will change to "this function".

> > + * type of MTRR.  0xFF indicates that MTRR are disabled.
> 
> So this shows that this patch shouldn't be the first one in the series.
> 
> IMO you want to start with cleaning up mtrr_type_lookup(), add the
> defines for its retval and *then* document its users. This way you won't
> have to touch the same place twice, the net-size of your patchset will
> go down and it will be easier for reviewiers.

Agreed.  This patch-set was originally a small set of patches, but was
extended later with additional patches, which ended up with touching the
same place again.  I will reorganize the patch-set. 

> > + *
> > + * Return 1 on success, and 0 when no PUD was set.
> 
> "Returns 1 on success and 0 on failure."

Will do.

> > + */
> >  int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
> >  {
> >  	u8 mtrr;
> >  
> > -	/*
> > -	 * Do not use a huge page when the range is covered by non-WB type
> > -	 * of MTRRs.
> > -	 */
> >  	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
> >  	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
> >  		return 0;
> 
> Ditto for the rest.

Will do.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
