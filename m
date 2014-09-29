Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 511F56B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 04:15:42 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id ge10so2881184lab.22
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 01:15:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5si17294922lal.109.2014.09.29.01.15.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 01:15:40 -0700 (PDT)
Message-ID: <54291528.40505@suse.cz>
Date: Mon, 29 Sep 2014 10:15:36 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v6 05/13] mm, compaction: move pageblock checks up from
 isolate_migratepages_range()
References: <1407142524-2025-1-git-send-email-vbabka@suse.cz> <1407142524-2025-6-git-send-email-vbabka@suse.cz> <20140929075038.GC29310@js1304-P5Q-DELUXE>
In-Reply-To: <20140929075038.GC29310@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 09/29/2014 09:50 AM, Joonsoo Kim wrote:
>
> Hello,
>
> This patch needs one fix.
> Please see below.

Oops, you're right.

> Thanks.
>
> ---------->8-------------
>  From 3ba15d35c00e0d913d603d2972678bf74554ed60 Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Mon, 29 Sep 2014 15:08:07 +0900
> Subject: [PATCH] mm/compaction: fix isolated page counting bug in compaction
>
> acct_isolated() is the function to adjust isolated page count. It
> iterates cc->migratepages list and add
> NR_ISOLATED_ANON/NR_ISOLATED_FILE count according to number of anon,
> file pages in migratepages list, respectively. Before commit (mm,
> compaction: move pageblock checks up from isolate_migratepages_range()),
> it is called just once in isolate_migratepages_range(), but, after commit,
> it is called in newly introduced isolate_migratepages_block() and this
> isolate_migratepages_block() could be called many times in
> isolate_migratepages_range() so that some page could be counted more
> than once. This duplicate counting bug results in hang in cma_alloc(),
> because too_many_isolated() returns true continually.
>
> This patch fixes this bug by moving acct_isolated() into upper layer
> function, isolate_migratepages_range() and isolate_migratepages().
> After this change, isolated page would be counted only once so
> problem would be gone.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> ---
>   mm/compaction.c |   19 ++++++++-----------
>   1 file changed, 8 insertions(+), 11 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 7d9d92e..48129b6 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -514,22 +514,19 @@ isolate_freepages_range(struct compact_control *cc,
>   }
>
>   /* Update the number of anon and file isolated pages in the zone */
> -static void acct_isolated(struct zone *zone, bool locked, struct compact_control *cc)
> +static void acct_isolated(struct zone *zone, struct compact_control *cc)
>   {
>   	struct page *page;
>   	unsigned int count[2] = { 0, };
>
> +	if (list_empty(&cc->migratepages))
> +		return;
> +
>   	list_for_each_entry(page, &cc->migratepages, lru)
>   		count[!!page_is_file_cache(page)]++;
>
> -	/* If locked we can use the interrupt unsafe versions */
> -	if (locked) {
> -		__mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
> -		__mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
> -	} else {
> -		mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
> -		mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
> -	}
> +	mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
> +	mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
>   }
>
>   /* Similar to reclaim, but different enough that they don't share logic */
> @@ -726,8 +723,6 @@ isolate_success:
>   	if (unlikely(low_pfn > end_pfn))
>   		low_pfn = end_pfn;
>
> -	acct_isolated(zone, locked, cc);
> -
>   	if (locked)
>   		spin_unlock_irqrestore(&zone->lru_lock, flags);
>
> @@ -789,6 +784,7 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
>   			break;
>   		}
>   	}
> +	acct_isolated(cc->zone, cc);
>
>   	return pfn;
>   }
> @@ -1028,6 +1024,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>   		break;
>   	}
>
> +	acct_isolated(zone, cc);
>   	/* Record where migration scanner will be restarted */
>   	cc->migrate_pfn = low_pfn;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
