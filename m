Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61C4AC48BE4
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:49:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2ACE5208E3
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:49:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2ACE5208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCDE86B0003; Thu, 27 Jun 2019 14:49:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7F718E0003; Thu, 27 Jun 2019 14:49:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6C098E0002; Thu, 27 Jun 2019 14:49:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 880576B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:49:56 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id h3so3592351iob.20
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 11:49:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=6K6g+obhxWmhbEx3WhFMIJ4bLzgnM3IuGyXdgFEaFJY=;
        b=Iml2olj76xXiQrwTOKVcIjg6zyx+i0aOdHAsqbOUnlXNQejdGwXvkiKcnNAMis8xfK
         aZ8uPxqonmZzDRqVVJB62AlWvMNOESxpCnvabjL1GVXp8t8kdJ46n3Fc3eQyFzHgrsr2
         lFSwQurDeuuwUf5Icixd6cPxXf7mjhbBZnmlk4Ocyk6lZMd/5ndphUqIYpYhKpWpAikc
         vc3u/WJd0HBSz3Cv0d1nnww+skXHhpSZtC0JQPJWntnkCSBZIR94v4YMw1//lX5XLTsS
         08B5SYDjf2Iura+pF2APbAd2JnGKGlYiQSLiQDJsuoDnhEgSo1ZbkKcg5HhmAD6s/cw3
         RkVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAXhQnwUfnmFssL0+I0lkqPuS3NQSShrAq9y/u89qdE4MDNm6CbW
	/fyo2bSezZnUT1a3Z83yK5UJr3lY6UelLCzxLswm8Ia7dAx63+VvneRYR3gJMaNk0RRJ9Nj4iHR
	PSbS+dTX6D0rZh/XsHFm5Seoznk/LExhh/klU0/1dCdmHDpB+Mf1fVAmp4OCmH/cITQ==
X-Received: by 2002:a6b:3b03:: with SMTP id i3mr6309767ioa.302.1561661396302;
        Thu, 27 Jun 2019 11:49:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuQdOpE6aOFlJQ3mI98/gxziio7Pmz0A4bMfRuoychqkar0rer3ckE2LHJduad4kCwrfs+
X-Received: by 2002:a6b:3b03:: with SMTP id i3mr6309712ioa.302.1561661395605;
        Thu, 27 Jun 2019 11:49:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561661395; cv=none;
        d=google.com; s=arc-20160816;
        b=pwSWxtKYlPM/Npvl/1Mt52s7/jo5DWMvLGDha7nhs3Zl3qAinyCaJlm1xtnSNV+LWs
         6KJcoilh0ayqRZEC1yQZfVUwYxAgOiB+3J3SnKWalP1orFIWIQrKdeCWzFxHsEcBjAuw
         2MCdrRnXaTpbpqFXPJdmpiaZ+FMkLz+SAgcEXKWVxJjtR9KN2jCyQixFFi1dVYbd6OSu
         KfZDSFmfFhkpFHkZ7XC9CkHRSrDJf4XzVMmFSQ3bcOols4S3zK0uECWw7w4QD0XKhAMN
         9cQ/RLSykpve8INyDPpH1XJiZF9K5FHFjioprPBBfOTHtl4KeQ+u08nW2+k3DUtdMZit
         Hp+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=6K6g+obhxWmhbEx3WhFMIJ4bLzgnM3IuGyXdgFEaFJY=;
        b=nx6asmD3DIAAUt7guzazhZwAlrB8TEGRmrcBgC8vZYMgzKPrzpSNqON0N+s91x/jI8
         U5COUqtyJ7sRGWSPQhRdCP0Ic4phBGtXxg+Qjgt0i+n9fabSbHiAOZITB1OYXcN7Iyxy
         kX/K5PR1Q0VBicZBPJpcfPtD9UhNYz9iNRUGCaM+oR5gk8GoDzgb5xGYPuoJhTFvoYXX
         ZEc8PxoGWVJN2myxCP46dOmZfPOg1ZcAtnv8lgmrg9/ekUulDs4ZbzU5VxeqCXUWkVGG
         6bX+gj7yWn2eISaxedoFJEpJiRWmM1i6gCik0Do27QlIMAFHyz7vILIbJJc5L+Qplq+H
         O62A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id i10si799949iol.68.2019.06.27.11.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jun 2019 11:49:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.132])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1hgZSz-0004rJ-D3; Thu, 27 Jun 2019 12:49:54 -0600
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
Cc: linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
 linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org, nouveau@lists.freedesktop.org
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-18-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <580609fd-5ef2-bae4-e8f8-adc1eb0314a1@deltatee.com>
Date: Thu, 27 Jun 2019 12:49:47 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190626122724.13313-18-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 68.147.80.180
X-SA-Exim-Rcpt-To: nouveau@lists.freedesktop.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-nvdimm@lists.01.org, bskeggs@redhat.com, jgg@mellanox.com, jglisse@redhat.com, dan.j.williams@intel.com, hch@lst.de
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [PATCH 17/25] PCI/P2PDMA: use the dev_pagemap internal refcount
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-06-26 6:27 a.m., Christoph Hellwig wrote:
> The functionality is identical to the one currently open coded in
> p2pdma.c.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

Also, for the P2PDMA changes in this series:

