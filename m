Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10430C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:21:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B97692070B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:21:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="POMfKb/Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B97692070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5172A8E0003; Mon, 29 Jul 2019 19:21:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C8738E0002; Mon, 29 Jul 2019 19:21:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DE478E0003; Mon, 29 Jul 2019 19:21:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB778E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:21:44 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v3so46090258ywe.21
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:21:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Ck0Fwz/3L8okeuwUnKILoh2bth9zQ838mb2LNvYCu5c=;
        b=GmEEESVusabIG6sSs3sx+B/8DZp1PzVJ61IKg6DRfV7DSOfq8EnEZKUk6MXJcG0H+4
         imfUK7KG3b9W6+RP2RxcCUbT+3UdHogBYRErEJaDpzM/E7tXS0/rqC7L2IujKNzcAhkx
         HY/a224uJOBm4CsN/FKe0ITzQ9DVF1j7Z2hRpS8MPt1HDO0fl3CTI9pov8mziH3OLJtE
         n1amqbwiIai7rrr2gornbuQGU8hjKY3jBVbBzzj+t6xZtG6PRw+5lssutot+o0tXmDh1
         tOJxO4HRZCkA67lqdwapKek1DXsh56d0dfnUH4bxIVLXES+hfFJd4MssyRckCr/XkSF1
         JD9A==
X-Gm-Message-State: APjAAAU0qjH1+CrzZbLFjmQNu+4dOwCjhwaRBe4/4qpLA5H2r1hp+x0Z
	JjNJWVWwo6j8N+oS6s+VSArKWkn9BwMfNmQJqPYHAE1HwqNHegnEDXGPzSncVK7kgiDBb7NV5DM
	VpS3ogFbS73df3a8xbzUogFwHQu1ZQBRbZZ2KQzf0neqn88LvGWnzVD0+OkxnX5/bDg==
X-Received: by 2002:a81:a6d2:: with SMTP id d201mr67177573ywh.237.1564442503880;
        Mon, 29 Jul 2019 16:21:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyRneietbNiHMEi+A575XUVuIKnLChEsadKjCJArawCbny2VbmdVKqalmIEfrxSpX8giWK
X-Received: by 2002:a81:a6d2:: with SMTP id d201mr67177553ywh.237.1564442503231;
        Mon, 29 Jul 2019 16:21:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564442503; cv=none;
        d=google.com; s=arc-20160816;
        b=PXF7Cwb2V4i9tXlsss305VZ2N0pFn48dYaCsLodP/1Ux/v6fHiDsYSEu1V2uvRild+
         ZhDyiasxz0b0Hqa3TiqAb6TpVEAaDI3Uw2Vb4yUmikoBszGKDsdGmVNKjd0rBKHkGhHC
         OBIki7teFDmsRBiiagTUSpwZMDbBYbVirijuPbbs5MkHOxCIYwfPLmqyR5WiuF3m+w4a
         5MNtyEfjZdv65+fd4Qm8k6I7oMdAU+Lq1LlIjR34MYvw+N6UfBjmoSfGPcCm7M9/7+x4
         fKsuwbKAb4chtXJJrrXEZbGaRY7NyQ4ksKcdlCbkT3joAXPkVtQJ/7odkcZ/R87yzXt/
         LBaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Ck0Fwz/3L8okeuwUnKILoh2bth9zQ838mb2LNvYCu5c=;
        b=YO3UtX1O4tLl+52yY44944esi75+gsDequlrYJv6WLRvku5hIJDO8AQRipNwYUxinI
         3HRNRvTkz+AeSIQ3UleIYVCC3/z0FWI4QHl0EEI4/90X1DDr6Kyu8I2I7s5bJaCcmDCe
         yjFFi7XGKXXm76dmuNufQ6IfCgrLW+qHAgE+xkglt2Tu0Zo38dGZXWGrIaNC1n/ILUT2
         DJxofkHo2q8J6vMb+JAmZHN8/Q9w54efHpGgA2aDFNgHNfIlmheBxSqyi758+u7fsy6S
         PrhYLuDsWdLCf0MIIhEyvk2eotR7d8w6YMFFiEc/Bs8k7Z1hZcylUDsbT/PS5mE6h/1M
         qoLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="POMfKb/Y";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id r8si15035595ybk.52.2019.07.29.16.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:21:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="POMfKb/Y";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3f7f8e0000>; Mon, 29 Jul 2019 16:21:50 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 29 Jul 2019 16:21:42 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 29 Jul 2019 16:21:42 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 29 Jul
 2019 23:21:40 +0000
Subject: Re: [PATCH 3/9] nouveau: factor out device memory address calculation
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: Bharata B Rao <bharata@linux.ibm.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<linux-kernel@vger.kernel.org>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-4-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <95ddc61c-edb9-b751-4e15-0d3f0aaca2e1@nvidia.com>
Date: Mon, 29 Jul 2019 16:21:40 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190729142843.22320-4-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564442510; bh=Ck0Fwz/3L8okeuwUnKILoh2bth9zQ838mb2LNvYCu5c=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=POMfKb/YMF0u6+QGiDqjGdH9lbOIf7G6w6JvD3Msf4yBRa7229kVJVax+KSS+cY2C
	 d5sL+sjwl/l/cPBDDZ6mr9yOs4LmD+lnKlb2a4UWkgi29cfcPUkE3Hjh6QRDNITc++
	 6Hgfj18O7Qm9bo8QE4+aUxtixOr8Re8PDf2XSG89G3LI3hGIm3e4cA3bOEOO23SOw2
	 VB6snRW8LBYrVdYdYH+rkI9VIp3FMPJcIbB+0K61vvzQed4J36ReyESE1XXv0qBsOi
	 0SY7ti+YSimYNOBZrgriBZ3Nrutk/Qy/u6XFJ8Ss725m+jHO8fOeb8PPE0vKXsCdIv
	 y3TxYfGGepEjg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/29/19 7:28 AM, Christoph Hellwig wrote:
