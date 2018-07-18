Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD1F6B0274
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 19:54:03 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e7-v6so3037993pfe.10
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 16:54:03 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k14-v6si4423445pga.149.2018.07.18.16.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 16:54:02 -0700 (PDT)
Subject: Re: [PATCHv5 12/19] x86/mm: Implement prep_encrypted_page() and
 arch_free_page()
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-13-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a05d800e-4c18-88e0-388c-093fc3dac6ec@intel.com>
Date: Wed, 18 Jul 2018 16:53:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180717112029.42378-13-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The description doesn't mention the potential performance implications
of this patch.  That's criminal at this point.

> --- a/arch/x86/mm/mktme.c
> +++ b/arch/x86/mm/mktme.c
> @@ -1,4 +1,5 @@
>  #include <linux/mm.h>
> +#include <linux/highmem.h>
>  #include <asm/mktme.h>
>  
>  phys_addr_t mktme_keyid_mask;
> @@ -49,3 +50,51 @@ int vma_keyid(struct vm_area_struct *vma)
>  	prot = pgprot_val(vma->vm_page_prot);
>  	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
>  }
> +
> +void prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
> +{
> +	int i;
> +
> +	/* It's not encrypted page: nothing to do */
> +	if (!keyid)
> +		return;

prep_encrypted_page() is called in the fast path in the page allocator.
This out-of-line copy costs a function call for all users and this is
also out of the reach of the compiler to understand that keyid!=0 is
unlikely.

I think this needs to be treated to the inline-in-the-header treatment.

> +	/*
> +	 * The hardware/CPU does not enforce coherency between mappings of the
> +	 * same physical page with different KeyIDs or encryption keys.
> +	 * We are responsible for cache management.
> +	 *
> +	 * We flush cache before allocating encrypted page
> +	 */
> +	clflush_cache_range(page_address(page), PAGE_SIZE << order);

It's also worth pointing out that this must be done on the keyid alias
direct map, not the normal one.

Wait a sec...  How do we know which direct map to use?

> +	for (i = 0; i < (1 << order); i++) {
> +		/* All pages coming out of the allocator should have KeyID 0 */
> +		WARN_ON_ONCE(lookup_page_ext(page)->keyid);
> +		lookup_page_ext(page)->keyid = keyid;
> +
> +		/* Clear the page after the KeyID is set. */
> +		if (zero)
> +			clear_highpage(page);
> +
> +		page++;
> +	}
> +}
> +
> +void arch_free_page(struct page *page, int order)
> +{
> +	int i;
> +
> +	/* It's not encrypted page: nothing to do */
> +	if (!page_keyid(page))
> +		return;

Ditto on pushing this to a header.

> +	clflush_cache_range(page_address(page), PAGE_SIZE << order);

OK, how do we know which copy of the direct map to use, here?

> +	for (i = 0; i < (1 << order); i++) {
> +		/* Check if the page has reasonable KeyID */
> +		WARN_ON_ONCE(lookup_page_ext(page)->keyid > mktme_nr_keyids);
> +		lookup_page_ext(page)->keyid = 0;
> +		page++;
> +	}
> +}
> 
