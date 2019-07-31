Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D3D9C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:06:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FA44206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:06:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FA44206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4CBE8E0006; Wed, 31 Jul 2019 08:06:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFE5C8E0001; Wed, 31 Jul 2019 08:06:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C51D8E0006; Wed, 31 Jul 2019 08:06:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4641E8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:06:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so42276613ede.0
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:06:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=WgHhNYCWR86wrumFJOYEXvi477ppZ0af+ybeduO3KMM=;
        b=tUjHQlgQT3XeZy0m+8BCBg5TBCl5JS/Hcx1YoybtoVKb+eKKkN+2T5H4VzkcoumOZv
         mOWFSv7z4fCMapumokl/OMtP6NASeGipwZpsx01pCSB+55XQuyX+HN80b0hQc+RvOT8A
         x+uWfHjMdF8b5SscEY0on0jBVkWEF96PaMBClf48D/G2+c7w2oyuV9LU+vD03mqfNjTL
         Uh+Kjawg1oTa5rV1vdsYxUKSJQ/nntZiIO+ftlXzBMG/d6zbJsOesWFUKtjcgx59S9pG
         YxrUpMqfh07jz1aBAIxkV3R9Q+szTcboRxp4BU65JjJyb9QuimjhmAaSYyXiQbshmqU3
         h+wA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUZAWBZVaAMws8Hy7XjgLhzEA4Ao+e5jReOuB2u2sAiEUC4Q4Lk
	2Nt4jyjDrkhoKTL2mhel2mERyTzmVDqgaN0pfMaYyba4oVHg/4jSHKiTdencjhOUTK9Nh/MjM1f
	9LYeHVdeBxUsYzaul4FOy8IJ1IyvEN4oj5Z42XJg6qdKi9EEA0aOeI9YQMvQrSb5rBA==
X-Received: by 2002:a17:906:1599:: with SMTP id k25mr92224345ejd.281.1564574817803;
        Wed, 31 Jul 2019 05:06:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaGjsDjh9NU4/tEHsZW6atH+otzOkPU+BK5LdCIqYrCX6FN/XJGHkoYXT89OLWUnvUYirr
X-Received: by 2002:a17:906:1599:: with SMTP id k25mr92224262ejd.281.1564574816924;
        Wed, 31 Jul 2019 05:06:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564574816; cv=none;
        d=google.com; s=arc-20160816;
        b=nRt/D6h78CN6+QIB+yOPfaBP5LxLxwCygdSsXhsnBCe/67qpNN2k+bgoqrLTPz/uek
         8ZRTkJTugDGXGW4URohLwinim9XeC5qhJCUquJ6L2mrPLwXMeiAybOB3r02dpiiP6SOp
         lm0CWo/GE87CSL3VAOFAKi3dJxszVR7dLtub6+KcnZZydLkduV8rHnF/CWESnHqxp4dh
         xcmPZ7bjDIUye2Y9EDDek93mKtaLVF7Tx+68W9lV3SgH4mJGcWbeNtnwA3CAGvGODQXo
         +mqATRD2+PV5Inl6moM+tgz0ulUHzQ0pt+FeDvNjXEHwnlkrlm+x+UCLFcbFNHg84Vj/
         jKow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=WgHhNYCWR86wrumFJOYEXvi477ppZ0af+ybeduO3KMM=;
        b=bT//R4290xiAb/AgcLdi4QbFudfNsegNQu4HYYZq2ZESrL3gSyziYoS6dAYHoYf4Zq
         gbzghM/0w90B7GfzY3u2XVLWjOowqstzmMsHDUKar7n9oDbDmC3qsPEUlPv++8lm+drx
         1BGUWJ/TqnfObWd5EHDXZ+QDpSH5Hz9acBVr8yxYBtRNajJRputNlARf8UKnw9tMlae/
         WMXNgLZRgjCkS7tSEk4aTrm5yASVFenDUuLGStVyKYsD3JfcZXLvTj+KsABfZwQCPCOh
         BuORiwG6oA7mSLmIG3/3No3fUWxQkAvVDxvyii0krBH4Tj/VPBnxxEIv0ybnoYRMZkDx
         xWaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w6si16733263eju.250.2019.07.31.05.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 05:06:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F2DA5AB9D;
	Wed, 31 Jul 2019 12:06:55 +0000 (UTC)
