Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id BDCCD6B0254
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 02:48:59 -0500 (EST)
Received: by wmdw130 with SMTP id w130so142498352wmd.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:48:59 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id vm2si16964594wjc.213.2015.11.11.23.48.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 23:48:58 -0800 (PST)
Received: by wmec201 with SMTP id c201so19359741wme.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:48:58 -0800 (PST)
Date: Thu, 12 Nov 2015 08:48:54 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151112074854.GA5376@gmail.com>
References: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151110123429.GE19187@pd.tnic>
 <20151110135303.GA11246@node.shutemov.name>
 <20151110144648.GG19187@pd.tnic>
 <20151110150713.GA11956@node.shutemov.name>
 <20151110170447.GH19187@pd.tnic>
 <20151111095101.GA22512@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151111095101.GA22512@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com, Toshi Kani <toshi.kani@hpe.com>, Linus Torvalds <torvalds@linux-foundation.org>


* Borislav Petkov <bp@alien8.de> wrote:

> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -279,17 +279,14 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
>  static inline pudval_t pud_pfn_mask(pud_t pud)
>  {
>  	if (native_pud_val(pud) & _PAGE_PSE)
> -		return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
> +		return ~((1ULL << PUD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
>  	else
>  		return PTE_PFN_MASK;
>  }

>  static inline pmdval_t pmd_pfn_mask(pmd_t pmd)
>  {
>  	if (native_pmd_val(pmd) & _PAGE_PSE)
> -		return PMD_PAGE_MASK & PHYSICAL_PAGE_MASK;
> +		return ~((1ULL << PMD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
>  	else
>  		return PTE_PFN_MASK;
>  }

So instead of uglifying the code, why not fix the real bug: change the 
PMD_PAGE_MASK/PUD_PAGE_MASK definitions to be 64-bit everywhere?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
