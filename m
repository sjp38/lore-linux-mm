Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 200C26B0005
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 08:43:02 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w1-v6so7248905plq.8
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:43:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y2-v6sor513624pgv.38.2018.07.20.05.43.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 05:43:01 -0700 (PDT)
Date: Fri, 20 Jul 2018 15:42:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 09/19] x86/mm: Preserve KeyID on pte_modify() and
 pgprot_modify()
Message-ID: <20180720124256.nvtw4mw2lcjkfrte@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-10-kirill.shutemov@linux.intel.com>
 <202c809d-8720-8dbb-51f5-1018e947a62a@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <202c809d-8720-8dbb-51f5-1018e947a62a@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 18, 2018 at 04:30:35PM -0700, Dave Hansen wrote:
> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> > An encrypted VMA will have KeyID stored in vma->vm_page_prot. This way
> > we don't need to do anything special to setup encrypted page table
> > entries
> 
> We don't do anything special for protection keys, either.  They just
> work too.
> 
> > diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> > index 99fff853c944..3731f7e08757 100644
> > --- a/arch/x86/include/asm/pgtable_types.h
> > +++ b/arch/x86/include/asm/pgtable_types.h
> > @@ -120,8 +120,21 @@
> >   * protection key is treated like _PAGE_RW, for
> >   * instance, and is *not* included in this mask since
> >   * pte_modify() does modify it.
> > + *
> > + * They include the physical address and the memory encryption keyID.
> > + * The paddr and the keyID never occupy the same bits at the same time.
> > + * But, a given bit might be used for the keyID on one system and used for
> > + * the physical address on another. As an optimization, we manage them in
> > + * one unit here since their combination always occupies the same hardware
> > + * bits. PTE_PFN_MASK_MAX stores combined mask.
> > + *
> > + * Cast PAGE_MASK to a signed type so that it is sign-extended if
> > + * virtual addresses are 32-bits but physical addresses are larger
> > + * (ie, 32-bit PAE).
> >   */
> 
> Could you please make the comment block consistent?  You're a lot wider
> than the comment above.

Okay.

> > -#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
> > +#define PTE_PFN_MASK_MAX \
> > +	(((signed long)PAGE_MASK) & ((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
> > +#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
> >  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
> >  			 _PAGE_SOFT_DIRTY)
> 
> Man, I'm not a fan of this.  This saves us from consuming 6 VM_HIGH bits
> (which we are not short on).  But, at the cost of complexity.

15, not 6. We have up-to 15 KeyID bits architecturally.

We can just have a separate field in vm_area_struct if we must.
But vm_page_prot work fine so far. I don't see a big reasone to change
them.

> Protection keys eat up PTE space and have an interface called
> pkey_mprotect().  MKTME KeyIDs take up PTE space and will probably have
> an interface called something_mprotect().  Yet, the implementations are
> going to be _very_ different with pkeys being excluded from
> _PAGE_CHG_MASK and KeyIDs being included.
> 
> I think you're saved here because we don't _actually_ do pte_modify() on
> an existing PTE: we blow the old one away upon encrypted_mprotect() and
> replace the PTE with a new one.
> 
> But, this is incompatible with any case where we want to change the
> KeyID and keep the old PTE target.  With AES-XTS, I guess this is a safe
> assumption, but it's worrying.
> 
> Are there scenarios where we want to keep PTE contents, but change the
> KeyID?

I don't see such scenario.

If for some reason we would need to map the same memory with different
KeyID it can be done from scratch. Without modifing existing mapping.

-- 
 Kirill A. Shutemov
