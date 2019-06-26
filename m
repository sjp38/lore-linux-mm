Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D501CC48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:48:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93AB820656
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:48:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93AB820656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34AD88E0006; Wed, 26 Jun 2019 17:48:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FA848E0002; Wed, 26 Jun 2019 17:48:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C3548E0006; Wed, 26 Jun 2019 17:48:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D88BC8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 17:48:25 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s195so38864pgs.13
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 14:48:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2CMZicb0w5xhua+jFN0mV4WCy1W1G/plgZFdEFNJpgI=;
        b=Itx+uGK8UOKQ2smlS2A84GOhAwetXOex7FHQ1S0DB9bc+mCuud97AKEcVOJCkbexAg
         kVmvMaxh56KzTtGAjVWI5aK/hlRDlEZer6KJ36DblJUkN9M0WWav6SRDw+p/tZ5F4mt6
         bluiEnSuNwBvT1zBfkKFebBYYAGQAic08uu6co95ku1H6i23Wl0A5s0oLALA79lGVpLf
         TC/SbVj/QdYvV7YCE6mm+nOIJYWAakwuLzUlJURI+cGDYGsKR6LPoQmK7R5XNoc+we0X
         Wkc0K54LjA6mHyaoSMnK935NtN2jCx/4hkX+KocmLoG4odSCFgT1gneyWrjRpLISw6Dn
         /ALQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXaFRJfXKBXxE/PyRahKhHfV4NyUoOiBy/muI+pBacNB2LSjcfj
	/+NzqPvplnQUIx4JiQo0lF9btPScDWiVmwpcW8RjEyArnLpZkP+cxtllyGcJ1o97Sjd/n3xY/W8
	mH9RD8VU3I9ouTDo7aNAGnSZCrl3P37gvLqE3JK6hJ1gDXImGbbICPElb9mirBpIh3A==
X-Received: by 2002:a63:db4b:: with SMTP id x11mr167438pgi.254.1561585705411;
        Wed, 26 Jun 2019 14:48:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhJMxyy/wiIg1RSdnM5PYcGm+z9QSrb2DFlmMhSoy/Im9piNokt4/S9zU5OnCeKADWQ9pM
X-Received: by 2002:a63:db4b:: with SMTP id x11mr167406pgi.254.1561585704686;
        Wed, 26 Jun 2019 14:48:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561585704; cv=none;
        d=google.com; s=arc-20160816;
        b=OThO2DoO+H8KvZQ81mKakqlmpSuCeds3QgV2oYhDcae7CbsX8SnWozpvo3wXktvL4+
         g2vznUlz8mqIjZ1Lq4Ug77UKi3f7bnJnqH0mjs80HrCooVjmOTo26zgqhdxOoWlTlvQ9
         3gSJ1e01trP+y/k5pE8VUHPArLq3lryvmcoyVuyHFkxw8BYZdQNoceat6c2yUz1cryDA
         JSroLM3pobnVcAUxqeNHWsHtOi3rrBt+eE6uLhldrEl2JdNhDQ4WGP4Aai9HbZ/qocSF
         JgNNpXh8+NXRIHjDh4TSh0a9fsvO4xh7PPo4ANPXafeDD1ZJ7xV1IE50Fs55UEu/cCh3
         Bh3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2CMZicb0w5xhua+jFN0mV4WCy1W1G/plgZFdEFNJpgI=;
        b=DihR6XaEjSz04YpsNQ/LPGziM1OwihHI5NXdoSfAz3Wpjkfq9rUZMH18vzzFQj3+b9
         Ki3HBgW+hGLEtxdK304AUSKK9aHY3ECvHR+u3A6wWmczvWQ4QRfH4NUVnewDV7qURVeS
         JXlVGVnkGPFlXa1s8ikqPuZJYTl6Q6YYpDRhRe6vYr9GfpXXGdU7rJfj8LFT1EuKYTLf
         v5c87LXzPgEWO/kbAHlUd1/NeWOjWOsQtQrZPJD1dTvymWbTvBeQLeplsgGaswF6T8NF
         oE4gY0d6sv7KZ4+yzNJh+v173EIH5Bv4Ke7AJrmPqKs0uRuKwIzpEbI1lAWoyAPawfPH
         yGaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 62si334117pff.216.2019.06.26.14.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 14:48:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 14:48:24 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,421,1557212400"; 
   d="scan'208";a="183267604"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 26 Jun 2019 14:48:23 -0700
