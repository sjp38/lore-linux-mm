Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0204E6B30CE
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:48:53 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id z126so11417314qka.10
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 02:48:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 88si9406007qte.245.2018.11.23.02.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 02:48:52 -0800 (PST)
Subject: Re: [PATCH v8 4/7] mm, devm_memremap_pages: Add MEMORY_DEVICE_PRIVATE
 support
References: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154275559036.76910.12434636179931292607.stgit@dwillia2-desk3.amr.corp.intel.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <0d1be2d5-8682-84aa-cbbd-f7ee01d77b12@redhat.com>
Date: Fri, 23 Nov 2018 11:48:48 +0100
MIME-Version: 1.0
In-Reply-To: <154275559036.76910.12434636179931292607.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org

On 21.11.18 00:13, Dan Williams wrote:
> In preparation for consolidating all ZONE_DEVICE enabling via
> devm_memremap_pages(), teach it how to handle the constraints of
> MEMORY_DEVICE_PRIVATE ranges.
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> [jglisse: call move_pfn_range_to_zone for MEMORY_DEVICE_PRIVATE]
> Acked-by: Christoph Hellwig <hch@lst.de>
> Reported-by: Logan Gunthorpe <logang@deltatee.com>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  kernel/memremap.c |   53 +++++++++++++++++++++++++++++++++++++++++------------
>  1 file changed, 41 insertions(+), 12 deletions(-)
> 
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 5e45f0c327a5..3eef989ef035 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -98,9 +98,15 @@ static void devm_memremap_pages_release(void *data)
>  		- align_start;
>  
>  	mem_hotplug_begin();
> -	arch_remove_memory(align_start, align_size, pgmap->altmap_valid ?
> -			&pgmap->altmap : NULL);
> -	kasan_remove_zero_shadow(__va(align_start), align_size);
> +	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
> +		pfn = align_start >> PAGE_SHIFT;
> +		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
> +				align_size >> PAGE_SHIFT, NULL);
> +	} else {
> +		arch_remove_memory(align_start, align_size,
> +				pgmap->altmap_valid ? &pgmap->altmap : NULL);
> +		kasan_remove_zero_shadow(__va(align_start), align_size);
> +	}
>  	mem_hotplug_done();
>  
>  	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
> @@ -187,17 +193,40 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  		goto err_pfn_remap;
>  
>  	mem_hotplug_begin();
> -	error = kasan_add_zero_shadow(__va(align_start), align_size);
> -	if (error) {
> -		mem_hotplug_done();
> -		goto err_kasan;
> +
> +	/*
> +	 * For device private memory we call add_pages() as we only need to
> +	 * allocate and initialize struct page for the device memory. More-
> +	 * over the device memory is un-accessible thus we do not want to
> +	 * create a linear mapping for the memory like arch_add_memory()
> +	 * would do.
> +	 *
> +	 * For all other device memory types, which are accessible by
> +	 * the CPU, we do want the linear mapping and thus use
> +	 * arch_add_memory().
> +	 */

I consider this comment really useful. :)

Short question: Right now, MEMORY_DEVICE_PRIVATE always indicates HMM,
correct? (I am just confused by the naming but I assume
MEMORY_DEVICE_PRIVATE is more generic than HMM)


-- 

Thanks,

David / dhildenb
