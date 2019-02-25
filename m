Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADF9DC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 12:01:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 622A9213A2
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 12:01:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 622A9213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 013038E0006; Mon, 25 Feb 2019 07:01:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F03638E0004; Mon, 25 Feb 2019 07:01:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCC6D8E0006; Mon, 25 Feb 2019 07:01:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CBFA8E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 07:01:03 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i22so3809364eds.20
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 04:01:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=OcLkOmbGB8vzK34XQ0qmhuZVp2as2xwj/HHqx6/a+K4=;
        b=TsaRJyO1O6fzT2V77asuxtx5Ct8rIIsNWu8C8Z4m9Rh4nNOLYGyLvWz0RTnu9RhlW2
         13D8/bJxrjvn9W9TKjCv6aucnpwBj/3qescDpB0HT9hQh8VyOHf65KWaMMHSCDHOz8bt
         SO3MdIInLKWgj4ebFoZEbx07k00Ut6wWdNhBT3Ntj1opS2BubRXRe1Ydsc/EEqTy+RtM
         ZtLg9ZnAuhcHOAFblbLYU8nzaAvxnvQpJH+RvHMFVJBn+GKE3bjQ+/NkXIPCg9DT8pK7
         WNLSsFNbfv4mUy4XnvjRsOH1f/VHvSPlkvfXXtTi5RNkk2O3QG6bMXeMie5KQCrzFrD4
         usSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuYi3EbhTlShzUqwjteUlDKEDIgm6BYJYd9Y81tJ3uhZCQDbG6/N
	O+CUCBXxE7r1HAWeQjSQXvuj3JEn9tAnMCi3FBWshRnuevASUPbu+ATGGHtf1jO5JlQ49l423el
	eE6KKpa8ye00MLK6rC5TuXgRNf/CRy8lBZLpfw75PSw1QI//m2SRRA3eyP9bq7xPQNg==
X-Received: by 2002:a50:b4db:: with SMTP id x27mr14423660edd.90.1551096063069;
        Mon, 25 Feb 2019 04:01:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaqA6A3psVawBM7L/J00nwgybEydvrCYGTkkU3ceEpZHuY5d2SHvjFEyKy9xWFUHF1EFqud
X-Received: by 2002:a50:b4db:: with SMTP id x27mr14423571edd.90.1551096061809;
        Mon, 25 Feb 2019 04:01:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551096061; cv=none;
        d=google.com; s=arc-20160816;
        b=dYuBKAvkHNA61qSbFltJW8ollvtqxdm5+mAGHAQKClmf6huzAyaxOQDeskFpKKavRA
         C5+EkCfAYj5ewTxDbaGl1aDVmiP9PNqbRT2IXdYuFe559W80xLwa/lcTadTX0MWQ0Zlt
         eTqEDzeufO0o/11hBeGWdie/8XNLxn0lMpQxcWizpFgyjUIHlsjMCcKbRyuu5VkRGPkd
         BMpXZOQNlWFHGMnz2habIent4YALajYURZEkJchtWeu7gawFsBC+VpYU1vOIsXn+BuC8
         v6tAvCqCGPgAMw9r0U6wEgsSKWVh8AmSllk7JwASCFBIMhfEkBpw1lQG6Re/oAczcp9F
         qBjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=OcLkOmbGB8vzK34XQ0qmhuZVp2as2xwj/HHqx6/a+K4=;
        b=ncRoaUjnPV9UrHdRUZ43iKUygU31wsISWNWmTPWOLvNSjgdnpTU1w14LxECRLS2KVT
         XrpWVP6eDLssi4MFo695OKR33cvQIZl6ihqVharvAbtppvUTXVzB+NMfY8kwZXpnJvil
         UDzIG+3OKPQvopFbgu+ZmoFKMNWhiSIC2szXxvp9K2AhkRCr9UnPYra9kGHIp2J8oG/u
         MgEQwLCnPeGGsvnYZOtIUMUoW5npNRRQ8A71P7s1to73LLlFi8GaQ/vQald4s5n548K5
         ufEuMB0hgiXK1pGMYoNB5Elp67Nrnx1xC1Znb32jwOYy5DdMEmN/xZEQHCaDWfL5AZnb
         Q1Sg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f55si1248735ede.435.2019.02.25.04.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 04:01:01 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D6158B000;
	Mon, 25 Feb 2019 12:01:00 +0000 (UTC)
Subject: Re: [PATCH 1/5] mm/workingset: remove unused @mapping argument in
 workingset_eviction()
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>
References: <20190222174337.26390-1-aryabinin@virtuozzo.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <e56aea36-f454-a75f-5f83-4150b87c9c15@suse.cz>
Date: Mon, 25 Feb 2019 13:01:00 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190222174337.26390-1-aryabinin@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/22/19 6:43 PM, Andrey Ryabinin wrote:
> workingset_eviction() doesn't use and never did use the @mapping argument.
> Remove it.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> ---
>  include/linux/swap.h | 2 +-
>  mm/vmscan.c          | 2 +-
>  mm/workingset.c      | 3 +--
>  3 files changed, 3 insertions(+), 4 deletions(-)
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
> index dcb994f2acc2..0906137760c5 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -215,13 +215,12 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
>  
>  /**
>   * workingset_eviction - note the eviction of a page from memory
> - * @mapping: address space the page was backing
>   * @page: the page being evicted
>   *
>   * Returns a shadow entry to be stored in @mapping->i_pages in place

The line above still references @mapping, I guess kerneldoc build will
complain?

>   * of the evicted @page so that a later refault can be detected.
>   */
> -void *workingset_eviction(struct address_space *mapping, struct page *page)
> +void *workingset_eviction(struct page *page)
>  {
>  	struct pglist_data *pgdat = page_pgdat(page);
>  	struct mem_cgroup *memcg = page_memcg(page);
> 

