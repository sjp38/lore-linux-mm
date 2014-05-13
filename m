Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f173.google.com (mail-ve0-f173.google.com [209.85.128.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8CBD46B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 12:52:28 -0400 (EDT)
Received: by mail-ve0-f173.google.com with SMTP id pa12so806485veb.4
        for <linux-mm@kvack.org>; Tue, 13 May 2014 09:52:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id s6si8069421qaj.16.2014.05.13.09.52.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 09:52:27 -0700 (PDT)
Date: Tue, 13 May 2014 18:52:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
 waitqueue lookups in unlock_page fastpath
Message-ID: <20140513165223.GB5226@laptop.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399974350-11089-20-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 10:45:50AM +0100, Mel Gorman wrote:
> diff --git a/mm/filemap.c b/mm/filemap.c
> index c60ed0f..d81ed7d 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -241,15 +241,15 @@ void delete_from_page_cache(struct page *page)
>  }
>  EXPORT_SYMBOL(delete_from_page_cache);
>  
> -static int sleep_on_page(void *word)
> +static int sleep_on_page(void)
>  {
> -	io_schedule();
> +	io_schedule_timeout(HZ);
>  	return 0;
>  }
>  
> -static int sleep_on_page_killable(void *word)
> +static int sleep_on_page_killable(void)
>  {
> -	sleep_on_page(word);
> +	sleep_on_page();
>  	return fatal_signal_pending(current) ? -EINTR : 0;
>  }
>  

I've got a patch from NeilBrown that conflicts with this, shouldn't be
hard to resolve though.

> @@ -680,30 +680,105 @@ static wait_queue_head_t *page_waitqueue(struct page *page)
>  	return &zone->wait_table[hash_ptr(page, zone->wait_table_bits)];
>  }
>  
> -static inline void wake_up_page(struct page *page, int bit)
> +static inline wait_queue_head_t *clear_page_waiters(struct page *page)
>  {
> -	__wake_up_bit(page_waitqueue(page), &page->flags, bit);
> +	wait_queue_head_t *wqh = NULL;
> +
> +	if (!PageWaiters(page))
> +		return NULL;
> +
> +	/*
> +	 * Prepare to clear PG_waiters if the waitqueue is no longer
> +	 * active. Note that there is no guarantee that a page with no
> +	 * waiters will get cleared as there may be unrelated pages
> +	 * sleeping on the same page wait queue. Accurate detection
> +	 * would require a counter. In the event of a collision, the
> +	 * waiter bit will dangle and lookups will be required until
> +	 * the page is unlocked without collisions. The bit will need to
> +	 * be cleared before freeing to avoid triggering debug checks.
> +	 *
> +	 * Furthermore, this can race with processes about to sleep on
> +	 * the same page if it adds itself to the waitqueue just after
> +	 * this check. The timeout in sleep_on_page prevents the race
> +	 * being a terminal one. In effect, the uncontended and non-race
> +	 * cases are faster in exchange for occasional worst case of the
> +	 * timeout saving us.
> +	 */
> +	wqh = page_waitqueue(page);
> +	if (!waitqueue_active(wqh))
> +		ClearPageWaiters(page);
> +
> +	return wqh;
> +}

This of course is properly disgusting, but my brain isn't working right
on 4 hours of sleep, so I'm able to suggest anything else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
