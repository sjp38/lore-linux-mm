Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0316B025E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 05:14:28 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id a140so45127407wma.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 02:14:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3si22839961wmf.48.2016.04.12.02.14.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 02:14:27 -0700 (PDT)
Subject: Re: mmotm woes, mainly compaction
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
 <570CB9CE.1070408@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570CBC72.9020003@suse.cz>
Date: Tue, 12 Apr 2016 11:14:26 +0200
MIME-Version: 1.0
In-Reply-To: <570CB9CE.1070408@suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/12/2016 11:03 AM, Vlastimil Babka wrote:
> On 04/12/2016 09:18 AM, Hugh Dickins wrote:
>> 3. /proc/sys/vm/stat_refresh warns nr_isolated_anon and nr_isolated_file
>>      go increasingly negative under compaction: which would add delay when
>>      should be none, or no delay when should delay.  putback_movable_pages()
>>      decrements the NR_ISOLATED counts which acct_isolated() increments,
>>      so isolate_migratepages_block() needs to acct before putback in that
>>      special case, and isolate_migratepages_range() can always do the acct
>>      itself, leaving migratepages putback to caller like most other places.
>
> The isolate_migratepages_block() part is mmotm-specific, so I'll split
> it out in this patch. Thanks for catching it and the lack of reset for
> cc->nr_migratepages which wasn't mentioned in changelog so I added it.
>
>> 5. It's easier to track the life of cc->migratepages if we don't assign
>>      it to a migratelist variable.
>
> This is also included here.
>
> This is a -fix for:
> mm-compaction-skip-blocks-where-isolation-fails-in-async-direct-compaction.patch
>
> ----8<----
>  From 59a0075b6cf85045aa2dc5cee1f27797bcd0b3d2 Mon Sep 17 00:00:00 2001
> From: Hugh Dickins <hughd@google.com>
> Date: Tue, 12 Apr 2016 10:51:20 +0200
> Subject: [PATCH] mm, compaction: prevent nr_isolated_* from going negative
>
> /proc/sys/vm/stat_refresh warns nr_isolated_anon and nr_isolated_file
> go increasingly negative under compaction: which would add delay when
> should be none, or no delay when should delay.  putback_movable_pages()
> decrements the NR_ISOLATED counts which acct_isolated() increments,
> so isolate_migratepages_block() needs to acct before putback in that
> special case. It's also useful to reset cc->nr_migratepages after putback
> so we don't needlessly return too early on the COMPACT_CLUSTER_MAX check.
>
> Also it's easier to track the life of cc->migratepages if we don't assign
> it to a migratelist variable.

Forgot
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/compaction.c | 9 +++++----
>   1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 67f886ecd773..ab649fba3d88 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -638,7 +638,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>   {
>   	struct zone *zone = cc->zone;
>   	unsigned long nr_scanned = 0, nr_isolated = 0;
> -	struct list_head *migratelist = &cc->migratepages;
>   	struct lruvec *lruvec;
>   	unsigned long flags = 0;
>   	bool locked = false;
> @@ -817,7 +816,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>   		del_page_from_lru_list(page, lruvec, page_lru(page));
>
>   isolate_success:
> -		list_add(&page->lru, migratelist);
> +		list_add(&page->lru, &cc->migratepages);
>   		cc->nr_migratepages++;
>   		nr_isolated++;
>
> @@ -851,9 +850,11 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>   				spin_unlock_irqrestore(&zone->lru_lock,	flags);
>   				locked = false;
>   			}
> -			putback_movable_pages(migratelist);
> -			nr_isolated = 0;
> +			acct_isolated(zone, cc);
> +			putback_movable_pages(&cc->migratepages);
> +			cc->nr_migratepages = 0;
>   			cc->last_migrated_pfn = 0;
> +			nr_isolated = 0;
>   		}
>
>   		if (low_pfn < next_skip_pfn) {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
