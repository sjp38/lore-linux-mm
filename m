Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 128D66B0256
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 18:57:31 -0500 (EST)
Received: by wmnn186 with SMTP id n186so132188408wmn.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 15:57:30 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id gb8si693919wjb.121.2015.11.09.15.57.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 15:57:30 -0800 (PST)
Received: by wmnn186 with SMTP id n186so132188074wmn.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 15:57:29 -0800 (PST)
Date: Tue, 10 Nov 2015 01:57:28 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151109235728.GA7813@node.shutemov.name>
References: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1447112591.21443.35.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447112591.21443.35.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com

On Mon, Nov 09, 2015 at 04:43:11PM -0700, Toshi Kani wrote:
> On Tue, 2015-11-10 at 01:18 +0200, Kirill A. Shutemov wrote:
> > Recent PAT patchset has caused issue on 32-bit PAE machines:
>  :
> > The problem is in pmd_pfn_mask() and pmd_flags_mask(). These helpers use
> > PMD_PAGE_MASK to calculate resulting mask. PMD_PAGE_MASK is 'unsigned
> > long', not 'unsigned long long' as physaddr_t. As result upper bits of
> > resulting mask is truncated.
> > 
> > The patch reworks code to use PMD_SHIFT as base of mask calculation
> > instead of PMD_PAGE_MASK.
> > 
> > pud_pfn_mask() and pud_flags_mask() aren't problematic since we don't
> > have PUD page table level on 32-bit systems, but they reworked too to be
> > consistent with PMD counterpart.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reported-and-Tested-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> > Fixes: f70abb0fc3da ("x86/asm: Fix pud/pmd interfaces to handle large PAT
> > bit")
> > Cc: Toshi Kani <toshi.kani@hpe.com>
> > ---
> >  arch/x86/include/asm/pgtable_types.h | 14 ++++----------
> >  1 file changed, 4 insertions(+), 10 deletions(-)
> > 
> > diff --git a/arch/x86/include/asm/pgtable_types.h
> > b/arch/x86/include/asm/pgtable_types.h
> > index dd5b0aa9dd2f..c1e797266ce9 100644
> > --- a/arch/x86/include/asm/pgtable_types.h
> > +++ b/arch/x86/include/asm/pgtable_types.h
> > @@ -279,17 +279,14 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
> >  static inline pudval_t pud_pfn_mask(pud_t pud)
> >  {
> >  	if (native_pud_val(pud) & _PAGE_PSE)
> > -		return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
> > +		return ~((1ULL << PUD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
> 
> Thanks for the fix!  Should we fix the PMD/PUD MASK/SIZE macros, so that we do
> not hit the same issue again when they are used? 

I don't this so. PAGE_SIZE is not 'unsigned long long'. And all *PAGE_MASK
are usually applied to virtual addresses which are 'unsigned long'.
I think it's safer to leave them as they are.

> 
> --- a/arch/x86/include/asm/page_types.h
> +++ b/arch/x86/include/asm/page_types.h
> @@ -17,10 +17,10 @@
>     (ie, 32-bit PAE). */
>  #define PHYSICAL_PAGE_MASK     (((signed long)PAGE_MASK) & __PHYSICAL_MASK)
> 
> -#define PMD_PAGE_SIZE          (_AC(1, UL) << PMD_SHIFT)
> +#define PMD_PAGE_SIZE          (_AC(1, ULL) << PMD_SHIFT)
>  #define PMD_PAGE_MASK          (~(PMD_PAGE_SIZE-1))
> 
> -#define PUD_PAGE_SIZE          (_AC(1, UL) << PUD_SHIFT)
> +#define PUD_PAGE_SIZE          (_AC(1, ULL) << PUD_SHIFT)
>  #define PUD_PAGE_MASK          (~(PUD_PAGE_SIZE-1))
> 
> Thanks,
> -Toshi
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
