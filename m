Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6461BC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:46:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 161F3217F9
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:46:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 161F3217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A3A66B000E; Fri, 14 Jun 2019 12:45:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 953A26B0266; Fri, 14 Jun 2019 12:45:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 843BF6B0269; Fri, 14 Jun 2019 12:45:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C71B6B000E
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:45:59 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j36so2252313pgb.20
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:45:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Yd9vMoglfAKCP7yxtTBnCz+dwMWDgekPGEWqIOKDh/0=;
        b=LIUIpsLIIEUWhhk3bCEUo56Kq0PVMZ/VfGzxxbXO/SDyODAqBvY59LWkdHvmuzoqf8
         kkvVGSk+Ts6QdNm452T5A+EeOXHXfN9DeAM3fkuqiqCxrEAljjlCleLjTV2r0IJnnsUN
         4QXrERDxCSKtkuaDNXsjd2WV1qiRc+uglCUbMnpMhE+N5yoNYnifpNijW96TfqfUCQKN
         uO5G5BGXwk6Zxj6a9/EuQS4uobQwK2mkRzoo/65wf0sI9I/Aiu+AYT/LwjXKZx315dE2
         NQO0l29qJnMBdOASLDKdDWReQIPlD9cYLbcLnuFHRzl66Afi044Xms7zNCFGg86mFwUK
         27ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of ville.syrjala@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ville.syrjala@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUa2xgY/MJ5RaNgk7HmBfWDBAwF41LSQs20JvMbMnf+tT8CG1Y5
	b9EwpC61lkNk67Q2a+X2iChViLX/MTmTiLYLXQ8Z1FysZbvBAAAa2nXB/WOvQHERUAwExbMUEKo
	ibW+R59Q586hJI786mHSfU3LxIzGx8g6C/PUUADiQGg59r3zyFkwY1enU6IBeS79O6Q==
X-Received: by 2002:a17:902:b70f:: with SMTP id d15mr12763813pls.318.1560530758944;
        Fri, 14 Jun 2019 09:45:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQg2oYQQx0h3dzKNKWl7wbznD2cgK2nh5a3Ht8eqYx5J62HjzVVs98JeoZOQ4yAFPXfHs9
X-Received: by 2002:a17:902:b70f:: with SMTP id d15mr12763755pls.318.1560530758111;
        Fri, 14 Jun 2019 09:45:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560530758; cv=none;
        d=google.com; s=arc-20160816;
        b=0AWzoQMapi4ij++gfrI0b3scjFxpIrLNKdKe5wA2CDew6ZlzUqDShwk7SYcn/bSx3w
         OxuCfIO66/9f5bHZsQn9K62Tgv8Yrr1XKdC2d8vQe4ztDtaimAQkEvP6KEe4I3C+2g7a
         YApriDZQ7SbQMsigfYQcFsTh9FlChQiXV10x+27teU4FaflhP1cwk6Dt8OBpfNrQc4u/
         sUXtepsVQ9kQ89RuB36yQ6+5+h1N1+O8jVdOBxzxS90yUYI/vquwk/GXeUCJ8ghWi4VY
         ZHG/fZKMtoxvTVl8GxH/dGTT1AiXNFiQv512dK2Be49yYmE0NJ4SSkhLGQEt5Z4Qj4Jg
         2TYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Yd9vMoglfAKCP7yxtTBnCz+dwMWDgekPGEWqIOKDh/0=;
        b=qWVhGWZjbmb2COQ5WXQQFyQmeWsLAY7bCAS917UKRRiPhIFH8BAbJ5tOWqY4AkUcO7
         JroVAIku6UvtCoCEfrJD6VR7NaXxBcA/2jc6EH6Xm+7ILutTO7HQcFwF6oQH0bZX+vnv
         2vMO238CsedwlDGzX8zVRg4xbwI5yEV9nD/u/wjEYjNbIEJu8PNMmgRJrM+BjQhOLFlv
         rPkBgSpPs4r6z+k32ykv+1siBsjxJr9rqzm+ttPwvilAFLzUTbf35gYJ7NZiZ9mjeIpJ
         Udee/fs3pm2RwwRtiGtUlHo7MsiFrFgwgCY7QLVIkY+BeV5/ECTGBPZkrIRVL+fGedf6
         NiQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of ville.syrjala@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ville.syrjala@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id v23si2652488plo.34.2019.06.14.09.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 09:45:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of ville.syrjala@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of ville.syrjala@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ville.syrjala@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 09:45:57 -0700
