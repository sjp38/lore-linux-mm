Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E807DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:10:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FDD22184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:10:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FDD22184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BFC58E0003; Thu, 14 Mar 2019 04:10:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36C348E0001; Thu, 14 Mar 2019 04:10:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2357E8E0003; Thu, 14 Mar 2019 04:10:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B56538E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 04:10:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r7so1999891eds.18
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:10:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QuYTpGByc/qy+K+SiwttBAeYqUp7FXrfw/6Xq9by67w=;
        b=OmmuXxYfdrHOBuFoS2HzQz7zTsheggtwGg6LBHriX8lO7IZqpqOeq0Dk3Mirnr08eA
         GGX2acubUB8sZNRQb8RVonXv4AjfURaYp9ZlgdLWHCo/DY4b5bJjcvVGcIlzj+DDH4Tw
         VrH3NNOF5R9EdfHy/GM9Jwj9HeyFdGKultnlj042k+Y6ZWVA2LlLfVuxGGLCbw02tf6X
         Ymic7m8UC2Wh32Sr+hHV9HqxIi8oK2lrxj6baUY4rXWugZTXIZnTgL7vjZFI1KXOGq99
         YBXVwi5tdcs7X8Dt18cbeijr6O6fP46jMnvP6X1A5BWLd64kTk89OkZR+Q2dm7Fg2uBw
         gI1w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAU2Xi2LKqY/UWNkreEEbIYOzqXqY56xzbjjRiz6q+8pZxoRiREa
	ZkvX9Oxv0R6DHUFJQhpiHDLqRptGePBzEpqQeWadNCgzQqfarBcpkuc0/koyotMarulUEnlOoN0
	BSKDk5Aoftte5XYiYrcVL3A7YDB4mBqfhg7ECpywN+5mJohB/JMFwbmp9N6GZ3UU=
X-Received: by 2002:aa7:d752:: with SMTP id a18mr10862621eds.15.1552551053310;
        Thu, 14 Mar 2019 01:10:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxAW3oU8G3o5F6Knak622X0bHT3Xxvv7eNAgldzuIlBgPaxE7H1pYSoguujl4366NRqvfa
X-Received: by 2002:aa7:d752:: with SMTP id a18mr10862559eds.15.1552551052398;
        Thu, 14 Mar 2019 01:10:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552551052; cv=none;
        d=google.com; s=arc-20160816;
        b=uWVFnH33hHjCq5qP9UpJctA23Ij0ex7XdfyqxtbYb16yuKi1sSNbthx0P8omAUXDdf
         s/HpNTEF0iV6LiZoMT+o/uDzLv0iCMigxcauaSq1/HpY73UwEuGzitm+T98EEXogHZKq
         ICQRnAeSMoh/AvlLmIgE+Pjdfg7FhB6hkOay47EBEwniAlo2AywONNReTlk2VNTFcUl1
         qFNABZcIOCFezx+UtQdPN8BDbB5zHQ4zgJUXj3cGJdKYC3WXu6DrTkHr1ilNSiwjrXVz
         dB+gAlls4Iw22yV086O3osAel6LCiHplhOgyku46sNp9Ooim47xwdAmfwpAtViOlM9R+
         B5VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QuYTpGByc/qy+K+SiwttBAeYqUp7FXrfw/6Xq9by67w=;
        b=pOXBaVw4xIvSVek8ii20KNLEIHOWODptKe9I18wwM6/MbkttrdGWxqbg6EH+QXmgfD
         3dWkOfxJsCR4uhK0eYGtw/TdDyyh0SYAMluHXcpZOgeti4NcJ2V0eZx/Iamkkp4OhUJs
         dgRPA2LnaFQt555BF8kJ8nSbGJP2JIcNcQgM4yc2pnPcqYta1vrXLsFKy4h/BuSktxBI
         dJU00BIFy+VJLk7JuGtKbp4z3wwMWJmRF5oOJkLJcSa9MEAgLnQvsRpRn6NhzVZ9XjKZ
         2Pt1eH6CYpNDQ11iQNzAt2SEHntKdeSFuixyWLObvUao8/+aqAn9/0sWLvpSu9+uikSn
         Q7rA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id m2si962106ejj.60.2019.03.14.01.10.52
        for <linux-mm@kvack.org>;
        Thu, 14 Mar 2019 01:10:52 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 1DDE14573; Thu, 14 Mar 2019 09:10:52 +0100 (CET)
Date: Thu, 14 Mar 2019 09:10:52 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm/hotplug: fix offline undo_isolate_page_range()
Message-ID: <20190314081052.cdp5sf6tlpvcc2ec@d104.suse.de>
References: <20190313143133.46200-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313143133.46200-1-cai@lca.pw>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 10:31:33AM -0400, Qian Cai wrote:
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
> Signed-off-by: Qian Cai <cai@lca.pw>

Forgot it:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

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
> 

-- 
Oscar Salvador
SUSE L3

