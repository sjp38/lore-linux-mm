Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CEE656B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 13:13:48 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u137-v6so491227itc.4
        for <linux-mm@kvack.org>; Tue, 22 May 2018 10:13:48 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id b196-v6si14940139ioe.63.2018.05.22.10.13.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 May 2018 10:13:47 -0700 (PDT)
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152694213486.5484.5340142369038375338.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <45b62e4b-ee9a-a2de-579f-24642bb1fbc7@deltatee.com>
Date: Tue, 22 May 2018 11:13:41 -0600
MIME-Version: 1.0
In-Reply-To: <152694213486.5484.5340142369038375338.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 4/5] mm, hmm: replace hmm_devmem_pages_create() with
 devm_memremap_pages()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 21/05/18 04:35 PM, Dan Williams wrote:
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
> +	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
> +		error = add_pages(nid, align_start >> PAGE_SHIFT,
> +				align_size >> PAGE_SHIFT, NULL, false);
> +	} else {
> +		struct zone *zone;
> +
> +		error = arch_add_memory(nid, align_start, align_size, altmap,
> +				false);
> +		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
> +		if (!error)
> +			move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
>  					align_size >> PAGE_SHIFT, altmap);
> +	}

Maybe I missed it in the patch but, don't we need the same thing in
devm_memremap_pages_release() such that it calls the correct remove
function? Similar to the replaced hmm code:

> -	mem_hotplug_begin();
> -	if (resource->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY)
> -		__remove_pages(zone, start_pfn, npages, NULL);
> -	else
> -		arch_remove_memory(start_pfn << PAGE_SHIFT,
> -				   npages << PAGE_SHIFT, NULL);
> -	mem_hotplug_done();
> -
> -	hmm_devmem_radix_release(resource);

Perhaps it should be a separate patch too as it would be easier to see
outside the big removal of HMM code.

Logan
