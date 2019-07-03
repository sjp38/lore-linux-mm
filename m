Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1F3FC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 20:26:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65548218A0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 20:26:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="YGnNDsOJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65548218A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAEA88E001E; Wed,  3 Jul 2019 16:26:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D379C8E0019; Wed,  3 Jul 2019 16:26:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB1698E001E; Wed,  3 Jul 2019 16:26:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 936318E0019
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 16:26:40 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id a65so4681244qkc.23
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 13:26:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=rm6vHnMn1NjJ83H8wZDmyjFoYuZQHy+fENvMn/j452Q=;
        b=SMTKS6udgKojgYkPBfBqxaCKHilQLWDllDssCiP71tJFi37HLZ/UNZiAGCoErHyl/r
         7anFR/47M7H26JxWGMlNNzxaVQvLmf6f/uq3BXl/cCyO97HjKGgsH1XRCT2/gYYXgJ3l
         2WK0y9WrXlGo6m9ut6uBAIgnASLc5R8zLXbnc6Gexzn2b2F3NNLYuvuNw8EHSNYlq1lE
         cA8vdZxwUcgCKokRv77I1kONc2/kVdZ8NE8CQJsgyNS8NjU65f0+77GetoCHGUV8gS2G
         su+dxf3An7HCn2nGaqR4h2kZI7mJcfTtRu7c3UDCJEqLtT11zX6gaMwqa9Su5uaJ1acW
         Sx3Q==
X-Gm-Message-State: APjAAAVGNGny0Yfjwgm+cV8GTTxajCPOV8LvA5C4l7V1ikHKP07Jd2+L
	ELwRzR/fYIncpmYTtSokyIx1YpVZzMnJ9QtZTBiCAcB+HfHPLS+xpCPuv9Fkp4ns68ts5oCLDNU
	mY7MEc2gqAke8s9Olc9zzBZcJoRd7N3FxlckHxLQ0G9d1zYI1ozOwRQnDwoulTqS6Ow==
X-Received: by 2002:a0d:e544:: with SMTP id o65mr23947702ywe.382.1562185600301;
        Wed, 03 Jul 2019 13:26:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzW9N8aVKR0EF6y+2qrGJCHoJqc1yOIzaasA7J/DbMgcJyp2HkUDy3zEbWT4F9+95jv0Uu3
X-Received: by 2002:a0d:e544:: with SMTP id o65mr23947667ywe.382.1562185599597;
        Wed, 03 Jul 2019 13:26:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562185599; cv=none;
        d=google.com; s=arc-20160816;
        b=yqY1K1GLEs3gs9Sz3AtFTaEILESHN0UglSERP3r9Kpi/KMcuIc+vwgGPrDT+Jg7rQ6
         EFd5/iKkc4VIGovvyzYWftQzfElnpYRnQI/mlpOGUrxJsCwQpjYdtyjNmd94+zlFkGew
         mrvf7RnSB6Bc7Rf7My3cIn77X+CUSfCGzsXpV8hURz5wFSjm6BpIg6zBhTx1pokXiYDD
         34ezYB53AdKgPExOT1SxKiQ6KJhs2KZDohEKmCy7D0+KZVy09hxYKK3oH6OdHNlfxB+S
         F2Lc5Ck5ILlT/SVTxGMHbGmGmn/lxhdO9KZ6bLNJf77ttqywjpVrOcd+HHH5IamZpNUc
         cjKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=rm6vHnMn1NjJ83H8wZDmyjFoYuZQHy+fENvMn/j452Q=;
        b=IBYn0NARD3RZIH6/BY8gU/fyKw/RDZlu9JDXrU3OnBS91XKWMSla551FEM2+HNxKqt
         J2kP7gotpQHw7d8CccBYZsCP/mcHtEEtjkkhae56YEXn3Val7uT82pChJy+397198y3B
         AKCD5XOeo73si6v9wHQnUIxSpfCS5DA/qF79NLW7lNBZ3eeYAZF8m9XYJD7/Qbum1/4p
         OPTxMiZkP1Z5DrDLf5pmBmglzTtoy/6KIgJTUkc9jQiAuA2gdHE059Uq6kNeSZOHQdCp
         jpRdtVJSz9CXm9eO2/KIqTAen1M38AiGyLOGg4X0SSD5WDE3QEBq7tZS4JWJW+OHJCP/
         IkMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YGnNDsOJ;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id b14si1475259ywe.467.2019.07.03.13.26.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 13:26:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YGnNDsOJ;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d1d0f7d0000>; Wed, 03 Jul 2019 13:26:37 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 03 Jul 2019 13:26:38 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 03 Jul 2019 13:26:38 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 3 Jul
 2019 20:26:34 +0000