X-ExtLoop1: 1
Received: from stinkbox.fi.intel.com (HELO stinkbox) ([10.237.72.174])
  by fmsmga007.fm.intel.com with SMTP; 14 Jun 2019 09:45:50 -0700
Received: by stinkbox (sSMTP sendmail emulation); Fri, 14 Jun 2019 19:45:49 +0300
Date: Fri, 14 Jun 2019 19:45:49 +0300
From: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	intel-gfx@lists.freedesktop.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	linux-media@vger.kernel.org,
	Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [Intel-gfx] [PATCH 03/16] drm/i915: stop using drm_pci_alloc
Message-ID: <20190614164549.GD5942@intel.com>
References: <20190614134726.3827-1-hch@lst.de>
 <20190614134726.3827-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190614134726.3827-4-hch@lst.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 03:47:13PM +0200, Christoph Hellwig wrote:
> Remove usage of the legacy drm PCI DMA wrappers, and with that the
> incorrect usage cocktail of __GFP_COMP, virt_to_page on DMA allocation
> and SetPageReserved.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/gpu/drm/i915/i915_gem.c        | 30 +++++++++++++-------------
>  drivers/gpu/drm/i915/i915_gem_object.h |  3 ++-
>  drivers/gpu/drm/i915/intel_display.c   |  2 +-
>  3 files changed, 18 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
> index ad01c92aaf74..8f2053c91aff 100644
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -228,7 +228,6 @@ i915_gem_get_aperture_ioctl(struct drm_device *dev, void *data,
>  static int i915_gem_object_get_pages_phys(struct drm_i915_gem_object *obj)
>  {
>  	struct address_space *mapping = obj->base.filp->f_mapping;
> -	drm_dma_handle_t *phys;
>  	struct sg_table *st;
>  	struct scatterlist *sg;
>  	char *vaddr;
> @@ -242,13 +241,13 @@ static int i915_gem_object_get_pages_phys(struct drm_i915_gem_object *obj)
>  	 * to handle all possible callers, and given typical object sizes,
>  	 * the alignment of the buddy allocation will naturally match.
>  	 */
> -	phys = drm_pci_alloc(obj->base.dev,
> -			     roundup_pow_of_two(obj->base.size),
> -			     roundup_pow_of_two(obj->base.size));
> -	if (!phys)
> +	obj->phys_vaddr = dma_alloc_coherent(&obj->base.dev->pdev->dev,
> +			roundup_pow_of_two(obj->base.size),
> +			&obj->phys_handle, GFP_KERNEL);
> +	if (!obj->phys_vaddr)
>  		return -ENOMEM;
>  
> -	vaddr = phys->vaddr;
> +	vaddr = obj->phys_vaddr;
>  	for (i = 0; i < obj->base.size / PAGE_SIZE; i++) {
>  		struct page *page;
>  		char *src;
> @@ -286,18 +285,17 @@ static int i915_gem_object_get_pages_phys(struct drm_i915_gem_object *obj)
>  	sg->offset = 0;
>  	sg->length = obj->base.size;
>  
> -	sg_dma_address(sg) = phys->busaddr;
> +	sg_dma_address(sg) = obj->phys_handle;
>  	sg_dma_len(sg) = obj->base.size;
>  
> -	obj->phys_handle = phys;
> -
>  	__i915_gem_object_set_pages(obj, st, sg->length);
>  
>  	return 0;
>  
>  err_phys:
> -	drm_pci_free(obj->base.dev, phys);
> -
> +	dma_free_coherent(&obj->base.dev->pdev->dev,
> +			roundup_pow_of_two(obj->base.size), obj->phys_vaddr,
> +			obj->phys_handle);

Need to undo the damage to obj->phys_vaddr here since
i915_gem_pwrite_ioctl() will now use that to determine if it's
dealing with a phys obj.

>  	return err;
>  }
>  
> @@ -335,7 +333,7 @@ i915_gem_object_put_pages_phys(struct drm_i915_gem_object *obj,
>  
>  	if (obj->mm.dirty) {
>  		struct address_space *mapping = obj->base.filp->f_mapping;
> -		char *vaddr = obj->phys_handle->vaddr;
> +		char *vaddr = obj->phys_vaddr;
>  		int i;
>  
>  		for (i = 0; i < obj->base.size / PAGE_SIZE; i++) {
> @@ -363,7 +361,9 @@ i915_gem_object_put_pages_phys(struct drm_i915_gem_object *obj,
>  	sg_free_table(pages);
>  	kfree(pages);
>  
> -	drm_pci_free(obj->base.dev, obj->phys_handle);
> +	dma_free_coherent(&obj->base.dev->pdev->dev,
> +			roundup_pow_of_two(obj->base.size), obj->phys_vaddr,
> +			obj->phys_handle);

This one is fine I think since the object remains a phys obj once
turned into one. At least the current code isn't clearing
phys_handle here. But my memory is a bit hazy on the details. Chris?

Also maybe s/phys_handle/phys_busaddr/ all over?

>  }
>  
>  static void
> @@ -603,7 +603,7 @@ i915_gem_phys_pwrite(struct drm_i915_gem_object *obj,
>  		     struct drm_i915_gem_pwrite *args,
>  		     struct drm_file *file)
>  {
> -	void *vaddr = obj->phys_handle->vaddr + args->offset;
> +	void *vaddr = obj->phys_vaddr + args->offset;
>  	char __user *user_data = u64_to_user_ptr(args->data_ptr);
>  
>  	/* We manually control the domain here and pretend that it
> @@ -1431,7 +1431,7 @@ i915_gem_pwrite_ioctl(struct drm_device *dev, void *data,
>  		ret = i915_gem_gtt_pwrite_fast(obj, args);
>  
>  	if (ret == -EFAULT || ret == -ENOSPC) {
> -		if (obj->phys_handle)
> +		if (obj->phys_vaddr)
>  			ret = i915_gem_phys_pwrite(obj, args, file);
>  		else
>  			ret = i915_gem_shmem_pwrite(obj, args);
> diff --git a/drivers/gpu/drm/i915/i915_gem_object.h b/drivers/gpu/drm/i915/i915_gem_object.h
> index ca93a40c0c87..14bd2d61d0f6 100644
> --- a/drivers/gpu/drm/i915/i915_gem_object.h
> +++ b/drivers/gpu/drm/i915/i915_gem_object.h
> @@ -290,7 +290,8 @@ struct drm_i915_gem_object {
>  	};
>  
>  	/** for phys allocated objects */
> -	struct drm_dma_handle *phys_handle;
> +	dma_addr_t phys_handle;
> +	void *phys_vaddr;
>  
>  	struct reservation_object __builtin_resv;
>  };
> diff --git a/drivers/gpu/drm/i915/intel_display.c b/drivers/gpu/drm/i915/intel_display.c
> index 5098228f1302..4f8b368ac4e2 100644
> --- a/drivers/gpu/drm/i915/intel_display.c
> +++ b/drivers/gpu/drm/i915/intel_display.c
> @@ -10066,7 +10066,7 @@ static u32 intel_cursor_base(const struct intel_plane_state *plane_state)
>  	u32 base;
>  
>  	if (INTEL_INFO(dev_priv)->display.cursor_needs_physical)
> -		base = obj->phys_handle->busaddr;
> +		base = obj->phys_handle;
>  	else
>  		base = intel_plane_ggtt_offset(plane_state);
>  
> -- 
> 2.20.1
> 
> _______________________________________________
> Intel-gfx mailing list
> Intel-gfx@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/intel-gfx

-- 
Ville Syrjälä
Intel

