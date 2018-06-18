Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 547A66B0007
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 09:12:52 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q19-v6so10072166plr.22
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 06:12:52 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id h68-v6si12431705pgc.429.2018.06.18.06.12.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 06:12:50 -0700 (PDT)
Date: Mon, 18 Jun 2018 16:12:47 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 14/17] x86/mm: Introduce direct_mapping_size
Message-ID: <20180618131247.myt6vjiav3nwww5p@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-15-kirill.shutemov@linux.intel.com>
 <4ece14a4-27bd-e10a-4c2c-822c3e629dcd@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ece14a4-27bd-e10a-4c2c-822c3e629dcd@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 06:37:07PM +0000, Dave Hansen wrote:
> On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> > Kernel need to have a way to access encrypted memory. We are going to
> "The kernel needs"...
> 
> > use per-KeyID direct mapping to facilitate the access with minimal
> > overhead.
> 
> What are the security implications of this approach?

I'll add this to the message:

Per-KeyID mappings require a lot more virtual address space. On 4-level
machine with 64 KeyIDs we max out 46-bit virtual address space dedicated
for direct mapping with 1TiB of RAM. Given that we round up any
calculation on direct mapping size to 1TiB, we effectively claim all
46-bit address space for direct mapping on such machine regardless of
RAM size.

Increased usage of virtual address space has implications for KASLR:
we have less space for randomization. With 64 TiB claimed for direct
mapping with 4-level we left with 27 TiB of entropy to place
page_offset_base, vmalloc_base and vmemmap_base.

5-level paging provides much wider virtual address space and KASLR
doesn't suffer significantly from per-KeyID direct mappings.

It's preferred to run MKTME with 5-level paging.

> > Direct mapping for each KeyID will be put next to each other in the
> 
> That needs to be "a direct mapping" or "the direct mapping".  It's
> missing an article to start the sentence.

Okay.

> > virtual address space. We need to have a way to find boundaries of
> > direct mapping for particular KeyID.
> > 
> > The new variable direct_mapping_size specifies the size of direct
> > mapping. With the value, it's trivial to find direct mapping for
> > KeyID-N: PAGE_OFFSET + N * direct_mapping_size.
> 
> I think this deserves an update to Documentation/x86/x86_64/mm.txt, no?

Right, I'll update it.

> > Size of direct mapping is calculated during KASLR setup. If KALSR is
> > disable it happens during MKTME initialization.
> 
> "disabled"
> 
> > diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
> > index 4408cd9a3bef..3d8ef8cb97e1 100644
> > --- a/arch/x86/mm/kaslr.c
> > +++ b/arch/x86/mm/kaslr.c
> > @@ -69,6 +69,15 @@ static inline bool kaslr_memory_enabled(void)
> >  	return kaslr_enabled() && !IS_ENABLED(CONFIG_KASAN);
> >  }
> >  
> > +#ifndef CONFIG_X86_INTEL_MKTME
> > +static void __init setup_direct_mapping_size(void)
> > +{
> > +	direct_mapping_size = max_pfn << PAGE_SHIFT;
> > +	direct_mapping_size = round_up(direct_mapping_size, 1UL << TB_SHIFT);
> > +	direct_mapping_size += (1UL << TB_SHIFT) * CONFIG_MEMORY_PHYSICAL_PADDING;
> > +}
> > +#endif
> 
> Comments, please.

Okay.

> >  /* Initialize base and padding for each memory region randomized with KASLR */
> >  void __init kernel_randomize_memory(void)
> >  {
> > @@ -93,7 +102,11 @@ void __init kernel_randomize_memory(void)
> >  	if (!kaslr_memory_enabled())
> >  		return;
> >  
> > -	kaslr_regions[0].size_tb = 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT);
> > +	/*
> > +	 * Upper limit for direct mapping size is 1/4 of whole virtual
> > +	 * address space
> > +	 */
> > +	kaslr_regions[0].size_tb = 1 << (__VIRTUAL_MASK_SHIFT - 1 - TB_SHIFT);
> 
> Is this a cleanup that can be separate?

Right. I'll split it up.

> >  	kaslr_regions[1].size_tb = VMALLOC_SIZE_TB;
> >  
> >  	/*
> > @@ -101,8 +114,10 @@ void __init kernel_randomize_memory(void)
> >  	 * add padding if needed (especially for memory hotplug support).
> >  	 */
> >  	BUG_ON(kaslr_regions[0].base != &page_offset_base);
> > -	memory_tb = DIV_ROUND_UP(max_pfn << PAGE_SHIFT, 1UL << TB_SHIFT) +
> > -		CONFIG_MEMORY_PHYSICAL_PADDING;
> > +
> > +	setup_direct_mapping_size();
> > +
> > +	memory_tb = direct_mapping_size * mktme_nr_keyids + 1;
> 
> What's the +1 for?  Is "mktme_nr_keyids" 0 for "MKTME unsupported"?
> That needs to be called out, I think.

I'll add a comment.

> >  	/* Adapt phyiscal memory region size based on available memory */
> >  	if (memory_tb < kaslr_regions[0].size_tb)
> > diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> > index 43a44f0f2a2d..3e5322bf035e 100644
> > --- a/arch/x86/mm/mktme.c
> > +++ b/arch/x86/mm/mktme.c
> > @@ -89,3 +89,51 @@ static bool need_page_mktme(void)
> >  struct page_ext_operations page_mktme_ops = {
> >  	.need = need_page_mktme,
> >  };
> > +
> > +void __init setup_direct_mapping_size(void)
> > +{
> > +	unsigned long available_va;
> > +
> > +	/* 1/4 of virtual address space is didicated for direct mapping */
> > +	available_va = 1UL << (__VIRTUAL_MASK_SHIFT - 1);
> > +
> > +	/* How much memory the systrem has? */
> > +	direct_mapping_size = max_pfn << PAGE_SHIFT;
> > +	direct_mapping_size = round_up(direct_mapping_size, 1UL << 40);
> > +
> > +	if (mktme_status != MKTME_ENUMERATED)
> > +		goto out;
> > +
> > +	/*
> > +	 * Not enough virtual address space to address all physical memory with
> > +	 * MKTME enabled. Even without padding.
> > +	 *
> > +	 * Disable MKTME instead.
> > +	 */
> > +	if (direct_mapping_size > available_va / mktme_nr_keyids + 1) {
> > +		pr_err("x86/mktme: Disabled. Not enough virtual address space\n");
> > +		pr_err("x86/mktme: Consider switching to 5-level paging\n");
> > +		mktme_disable();
> > +		goto out;
> > +	}
> > +
> > +	/*
> > +	 * Virtual address space is divided between per-KeyID direct mappings.
> > +	 */
> > +	available_va /= mktme_nr_keyids + 1;
> > +out:
> > +	/* Add padding, if there's enough virtual address space */
> > +	direct_mapping_size += (1UL << 40) * CONFIG_MEMORY_PHYSICAL_PADDING;
> > +	if (direct_mapping_size > available_va)
> > +		direct_mapping_size = available_va;
> > +}
> 
> Do you really need two copies of this function?  Shouldn't it see
> mktme_status!=MKTME_ENUMERATED and just jump out?  How is the code
> before that "goto out" different from the CONFIG_MKTME=n case?

mktme.c is not compiled for CONFIG_MKTME=n.

-- 
 Kirill A. Shutemov
