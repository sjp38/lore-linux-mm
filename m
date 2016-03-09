Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE5B6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 19:23:54 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id fz5so31340862obc.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 16:23:54 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id n83si4221004oih.63.2016.03.08.16.23.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 16:23:53 -0800 (PST)
Message-ID: <1457486191.15454.532.camel@hpe.com>
Subject: Re: [PATCH] mm: fix 'size' alignment in devm_memremap_pages()
From: Toshi Kani <toshi.kani@hpe.com>
Date: Tue, 08 Mar 2016 18:16:31 -0700
In-Reply-To: <20160308222516.16008.22439.stgit@dwillia2-desk3.jf.intel.com>
References: <20160308222516.16008.22439.stgit@dwillia2-desk3.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2016-03-08 at 14:32 -0800, Dan Williams wrote:
> We need to align the end address, not just the size.
> 
> Cc: Toshi Kani <toshi.kani@hpe.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

The change looks good.

Reviewed-by: Toshi Kani <toshi.kani@hpe.com>

Thanks,
-Toshi

> ---
> Hi Andrew, one more fixup to devm_memremap_pages().A A I was discussing
> patch "mm: fix mixed zone detection in devm_memremap_pages" with Toshi
> and noticed that it was mishandling the end-of-range alignment.A A Please
> apply or fold this into the existing patch.
> 
> A kernel/memremap.c |A A A 12 +++++++-----
> A 1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index c0f11a498a5a..60baf4d3401e 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -270,14 +270,16 @@ struct dev_pagemap
> *find_dev_pagemap(resource_size_t phys)
> A void *devm_memremap_pages(struct device *dev, struct resource *res,
> A 		struct percpu_ref *ref, struct vmem_altmap *altmap)
> A {
> -	resource_size_t align_start = res->start & ~(SECTION_SIZE - 1);
> -	resource_size_t align_size = ALIGN(resource_size(res),
> SECTION_SIZE);
> -	int is_ram = region_intersects(align_start, align_size, "System
> RAM");
> -	resource_size_t key, align_end;
> +	resource_size_t key, align_start, align_size, align_end;
> A 	struct dev_pagemap *pgmap;
> A 	struct page_map *page_map;
> +	int error, nid, is_ram;
> A 	unsigned long pfn;
> -	int error, nid;
> +
> +	align_start = res->start & ~(SECTION_SIZE - 1);
> +	align_size = ALIGN(res->start + resource_size(res),
> SECTION_SIZE)
> +		- align_start;
> +	is_ram = region_intersects(align_start, align_size, "System
> RAM");
> A 
> A 	if (is_ram == REGION_MIXED) {
> A 		WARN_ONCE(1, "%s attempted on mixed region %pr\n",
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
