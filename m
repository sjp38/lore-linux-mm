Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A21D3C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 11:08:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 530E6206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 11:08:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 530E6206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC3BE8E0003; Wed, 31 Jul 2019 07:08:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D74338E0001; Wed, 31 Jul 2019 07:08:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3D278E0003; Wed, 31 Jul 2019 07:08:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 74BC68E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:08:48 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w25so42128442edu.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:08:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=VyUDkEfVMAj+fw3WqhJs39i3F9XXjtiJpaU45FwboJU=;
        b=sT2IPlF51MH0mMMhJYYaW/1T3e1Rto3aiQqEeEVy55eszN8MAiKRr/X4/IVefG6rQZ
         9o2OHSZUTnhyVwPoYMl7feK6MVSUjV7fw+ki/GUOzQlMgVZeYXYWOKeqvbYkzi7AZ6dR
         EqRngekbbE1JgRjlrNfmZaIhhPPBvopZhUo+K43Kfxi6G8sMKjeZKXjex3Vp8UWW2Nsn
         RD8usNVeHyahoUuyo/s4IdBUmCBs6zgUvLLySG4fLP0zQhjcxjt2T746rcVdNMqtM370
         ewr/76XbcH2JFJapQ7Eum/qsvI28OdPF9raojE+1Rg9/6t9oqMhHvy2sQIBvEKJjPRe/
         S3yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAV++8i/Glr7+ibEsmuqDMjhhCDZBNTc0OdpPfGD5gByoxBCnTkT
	JGWf37adLkbZFl8E/cL7L4ibV4EKJRTOI4+ykT/cYIiFRN8E0IaD1CeOGg2rjwq8OHhqGM2cqwo
	HLDXvw0lG555wqt9WkIiRbNVmUFYm1MvVDxtia2f/S7bkSco3I1AQiVZw5YShSmWDxQ==
X-Received: by 2002:a17:906:154f:: with SMTP id c15mr93100604ejd.268.1564571327916;
        Wed, 31 Jul 2019 04:08:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzojoUu++jktPvHd0ZcWliyBUhCOKqup34sQIMoqg12fXoA341CydeLbjl1b9HO6N2hzVoo
X-Received: by 2002:a17:906:154f:: with SMTP id c15mr93100530ejd.268.1564571326753;
        Wed, 31 Jul 2019 04:08:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564571326; cv=none;
        d=google.com; s=arc-20160816;
        b=p+JBHvCuMV9qQwblsRksouhzUqRdT8chyog3dQhl6Q6Xi73rGallSndjyasKZO5KEv
         g8Vj6kYTCHB1mY/HkjfqTAURq77gZNbebunKXPOdhcO5NhgXLwuf3Kl6e/yoAmhFRHkb
         C4RGkIf/2lZBG4g8LFnUMAihvIbcmSDe95DpjOY7IoWKCCDtAvYrEeCdtmD1iq62lNcO
         tyef/bx9RuEgWLp4pzsMCQFu46p1QT4qcATdddt9gtZaZP0/C5jZWENG+5GBZpivseSA
         HYFQ5Den/lJzjL4Z02nnK1BbgiAEbE9RAQyH88gbe3VX+yPBuhn/yKlk9Jnv/hSbReZ4
         qatQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=VyUDkEfVMAj+fw3WqhJs39i3F9XXjtiJpaU45FwboJU=;
        b=A+QUoveCAfDlZjZHhOCSs5DP3ZENOlhgx4ovkGcBGRszdiuykIuM6BWLZ7Os/Lh7QO
         +tng0VjIwjb8Tr1z+3JGHm3ZsE3MUEQ7Q9FYOTsDNtRmOz/NU6bKu0noFnuIIuWuB5go
         vgu+XNSODUxLJxu6GDXyYCMzTzqEypJgMFhuZ2EzP/g2+dLB5FKltW/EI4Z0ULGGkTfN
         MWyyWUPobUW5sK/NSAdZLu4spKGnkh/92I+/TyNdqYeR/UYEcRmFBWZ4crZl/5xhYoQA
         Uo50+kpR4RPl0Juojk2dJf/sPh34dV6M811ZINOQDbpxLVHXrSuBYjGyUQKM24IaH/By
         /Q8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x42si24095577edx.239.2019.07.31.04.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 04:08:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C72B0AF1B;
	Wed, 31 Jul 2019 11:08:45 +0000 (UTC)
