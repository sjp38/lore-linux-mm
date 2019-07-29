Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ABA0C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:28:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3D8B20679
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:28:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="hdpDddME"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3D8B20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 909D68E0003; Mon, 29 Jul 2019 19:28:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BAF18E0002; Mon, 29 Jul 2019 19:28:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 782EE8E0003; Mon, 29 Jul 2019 19:28:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 559DF8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:28:04 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id a2so35167467ybb.14
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:28:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=krkJ5Muxr1zU2Yfhb1ZLXVRsDPvsAPqIzJeSuzeVg2U=;
        b=opGcslRMMUE7MB7KrRcvC8sGgyU7WRkZWsbCVpkRHprjWnG2BRNvGKdhqxRS6M66g9
         2m5mX2Yh8SdGVwDUAc4ec6yAefKxbBUKDyvfhallDKsCxLm2YJjgtf155+/zGnoagiEZ
         tDjlIc6fyOeIm5JoWh9kxCHazqmjnzfYxEytFUleepFRlvyFSMz/AqWyaMUv0Kf/d3qx
         8sgfk7oDUAI0OB65tGPV6KdLzTu1QHzBe4b2/ukiOyy3/U3pPcD/cCOkJNTNF1qOSnoR
         JqtO+hdYfV+fVELAYx5+MiLzlodzQSp20ffLJosILzwJl7MQMjO/wjMBXDhqQGcIg1KT
         Disg==
X-Gm-Message-State: APjAAAWebQk55BAHyJ2Cs4Exc+dz2qrBfH6ctzRVGrTlJu6yj3oaZ92V
	DUHSy8O/8vwEkaE7u71Ul3SFzILKCMqRpEEKS7uW5wAtZwBDFBSjb3prfOxj+WcmLlZ2KHVNgqx
	SZpzzAIWoRVcKbCu6X1FnTq+5b9/ZQZJ4UYggqaX17D/h2dzPv1sNS+f5yKC5GPgJeA==
X-Received: by 2002:a81:3457:: with SMTP id b84mr62558072ywa.313.1564442884093;
        Mon, 29 Jul 2019 16:28:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkJJX+rRmLnZKUpBAinGG8BlX5mbVdrAuI0j/6ZriJaTwrg/nClVVyecJVnP8WQkVqTFFY
X-Received: by 2002:a81:3457:: with SMTP id b84mr62558040ywa.313.1564442883204;
        Mon, 29 Jul 2019 16:28:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564442883; cv=none;
        d=google.com; s=arc-20160816;
        b=x9OvtEQc/b55sP+uG2y6Her2C5H9/gKj8g9FQDW1lgVmzj7uvWFR3A/AzXSoiD5S1m
         pkPtfcgKCIXH41SXPneMmrchScZPqf/5wq5+HFgoyc+izhP4kZjpDaVRRAEAC/Op7VSt
         ZGZVJ6kLrOZCPLwnf1yOH2qfU0dvJMCl5tZQ5Nb2a2WIN3KVHKhv8IgClhOJFH/IIWfN
         aCFjsNqJGjsDMdy12JXHGS4MqT4y0QEtLHCUN7PAx34Dj+dOTZ/uwUs7ClOqP5CUQwwC
         SvOvErqXLTrCn7kb8zuPVA14y6mbbP8R8sLSIEzsjtMRVx6Pa+xPwUorrhvD/Lh62Eq9
         1liQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=krkJ5Muxr1zU2Yfhb1ZLXVRsDPvsAPqIzJeSuzeVg2U=;
        b=RR/peqwepTJQz7OS4Os8onJjuou2Crex+TyzkpSJiS/6fSwVtSpGVgd8ioSqTcs0Du
         R6sfsIaejgDt9KIh3ROQs409oZn5yoHX5NVjhxX5xt46pmU293jR2b9AEJAM7gzWgVrT
         FbAO2LhDIqut+wW5AC5YYshvZ2qu5/nIb+n4k3iH6ZxVZGze+7Y7fZdgMOEsBXfbylBj
         bDWA1jsa3luLzmRrhb+60ur5W3XmESG0rRmRvlvr6fsN8hlGCP8BTIXue1q9/3V5W9hm
         H9yrt7X6zMBDG58JcClzkXCARsiFE10syL/CZMYd4Bte+vNlhFFfFt2Mo0PM36wUwGgL
         kwOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=hdpDddME;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id u5si12443003ybb.233.2019.07.29.16.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:28:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=hdpDddME;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3f81030002>; Mon, 29 Jul 2019 16:28:03 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 29 Jul 2019 16:28:02 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 29 Jul 2019 16:28:02 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 29 Jul
 2019 23:27:58 +0000
