Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8378E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 16:28:25 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id z17-v6so2295715qka.9
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 13:28:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e23-v6si273457qta.54.2018.09.18.13.28.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 13:28:24 -0700 (PDT)
Date: Tue, 18 Sep 2018 16:28:19 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v5 2/7] mm, devm_memremap_pages: Kill mapping "System
 RAM" support
Message-ID: <20180918202818.GB14689@redhat.com>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153680533172.453305.5701902165148172434.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <153680533172.453305.5701902165148172434.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 12, 2018 at 07:22:11PM -0700, Dan Williams wrote:
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

Reviewed-by: Jerome Glisse <jglisse@redhat.com>

> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
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