Subject: Re: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim perform
 dryrun detection
To: Hillf Danton <hdanton@sina.com>, Mel Gorman <mgorman@suse.de>,
 Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-2-mike.kravetz@oracle.com>
 <20190725080551.GB2708@suse.de>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <295a37b1-8257-9b4a-b586-9a4990cc9d35@suse.cz>
Date: Wed, 31 Jul 2019 13:08:44 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190725080551.GB2708@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/26/19 9:40 AM, Hillf Danton wrote:
> 
> On Thu, 25 Jul 2019 08:05:55 +0000 (UTC) Mel Gorman wrote:
>>
>> Agreed that the description could do with improvement. However, it
>> makes sense that if compaction reports it can make progress that it is
>> unnecessary to continue reclaiming.
> 
> Thanks Mike and Mel.
> 
> Hillf
> ---8<---
> From: Hillf Danton <hdanton@sina.com>
> Subject: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim perform dryrun detection
> 
> Address the issue of should_continue_reclaim continuing true too often
> for __GFP_RETRY_MAYFAIL attempts when !nr_reclaimed and nr_scanned.
> This could happen during hugetlb page allocation causing stalls for
> minutes or hours.
> 
> We can stop reclaiming pages if compaction reports it can make a progress.
> A code reshuffle is needed to do that. And it has side-effects, however,
> with allocation latencies in other cases but that would come at the cost
> of potential premature reclaim which has consequences of itself.

I don't really understand that paragraph, did Mel meant it like this?

> We can also bail out of reclaiming pages if we know that there are not
> enough inactive lru pages left to satisfy the costly allocation.
> 
> We can give up reclaiming pages too if we see dryrun occur, with the
> certainty of plenty of inactive pages. IOW with dryrun detected, we are
> sure we have reclaimed as many pages as we could.
> 
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Hillf Danton <hdanton@sina.com>

I agree this is an improvement overall, but perhaps the patch does too
many things at once. The reshuffle is one thing and makes sense. The
change of the last return condition could perhaps be separate. Also
AFAICS the ultimate result is that when nr_reclaimed == 0, the function
will now always return false. Which makes the initial test for
__GFP_RETRY_MAYFAIL and the comments there misleading. There will no
longer be a full LRU scan guaranteed - as long as the scanned LRU chunk
yields no reclaimed page, we abort.

> ---
>  mm/vmscan.c | 28 +++++++++++++++-------------
>  1 file changed, 15 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f4fd02a..484b6b1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2673,18 +2673,6 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
>  			return false;
>  	}
>  
> -	/*
> -	 * If we have not reclaimed enough pages for compaction and the
> -	 * inactive lists are large enough, continue reclaiming
> -	 */
> -	pages_for_compaction = compact_gap(sc->order);
> -	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
> -	if (get_nr_swap_pages() > 0)
> -		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
> -	if (sc->nr_reclaimed < pages_for_compaction &&
> -			inactive_lru_pages > pages_for_compaction)
> -		return true;
> -
>  	/* If compaction would go ahead or the allocation would succeed, stop */
>  	for (z = 0; z <= sc->reclaim_idx; z++) {
>  		struct zone *zone = &pgdat->node_zones[z];
> @@ -2700,7 +2688,21 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
>  			;
>  		}
>  	}
> -	return true;
> +
> +	/*
> +	 * If we have not reclaimed enough pages for compaction and the
> +	 * inactive lists are large enough, continue reclaiming
> +	 */
> +	pages_for_compaction = compact_gap(sc->order);
> +	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
> +	if (get_nr_swap_pages() > 0)
> +		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
> +
> +	return inactive_lru_pages > pages_for_compaction &&
> +		/*
> +		 * avoid dryrun with plenty of inactive pages
> +		 */
> +		nr_scanned && nr_reclaimed;
>  }
>  
>  static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
> --
> 

