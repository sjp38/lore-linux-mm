Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 722FA6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 04:50:39 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id x13so2056970wgg.3
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 01:50:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e6si1171497wik.35.2014.02.07.01.50.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 01:50:38 -0800 (PST)
Message-ID: <52F4AC6B.5080101@suse.cz>
Date: Fri, 07 Feb 2014 10:50:35 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] mm/compaction: change the timing to check to drop
 the spinlock
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com> <1391749726-28910-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1391749726-28910-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/07/2014 06:08 AM, Joonsoo Kim wrote:
> It is odd to drop the spinlock when we scan (SWAP_CLUSTER_MAX - 1) th pfn
> page. This may results in below situation while isolating migratepage.
> 
> 1. try isolate 0x0 ~ 0x200 pfn pages.
> 2. When low_pfn is 0x1ff, ((low_pfn+1) % SWAP_CLUSTER_MAX) == 0, so drop
> the spinlock.
> 3. Then, to complete isolating, retry to aquire the lock.
> 
> I think that it is better to use SWAP_CLUSTER_MAX th pfn for checking
> the criteria about dropping the lock. This has no harm 0x0 pfn, because,
> at this time, locked variable would be false.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 0d821a2..b1ba297 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -481,7 +481,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  	cond_resched();
>  	for (; low_pfn < end_pfn; low_pfn++) {
>  		/* give a chance to irqs before checking need_resched() */
> -		if (locked && !((low_pfn+1) % SWAP_CLUSTER_MAX)) {
> +		if (locked && !(low_pfn % SWAP_CLUSTER_MAX)) {
>  			if (should_release_lock(&zone->lru_lock)) {
>  				spin_unlock_irqrestore(&zone->lru_lock, flags);
>  				locked = false;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
