Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2637C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:26:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8045B2086D
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:26:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8045B2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37B926B026F; Fri, 12 Apr 2019 16:26:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 329236B0270; Fri, 12 Apr 2019 16:26:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CB0A6B0271; Fri, 12 Apr 2019 16:26:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDAF66B026F
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 16:26:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h22so4237563edh.1
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 13:26:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QlmwQJ0z4pq01Nq9vw0YVZgLTzke30ug0ObNOU9FAQs=;
        b=NQaJi1dIpY/yn7qCgZRIyeXDDfMdTyUMEOVR0Q/bAWIi3EQm+n/ERh9sqwZ/7w2Kwu
         M6qbv6boRd3G2mpUHpQEfI1LirJjkLrOkGHBSysu4TLPds2BXYaz38gWGc2ysKO0gTEh
         8M/TFdy5CJ99cPBCGxUe1RbgU1xnZMqZeE5bD1afBLqzmRdMOsBIJ7DwFLBwYFjUS66s
         ijjx0hzFFi03D1N2zSRvKSaM29VQFSuyHFer1X96G43AQE/IRRbYU5SquHx/WfM629bQ
         +puUNmZXcgWAhgfJn4F7DYdqWpV3eRLfKQsDSOYBZpOei64i86zKzayOJc22luDeWXj1
         K/Jg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWsFmfR8gVIwCkC98pWrZnKjUGjZVViLaEExqogY2nKGEO+qGP4
	jrB4gJ6rLC7bP9aqGiTuuT5EzjjG4TxV7FijDbRF4/6CPWeDsYKr5n4x5QilMTEs6KchTzXciwt
	TjlGGHDN+DdLzHOC/lEvdf+mINWYjx3QCYsNQTwltR64Pgrltw9VTaeB71S3M4Cw=
X-Received: by 2002:a17:906:3e85:: with SMTP id a5mr32687012ejj.272.1555100788309;
        Fri, 12 Apr 2019 13:26:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwy5tgfWMku9TtV/GInM5tPacTWhCeKPguxfuzRfRpsS3KbOpYrA9S2jbBtD/kU12ZvOZeF
X-Received: by 2002:a17:906:3e85:: with SMTP id a5mr32686979ejj.272.1555100787395;
        Fri, 12 Apr 2019 13:26:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555100787; cv=none;
        d=google.com; s=arc-20160816;
        b=lwRdy+w2WcCpuJEC0yAPqXSE+HJb0o3hXg99EUQKrkn63gIh5azjdYNGpC5p9Op809
         W/KJ7eSJyXunw0MiUjxl3d1Pc5AwpXH7dc4xSlCIfZK3rK60TM7gIwS0bVSq9c5jh3K6
         GBgleW/md0HM3muUv5sSmsTdC2iX4n6poQg31XDvJYuXok6P47wcAM3E9IesOEwCnUw1
         oPTBM3C848ATd86WWzgUO6Rs0W3MJqbYSjHAF6cvXMXucGEO18BW2HBFnZDGofFi+ACs
         VYCmoHYw7Wtt/LgH7OZ/YhAm6Fo9ALuCrL5FfdATX2nkSIWuW8/KHHLKQwAVbUAoNpcR
         s0LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QlmwQJ0z4pq01Nq9vw0YVZgLTzke30ug0ObNOU9FAQs=;
        b=SFsnOsQufl1vooi44YcYf/vLH9zHKTKkBPEfjfzNxS7HUv7g42m/B8d9M+iBRkc3x8
         4R1D2K8we+497Jy7im8D/TTP2+F/OkMDB0XIjUqAFvO3wLoswaLelrMF7M9R6ivf+jAx
         gOpaLqzqTI9qVgtcByrxXWAqeJ3Uk0ePUs9p1Gkw0sP8xMrSKCFNUQjrCAJiTQnLc1AS
         uHooiAbQuI26uG6JzjJELSMOXRlLV8ucjYtArmokrKDLdSRTMi6PTDVNF+KqFUCy35p7
         8cKE3lwZgpmU8LV29D91LHsStwtKzhWF+uUAoQXjFPzcoZsznGhFQeIkC4+78fIVIwRN
         Z1Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v16si5121613edy.33.2019.04.12.13.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 13:26:27 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BBE92AED0;
	Fri, 12 Apr 2019 20:26:26 +0000 (UTC)
Date: Fri, 12 Apr 2019 22:26:25 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, osalvador@suse.de, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm/hotplug: treat CMA pages as unmovable
Message-ID: <20190412202625.GJ5223@dhcp22.suse.cz>
References: <20190412152659.3916-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190412152659.3916-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-04-19 11:26:59, Qian Cai wrote:
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d96ca5bc555b..a9d2b0236167 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8005,7 +8005,10 @@ void *__init alloc_large_system_hash(const char *tablename,
>  bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  			 int migratetype, int flags)
>  {
> -	unsigned long pfn, iter, found;
> +	unsigned long found;
> +	unsigned long iter = 0;
> +	unsigned long pfn = page_to_pfn(page);
> +	char reason[] = "unmovable page";

	const char *reason = "unovable page";
>  
>  	/*
>  	 * TODO we could make this much more efficient by not checking every
> @@ -8015,17 +8018,20 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	 * can still lead to having bootmem allocations in zone_movable.
>  	 */
>  
> -	/*
> -	 * CMA allocations (alloc_contig_range) really need to mark isolate
> -	 * CMA pageblocks even when they are not movable in fact so consider
> -	 * them movable here.
> -	 */
> -	if (is_migrate_cma(migratetype) &&
> -			is_migrate_cma(get_pageblock_migratetype(page)))
> -		return false;
> +	if (is_migrate_cma(get_pageblock_migratetype(page))) {
> +		/*
> +		 * CMA allocations (alloc_contig_range) really need to mark
> +		 * isolate CMA pageblocks even when they are not movable in fact
> +		 * so consider them movable here.
> +		 */
> +		if (is_migrate_cma(migratetype))
> +			return false;
> +
> +		strscpy(reason, "CMA page", 9);

		reason = "CMA page";

> +		goto unmovable;
> +	}

Other than that looks good. After fixing the above, feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

-- 
Michal Hocko
SUSE Labs