Tested-by: Logan Gunthorpe <logang@deltatee.com>

I've ran this series through my simple P2PDMA tests.

Logan

> ---
>  drivers/pci/p2pdma.c | 57 ++++----------------------------------------
>  1 file changed, 4 insertions(+), 53 deletions(-)
> 
> diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
> index ebd8ce3bba2e..608f84df604a 100644
> --- a/drivers/pci/p2pdma.c
> +++ b/drivers/pci/p2pdma.c
> @@ -24,12 +24,6 @@ struct pci_p2pdma {
>  	bool p2pmem_published;
>  };
>  
> -struct p2pdma_pagemap {
> -	struct dev_pagemap pgmap;
> -	struct percpu_ref ref;
> -	struct completion ref_done;
> -};
> -
>  static ssize_t size_show(struct device *dev, struct device_attribute *attr,
>  			 char *buf)
>  {
> @@ -78,32 +72,6 @@ static const struct attribute_group p2pmem_group = {
>  	.name = "p2pmem",
>  };
>  
> -static struct p2pdma_pagemap *to_p2p_pgmap(struct percpu_ref *ref)
> -{
> -	return container_of(ref, struct p2pdma_pagemap, ref);
> -}
> -
> -static void pci_p2pdma_percpu_release(struct percpu_ref *ref)
> -{
> -	struct p2pdma_pagemap *p2p_pgmap = to_p2p_pgmap(ref);
> -
> -	complete(&p2p_pgmap->ref_done);
> -}
> -
> -static void pci_p2pdma_percpu_kill(struct dev_pagemap *pgmap)
> -{
> -	percpu_ref_kill(pgmap->ref);
> -}
> -
> -static void pci_p2pdma_percpu_cleanup(struct dev_pagemap *pgmap)
> -{
> -	struct p2pdma_pagemap *p2p_pgmap =
> -		container_of(pgmap, struct p2pdma_pagemap, pgmap);
> -
> -	wait_for_completion(&p2p_pgmap->ref_done);
> -	percpu_ref_exit(&p2p_pgmap->ref);
> -}
> -
>  static void pci_p2pdma_release(void *data)
>  {
>  	struct pci_dev *pdev = data;
> @@ -153,11 +121,6 @@ static int pci_p2pdma_setup(struct pci_dev *pdev)
>  	return error;
>  }
>  
> -static const struct dev_pagemap_ops pci_p2pdma_pagemap_ops = {
> -	.kill		= pci_p2pdma_percpu_kill,
> -	.cleanup	= pci_p2pdma_percpu_cleanup,
> -};
> -
>  /**
>   * pci_p2pdma_add_resource - add memory for use as p2p memory
>   * @pdev: the device to add the memory to
> @@ -171,7 +134,6 @@ static const struct dev_pagemap_ops pci_p2pdma_pagemap_ops = {
>  int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  			    u64 offset)
>  {
> -	struct p2pdma_pagemap *p2p_pgmap;
>  	struct dev_pagemap *pgmap;
>  	void *addr;
>  	int error;
> @@ -194,26 +156,15 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  			return error;
>  	}
>  
> -	p2p_pgmap = devm_kzalloc(&pdev->dev, sizeof(*p2p_pgmap), GFP_KERNEL);
> -	if (!p2p_pgmap)
> +	pgmap = devm_kzalloc(&pdev->dev, sizeof(*pgmap), GFP_KERNEL);
> +	if (!pgmap)
>  		return -ENOMEM;
> -
> -	init_completion(&p2p_pgmap->ref_done);
> -	error = percpu_ref_init(&p2p_pgmap->ref,
> -			pci_p2pdma_percpu_release, 0, GFP_KERNEL);
> -	if (error)
> -		goto pgmap_free;
> -
> -	pgmap = &p2p_pgmap->pgmap;
> -
>  	pgmap->res.start = pci_resource_start(pdev, bar) + offset;
>  	pgmap->res.end = pgmap->res.start + size - 1;
>  	pgmap->res.flags = pci_resource_flags(pdev, bar);
> -	pgmap->ref = &p2p_pgmap->ref;
>  	pgmap->type = MEMORY_DEVICE_PCI_P2PDMA;
>  	pgmap->pci_p2pdma_bus_offset = pci_bus_address(pdev, bar) -
>  		pci_resource_start(pdev, bar);
> -	pgmap->ops = &pci_p2pdma_pagemap_ops;
>  
>  	addr = devm_memremap_pages(&pdev->dev, pgmap);
>  	if (IS_ERR(addr)) {
> @@ -224,7 +175,7 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  	error = gen_pool_add_owner(pdev->p2pdma->pool, (unsigned long)addr,
>  			pci_bus_address(pdev, bar) + offset,
>  			resource_size(&pgmap->res), dev_to_node(&pdev->dev),
> -			&p2p_pgmap->ref);
> +			pgmap->ref);
>  	if (error)
>  		goto pages_free;
>  
> @@ -236,7 +187,7 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  pages_free:
>  	devm_memunmap_pages(&pdev->dev, pgmap);
>  pgmap_free:
> -	devm_kfree(&pdev->dev, p2p_pgmap);
> +	devm_kfree(&pdev->dev, pgmap);
>  	return error;
>  }
>  EXPORT_SYMBOL_GPL(pci_p2pdma_add_resource);
> 

