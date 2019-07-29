Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35F86C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:26:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D30D620679
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:26:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="jqHrHACF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D30D620679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B1828E0003; Mon, 29 Jul 2019 19:26:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 561E98E0002; Mon, 29 Jul 2019 19:26:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 428DC8E0003; Mon, 29 Jul 2019 19:26:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1AECF8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:26:29 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id h203so46310179ywb.9
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:26:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=G1LxFP21VZwF9eYr/zeeq4GDQS7/44MoewdM+HDB/gs=;
        b=As1HRdCzfjBBbTBbM6h1DyR6DpRWZFUq++g9aM9vUKNjw5oaR7sQsz3vRetMDo4YRt
         AdALOXmkEFz1K+g99dkpihMDcHx4mbVeaNWbpN/Zsb6JjFvHCWQuyUy5tbLLnYH4DUFn
         VpYvOn6hxaIklF/EwKhVuLSKL8Nb8G0w/288jvAiL+KlPEILEO5/4F73OHK3eHszyuwM
         NcpYZCDiu7b3SrX0qwb5bqyua7rMkEzQ500UWybR54tfCMjmMOpVo08/1YyrkFDJ7xiu
         nZ1MnwUfytR/cbzcFHNdTo+g/oHuk33n71m1pcAfLlh51i2yGYjZLL9qu4LJbLGMB3lM
         vSog==
X-Gm-Message-State: APjAAAWFrVc2ctbtlZN2ozOhUd0Fvv4h3UcB6Hcg+9sUv3zHGVTBls1c
	3l2WvCgWELgCtdcgQ32pRq5Vhz5IdwAY19aIhCsZw0KFVeuPmOIhmUhMuokbQOM0NTH7pvmPP0P
	yXP+6JBYvkjzqU6+2y0OSkZaKfopHZJawvL3eKOe/dsSD50qVHx9tA0/QoE9Ob2D0NQ==
X-Received: by 2002:a25:d907:: with SMTP id q7mr27727003ybg.348.1564442788829;
        Mon, 29 Jul 2019 16:26:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/DnD8CikE/nq3rloZ9N017+Su/3ni2Kx8TJb92s9KghP2H/Jag9CknrdrH1w6dpxAKwuY
X-Received: by 2002:a25:d907:: with SMTP id q7mr27726973ybg.348.1564442788144;
        Mon, 29 Jul 2019 16:26:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564442788; cv=none;
        d=google.com; s=arc-20160816;
        b=Q1FJumyoCi3U/KYdqqQpvDXnWGi2+3unzVCCMsqKSGzhB89dziBB02OuHiozYXljxp
         d1Jmu4r2mVPXo63n/aRPzwmf+ppivJxm7TV5RYt2sCKT+T/6hJo0xoNLbBxDpoKf6T+Y
         2oVTJXCTyLNa+T//o1y39McbUigwYDFxgnyp6+cEW9EfCff0ySSf17vNK+UTeyEQuJXi
         HFfMUUeNCyi7DPv5OIOpgB1elpsd/qQAdv2gSpDyYpy0UZsQkurKwfIUNt5Gk8Cqukcg
         6Xust+y3BSohUMKWy+N36wV8OF4je2k75rhs1fXuQof0Vzeli5yuqBiSG2croggxeemT
         1HGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=G1LxFP21VZwF9eYr/zeeq4GDQS7/44MoewdM+HDB/gs=;
        b=cFfXejejfXjiLtlHNMjRHdIqFA8xLvC1xg5Cua5dSIFjyEGHW62cZI/0BlwTq3ucma
         8wHKuu0VEWukpbMbZrROjIV/29CAKz12IofaXq6iVBAaw4Yyl/YLXB0ZKRgEdXmFPZr9
         HYYeztw5C58D6ZJj98o1zmzke3ihrRsYPEYqW5kM+A0S1iPzNVWUVFOq35619Qhrnw1V
         890swgKxAp+rsYPA5BKWD6PUZUKEO6CZTJnrPYbtCGFlGxkn7aC7RFPe7AplWZjyBB9Q
         cETU3NjSLR0KazJTq7wpaMfyV0Xwh0jo6DOT0h9+YUic2WB8+uHBhO80B0B/OkEgfFmx
         L5PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jqHrHACF;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id v65si21121028ywd.433.2019.07.29.16.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:26:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jqHrHACF;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3f809a0000>; Mon, 29 Jul 2019 16:26:18 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 29 Jul 2019 16:26:27 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 29 Jul 2019 16:26:27 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 29 Jul
 2019 23:26:22 +0000
