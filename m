Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8946B6B206E
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:26:47 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id z6so105351qtj.21
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:26:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t65si5530340qkh.219.2018.11.20.06.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 06:26:46 -0800 (PST)
Subject: Re: [RFC PATCH 2/3] mm, memory_hotplug: deobfuscate migration part of
 offlining
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-3-mhocko@kernel.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <f25bfa30-96cf-799c-6885-86a3a537a977@redhat.com>
Date: Tue, 20 Nov 2018 15:26:43 +0100
MIME-Version: 1.0
In-Reply-To: <20181120134323.13007-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 20.11.18 14:43, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Memory migration might fail during offlining and we keep retrying in
> that case. This is currently obfuscate by goto retry loop. The code
> is hard to follow and as a result it is even suboptimal becase each
> retry round scans the full range from start_pfn even though we have
> successfully scanned/migrated [start_pfn, pfn] range already. This
> is all only because check_pages_isolated failure has to rescan the full
> range again.
> 
> De-obfuscate the migration retry loop by promoting it to a real for
> loop. In fact remove the goto altogether by making it a proper double
> loop (yeah, gotos are nasty in this specific case). In the end we
> will get a slightly more optimal code which is better readable.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory_hotplug.c | 60 +++++++++++++++++++++++----------------------
>  1 file changed, 31 insertions(+), 29 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 6263c8cd4491..9cd161db3061 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1591,38 +1591,40 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  		goto failed_removal_isolated;
>  	}
>  
> -	pfn = start_pfn;
> -repeat:
> -	/* start memory hot removal */
> -	ret = -EINTR;
> -	if (signal_pending(current)) {
> -		reason = "signal backoff";
> -		goto failed_removal_isolated;
> -	}
> +	do {
> +		for (pfn = start_pfn; pfn;)
> +		{

{ on a new line looks weird.

> +			/* start memory hot removal */
> +			ret = -EINTR;

I think we can move that into the "if (signal_pending(current))"

(if my eyes are not wrong, this will not be touched otherwise)

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
> +				/* TODO fatal migration failures should bail out */
> +				do_migrate_range(pfn, end_pfn);

Right, that return value was always ignored.

> +			}
> +		}
> +
> +		/*
> +		 * dissolve free hugepages in the memory block before doing offlining
> +		 * actually in order to make hugetlbfs's object counting consistent.
> +		 */
> +		ret = dissolve_free_huge_pages(start_pfn, end_pfn);
> +		if (ret) {
> +			reason = "failure to dissolve huge pages";
> +			goto failed_removal_isolated;
> +		}
> +		/* check again */
> +		offlined_pages = check_pages_isolated(start_pfn, end_pfn);
> +	} while (offlined_pages < 0);
>  
> -	/*
> -	 * dissolve free hugepages in the memory block before doing offlining
> -	 * actually in order to make hugetlbfs's object counting consistent.
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
>  	pr_info("Offlined Pages %ld\n", offlined_pages);
>  	/* Ok, all of our target is isolated.
>  	   We cannot do rollback at this point. */
> 

Looks much better to me.


-- 

Thanks,

David / dhildenb
