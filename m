Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0868C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:40:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A66EE2184A
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:40:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A66EE2184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4307B8E0003; Thu, 28 Feb 2019 03:40:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DEB08E0001; Thu, 28 Feb 2019 03:40:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27E8E8E0003; Thu, 28 Feb 2019 03:40:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C10FF8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:40:17 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id h37so6484739eda.7
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 00:40:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=9lIVa1SkwlGhp3UoewozuKjb6M5AcSFhiwXvomboeJI=;
        b=a4LfHAxdyjQ13BieMATs7kRCXqbCS3Bkavr85QQJfhI0ImMAaPz7Y+nMbvnOSXoZsc
         y/G8SgdHAlmOuVbE6ZiYOwT/uPSiCHvn+C+QkTvv7zDxlMcIVnUSVfhOvESeCP6U92Ln
         mg3YuMtJMw0K58939ByUlcjL/lxZPvi5jKLmLMAp1o5X/lV1+bfWxY8XdL/lqydufdOb
         Bn1OaDntWZdmgH9tGnK/p3CaTQ9WOeoSmdDQoIOSyNlzGzsanbu69neGakOx22YWjTkq
         utxkNKgARL8gVVmg62Mg64N4F9LsBwjZXWffSHe40FARWxN6kafOHLlK/Q30sMUhJ1/9
         qkYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuYS1g3+70Xl1c3VQhuSsuI0Xz4hkvR3yB9BNxzAfeiZ51GrvzMT
	IZI8BC0x7Bi+lRiwSBH1wjQftHEipftyOwQLXQUPXO17RIJCoFfVTqMK3TdkR27PS4BV/z6hCBg
	pdmB0cyYW+Yc14YP3pIni4BiI7LVe9CaEJZLhEkVPCS7Do6zMPMFVGtxeFf3sDNXYXg==
X-Received: by 2002:a17:906:c406:: with SMTP id u6mr4426181ejz.95.1551343217337;
        Thu, 28 Feb 2019 00:40:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY82qOrp1dIDiA/3z8Htx19IZBB2uaX+141VccclvvXUagA/1Zs8D9iZvbQrdfvA/RwX0dm
X-Received: by 2002:a17:906:c406:: with SMTP id u6mr4426143ejz.95.1551343216416;
        Thu, 28 Feb 2019 00:40:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551343216; cv=none;
        d=google.com; s=arc-20160816;
        b=CG2w51IpfDwyPIy/IpnJOQHapjU/LidgUWtZSfM/HHv+LJjcDnKcMzPvsrVmpQjjhn
         AicovjRIYrSrsuS6TE4NFcu3ZJwlBkP5UoqB248l0OZPmjEavPfQdQEEkp7/6bClqjJ7
         My33pd7BN4fx7EGPQFQIaIdjzdaNSxmMd1gaNKxt2a2b+qHZBFuhgtkMT0lQd/IgRm4C
         YCoAbIVKKPCd8CXDxswNLi4Il8/F4NTenC1tzEduvLnbPlvhB1BUBBX/Jq5AjyZCepeK
         oQVpIjrgnJlVYFhiXCvDtg3ZQw2chLI2MO6iXB4wxyC6r5gra+cnVTNbWaFR8YyOzL/a
         3A4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=9lIVa1SkwlGhp3UoewozuKjb6M5AcSFhiwXvomboeJI=;
        b=gBHbO4YygTtp2HoOayHpL1LsFpQwAsXpyI6pY4v0GtL6sKbbd5x3MoOpC3ZqNAfybA
         +YM3t0Yj9P/kkusxn53dngSWIM+vq5gIj8Foc2iwaRWaldleZKDyxpuD1kzEXNmUWIoE
         EJAwE1Dbdj0HOHo0oeI/i5fqFDrjNZiHkRP7D56+fHEkxQGzqPnVqHhnTJT/4+Za+9zk
         S7BCG5qznjwQxZNB6OExIE17VexbqpXY1Be62+leYTRKFgFOHQgAzaE752ATotF4Mrqh
         jAUvymD3sHmBV8LyDeL9X5r1mZGLm4CZFyNrJQrrEOXctFHqzGSC/yo7Bb0+S2hEZDus
         b4FA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ay2si2660194ejb.54.2019.02.28.00.40.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 00:40:16 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C9724AE84;
	Thu, 28 Feb 2019 08:40:15 +0000 (UTC)
Subject: Re: [PATCH v2 1/4] mm/workingset: remove unused @mapping argument in
 workingset_eviction()
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <7faa0a46-ad3e-0533-6646-4e79d468e558@suse.cz>
Date: Thu, 28 Feb 2019 09:40:15 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190228083329.31892-1-aryabinin@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 9:33 AM, Andrey Ryabinin wrote:
> workingset_eviction() doesn't use and never did use the @mapping argument.
> Remove it.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Rik van Riel <riel@surriel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> ---
> 
> Changes since v1:
>  - s/@mapping/@page->mapping in comment
>  - Acks
> 
>  include/linux/swap.h | 2 +-
>  mm/vmscan.c          | 2 +-
>  mm/workingset.c      | 5 ++---
>  3 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 649529be91f2..fc50e21b3b88 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -307,7 +307,7 @@ struct vma_swap_readahead {
>  };
>  
>  /* linux/mm/workingset.c */
> -void *workingset_eviction(struct address_space *mapping, struct page *page);
> +void *workingset_eviction(struct page *page);
>  void workingset_refault(struct page *page, void *shadow);
>  void workingset_activation(struct page *page);
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ac4806f0f332..a9852ed7b97f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -952,7 +952,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
>  		 */
>  		if (reclaimed && page_is_file_cache(page) &&
>  		    !mapping_exiting(mapping) && !dax_mapping(mapping))
> -			shadow = workingset_eviction(mapping, page);
> +			shadow = workingset_eviction(page);
>  		__delete_from_page_cache(page, shadow);
>  		xa_unlock_irqrestore(&mapping->i_pages, flags);
>  
> diff --git a/mm/workingset.c b/mm/workingset.c
> index dcb994f2acc2..0bedf67502d5 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -215,13 +215,12 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
>  
>  /**
>   * workingset_eviction - note the eviction of a page from memory
> - * @mapping: address space the page was backing
>   * @page: the page being evicted
>   *
> - * Returns a shadow entry to be stored in @mapping->i_pages in place
> + * Returns a shadow entry to be stored in @page->mapping->i_pages in place
>   * of the evicted @page so that a later refault can be detected.
>   */
> -void *workingset_eviction(struct address_space *mapping, struct page *page)
> +void *workingset_eviction(struct page *page)
>  {
>  	struct pglist_data *pgdat = page_pgdat(page);
>  	struct mem_cgroup *memcg = page_memcg(page);
> 

