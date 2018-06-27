Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 528036B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:57:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v10-v6so1619036pfm.11
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 14:57:01 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e1-v6si4863268pfk.198.2018.06.27.14.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 14:57:00 -0700 (PDT)
Date: Thu, 28 Jun 2018 00:56:59 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv4 17/18] x86/mm: Handle encrypted memory in
 page_to_virt() and __pa()
Message-ID: <20180627215658.ol5zq3o5746gizpu@black.fi.intel.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-18-kirill.shutemov@linux.intel.com>
 <1609f2b4-4638-8b9d-4dc7-fcb3303739cd@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1609f2b4-4638-8b9d-4dc7-fcb3303739cd@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 26, 2018 at 04:38:23PM +0000, Dave Hansen wrote:
> > diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
> > index ba83fba4f9b3..dbfbd955da98 100644
> > --- a/arch/x86/include/asm/mktme.h
> > +++ b/arch/x86/include/asm/mktme.h
> > @@ -29,6 +29,9 @@ void arch_free_page(struct page *page, int order);
> >  
> >  int sync_direct_mapping(void);
> >  
> > +#define page_to_virt(x) \
> > +	(__va(PFN_PHYS(page_to_pfn(x))) + page_keyid(x) * direct_mapping_size)
> 
> Please put this in a generic header so that this hunk represents the
> *default* x86 implementation that is used universally on x86.

As I said, I disagree with you on the style preference.

If a maintainer prefers it to be done in your way, I'll move the macros.

> Then, please do
> 
> #ifndef CONFIG_MKTME_WHATEVER
> #define page_keyid(x) (0)
> #endif

Default page_keyid() implementation returns 0.

> >  #else
> >  #define mktme_keyid_mask	((phys_addr_t)0)
> >  #define mktme_nr_keyids		0
> > diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
> > index 53c32af895ab..ffad496aadad 100644
> > --- a/arch/x86/include/asm/page_64.h
> > +++ b/arch/x86/include/asm/page_64.h
> > @@ -23,7 +23,7 @@ static inline unsigned long __phys_addr_nodebug(unsigned long x)
> >  	/* use the carry flag to determine if x was < __START_KERNEL_map */
> >  	x = y + ((x > y) ? phys_base : (__START_KERNEL_map - PAGE_OFFSET));
> >  
> > -	return x;
> > +	return x % direct_mapping_size;
> 
> There are almost *surely* performance implications from this that affect
> anyone with this compile option turned on.  There's now a 64-bit integer
> division operation which is used in places like kfree().

Fair point. Apparently, modern CPU is good enough to hide the overhead.
I'll look into how to avoid division.

After quick look the only way to get it cheap (near free on my CPU) is to
have power-of-2 direct_mapping_size and mask address before returning it.

If direct_mapping_size is not power-of-2, the best variant I've come up
with so far costs a branch for non-encrypted memory.

For encrypted it is branch, 32-bit division and some bit shifting and
masking.

I'll look into this more.

-- 
 Kirill A. Shutemov