Subject: Re: [RFC PATCH 2/3] mm, compaction: use MIN_COMPACT_COSTLY_PRIORITY
 everywhere for costly orders
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
 Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-3-mike.kravetz@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <278da9d8-6781-b2bc-8de6-6a71e879513c@suse.cz>
Date: Wed, 31 Jul 2019 14:06:55 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724175014.9935-3-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/24/19 7:50 PM, Mike Kravetz wrote:
> For PAGE_ALLOC_COSTLY_ORDER allocations, MIN_COMPACT_COSTLY_PRIORITY is
> minimum (highest priority).  Other places in the compaction code key off
> of MIN_COMPACT_PRIORITY.  Costly order allocations will never get to
> MIN_COMPACT_PRIORITY.  Therefore, some conditions will never be met for
> costly order allocations.
> 
> This was observed when hugetlb allocations could stall for minutes or
> hours when should_compact_retry() would return true more often then it
> should.  Specifically, this was in the case where compact_result was
> COMPACT_DEFERRED and COMPACT_PARTIAL_SKIPPED and no progress was being
> made.

Hmm, the point of MIN_COMPACT_COSTLY_PRIORITY was that costly
allocations will not reach the priority where compaction becomes too
expensive. With your patch, they still don't reach that priority value,
but are allowed to be thorough anyway, even sooner. That just seems like
a wrong way to fix the problem. If should_compact_retry() returns
misleading results for costly allocations, then that should be fixed
instead?

Alternatively, you might want to say that hugetlb allocations are not
like other random costly allocations, because the admin setting
nr_hugepages is prepared to take the cost (I thought that was indicated
by the __GFP_RETRY_MAYFAIL flag, but seeing all the other users of it,
I'm not sure anymore). In that case should_compact_retry() could take
__GFP_RETRY_MAYFAIL into account and allow MIN_COMPACT_PRIORITY even for
costly allocations.

> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/compaction.c | 18 +++++++++++++-----
>  1 file changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 952dc2fb24e5..325b746068d1 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -2294,9 +2294,15 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
>  		.alloc_flags = alloc_flags,
>  		.classzone_idx = classzone_idx,
>  		.direct_compaction = true,
> -		.whole_zone = (prio == MIN_COMPACT_PRIORITY),
> -		.ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY),
> -		.ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY)
> +		.whole_zone = ((order > PAGE_ALLOC_COSTLY_ORDER) ?
> +				(prio == MIN_COMPACT_COSTLY_PRIORITY) :
> +				(prio == MIN_COMPACT_PRIORITY)),
> +		.ignore_skip_hint = ((order > PAGE_ALLOC_COSTLY_ORDER) ?
> +				(prio == MIN_COMPACT_COSTLY_PRIORITY) :
> +				(prio == MIN_COMPACT_PRIORITY)),
> +		.ignore_block_suitable = ((order > PAGE_ALLOC_COSTLY_ORDER) ?
> +				(prio == MIN_COMPACT_COSTLY_PRIORITY) :
> +				(prio == MIN_COMPACT_PRIORITY))
>  	};
>  	struct capture_control capc = {
>  		.cc = &cc,
> @@ -2338,6 +2344,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  	int may_perform_io = gfp_mask & __GFP_IO;
>  	struct zoneref *z;
>  	struct zone *zone;
> +	int min_priority;
>  	enum compact_result rc = COMPACT_SKIPPED;
>  
>  	/*
> @@ -2350,12 +2357,13 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, prio);
>  
>  	/* Compact each zone in the list */
> +	min_priority = (order > PAGE_ALLOC_COSTLY_ORDER) ?
> +			MIN_COMPACT_COSTLY_PRIORITY : MIN_COMPACT_PRIORITY;
>  	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
>  								ac->nodemask) {
>  		enum compact_result status;
>  
> -		if (prio > MIN_COMPACT_PRIORITY
> -					&& compaction_deferred(zone, order)) {
> +		if (prio > min_priority && compaction_deferred(zone, order)) {
>  			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
>  			continue;
>  		}
> 

