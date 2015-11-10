Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2E94F6B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 07:34:43 -0500 (EST)
Received: by wmvv187 with SMTP id v187so5568020wmv.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 04:34:42 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id lt1si4177550wjb.41.2015.11.10.04.34.41
        for <linux-mm@kvack.org>;
        Tue, 10 Nov 2015 04:34:42 -0800 (PST)
Date: Tue, 10 Nov 2015 13:34:29 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151110123429.GE19187@pd.tnic>
References: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com, Toshi Kani <toshi.kani@hpe.com>

On Tue, Nov 10, 2015 at 01:18:10AM +0200, Kirill A. Shutemov wrote:
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index dd5b0aa9dd2f..c1e797266ce9 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -279,17 +279,14 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
>  static inline pudval_t pud_pfn_mask(pud_t pud)
>  {
>  	if (native_pud_val(pud) & _PAGE_PSE)
> -		return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
> +		return ~((1ULL << PUD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;

In file included from ./arch/x86/include/asm/boot.h:5:0,
                 from ./arch/x86/boot/boot.h:26,
                 from arch/x86/realmode/rm/wakemain.c:2:
./arch/x86/include/asm/pgtable_types.h: In function a??pud_pfn_maska??:
./arch/x86/include/asm/pgtable_types.h:282:10: warning: large integer implicitly truncated to unsigned type [-Woverflow]
   return ~((1ULL << PUD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
          ^
./arch/x86/include/asm/pgtable_types.h: In function a??pmd_pfn_maska??:
./arch/x86/include/asm/pgtable_types.h:300:10: warning: large integer implicitly truncated to unsigned type [-Woverflow]
   return ~((1ULL << PMD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
          ^
In file included from ./arch/x86/include/asm/boot.h:5:0,
                 from arch/x86/realmode/rm/../../boot/boot.h:26,
                 from arch/x86/realmode/rm/../../boot/video-mode.c:18,
                 from arch/x86/realmode/rm/video-mode.c:1:
./arch/x86/include/asm/pgtable_types.h: In function a??pud_pfn_maska??:
./arch/x86/include/asm/pgtable_types.h:282:10: warning: large integer implicitly truncated to unsigned type [-Woverflow]
   return ~((1ULL << PUD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
          ^
...

That's a 64-bit config.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
