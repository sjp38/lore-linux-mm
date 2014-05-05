Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id EAAC16B0087
	for <linux-mm@kvack.org>; Mon,  5 May 2014 06:50:57 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so5186468eek.22
        for <linux-mm@kvack.org>; Mon, 05 May 2014 03:50:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si2134109eeg.234.2014.05.05.03.50.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 May 2014 03:50:56 -0700 (PDT)
Date: Mon, 5 May 2014 12:50:54 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 17/17] mm: filemap: Avoid unnecessary barries and
 waitqueue lookup in unlock_page fastpath
Message-ID: <20140505105054.GC23927@quack.suse.cz>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-18-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398933888-4940-18-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu 01-05-14 09:44:48, Mel Gorman wrote:
> From: Nick Piggin <npiggin@suse.de>
> 
> This patch introduces a new page flag for 64-bit capable machines,
> PG_waiters, to signal there are processes waiting on PG_lock and uses it to
> avoid memory barriers and waitqueue hash lookup in the unlock_page fastpath.
> 
> This adds a few branches to the fast path but avoids bouncing a dirty
> cache line between CPUs. 32-bit machines always take the slow path but the
> primary motivation for this patch is large machines so I do not think that
> is a concern.
...
>  /* 
> diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> index 7d50f79..fb83fe0 100644
> --- a/kernel/sched/wait.c
> +++ b/kernel/sched/wait.c
> @@ -304,8 +304,7 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *arg)
>  		= container_of(wait, struct wait_bit_queue, wait);
>  
>  	if (wait_bit->key.flags != key->flags ||
> -			wait_bit->key.bit_nr != key->bit_nr ||
> -			test_bit(key->bit_nr, key->flags))
> +			wait_bit->key.bit_nr != key->bit_nr)
>  		return 0;
>  	else
>  		return autoremove_wake_function(wait, mode, sync, key);
  This change seems to be really unrelated? And it would deserve a comment
on its own I'd think so maybe split that in a separate patch?

> diff --git a/mm/filemap.c b/mm/filemap.c
> index c60ed0f..93e4385 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> +int  __wait_on_page_locked_killable(struct page *page)
> +{
> +	int ret = 0;
> +	wait_queue_head_t *wq = page_waitqueue(page);
> +	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
> +
> +	if (!test_bit(PG_locked, &page->flags))
> +		return 0;
> +	do {
> +		prepare_to_wait(wq, &wait.wait, TASK_KILLABLE);
> +		if (!PageWaiters(page))
> +			SetPageWaiters(page);
> +		if (likely(PageLocked(page)))
> +			ret = sleep_on_page_killable(page);
> +		finish_wait(wq, &wait.wait);
> +	} while (PageLocked(page) && !ret);
  So I'm somewhat wondering why this is the only page waiting variant that
does finish_wait() inside the loop. Everyone else does it outside the while
loop which seems sufficient to me even in this case...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
