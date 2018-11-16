Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id C91C06B0966
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 07:04:56 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id w80so4831775oiw.19
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 04:04:56 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j37si12535839oth.260.2018.11.16.04.04.55
        for <linux-mm@kvack.org>;
        Fri, 16 Nov 2018 04:04:55 -0800 (PST)
Subject: Re: [PATCH 4/5] mm, memory_hotplug: print reason for the offlining
 failure
References: <20181116083020.20260-1-mhocko@kernel.org>
 <20181116083020.20260-5-mhocko@kernel.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <c400b307-d49b-4463-03d8-88a0dcedf242@arm.com>
Date: Fri, 16 Nov 2018 17:34:50 +0530
MIME-Version: 1.0
In-Reply-To: <20181116083020.20260-5-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On 11/16/2018 02:00 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> The memory offlining failure reporting is inconsistent and insufficient.
> Some error paths simply do not report the failure to the log at all.
> When we do report there are no details about the reason of the failure
> and there are several of them which makes memory offlining failures
> hard to debug.
> 
> Make sure that the
> 	memory offlining [mem %#010llx-%#010llx] failed
> message is printed for all failures and also provide a short textual
> reason for the failure e.g.
> 
> [ 1984.506184] rac1 kernel: memory offlining [mem 0x82600000000-0x8267fffffff] failed due to signal backoff
> 
> this tells us that the offlining has failed because of a signal pending
> aka user intervention.
> 
> [akpm: tweak messages a bit]
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory_hotplug.c | 34 +++++++++++++++++++++++-----------
>  1 file changed, 23 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index a92b1b8f6218..88d50e74e3fe 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1553,6 +1553,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	unsigned long valid_start, valid_end;
>  	struct zone *zone;
>  	struct memory_notify arg;
> +	char *reason;
>  
>  	mem_hotplug_begin();
>  
> @@ -1561,7 +1562,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start,
>  				  &valid_end)) {
>  		mem_hotplug_done();
> -		return -EINVAL;
> +		ret = -EINVAL;
> +		reason = "multizone range";
> +		goto failed_removal;
>  	}
>  
>  	zone = page_zone(pfn_to_page(valid_start));
> @@ -1573,7 +1576,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  				       MIGRATE_MOVABLE, true);
>  	if (ret) {
>  		mem_hotplug_done();
> -		return ret;
> +		reason = "failure to isolate range";
> +		goto failed_removal;
>  	}
>  
>  	arg.start_pfn = start_pfn;
> @@ -1582,15 +1586,19 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  
>  	ret = memory_notify(MEM_GOING_OFFLINE, &arg);
>  	ret = notifier_to_errno(ret);
> -	if (ret)
> -		goto failed_removal;
> +	if (ret) {
> +		reason = "notifier failure";
> +		goto failed_removal_isolated;
> +	}
>  
>  	pfn = start_pfn;
>  repeat:
>  	/* start memory hot removal */
>  	ret = -EINTR;
> -	if (signal_pending(current))
> -		goto failed_removal;
> +	if (signal_pending(current)) {
> +		reason = "signal backoff";
> +		goto failed_removal_isolated;
> +	}
>  
>  	cond_resched();
>  	lru_add_drain_all();
> @@ -1607,8 +1615,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	 * actually in order to make hugetlbfs's object counting consistent.
>  	 */
>  	ret = dissolve_free_huge_pages(start_pfn, end_pfn);
> -	if (ret)
> -		goto failed_removal;
> +	if (ret) {
> +		reason = "failure to dissolve huge pages";
> +		goto failed_removal_isolated;
> +	}
>  	/* check again */
>  	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
>  	if (offlined_pages < 0)
> @@ -1648,13 +1658,15 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	mem_hotplug_done();
>  	return 0;
>  
> +failed_removal_isolated:
> +	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
>  failed_removal:
> -	pr_debug("memory offlining [mem %#010llx-%#010llx] failed\n",
> +	pr_debug("memory offlining [mem %#010llx-%#010llx] failed due to %s\n",
>  		 (unsigned long long) start_pfn << PAGE_SHIFT,
> -		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
> +		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1,
> +		 reason);
>  	memory_notify(MEM_CANCEL_OFFLINE, &arg);
>  	/* pushback to free area */
> -	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
>  	mem_hotplug_done();
>  	return ret;
>  }
> 

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
