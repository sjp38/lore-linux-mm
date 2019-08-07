Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1066C41514
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 10:04:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D8C021E6C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 10:04:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D8C021E6C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D68256B0003; Wed,  7 Aug 2019 06:04:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3F6C6B0006; Wed,  7 Aug 2019 06:04:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C078E6B0007; Wed,  7 Aug 2019 06:04:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 738746B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 06:04:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e9so44673624edv.18
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 03:04:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=xNh67J09UClLaXZNUq/U9zrE2IHPqKErv+9PvHvj8ic=;
        b=ciQDJQGuZoPVP3Wt3NrOrtp3rp5JlAgWXGQXy5EXpm3qGbyYTzLKaJWe3jzln6eNJI
         9A5pY2fKbr9Zzq34nqDwpNQ8JdObcHVeB1GTH5PQar0nNZ/U4gVU5Z1Ddu0K7o28O2pw
         nDw5xNzaxS5nMEcAeF6N477jS8m7Kb1E9Ta4Y4VfmufsMrqI9xcxyOVroS/XGwFfM6fs
         szW3XDkaqAJskM7zGfK0fxTVF7YVNy/cPdlYIr1rCtVjwBf6kCXTAqznzqCL5qsfFAP3
         MXwkODMWYJTdLh1SHqNpcM/IOI9qp/Fotvhn1Dnnl8YHARWr7SmR0q+iIswFp7EVaqEp
         C3Ug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXkyuwoXLtDJVt/tT5phTtmNfMfwgp3muFYVMWL8xO87KBP95Tg
	it+jxc6bydxzQZhIKJR77yWZK+/2QDlodDbAYBtFbtD4u+/gG1nusmtddjJykmiAJQnUAgUK3KG
	Or0ZViKOdXD9o0izlMDCkQwOOvO1iZ6Zi9cslfC2/x+lwKcLQMcr8zS3fRv1EBWwSMg==
X-Received: by 2002:a50:a4ef:: with SMTP id x44mr8838582edb.304.1565172286042;
        Wed, 07 Aug 2019 03:04:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztSe63ndvi+WHBlXSbgYjmcrp2UvyEaL93nrRiNHeY+gs3vwhNSrK1UAVGVANJRHs/GMqy
X-Received: by 2002:a50:a4ef:: with SMTP id x44mr8838509edb.304.1565172285202;
        Wed, 07 Aug 2019 03:04:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565172285; cv=none;
        d=google.com; s=arc-20160816;
        b=GHQKn/7GOQdbZQmp/drGJ7fZM+jAUmD0+wFPiMb3w9aH++5qB0GRQLRflW+KrI6BTH
         QVB3spSjz7IJAaZ7PrmWePcZ/fi+hxrR4Ysm6EqBZhLCOe+4Ufm3Cxz+4TwY8Ayh62rf
         weM3OdLyQYnPfVynFvBtGMBkZ/liXfX1C1O11KiqZ7AxLNENLBBex9ENTHHYdkLWQ2n3
         RAhw4gi26ZpySwkodQ/PoygQ+V+hFOz4mWd7KoJ968AdH0kqOQwZtnrE8oRR84dTEKrG
         lQJ0rIkoHq+Z/g+w1Pmw12bFmte6CGY9WXAfnIsfq3RKUDthf7ZGJtIpSEZE9dfwy4AR
         /Adw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xNh67J09UClLaXZNUq/U9zrE2IHPqKErv+9PvHvj8ic=;
        b=aY97prRIneAElyKkZC3u0KoXHcJl78+/3KYvcXVD+e75qdRwuukJILzfWfj1Gh/65Y
         Nf3exvpdunjniX46awHSdaCVVzgUpq/j44gSkA0pDR3Q8Eesj9xlYrUo2R/6nr9Zleet
         2TDh+mWGgXndtmNJtGHMUvis19He9ylrTW52UfLdcg6cfD+B8FIFfwaBM2sCf9qRclUW
         BvRap9kM1nCefPt9fDmGDsVTRA1AoY3Oxd7ASK52dwXQMkL8XAV0KJ4fV/9Z4jW3/827
         /iM27StSJxeWkYYWyVGdMosSfOi8YJSf99H2pdQIDFhdHedABu+qDs/nr7/zGhbKs1GV
         htww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si28142024eje.340.2019.08.07.03.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 03:04:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7D95DAD20;
	Wed,  7 Aug 2019 10:04:44 +0000 (UTC)
Subject: Re: [PATCH] mm/compaction: remove unnecessary zone parameter in
 isolate_migratepages()
To: Pengfei Li <lpf.vector@gmail.com>, akpm@linux-foundation.org
Cc: mgorman@techsingularity.net, cai@lca.pw, aryabinin@virtuozzo.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190806151616.21107-1-lpf.vector@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5d07663b-3915-b6a4-4886-fc78dc3ef209@suse.cz>
Date: Wed, 7 Aug 2019 12:04:38 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190806151616.21107-1-lpf.vector@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 5:16 PM, Pengfei Li wrote:
> Like commit 40cacbcb3240 ("mm, compaction: remove unnecessary zone
> parameter in some instances"), remove unnecessary zone parameter.
> 
> No functional change.
> 
> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/compaction.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 952dc2fb24e5..685c3e3d0a0f 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1737,8 +1737,7 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
>   * starting at the block pointed to by the migrate scanner pfn within
>   * compact_control.
>   */
> -static isolate_migrate_t isolate_migratepages(struct zone *zone,
> -					struct compact_control *cc)
> +static isolate_migrate_t isolate_migratepages(struct compact_control *cc)
>  {
>  	unsigned long block_start_pfn;
>  	unsigned long block_end_pfn;
> @@ -1756,8 +1755,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	 */
>  	low_pfn = fast_find_migrateblock(cc);
>  	block_start_pfn = pageblock_start_pfn(low_pfn);
> -	if (block_start_pfn < zone->zone_start_pfn)
> -		block_start_pfn = zone->zone_start_pfn;
> +	if (block_start_pfn < cc->zone->zone_start_pfn)
> +		block_start_pfn = cc->zone->zone_start_pfn;
>  
>  	/*
>  	 * fast_find_migrateblock marks a pageblock skipped so to avoid
> @@ -1787,8 +1786,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  		if (!(low_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages)))
>  			cond_resched();
>  
> -		page = pageblock_pfn_to_page(block_start_pfn, block_end_pfn,
> -									zone);
> +		page = pageblock_pfn_to_page(block_start_pfn,
> +						block_end_pfn, cc->zone);
>  		if (!page)
>  			continue;
>  
> @@ -2158,7 +2157,7 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
>  			cc->rescan = true;
>  		}
>  
> -		switch (isolate_migratepages(cc->zone, cc)) {
> +		switch (isolate_migratepages(cc)) {
>  		case ISOLATE_ABORT:
>  			ret = COMPACT_CONTENDED;
>  			putback_movable_pages(&cc->migratepages);
> 

