Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3F76B20AD
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 10:35:08 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x1-v6so1422127edh.8
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 07:35:08 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id m1si8355293edj.174.2018.11.20.07.35.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 07:35:06 -0800 (PST)
Message-ID: <1542726815.6817.8.camel@suse.com>
Subject: Re: [RFC PATCH 2/3] mm, memory_hotplug: deobfuscate migration part
 of offlining
From: osalvador <osalvador@suse.com>
Date: Tue, 20 Nov 2018 16:13:35 +0100
In-Reply-To: <20181120134323.13007-3-mhocko@kernel.org>
References: <20181120134323.13007-1-mhocko@kernel.org>
	 <20181120134323.13007-3-mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


> Signed-off-by: Michal Hocko <mhocko@suse.com>
[...]
> +	do {
> +		for (pfn = start_pfn; pfn;)
> +		{
> +			/* start memory hot removal */

Should we change thAT comment? I mean, this is not really the hot-
removal stage.

Maybe "start memory migration" suits better? or memory offlining?

> +			ret = -EINTR;
> +			if (signal_pending(current)) {
> +				reason = "signal backoff";
> +				goto failed_removal_isolated;
> +			}
>  
> -	cond_resched();
> -	lru_add_drain_all();
> -	drain_all_pages(zone);
> +			cond_resched();
> +			lru_add_drain_all();
> +			drain_all_pages(zone);
>  
> -	pfn = scan_movable_pages(start_pfn, end_pfn);
> -	if (pfn) { /* We have movable pages */
> -		ret = do_migrate_range(pfn, end_pfn);
> -		goto repeat;
> -	}
> +			pfn = scan_movable_pages(pfn, end_pfn);
> +			if (pfn) {
> +				/* TODO fatal migration failures
> should bail out */
> +				do_migrate_range(pfn, end_pfn);
> +			}
> +		}
> +
> +		/*
> +		 * dissolve free hugepages in the memory block
> before doing offlining
> +		 * actually in order to make hugetlbfs's object
> counting consistent.
> +		 */
> +		ret = dissolve_free_huge_pages(start_pfn, end_pfn);
> +		if (ret) {
> +			reason = "failure to dissolve huge pages";
> +			goto failed_removal_isolated;
> +		}
> +		/* check again */
> +		offlined_pages = check_pages_isolated(start_pfn,
> end_pfn);
> +	} while (offlined_pages < 0);
>  
> -	/*
> -	 * dissolve free hugepages in the memory block before doing
> offlining
> -	 * actually in order to make hugetlbfs's object counting
> consistent.
> -	 */
> -	ret = dissolve_free_huge_pages(start_pfn, end_pfn);
> -	if (ret) {
> -		reason = "failure to dissolve huge pages";
> -		goto failed_removal_isolated;
> -	}
> -	/* check again */
> -	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
> -	if (offlined_pages < 0)
> -		goto repeat;

This indeed looks much nicer and it is easier to follow.
With the changes commented by David:

Reviewed-by: Oscar Salvador <osalvador@suse.de>
