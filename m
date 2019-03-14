Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 330A3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:05:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB46A21019
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:05:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB46A21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 658468E0003; Thu, 14 Mar 2019 04:05:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 609958E0001; Thu, 14 Mar 2019 04:05:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F85A8E0003; Thu, 14 Mar 2019 04:05:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E602A8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 04:05:25 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i59so2024152edi.15
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:05:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Tu9oo3vqaWLlmVIi+6dEWemlMDSkRQ+l4lW0iKtc+ck=;
        b=gzyd8G8e64AnLumYqW0YJ7ZMRaw+HWPzQd57lpMqPgC1KPVk3ZARdDtcOWQMzqAy0E
         4R0yUbNdNrH6p3iH3x4D2oXwkB6pgmaiMoLh+j04XyTNhJn0vS4tKy5lcnxO6tDzDatp
         FDpvIQw2gTUMuIsMk+wt3J6H0GJs73UtvYsc1GxsOcLhlwotNsk5dli26Ee/sJO+pcXx
         Q+Ws1mfGjPMHWGCs0HMTKC+IlpsBnSaM9PWkblJx+SH2rUItnpjL2QB/1rYrUc3r6yj9
         5AbvxKytfDKesUQ0DEKm7QYiabQml6me5PwtAiZybcEXnp8tgxy9FlAWn+Jf7KZAx3aE
         4ktA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW33t72ASvBx/tNOtq/BAKCfN6dcMaWcnX7lrhw20JiiWDWgdkd
	sntUdozPaGuHNODdcf+u5HdAHOsya4ue/hp1E2Ih4bvAv9sHtmMOQhyFCaTD3C8R2Idjlibq0h2
	PFx3N8Yox7YZKw6EISjp225RP15M4BpYUXQWPfvZb8jNYFdvgQOIcUKx55GkHOsc=
X-Received: by 2002:a17:906:3592:: with SMTP id o18mr5016730ejb.28.1552550725470;
        Thu, 14 Mar 2019 01:05:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymQacJLC4FW/atdQEQFNp3BI5UkSAycn8KsnIQpsaAUz/2ooH3ZluIVST9gUhkwuTG0Hi2
X-Received: by 2002:a17:906:3592:: with SMTP id o18mr5016678ejb.28.1552550724355;
        Thu, 14 Mar 2019 01:05:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552550724; cv=none;
        d=google.com; s=arc-20160816;
        b=b8euRNWHv9aU+VQnVfkFPrsf0xLbRs3nK5FeOBNC6aQ5zhALvwB/0flq/sT6YLVaMp
         9g9/WyDpgRIGSG9XWYC11sL2XBoiVOlmLywI0m/y21MMZAVH1hYNZws0hKYNMPxl4mwD
         wSUdJzNcXsnx+ijeQK7IfieltmwC04F4Oitmt8D57zMti+izcN7L6VDZ+kgT5s4ktwjR
         Cf0CmiFUzavDJUZ0tBcipXMxZnNXIxAjbvVCog/e1pbxrPQSOMt2AXDB6mOj3bKwu1rO
         bmPQKs2UWeVCm7cnp9weW0G8UvIZlPHwyNVV/CqK7EAPDr6NqC+vrftEzLbjSZsy6p99
         33DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Tu9oo3vqaWLlmVIi+6dEWemlMDSkRQ+l4lW0iKtc+ck=;
        b=Y3DMHi+TDt6ifXwgjcLZz0MvUBc64T2G0r2H9pEoT3l1IHslQsFCxKd+ftOS7wG1cj
         TJxOawwSGZAB/cwDbRXKQ5P91BqkG12m7u5FTlscdenlkSiNWmVIxZRu0fUSV1LltivT
         vMBLzBL/v0fBJLujRRddduEtLRZbmojgpyUtmEcSmdSXiClww/OWKH0MWKWPCfGopH1R
         KBpclyUaeCXp/sZJK+ThxMQOlKECVcDAK1N4/l5QC5lIcswnjmZCvvo2dLNJX1JfiPPJ
         UZKyatdDrLrog1EIj0nWAfrsuniD1mpRiJJtr/n8U1EAo8iHwwcogjRllgJ382GV+ntO
         0qkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p18si1652530eds.250.2019.03.14.01.05.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 01:05:24 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D970EACC1;
	Thu, 14 Mar 2019 08:05:23 +0000 (UTC)
