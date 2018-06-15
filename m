Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D48586B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 11:27:36 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t19-v6so5485158plo.9
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 08:27:36 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t1-v6si8802797plb.90.2018.06.15.08.27.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 08:27:35 -0700 (PDT)
Date: Fri, 15 Jun 2018 18:27:32 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 07/17] x86/mm: Preserve KeyID on pte_modify() and
 pgprot_modify()
Message-ID: <20180615152731.3y6rre7g66rmncxr@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-8-kirill.shutemov@linux.intel.com>
 <8c31f6d2-6512-2726-763e-6dd1cbb0350a@intel.com>
 <20180615125720.r755xaegvfcqfr6x@black.fi.intel.com>
 <645a4ca8-ae77-dcdd-0cbc-0da467fc210d@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <645a4ca8-ae77-dcdd-0cbc-0da467fc210d@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 15, 2018 at 01:43:03PM +0000, Dave Hansen wrote:
> On 06/15/2018 05:57 AM, Kirill A. Shutemov wrote:
> >>> +#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
> >>>  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
> >>>  			 _PAGE_SOFT_DIRTY)
> >>>  #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
> >> This makes me a bit nervous.  We have some places (here) where we
> >> pretend that the KeyID is part of the paddr and then other places like
> >> pte_pfn() where it's not.
> > Other option is to include KeyID mask into _PAGE_CHG_MASK. But it means
> > _PAGE_CHG_MASK would need to reference *two* variables: physical_mask and
> > mktme_keyid_mask. I mentioned this in the commit message.
> 
> Why can't it be one variable with a different name that's populated by
> OR'ing physical_mask and mktme_keyid_mask together?

My point is that we don't need variables at all here.

Architecture defines range of bits in PTE used for PFN. MKTME reduces the
number of bits for PFN. PTE_PFN_MASK_MAX represents the original
architectural range, before MKTME stole these bits.

PTE_PFN_MASK_MAX is constant -- on x86-64 bits 51:12 -- regardless of
MKTME support.

> My issue here is that it this approach adds confusion around the logical
> separation between physical address and the bits immediately above the
> physical address in the PTE that are stolen for the keyID.

Well, yes, with MKTME the meaning of PFN/physical address is not that clear
cut. This comes from hardware design. I don't think we will be able to get
rid of ambiguity completely.

If you have suggestions on how to make it clearer, I would be glad to
rework it.

> Whatever you come up with will probably fine, as long as things that are
> called "PFN" or physical address don't also get used for keyID bits.

We are arguing about macros used exactly once. Is it really so confusing?

-- 
 Kirill A. Shutemov
