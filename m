Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id D9D066B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 07:19:18 -0400 (EDT)
Received: by wizk4 with SMTP id k4so156169661wiz.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 04:19:18 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id do5si16311383wib.50.2015.05.05.04.19.15
        for <linux-mm@kvack.org>;
        Tue, 05 May 2015 04:19:16 -0700 (PDT)
Date: Tue, 5 May 2015 13:19:13 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 1/7] mm, x86: Document return values of mapping funcs
Message-ID: <20150505111913.GH3910@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1427234921-19737-2-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, Mar 24, 2015 at 04:08:35PM -0600, Toshi Kani wrote:
> Document the return values of KVA mapping functions,

KVA?

Please write it out.

> pud_set_huge(), pmd_set_huge, pud_clear_huge() and
> pmd_clear_huge().
> 
> Simplify the conditions to select HAVE_ARCH_HUGE_VMAP
> in the Kconfig, since X86_PAE depends on X86_32.
> 
> There is no functional change in this patch.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  arch/x86/Kconfig      |    2 +-
>  arch/x86/mm/pgtable.c |   36 ++++++++++++++++++++++++++++--------
>  2 files changed, 29 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index cb23206..2ea27da 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -99,7 +99,7 @@ config X86
>  	select IRQ_FORCED_THREADING
>  	select HAVE_BPF_JIT if X86_64
>  	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
> -	select HAVE_ARCH_HUGE_VMAP if X86_64 || (X86_32 && X86_PAE)
> +	select HAVE_ARCH_HUGE_VMAP if X86_64 || X86_PAE
>  	select ARCH_HAS_SG_CHAIN
>  	select CLKEVT_I8253
>  	select ARCH_HAVE_NMI_SAFE_CMPXCHG

This is an unrelated change, please carve it out in a separate patch.

> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index 0b97d2c..4891fa1 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -563,14 +563,19 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
>  }
>  
>  #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
> +/**
> + * pud_set_huge - setup kernel PUD mapping
> + *
> + * MTRR can override PAT memory types with 4KB granularity.  Therefore,
> + * it does not set up a huge page when the range is covered by a non-WB

"it" is what exactly?

> + * type of MTRR.  0xFF indicates that MTRR are disabled.

So this shows that this patch shouldn't be the first one in the series.

IMO you want to start with cleaning up mtrr_type_lookup(), add the
defines for its retval and *then* document its users. This way you won't
have to touch the same place twice, the net-size of your patchset will
go down and it will be easier for reviewiers.

> + *
> + * Return 1 on success, and 0 when no PUD was set.

"Returns 1 on success and 0 on failure."

> + */
>  int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
>  {
>  	u8 mtrr;
>  
> -	/*
> -	 * Do not use a huge page when the range is covered by non-WB type
> -	 * of MTRRs.
> -	 */
>  	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
>  	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
>  		return 0;

Ditto for the rest.

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
