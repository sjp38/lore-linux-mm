Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DCE2C48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:01:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D65EF208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:01:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D65EF208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 701EF6B0003; Wed, 26 Jun 2019 14:01:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B37A8E0003; Wed, 26 Jun 2019 14:01:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A1768E0002; Wed, 26 Jun 2019 14:01:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 21E1B6B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 14:01:25 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 65so1844457plf.16
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 11:01:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=svik35W1NsukDvVLNPgzFfv/q3RAdnN3kBobIhH3TrU=;
        b=GuYPeQpHNrsYCeIZoOKEqZfxhYbcw6PVo+FjPJpJOU7hX1htV4MXQG6/e75/B2VVB3
         O8ylXvFOFizJsSOHTZo0zP15kWhFbXaIaNZT20WJmO0isLDUlML0/fiZb9XGOtBQ/DkF
         XGYQVkMBeN+YuR5pHbtArjyW0JTWxLU241wBrfu2OHwNZss4yImfCrd+RHicye9Tfsy0
         uQD/6YL683puW9MnEtF3vH+Tf9EtdQ4DboclLwlnGJD+8F7meXKgwpAIAZ9UVtE0sUmh
         0lJXZVQ4UoYE3oXdjiFwQ3TuVctLnV2cLPSboVA9QGejWJFA1VzkQIpF37Gjq0nAUhpi
         nICg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVQTkOu7vcVHYTo5BnG8JgtIUMLp1DE2A55S+MrEY8fjGtDXgL1
	LVDwtB4PggKKBs9mdHyGlADtAeJuHUQwgfiJMoMAjhLgclpyxZAjLKcGkx8O/jhOVZqInxoZcV8
	EiP3ijOHc0W6aky22X6K/w+C+W3D84y5/OE6dkkx1o3Na8oiiAA/M4piAPEQ9wkQosQ==
X-Received: by 2002:a17:90a:8c92:: with SMTP id b18mr355895pjo.97.1561572084616;
        Wed, 26 Jun 2019 11:01:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9IsrcrSHzcxKbveeCC5x7+GTjW1r5XCYdCx/GwlU5xKhhqSzZocJUSx1ln4uDwAzWfy/p
X-Received: by 2002:a17:90a:8c92:: with SMTP id b18mr355814pjo.97.1561572083679;
        Wed, 26 Jun 2019 11:01:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561572083; cv=none;
        d=google.com; s=arc-20160816;
        b=0BNd6wZfOPUQrTTX94W6vUD8e0fF8rlI0YauxqEB83Psi/cSw+efsOXEPDoWQtY272
         GGPODTgOsZt0AJjzx5iov+Su/QGBvi1RE/2wLfEyf2R8iUsPSMIGPHYHpKLlgvBxB47Q
         6Pd9ukYV6xt5T9z+bDes4iTGnMnuYDmQGR0KVU95V15GxlM9QmukwSApF7KWq6BxfWIx
         Fiw72qEMLIaPzWk+43MeaOQEEwLB1ursTSXA2rprrPJFFlCSey/TyEs2fMNRllNssKGe
         RC7KcFb/B8DuAFZS7shJvvDBWU/JU38iRtAz0JkyALWUpP7MxJkOobwDWExOn2IwNtfB
         O49g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=svik35W1NsukDvVLNPgzFfv/q3RAdnN3kBobIhH3TrU=;
        b=0N0XuJSRRPeAqBz/Uv+g41yW82+SF48nHKp8eER/5PDpBsF9AHv5rAWWFKZm5HJ7Sq
         ALSI4uJVr2aQY7tlIgZv8JXIqxWMa3IKQaZ5sTiAlWQxlodTgMUFYkG96Qmm4KVI7f24
         hb5kIDhO6nDf2KpxnWm34/PrztIB3CIf/m5xZrGyWMN6w09AuwgyhHttrXekh0Iu2mjS
         UjaF5Kmh71386tZOk7AQHNhiae8+oX7NLFPSywrC9DahMTjCmelSLnnx2miuFpnIXp3b
         o2CN9i814oEov07Blgy9PuNZpJZaCL4tV0/uRD5LkEjeMtCn2XFk9Ea/HF8WumKwpEGD
         V1Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l24si4775014pff.185.2019.06.26.11.01.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 11:01:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 11:01:23 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,420,1557212400"; 
   d="scan'208";a="164032950"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 26 Jun 2019 11:01:22 -0700
