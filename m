Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7F46B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 18:22:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t83-v6so1468948wmt.3
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 15:22:03 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b13-v6si3427672wrr.53.2018.07.18.15.22.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jul 2018 15:22:02 -0700 (PDT)
Date: Thu, 19 Jul 2018 00:21:44 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv5 18/19] x86/mm: Handle encrypted memory in page_to_virt()
 and __pa()
In-Reply-To: <20180717112029.42378-19-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.21.1807182356520.1689@nanos.tec.linutronix.de>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com> <20180717112029.42378-19-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 17 Jul 2018, Kirill A. Shutemov wrote:

> Per-KeyID direct mappings require changes into how we find the right
> virtual address for a page and virt-to-phys address translations.
> 
> page_to_virt() definition overwrites default macros provided by
> <linux/mm.h>. We only overwrite the macros if MTKME is enabled
> compile-time.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/include/asm/mktme.h   | 3 +++
>  arch/x86/include/asm/page_64.h | 2 +-
>  2 files changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
> index ba83fba4f9b3..dbfbd955da98 100644
> --- a/arch/x86/include/asm/mktme.h
> +++ b/arch/x86/include/asm/mktme.h
> @@ -29,6 +29,9 @@ void arch_free_page(struct page *page, int order);
>  
>  int sync_direct_mapping(void);
>  
> +#define page_to_virt(x) \
> +	(__va(PFN_PHYS(page_to_pfn(x))) + page_keyid(x) * direct_mapping_size)

This really does not belong into the mktme header.

Please make this the unconditional x86 page_to_virt() implementation in
asm/page.h, which is the canonical and obvious place for it.

The page_keyid() name is quite generic as well. Can this please have some
kind of reference to the underlying mechanism, i.e. mktme?

Please hide the multiplication with direct_mapping_size in the mktme header
as well. It's non interesting for the !MKTME case. Something like:

#define page_to_virt(x) \
	(__va(PFN_PHYS(page_to_pfn(x))) + mktme_page_to_virt_offset(x))

makes it immediately clear where to look and also makes it clear that the
offset will be 0 for a !MKTME enabled kernel and (hopefully) for all !MKTME
enabled processors as well.

And then have a proper implementation of mktme_page_to_virt_offset() with a
proper comment what on earth this is doing. It might be all obvious to you
now, but it's completely non obvious for the casual reader and you will
have to twist your brain around it 6 month from now as well.

>  #else
>  #define mktme_keyid_mask	((phys_addr_t)0)
>  #define mktme_nr_keyids		0
> diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
> index f57fc3cc2246..a4f394e3471d 100644
> --- a/arch/x86/include/asm/page_64.h
> +++ b/arch/x86/include/asm/page_64.h
> @@ -24,7 +24,7 @@ static inline unsigned long __phys_addr_nodebug(unsigned long x)
>  	/* use the carry flag to determine if x was < __START_KERNEL_map */
>  	x = y + ((x > y) ? phys_base : (__START_KERNEL_map - PAGE_OFFSET));
>  
> -	return x;
> +	return x & direct_mapping_mask;

This hunk also lacks any explanation both in the changelog and in form of a
comment.

> Per-KeyID direct mappings require changes into how we find the right
> virtual address for a page and virt-to-phys address translations.

That's pretty useless as it does just tell about 'changes', but not at all
about what kind of changes and why these changes are required. It's really
not helpful to assume that everyone stumbling over this will know the whole
story especially not 6 month after this has been merged and then someone
ends up with a bisect on that change.

While at it, please get rid of the 'we'. We are neither CPUs nor code.

Thanks,

	tglx
