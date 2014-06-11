Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D8B5A6B013A
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 22:46:24 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so490808pab.36
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:46:24 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id cs2si36281085pbc.242.2014.06.10.19.46.23
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 19:46:23 -0700 (PDT)
Message-ID: <5397C2BA.5030808@cn.fujitsu.com>
Date: Wed, 11 Jun 2014 10:45:14 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] mm, compaction: do not recheck suitable_migration_target
 under lock
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/09/2014 05:26 PM, Vlastimil Babka wrote:
> isolate_freepages_block() rechecks if the pageblock is suitable to be a target
> for migration after it has taken the zone->lock. However, the check has been
> optimized to occur only once per pageblock, and compact_checklock_irqsave()
> might be dropping and reacquiring lock, which means somebody else might have
> changed the pageblock's migratetype meanwhile.
> 
> Furthermore, nothing prevents the migratetype to change right after
> isolate_freepages_block() has finished isolating. Given how imperfect this is,
> it's simpler to just rely on the check done in isolate_freepages() without
> lock, and not pretend that the recheck under lock guarantees anything. It is
> just a heuristic after all.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
> I suggest folding mm-compactionc-isolate_freepages_block-small-tuneup.patch into this
> 
>  mm/compaction.c | 13 -------------
>  1 file changed, 13 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 5175019..b73b182 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -276,7 +276,6 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  	struct page *cursor, *valid_page = NULL;
>  	unsigned long flags;
>  	bool locked = false;
> -	bool checked_pageblock = false;
>  
>  	cursor = pfn_to_page(blockpfn);
>  
> @@ -307,18 +306,6 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  		if (!locked)
>  			break;
>  
> -		/* Recheck this is a suitable migration target under lock */
> -		if (!strict && !checked_pageblock) {
> -			/*
> -			 * We need to check suitability of pageblock only once
> -			 * and this isolate_freepages_block() is called with
> -			 * pageblock range, so just check once is sufficient.
> -			 */
> -			checked_pageblock = true;
> -			if (!suitable_migration_target(page))
> -				break;
> -		}
> -
>  		/* Recheck this is a buddy page under lock */
>  		if (!PageBuddy(page))
>  			goto isolate_fail;
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
