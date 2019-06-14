Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B463C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:54:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3761021537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:54:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="msD87jcA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3761021537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0DDB6B000D; Thu, 13 Jun 2019 20:54:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABF696B000E; Thu, 13 Jun 2019 20:54:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 985B96B0266; Thu, 13 Jun 2019 20:54:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 773C96B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:54:09 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id v15so1111095ybe.13
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:54:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=oaghaGhc6k9hrZ1Hrvf1WRHivvtYUvtzqZie9Kkvs/o=;
        b=iJO4dVjnHifUu/+gen/jU0u6k6qprXYchYLO7WuaQ+BnSALe31hUuEx7XMGQTwvrvX
         uKo+T836/KPIDim4h0Hh4OAVO+Q89vBlkpt7pKe07j42WDICHiaCYlC5B0bmrKj6o3zF
         Qd8uYrEtNTvs3pp/OZdS+hZ4IbpfukU3xYZXrUzfKu2cD2H0u/2Ai19owoRZkrosXiOA
         QSr5xQrgJk3vfFU9/56U+MdYvY0WncOuRW+4DJa1qNJw2JjZCsRlJPcWKBqsUiRfr8QE
         5V8VvvY1dsgmPWP2tLQG00hYzFlhZgqlvPGPnm4EC7ZZuvCrWiMc7rlc4deevsCfj3nu
         54ow==
X-Gm-Message-State: APjAAAXI1KPq9ftZGbJUQaLPx7K8W+DJKvnBc1M9jESub+2vS32aFwbc
	Mbdu5S8A+bewxhiF/MPzMZNqP9NCpHeumOFMH4dQo6AErENtRoMfSqcaNXHhBh7LBSDtZcFsgOs
	16zSl6QOn6BBbOrzU3KwzwNkirLc8oKANsrfYl2t90rdX3tYoCoJS2J9NFeZ8Y4oQ+A==
X-Received: by 2002:a81:5296:: with SMTP id g144mr7645962ywb.378.1560473649222;
        Thu, 13 Jun 2019 17:54:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCcyJU+O+CyNMDgzqSN66C0mXd0Pq6U41GrV6lYTKtL9UBHAAYyWF1dMOmxdTpdZiizHNT
X-Received: by 2002:a81:5296:: with SMTP id g144mr7645942ywb.378.1560473648626;
        Thu, 13 Jun 2019 17:54:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473648; cv=none;
        d=google.com; s=arc-20160816;
        b=AVtF0DJsVJ1PL/QvI0JZOdeoCQjoadaTg/FIovC5lYR7qefht9aWC+c93SoJHAVh4i
         yhqWY28s/fS20eov2Tdcr+yLr3L8HFUCo9PSxJMGNICq1Ko+xOkwcCZtvLtIkYXrQ8En
         RB11+Q9v+n1amyStOwEGZRWUP5bKaJ+E+NdigbCZMEYV9kejrKRAFOCbHv6BxuI1auW9
         5y32/ZWQnAekioqdFkEpoQ55s0+mGPTCgUUHzrNNTepPIDmTqxoSdALIWbRcSGQVNSbk
         yEo3RdGMj25GH9uUC/K673lMheqbkdA/jclJMYqWu0zqxHgjHzrNZ8KnX4Ggbgx76Bm1
         YerA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=oaghaGhc6k9hrZ1Hrvf1WRHivvtYUvtzqZie9Kkvs/o=;
        b=HMR4d9udRIGQQzZDyjIwE38hqZWqF5ZuoQj5gvAcZvOeIqfWXWw5VI40eKcbj8NBUM
         Gmoql9vffojWvRft0UNMaJ0hEDTHwDl1meaIaMQlWjsL4egF87AcunO3Eq4H98h2ufb9
         JAmYe34mkkhXB8a1F7mvOMK1TvDghpih65E1DId6Bn15SfQrhfkkId6SlK6Evsli13KT
         MQUdIDXg6oAeOvB373nOph/5ZYu9JhX0UIKGdIc5NP54OFrjepdn1yw8ZA9KTrfpwaOL
         nfS4ssSwedQONhHpQZWnGG1Bvr3jDi2xNv6AQ79XGU0oGOtxPYUR1W0kaiU9aRSab2c1
         HY3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=msD87jcA;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id v85si525276ywc.58.2019.06.13.17.54.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 17:54:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=msD87jcA;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d02f02f0000>; Thu, 13 Jun 2019 17:54:07 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 13 Jun 2019 17:54:07 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 13 Jun 2019 17:54:07 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 00:54:05 +0000