> Factor out the repeated device memory address calculation into
> a helper.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   drivers/gpu/drm/nouveau/nouveau_dmem.c | 42 +++++++++++---------------
>   1 file changed, 17 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> index e696157f771e..d469bc334438 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> @@ -102,6 +102,14 @@ struct nouveau_migrate {
>   	unsigned long dma_nr;
>   };
>   
> +static unsigned long nouveau_dmem_page_addr(struct page *page)
> +{
> +	struct nouveau_dmem_chunk *chunk = page->zone_device_data;
> +	unsigned long idx = page_to_pfn(page) - chunk->pfn_first;
> +
> +	return (idx << PAGE_SHIFT) + chunk->bo->bo.offset;
> +}
> +
>   static void nouveau_dmem_page_free(struct page *page)
>   {
>   	struct nouveau_dmem_chunk *chunk = page->zone_device_data;
> @@ -169,9 +177,7 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
>   	/* Copy things over */
>   	copy = drm->dmem->migrate.copy_func;
>   	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, i++) {
> -		struct nouveau_dmem_chunk *chunk;
>   		struct page *spage, *dpage;
> -		u64 src_addr, dst_addr;
>   
>   		dpage = migrate_pfn_to_page(dst_pfns[i]);
>   		if (!dpage || dst_pfns[i] == MIGRATE_PFN_ERROR)
> @@ -194,14 +200,10 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
>   			continue;
>   		}
>   
> -		dst_addr = fault->dma[fault->npages++];
> -
> -		chunk = spage->zone_device_data;
> -		src_addr = page_to_pfn(spage) - chunk->pfn_first;
> -		src_addr = (src_addr << PAGE_SHIFT) + chunk->bo->bo.offset;
> -
> -		ret = copy(drm, 1, NOUVEAU_APER_HOST, dst_addr,
> -				   NOUVEAU_APER_VRAM, src_addr);
> +		ret = copy(drm, 1, NOUVEAU_APER_HOST,
> +				fault->dma[fault->npages++],
> +				NOUVEAU_APER_VRAM,
> +				nouveau_dmem_page_addr(spage));
>   		if (ret) {
>   			dst_pfns[i] = MIGRATE_PFN_ERROR;
>   			__free_page(dpage);
> @@ -687,18 +689,12 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
>   	/* Copy things over */
>   	copy = drm->dmem->migrate.copy_func;
>   	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, i++) {
> -		struct nouveau_dmem_chunk *chunk;
>   		struct page *spage, *dpage;
> -		u64 src_addr, dst_addr;
>   
>   		dpage = migrate_pfn_to_page(dst_pfns[i]);
>   		if (!dpage || dst_pfns[i] == MIGRATE_PFN_ERROR)
>   			continue;
>   
> -		chunk = dpage->zone_device_data;
> -		dst_addr = page_to_pfn(dpage) - chunk->pfn_first;
> -		dst_addr = (dst_addr << PAGE_SHIFT) + chunk->bo->bo.offset;
> -
>   		spage = migrate_pfn_to_page(src_pfns[i]);
>   		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE)) {
>   			nouveau_dmem_page_free_locked(drm, dpage);
> @@ -716,10 +712,10 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
>   			continue;
>   		}
>   
> -		src_addr = migrate->dma[migrate->dma_nr++];
> -
> -		ret = copy(drm, 1, NOUVEAU_APER_VRAM, dst_addr,
> -				   NOUVEAU_APER_HOST, src_addr);
> +		ret = copy(drm, 1, NOUVEAU_APER_VRAM,
> +				nouveau_dmem_page_addr(dpage),
> +				NOUVEAU_APER_HOST,
> +				migrate->dma[migrate->dma_nr++]);
>   		if (ret) {
>   			nouveau_dmem_page_free_locked(drm, dpage);
>   			dst_pfns[i] = 0;
> @@ -846,7 +842,6 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
>   
>   	npages = (range->end - range->start) >> PAGE_SHIFT;
>   	for (i = 0; i < npages; ++i) {
> -		struct nouveau_dmem_chunk *chunk;
>   		struct page *page;
>   		uint64_t addr;
>   
> @@ -864,10 +859,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
>   			continue;
>   		}
>   
> -		chunk = page->zone_device_data;
> -		addr = page_to_pfn(page) - chunk->pfn_first;
> -		addr = (addr + chunk->bo->bo.mem.start) << PAGE_SHIFT;
> -
> +		addr = nouveau_dmem_page_addr(page);
>   		range->pfns[i] &= ((1UL << range->pfn_shift) - 1);
>   		range->pfns[i] |= (addr >> PAGE_SHIFT) << range->pfn_shift;
>   	}
> 