Subject: Re: [PATCH 6/9] nouveau: simplify nouveau_dmem_migrate_vma
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: Bharata B Rao <bharata@linux.ibm.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<linux-kernel@vger.kernel.org>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-7-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <ceb593fb-840b-c915-be8e-77d056e26628@nvidia.com>
Date: Mon, 29 Jul 2019 16:27:58 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190729142843.22320-7-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564442883; bh=krkJ5Muxr1zU2Yfhb1ZLXVRsDPvsAPqIzJeSuzeVg2U=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=hdpDddMEwgu8oVBZddb5LHa8YOeL73mywlp6H+Z88inlgmOIZyzviRnV0xG8psmQX
	 gGG1FahrlO/VXl6jCJZ6zYLbSCTSItA1O39WbwvUpDCRcCavmLFkoHrO7fVIpsiVSe
	 IqOS2KVG4xVNgbB/6W7ounFR/g4eqCuvNs+50GEDyCeglBhhw1/s0c3CIgYzWc/BIj
	 sgQjCm/LYUnHZF36DFUp1qsUHE+EbNMkBUG3b0riviY2J6sdGxsy9b9vJqdCvu0dpe
	 24ZjqMjI+d8U0b68LJO+4jFadsaH36me6R8PCx5c4hD8gr5hwYFDsKCxWL1OVbJuoL
	 V+M5d7i0tnMhA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/29/19 7:28 AM, Christoph Hellwig wrote:
