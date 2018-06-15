Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC966B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 08:57:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x17-v6so4623142pfm.18
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 05:57:33 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t184-v6si6513248pgt.540.2018.06.15.05.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 05:57:31 -0700 (PDT)
Date: Fri, 15 Jun 2018 15:57:20 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 07/17] x86/mm: Preserve KeyID on pte_modify() and
 pgprot_modify()
Message-ID: <20180615125720.r755xaegvfcqfr6x@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-8-kirill.shutemov@linux.intel.com>
 <8c31f6d2-6512-2726-763e-6dd1cbb0350a@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8c31f6d2-6512-2726-763e-6dd1cbb0350a@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 06:13:03PM +0000, Dave Hansen wrote:
> On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> > Encrypted VMA will have KeyID stored in vma->vm_page_prot. This way we
> 
> "An encrypted VMA..."
> 
> > don't need to do anything special to setup encrypted page table entries
> > and don't need to reserve space for KeyID in a VMA.
> > 
> > This patch changes _PAGE_CHG_MASK to include KeyID bits. Otherwise they
> > are going to be stripped from vm_page_prot on the first pgprot_modify().
> > 
> > Define PTE_PFN_MASK_MAX similar to PTE_PFN_MASK but based on
> > __PHYSICAL_MASK_SHIFT. This way we include whole range of bits
> > architecturally available for PFN without referencing physical_mask and
> > mktme_keyid_mask variables.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/include/asm/pgtable_types.h | 7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> > index 1e5a40673953..e8ebe760b88d 100644
> > --- a/arch/x86/include/asm/pgtable_types.h
> > +++ b/arch/x86/include/asm/pgtable_types.h
> > @@ -121,8 +121,13 @@
> >   * protection key is treated like _PAGE_RW, for
> >   * instance, and is *not* included in this mask since
> >   * pte_modify() does modify it.
> > + *
> > + * It includes full range of PFN bits regardless if they were claimed for KeyID
> > + * or not: we want to preserve KeyID on pte_modify() and pgprot_modify().
> >   */
> > -#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
> > +#define PTE_PFN_MASK_MAX \
> > +	(((signed long)PAGE_MASK) & ((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
> 
> "signed long" is really unusual to see.  Was that intentional?

Yes. That's trick with sign-extension, borrowed from PHYSICAL_PAGE_MASK
definition. It helps on 32-bit with PAE properly expand the PAGE_MASK to
64-bit.

I'll add comment.

> > +#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
> >  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
> >  			 _PAGE_SOFT_DIRTY)
> >  #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
> 
> This makes me a bit nervous.  We have some places (here) where we
> pretend that the KeyID is part of the paddr and then other places like
> pte_pfn() where it's not.

Other option is to include KeyID mask into _PAGE_CHG_MASK. But it means
_PAGE_CHG_MASK would need to reference *two* variables: physical_mask and
mktme_keyid_mask. I mentioned this in the commit message.

This is more efficient way to achieve the same compile-time without
referencing any variables.

> Seems like something that will come back to bite us.

Any suggestions?

-- 
 Kirill A. Shutemov
