Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 970676B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 23:57:12 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so4691691wid.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 20:57:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cd7si1319192wib.4.2015.07.09.20.57.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jul 2015 20:57:10 -0700 (PDT)
Message-ID: <559F4293.1090801@suse.com>
Date: Fri, 10 Jul 2015 05:57:07 +0200
From: Juergen Gross <jgross@suse.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] x86: Fix pXd_flags() to handle _PAGE_PAT_LARGE
References: <1436461431-27305-1-git-send-email-toshi.kani@hp.com> <1436461431-27305-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1436461431-27305-2-git-send-email-toshi.kani@hp.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, konrad.wilk@oracle.com, elliott@hp.com

On 07/09/2015 07:03 PM, Toshi Kani wrote:
> The PAT bit gets relocated to bit 12 when PUD and PMD mappings are
> used.  This bit 12, however, is not covered by PTE_FLAGS_MASK, which
> is corrently used for masking the flag bits for all cases.
>
> Fix pud_flags() and pmd_flags() to cover the PAT bit, _PAGE_PAT_LARGE,
> when they are used to map a large page with _PAGE_PSE set.
>
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: Konrad Wilk <konrad.wilk@oracle.com>
> Cc: Robert Elliott <elliott@hp.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>   arch/x86/include/asm/pgtable_types.h |   16 +++++++++++++---
>   1 file changed, 13 insertions(+), 3 deletions(-)
>
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index 13f310b..caaf45c 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -212,9 +212,13 @@ enum page_cache_mode {
>   /* PTE_PFN_MASK extracts the PFN from a (pte|pmd|pud|pgd)val_t */
>   #define PTE_PFN_MASK		((pteval_t)PHYSICAL_PAGE_MASK)
>
> -/* PTE_FLAGS_MASK extracts the flags from a (pte|pmd|pud|pgd)val_t */
> +/* Extracts the flags from a (pte|pmd|pud|pgd)val_t of a 4KB page */
>   #define PTE_FLAGS_MASK		(~PTE_PFN_MASK)
>
> +/* Extracts the flags from a (pmd|pud)val_t of a (1GB|2MB) page */
> +#define PMD_FLAGS_MASK_LARGE	((~PTE_PFN_MASK) | _PAGE_PAT_LARGE)
> +#define PUD_FLAGS_MASK_LARGE	((~PTE_PFN_MASK) | _PAGE_PAT_LARGE)
> +
>   typedef struct pgprot { pgprotval_t pgprot; } pgprot_t;
>
>   typedef struct { pgdval_t pgd; } pgd_t;
> @@ -278,12 +282,18 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
>
>   static inline pudval_t pud_flags(pud_t pud)
>   {
> -	return native_pud_val(pud) & PTE_FLAGS_MASK;
> +	if (native_pud_val(pud) & _PAGE_PSE)
> +		return native_pud_val(pud) & PUD_FLAGS_MASK_LARGE;
> +	else
> +		return native_pud_val(pud) & PTE_FLAGS_MASK;
>   }
>
>   static inline pmdval_t pmd_flags(pmd_t pmd)
>   {
> -	return native_pmd_val(pmd) & PTE_FLAGS_MASK;
> +	if (native_pmd_val(pmd) & _PAGE_PSE)
> +		return native_pmd_val(pmd) & PMD_FLAGS_MASK_LARGE;
> +	else
> +		return native_pmd_val(pmd) & PTE_FLAGS_MASK;
>   }

Hmm, I think this covers only half of the problem. pud_pfn() and
pmd_pfn() will return wrong results for large pages with PAT bit
set as well.

I'd rather use something like:

static inline unsigned long pmd_pfn_mask(pmd_t pmd)
{
	if (pmd_large(pmd))
		return PMD_PAGE_MASK & PHYSICAL_PAGE_MASK;
	else
		return PTE_PFN_MASK;
}

static inline unsigned long pmd_flags_mask(pmd_t pmd)
{
	if (pmd_large(pmd))
		return ~(PMD_PAGE_MASK & PHYSICAL_PAGE_MASK);
	else
		return ~PTE_PFN_MASK;
}

static inline unsigned long pmd_pfn(pmd_t pmd)
{
         return (pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT;
}

static inline pmdval_t pmd_flags(pmd_t pmd)
{
	return native_pmd_val(pmd) & ~pmd_flags_mask(pmd);
}


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
