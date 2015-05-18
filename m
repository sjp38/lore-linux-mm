Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 20A0B6B0096
	for <linux-mm@kvack.org>; Mon, 18 May 2015 13:42:02 -0400 (EDT)
Received: by obcus9 with SMTP id us9so134324660obc.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 10:42:01 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id d22si376839oib.31.2015.05.18.10.42.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 10:42:01 -0700 (PDT)
Message-ID: <1431969759.19889.5.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 18 May 2015 11:22:39 -0600
In-Reply-To: <20150518133348.GA23618@pd.tnic>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
	 <1431714237-880-7-git-send-email-toshi.kani@hp.com>
	 <20150518133348.GA23618@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com

On Mon, 2015-05-18 at 15:33 +0200, Borislav Petkov wrote:
> On Fri, May 15, 2015 at 12:23:57PM -0600, Toshi Kani wrote:
> > This patch adds an additional argument, 'uniform', to
> > mtrr_type_lookup(), which returns 1 when a given range is
> > covered uniformly by MTRRs, i.e. the range is fully covered
> > by a single MTRR entry or the default type.
> > 
> > pud_set_huge() and pmd_set_huge() are changed to check the
> > new 'uniform' flag to see if it is safe to create a huge page
> > mapping to the range.  This allows them to create a huge page
> > mapping to a range covered by a single MTRR entry of any
> > memory type.  It also detects a non-optimal request properly.
> > They continue to check with the WB type since the WB type has
> > no effect even if a request spans multiple MTRR entries.
> > 
> > pmd_set_huge() logs a warning message to a non-optimal request
> > so that driver writers will be aware of such a case.  Drivers
> > should make a mapping request aligned to a single MTRR entry
> > when the range is covered by MTRRs.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > ---
> >  arch/x86/include/asm/mtrr.h        |    4 ++--
> >  arch/x86/kernel/cpu/mtrr/generic.c |   37 ++++++++++++++++++++++++++----------
> >  arch/x86/mm/pat.c                  |    4 ++--
> >  arch/x86/mm/pgtable.c              |   33 ++++++++++++++++++++------------
> >  4 files changed, 52 insertions(+), 26 deletions(-)
 :
> 
> All applied, 

Great!

> I reformatted the comments in this last one a bit and made
> the warning message hopefully a bit more descriptive:

I have a few comments below.

> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index c30f9819786b..f1894daa79ee 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -566,19 +566,24 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
>  /**
>   * pud_set_huge - setup kernel PUD mapping
>   *
> - * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
> - * this function does not set up a huge page when the range is covered
> - * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
> - * disabled.
> + * MTRRs can override PAT memory types with 4KiB granularity. Therefore,
> + * this function sets up a huge page only if all of the following
> + * conditions are met:

It should be "if any of the following condition is met".  Or, does NOT
setup if all of ...

> + *
> + *  - MTRRs are disabled.
> + *  - The range is mapped uniformly by an MTRR, i.e. the range is
> + *    fully covered by a single MTRR entry or the default type.
> + *  - The MTRR memory type is WB.
>   *
>   * Returns 1 on success and 0 on failure.
>   */
>  int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
>  {
> -	u8 mtrr;
> +	u8 mtrr, uniform;
>  
> -	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
> -	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
> +	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE, &uniform);
> +	if ((mtrr != MTRR_TYPE_INVALID) && (!uniform) &&
> +	    (mtrr != MTRR_TYPE_WRBACK))
>  		return 0;
>  
>  	prot = pgprot_4k_2_large(prot);
> @@ -593,20 +598,28 @@ int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
>  /**
>   * pmd_set_huge - setup kernel PMD mapping
>   *
> - * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
> - * this function does not set up a huge page when the range is covered
> - * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
> - * disabled.
> + * MTRRs can override PAT memory types with 4KiB granularity. Therefore,
> + * this function sets up a huge page only if all of the following
> + * conditions are met:

Ditto.

> + *
> + *  - MTRR is disabled.
> + *  - The range is mapped uniformly by an MTRR, i.e. the range is
> + *    fully covered by a single MTRR entry or the default type.
> + *  - The MTRR memory type is WB.
>   *
>   * Returns 1 on success and 0 on failure.
>   */
>  int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
>  {
> -	u8 mtrr;
> +	u8 mtrr, uniform;
>  
> -	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
> -	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
> +	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE, &uniform);
> +	if ((mtrr != MTRR_TYPE_INVALID) && (!uniform) &&
> +	    (mtrr != MTRR_TYPE_WRBACK)) {
> +		pr_warn_once("%s: Cannot satisfy [mem %#010llx-%#010llx] with a huge-page mapping due to MTRR override.\n",
> +			     __func__, addr, addr + PMD_SIZE);

This new message looks good.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
