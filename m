Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id F1F1F8E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 12:10:52 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s15-v6so4858720iob.11
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 09:10:52 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id c1-v6si3022717iok.212.2018.09.13.09.10.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Sep 2018 09:10:51 -0700 (PDT)
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153680533172.453305.5701902165148172434.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <50c1172d-29c6-4509-de0d-897163b0b2e4@deltatee.com>
Date: Thu, 13 Sep 2018 10:10:45 -0600
MIME-Version: 1.0
In-Reply-To: <153680533172.453305.5701902165148172434.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH v5 2/7] mm, devm_memremap_pages: Kill mapping "System RAM"
 support
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 12/09/18 08:22 PM, Dan Williams wrote:
> Given the fact that devm_memremap_pages() requires a percpu_ref that is
> torn down by devm_memremap_pages_release() the current support for
> mapping RAM is broken.
> 
> Support for remapping "System RAM" has been broken since the beginning
> and there is no existing user of this this code path, so just kill the
> support and make it an explicit error.
> 
> This cleanup also simplifies a follow-on patch to fix the error path
> when setting a devm release action for devm_memremap_pages_release()
> fails.
> 
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

Logan

> ---
>  kernel/memremap.c |    9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index f95c7833db6d..92e838127767 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -202,15 +202,12 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  	is_ram = region_intersects(align_start, align_size,
>  		IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
>  
> -	if (is_ram == REGION_MIXED) {
> -		WARN_ONCE(1, "%s attempted on mixed region %pr\n",
> -				__func__, res);
> +	if (is_ram != REGION_DISJOINT) {
> +		WARN_ONCE(1, "%s attempted on %s region %pr\n", __func__,
> +				is_ram == REGION_MIXED ? "mixed" : "ram", res);
>  		return ERR_PTR(-ENXIO);
>  	}
>  
> -	if (is_ram == REGION_INTERSECTS)
> -		return __va(res->start);
> -
>  	if (!pgmap->ref)
>  		return ERR_PTR(-EINVAL);
>  
> 
