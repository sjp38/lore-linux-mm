Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCEA8C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:36:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B546216FD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:36:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B546216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B37E6B0003; Wed, 26 Jun 2019 17:36:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 463608E0003; Wed, 26 Jun 2019 17:36:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32BBC8E0002; Wed, 26 Jun 2019 17:36:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0B996B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 17:36:23 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b24so100722plz.20
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 14:36:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fajVDXKdpxIWIkT+4kVYimpOdEgfRYqcc2E8pLafSSo=;
        b=dfg9zelKVMUgui6OyXK6Ld4x2H4Q5rF8Yl6TI1WAOJoQEQQ1SJT7PMvTkZ6hS0P4S9
         vKQowpxHYyPVRie69rTXEUUuObLuuIEDO6iWMD8jVMEnNf+ZI4XLKPhYFsnWdlFNjHbc
         fc1bZfcYTVh9ySn07PksnO+PKHqGYGMMTnxRbTS0SDCK9roppGh1KctO+VzXNLXiQd5w
         10K/pixINr0P1PiRMgJOGWvLe8qfK9EoKoF3NmNN/geImI6RvNwgTWo9reUvtf32bi+s
         PovGDec2t0TkoCk/CAlcTTh4GHhpAOXHY3hEcbcrizh/or7xYjoMOpfkV5u2PtC8bX4/
         DGSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVY6j7lpQb5hmoQ+gmQamq6YLegfZxzW0Is7XMtNbjYJW3Ix2FW
	NXhmlxPXjemeDglDTTu3L3xRxjUzy9smZF11+W4PjlzZGlxgDHrVJGJA528WHVF2f6m8CAeZLTo
	mfiu4V/9qqwYkHDAcvmWCLUjB0i1WCMSHgDnIBfQ+a5jx12uGPha+aJwEPhIjvnGwbw==
X-Received: by 2002:a63:455c:: with SMTP id u28mr119902pgk.416.1561584983425;
        Wed, 26 Jun 2019 14:36:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDtibBhtEJzMEZXJL9fwpsdBur8i/1M7bHxaapg2XsrX5UjZ+gw+JBVowk0wOGRM8OFvjR
X-Received: by 2002:a63:455c:: with SMTP id u28mr119831pgk.416.1561584982220;
        Wed, 26 Jun 2019 14:36:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561584982; cv=none;
        d=google.com; s=arc-20160816;
        b=LmHmSDC/N6HXrdo03oFA0I0yr0PAXBungq0p6EiFmNkQaZinSOJe5e4FNnQKLOJiBw
         fQw2zdlAHaKUlBWsstAYx9IvR8VrInIPzvIgzXN4/FesqZNIqaHghkEv+J6H9CFc9HKr
         Rn7UOVXDMEBNXaVRKukQ2l42IFTTQ5IKu2DtuYsiPUshY9r0CYuleAnQAIKAQNiJdvzC
         pHiewAzi+Iq1ducJy1nY+MhnXdCYBANNb4XO+jz0ObIEn0Qa/9zWxxlCPa+kezri3+pV
         Neq1fvhmitDQOd0u3E/k7k3njL47GrS0ANasfuZtK5EZGNaNh+FS3m1XBBhtYeDHV6g+
         s41Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fajVDXKdpxIWIkT+4kVYimpOdEgfRYqcc2E8pLafSSo=;
        b=nXwvPkd6f90SHAKCRLZWgYcgOyk40q9O2lBCTtEtdrxoulF0fkVqxMYYhF2aomFcE0
         yraTYdYxQ+Ka2VZzx030y+D3vLgJ/zj/2X5Xz1s66ls7igOdo/QA3MbUHmEFnVAR8945
         jVWNFxYvqDqH1zwHdsLWd+voOFDJs35KP5l7rXbEG0NbC6B8nk9NQzOeTxurOZnj9mp7
         DhtlzGiuwQzAqArcSrzwHN3G7pk62Ks+5fOvUFAJBCIX8tRUjHwkPJdinIEiu5k0GRjD
         N93elsWJpUQ6ei18v7Pmwnf3pF+5BUcpGBm26X81KjR/RE9Nnxs7KrT0+yFs9LF2JQp3
         T2KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g2si291089plp.1.2019.06.26.14.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 14:36:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 14:36:21 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,421,1557212400"; 
   d="scan'208";a="360890792"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga006.fm.intel.com with ESMTP; 26 Jun 2019 14:36:21 -0700
Date: Wed, 26 Jun 2019 14:36:21 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 23/25] mm: sort out the DEVICE_PRIVATE Kconfig mess
Message-ID: <20190626213620.GA8399@iweiny-DESK2.sc.intel.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-24-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626122724.13313-24-hch@lst.de>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:22PM +0200, Christoph Hellwig wrote:
> The ZONE_DEVICE support doesn't depend on anything HMM related, just on
> various bits of arch support as indicated by the architecture.  Also
> don't select the option from nouveau as it isn't present in many setups,
> and depend on it instead.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  drivers/gpu/drm/nouveau/Kconfig | 2 +-
>  mm/Kconfig                      | 5 ++---
>  2 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
> index dba2613f7180..6303d203ab1d 100644
> --- a/drivers/gpu/drm/nouveau/Kconfig
> +++ b/drivers/gpu/drm/nouveau/Kconfig
> @@ -85,10 +85,10 @@ config DRM_NOUVEAU_BACKLIGHT
>  config DRM_NOUVEAU_SVM
>  	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
>  	depends on ARCH_HAS_HMM
> +	depends on DEVICE_PRIVATE
>  	depends on DRM_NOUVEAU
>  	depends on STAGING
>  	select HMM_MIRROR
> -	select DEVICE_PRIVATE
>  	default n
>  	help
>  	  Say Y here if you want to enable experimental support for
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 6f35b85b3052..eecf037a54b3 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -677,13 +677,13 @@ config ARCH_HAS_HMM_MIRROR
>  
>  config ARCH_HAS_HMM
>  	bool
> -	default y
>  	depends on (X86_64 || PPC64)
>  	depends on ZONE_DEVICE
>  	depends on MMU && 64BIT
>  	depends on MEMORY_HOTPLUG
>  	depends on MEMORY_HOTREMOVE
>  	depends on SPARSEMEM_VMEMMAP
> +	default y
>  
>  config MIGRATE_VMA_HELPER
>  	bool
> @@ -709,8 +709,7 @@ config HMM_MIRROR
>  
>  config DEVICE_PRIVATE
>  	bool "Unaddressable device memory (GPU memory, ...)"
> -	depends on ARCH_HAS_HMM
> -	select HMM
> +	depends on ZONE_DEVICE
>  	select DEV_PAGEMAP_OPS
>  
>  	help
> -- 
> 2.20.1
> 