> Factor the main copy page to vram routine out into a helper that acts
> on a single page and which doesn't require the nouveau_dmem_migrate
> structure for argument passing.  As an added benefit the new version
> only allocates the dma address array once and reuses it for each
> subsequent chunk of work.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   drivers/gpu/drm/nouveau/nouveau_dmem.c | 185 ++++++++-----------------
>   1 file changed, 56 insertions(+), 129 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> index 036e6c07d489..6cb930755970 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> @@ -44,8 +44,6 @@
>   #define DMEM_CHUNK_SIZE (2UL << 20)
>   #define DMEM_CHUNK_NPAGES (DMEM_CHUNK_SIZE >> PAGE_SHIFT)
>   
> -struct nouveau_migrate;
> -
>   enum nouveau_aper {
>   	NOUVEAU_APER_VIRT,
>   	NOUVEAU_APER_VRAM,
> @@ -86,15 +84,6 @@ static inline struct nouveau_dmem *page_to_dmem(struct page *page)
>   	return container_of(page->pgmap, struct nouveau_dmem, pagemap);
>   }
>   
> -struct nouveau_migrate {
> -	struct vm_area_struct *vma;
> -	struct nouveau_drm *drm;
> -	struct nouveau_fence *fence;
> -	unsigned long npages;
> -	dma_addr_t *dma;
> -	unsigned long dma_nr;
> -};
> -
>   static unsigned long nouveau_dmem_page_addr(struct page *page)
>   {
>   	struct nouveau_dmem_chunk *chunk = page->zone_device_data;
> @@ -569,131 +558,67 @@ nouveau_dmem_init(struct nouveau_drm *drm)
>   	drm->dmem = NULL;
>   }
>   
> -static void
> -nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
> -				    const unsigned long *src_pfns,
> -				    unsigned long *dst_pfns,
> -				    unsigned long start,
> -				    unsigned long end,
> -				    struct nouveau_migrate *migrate)
> +static unsigned long nouveau_dmem_migrate_copy_one(struct nouveau_drm *drm,
> +		struct vm_area_struct *vma, unsigned long addr,
> +		unsigned long src, dma_addr_t *dma_addr)
>   {
> -	struct nouveau_drm *drm = migrate->drm;
>   	struct device *dev = drm->dev->dev;
> -	unsigned long addr, i, npages = 0;
> -	nouveau_migrate_copy_t copy;
> -	int ret;
> -
> -	/* First allocate new memory */
> -	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, i++) {
> -		struct page *dpage, *spage;
> -
> -		dst_pfns[i] = 0;
> -		spage = migrate_pfn_to_page(src_pfns[i]);
> -		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE))
> -			continue;
> -
> -		dpage = nouveau_dmem_page_alloc_locked(drm);
> -		if (!dpage)
> -			continue;
> -
> -		dst_pfns[i] = migrate_pfn(page_to_pfn(dpage)) |
> -			      MIGRATE_PFN_LOCKED |
> -			      MIGRATE_PFN_DEVICE;
> -		npages++;
> -	}
> -
> -	if (!npages)
> -		return;
> -
> -	/* Allocate storage for DMA addresses, so we can unmap later. */
> -	migrate->dma = kmalloc(sizeof(*migrate->dma) * npages, GFP_KERNEL);
> -	if (!migrate->dma)
> -		goto error;
> -	migrate->dma_nr = 0;
> -
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
> -			nouveau_dmem_page_free_locked(drm, dpage);
> -			dst_pfns[i] = 0;
> -			continue;
> -		}
> -
> -		migrate->dma[migrate->dma_nr] =
> -			dma_map_page_attrs(dev, spage, 0, PAGE_SIZE,
> -					   PCI_DMA_BIDIRECTIONAL,
> -					   DMA_ATTR_SKIP_CPU_SYNC);
> -		if (dma_mapping_error(dev, migrate->dma[migrate->dma_nr])) {
> -			nouveau_dmem_page_free_locked(drm, dpage);
> -			dst_pfns[i] = 0;
> -			continue;
> -		}
> -
> -		ret = copy(drm, 1, NOUVEAU_APER_VRAM,
> -				nouveau_dmem_page_addr(dpage),
> -				NOUVEAU_APER_HOST,
> -				migrate->dma[migrate->dma_nr++]);
> -		if (ret) {
> -			nouveau_dmem_page_free_locked(drm, dpage);
> -			dst_pfns[i] = 0;
> -			continue;
> -		}
> -	}
> +	struct page *dpage, *spage;
>   
> -	nouveau_fence_new(drm->dmem->migrate.chan, false, &migrate->fence);
> +	spage = migrate_pfn_to_page(src);
> +	if (!spage || !(src & MIGRATE_PFN_MIGRATE))
> +		goto out;
>   
> -	return;
> +	dpage = nouveau_dmem_page_alloc_locked(drm);
> +	if (!dpage)
> +		return 0;
>   
> -error:
> -	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, ++i) {
> -		struct page *page;
> +	*dma_addr = dma_map_page(dev, spage, 0, PAGE_SIZE, DMA_BIDIRECTIONAL);
> +	if (dma_mapping_error(dev, *dma_addr))
> +		goto out_free_page;
>   
> -		if (!dst_pfns[i] || dst_pfns[i] == MIGRATE_PFN_ERROR)
> -			continue;
> +	if (drm->dmem->migrate.copy_func(drm, 1, NOUVEAU_APER_VRAM,
> +			nouveau_dmem_page_addr(dpage), NOUVEAU_APER_HOST,
> +			*dma_addr))
> +		goto out_dma_unmap;
>   
> -		page = migrate_pfn_to_page(dst_pfns[i]);
> -		dst_pfns[i] = MIGRATE_PFN_ERROR;
> -		if (page == NULL)
> -			continue;
> +	return migrate_pfn(page_to_pfn(dpage)) |
> +		MIGRATE_PFN_LOCKED | MIGRATE_PFN_DEVICE;
>   
> -		__free_page(page);
> -	}
> +out_dma_unmap:
> +	dma_unmap_page(dev, *dma_addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
> +out_free_page:
> +	nouveau_dmem_page_free_locked(drm, dpage);
> +out:
> +	return 0;
>   }
>   
> -static void
> -nouveau_dmem_migrate_finalize_and_map(struct nouveau_migrate *migrate)
> +static void nouveau_dmem_migrate_chunk(struct migrate_vma *args,
> +		struct nouveau_drm *drm, dma_addr_t *dma_addrs)
>   {
> -	struct nouveau_drm *drm = migrate->drm;
> +	struct nouveau_fence *fence;
> +	unsigned long addr = args->start, nr_dma = 0, i;
> +
> +	for (i = 0; addr < args->end; i++) {
> +		args->dst[i] = nouveau_dmem_migrate_copy_one(drm, args->vma,
> +				addr, args->src[i], &dma_addrs[nr_dma]);
> +		if (args->dst[i])
> +			nr_dma++;
> +		addr += PAGE_SIZE;
> +	}
>   
> -	nouveau_dmem_fence_done(&migrate->fence);
> +	nouveau_fence_new(drm->dmem->migrate.chan, false, &fence);
> +	migrate_vma_pages(args);
> +	nouveau_dmem_fence_done(&fence);
>   
> -	while (migrate->dma_nr--) {
> -		dma_unmap_page(drm->dev->dev, migrate->dma[migrate->dma_nr],
> -			       PAGE_SIZE, PCI_DMA_BIDIRECTIONAL);
> +	while (nr_dma--) {
> +		dma_unmap_page(drm->dev->dev, dma_addrs[nr_dma], PAGE_SIZE,
> +				DMA_BIDIRECTIONAL);
>   	}
> -	kfree(migrate->dma);
> -
>   	/*
> -	 * FIXME optimization: update GPU page table to point to newly
> -	 * migrated memory.
> +	 * FIXME optimization: update GPU page table to point to newly migrated
> +	 * memory.
>   	 */
> -}
> -
> -static void nouveau_dmem_migrate_chunk(struct migrate_vma *args,
> -		struct nouveau_migrate *migrate)
> -{
> -	nouveau_dmem_migrate_alloc_and_copy(args->vma, args->src, args->dst,
> -			args->start, args->end, migrate);
> -	migrate_vma_pages(args);
> -	nouveau_dmem_migrate_finalize_and_map(migrate);
>   	migrate_vma_finalize(args);
>   }
>   
> @@ -705,38 +630,40 @@ nouveau_dmem_migrate_vma(struct nouveau_drm *drm,
>   {
>   	unsigned long npages = (end - start) >> PAGE_SHIFT;
>   	unsigned long max = min(SG_MAX_SINGLE_ALLOC, npages);
> +	dma_addr_t *dma_addrs;
>   	struct migrate_vma args = {
>   		.vma		= vma,
>   		.start		= start,
>   	};
> -	struct nouveau_migrate migrate = {
> -		.drm		= drm,
> -		.vma		= vma,
> -		.npages		= npages,
> -	};
>   	unsigned long c, i;
>   	int ret = -ENOMEM;
>   
> -	args.src = kzalloc(sizeof(long) * max, GFP_KERNEL);
> +	args.src = kcalloc(max, sizeof(args.src), GFP_KERNEL);
>   	if (!args.src)
>   		goto out;
> -	args.dst = kzalloc(sizeof(long) * max, GFP_KERNEL);
> +	args.dst = kcalloc(max, sizeof(args.dst), GFP_KERNEL);
>   	if (!args.dst)
>   		goto out_free_src;
>   
> +	dma_addrs = kmalloc_array(max, sizeof(*dma_addrs), GFP_KERNEL);
> +	if (!dma_addrs)
> +		goto out_free_dst;
> +
>   	for (i = 0; i < npages; i += c) {
>   		c = min(SG_MAX_SINGLE_ALLOC, npages);
>   		args.end = start + (c << PAGE_SHIFT);
>   		ret = migrate_vma_setup(&args);
>   		if (ret)
> -			goto out_free_dst;
> +			goto out_free_dma;
>   
>   		if (args.cpages)
> -			nouveau_dmem_migrate_chunk(&args, &migrate);
> +			nouveau_dmem_migrate_chunk(&args, drm, dma_addrs);
>   		args.start = args.end;
>   	}
>   
>   	ret = 0;
> +out_free_dma:
> +	kfree(dma_addrs);
>   out_free_dst:
>   	kfree(args.dst);
>   out_free_src:
> 

