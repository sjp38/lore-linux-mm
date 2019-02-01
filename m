Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0469AC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 09:58:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB94C20857
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 09:58:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB94C20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 564788E0002; Fri,  1 Feb 2019 04:58:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 515C88E0001; Fri,  1 Feb 2019 04:58:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 404868E0002; Fri,  1 Feb 2019 04:58:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D6A038E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 04:58:41 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t2so2554955edb.22
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 01:58:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tQBht9A4XqV4woLTBjf7Nx+Rh/ptHiBz6js6MhWi5Uc=;
        b=mId/4rGXCkDqlU0SqFXXlvqGok1rmaPRO37dd3M/yKw9ZxirIZg9ntIsG7FVBR7jca
         S53i4/MDQ1kfDvf0TQLObNSqqesxO6BHFwJZm/cvpNYBu39ebSh539ozXRn+2nr4d28s
         IAV7qBYn1cbTsDcTFD1gfVP1hFqzLY9W1QxKnW0voT+vlPGur8GstjLH0S1R6ONPfCFg
         2LI52PC5fWJmLIYyWfvQgXmEzcNw7y0+4m9/3c/nVAiRNMT8roBHBa1hZjqkgijnm+UH
         j4WWhzqPZxNJoyke3KpDiCxgQ+rF3NYxJumh7BcMcbYbq65pXeIzWiMl7Bmv8wnoO6zi
         O49w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubq5QqUbBM9g/ZnCUkvTbS/Nf+Da4btq65i0AxmaNkU2swbGXmU
	4UIetNlS5GPm2uDX9SbP5VqSDSClT819kPeX2IP3CtnxvHSL8K0l3zoB2eQzauZNxTgqsvlgnZ6
	gbis4KsVNKSZyq7KhK4SSyQTnQaLghvNz6B4DYxefhjLx/hp8HGmntm9G5w3ifFE=
X-Received: by 2002:a17:906:53d7:: with SMTP id p23mr1643499ejo.210.1549015121232;
        Fri, 01 Feb 2019 01:58:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IausEMnGCottYoCk+rLMOl6LFPjEkvFe2OndlBT2e/ZR2H3ZDbnmRQEHPYqnzN6R8mR9j5R
X-Received: by 2002:a17:906:53d7:: with SMTP id p23mr1643439ejo.210.1549015120145;
        Fri, 01 Feb 2019 01:58:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549015120; cv=none;
        d=google.com; s=arc-20160816;
        b=IDMhgXHFptAYjPRIx7CY54GzPqCRf7islV2YTIFvGvWp/k4tlh1gG9K+HTAz1KSVaE
         TlSGlfsBhbil9Kl951pY1KTd/4B6xo6Uxr7e9hn5+h1GmDeEKZ8eMmpL2OR8ctgiWulN
         xjHSYe0m+JInj9IOPAeVG7XlOTa3QyU3I5LzvwF96PH1FKCseIDAXHWtxV4rL8zBW9IX
         wc04OuZg/x/gg+xNJh2kOOHCA+P95ATqpc2tgveONNs14iYS2PNMtYNG3qKz6IJPOS6J
         vSiUuurlKM9KbRAKDk4Ods4IrrjxP3b8nDfN4/bJjA7/gRiLUBGaytnPkSFK9J2c3znD
         CMeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tQBht9A4XqV4woLTBjf7Nx+Rh/ptHiBz6js6MhWi5Uc=;
        b=NZZRIFYdQEqcKYc+6+bBVLFACnmU7JpnP+vK388ot+zSWWdA9cMFP3ztGZ2CNHxLEk
         ZPh48Me7KlNKNHxCB7L6B7dZ6tGSm8DyFBkfwbAFmWm+QySE/3A4sjYl+GtIi7oJAIX4
         KkDEiM0YDryaAA/NzOpHTIKQJqlRIUfEmZXhXHs4PLV8kD/WeZ360roAXy9WmgZftTQQ
         cnU0LtWVhHcfDKsNHM3OTh+9dwGoQ5lggESeW6zdz/PipiutJyiW1d0Kdd7kVcc1AfyS
         44a/OHyQQFfntS+NA/GKdY9crPqZVaTqKnhJCoXb97IeY8k7PSDd+aqoqX5V6I7GclFA
         aJ8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b9si3585305eds.108.2019.02.01.01.58.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 01:58:40 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A2E9FAD43;
	Fri,  1 Feb 2019 09:58:39 +0000 (UTC)
Date: Fri, 1 Feb 2019 10:58:38 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Dave Hansen <dave.hansen@linux.intel.com>,
	Kees Cook <keescook@chromium.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, keith.busch@intel.com
