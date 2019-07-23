Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 814A5C7618F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:44:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C2D2218DA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:44:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C2D2218DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D54926B0003; Mon, 22 Jul 2019 20:44:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDE406B0005; Mon, 22 Jul 2019 20:44:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA5548E0001; Mon, 22 Jul 2019 20:44:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81F5C6B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 20:44:33 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l11so3399859pgc.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 17:44:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2nIoLpZG+EcIPh2YDnObXkT5a6ekFnxjfIyB29gW8gQ=;
        b=pDp/0ykvk0BmjFCw3G6lBUAniKVP5662B8zu8FZReSAlSrwL89M2Jbhy+ZAWh3eAzi
         yEM+6Elfb8hTWxnOpJa82n3RD82Y0/EAURVxdFhYRfWioTzEnDKaWvWIycIiMci7bcxK
         aB1R2hDtj/WEVtcTjS+JbBGHMNcGpk4O1vBdGYDGMEEGR/o9yWWrYnhOq1WOuk7kxHbP
         Mqo+S94rqiNVDJGGxyFs5PoQY8nP1axxWP6NpXlbS0pM+NsLydtgtj9L5s8dLSukmzW+
         RSxIpZTats4WtykePqutp9cv/VCWCQqCH2XD0F/QOw5KGtKszJ62tPOUKLqg4Md4bCsQ
         aRlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU6RP7vsBODyMyAPNhgkk4G6ZtQ6kb83IuDn5tOLX87CXlv7rv6
	63utzsBACmuCyAQ/aKL1CCV7LdA8x7HNV1uR/IT41p2buYrXGiZpwXDfieFoD/iSiOsNb9nsmep
	4nji6Hg7Fq+V0+oyliuDvY/3S9j//JNlRZHuJTBj8qx4Li+7KvrviBJhghyKLFbv9qw==
X-Received: by 2002:a17:90b:8c8:: with SMTP id ds8mr81027530pjb.89.1563842673132;
        Mon, 22 Jul 2019 17:44:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyI/vsDIVwLyyh63ZbrGI/yZxmhrYuYVOx7MP8SobpSHYlvXrfbkBii8gd+ZF/93S70qouw
X-Received: by 2002:a17:90b:8c8:: with SMTP id ds8mr81027477pjb.89.1563842672366;
        Mon, 22 Jul 2019 17:44:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563842672; cv=none;
        d=google.com; s=arc-20160816;
        b=O90mKjENNSm0X2Zq3MK5iR9b6+dmZXRj/l9izPuJyKJLiaxZneqASwlk0U90HR/l3V
         ELAI9WKof2y8l2IqZ893T4ghV7eLVtbdgHOgYb58+9pVJCBRwSXXQEw3FSGM1tmyuQxK
         KjPZgeYdk8jCE7VKGoRGuiX5YsOZ/wDcbKaT+ZXVw/7gytKQZOSvdF6tOzMrGYBgN+vh
         Ce1qDMgM+7FxVuQ1dSUaf3Ub6otT6juj/mxVYlRREaPTYGINVioLSOx6/AH2GVWejxRz
         oyj0GtkKXAm04dYSxSH91UhBAKWKSfaLcNM8Ho/aCdTIi40/a7TodGYXJgb8tmVrzDaJ
         xJEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2nIoLpZG+EcIPh2YDnObXkT5a6ekFnxjfIyB29gW8gQ=;
        b=nAI8d9rTvsdEID3FE3tjpKEqYHwPuF1cUCJxYMkHXBxqk7rIt3g2OpdpziiaAumKTo
         JCvpNE6y0rFFGjtTKV0SXpFyRuzjkc3gnfZsdGeRGZF7G3wU88OOK9wXpndGIzvfvauh
         59ZouW/dCTdns4hDQE94Auj1/RtGZsGlmLIb7/cPRQ/6+E+zjJJ9oMjNBlrV0iGl/Tdq
         rx+kz30ceTSMS1KoHXVVF1Tm7xn9aj643PHc5g20o4q0kbF5xyjRyoZrphvEZjeP9EQA
         hLaufLwj2A0iRAsbzzulSHFZTP986rmRBNU0i1UFZVpyk+lGCHKKefacp8iEyIf7Ev3k
         zMkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id x35si8676701pga.337.2019.07.22.17.44.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 17:44:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Jul 2019 17:44:06 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,297,1559545200"; 
   d="scan'208";a="253071976"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 22 Jul 2019 17:44:06 -0700
Date: Mon, 22 Jul 2019 17:44:06 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: [PATCH v2 2/3] mm: Introduce page_shift()
Message-ID: <20190723004406.GC10284@iweiny-DESK2.sc.intel.com>
References: <20190721104612.19120-1-willy@infradead.org>
 <20190721104612.19120-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721104612.19120-3-willy@infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 03:46:11AM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> Replace PAGE_SHIFT + compound_order(page) with the new page_shift()
> function.  Minor improvements in readability.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  arch/powerpc/mm/book3s64/iommu_api.c | 7 ++-----
>  drivers/vfio/vfio_iommu_spapr_tce.c  | 2 +-
>  include/linux/mm.h                   | 6 ++++++
>  3 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/powerpc/mm/book3s64/iommu_api.c b/arch/powerpc/mm/book3s64/iommu_api.c
> index b056cae3388b..56cc84520577 100644
> --- a/arch/powerpc/mm/book3s64/iommu_api.c
> +++ b/arch/powerpc/mm/book3s64/iommu_api.c
> @@ -129,11 +129,8 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
>  		 * Allow to use larger than 64k IOMMU pages. Only do that
>  		 * if we are backed by hugetlb.
>  		 */
> -		if ((mem->pageshift > PAGE_SHIFT) && PageHuge(page)) {
> -			struct page *head = compound_head(page);
> -
> -			pageshift = compound_order(head) + PAGE_SHIFT;
> -		}
> +		if ((mem->pageshift > PAGE_SHIFT) && PageHuge(page))
> +			pageshift = page_shift(compound_head(page));
>  		mem->pageshift = min(mem->pageshift, pageshift);
>  		/*
>  		 * We don't need struct page reference any more, switch
> diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
> index 8ce9ad21129f..1883fd2901b2 100644
> --- a/drivers/vfio/vfio_iommu_spapr_tce.c
> +++ b/drivers/vfio/vfio_iommu_spapr_tce.c
> @@ -190,7 +190,7 @@ static bool tce_page_is_contained(struct mm_struct *mm, unsigned long hpa,
>  	 * a page we just found. Otherwise the hardware can get access to
>  	 * a bigger memory chunk that it should.
>  	 */
> -	return (PAGE_SHIFT + compound_order(compound_head(page))) >= page_shift;
> +	return page_shift(compound_head(page)) >= page_shift;
>  }
>  
>  static inline bool tce_groups_attached(struct tce_container *container)
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 899dfcf7c23d..64762559885f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -811,6 +811,12 @@ static inline unsigned long page_size(struct page *page)
>  	return PAGE_SIZE << compound_order(page);
>  }
>  
> +/* Returns the number of bits needed for the number of bytes in a page */
> +static inline unsigned int page_shift(struct page *page)
> +{
> +	return PAGE_SHIFT + compound_order(page);
> +}
> +
>  void free_compound_page(struct page *page);
>  
>  #ifdef CONFIG_MMU
> -- 
> 2.20.1
> 

