Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3CB6B02FA
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 12:11:53 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id h41so15197501ioi.1
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 09:11:53 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id i129si5942436itd.43.2017.04.27.09.11.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 09:11:52 -0700 (PDT)
References: <20170423233125.nehmgtzldgi25niy@node.shutemov.name>
 <149325431313.40660.7404075559824162131.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <3e595ba6-2ea1-e25d-e254-6c7edcf23f88@deltatee.com>
Date: Thu, 27 Apr 2017 10:11:46 -0600
MIME-Version: 1.0
In-Reply-To: <149325431313.40660.7404075559824162131.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] mm, zone_device: replace {get, put}_zone_device_page()
 with a single reference
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>



On 26/04/17 06:55 PM, Dan Williams wrote:
> @@ -277,7 +269,10 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
>   *
>   * Notes:
>   * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages() time
> - *    (or devm release event).
> + *    (or devm release event). The expected order of events is that @ref has
> + *    been through percpu_ref_kill() before devm_memremap_pages_release(). The
> + *    wait for the completion of kill and percpu_ref_exit() must occur after
> + *    devm_memremap_pages_release().
>   *
>   * 2/ @res is expected to be a host memory range that could feasibly be
>   *    treated as a "System RAM" range, i.e. not a device mmio range, but
> @@ -379,6 +374,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  		 */
>  		list_del(&page->lru);
>  		page->pgmap = pgmap;
> +		percpu_ref_get(ref);
>  	}
>  	devres_add(dev, page_map);
>  	return __va(res->start);
> diff --git a/mm/swap.c b/mm/swap.c
> index 5dabf444d724..01267dda6668 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -97,6 +97,16 @@ static void __put_compound_page(struct page *page)
>  
>  void __put_page(struct page *page)
>  {
> +	if (is_zone_device_page(page)) {
> +		put_dev_pagemap(page->pgmap);
> +
> +		/*
> +		 * The page belong to device, do not return it to
> +		 * page allocator.
> +		 */
> +		return;
> +	}
> +
>  	if (unlikely(PageCompound(page)))
>  		__put_compound_page(page);
>  	else
> 

Forgive me if I'm missing something but this doesn't make sense to me.
We are taking a reference once when the region is initialized and
releasing it every time a page within the region's reference count drops
to zero. That does not seem to be symmetric and I don't see how it
tracks that pages are in use. Shouldn't get_dev_pagemap be called when
any page is allocated or something like that (ie. the inverse of
__put_page)?

Thanks,

Logan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