Date: Wed, 26 Jun 2019 11:01:22 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [PATCH 08/25] memremap: validate the pagemap type passed to
 devm_memremap_pages
Message-ID: <20190626180122.GB4605@iweiny-DESK2.sc.intel.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626122724.13313-9-hch@lst.de>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:07PM +0200, Christoph Hellwig wrote:
> Most pgmap types are only supported when certain config options are
> enabled.  Check for a type that is valid for the current configuration
> before setting up the pagemap.  For this the usage of the 0 type for
> device dax gets replaced with an explicit MEMORY_DEVICE_DEVDAX type.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  drivers/dax/device.c     |  1 +
>  include/linux/memremap.h |  8 ++++++++
>  kernel/memremap.c        | 22 ++++++++++++++++++++++
>  3 files changed, 31 insertions(+)
> 
> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> index 8465d12fecba..79014baa782d 100644
> --- a/drivers/dax/device.c
> +++ b/drivers/dax/device.c
> @@ -468,6 +468,7 @@ int dev_dax_probe(struct device *dev)
>  	dev_dax->pgmap.ref = &dev_dax->ref;
>  	dev_dax->pgmap.kill = dev_dax_percpu_kill;
>  	dev_dax->pgmap.cleanup = dev_dax_percpu_exit;
> +	dev_dax->pgmap.type = MEMORY_DEVICE_DEVDAX;
>  	addr = devm_memremap_pages(dev, &dev_dax->pgmap);
>  	if (IS_ERR(addr))
>  		return PTR_ERR(addr);
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 995c62c5a48b..0c86f2c5ac9c 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -45,13 +45,21 @@ struct vmem_altmap {
>   * wakeup is used to coordinate physical address space management (ex:
>   * fs truncate/hole punch) vs pinned pages (ex: device dma).
>   *
> + * MEMORY_DEVICE_DEVDAX:
> + * Host memory that has similar access semantics as System RAM i.e. DMA
> + * coherent and supports page pinning. In contrast to
> + * MEMORY_DEVICE_FS_DAX, this memory is access via a device-dax
> + * character device.
> + *
>   * MEMORY_DEVICE_PCI_P2PDMA:
>   * Device memory residing in a PCI BAR intended for use with Peer-to-Peer
>   * transactions.
>   */
>  enum memory_type {
> +	/* 0 is reserved to catch uninitialized type fields */
>  	MEMORY_DEVICE_PRIVATE = 1,
>  	MEMORY_DEVICE_FS_DAX,
> +	MEMORY_DEVICE_DEVDAX,
>  	MEMORY_DEVICE_PCI_P2PDMA,
>  };
>  
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 6e1970719dc2..abda62d1e5a3 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -157,6 +157,28 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  	pgprot_t pgprot = PAGE_KERNEL;
>  	int error, nid, is_ram;
>  
> +	switch (pgmap->type) {
> +	case MEMORY_DEVICE_PRIVATE:
> +		if (!IS_ENABLED(CONFIG_DEVICE_PRIVATE)) {
> +			WARN(1, "Device private memory not supported\n");
> +			return ERR_PTR(-EINVAL);
> +		}
> +		break;
> +	case MEMORY_DEVICE_FS_DAX:
> +		if (!IS_ENABLED(CONFIG_ZONE_DEVICE) ||
> +		    IS_ENABLED(CONFIG_FS_DAX_LIMITED)) {
> +			WARN(1, "File system DAX not supported\n");
> +			return ERR_PTR(-EINVAL);
> +		}
> +		break;
> +	case MEMORY_DEVICE_DEVDAX:
> +	case MEMORY_DEVICE_PCI_P2PDMA:
> +		break;
> +	default:
> +		WARN(1, "Invalid pgmap type %d\n", pgmap->type);
> +		break;
> +	}
> +
>  	if (!pgmap->ref || !pgmap->kill || !pgmap->cleanup) {
>  		WARN(1, "Missing reference count teardown definition\n");
>  		return ERR_PTR(-EINVAL);
> -- 
> 2.20.1
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

