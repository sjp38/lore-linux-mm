Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D63E46B0342
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 13:26:09 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b9so3032367wra.3
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 10:26:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i71si1920002wme.59.2017.09.08.10.26.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Sep 2017 10:26:08 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
References: <20170904082148.23131-1-mhocko@kernel.org>
 <20170904082148.23131-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <eb5bf356-f498-b430-1ae8-4ff1ad15ad7f@suse.cz>
Date: Fri, 8 Sep 2017 19:26:06 +0200
MIME-Version: 1.0
In-Reply-To: <20170904082148.23131-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 09/04/2017 10:21 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Memory offlining can fail just too eagerly under a heavy memory pressure.
> 
> [ 5410.336792] page:ffffea22a646bd00 count:255 mapcount:252 mapping:ffff88ff926c9f38 index:0x3
> [ 5410.336809] flags: 0x9855fe40010048(uptodate|active|mappedtodisk)
> [ 5410.336811] page dumped because: isolation failed
> [ 5410.336813] page->mem_cgroup:ffff8801cd662000
> [ 5420.655030] memory offlining [mem 0x18b580000000-0x18b5ffffffff] failed
> 
> Isolation has failed here because the page is not on LRU. Most probably
> because it was on the pcp LRU cache or it has been removed from the LRU
> already but it hasn't been freed yet. In both cases the page doesn't look
> non-migrable so retrying more makes sense.
> 
> __offline_pages seems rather cluttered when it comes to the retry
> logic. We have 5 retries at maximum and a timeout. We could argue
> whether the timeout makes sense but failing just because of a race when
> somebody isoltes a page from LRU or puts it on a pcp LRU lists is just
> wrong. It only takes it to race with a process which unmaps some pages
> and remove them from the LRU list and we can fail the whole offline
> because of something that is a temporary condition and actually not
> harmful for the offline. Please note that unmovable pages should be
> already excluded during start_isolate_page_range.

Hmm, the has_unmovable_pages() check doesn't offer any strict guarantees due to
races, per its comment. Also at the very quick glance, I see a check where it
assumes that MIGRATE_MOVABLE pageblock will have no unmovable pages. There is no
such guarantee even without races.

> Fix this by removing the max retry count and only rely on the timeout
> resp. interruption by a signal from the userspace. Also retry rather
> than fail when check_pages_isolated sees some !free pages because those
> could be a result of the race as well.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Even within a movable node where has_unmovable_pages() is a non-issue, you could
have pinned movable pages where the pinning is not temporary. So after this
patch, this will really keep retrying forever. I'm not saying it's wrong, just
pointing it out, since the changelog seems to assume there would be only
temporary failures possible and thus unbound retries are always correct.
The obvious problem if we wanted to avoid this, is how to recognize
non-temporary failures...

> ---
>  mm/memory_hotplug.c | 40 ++++++++++------------------------------
>  1 file changed, 10 insertions(+), 30 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 459bbc182d10..c9dcbe6d2ac6 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1597,7 +1597,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  {
>  	unsigned long pfn, nr_pages, expire;
>  	long offlined_pages;
> -	int ret, drain, retry_max, node;
> +	int ret, node;
>  	unsigned long flags;
>  	unsigned long valid_start, valid_end;
>  	struct zone *zone;
> @@ -1634,43 +1634,25 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  
>  	pfn = start_pfn;
>  	expire = jiffies + timeout;
> -	drain = 0;
> -	retry_max = 5;
>  repeat:
>  	/* start memory hot removal */
> -	ret = -EAGAIN;
> +	ret = -EBUSY;
>  	if (time_after(jiffies, expire))
>  		goto failed_removal;
>  	ret = -EINTR;
>  	if (signal_pending(current))
>  		goto failed_removal;
> -	ret = 0;
> -	if (drain) {
> -		lru_add_drain_all_cpuslocked();
> -		cond_resched();
> -		drain_all_pages(zone);
> -	}
> +
> +	cond_resched();
> +	lru_add_drain_all_cpuslocked();
> +	drain_all_pages(zone);
>  
>  	pfn = scan_movable_pages(start_pfn, end_pfn);
>  	if (pfn) { /* We have movable pages */
>  		ret = do_migrate_range(pfn, end_pfn);
> -		if (!ret) {
> -			drain = 1;
> -			goto repeat;
> -		} else {
> -			if (ret < 0)
> -				if (--retry_max == 0)
> -					goto failed_removal;
> -			yield();
> -			drain = 1;
> -			goto repeat;
> -		}
> +		goto repeat;
>  	}
> -	/* drain all zone's lru pagevec, this is asynchronous... */
> -	lru_add_drain_all_cpuslocked();
> -	yield();
> -	/* drain pcp pages, this is synchronous. */
> -	drain_all_pages(zone);
> +
>  	/*
>  	 * dissolve free hugepages in the memory block before doing offlining
>  	 * actually in order to make hugetlbfs's object counting consistent.
> @@ -1680,10 +1662,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  		goto failed_removal;
>  	/* check again */
>  	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
> -	if (offlined_pages < 0) {
> -		ret = -EBUSY;
> -		goto failed_removal;
> -	}
> +	if (offlined_pages < 0)
> +		goto repeat;
>  	pr_info("Offlined Pages %ld\n", offlined_pages);
>  	/* Ok, all of our target is isolated.
>  	   We cannot do rollback at this point. */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
