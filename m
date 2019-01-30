Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41269C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:11:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BBB12087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:11:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BBB12087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A14578E000E; Wed, 30 Jan 2019 14:11:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99BFB8E0001; Wed, 30 Jan 2019 14:11:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 817158E000E; Wed, 30 Jan 2019 14:11:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3750A8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:11:26 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o9so353129pgv.19
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:11:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Nzecc/+f+80h8iU/Qz6OgkLmqq+g61F1cNBzZMRjDn8=;
        b=fh9zSwTOajgCB3/IiLO7Ef5G8dHwTkksEAo2RQ/ROzOl6Vp5b9EmGoASZBhFJ+6PTN
         bRlNZLd2q3sLWMqOk1XUkwI27bjkTmtcu8N4WgIomRo2Em/bgBinCsX87eh8dBCUNVtO
         pdP91L4MGf6cSlJl/cPX54RfKL2TP7ZZIy5i1QC82NPQ9Zei0vTVCClVFEJCh0traZ7g
         4cnr9bjEyTaojnZc07yJl7C5nlyi6GkAPsyrFlnaVROurkpoAdoIAJBqFkNttOtRiMtq
         8G4PzNfvuzE9jOUZoeJNLZyM/mISvh1+IdKupoATnLyw4CpcvjEkD1lz5P7bjDLrYcPO
         AZfQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdNtxsr7zZQbwJHYAtQYlYiOlegKINniogBoKKouPs1i51Mqz4D
	X5gx/C5uK9R11+jvC5/4JvKDr6hTIxfcaaqkfoH2nK+nGW3kDPBbYVYOELBldpPCLjugmiaYyYH
	EUSC6neP0xAEKdy/xUnCxdmlfFQaJXk07UocBNIMVkTtfc9pFXKbFU9MHSdkJXqk=
X-Received: by 2002:a17:902:20c8:: with SMTP id v8mr32058109plg.319.1548875485841;
        Wed, 30 Jan 2019 11:11:25 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6EZg2qCoQDM2kpwh00q7vTMKrYiq6S0n6k+/1EEVyF+/O1OcSy1WIc31P29RC3t4lzJ3AN
X-Received: by 2002:a17:902:20c8:: with SMTP id v8mr32058066plg.319.1548875485132;
        Wed, 30 Jan 2019 11:11:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548875485; cv=none;
        d=google.com; s=arc-20160816;
        b=FmCFr+IX65DQXojpDQ8FEJjwOC0CKNHhf6E/1UmLDBRw3NNoehf19bktIdKYY/0qAP
         Cu91mxG0tD+0bpWD2/ht2jjv0oc8RaLXDIGa8RvJxx8wdLLbyUoSMc+NrZlfheqCftGA
         MR9etwStozQa8sKDHXfbcfRaEjOJDwarqS6dZRI8t+5JvkBPw5ZOT2II81JSw9yJ8N61
         QT3RrpR2BcpPwJKZ4RXBatZr4lrbWLWlAhWVBl4ZQRkhLWAu3yEKeE+EKTseSjm6Yk6A
         m5t3PCzUzKWCHilKcbZvFALGHOfPp5HTMWKvvRhcpsSud1ToYu3UX5Gwd1+YV0F/7VCN
         dGNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Nzecc/+f+80h8iU/Qz6OgkLmqq+g61F1cNBzZMRjDn8=;
        b=LKMLBykiygZHIWD5vDYj4zJLZsAeSq7qAnlKChxPQnHKXB6CINYQ8vsTOyw8PBx9uD
         OF75aC8/oLCoxdlshnzXOOi3mLLA8Be7svWZdF86uxMzvY+M0bUUE0HveCEsi8NFRUZ5
         pcdoTp5W6OlYS9f1XlB328VuGIglIgtpqCGcBEHBOCWeHE8IPjEEVsSUBe1joCzqGU16
         nEhr0/IIk7sibpOa2EPvAXXxu2jwlncO3pOla1czqYXl2ef6+P7QgcTgvrVW7Jy4S7gu
         hf7AnGtlE04JZdcg+teCSwXgv/Y3j/U6MBv+QjMagwzXAxoDDx+DDY2PCY+m48Nxgyc5
         oNkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 80si2289141pfz.11.2019.01.30.11.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 11:11:25 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6E8A5AD7A;
	Wed, 30 Jan 2019 19:11:23 +0000 (UTC)
Date: Wed, 30 Jan 2019 20:11:17 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Dave Hansen <dave.hansen@linux.intel.com>,
	Kees Cook <keescook@chromium.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 3/3] mm: Maintain randomization of page free lists
Message-ID: <20190130191117.GH18811@dhcp22.suse.cz>
References: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154882454628.1338686.46582179767934746.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154882454628.1338686.46582179767934746.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 29-01-19 21:02:26, Dan Williams wrote:
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

I have asked in v7 but didn't get any response. Do we really ned per
free_area random pool? Why a global one is not sufficient?

> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/mmzone.h  |   12 ++++++++++++
>  include/linux/shuffle.h |   12 ++++++++++++
>  mm/page_alloc.c         |   11 +++++++++--
>  mm/shuffle.c            |   16 ++++++++++++++++
>  4 files changed, 49 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 6ab8b58c6481..d42aafe23045 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -98,6 +98,10 @@ extern int page_group_by_mobility_disabled;
>  struct free_area {
>  	struct list_head	free_list[MIGRATE_TYPES];
>  	unsigned long		nr_free;
> +#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
> +	u64			rand;
> +	u8			rand_bits;
> +#endif
>  };
>  
>  /* Used for pages not on another list */
> @@ -116,6 +120,14 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
>  	area->nr_free++;
>  }
>  
> +#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
> +/* Used to preserve page allocation order entropy */
> +void add_to_free_area_random(struct page *page, struct free_area *area,
> +		int migratetype);
> +#else
> +#define add_to_free_area_random add_to_free_area
> +#endif
> +
>  /* Used for pages which are on another list */
>  static inline void move_to_free_area(struct page *page, struct free_area *area,
>  			     int migratetype)
> diff --git a/include/linux/shuffle.h b/include/linux/shuffle.h
> index bed2d2901d13..649498442aa0 100644
> --- a/include/linux/shuffle.h
> +++ b/include/linux/shuffle.h
> @@ -29,6 +29,13 @@ static inline void shuffle_zone(struct zone *z)
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
> @@ -41,5 +48,10 @@ static inline void shuffle_zone(struct zone *z)
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
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1cb9a467e451..7895f8bd1a32 100644
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
> index db517cdbaebe..0da7d1826c6a 100644
> --- a/mm/shuffle.c
> +++ b/mm/shuffle.c
> @@ -186,3 +186,19 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
>  	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
>  		shuffle_zone(z);
>  }
> +
> +void add_to_free_area_random(struct page *page, struct free_area *area,
> +		int migratetype)
> +{
> +	if (area->rand_bits == 0) {
> +		area->rand_bits = 64;
> +		area->rand = get_random_u64();
> +	}
> +
> +	if (area->rand & 1)
> +		add_to_free_area(page, area, migratetype);
> +	else
> +		add_to_free_area_tail(page, area, migratetype);
> +	area->rand_bits--;
> +	area->rand >>= 1;
> +}
> 

-- 
Michal Hocko
SUSE Labs