Subject: Re: [PATCH 5/9] nouveau: simplify nouveau_dmem_migrate_to_ram
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: Bharata B Rao <bharata@linux.ibm.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<linux-kernel@vger.kernel.org>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-6-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <0c07ed9b-96c3-ec06-c6c5-1676f5c91eda@nvidia.com>
Date: Mon, 29 Jul 2019 16:26:22 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190729142843.22320-6-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564442778; bh=G1LxFP21VZwF9eYr/zeeq4GDQS7/44MoewdM+HDB/gs=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=jqHrHACFZoBWZhi9/KhmjsswxPPZKCo1ogM0BBbLeMCZvjL3ndhiINa06G8EJiKN0
	 aAX6fVNQjvjapU5IucYrQ/PhBYE8Qx8c/sAOM4QU2qCASBFP0gD+tFx8UFSUk3i3Vl
	 Ejuy9i1TcRUJWr0F1IrRz7TBdUQ6qgEl08TNpNkTIJ20D/ALypTrxp2C4WBZe/N3IQ
	 +rxP8muTU6k5kEqB0rS9hBGrI6xFyzE5OLjvnvIJ4gHOqTQfOb4sC+hatCAD90TaTt
	 5vaMEs4XyJ3e5wjJbW542SA46PeXPAEYqnOPmpWBLVIjTs5u4ZF0eW+xVkHRO57m6t
	 0McRcwIAbGuLQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/29/19 7:28 AM, Christoph Hellwig wrote:
> Factor the main copy page to ram routine out into a helper that acts on
> a single page and which doesn't require the nouveau_dmem_fault
> structure for argument passing.  Also remove the loop over multiple
> pages as we only handle one at the moment, although the structure of
> the main worker function makes it relatively easy to add multi page
> support back if needed in the future.  But at least for now this avoid
> the needed to dynamically allocate memory for the dma addresses in
> what is essentially the page fault path.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   drivers/gpu/drm/nouveau/nouveau_dmem.c | 158 ++++++-------------------
>   1 file changed, 39 insertions(+), 119 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> index 21052a4aaf69..036e6c07d489 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> @@ -86,13 +86,6 @@ static inline struct nouveau_dmem *page_to_dmem(struct page *page)
>   	return container_of(page->pgmap, struct nouveau_dmem, pagemap);
>   }
>   
> -struct nouveau_dmem_fault {
> -	struct nouveau_drm *drm;
> -	struct nouveau_fence *fence;
> -	dma_addr_t *dma;
> -	unsigned long npages;
> -};
> -
>   struct nouveau_migrate {
>   	struct vm_area_struct *vma;
>   	struct nouveau_drm *drm;
> @@ -146,130 +139,55 @@ static void nouveau_dmem_fence_done(struct nouveau_fence **fence)
>   	}
>   }
>   
> -static void
> -nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
> -				  const unsigned long *src_pfns,
> -				  unsigned long *dst_pfns,
> -				  unsigned long start,
> -				  unsigned long end,
> -				  struct nouveau_dmem_fault *fault)
> +static vm_fault_t nouveau_dmem_fault_copy_one(struct nouveau_drm *drm,
> +		struct vm_area_struct *vma, unsigned long addr,
> +		unsigned long src, unsigned long *dst, dma_addr_t *dma_addr)
>   {
> -	struct nouveau_drm *drm = fault->drm;
>   	struct device *dev = drm->dev->dev;
> -	unsigned long addr, i, npages = 0;
> -	nouveau_migrate_copy_t copy;
> -	int ret;
> -
> -
> -	/* First allocate new memory */
> -	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, i++) {
> -		struct page *dpage, *spage;
> -
> -		dst_pfns[i] = 0;
> -		spage = migrate_pfn_to_page(src_pfns[i]);
> -		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE))
> -			continue;
> +	struct page *dpage, *spage;
>   
> -		dpage = alloc_page_vma(GFP_HIGHUSER, vma, addr);
> -		if (!dpage) {
> -			dst_pfns[i] = MIGRATE_PFN_ERROR;
> -			continue;
> -		}
> -		lock_page(dpage);
> -
> -		dst_pfns[i] = migrate_pfn(page_to_pfn(dpage)) |
> -			      MIGRATE_PFN_LOCKED;
> -		npages++;
> -	}
> +	spage = migrate_pfn_to_page(src);
> +	if (!spage || !(src & MIGRATE_PFN_MIGRATE))
> +		return 0;
>   
> -	/* Allocate storage for DMA addresses, so we can unmap later. */
> -	fault->dma = kmalloc(sizeof(*fault->dma) * npages, GFP_KERNEL);
> -	if (!fault->dma)
> +	dpage = alloc_page_vma(GFP_HIGHUSER, args->vma, addr);
> +	if (!dpage)
>   		goto error;
> +	lock_page(dpage);
>   
> -	/* Copy things over */
> -	copy = drm->dmem->migrate.copy_func;
> -	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, i++) {
> -		struct page *spage, *dpage;
> -
> -		dpage = migrate_pfn_to_page(dst_pfns[i]);
> -		if (!dpage || dst_pfns[i] == MIGRATE_PFN_ERROR)
> -			continue;
> -
> -		spage = migrate_pfn_to_page(src_pfns[i]);
> -		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE)) {
> -			dst_pfns[i] = MIGRATE_PFN_ERROR;
> -			__free_page(dpage);
> -			continue;
> -		}
> -
> -		fault->dma[fault->npages] =
> -			dma_map_page_attrs(dev, dpage, 0, PAGE_SIZE,
> -					   PCI_DMA_BIDIRECTIONAL,
> -					   DMA_ATTR_SKIP_CPU_SYNC);
> -		if (dma_mapping_error(dev, fault->dma[fault->npages])) {
> -			dst_pfns[i] = MIGRATE_PFN_ERROR;
> -			__free_page(dpage);
> -			continue;
> -		}
> -
> -		ret = copy(drm, 1, NOUVEAU_APER_HOST,
> -				fault->dma[fault->npages++],
> -				NOUVEAU_APER_VRAM,
> -				nouveau_dmem_page_addr(spage));
> -		if (ret) {
> -			dst_pfns[i] = MIGRATE_PFN_ERROR;
> -			__free_page(dpage);
> -			continue;
> -		}
> -	}
> +	*dma_addr = dma_map_page(dev, dpage, 0, PAGE_SIZE, DMA_BIDIRECTIONAL);
> +	if (dma_mapping_error(dev, *dma_addr))
> +		goto error_free_page;
>   
> -	nouveau_fence_new(drm->dmem->migrate.chan, false, &fault->fence);
> +	if (drm->dmem->migrate.copy_func(drm, 1, NOUVEAU_APER_HOST, *dma_addr,
> +			NOUVEAU_APER_VRAM, nouveau_dmem_page_addr(spage)))
> +		goto error_dma_unmap;
>   
> -	return;
> +	*dst = migrate_pfn(page_to_pfn(dpage)) | MIGRATE_PFN_LOCKED;

