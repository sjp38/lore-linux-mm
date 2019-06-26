Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC10AC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:47:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E07D20665
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:47:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E07D20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 324268E0005; Wed, 26 Jun 2019 17:47:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D4A08E0002; Wed, 26 Jun 2019 17:47:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C37A8E0005; Wed, 26 Jun 2019 17:47:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D569A8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 17:47:52 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id f2so142106plr.0
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 14:47:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HWBA0pfU5Q/PjFWqVioY7S2ZgavT51S4DneL7uc3gtc=;
        b=qKoYYFiLdgIH+w2xR6uDru6BOPq06K93Gnqo67MWMjgdB879zEiYaxjBisQaspLAg7
         oAj5535f4e7gr+jZU6syZOXcNrzEfIuiQwd/IP3tkBgS1cjU3u7Q+c5Upk5gSux00KYV
         ghOVTNhLwRO/wqyyIplts5ei+hIDFo7u5T7Qy8pRCV2FtZbj49STl/Or0Qo9XlMk1tu+
         izW9HwWlryFamgyvtRWqZjvH6ZCmw6FOOrKOZ3UK+MbfiKsGH6WfJh7HzRVbw2EemNOF
         9fyMQ4rPMBsjDseh5xha2lj3ljRAhy52fq00gyoP74wQnVWnUz91FdhNjsZ16p2AmN/e
         9myg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU83FrmnI+w9/NHoKClTpE3pWSOd5LE+OzTK2BPzpny3DMZVIEV
	EXBVXd97bW65LZxqDx6h5UY3LTQ50e9JfrOgDGhzjVJ9K2Xve+8r/NA7BANZRiqxZwr3VAUqFgC
	yPTx1vTgA+OWvIZ4Y+tAzhiCYwUPPMvrZS/IA/rc5Pb9d0nhMLfJoIBm7cBuIYvL5TQ==
X-Received: by 2002:a65:6481:: with SMTP id e1mr151473pgv.408.1561585672444;
        Wed, 26 Jun 2019 14:47:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwK7YVpo4nbELgVOsbSadfXcWKeLZgcGUW0wsVHEp/wimKadA2pRWcnNEDNvYRGkcURk9xS
X-Received: by 2002:a65:6481:: with SMTP id e1mr151428pgv.408.1561585671547;
        Wed, 26 Jun 2019 14:47:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561585671; cv=none;
        d=google.com; s=arc-20160816;
        b=Hbb5qcJ3c6zSYRCss2ooi4C2tEe4/Lth/LcT9+2juP38lYbBAC0ltHdBcQncGZof6q
         8bwTd4ai2VePnt1TCYYwuHwEtvfrOSMjB+u1PVwTw2PP76HWgnfYuvs1ibg8hPMl1czn
         1DbZCCL/G6FpbPcQWgldIYcR1jqvcjzbcA8Y9bM01rT738USwJtrmWgMqIt6d4Z/d5XJ
         qp9nRYug7zmCyI+dGJQHxSfqpCCijfL9sjsqm6GWd7m9Pz64iRNb1FJuGqlunWMITWj3
         ic6shrE5bxPHTPC5E82G8P+Akr/LkQnktyZf4a61S0OFkM03fwPWW5gbakq5LFaHz0s0
         at2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HWBA0pfU5Q/PjFWqVioY7S2ZgavT51S4DneL7uc3gtc=;
        b=L//cDQV1RyKdnTatRgoEZnn2k4883Seud6afjKQgkxJOtxpdOIBgtce8gJDlijf8oF
         n9XbERvUsuFtrMN8O7bIlsAznmXLbNBt66TJpqK4ASG6MX9iY4Sy6Bskrbd7pShHxvKh
         lOCaQXvZe420jDjH7Fw8AwowQziPnkUYDahVaRHf3JFOoriAJq1i4ESX/rLCZwAAokHu
         QVR7dSYcfpKyV019P5OjcQq0TOF3KR2vM51oXzvy+//pacK7AU41KU4i5/XktyLMNbbk
         dmLwOiwin0jAt2mjpJn7Ig+77seAmitu2LFS4WIIpWw6zkccIrOWpZ8BvqoA7dsYiS2s
         rC0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id h11si194636pgq.170.2019.06.26.14.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 14:47:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 14:47:51 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,421,1557212400"; 
   d="scan'208";a="162409132"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 26 Jun 2019 14:47:50 -0700
Date: Wed, 26 Jun 2019 14:47:50 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [PATCH 15/25] memremap: provide an optional internal refcount in
 struct dev_pagemap
