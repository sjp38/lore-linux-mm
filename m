Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id E2B706B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 04:00:21 -0500 (EST)
Received: by wmec201 with SMTP id c201so21970854wme.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 01:00:21 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id m131si36703849wmb.1.2015.11.12.01.00.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 01:00:20 -0800 (PST)
Received: by wmvv187 with SMTP id v187so21927056wmv.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 01:00:20 -0800 (PST)
Date: Thu, 12 Nov 2015 11:00:19 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151112090018.GA22481@node.shutemov.name>
References: <20151110135303.GA11246@node.shutemov.name>
 <20151110144648.GG19187@pd.tnic>
 <20151110150713.GA11956@node.shutemov.name>
 <20151110170447.GH19187@pd.tnic>
 <20151111095101.GA22512@pd.tnic>
 <20151112074854.GA5376@gmail.com>
 <20151112075758.GA20702@node.shutemov.name>
 <20151112080059.GA6835@gmail.com>
 <20151112084616.EABFE19B@black.fi.intel.com>
 <20151112085418.GA18963@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151112085418.GA18963@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Borislav Petkov <bp@alien8.de>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com, Toshi Kani <toshi.kani@hpe.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Nov 12, 2015 at 09:54:18AM +0100, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> 
> > diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
> > index c5b7fb2774d0..cc071c6f7d4d 100644
> > --- a/arch/x86/include/asm/page_types.h
> > +++ b/arch/x86/include/asm/page_types.h
> > @@ -9,19 +9,21 @@
> >  #define PAGE_SIZE	(_AC(1,UL) << PAGE_SHIFT)
> >  #define PAGE_MASK	(~(PAGE_SIZE-1))
> >  
> > +#define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
> > +#define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
> > +
> > +#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
> > +#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
> > +
> >  #define __PHYSICAL_MASK		((phys_addr_t)((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
> >  #define __VIRTUAL_MASK		((1UL << __VIRTUAL_MASK_SHIFT) - 1)
> >  
> > -/* Cast PAGE_MASK to a signed type so that it is sign-extended if
> > +/* Cast *PAGE_MASK to a signed type so that it is sign-extended if
> >     virtual addresses are 32-bits but physical addresses are larger
> >     (ie, 32-bit PAE). */
> >  #define PHYSICAL_PAGE_MASK	(((signed long)PAGE_MASK) & __PHYSICAL_MASK)
> > -
> > -#define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
> > -#define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
> > -
> > -#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
> > -#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
> > +#define PHYSICAL_PMD_PAGE_MASK	(((signed long)PMD_PAGE_MASK) & __PHYSICAL_MASK)
> > +#define PHYSICAL_PUD_PAGE_MASK	(((signed long)PUD_PAGE_MASK) & __PHYSICAL_MASK)
> 
> that's a really odd way of writing it, 'long' is signed by default ...

See the comment above (it was there before the patch). 'signed' can be
considered as documentation -- we want sign-extension here.

> There seems to be 150+ such cases in the kernel source though - weird.
> 
> More importantly, how does this improve things on 32-bit PAE kernels? If I follow 
> the values correctly then PMD_PAGE_MASK is 'UL' i.e. 32-bit:
> 
> > +#define PMD_PAGE_SIZE                (_AC(1, UL) << PMD_SHIFT)
> > +#define PMD_PAGE_MASK                (~(PMD_PAGE_SIZE-1))
> 
> thus PHYSICAL_PMD_PAGE_MASK is 32-bit too:
> 
> > +#define PHYSICAL_PMD_PAGE_MASK       (((signed long)PMD_PAGE_MASK) & __PHYSICAL_MASK)
> 
> so how is the bug fixed?

Again, see the comment.
I've checked that it generates correct value (using kernel/bounds.c).

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
