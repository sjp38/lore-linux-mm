Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5404C6B0038
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 12:20:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j16so6288549pga.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 09:20:01 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a6si1548337pll.406.2017.09.20.09.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 09:19:59 -0700 (PDT)
Subject: Re: [PATCH v5 03/10] swiotlb: Map the buffer if it was unmapped by
 XPFO
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-4-tycho@docker.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5877eed8-0e8e-0dec-fdc7-de01bdbdafa8@intel.com>
Date: Wed, 20 Sep 2017 09:19:56 -0700
MIME-Version: 1.0
In-Reply-To: <20170809200755.11234-4-tycho@docker.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On 08/09/2017 01:07 PM, Tycho Andersen wrote:
> --- a/lib/swiotlb.c
> +++ b/lib/swiotlb.c
> @@ -420,8 +420,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
>  {
>  	unsigned long pfn = PFN_DOWN(orig_addr);
>  	unsigned char *vaddr = phys_to_virt(tlb_addr);
> +	struct page *page = pfn_to_page(pfn);
>  
> -	if (PageHighMem(pfn_to_page(pfn))) {
> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
>  		/* The buffer does not have a mapping.  Map it in and copy */
>  		unsigned int offset = orig_addr & ~PAGE_MASK;
>  		char *buffer;

This is a little scary.  I wonder how many more of these are in the
kernel, like:

> static inline void *skcipher_map(struct scatter_walk *walk)
> {
>         struct page *page = scatterwalk_page(walk);
> 
>         return (PageHighMem(page) ? kmap_atomic(page) : page_address(page)) +
>                offset_in_page(walk->offset);
> }

Is there any better way to catch these?  Like, can we add some debugging
to check for XPFO pages in __va()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
