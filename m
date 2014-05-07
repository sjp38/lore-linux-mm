Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9C66B0037
	for <linux-mm@kvack.org>; Wed,  7 May 2014 08:10:48 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so668549eek.16
        for <linux-mm@kvack.org>; Wed, 07 May 2014 05:10:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n7si16179261eeu.139.2014.05.07.05.10.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 05:10:47 -0700 (PDT)
Message-ID: <536A22C5.6060704@suse.cz>
Date: Wed, 07 May 2014 14:10:45 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v3 6/6] mm, compaction: terminate async compaction when
 rescheduling
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/07/2014 04:22 AM, David Rientjes wrote:
> Async compaction terminates prematurely when need_resched(), see
> compact_checklock_irqsave().  This can never trigger, however, if the
> cond_resched() in isolate_migratepages_range() always takes care of the
> scheduling.
>
> If the cond_resched() actually triggers, then terminate this pageblock scan for
> async compaction as well.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/compaction.c | 7 ++++++-
>   1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -500,8 +500,13 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   			return 0;
>   	}
>
> +	if (cond_resched()) {
> +		/* Async terminates prematurely on need_resched() */
> +		if (cc->mode == MIGRATE_ASYNC)
> +			return 0;
> +	}
> +
>   	/* Time to isolate some pages for migration */
> -	cond_resched();
>   	for (; low_pfn < end_pfn; low_pfn++) {
>   		/* give a chance to irqs before checking need_resched() */
>   		if (locked && !(low_pfn % SWAP_CLUSTER_MAX)) {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
