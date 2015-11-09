Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 03D126B0254
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 18:47:21 -0500 (EST)
Received: by iody8 with SMTP id y8so203058192iod.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 15:47:20 -0800 (PST)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id y37si1306736ioi.7.2015.11.09.15.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 15:47:20 -0800 (PST)
Message-ID: <1447112591.21443.35.camel@hpe.com>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 09 Nov 2015 16:43:11 -0700
In-Reply-To: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
References: 
	<1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org
Cc: bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com

On Tue, 2015-11-10 at 01:18 +0200, Kirill A. Shutemov wrote:
> Recent PAT patchset has caused issue on 32-bit PAE machines:
 :
> The problem is in pmd_pfn_mask() and pmd_flags_mask(). These helpers use
> PMD_PAGE_MASK to calculate resulting mask. PMD_PAGE_MASK is 'unsigned
> long', not 'unsigned long long' as physaddr_t. As result upper bits of
> resulting mask is truncated.
> 
> The patch reworks code to use PMD_SHIFT as base of mask calculation
> instead of PMD_PAGE_MASK.
> 
> pud_pfn_mask() and pud_flags_mask() aren't problematic since we don't
> have PUD page table level on 32-bit systems, but they reworked too to be
> consistent with PMD counterpart.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-and-Tested-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Fixes: f70abb0fc3da ("x86/asm: Fix pud/pmd interfaces to handle large PAT
> bit")
> Cc: Toshi Kani <toshi.kani@hpe.com>
> ---
>  arch/x86/include/asm/pgtable_types.h | 14 ++++----------
>  1 file changed, 4 insertions(+), 10 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgtable_types.h
> b/arch/x86/include/asm/pgtable_types.h
> index dd5b0aa9dd2f..c1e797266ce9 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -279,17 +279,14 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
>  static inline pudval_t pud_pfn_mask(pud_t pud)
>  {
>  	if (native_pud_val(pud) & _PAGE_PSE)
> -		return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
> +		return ~((1ULL << PUD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;

Thanks for the fix!  Should we fix the PMD/PUD MASK/SIZE macros, so that we do
not hit the same issue again when they are used? 

--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -17,10 +17,10 @@
    (ie, 32-bit PAE). */
 #define PHYSICAL_PAGE_MASK     (((signed long)PAGE_MASK) & __PHYSICAL_MASK)

-#define PMD_PAGE_SIZE          (_AC(1, UL) << PMD_SHIFT)
+#define PMD_PAGE_SIZE          (_AC(1, ULL) << PMD_SHIFT)
 #define PMD_PAGE_MASK          (~(PMD_PAGE_SIZE-1))

-#define PUD_PAGE_SIZE          (_AC(1, UL) << PUD_SHIFT)
+#define PUD_PAGE_SIZE          (_AC(1, ULL) << PUD_SHIFT)
 #define PUD_PAGE_MASK          (~(PUD_PAGE_SIZE-1))

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
