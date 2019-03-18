Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D84E5C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 12:43:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78F6320850
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 12:43:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78F6320850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE6016B0003; Mon, 18 Mar 2019 08:43:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D93326B0006; Mon, 18 Mar 2019 08:43:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C83F56B0007; Mon, 18 Mar 2019 08:43:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 728BE6B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 08:43:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k21so6931438eds.19
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:43:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OP5ZLnoTurN/ZykPUqVrgOTNLlqJc0wQyH6bdT3ct90=;
        b=jZxvnfsjz3tTzXpzw9RKsq+WBYdScqe9TEKJuX+JFGZ6wkkoj72jdIx/q8nDSxLpni
         tT3bMRv9Y69Ugkqs7ObacZWc7FX9Bp9iB7aAcnyi79+KPwRKiPcyfPUBsd5hh2FEokth
         erQm6vTHHSHrV3V/SBXvh8IkHipzcPOXF5+fejdgivlH/kSv/EJ/ejn2k5LijIc5kmxT
         CUHrihnatMTwmZRuXR9BNfJLGuhpb9BbODIutV6jTLJTsM7dmi+eAMTcjnOG7wn05caI
         u2lbdKTwEKYIH2wJQLg45N+/xQyI8Y3b5BYLjrlQDJQE2uWnc+/nWtMGKWzxE+tVNuXG
         4NWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAXy0h5F/2o+Cd+VfylAbM5h1MO2xtBw0VsmRQTJJQFQDO0AnhKG
	tsQ+hK4MXEOxgYOgTsughgzrwZC44woy5GGuDLWQZjKLZjoXXDNrsZ+OLkkzsziLaCvH9XMD+9h
	hyp5Jd04/nELMp4HBoxC0zxZOwncytOpDqYSGvT/HYNUhIrqpxijB5n+3q8iRtNsRNA==
X-Received: by 2002:a50:b4e6:: with SMTP id x35mr12720710edd.123.1552912986023;
        Mon, 18 Mar 2019 05:43:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQ44PXgmFW4E9Fhh/ZX8gNvk1CKGNuRoXWWYdWhmnSEyDwvKgwgJNgDLxCmqXQog67Bc4W
X-Received: by 2002:a50:b4e6:: with SMTP id x35mr12720661edd.123.1552912985097;
        Mon, 18 Mar 2019 05:43:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552912985; cv=none;
        d=google.com; s=arc-20160816;
        b=BkTx9xpLOe822nbNdmD2U7y6Fau6/NrmvUfTFZyV4A4DPP8lPrCz0EKKl/kc9t/93U
         8I2GW0nYqdVGjVj0+lNik4XV6Z/5WyFMT7vZ2L6W9fGV+ozed6oOqHZvnCKhWOnzdWSZ
         SwmmBQYAGS34Ni9zkOSs2hG8j4T2A0+S8lS+M/WfAE672JwPVhyBg5P/70xYWQyeWcqM
         1QaahvkjurnpyEIj7A25dkL7+NFA3pld2iAoADQALykSO9FmkzuHeeYU//oalfeFaUn5
         HMbfo9jdYNwMkp9OhpJH0w3jhHn9WpQ8XcFYVuihX7qPS72PmQVyTbQB7sQAbuf9dlfw
         5MwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OP5ZLnoTurN/ZykPUqVrgOTNLlqJc0wQyH6bdT3ct90=;
        b=UqVMhWes7sAgFrtJqowDbuViWTUAlKb14Ajtr0Q8o+8HPzSvdpzBGcU6iILWSpS2ab
         hRXxUVTs8HIDwRdZs7MsDsBMdzr1HgJ7UsRLHNGioumgqN61M5B7O65DC3LJyObIyDRb
         GBvFHZWYN2SqLJKPv55/z5+iVfcmrEoD3ONV9RppwOZA4g+MUHTr1bl9/YfyArR7uLZx
         5pNAe3oHIptscRfbsXmcVEbQxtN8/kWCj0SvRZuFZqsDgbaCBEatK3aIbjWvlzgBWNOv
         K5WIv+4/T8DSFoTJZ3lOKcGGIIEzMqNwbp2BrMJeXjzJcxubWU0+C1Ejjf4utBxF7BQx
         rQ8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb7si3584634ejb.11.2019.03.18.05.43.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 05:43:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5DBE3ABF0;
	Mon, 18 Mar 2019 12:43:04 +0000 (UTC)
