Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B005A6B0254
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:53:07 -0500 (EST)
Received: by wmec201 with SMTP id c201so134629108wme.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:53:07 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id u8si4550208wjx.172.2015.11.10.05.53.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 05:53:06 -0800 (PST)
Received: by wmec201 with SMTP id c201so1678981wme.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:53:06 -0800 (PST)
Date: Tue, 10 Nov 2015 15:53:03 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151110135303.GA11246@node.shutemov.name>
References: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151110123429.GE19187@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20151110123429.GE19187@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com, Toshi Kani <toshi.kani@hpe.com>

On Tue, Nov 10, 2015 at 01:34:29PM +0100, Borislav Petkov wrote:
> On Tue, Nov 10, 2015 at 01:18:10AM +0200, Kirill A. Shutemov wrote:
> > diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
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
> In file included from ./arch/x86/include/asm/boot.h:5:0,
>                  from ./arch/x86/boot/boot.h:26,
>                  from arch/x86/realmode/rm/wakemain.c:2:
> ./arch/x86/include/asm/pgtable_types.h: In function a??pud_pfn_maska??:
> ./arch/x86/include/asm/pgtable_types.h:282:10: warning: large integer implicitly truncated to unsigned type [-Woverflow]
>    return ~((1ULL << PUD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
>           ^
> ./arch/x86/include/asm/pgtable_types.h: In function a??pmd_pfn_maska??:
> ./arch/x86/include/asm/pgtable_types.h:300:10: warning: large integer implicitly truncated to unsigned type [-Woverflow]
>    return ~((1ULL << PMD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
>           ^
> In file included from ./arch/x86/include/asm/boot.h:5:0,
>                  from arch/x86/realmode/rm/../../boot/boot.h:26,
>                  from arch/x86/realmode/rm/../../boot/video-mode.c:18,
>                  from arch/x86/realmode/rm/video-mode.c:1:
> ./arch/x86/include/asm/pgtable_types.h: In function a??pud_pfn_maska??:
> ./arch/x86/include/asm/pgtable_types.h:282:10: warning: large integer implicitly truncated to unsigned type [-Woverflow]
>    return ~((1ULL << PUD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
>           ^
> ...
> 
> That's a 64-bit config.

Oh.. pmdval_t/pudval_t is 'unsinged long' on 64 bit. But realmode code
uses -m16 which makes 'unsigned long' 32-bit therefore truncation warning.

These helpers not really used in realmode code. I see few ways out:

 - convert helpers to macros to avoid their translation;

 - wrap the code into not-for-realmode ifdef. (Do we have any?);

 - convert pudval_t/pmdval_t to u64 for 64-bit. I'm not sure what side
   effects would it have.

Any opinions?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
