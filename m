Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5DDA46B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 08:29:17 -0500 (EST)
Received: by wmec201 with SMTP id c201so91393444wme.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 05:29:17 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id 202si19519423wms.8.2015.11.12.05.29.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 05:29:16 -0800 (PST)
Received: by wmec201 with SMTP id c201so32944100wme.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 05:29:15 -0800 (PST)
Date: Thu, 12 Nov 2015 14:29:11 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151112132911.GA2964@gmail.com>
References: <20151110144648.GG19187@pd.tnic>
 <20151110150713.GA11956@node.shutemov.name>
 <20151110170447.GH19187@pd.tnic>
 <20151111095101.GA22512@pd.tnic>
 <20151112074854.GA5376@gmail.com>
 <20151112075758.GA20702@node.shutemov.name>
 <20151112080059.GA6835@gmail.com>
 <20151112084616.EABFE19B@black.fi.intel.com>
 <20151112085418.GA18963@gmail.com>
 <20151112090018.GA22481@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151112090018.GA22481@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Borislav Petkov <bp@alien8.de>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com, Toshi Kani <toshi.kani@hpe.com>, Linus Torvalds <torvalds@linux-foundation.org>


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Thu, Nov 12, 2015 at 09:54:18AM +0100, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
> > > index c5b7fb2774d0..cc071c6f7d4d 100644
> > > --- a/arch/x86/include/asm/page_types.h
> > > +++ b/arch/x86/include/asm/page_types.h
> > > @@ -9,19 +9,21 @@
> > >  #define PAGE_SIZE	(_AC(1,UL) << PAGE_SHIFT)
> > >  #define PAGE_MASK	(~(PAGE_SIZE-1))
> > >  
> > > +#define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
> > > +#define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
> > > +
> > > +#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
> > > +#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
> > > +
> > >  #define __PHYSICAL_MASK		((phys_addr_t)((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
> > >  #define __VIRTUAL_MASK		((1UL << __VIRTUAL_MASK_SHIFT) - 1)
> > >  
> > > -/* Cast PAGE_MASK to a signed type so that it is sign-extended if
> > > +/* Cast *PAGE_MASK to a signed type so that it is sign-extended if
> > >     virtual addresses are 32-bits but physical addresses are larger
> > >     (ie, 32-bit PAE). */
> > >  #define PHYSICAL_PAGE_MASK	(((signed long)PAGE_MASK) & __PHYSICAL_MASK)
> > > -
> > > -#define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
> > > -#define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
> > > -
> > > -#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
> > > -#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
> > > +#define PHYSICAL_PMD_PAGE_MASK	(((signed long)PMD_PAGE_MASK) & __PHYSICAL_MASK)
> > > +#define PHYSICAL_PUD_PAGE_MASK	(((signed long)PUD_PAGE_MASK) & __PHYSICAL_MASK)
> > 
> > that's a really odd way of writing it, 'long' is signed by default ...
> 
> See the comment above (it was there before the patch). 'signed' can be
> considered as documentation -- we want sign-extension here.
> 
> > There seems to be 150+ such cases in the kernel source though - weird.
> > 
> > More importantly, how does this improve things on 32-bit PAE kernels? If I follow 
> > the values correctly then PMD_PAGE_MASK is 'UL' i.e. 32-bit:
> > 
> > > +#define PMD_PAGE_SIZE                (_AC(1, UL) << PMD_SHIFT)
> > > +#define PMD_PAGE_MASK                (~(PMD_PAGE_SIZE-1))
> > 
> > thus PHYSICAL_PMD_PAGE_MASK is 32-bit too:
> > 
> > > +#define PHYSICAL_PMD_PAGE_MASK       (((signed long)PMD_PAGE_MASK) & __PHYSICAL_MASK)
> > 
> > so how is the bug fixed?
> 
> Again, see the comment.

Ah, indeed! That should in fact work even better than using u64 or so, as it does 
the obvious thing for masks.

The concept will only break down once TBPAGES (well, 512 GB pages) are introduced.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
