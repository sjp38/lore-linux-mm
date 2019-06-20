Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2900FC48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:32:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1C922083B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:32:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1C922083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 819598E0005; Thu, 20 Jun 2019 15:32:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C8E98E0001; Thu, 20 Jun 2019 15:32:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 692328E0005; Thu, 20 Jun 2019 15:32:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19B808E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 15:32:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i44so5648652eda.3
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:32:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TZPO+BciIG/h5YjiBR5gjrouvInSnuhq+sBkKrqdDX4=;
        b=M7v7J+hoQZE2lGoj7FT1PSDU99ZjJ2t32knUuAOuAl4CRdiizFBdCwCrd77WPmdLh0
         s+vBP41nOox8B2qoq/EI/90NHwrMQ1mfiDTBLO5Wyf2umfqgib/ZpgsxbfBC3D+QS8LH
         moEQpg+CMhmqWI3/03Ixsm4wqPp+Fp+KVFkFDXcdCWVeK4MIdbjPFLp5BMoBvWHk1/6V
         oWjpFXHzg6bcUf+Dq+1F5rHAZXYF8WOkL5KRU+nfteYPJgv6uNxk5MZHfF+EdeST0tUK
         f0eyfUv3bEceQlCV6jqpEHND8t92DxwtqN8ptywrc6meO/zTtmVdR1TU7aAjaevwzbzt
         U48g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXDc3GVjYbI8KAsYpO/d+MUhlnxQX50t1IMoS3kByft273Zk9I2
	ef3WybXxqCoBU4Xa6MGHFAm8MJxnvSfm+jJU5qUMJ5eNAfoa+AUPTk24nlL4xxWzFU5WdAVKR6l
	3cqNlC3rmSe3Cm/7zqFXWx7f6K5YkRSuBUZ8W51362RQzsa4FkhZtMfEQqbopezs=
X-Received: by 2002:aa7:cfd3:: with SMTP id r19mr11226384edy.102.1561059163664;
        Thu, 20 Jun 2019 12:32:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQJie5EoKSEFqiOlytUFfMqCw4jdyzHOZKvlFivSIbiIrBKOEVtHYh85LH7jKw3DWg2LBF
X-Received: by 2002:aa7:cfd3:: with SMTP id r19mr11226333edy.102.1561059162990;
        Thu, 20 Jun 2019 12:32:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561059162; cv=none;
        d=google.com; s=arc-20160816;
        b=bo8PVHWXgVnB6NGXRpKrIGZeDNQ5PQiIpg0lQ4g9HuFHnQ7TGo5cbTTUVOj3jHsLSa
         D/xj8aaVpgcKNJSDMsvy63eVVan9SSPyXPNoH7Oavc8FS8J/Z+Nc/33fL2Jz8Bc86VCk
         /ixMvh6DdNem9Z1aDMkbMPsalhuyd5hi3LKC/1ibotL/CMlHSdny7RIV9jmdl39vAuzg
         xdc2uoKKPou+uZQYK9rU67eFpE6Uz15Fh/+PGFEL+fS/FHyppsgJZ8xxo8qQfS1UH2JL
         nrEjKq6OlhRGxbCqRhhNwabbslBbMh7ZEo0nBuwmkAJxsvAGfdpUZpSfrhbcye+L0BWF
         vUMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TZPO+BciIG/h5YjiBR5gjrouvInSnuhq+sBkKrqdDX4=;
        b=a5grwAujSYaV8A08jEK04GxoHiZ3DIIqcvPfndCvL1ytU3eEb9m44c7P4OdZJBS07S
         ggQzcVrhbP4sPXMTCuNjc9Ijs0CzQJHWG16hEP1nx0PYQNHuc8im+k08/IcY1tCukJ2Z
         szjMBdPpgC5hvi0Ji+rm23ZnZx7zzx3DOcFmgKokJo/DKH09Sk0NCy1aphcOuz/Fz26a
         7mLMGq11Ehf6epTDCaQeU0lBDSzjNouOB/A6yJQL/3dcwMFSepvhEHi+b3XwrTljgaN8
         CjmBJJ1m8bpZYPO3Ay6/S5IYktT2OABW4fBY4GqEYLDOR97YRTpuLyVRJuJ0SWEeLjrT
         F1Fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si354805ejj.268.2019.06.20.12.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 12:32:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 21B8DAC9A;
	Thu, 20 Jun 2019 19:32:42 +0000 (UTC)
Date: Thu, 20 Jun 2019 21:32:41 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 03/22] mm: remove hmm_devmem_add_resource
Message-ID: <20190620193241.GJ12083@dhcp22.suse.cz>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613094326.24093-4-hch@lst.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 13-06-19 11:43:06, Christoph Hellwig wrote:
> This function has never been used since it was first added to the kernel
> more than a year and a half ago, and if we ever grow a consumer of the
> MEMORY_DEVICE_PUBLIC infrastructure it can easily use devm_memremap_pages
> directly now that we've simplified the API for it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/hmm.h |  3 ---
>  mm/hmm.c            | 54 ---------------------------------------------
>  2 files changed, 57 deletions(-)
> 
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
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

