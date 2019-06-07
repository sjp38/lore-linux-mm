Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4B0FC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:32:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B2FF20673
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:32:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B2FF20673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D47376B0276; Fri,  7 Jun 2019 18:32:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF7726B0278; Fri,  7 Jun 2019 18:32:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE9E96B0279; Fri,  7 Jun 2019 18:32:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86E666B0276
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 18:32:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o12so2211577pll.17
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 15:32:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/PzOH/mhDnUIn9so19dRUio6D2Ow1DDT+jhTy7iyKvw=;
        b=eyqKJi1qNeSVCz0cp6v1qu8R1rg3h4ysz1XRaotThzj1R89bSuSHF82gZv/dDdcpWu
         ecaAIjoOoAai02/gVCVbbVE1VPtUcqLHW5NjuDy2mahhyp/D7XbC+F5xAx8V6EsoTAKr
         6ER0e0hOMLRfJwlwhhYo9Xx6E5gagkNBafN/oghsf2C4JDhumco7T0XgnOu6L0TK4yRO
         /yNpzrsEcn1poN/11mAuNVZDM4gkJJTgdy38lOtzh+fWkteVAfInEN46fIQwPALfmlKW
         mhuudpv6Kef7KZF8J5ezHXDVLSQO4b6T+f1/c2f93Shl/x7f3oiPROscJWzFW0dFYVZw
         Es3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXdpNmmMWIoDl6uaQgICwa4xHp0mfTkL3nx8GZpu2TgexWnTfbF
	TK4cEo1kLcTDrOG34ZjcSLPzcWLqYUCk82yghGEQ187qvfK/n13Mb8/H/Dz4HC0MMMne6XqLPqg
	24jgz9fYIpqiArLrCrf7eZyTTiuFuWS6oXczGJWFGyAP2W7zZ7IYTyJFlgBFfLkSiSw==
X-Received: by 2002:a62:3287:: with SMTP id y129mr5160388pfy.251.1559946733219;
        Fri, 07 Jun 2019 15:32:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoka44Imabf/qxaiMh2qlkXO6T5OqyUm3pw4kLIIw8Xu1KU8K/rmdv/GuU4akIEEcoPlJG
X-Received: by 2002:a62:3287:: with SMTP id y129mr5160332pfy.251.1559946732464;
        Fri, 07 Jun 2019 15:32:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559946732; cv=none;
        d=google.com; s=arc-20160816;
        b=cRKY55GUk3/+esfUHEvUtRjP4B/1Awv7GJVLHIgiQwYUnnr6gkA+Hlznr+nJhFdca0
         YOzxvEXWkAX+OGBIGn909VsmjA/gsoeWfQGUr/iwxIHXVtS8e8NJcj4P2H0WW6ffbE96
         VYlStYroTO7QVWPzmFM/UvT73UlNJyHjaGeT9GuUQ/OBGfKRRNbY2U9CNKUNLxXnnLMX
         iAJcsUxkC4sMntboegWtcYzhANNc5/bqwPWChCqENHyzimOQN2vGRUTlptJV2UVs3KW8
         im6rYxt1PXsR6p0OUSAj+qUCNjcUbilKFzL+bRwQLjoCflVhPzCzTxigwwyG4cHcRCo8
         O7Wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/PzOH/mhDnUIn9so19dRUio6D2Ow1DDT+jhTy7iyKvw=;
        b=ow1GeGr+vmlHy2yJ2sUuc7g6ksGlHwTxatkYt3rMw2hH2ZEzy8r1cSPshJoDVq4Mrj
         ZniteJMPAPe06ZMC6GSF5Hb97x1nuIz8qjeEwoqy/pCe9Oj1ehlCgRa8MLZuw9RR4Ndf
         dFnuf9bf4qDrS+y9uEpZgDcHhd4Awlh2xd1MpHi2JnPNH3CUWijV0qh1WhpSfj1x32ra
         qShu65Tau7FUqvEtcjclstEv4iRbDzFCulLDDY+MhicAJ48CyKhpeNfxyNEGrU9Ywv8D
         NOeTa5M/OUkzzg3LQZ9bxsuGpUr/73r97YgyFEC3KWQZCK9F4j3+AUsUXutj0nPE/bW8
         2k7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s68si3116938pfb.39.2019.06.07.15.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 15:32:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 15:32:11 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga008.jf.intel.com with ESMTP; 07 Jun 2019 15:32:10 -0700