Need a "return 0;" here or you undo the work done.

>   
> +error_dma_unmap:
> +	dma_unmap_page(dev, *dma_addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
> +error_free_page:
> +	__free_page(dpage);
>   error:
> -	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, ++i) {
> -		struct page *page;
> -
> -		if (!dst_pfns[i] || dst_pfns[i] == MIGRATE_PFN_ERROR)
> -			continue;
> -
> -		page = migrate_pfn_to_page(dst_pfns[i]);
> -		dst_pfns[i] = MIGRATE_PFN_ERROR;
> -		if (page == NULL)
> -			continue;
> -
> -		__free_page(page);
> -	}
> -}
> -
> -static void
> -nouveau_dmem_fault_finalize_and_map(struct nouveau_dmem_fault *fault)
> -{
> -	struct nouveau_drm *drm = fault->drm;
> -
> -	nouveau_dmem_fence_done(&fault->fence);
> -
> -	while (fault->npages--) {
> -		dma_unmap_page(drm->dev->dev, fault->dma[fault->npages],
> -			       PAGE_SIZE, PCI_DMA_BIDIRECTIONAL);
> -	}
> -	kfree(fault->dma);
> +	return VM_FAULT_SIGBUS;
>   }
>   
>   static vm_fault_t nouveau_dmem_migrate_to_ram(struct vm_fault *vmf)
>   {
>   	struct nouveau_dmem *dmem = page_to_dmem(vmf->page);
> -	unsigned long src[1] = {0}, dst[1] = {0};
> +	struct nouveau_drm *drm = dmem->drm;
> +	struct nouveau_fence *fence;
> +	unsigned long src = 0, dst = 0;
> +	dma_addr_t dma_addr = 0;
> +	vm_fault_t ret;
>   	struct migrate_vma args = {
>   		.vma		= vmf->vma,
>   		.start		= vmf->address,
>   		.end		= vmf->address + PAGE_SIZE,
> -		.src		= src,
> -		.dst		= dst,
> +		.src		= &src,
> +		.dst		= &dst,
>   	};
> -	struct nouveau_dmem_fault fault = { .drm = dmem->drm };
>   
>   	/*
>   	 * FIXME what we really want is to find some heuristic to migrate more
> @@ -281,16 +199,18 @@ static vm_fault_t nouveau_dmem_migrate_to_ram(struct vm_fault *vmf)
>   	if (!args.cpages)
>   		return 0;
>   
> -	nouveau_dmem_fault_alloc_and_copy(args.vma, src, dst, args.start,
> -			args.end, &fault);
> -	migrate_vma_pages(&args);
> -	nouveau_dmem_fault_finalize_and_map(&fault);
> +	ret = nouveau_dmem_fault_copy_one(drm, vmf->vma, vmf->address, src,
> +			&dst, &dma_addr);
> +	if (ret || dst == 0)
> +		goto done;
>   
> +	nouveau_fence_new(dmem->migrate.chan, false, &fence);
> +	migrate_vma_pages(&args);
> +	nouveau_dmem_fence_done(&fence);
> +	dma_unmap_page(drm->dev->dev, dma_addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
> +done:
>   	migrate_vma_finalize(&args);
> -	if (dst[0] == MIGRATE_PFN_ERROR)
> -		return VM_FAULT_SIGBUS;
> -
> -	return 0;
> +	return ret;
>   }
>   
>   static const struct dev_pagemap_ops nouveau_dmem_pagemap_ops = {
> 

