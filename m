Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07A226B0286
	for <linux-mm@kvack.org>; Wed, 23 May 2018 11:47:57 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i3-v6so3240503iti.1
        for <linux-mm@kvack.org>; Wed, 23 May 2018 08:47:57 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 202-v6si2264221ite.86.2018.05.23.08.47.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 08:47:54 -0700 (PDT)
References: <152705221686.21414.771870778478134768.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152705223396.21414.13388289577013917472.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <8f0cae82-130f-8a64-cfbd-fda5fd76bb79@deltatee.com>
Date: Wed, 23 May 2018 09:47:45 -0600
MIME-Version: 1.0
In-Reply-To: <152705223396.21414.13388289577013917472.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v2 3/7] mm, devm_memremap_pages: Fix shutdown handling
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 22/05/18 11:10 PM, Dan Williams wrote:
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 7b4899c06f49..b5e894133cf6 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -106,6 +106,7 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
>   * @res: physical address range covered by @ref
>   * @ref: reference count that pins the devm_memremap_pages() mapping
> + * @kill: callback to transition @ref to the dead state
>   * @dev: host device of the mapping for debug
>   * @data: private data pointer for page_free()
>   * @type: memory type: see MEMORY_* in memory_hotplug.h
> @@ -117,13 +118,15 @@ struct dev_pagemap {
>  	bool altmap_valid;
>  	struct resource res;
>  	struct percpu_ref *ref;
> +	void (*kill)(struct percpu_ref *ref);
>  	struct device *dev;
>  	void *data;
>  	enum memory_type type;
>  };
>  
>  #ifdef CONFIG_ZONE_DEVICE
> -void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
> +void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
> +		void (*kill)(struct percpu_ref *));


It seems redundant to me to have the kill pointer both passed in as an
argument and passed in as part of pgmap... Why not just expect the user
to set it in the *pgmap that's passed in just like we expect ref to be
set ahead of time?

Another thought (that may be too forward looking) is to pass the
dev_pagemap struct to the kill function instead of the reference. That
way, if some future user wants to do something extra on kill they can
use container_of() to get extra context to work with.

Thanks,

Logan
