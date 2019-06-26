Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B7DFC48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:49:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A4F1216FD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:49:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A4F1216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9162E8E0007; Wed, 26 Jun 2019 17:49:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C6118E0002; Wed, 26 Jun 2019 17:49:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B46F8E0007; Wed, 26 Jun 2019 17:49:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 43B7B8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 17:49:07 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s22so137778plp.5
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 14:49:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/J6yM+3W7BrpB9z1xcA3LCZqego3IUnku47XqmaXpsA=;
        b=Lf6FhfRjJiKDVhE9vqQ0Ycc0nKOxohp0YM7VaJe06NgXChUmSGnnp5huj2WYce/i7d
         TEDbeCJB53dVUcOan8lqmNd+mQ/ly7Oel/6wRROk6sXef4/VL/5o1lx3jxg5ek2zhUrc
         IjG/klLXekGY1G7/sIRtWXEad4A1LeRSJ7PHqGRpPO0Ijna4adVkGsLMzHdFh1c4KCCf
         z1x1TmUmnbVXucGD9UMefqyMlJXy0NRVsVhjLntYAfEnv08fJJbROcpoTaUc4TQ1QfOS
         sD0xaTzRoB/5qGrSFhXqbD0+s2aBepJ8r6BStgOI/NYB/yjK5fwX6bVbDyT0Ol4Z7/Fp
         Hjrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV2MxVjskyiDhnMwxC9a+XjZTu2DqEaQU5Ha5zuu99o0+SlqjUA
	AzofTT8TL0MJP6DC+o4OdWcdl/hG76uEs3DJAFAAjVt0kPvms1XVs1XUgltvzQ+coT6rToP8vgO
	WeouqPLX6vN6FZxjVW7fqnnXVas5Px7+c2EA5roHU447irc2U0G/5Nn0koKUxEOHCOg==
X-Received: by 2002:a63:fb4b:: with SMTP id w11mr117257pgj.415.1561585746851;
        Wed, 26 Jun 2019 14:49:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx74cpcNOh5Td7CVlbJVHhgP2h1FLsE7oDSzi3TpBLW9BHnNI5nGnwSREKl4ZhjO2v1Im1t
X-Received: by 2002:a63:fb4b:: with SMTP id w11mr117213pgj.415.1561585746111;
        Wed, 26 Jun 2019 14:49:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561585746; cv=none;
        d=google.com; s=arc-20160816;
        b=foI4nFjfH3kWLAeH0VjZLKUz0x2iZNiroojJ2RdywC72vOrLOw6lxNIUjWNhJTzElq
         2Lco37UgZqplJveD4IP8UNV4HsyAjIcWgT8EwOcJdhs079KoPFU3AxgzLjEe56q/LITv
         INtFNF8hJL5tSCZWd8fh+N6wBtK6Xs8Tcn4dq3L4xWbok+9DyS5+rBvFWbnIAAUKHKJT
         3/3tXUK2WJ/kZ3e6NGmoqy+tP4n0OW/oq0clfLQh57YGUup+v2zQIwuh4m18TLYH+npg
         OVwllxe3nl5SCVNxa0Dpo2BCxSPa6FnftF945zlXwk5XChLGEifGgwOcdymqqQNKbi+V
         N3pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/J6yM+3W7BrpB9z1xcA3LCZqego3IUnku47XqmaXpsA=;
        b=zOZOuCHnQ3mgEAkq+bhh7Jt83iE1x40CexjLgsmD5TlOZkaqUh/8d2HYsyKkgqBAsY
         G7ld8A6S2Wkln0To94g54GNFZ3L0rLO2QTvy7Jf95wckvibuNB+mPwpXCGbmLz5YjgYU
         RQk+vH17nf/WAY/FlpYONrw6Ud9cU+OelkGaoEqnh0ntGh7wkARtItDgWbyOQAemriD5
         19boYMwJm59gfLBHmRTTfFqhjHaN+dTKPwNkVcIBtbvv3QlmgFa82e1zBHmKk8zpTA1e
         yoPWvf0eTsYw0sHElSz/qEOqOd60Qk6zVwU0odHUqV2Yaoykr3zUy/cWE32WAvbYrT1l
         OI3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f7si162711pgr.536.2019.06.26.14.49.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 14:49:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 14:49:05 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,421,1557212400"; 
   d="scan'208";a="164492176"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 26 Jun 2019 14:49:04 -0700
Date: Wed, 26 Jun 2019 14:49:04 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [PATCH 17/25] PCI/P2PDMA: use the dev_pagemap internal refcount
Message-ID: <20190626214903.GE8399@iweiny-DESK2.sc.intel.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-18-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626122724.13313-18-hch@lst.de>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:16PM +0200, Christoph Hellwig wrote:
> The functionality is identical to the one currently open coded in
> p2pdma.c.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

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
> -- 
> 2.20.1
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

