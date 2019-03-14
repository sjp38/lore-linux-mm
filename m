Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7F56C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:23:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 984B920657
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:23:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 984B920657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 337878E0003; Thu, 14 Mar 2019 10:23:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BF548E0001; Thu, 14 Mar 2019 10:23:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 188C18E0003; Thu, 14 Mar 2019 10:23:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B03278E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 10:23:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x21so2119969edr.17
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 07:23:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QGlXpQeneKQSUYIMIWDzkxiCPUwq6qQ50H1vRsXWC6w=;
        b=EZ43tt3GmOrUCoJF7Zp9BRSp78wu2M9fsPiPzUmnN6Hec4BE01zCA1JUdfXp74M+mN
         LMJUDGoI0kN6wKJuMOkJ2+c76Mk5X/AgRcjSu9gKLqLSg5ESS1CyZz3BUREtl+vO+/0m
         8m6b3QyyeKopmiUWuqkCDACO7bNgIalxlJVFheVuNowsN37xCiFnwBtHNJL0pTh27cZT
         /90r6C6yBcKhUhfKj/9IvblgE22LlFiMTPklgnrhZM7VRi6tb9QRMcZ4KQRx6rjH3Gy5
         SYlD+Zn/Ao3gZSFNVdw9SSDlF6e9lK7zRHg2EjgclkpKqacm/U/qoo3oR5x2+uARxM6M
         zBIg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUH+Oy1YRid9o1PQXUMtnBN02Xq/bNif/60mVTy3b9aEKdBLpqq
	kTwDtrgDHzhHi3cHoSaVwZZhgri5vGZXmRHdf9sxaAUXd3ZI5lD8sQhuJWkxl6NgCBOMgJDB+F5
	oa6P3N5+RiSTJ6ZRHsfb05k6aP8s1ygCogJAgCu2bYKleUD/NizEzsm6wtgeRWTA=
X-Received: by 2002:a05:6402:603:: with SMTP id n3mr11636838edv.255.1552573399177;
        Thu, 14 Mar 2019 07:23:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyojh04NC+qo4tJ4LNj2UiJq+UOih+qAvi0gn8xNrDkSF18TCsQ2YXM2z0XLdZhu72Z5yTv
X-Received: by 2002:a05:6402:603:: with SMTP id n3mr11636768edv.255.1552573398005;
        Thu, 14 Mar 2019 07:23:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552573398; cv=none;
        d=google.com; s=arc-20160816;
        b=bsXoq49yczHn8m2TH4pj7wPZsz49qGSE/xklveq2qKbPa1cRIxr0bWxGZbBdbcfnCM
         LHJqdBuP6BjkiqMcvmrZowmR3X6dNwYXYgItnkxJwZVAaME7fjqWvNQYwOiRJRZBeNEf
         +6M5GWHGMFgHRgKM+DXasA9HJtjrs3F6FizjqKObOINF71FwdYBgsyZ+yj0MYnNrLOzM
         Y/Bmg3TwAXEhOsXnNFdRfFB+5by7toOKb98rLvbEV195+lYRC3rJWyL5Nw0kBK8OXfiA
         Ztk3DUalFmsPrIabGFaNf84H/EA8WlOZcFoWh/7ErQlZ4G36UKci4H7uHtrz/2t5NuXX
         4YFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QGlXpQeneKQSUYIMIWDzkxiCPUwq6qQ50H1vRsXWC6w=;
        b=zO8m0qIPZYYws4SEdMXXpcmXC6FPy0LfQda3BZjMjLZQKeKnoZOybJXdn22rUJ1lZa
         7bJh/LdZ7/Un6nvxCjdKrDuBCvnbcYZJVKVIMOrkZdVz+fiI3yxQhPFrfAkn9yVHGD4i
         R/2+kh7GYgMpIIvlhehNyYbYaSqVG6JuJXU9OZvILta2FJRSaPJItU16XQcDoc0eMfVl
         GFGjqtUPMRtyE+sIsEQNZCuZsz6r786Ws9mvPAiJkqk6+2oILsIt7ZumZux7uPSifEC2
         MZ7l6AP5oZY4p9Uve+4vcpsODWDn+0PlWKbMGy4+k9CKa98pJQydH1v/FPdQqCDm3Qa3
         hS1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r6si234617eji.164.2019.03.14.07.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 07:23:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7AE4EAFF9;
	Thu, 14 Mar 2019 14:23:17 +0000 (UTC)
Date: Thu, 14 Mar 2019 15:23:17 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, osalvador@suse.de, vbabka@suse.cz,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] mm/hotplug: fix offline undo_isolate_page_range()
Message-ID: <20190314142317.GN7473@dhcp22.suse.cz>
References: <20190314140654.58883-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314140654.58883-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-03-19 10:06:54, Qian Cai wrote:
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
> the above commit introduced.
> 
> Even if alloc_contig_range() can be used to isolate 16GB-hugetlb pages
> on ppc64, an "int" should still be enough to represent the number of
> pageblocks there. Fix an incorrect comment along the way.
> 
> Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
> Signed-off-by: Qian Cai <cai@lca.pw>

