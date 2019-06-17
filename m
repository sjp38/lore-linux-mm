Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45DF8C46477
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:10:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 049052085A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:10:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 049052085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB8F78E0004; Mon, 17 Jun 2019 16:10:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A698B8E0001; Mon, 17 Jun 2019 16:10:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 957B68E0004; Mon, 17 Jun 2019 16:10:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75DD98E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:10:19 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id j18so13398722ioj.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:10:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=kggqsXrvr+Hue0NwHkAqIj7QYKap6gNW2dH4cC6BIbo=;
        b=WGiD/ylV8vd+Qw7DeQk/2hg2i4cu5//uCCtXqgBphEdq4sdOrqDbXBJbHJKyZ783Xr
         kyofEXEzkbFpFp+NWD+AYZyuMGAx5C1Bhoh5r26at9xpBVU7RCh7akTTbyJHxt+BxDJb
         63EfMHgZ+N5h6oeEuHJy7+xOCLvCiw//IAD/oKi8mvGsi7otaV3xTuYR1KUlhD0lWIYx
         pu0ZjpOyO8Yf0dr+QcJCVgbloKze1yspt7mrW0qA6bYfXF7YH7FnYOoByWLE614zv4QM
         yIHa/LN9v6HgkgcbcvQ4aCKz95F4rJjiIAva6foxoWXVSZ4S5W7a/7jJZ6r0fUMt/eJ8
         z8wg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAVdrue9JBgWpnzspKq8bBjvjXt72JcJ+VWoaQzX7+Sc0TWkno7i
	TLIkYBNisKAxW8dhXsTPttCL0MkFkVdEhVAdWB9S0x+W49xsBOtlQGPxoqyySoHknM8Tijas14l
	zly//1olQYyD1UQcO8uhUHZCDkp78Z3XhCI8nc203tLhbANYUl3ZE0jNmh7+k98GEIA==
X-Received: by 2002:a6b:2c96:: with SMTP id s144mr61240017ios.57.1560802219198;
        Mon, 17 Jun 2019 13:10:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTrKBTGbBTKmBZDmIHSfY9r43Qn5S2mkxOEvbt1wD3zrCdgenvgeVFWI0BwEYnjY9nnsay
X-Received: by 2002:a6b:2c96:: with SMTP id s144mr61239955ios.57.1560802218500;
        Mon, 17 Jun 2019 13:10:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560802218; cv=none;
        d=google.com; s=arc-20160816;
        b=0Q5QwFxgLMFfs8zYQQCW0JCkYMh03tdL1ZVr4qOMzrFPB3GN412l8T/ba10QkCmqjS
         gqhUtmMMfBV+UkK5jTt57UvXr9FnUeHn+dYckuOBvQaL4ELRHlgJMCjjJM2z01DPYAUq
         Hqpc9fOjzAoZNBJZDxanrwA7A9kSLestz/DAqMSB0wxFrRooawJfQF97Z0eB4jKKbVxW
         PiIlD/SBADa8kKXOdYfddiLe9aGs0OtvgM6LY/9eNcuAIrjB2S9ZwEFXDwIbeWc99lZC
         cr2Yn0yKwDQ3CXGb2/UTXADUC+z3JNAWbFloak5RAatMnz6qS+2UThLrH+JhHFSBuL+/
         wARg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=kggqsXrvr+Hue0NwHkAqIj7QYKap6gNW2dH4cC6BIbo=;
        b=MozX0kCuudrFU2rY4R/JIxOEmJ1zVSlAfgjPFvZgOiyTSd87NqxmEo3E2tlNuZGg0Y
         rF4XAVi28x7fuitCW4gHzV2izbZJ5+xOUv3ucuGmR1I1u0aNen1BqVjPlVNVs4cjK2H1
         WNyxAhY46yWkADwJc6mwCErCly5ffVKrxZZ09aN9tYMNOazMoGjK6cLJQGU3ZP2asnp3
         /vSaOrtPZ2P8YQknKI9q5VHNW+i+Vq2ha8ri9VaVrzC/5q6xFOk1v6m/om95WJkMQv8M
         4PU+QH8Gcqu8drwULRDFL+VY721TGcWC1cm8QSa5k9Fu26q8/ttp9FZkSGL7VxgGftzY
         dZGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id i82si17075973ioa.57.2019.06.17.13.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jun 2019 13:10:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1hcxxI-0004rl-Iq; Mon, 17 Jun 2019 14:10:17 -0600
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
Cc: linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
 linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org, nouveau@lists.freedesktop.org
References: <20190617122733.22432-1-hch@lst.de>
 <20190617122733.22432-17-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <e404fb0b-4ed8-34bb-7df8-9b59cb760f53@deltatee.com>
Date: Mon, 17 Jun 2019 14:10:16 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190617122733.22432-17-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: nouveau@lists.freedesktop.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-nvdimm@lists.01.org, bskeggs@redhat.com, jgg@mellanox.com, jglisse@redhat.com, dan.j.williams@intel.com, hch@lst.de
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [PATCH 16/25] PCI/P2PDMA: use the dev_pagemap internal refcount
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-06-17 6:27 a.m., Christoph Hellwig wrote:
> The functionality is identical to the one currently open coded in
> p2pdma.c.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

I also did a quick test with the full patch-set to ensure that the setup
and tear down paths for p2pdma still work correctly and it all does.

Thanks,

Logan

> ---
>  drivers/pci/p2pdma.c | 56 ++++----------------------------------------
>  1 file changed, 4 insertions(+), 52 deletions(-)
> 
> diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
> index 48a88158e46a..608f84df604a 100644
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
> @@ -194,22 +156,12 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
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
> @@ -223,7 +175,7 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  	error = gen_pool_add_owner(pdev->p2pdma->pool, (unsigned long)addr,
>  			pci_bus_address(pdev, bar) + offset,
>  			resource_size(&pgmap->res), dev_to_node(&pdev->dev),
> -			&p2p_pgmap->ref);
> +			pgmap->ref);
>  	if (error)
>  		goto pages_free;
>  
> @@ -235,7 +187,7 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  pages_free:
>  	devm_memunmap_pages(&pdev->dev, pgmap);
>  pgmap_free:
> -	devm_kfree(&pdev->dev, p2p_pgmap);
> +	devm_kfree(&pdev->dev, pgmap);
>  	return error;
>  }
>  EXPORT_SYMBOL_GPL(pci_p2pdma_add_resource);
> 