Date: Thu, 14 Mar 2019 09:05:22 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, osalvador@suse.de, vbabka@suse.cz,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm/hotplug: fix offline undo_isolate_page_range()
Message-ID: <20190314080522.GC7473@dhcp22.suse.cz>
References: <20190313143133.46200-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313143133.46200-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-03-19 10:31:33, Qian Cai wrote:
> The commit f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded
> memory to zones until online") introduced move_pfn_range_to_zone() which
> calls memmap_init_zone() during onlining a memory block.
> memmap_init_zone() will reset pagetype flags and makes migrate type to
> be MOVABLE.
> 
> However, in __offline_pages(), it also call undo_isolate_page_range()
> after offline_isolated_pages() to do the same thing. Due to
> the commit 2ce13640b3f4 ("mm: __first_valid_page skip over offline
> pages") changed __first_valid_page() to skip offline pages,
> undo_isolate_page_range() here just waste CPU cycles looping around the
> offlining PFN range while doing nothing, because __first_valid_page()
> will return NULL as offline_isolated_pages() has already marked all
> memory sections within the pfn range as offline via
> offline_mem_sections().
> 
> Also, after calling the "useless" undo_isolate_page_range() here, it
> reaches the point of no returning by notifying MEM_OFFLINE. Those pages
> will be marked as MIGRATE_MOVABLE again once onlining. The only thing
> left to do is to decrease the number of isolated pageblocks zone
> counter which would make some paths of the page allocation slower that
> the above commit introduced. A memory block is usually at most 1GiB in
> size, so an "int" should be enough to represent the number of pageblocks
> in a block. Fix an incorrect comment along the way.
> 
> Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")

Cc: stable # 4.13+

> Signed-off-by: Qian Cai <cai@lca.pw>

Yes, this looks good.

Acked-by: Michal Hocko <mhocko@suse.com>

I would just ask you to add a return value of start_isolate_page_range documentation.

Thanks!
> ---
> 
> v2: return the nubmer of isolated pageblocks in start_isolate_page_range() per
>     Oscar; take the zone lock when undoing zone->nr_isolate_pageblock per
>     Michal.
> 
>  mm/memory_hotplug.c | 17 +++++++++++++----
>  mm/page_alloc.c     |  2 +-
>  mm/page_isolation.c | 16 ++++++++++------
>  mm/sparse.c         |  2 +-
>  4 files changed, 25 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index cd23c081924d..8ffe844766da 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1580,7 +1580,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  {
>  	unsigned long pfn, nr_pages;
>  	long offlined_pages;
> -	int ret, node;
> +	int ret, node, count;
>  	unsigned long flags;
>  	unsigned long valid_start, valid_end;
>  	struct zone *zone;
> @@ -1606,10 +1606,11 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	ret = start_isolate_page_range(start_pfn, end_pfn,
>  				       MIGRATE_MOVABLE,
>  				       SKIP_HWPOISON | REPORT_FAILURE);
> -	if (ret) {
> +	if (ret < 0) {
>  		reason = "failure to isolate range";
>  		goto failed_removal;
>  	}
> +	count = ret;
>  
>  	arg.start_pfn = start_pfn;
>  	arg.nr_pages = nr_pages;
> @@ -1661,8 +1662,16 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	/* Ok, all of our target is isolated.
>  	   We cannot do rollback at this point. */
>  	offline_isolated_pages(start_pfn, end_pfn);
> -	/* reset pagetype flags and makes migrate type to be MOVABLE */
> -	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> +
> +	/*
> +	 * Onlining will reset pagetype flags and makes migrate type
> +	 * MOVABLE, so just need to decrease the number of isolated
> +	 * pageblocks zone counter here.
> +	 */
> +	spin_lock_irqsave(&zone->lock, flags);
> +	zone->nr_isolate_pageblock -= count;
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +
>  	/* removal success */
>  	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
>  	zone->present_pages -= offlined_pages;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 03fcf73d47da..d96ca5bc555b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8233,7 +8233,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  
>  	ret = start_isolate_page_range(pfn_max_align_down(start),
>  				       pfn_max_align_up(end), migratetype, 0);
> -	if (ret)
> +	if (ret < 0)
>  		return ret;
>  
>  	/*
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index ce323e56b34d..bf67b63227ca 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -172,7 +172,8 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
>   * future will not be allocated again.
>   *
>   * start_pfn/end_pfn must be aligned to pageblock_order.
> - * Return 0 on success and -EBUSY if any part of range cannot be isolated.
> + * Return the number of isolated pageblocks on success and -EBUSY if any part of
> + * range cannot be isolated.
>   *
>   * There is no high level synchronization mechanism that prevents two threads
>   * from trying to isolate overlapping ranges.  If this happens, one thread
> @@ -188,6 +189,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  	unsigned long pfn;
>  	unsigned long undo_pfn;
>  	struct page *page;
> +	int count = 0;
>  
>  	BUG_ON(!IS_ALIGNED(start_pfn, pageblock_nr_pages));
>  	BUG_ON(!IS_ALIGNED(end_pfn, pageblock_nr_pages));
> @@ -196,13 +198,15 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  	     pfn < end_pfn;
>  	     pfn += pageblock_nr_pages) {
>  		page = __first_valid_page(pfn, pageblock_nr_pages);
> -		if (page &&
> -		    set_migratetype_isolate(page, migratetype, flags)) {
> -			undo_pfn = pfn;
> -			goto undo;
> +		if (page) {
> +			if (set_migratetype_isolate(page, migratetype, flags)) {
> +				undo_pfn = pfn;
> +				goto undo;
> +			}
> +			count++;
>  		}
>  	}
> -	return 0;
> +	return count;
>  undo:
>  	for (pfn = start_pfn;
>  	     pfn < undo_pfn;
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 69904aa6165b..56e057c432f9 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -567,7 +567,7 @@ void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -/* Mark all memory sections within the pfn range as online */
> +/* Mark all memory sections within the pfn range as offline */
>  void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  {
>  	unsigned long pfn;
> -- 
> 2.17.2 (Apple Git-113)

-- 
Michal Hocko
SUSE Labs

