Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBB266B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 05:50:45 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d10-v6so18100pgv.8
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 02:50:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v3-v6sor2574062plb.24.2018.07.23.02.50.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 02:50:44 -0700 (PDT)
Date: Mon, 23 Jul 2018 12:50:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 12/19] x86/mm: Implement prep_encrypted_page() and
 arch_free_page()
Message-ID: <20180723095040.w67jp7c7cnxezuwp@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-13-kirill.shutemov@linux.intel.com>
 <a05d800e-4c18-88e0-388c-093fc3dac6ec@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a05d800e-4c18-88e0-388c-093fc3dac6ec@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 18, 2018 at 04:53:27PM -0700, Dave Hansen wrote:
> The description doesn't mention the potential performance implications
> of this patch.  That's criminal at this point.
> 
> > --- a/arch/x86/mm/mktme.c
> > +++ b/arch/x86/mm/mktme.c
> > @@ -1,4 +1,5 @@
> >  #include <linux/mm.h>
> > +#include <linux/highmem.h>
> >  #include <asm/mktme.h>
> >  
> >  phys_addr_t mktme_keyid_mask;
> > @@ -49,3 +50,51 @@ int vma_keyid(struct vm_area_struct *vma)
> >  	prot = pgprot_val(vma->vm_page_prot);
> >  	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
> >  }
> > +
> > +void prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
> > +{
> > +	int i;
> > +
> > +	/* It's not encrypted page: nothing to do */
> > +	if (!keyid)
> > +		return;
> 
> prep_encrypted_page() is called in the fast path in the page allocator.
> This out-of-line copy costs a function call for all users and this is
> also out of the reach of the compiler to understand that keyid!=0 is
> unlikely.
> 
> I think this needs to be treated to the inline-in-the-header treatment.

Okay. Again as a macros.

> > +	/*
> > +	 * The hardware/CPU does not enforce coherency between mappings of the
> > +	 * same physical page with different KeyIDs or encryption keys.
> > +	 * We are responsible for cache management.
> > +	 *
> > +	 * We flush cache before allocating encrypted page
> > +	 */
> > +	clflush_cache_range(page_address(page), PAGE_SIZE << order);
> 
> It's also worth pointing out that this must be done on the keyid alias
> direct map, not the normal one.
> 
> Wait a sec...  How do we know which direct map to use?

page_address() -> lowmem_page_address() -> page_to_virt()

page_to_virt() returns virtual address from the right direct mapping.

> > +	for (i = 0; i < (1 << order); i++) {
> > +		/* All pages coming out of the allocator should have KeyID 0 */
> > +		WARN_ON_ONCE(lookup_page_ext(page)->keyid);
> > +		lookup_page_ext(page)->keyid = keyid;
> > +
> > +		/* Clear the page after the KeyID is set. */
> > +		if (zero)
> > +			clear_highpage(page);
> > +
> > +		page++;
> > +	}
> > +}
> > +
> > +void arch_free_page(struct page *page, int order)
> > +{
> > +	int i;
> > +
> > +	/* It's not encrypted page: nothing to do */
> > +	if (!page_keyid(page))
> > +		return;
> 
> Ditto on pushing this to a header.
> 
> > +	clflush_cache_range(page_address(page), PAGE_SIZE << order);
> 
> OK, how do we know which copy of the direct map to use, here?

The same way as above.

> > +	for (i = 0; i < (1 << order); i++) {
> > +		/* Check if the page has reasonable KeyID */
> > +		WARN_ON_ONCE(lookup_page_ext(page)->keyid > mktme_nr_keyids);
> > +		lookup_page_ext(page)->keyid = 0;
> > +		page++;
> > +	}
> > +}
> > 
> 

-- 
 Kirill A. Shutemov
