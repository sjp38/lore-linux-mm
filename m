Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F42DC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:43:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4E4820880
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:43:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E4820880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59D1B6B0005; Mon,  5 Aug 2019 04:43:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 526586B0006; Mon,  5 Aug 2019 04:43:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 353A76B0007; Mon,  5 Aug 2019 04:43:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFDC46B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 04:43:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i9so51080106edr.13
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 01:43:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=/IHFKxXk+Yr8G4Z6c3nZJvSj4L0kjAeKcxjyzWSgJGw=;
        b=q5chL/Q5yhsrbSmkLVTm+W3STw+0lwAxhCoumprC2mpTu2uTERRgwHwiSVL4bVXrc7
         EG9Qy5YaQvUySu+iD8en++Kly272hsCUFthZkUYZaiqj+QGociQ0nWFouMYV0z4IpFYl
         EnyszdSnMk1NqN3D2dyxH6OMdBJGtyhDp3iwbsJASGOeHVukGDxzc8ADXji8ab7P0KD1
         pSdUV6sBg1iudIG+qLg+OSr829v+5sFhLXGIGzyv0SySk6ltHe4OwyfenzmN1VfwGnco
         h42NFJqs1WTBT1nHfXIlBEj55AHxYlTFp7SjFHBXRfSVWgNMJrTy89kIY1ompkDA3buC
         Sciw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAV80DTdBY6Pzv5Yfeo910X00yktqRQtxSGK6scX43Km22gIwJAj
	Ayt3Vi6FD4oEbL7Wj2/DgRfylPYQ8Zg4DcTnWoo8lbyavH73jf9CHs1wq45NtA0Jiy1hjGv3tJ/
	SFJF7MrexVOWaZvyrzOfNwZ+HOXg0blbSQAv+Yhv89cZ5/vTEsFqd5907qc84oCSj+Q==
X-Received: by 2002:a17:906:d201:: with SMTP id w1mr84870565ejz.303.1564994581418;
        Mon, 05 Aug 2019 01:43:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvinEeftHyjvcpCfPYEj+61CS/2kPz4n+Yq65Dm4YGYak//msHrb5tFClTF2qknCpDKtma
X-Received: by 2002:a17:906:d201:: with SMTP id w1mr84870513ejz.303.1564994580482;
        Mon, 05 Aug 2019 01:43:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564994580; cv=none;
        d=google.com; s=arc-20160816;
        b=kTagFpesMBaQVWSPJ6KcEm/b4EtSEBtIZt0tzc0m8AZjH3ZqaLh2JtMx05CMfm9U8u
         v0kYN2yX8FYONPQdx6z5pHGKL8VpUkk++jJmNxRRuZbwk3jr28HN+rkWfzqHeBTWsixL
         Y5wJ+t/e9eF+4oVcQXW9BouWeI6yyK7gBQz4YHMSI/1P1aw8TYPq/htkPxK16h2HTv7s
         ZVgBZJv08JoYEmy/raQtU7hItccZkgVs94q2f+P8WcOLxJ3azad8bWgJQ9at1VrDIuSn
         nmNzctu9lVur3duofq97oU81gylII9qGfBXZZBwivyfCyHfoQEg+mW/azK7bO69XUfGF
         KjCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=/IHFKxXk+Yr8G4Z6c3nZJvSj4L0kjAeKcxjyzWSgJGw=;
        b=XdyzGh5whl1fGzzKF30UqLNF2VMxIpKhdsmcijzJ3SLdaOISG/4J1uDegNMr9b8a2+
         aGRfIU0P/kTHKgGRdaWo71ixpYDFwZZgA+c50AMOZL3ipkMhs+Vak5jd9yQyE4aVd5Te
         lUbrlYasvTc71Ptf+9Z6a77CnrSmbQeyxXiaUl6OppNMC0YtX8iM7EDa1V9/Ibn7H4K+
         x0QEDRNSYdvZH7Li5QfqFt/4fKk9TEhz8vQJ0Lt3aB0vV6kHtTt2opUj9Y/Xw3MiNKO4
         oqIzJ53PD34k4n/fS7PGjHhEJVkrZI2UKP93/f9uZ0Zbloz5HnlUe1lBMZukT+eimXkA
         AWAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y23si27102730edu.250.2019.08.05.01.43.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 01:43:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D5442B61C;
	Mon,  5 Aug 2019 08:42:59 +0000 (UTC)
Subject: Re: [PATCH 1/3] mm, reclaim: make should_continue_reclaim perform
 dryrun detection
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
 Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
 Andrea Arcangeli <aarcange@redhat.com>, David Rientjes
 <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
References: <20190802223930.30971-1-mike.kravetz@oracle.com>
 <20190802223930.30971-2-mike.kravetz@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <bb16d3f0-0984-be32-4346-358abad92c4c@suse.cz>
Date: Mon, 5 Aug 2019 10:42:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190802223930.30971-2-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/3/19 12:39 AM, Mike Kravetz wrote:
> From: Hillf Danton <hdanton@sina.com>
> 
> Address the issue of should_continue_reclaim continuing true too often
> for __GFP_RETRY_MAYFAIL attempts when !nr_reclaimed and nr_scanned.
> This could happen during hugetlb page allocation causing stalls for
> minutes or hours.
> 
> We can stop reclaiming pages if compaction reports it can make a progress.
> A code reshuffle is needed to do that.

> And it has side-effects, however,
> with allocation latencies in other cases but that would come at the cost
> of potential premature reclaim which has consequences of itself.

Based on Mel's longer explanation, can we clarify the wording here? e.g.:

There might be side-effect for other high-order allocations that would
potentially benefit from more reclaim before compaction for them to be
faster and less likely to stall, but the consequences of
premature/over-reclaim are considered worse.

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
> Tested-by: Mike Kravetz <mike.kravetz@oracle.com>
> Acked-by: Mel Gorman <mgorman@suse.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
I will send some followup cleanup.

There should be also Mike's SOB?



> ---
>  mm/vmscan.c | 28 +++++++++++++++-------------
>  1 file changed, 15 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 47aa2158cfac..a386c5351592 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2738,18 +2738,6 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
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
> @@ -2765,7 +2753,21 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
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
> 

