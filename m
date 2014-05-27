Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 599F56B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 14:46:01 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so9783667pbc.9
        for <linux-mm@kvack.org>; Tue, 27 May 2014 11:46:01 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xg6si20288566pab.9.2014.05.27.11.45.59
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 11:46:00 -0700 (PDT)
Message-ID: <5384DD67.3010408@intel.com>
Date: Tue, 27 May 2014 11:45:59 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: bootmem: Check pfn_valid() before accessing struct
 page
References: <1401199802-10212-1-git-send-email-matt.fleming@intel.com>
In-Reply-To: <1401199802-10212-1-git-send-email-matt.fleming@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>

On 05/27/2014 07:10 AM, Matt Fleming wrote:
> We need to check that a pfn is valid before handing it to pfn_to_page()
> since on low memory systems with CONFIG_HIGHMEM=n it's possible that a
> pfn may not have a corresponding struct page.
> 
> This is in fact the case for one of Alan's machines where some of the
> EFI boot services pages live in highmem, and running a kernel without
> CONFIG_HIGHMEM enabled results in the following oops
...
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 90bd3507b413..406e9cb1d58c 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -164,6 +164,9 @@ void __init free_bootmem_late(unsigned long physaddr, unsigned long size)
>  	end = PFN_DOWN(physaddr + size);
>  
>  	for (; cursor < end; cursor++) {
> +		if (!pfn_valid(cursor))
> +			continue;
> +
>  		__free_pages_bootmem(pfn_to_page(cursor), 0);
>  		totalram_pages++;
>  	}

I don't think this is quite right.  pfn_valid() tells us whether we have
a 'struct page' there or not.  *BUT*, it does not tell us whether it is
RAM that we can actually address and than can be freed in to the buddy
allocator.

I think sparsemem is where this matters.  Let's say mem= caused lowmem
to end in the middle of a section (or that 896MB wasn't
section-aligned).  Then someone calls free_bootmem_late() on an area
that is in the last section, but _above_ max_mapnr.  It'll be
pfn_valid(), we'll free it in to the buddy allocator, and we'll blam the
first time we try to write to a bogus vaddr after a phys_to_virt().

At a higher level, I don't like the idea of the bootmem code papering
over bugs when somebody calls in to it trying to _free_ stuff that's not
memory (as far as the kernel is concerned).

I think the right thing to do is to call in to the e820 code and see if
the range is E820_RAM before trying to bootmem-free it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