Subject: Re: [Nouveau] [PATCH 03/22] mm: remove hmm_devmem_add_resource
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
CC: <linux-nvdimm@lists.01.org>, <linux-pci@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-mm@kvack.org>, <nouveau@lists.freedesktop.org>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-4-hch@lst.de>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <b0136e6b-2262-ae4e-67ba-3d0b3895873b@nvidia.com>
Date: Thu, 13 Jun 2019 17:54:05 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190613094326.24093-4-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560473647; bh=oaghaGhc6k9hrZ1Hrvf1WRHivvtYUvtzqZie9Kkvs/o=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=msD87jcA2rRG9Llyq0qt1WMB2QnQwlCA5FboAnD5ObAlNrd0UXGEduqhvkfygikiG
	 X/FDHinicS3Efvg3d57Jm26shPNaEmayltJCp5yJQZZeY/XUAJ9yuE28dJLinUDmst
	 hfPVk2mmuqjWbbXi5PN/lD+bEyQhTU2/HuxvXb4GSlidJB0FuUB3Qbw3dB7EXnopuS
	 70ZHlcNhJG9lxipOFV1GdXLcilcLcloKtFVGyKtsgpsjI+nbjKdhxdsIHIGRCMwhfr
	 h2Uc0N+TEc+StNM9rr5zvfJdDHOGWwk2wBBxonlsQTnl7Sy3RjDibSN0QnbqU2I3p2
	 +mHNjmJsw2lrA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 2:43 AM, Christoph Hellwig wrote:
> This function has never been used since it was first added to the kernel
> more than a year and a half ago, and if we ever grow a consumer of the
> MEMORY_DEVICE_PUBLIC infrastructure it can easily use devm_memremap_pages
> directly now that we've simplified the API for it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/hmm.h |  3 ---
>  mm/hmm.c            | 54 ---------------------------------------------
>  2 files changed, 57 deletions(-)
> 

No objections here, good cleanup.

Reviewed-by: John Hubbard <jhubbard@nvidia.com> 

thanks,
-- 
John Hubbard
NVIDIA

> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 4867b9da1b6c..5761a39221a6 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -688,9 +688,6 @@ struct hmm_devmem {
>  struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
>  				  struct device *device,
>  				  unsigned long size);
> -struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
> -					   struct device *device,
> -					   struct resource *res);
>  
>  /*
>   * hmm_devmem_page_set_drvdata - set per-page driver data field
> diff --git a/mm/hmm.c b/mm/hmm.c
> index ff2598eb7377..0c62426d1257 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -1445,58 +1445,4 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
>  	return devmem;
>  }
>  EXPORT_SYMBOL_GPL(hmm_devmem_add);
> -
> -struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
> -					   struct device *device,
> -					   struct resource *res)
> -{
> -	struct hmm_devmem *devmem;
> -	void *result;
> -	int ret;
> -
> -	if (res->desc != IORES_DESC_DEVICE_PUBLIC_MEMORY)
> -		return ERR_PTR(-EINVAL);
> -
> -	dev_pagemap_get_ops();
> -
> -	devmem = devm_kzalloc(device, sizeof(*devmem), GFP_KERNEL);
> -	if (!devmem)
> -		return ERR_PTR(-ENOMEM);
> -
> -	init_completion(&devmem->completion);
> -	devmem->pfn_first = -1UL;
> -	devmem->pfn_last = -1UL;
> -	devmem->resource = res;
> -	devmem->device = device;
> -	devmem->ops = ops;
> -
> -	ret = percpu_ref_init(&devmem->ref, &hmm_devmem_ref_release,
> -			      0, GFP_KERNEL);
> -	if (ret)
> -		return ERR_PTR(ret);
> -
> -	ret = devm_add_action_or_reset(device, hmm_devmem_ref_exit,
> -			&devmem->ref);
> -	if (ret)
> -		return ERR_PTR(ret);
> -
> -	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
> -	devmem->pfn_last = devmem->pfn_first +
> -			   (resource_size(devmem->resource) >> PAGE_SHIFT);
> -	devmem->page_fault = hmm_devmem_fault;
> -
> -	devmem->pagemap.type = MEMORY_DEVICE_PUBLIC;
> -	devmem->pagemap.res = *devmem->resource;
> -	devmem->pagemap.page_free = hmm_devmem_free;
> -	devmem->pagemap.altmap_valid = false;
> -	devmem->pagemap.ref = &devmem->ref;
> -	devmem->pagemap.data = devmem;
> -	devmem->pagemap.kill = hmm_devmem_ref_kill;
> -
> -	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
> -	if (IS_ERR(result))
> -		return result;
> -	return devmem;
> -}
> -EXPORT_SYMBOL_GPL(hmm_devmem_add_resource);
>  #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
> 