Date: Wed, 26 Jun 2019 14:48:23 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
Message-ID: <20190626214823.GD8399@iweiny-DESK2.sc.intel.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-17-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626122724.13313-17-hch@lst.de>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:15PM +0200, Christoph Hellwig wrote:
> The functionality is identical to the one currently open coded in
> device-dax.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  drivers/dax/dax-private.h |  4 ----
>  drivers/dax/device.c      | 43 ---------------------------------------
>  2 files changed, 47 deletions(-)
> 
> diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
> index b4177aafbbd1..c915889d1769 100644
> --- a/drivers/dax/dax-private.h
> +++ b/drivers/dax/dax-private.h
> @@ -43,8 +43,6 @@ struct dax_region {
>   * @target_node: effective numa node if dev_dax memory range is onlined
>   * @dev - device core
>   * @pgmap - pgmap for memmap setup / lifetime (driver owned)
> - * @ref: pgmap reference count (driver owned)
> - * @cmp: @ref final put completion (driver owned)
>   */
>  struct dev_dax {
>  	struct dax_region *region;
> @@ -52,8 +50,6 @@ struct dev_dax {
>  	int target_node;
>  	struct device dev;
>  	struct dev_pagemap pgmap;
> -	struct percpu_ref ref;
> -	struct completion cmp;
>  };
>  
>  static inline struct dev_dax *to_dev_dax(struct device *dev)
> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> index b5257038c188..1af823b2fe6b 100644
> --- a/drivers/dax/device.c
> +++ b/drivers/dax/device.c
> @@ -14,36 +14,6 @@
>  #include "dax-private.h"
>  #include "bus.h"
>  
> -static struct dev_dax *ref_to_dev_dax(struct percpu_ref *ref)
> -{
> -	return container_of(ref, struct dev_dax, ref);
> -}
> -
> -static void dev_dax_percpu_release(struct percpu_ref *ref)
> -{
> -	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
> -
> -	dev_dbg(&dev_dax->dev, "%s\n", __func__);
> -	complete(&dev_dax->cmp);
> -}
> -
> -static void dev_dax_percpu_exit(struct dev_pagemap *pgmap)
> -{
> -	struct dev_dax *dev_dax = container_of(pgmap, struct dev_dax, pgmap);
> -
> -	dev_dbg(&dev_dax->dev, "%s\n", __func__);
> -	wait_for_completion(&dev_dax->cmp);
> -	percpu_ref_exit(pgmap->ref);
> -}
> -
> -static void dev_dax_percpu_kill(struct dev_pagemap *pgmap)
> -{
> -	struct dev_dax *dev_dax = container_of(pgmap, struct dev_dax, pgmap);
> -
> -	dev_dbg(&dev_dax->dev, "%s\n", __func__);
> -	percpu_ref_kill(pgmap->ref);
> -}
> -
>  static int check_vma(struct dev_dax *dev_dax, struct vm_area_struct *vma,
>  		const char *func)
>  {
> @@ -441,11 +411,6 @@ static void dev_dax_kill(void *dev_dax)
>  	kill_dev_dax(dev_dax);
>  }
>  
> -static const struct dev_pagemap_ops dev_dax_pagemap_ops = {
> -	.kill		= dev_dax_percpu_kill,
> -	.cleanup	= dev_dax_percpu_exit,
> -};
> -
>  int dev_dax_probe(struct device *dev)
>  {
>  	struct dev_dax *dev_dax = to_dev_dax(dev);
> @@ -463,15 +428,7 @@ int dev_dax_probe(struct device *dev)
>  		return -EBUSY;
>  	}
>  
> -	init_completion(&dev_dax->cmp);
> -	rc = percpu_ref_init(&dev_dax->ref, dev_dax_percpu_release, 0,
> -			GFP_KERNEL);
> -	if (rc)
> -		return rc;
> -
> -	dev_dax->pgmap.ref = &dev_dax->ref;
>  	dev_dax->pgmap.type = MEMORY_DEVICE_DEVDAX;
> -	dev_dax->pgmap.ops = &dev_dax_pagemap_ops;
>  	addr = devm_memremap_pages(dev, &dev_dax->pgmap);
>  	if (IS_ERR(addr))
>  		return PTR_ERR(addr);
> -- 
> 2.20.1
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