Subject: Re: [PATCH v10 3/3] mm: Maintain randomization of page free lists
Message-ID: <20190201095838.GJ11599@dhcp22.suse.cz>
References: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154899812788.3165233.9066631950746578517.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154899812788.3165233.9066631950746578517.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 31-01-19 21:15:27, Dan Williams wrote:
> When freeing a page with an order >= shuffle_page_order randomly select
> the front or back of the list for insertion.
> 
> While the mm tries to defragment physical pages into huge pages this can
> tend to make the page allocator more predictable over time. Inject the
> front-back randomness to preserve the initial randomness established by
> shuffle_free_memory() when the kernel was booted.
> 
> The overhead of this manipulation is constrained by only being applied
> for MAX_ORDER sized pages by default.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mmzone.h |   12 ++++++++++++
>  mm/page_alloc.c        |   11 +++++++++--
>  mm/shuffle.c           |   23 +++++++++++++++++++++++
>  mm/shuffle.h           |   12 ++++++++++++
>  4 files changed, 56 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2274e43933ae..a3cb9a21196d 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -116,6 +116,18 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
>  	area->nr_free++;
>  }
>  
> +#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
> +/* Used to preserve page allocation order entropy */
> +void add_to_free_area_random(struct page *page, struct free_area *area,
> +		int migratetype);
> +#else
> +static inline void add_to_free_area_random(struct page *page,
> +		struct free_area *area, int migratetype)
> +{
> +	add_to_free_area(page, area, migratetype);
> +}
> +#endif
> +
>  /* Used for pages which are on another list */
>  static inline void move_to_free_area(struct page *page, struct free_area *area,
>  			     int migratetype)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3fd0df403766..2a0969e3b0eb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -43,6 +43,7 @@
>  #include <linux/mempolicy.h>
>  #include <linux/memremap.h>
>  #include <linux/stop_machine.h>
> +#include <linux/random.h>
>  #include <linux/sort.h>
>  #include <linux/pfn.h>
>  #include <linux/backing-dev.h>
> @@ -889,7 +890,8 @@ static inline void __free_one_page(struct page *page,
>  	 * so it's less likely to be used soon and more likely to be merged
>  	 * as a higher order page
>  	 */
> -	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)) {
> +	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)
> +			&& !is_shuffle_order(order)) {
>  		struct page *higher_page, *higher_buddy;
>  		combined_pfn = buddy_pfn & pfn;
>  		higher_page = page + (combined_pfn - pfn);
> @@ -903,7 +905,12 @@ static inline void __free_one_page(struct page *page,
>  		}
>  	}
>  
> -	add_to_free_area(page, &zone->free_area[order], migratetype);
> +	if (is_shuffle_order(order))
> +		add_to_free_area_random(page, &zone->free_area[order],
> +				migratetype);
> +	else
> +		add_to_free_area(page, &zone->free_area[order], migratetype);
> +
>  }
>  
>  /*
> diff --git a/mm/shuffle.c b/mm/shuffle.c
> index 8badf4f0a852..19bbf3e37fb6 100644
> --- a/mm/shuffle.c
> +++ b/mm/shuffle.c
> @@ -168,3 +168,26 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
>  	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
>  		shuffle_zone(z);
>  }
> +
> +void add_to_free_area_random(struct page *page, struct free_area *area,
> +		int migratetype)
> +{
> +	static u64 rand;
> +	static u8 rand_bits;
> +
> +	/*
> +	 * The lack of locking is deliberate. If 2 threads race to
> +	 * update the rand state it just adds to the entropy.
> +	 */
> +	if (rand_bits == 0) {
> +		rand_bits = 64;
> +		rand = get_random_u64();
> +	}
> +
> +	if (rand & 1)
> +		add_to_free_area(page, area, migratetype);
> +	else
> +		add_to_free_area_tail(page, area, migratetype);
> +	rand_bits--;
> +	rand >>= 1;
> +}
> diff --git a/mm/shuffle.h b/mm/shuffle.h
> index 644c8ee97b9e..fc1e327ae22d 100644
> --- a/mm/shuffle.h
> +++ b/mm/shuffle.h
> @@ -36,6 +36,13 @@ static inline void shuffle_zone(struct zone *z)
>  		return;
>  	__shuffle_zone(z);
>  }
> +
> +static inline bool is_shuffle_order(int order)
> +{
> +	if (!static_branch_unlikely(&page_alloc_shuffle_key))
> +                return false;
> +	return order >= SHUFFLE_ORDER;
> +}
>  #else
>  static inline void shuffle_free_memory(pg_data_t *pgdat)
>  {
> @@ -48,5 +55,10 @@ static inline void shuffle_zone(struct zone *z)
>  static inline void page_alloc_shuffle(enum mm_shuffle_ctl ctl)
>  {
>  }
> +
> +static inline bool is_shuffle_order(int order)
> +{
> +	return false;
> +}
>  #endif
>  #endif /* _MM_SHUFFLE_H */
> 

-- 
Michal Hocko
SUSE Labs