Date: Fri, 7 Jun 2019 15:33:24 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v2 hmm 02/11] mm/hmm: Use hmm_mirror not mm as an
 argument for hmm_range_register
Message-ID: <20190607223324.GD14559@iweiny-DESK2.sc.intel.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-3-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606184438.31646-3-jgg@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 03:44:29PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> Ralph observes that hmm_range_register() can only be called by a driver
> while a mirror is registered. Make this clear in the API by passing in the
> mirror structure as a parameter.
> 
> This also simplifies understanding the lifetime model for struct hmm, as
> the hmm pointer must be valid as part of a registered mirror so all we
> need in hmm_register_range() is a simple kref_get.
> 
> Suggested-by: Ralph Campbell <rcampbell@nvidia.com>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> ---
> v2
> - Include the oneline patch to nouveau_svm.c
> ---
>  drivers/gpu/drm/nouveau/nouveau_svm.c |  2 +-
>  include/linux/hmm.h                   |  7 ++++---
>  mm/hmm.c                              | 15 ++++++---------
>  3 files changed, 11 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
> index 93ed43c413f0bb..8c92374afcf227 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_svm.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
> @@ -649,7 +649,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
>  		range.values = nouveau_svm_pfn_values;
>  		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
>  again:
> -		ret = hmm_vma_fault(&range, true);
> +		ret = hmm_vma_fault(&svmm->mirror, &range, true);
>  		if (ret == 0) {
>  			mutex_lock(&svmm->mutex);
>  			if (!hmm_vma_range_done(&range)) {
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 688c5ca7068795..2d519797cb134a 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -505,7 +505,7 @@ static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
>   * Please see Documentation/vm/hmm.rst for how to use the range API.
>   */
>  int hmm_range_register(struct hmm_range *range,
> -		       struct mm_struct *mm,
> +		       struct hmm_mirror *mirror,
>  		       unsigned long start,
>  		       unsigned long end,
>  		       unsigned page_shift);
> @@ -541,7 +541,8 @@ static inline bool hmm_vma_range_done(struct hmm_range *range)
>  }
>  
>  /* This is a temporary helper to avoid merge conflict between trees. */
> -static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> +static inline int hmm_vma_fault(struct hmm_mirror *mirror,
> +				struct hmm_range *range, bool block)
>  {
>  	long ret;
>  
> @@ -554,7 +555,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>  	range->default_flags = 0;
>  	range->pfn_flags_mask = -1UL;
>  
> -	ret = hmm_range_register(range, range->vma->vm_mm,
> +	ret = hmm_range_register(range, mirror,
>  				 range->start, range->end,
>  				 PAGE_SHIFT);
>  	if (ret)
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 547002f56a163d..8796447299023c 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -925,13 +925,13 @@ static void hmm_pfns_clear(struct hmm_range *range,
>   * Track updates to the CPU page table see include/linux/hmm.h
>   */
>  int hmm_range_register(struct hmm_range *range,
> -		       struct mm_struct *mm,
> +		       struct hmm_mirror *mirror,
>  		       unsigned long start,
>  		       unsigned long end,
>  		       unsigned page_shift)
>  {
>  	unsigned long mask = ((1UL << page_shift) - 1UL);
> -	struct hmm *hmm;
> +	struct hmm *hmm = mirror->hmm;
>  
>  	range->valid = false;
>  	range->hmm = NULL;
> @@ -945,15 +945,12 @@ int hmm_range_register(struct hmm_range *range,
>  	range->start = start;
>  	range->end = end;
>  
> -	hmm = hmm_get_or_create(mm);
> -	if (!hmm)
> -		return -EFAULT;
> -
>  	/* Check if hmm_mm_destroy() was call. */
> -	if (hmm->mm == NULL || hmm->dead) {
> -		hmm_put(hmm);
> +	if (hmm->mm == NULL || hmm->dead)
>  		return -EFAULT;
> -	}
> +
> +	range->hmm = hmm;

I don't think you need this assignment here.  In the code below (right after
the mutext_lock()) it is set already.  And looks like it remains that way after
the end of the series.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> +	kref_get(&hmm->kref);
>  
>  	/* Initialize range to track CPU page table updates. */
>  	mutex_lock(&hmm->lock);
> -- 
> 2.21.0
> 