Subject: Re: [PATCH 5/5] mm: remove the legacy hmm_pfn_* APIs
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: <linux-mm@kvack.org>, <nouveau@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <linux-kernel@vger.kernel.org>
References: <20190703184502.16234-1-hch@lst.de>
 <20190703184502.16234-6-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <d234738d-92ee-a841-5d9b-22881f2ac545@nvidia.com>
Date: Wed, 3 Jul 2019 13:26:34 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190703184502.16234-6-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1562185597; bh=rm6vHnMn1NjJ83H8wZDmyjFoYuZQHy+fENvMn/j452Q=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=YGnNDsOJPDkrHnZlPSB55fjBHjofdZ1pqmg5mfa3pGUujmhe6o4wkL5zQFrut+fQL
	 EmRJT13nJsodHkdgKjpZR4k/NVQ+p2haLqoN51ApjjBfdxsQu37mRCZGfnn6ihTByE
	 RqPRggRXqjKi+TPrFy0qX8AWs4E/HIO1hxx+f7X5zz0G3WndR2YJOusT3+PpWP3WqJ
	 GC1OQ7RZna/YgqfIZhbnEszK6cBofosZXX+Adtv7Nj+x4Kwh931vt2y8xYJ1ObEqrj
	 DN+gXSpIZpsebWAzOqem2frFsJh0Yzu9UH1ZaH7KUfDvQlih8aYWqZh7VPKCTVXycB
	 sw34ttIzrFWiQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/3/19 11:45 AM, Christoph Hellwig wrote:
> Switch the one remaining user in nouveau over to its replacement,
> and remove all the wrappers.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   drivers/gpu/drm/nouveau/nouveau_dmem.c |  2 +-
>   include/linux/hmm.h                    | 34 --------------------------
>   2 files changed, 1 insertion(+), 35 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> index 42c026010938..b9ced2e61667 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> @@ -844,7 +844,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
>   		struct page *page;
>   		uint64_t addr;
>   
> -		page = hmm_pfn_to_page(range, range->pfns[i]);
> +		page = hmm_device_entry_to_page(range, range->pfns[i]);
>   		if (page == NULL)
>   			continue;
>   
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 657606f48796..cdcd78627393 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -290,40 +290,6 @@ static inline uint64_t hmm_device_entry_from_pfn(const struct hmm_range *range,
>   		range->flags[HMM_PFN_VALID];
>   }
>   
> -/*
> - * Old API:
> - * hmm_pfn_to_page()
> - * hmm_pfn_to_pfn()
> - * hmm_pfn_from_page()
> - * hmm_pfn_from_pfn()
> - *
> - * This are the OLD API please use new API, it is here to avoid cross-tree
> - * merge painfullness ie we convert things to new API in stages.
> - */
> -static inline struct page *hmm_pfn_to_page(const struct hmm_range *range,
> -					   uint64_t pfn)
> -{
> -	return hmm_device_entry_to_page(range, pfn);
> -}
> -
> -static inline unsigned long hmm_pfn_to_pfn(const struct hmm_range *range,
> -					   uint64_t pfn)
> -{
> -	return hmm_device_entry_to_pfn(range, pfn);
> -}
> -
> -static inline uint64_t hmm_pfn_from_page(const struct hmm_range *range,
> -					 struct page *page)
> -{
> -	return hmm_device_entry_from_page(range, page);
> -}
> -
> -static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
> -					unsigned long pfn)
> -{
> -	return hmm_device_entry_from_pfn(range, pfn);
> -}
> -
>   /*
>    * Mirroring: how to synchronize device page table with CPU page table.
>    *
> 

