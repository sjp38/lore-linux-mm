Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 516A86B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 08:57:58 -0400 (EDT)
Received: by wgra20 with SMTP id a20so52385123wgr.3
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 05:57:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lh10si3182622wjb.88.2015.04.01.05.57.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Apr 2015 05:57:57 -0700 (PDT)
Message-ID: <551BEB53.8080402@suse.cz>
Date: Wed, 01 Apr 2015 14:57:55 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: free large amount of 0-order pages in workqueue
References: <1427839895-16434-1-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1427839895-16434-1-git-send-email-sasha.levin@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org
Cc: mhocko@suse.cz, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, open@kvack.org, list@kvack.org, MEMORY MANAGEMENT <linux-mm@kvack.org>

On 04/01/2015 12:11 AM, Sasha Levin wrote:
> Freeing pages became a rather costly operation, specially when multiple debug
> options are enabled. This causes hangs when an attempt to free a large amount
> of 0-order is made. Two examples are vfree()ing large block of memory, and
> punching a hole in a shmem filesystem.
>
> To avoid that, move any free operations that involve batching pages into a
> list to a workqueue handler where they could be freed later.

Is there a risk of creating a situation where memory is apparently 
missing, because the work item hasn't been processed? Leading to 
allocation failures, needless reclaim, spurious OOM, etc? If yes, such 
situations should probably wait for completion of the work first?

And maybe it shouldn't be used everywhere (as patch 2/2 does) but only 
where it makes sense. Process exits, maybe?

> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   mm/page_alloc.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++----
>   1 file changed, 46 insertions(+), 4 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5bd9711..812ca75 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1586,10 +1586,11 @@ out:
>   	local_irq_restore(flags);
>   }
>
> -/*
> - * Free a list of 0-order pages
> - */
> -void free_hot_cold_page_list(struct list_head *list, bool cold)
> +static LIST_HEAD(free_hot_page_list);
> +static LIST_HEAD(free_cold_page_list);
> +static DEFINE_SPINLOCK(free_page_lock);
> +
> +static void __free_hot_cold_page_list(struct list_head *list, bool cold)
>   {
>   	struct page *page, *next;
>
> @@ -1599,6 +1600,47 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
>   	}
>   }
>
> +static void free_page_lists_work(struct work_struct *work)
> +{
> +	LIST_HEAD(hot_pages);
> +	LIST_HEAD(cold_pages);
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&free_page_lock, flags);
> +	list_cut_position(&hot_pages, &free_hot_page_list,
> +					free_hot_page_list.prev);
> +	list_cut_position(&cold_pages, &free_cold_page_list,
> +					free_cold_page_list.prev);
> +	spin_unlock_irqrestore(&free_page_lock, flags);
> +
> +	__free_hot_cold_page_list(&hot_pages, false);
> +	__free_hot_cold_page_list(&cold_pages, true);
> +}
> +
> +static DECLARE_WORK(free_page_work, free_page_lists_work);
> +
> +/*
> + * Free a list of 0-order pages
> + */
> +void free_hot_cold_page_list(struct list_head *list, bool cold)
> +{
> +	unsigned long flags;
> +
> +	if (unlikely(!keventd_up())) {
> +		__free_hot_cold_page_list(list, cold);
> +		return;
> +	}
> +
> +	spin_lock_irqsave(&free_page_lock, flags);
> +	if(cold)
> +		list_splice_tail(list, &free_cold_page_list);
> +	else
> +		list_splice_tail(list, &free_hot_page_list);
> +	spin_unlock_irqrestore(&free_page_lock, flags);
> +
> +	schedule_work(&free_page_work);
> +}
> +
>   /*
>    * split_page takes a non-compound higher-order page, and splits it into
>    * n (1<<order) sub-pages: page[0..n]
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
