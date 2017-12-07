Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EC69D6B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:53:27 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y200so9080358itc.7
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:53:27 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id n71si3984309ioe.331.2017.12.07.11.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Dec 2017 11:53:26 -0800 (PST)
References: <20171207150840.28409-1-hch@lst.de>
 <20171207150840.28409-15-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <6260792f-cf6f-6b98-75a5-9e174107571a@deltatee.com>
Date: Thu, 7 Dec 2017 12:53:24 -0700
MIME-Version: 1.0
In-Reply-To: <20171207150840.28409-15-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 14/14] memremap: RCU protect data returned from
 dev_pagemap lookups
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org



On 07/12/17 08:08 AM, Christoph Hellwig wrote:
> Take the RCU critical sections into the callers of to_vmem_altmap so that
> we can read the page map inside the critical section.  Also rename the
> remaining helper to __lookup_dev_pagemap to fit into the current naming
> scheme.
I'm not saying I disagree, but what's the reasoning behind the double 
underscore prefix to the function?

> +struct dev_pagemap *__lookup_dev_pagemap(struct page *start_page)
> +{
> +	struct dev_pagemap *pgmap;
> +
> +	pgmap = radix_tree_lookup(&pgmap_radix, page_to_pfn(start_page));
> +	if (!pgmap || !pgmap->base_pfn)
> +		return NULL;
> +	return pgmap;
> +}

I'm also wondering why we are still looking up the dev_pagemap via the 
radix tree when struct page already has a pointer to it (page->pgmap).

Thanks,

Logan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
