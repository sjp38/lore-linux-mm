Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC1A6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 03:46:54 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so58712255pac.3
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 00:46:54 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yi1si18576717pbb.246.2015.11.12.00.46.53
        for <linux-mm@kvack.org>;
        Thu, 12 Nov 2015 00:46:53 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20151112080059.GA6835@gmail.com>
References: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151110123429.GE19187@pd.tnic>
 <20151110135303.GA11246@node.shutemov.name>
 <20151110144648.GG19187@pd.tnic>
 <20151110150713.GA11956@node.shutemov.name>
 <20151110170447.GH19187@pd.tnic>
 <20151111095101.GA22512@pd.tnic>
 <20151112074854.GA5376@gmail.com>
 <20151112075758.GA20702@node.shutemov.name>
 <20151112080059.GA6835@gmail.com>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Content-Transfer-Encoding: 7bit
Message-Id: <20151112084616.EABFE19B@black.fi.intel.com>
Date: Thu, 12 Nov 2015 10:46:16 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com, Toshi Kani <toshi.kani@hpe.com>, Linus Torvalds <torvalds@linux-foundation.org>

Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> 
> > On Thu, Nov 12, 2015 at 08:48:54AM +0100, Ingo Molnar wrote:
> > > 
> > > * Borislav Petkov <bp@alien8.de> wrote:
> > > 
> > > > --- a/arch/x86/include/asm/pgtable_types.h
> > > > +++ b/arch/x86/include/asm/pgtable_types.h
> > > > @@ -279,17 +279,14 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
> > > >  static inline pudval_t pud_pfn_mask(pud_t pud)
> > > >  {
> > > >  	if (native_pud_val(pud) & _PAGE_PSE)
> > > > -		return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
> > > > +		return ~((1ULL << PUD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
> > > >  	else
> > > >  		return PTE_PFN_MASK;
> > > >  }
> > > 
> > > >  static inline pmdval_t pmd_pfn_mask(pmd_t pmd)
> > > >  {
> > > >  	if (native_pmd_val(pmd) & _PAGE_PSE)
> > > > -		return PMD_PAGE_MASK & PHYSICAL_PAGE_MASK;
> > > > +		return ~((1ULL << PMD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
> > > >  	else
> > > >  		return PTE_PFN_MASK;
> > > >  }
> > > 
> > > So instead of uglifying the code, why not fix the real bug: change the 
> > > PMD_PAGE_MASK/PUD_PAGE_MASK definitions to be 64-bit everywhere?
> > 
> > *PAGE_MASK are usually applied to virtual addresses. I don't think it
> > should anything but 'unsigned long'. This is odd use case really.
> 
> So we already have PHYSICAL_PAGE_MASK, why not introduce PHYSICAL_PMD_MASK et al, 
> instead of uglifying the code?

Okay, makes sense. Check out the patch below.

> But, what problems do you expect with having a wider mask than its primary usage? 
> If it's used for 32-bit values it will be truncated down safely. (But I have not 
> tested it, so I might be missing some complication.)

Yeah, I basically worry about non realized side effect.

And these masks are defined via {PMD,PUD}_PAGE_SIZE. Should we change them
to 'unsigned long long' too or leave alone? What about PAGE_SIZE and
PAGE_MASK? Need to be converted too?
