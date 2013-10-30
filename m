Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6796B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 16:19:13 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so1478638pde.29
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 13:19:13 -0700 (PDT)
Received: from psmtp.com ([74.125.245.178])
        by mx.google.com with SMTP id cj2si18916432pbc.177.2013.10.30.13.19.11
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 13:19:11 -0700 (PDT)
Received: by mail-yh0-f42.google.com with SMTP id z6so838467yhz.15
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 13:19:09 -0700 (PDT)
Message-ID: <527169BB.8020104@gmail.com>
Date: Wed, 30 Oct 2013 16:19:07 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: get rid of unnecessary pageblock scanning in setup_zone_migrate_reserve
References: <1382562092-15570-1-git-send-email-kosaki.motohiro@gmail.com> <20131030151904.GO2400@suse.de>
In-Reply-To: <20131030151904.GO2400@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

> @@ -3926,11 +3929,11 @@ static void setup_zone_migrate_reserve(struct zone *zone)
>   	/*
>   	 * Reserve blocks are generally in place to help high-order atomic
>   	 * allocations that are short-lived. A min_free_kbytes value that
> -	 * would result in more than 2 reserve blocks for atomic allocations
> -	 * is assumed to be in place to help anti-fragmentation for the
> -	 * future allocation of hugepages at runtime.
> +	 * would result in more than MAX_MIGRATE_RESERVE_BLOCKS reserve blocks
> +	 * for atomic allocations is assumed to be in place to help
> +	 * anti-fragmentation for the future allocation of hugepages at runtime.
>   	 */
> -	reserve = min(2, reserve);
> +	reserve = min(MAX_MIGRATE_RESERVE_BLOCKS, reserve);
>
>   	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
>   		if (!pfn_valid(pfn))
> @@ -3956,6 +3959,7 @@ static void setup_zone_migrate_reserve(struct zone *zone)
>   			/* If this block is reserved, account for it */
>   			if (block_migratetype == MIGRATE_RESERVE) {
>   				reserve--;
> +				found++;
>   				continue;
>   			}
>
> @@ -3970,6 +3974,10 @@ static void setup_zone_migrate_reserve(struct zone *zone)
>   			}
>   		}
>
> +		/* If all possible reserve blocks have been found, we're done */
> +		if (found >= MAX_MIGRATE_RESERVE_BLOCKS)
> +			break;
> +
>   		/*
>   		 * If the reserve is met and this is a previous reserved block,
>   		 * take it back

Nit. I would like to add following hunk. This is just nit because moving
reserve pageblock is extreme rare.

		if (block_migratetype == MIGRATE_RESERVE) {
+                       found++;
			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
			move_freepages_block(zone, page, MIGRATE_MOVABLE);
		}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
