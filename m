Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78D53C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:07:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 406FF206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:07:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 406FF206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCA216B0005; Wed, 17 Apr 2019 10:07:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C789B6B0006; Wed, 17 Apr 2019 10:07:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8FDB6B0007; Wed, 17 Apr 2019 10:07:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8936B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:07:04 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g1so12857919edm.16
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:07:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=f0Xfzagf+Vy+C6r+wVa1vzukFKyiArqmFJ9ke9TdA+w=;
        b=faTgaIdDJZvGLz6kvo7ljjW8ETHm2ix8KJnCVOOYinylot+kamT83ngt+/e0U/XSt2
         bO7PVBYQpem4xgsNnNjBCTALb/KBcSJOv6lRr7YwUqqBGlAmq7Dz3DlW7OU/GBvnKpHt
         f6yzdKAViDhOUQMun46/oEE7VLr9OWaKHuLDbLZ/h03TDB5ja4ksRk/rh1BKBZEBWHww
         EUhKSyejip/+ObEkwkZN2fjCvq8WaMALVTErNiDX5FFrSFV5HpoZir2+6bL2P+8auXKx
         YUCS5qfuy85TXobR+OHZEk/iCtSHAh153AIJCZ/fSeKtxKDnwJ8sLuHJqfffTw6vG7Ur
         TvQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXAYqY+UZgfySuLaIfJ47XalDJqIbT9zK6qEOqcSclKUf0chtCa
	Osop70SiYtL4zexlSmTuLyBRWQhfMrwrggxep9bvbbMohG25hdPu8yCuzq4uDPi7y8mV8mm21SJ
	NEdVfyEc/dOz69b/nv0pMqwvLcmHD7Bf31ZiEQmzIKDFrDGl2HQs3gexgmeqXpV2nfw==
X-Received: by 2002:a50:b1b0:: with SMTP id m45mr24279590edd.82.1555510023767;
        Wed, 17 Apr 2019 07:07:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaBnYbUaG9DpZgRz1HpwFQ7CiKv+oDlQUB5lboYgIKdQ4igGMvFmG7Z+lncHwpAznyUqlM
X-Received: by 2002:a50:b1b0:: with SMTP id m45mr24279531edd.82.1555510022767;
        Wed, 17 Apr 2019 07:07:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555510022; cv=none;
        d=google.com; s=arc-20160816;
        b=OzCFaTULpmHwtTciDE3u5kU0R6K1MAnsdRmwTwZUt2tudL4NcLGVHcZrNa/IhFCBye
         0qWasuwH6ThZ16KjsLYxApyzOfeeju/8dvJn35znKQyRx+XP64+pl8JzQaMkX4RZ/6sS
         y7Cm9cUTA0bgPZJFEK5lESBG+NSjci/kvnh6X5wBlc4XmPgbucVrO0KUvTUmPsiV6Cko
         6xgXxdYIxcShOlfPOIOvEACK4iAmb4chuiQmSt1tfyrPFk0ObIEQ2YgxojiuaK1MENll
         dPkoQj1xq6EO/dKIeYSNu8jssC7tmeaboaPJtmDP5GDliChM38WjJa3EeLm2bhDGLo1u
         U8Tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=f0Xfzagf+Vy+C6r+wVa1vzukFKyiArqmFJ9ke9TdA+w=;
        b=WJEpHpXf0lYlgAuo3BwUz+q2RBED+2HZb2Tquyc+rvdZCJUA15cEdgJBHkjxJvbQvy
         cMvTyIRCidlXlfRKCb/pT9/Q2dm030EqE7I1r9ddCo6aQ/iTuQIzqF227Ur8k4Y9j7Ma
         s3FpNuFS0dzEqBPZhcGrBpBrxvrMi9mIN1yUhzWkeSH49Iwl0lIKlDScO5l9qnUj4Qqr
         J0EoH7BmGUtKtU8L76HI9EKjvgk4RugD7YLZXzwo9bkG6HT+cORTSyAZbJ/P3TW+KhDF
         1l0e268QBa19IECJbQR5GIpxb7MXGjsPSeEv6VFLzvnL4lVDepsc622igLwGtStmNwdP
         pUAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q18si6950857ejr.51.2019.04.17.07.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 07:07:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4B2E1B17E;
	Wed, 17 Apr 2019 14:07:02 +0000 (UTC)
Message-ID: <1555510005.3139.36.camel@suse.de>
Subject: Re: [PATCH v4] mm/hotplug: treat CMA pages as unmovable
From: Oscar Salvador <osalvador@suse.de>
To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org
Cc: mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Vlastimil Babka
	 <vbabka@suse.cz>
Date: Wed, 17 Apr 2019 16:06:45 +0200
In-Reply-To: <20190416170510.20048-1-cai@lca.pw>
References: <20190416170510.20048-1-cai@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Qian Cai <cai@lca.pw>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
> 
> v4: Use is_migrate_cma_page() and update the commit log per
> Vlastimil.
> v3: Use a string pointer instead of an array per Michal.
> v2: Borrow some commit log texts.
>     Call dump_page() in the error path.
> 
>  mm/page_alloc.c | 30 ++++++++++++++++++------------
>  1 file changed, 18 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d96ca5bc555b..c6ce20aaf80b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8005,7 +8005,10 @@ void *__init alloc_large_system_hash(const
> char *tablename,
>  bool has_unmovable_pages(struct zone *zone, struct page *page, int
> count,
>  			 int migratetype, int flags)
>  {
> -	unsigned long pfn, iter, found;
> +	unsigned long found;
> +	unsigned long iter = 0;
> +	unsigned long pfn = page_to_pfn(page);
> +	const char *reason = "unmovable page";
>  
>  	/*
>  	 * TODO we could make this much more efficient by not
> checking every
> @@ -8015,17 +8018,20 @@ bool has_unmovable_pages(struct zone *zone,
> struct page *page, int count,
>  	 * can still lead to having bootmem allocations in
> zone_movable.
>  	 */
>  
> -	/*
> -	 * CMA allocations (alloc_contig_range) really need to mark
> isolate
> -	 * CMA pageblocks even when they are not movable in fact so
> consider
> -	 * them movable here.
> -	 */
> -	if (is_migrate_cma(migratetype) &&
> -			is_migrate_cma(get_pageblock_migratetype(pag
> e)))
> -		return false;
> +	if (is_migrate_cma_page(page)) {
> +		/*
> +		 * CMA allocations (alloc_contig_range) really need
> to mark
> +		 * isolate CMA pageblocks even when they are not
> movable in fact
> +		 * so consider them movable here.
> +		 */
> +		if (is_migrate_cma(migratetype))
> +			return false;
> +
> +		reason = "CMA page";
> +		goto unmovable;
> +	}
>  
> -	pfn = page_to_pfn(page);
> -	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++)
> {
> +	for (found = 0; iter < pageblock_nr_pages; iter++) {
>  		unsigned long check = pfn + iter;
>  
>  		if (!pfn_valid_within(check))
> @@ -8105,7 +8111,7 @@ bool has_unmovable_pages(struct zone *zone,
> struct page *page, int count,
>  unmovable:
>  	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
>  	if (flags & REPORT_FAILURE)
> -		dump_page(pfn_to_page(pfn+iter), "unmovable page");
> +		dump_page(pfn_to_page(pfn + iter), reason);
>  	return true;
>  }
>  
-- 
Oscar Salvador
SUSE L3