Message-ID: <20190626214750.GC8399@iweiny-DESK2.sc.intel.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-16-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626122724.13313-16-hch@lst.de>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:14PM +0200, Christoph Hellwig wrote:
> Provide an internal refcounting logic if no ->ref field is provided
> in the pagemap passed into devm_memremap_pages so that callers don't
> have to reinvent it poorly.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/memremap.h          |  4 ++
>  kernel/memremap.c                 | 64 ++++++++++++++++++++++++-------
>  tools/testing/nvdimm/test/iomap.c | 58 ++++++++++++++++++++++------
>  3 files changed, 101 insertions(+), 25 deletions(-)
> 
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index e25685b878e9..f8a5b2a19945 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -95,6 +95,8 @@ struct dev_pagemap_ops {
>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
>   * @res: physical address range covered by @ref
>   * @ref: reference count that pins the devm_memremap_pages() mapping
> + * @internal_ref: internal reference if @ref is not provided by the caller
> + * @done: completion for @internal_ref
>   * @dev: host device of the mapping for debug
>   * @data: private data pointer for page_free()
>   * @type: memory type: see MEMORY_* in memory_hotplug.h
> @@ -105,6 +107,8 @@ struct dev_pagemap {
>  	struct vmem_altmap altmap;
>  	struct resource res;
>  	struct percpu_ref *ref;
> +	struct percpu_ref internal_ref;
> +	struct completion done;
>  	struct device *dev;
>  	enum memory_type type;
>  	unsigned int flags;
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index eee490e7d7e1..bea6f887adad 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -29,7 +29,7 @@ static void devmap_managed_enable_put(void *data)
>  
>  static int devmap_managed_enable_get(struct device *dev, struct dev_pagemap *pgmap)
>  {
> -	if (!pgmap->ops->page_free) {
> +	if (!pgmap->ops || !pgmap->ops->page_free) {
>  		WARN(1, "Missing page_free method\n");
>  		return -EINVAL;
>  	}
> @@ -75,6 +75,24 @@ static unsigned long pfn_next(unsigned long pfn)
>  #define for_each_device_pfn(pfn, map) \
>  	for (pfn = pfn_first(map); pfn < pfn_end(map); pfn = pfn_next(pfn))
>  
> +static void dev_pagemap_kill(struct dev_pagemap *pgmap)
> +{
> +	if (pgmap->ops && pgmap->ops->kill)
> +		pgmap->ops->kill(pgmap);
> +	else
> +		percpu_ref_kill(pgmap->ref);
> +}
> +
> +static void dev_pagemap_cleanup(struct dev_pagemap *pgmap)
> +{
> +	if (pgmap->ops && pgmap->ops->cleanup) {
> +		pgmap->ops->cleanup(pgmap);
> +	} else {
> +		wait_for_completion(&pgmap->done);
> +		percpu_ref_exit(pgmap->ref);
> +	}
> +}
> +
>  static void devm_memremap_pages_release(void *data)
>  {
>  	struct dev_pagemap *pgmap = data;
> @@ -84,10 +102,10 @@ static void devm_memremap_pages_release(void *data)
>  	unsigned long pfn;
>  	int nid;
>  
> -	pgmap->ops->kill(pgmap);
> +	dev_pagemap_kill(pgmap);
>  	for_each_device_pfn(pfn, pgmap)
>  		put_page(pfn_to_page(pfn));
> -	pgmap->ops->cleanup(pgmap);
> +	dev_pagemap_cleanup(pgmap);
>  
>  	/* pages are dead and unused, undo the arch mapping */
>  	align_start = res->start & ~(SECTION_SIZE - 1);
> @@ -114,20 +132,29 @@ static void devm_memremap_pages_release(void *data)
>  		      "%s: failed to free all reserved pages\n", __func__);
>  }
>  
> +static void dev_pagemap_percpu_release(struct percpu_ref *ref)
> +{
> +	struct dev_pagemap *pgmap =
> +		container_of(ref, struct dev_pagemap, internal_ref);
> +
> +	complete(&pgmap->done);
> +}
> +
>  /**
>   * devm_memremap_pages - remap and provide memmap backing for the given resource
>   * @dev: hosting device for @res
>   * @pgmap: pointer to a struct dev_pagemap
>   *
>   * Notes:
> - * 1/ At a minimum the res, ref and type and ops members of @pgmap must be
> - *    initialized by the caller before passing it to this function
> + * 1/ At a minimum the res and type members of @pgmap must be initialized
> + *    by the caller before passing it to this function
>   *
>   * 2/ The altmap field may optionally be initialized, in which case
>   *    PGMAP_ALTMAP_VALID must be set in pgmap->flags.
>   *
> - * 3/ pgmap->ref must be 'live' on entry and will be killed and reaped
> - *    at devm_memremap_pages_release() time, or if this routine fails.
> + * 3/ The ref field may optionally be provided, in which pgmap->ref must be
> + *    'live' on entry and will be killed and reaped at
> + *    devm_memremap_pages_release() time, or if this routine fails.
>   *
>   * 4/ res is expected to be a host memory range that could feasibly be
>   *    treated as a "System RAM" range, i.e. not a device mmio range, but
> @@ -175,10 +202,21 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  		break;
>  	}
>  
> -	if (!pgmap->ref || !pgmap->ops || !pgmap->ops->kill ||
> -	    !pgmap->ops->cleanup) {
> -		WARN(1, "Missing reference count teardown definition\n");
> -		return ERR_PTR(-EINVAL);
> +	if (!pgmap->ref) {
> +		if (pgmap->ops && (pgmap->ops->kill || pgmap->ops->cleanup))
> +			return ERR_PTR(-EINVAL);
> +
> +		init_completion(&pgmap->done);
> +		error = percpu_ref_init(&pgmap->internal_ref,
> +				dev_pagemap_percpu_release, 0, GFP_KERNEL);
> +		if (error)
> +			return ERR_PTR(error);
> +		pgmap->ref = &pgmap->internal_ref;
> +	} else {
> +		if (!pgmap->ops || !pgmap->ops->kill || !pgmap->ops->cleanup) {
> +			WARN(1, "Missing reference count teardown definition\n");
> +			return ERR_PTR(-EINVAL);
> +		}

After this series are there any users who continue to supply their own
reference object and these callbacks?

As it stands:

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

>  	}
>  
>  	if (need_devmap_managed) {
> @@ -296,8 +334,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>   err_pfn_remap:
>  	pgmap_array_delete(res);
>   err_array:
> -	pgmap->ops->kill(pgmap);
> -	pgmap->ops->cleanup(pgmap);
> +	dev_pagemap_kill(pgmap);
> +	dev_pagemap_cleanup(pgmap);
>  	return ERR_PTR(error);
>  }
>  EXPORT_SYMBOL_GPL(devm_memremap_pages);
> diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
> index 82f901569e06..cd040b5abffe 100644
> --- a/tools/testing/nvdimm/test/iomap.c
> +++ b/tools/testing/nvdimm/test/iomap.c
> @@ -100,26 +100,60 @@ static void nfit_test_kill(void *_pgmap)
>  {
>  	struct dev_pagemap *pgmap = _pgmap;
>  
> -	WARN_ON(!pgmap || !pgmap->ref || !pgmap->ops || !pgmap->ops->kill ||
> -		!pgmap->ops->cleanup);
> -	pgmap->ops->kill(pgmap);
> -	pgmap->ops->cleanup(pgmap);
> +	WARN_ON(!pgmap || !pgmap->ref);
> +
> +	if (pgmap->ops && pgmap->ops->kill)
> +		pgmap->ops->kill(pgmap);
> +	else
> +		percpu_ref_kill(pgmap->ref);
> +
> +	if (pgmap->ops && pgmap->ops->cleanup) {
> +		pgmap->ops->cleanup(pgmap);
> +	} else {
> +		wait_for_completion(&pgmap->done);
> +		percpu_ref_exit(pgmap->ref);
> +	}
> +}
> +
> +static void dev_pagemap_percpu_release(struct percpu_ref *ref)
> +{
> +	struct dev_pagemap *pgmap =
> +		container_of(ref, struct dev_pagemap, internal_ref);
> +
> +	complete(&pgmap->done);
>  }
>  
>  void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  {
> +	int error;
>  	resource_size_t offset = pgmap->res.start;
>  	struct nfit_test_resource *nfit_res = get_nfit_res(offset);
>  
> -	if (nfit_res) {
> -		int rc;
> -
> -		rc = devm_add_action_or_reset(dev, nfit_test_kill, pgmap);
> -		if (rc)
> -			return ERR_PTR(rc);
> -		return nfit_res->buf + offset - nfit_res->res.start;
> +	if (!nfit_res)
> +		return devm_memremap_pages(dev, pgmap);
> +
> +	pgmap->dev = dev;
> +	if (!pgmap->ref) {
> +		if (pgmap->ops && (pgmap->ops->kill || pgmap->ops->cleanup))
> +			return ERR_PTR(-EINVAL);
> +
> +		init_completion(&pgmap->done);
> +		error = percpu_ref_init(&pgmap->internal_ref,
> +				dev_pagemap_percpu_release, 0, GFP_KERNEL);
> +		if (error)
> +			return ERR_PTR(error);
> +		pgmap->ref = &pgmap->internal_ref;
> +	} else {
> +		if (!pgmap->ops || !pgmap->ops->kill || !pgmap->ops->cleanup) {
> +			WARN(1, "Missing reference count teardown definition\n");
> +			return ERR_PTR(-EINVAL);
> +		}
>  	}
> -	return devm_memremap_pages(dev, pgmap);
> +
> +	error = devm_add_action_or_reset(dev, nfit_test_kill, pgmap);
> +	if (error)
> +		return ERR_PTR(error);
> +	return nfit_res->buf + offset - nfit_res->res.start;
>  }
>  EXPORT_SYMBOL_GPL(__wrap_devm_memremap_pages);
>  
> -- 
> 2.20.1
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