Thanks for updating the doc. Looks good to me. I just guess you wanted
to make the doc a full kerneldoc and start it as /**

Other than that
Acked-by: Michal Hocko <mhocko@suse.com>

Just wondering, is there any specific reason to not consider the patch
for stable trees? While not critical, pushing some hotpaths into slower
mode is quite annoying. I cannot say this would be visible but it is
certainly an unintended behavior and the patch is reasonably safe to
backport so I would include it.

> ---
> 
> v3: Reconstruct the kernel-doc comments.
>     Use a more meaningful variable name per Oscar.
>     Update the commit log a bit.
> v2: Return the nubmer of isolated pageblocks in start_isolate_page_range() per
>     Oscar; take the zone lock when undoing zone->nr_isolate_pageblock per
>     Michal.
> 
>  include/linux/page-isolation.h |  4 ----
>  mm/memory_hotplug.c            | 17 +++++++++++++----
>  mm/page_alloc.c                |  2 +-
>  mm/page_isolation.c            | 35 +++++++++++++++++++++-------------
>  mm/sparse.c                    |  2 +-
>  5 files changed, 37 insertions(+), 23 deletions(-)
> 
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 4eb26d278046..5b24d56b2296 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -47,10 +47,6 @@ int move_freepages_block(struct zone *zone, struct page *page,
>   * For isolating all pages in the range finally, the caller have to
>   * free all pages in the range. test_page_isolated() can be used for
>   * test it.
> - *
> - * The following flags are allowed (they can be combined in a bit mask)
> - * SKIP_HWPOISON - ignore hwpoison pages
> - * REPORT_FAILURE - report details about the failure to isolate the range
>   */
>  int
>  start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d63c5a2959cf..cd1a8c4c6183 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1580,7 +1580,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  {
>  	unsigned long pfn, nr_pages;
>  	long offlined_pages;
> -	int ret, node;
> +	int ret, node, nr_isolate_pageblock;
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
> +	nr_isolate_pageblock = ret;
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
> +	zone->nr_isolate_pageblock -= nr_isolate_pageblock;
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
> index e8baab91b1d1..dd7c002cd5ae 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -162,19 +162,22 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
>  }
>  
>  /*
> - * start_isolate_page_range() -- make page-allocation-type of range of pages
> - * to be MIGRATE_ISOLATE.
> - * @start_pfn: The lower PFN of the range to be isolated.
> - * @end_pfn: The upper PFN of the range to be isolated.
> - * @migratetype: migrate type to set in error recovery.
> + * start_isolate_page_range() - make page-allocation-type of range of pages to
> + * be MIGRATE_ISOLATE.
> + * @start_pfn:		The lower PFN of the range to be isolated.
> + * @end_pfn:		The upper PFN of the range to be isolated.
> + *			start_pfn/end_pfn must be aligned to pageblock_order.
> + * @migratetype:	migrate type to set in error recovery.
> + * @flags:		The following flags are allowed (they can be combined in
> + *			a bit mask)
> + *			SKIP_HWPOISON - ignore hwpoison pages
> + *			REPORT_FAILURE - report details about the failure to
> + *			isolate the range
>   *
>   * Making page-allocation-type to be MIGRATE_ISOLATE means free pages in
>   * the range will never be allocated. Any free pages and pages freed in the
>   * future will not be allocated again.
>   *
> - * start_pfn/end_pfn must be aligned to pageblock_order.
> - * Return 0 on success and -EBUSY if any part of range cannot be isolated.
> - *
>   * There is no high level synchronization mechanism that prevents two threads
>   * from trying to isolate overlapping ranges.  If this happens, one thread
>   * will notice pageblocks in the overlapping range already set to isolate.
> @@ -182,6 +185,9 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
>   * returns an error.  We then clean up by restoring the migration type on
>   * pageblocks we may have modified and return -EBUSY to caller.  This
>   * prevents two threads from simultaneously working on overlapping ranges.
> + *
> + * Return: the number of isolated pageblocks on success and -EBUSY if any part
> + * of range cannot be isolated.
>   */
>  int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  			     unsigned migratetype, int flags)
> @@ -189,6 +195,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  	unsigned long pfn;
>  	unsigned long undo_pfn;
>  	struct page *page;
> +	int nr_isolate_pageblock = 0;
>  
>  	BUG_ON(!IS_ALIGNED(start_pfn, pageblock_nr_pages));
>  	BUG_ON(!IS_ALIGNED(end_pfn, pageblock_nr_pages));
> @@ -197,13 +204,15 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
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
> +			nr_isolate_pageblock++;
>  		}
>  	}
> -	return 0;
> +	return nr_isolate_pageblock;
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