Date: Mon, 18 Mar 2019 13:43:00 +0100
From: Michal Hocko <mhocko@suse.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Takashi Iwai <tiwai@suse.de>, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3] mm, page_alloc: disallow __GFP_COMP in
 alloc_pages_exact()
Message-ID: <20190318124300.GF8924@dhcp22.suse.cz>
References: <20190314093944.19406-1-vbabka@suse.cz>
 <20190314094249.19606-1-vbabka@suse.cz>
 <0c6393eb-b28d-4607-c386-862a71f09de6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c6393eb-b28d-4607-c386-862a71f09de6@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 18-03-19 13:21:59, Vlastimil Babka wrote:
> OK here's a new version that changes the patch to remove __GFP_COMP per
> the v2 discussion, and also fixes the bug Kirill spotted (thanks!).
> 
> ----8<----
> >From 1fbc84c208573b885f51818ed823f89b3aa1e0ae Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 14 Mar 2019 10:19:30 +0100
> Subject: [PATCH v3] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()
> 
> alloc_pages_exact*() allocates a page of sufficient order and then splits it
> to return only the number of pages requested. That makes it incompatible with
> __GFP_COMP, because compound pages cannot be split.
> 
> As shown by [1] things may silently work until the requested size (possibly
> depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
> triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.
> 
> There are several options here, none of them great:
> 
> 1) Don't do the spliting when __GFP_COMP is passed, and return the whole
> compound page. However if caller then returns it via free_pages_exact(),
> that will be unexpected and the freeing actions there will be wrong.
> 
> 2) Warn and remove __GFP_COMP from the flags. But the caller may have really
> wanted it, so things may break later somewhere.
> 
> 3) Warn and return NULL. However NULL may be unexpected, especially for
> small sizes.
> 
> This patch picks option 2, because as Michal Hocko put it: "callers wanted it"
> is much less probable than "caller is simply confused and more gfp flags is
> surely better than fewer".
> 
> [1] https://lore.kernel.org/lkml/20181126002805.GI18977@shao2-debian/T/#u
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/page_alloc.c | 14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0b9f577b1a2a..123d9a407599 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4752,7 +4752,7 @@ static void *make_alloc_exact(unsigned long addr, unsigned int order,
>  /**
>   * alloc_pages_exact - allocate an exact number physically-contiguous pages.
>   * @size: the number of bytes to allocate
> - * @gfp_mask: GFP flags for the allocation
> + * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
>   *
>   * This function is similar to alloc_pages(), except that it allocates the
>   * minimum number of pages to satisfy the request.  alloc_pages() can only
> @@ -4767,6 +4767,9 @@ void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
>  	unsigned int order = get_order(size);
>  	unsigned long addr;
>  
> +	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
> +		gfp_mask &= ~__GFP_COMP;
> +
>  	addr = __get_free_pages(gfp_mask, order);
>  	return make_alloc_exact(addr, order, size);
>  }
> @@ -4777,7 +4780,7 @@ EXPORT_SYMBOL(alloc_pages_exact);
>   *			   pages on a node.
>   * @nid: the preferred node ID where memory should be allocated
>   * @size: the number of bytes to allocate
> - * @gfp_mask: GFP flags for the allocation
> + * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
>   *
>   * Like alloc_pages_exact(), but try to allocate on node nid first before falling
>   * back.
> @@ -4785,7 +4788,12 @@ EXPORT_SYMBOL(alloc_pages_exact);
>  void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
>  {
>  	unsigned int order = get_order(size);
> -	struct page *p = alloc_pages_node(nid, gfp_mask, order);
> +	struct page *p;
> +
> +	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
> +		gfp_mask &= ~__GFP_COMP;
> +
> +	p = alloc_pages_node(nid, gfp_mask, order);
>  	if (!p)
>  		return NULL;
>  	return make_alloc_exact((unsigned long)page_address(p), order, size);
> -- 
> 2.21.0
> 

-- 
Michal Hocko
SUSE Labs

