Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7FB6B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 11:05:12 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d8so12129314pgt.1
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 08:05:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r63si1137755plb.443.2017.09.21.08.05.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 08:05:11 -0700 (PDT)
Date: Thu, 21 Sep 2017 08:05:10 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 7/7] fs-writeback: only allow one inflight and pending
 full flush
Message-ID: <20170921150510.GH8839@infradead.org>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-8-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505921582-26709-8-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On Wed, Sep 20, 2017 at 09:33:02AM -0600, Jens Axboe wrote:
> When someone calls wakeup_flusher_threads() or
> wakeup_flusher_threads_bdi(), they schedule writeback of all dirty
> pages in the system (or on that bdi). If we are tight on memory, we
> can get tons of these queued from kswapd/vmscan. This causes (at
> least) two problems:
> 
> 1) We consume a ton of memory just allocating writeback work items.
> 2) We spend so much time processing these work items, that we
>    introduce a softlockup in writeback processing.
> 
> Fix this by adding a 'start_all' bit to the writeback structure, and
> set that when someone attempts to flush all dirty page.  The bit is
> cleared when we start writeback on that work item. If the bit is
> already set when we attempt to queue !nr_pages writeback, then we
> simply ignore it.
> 
> This provides us one full flush in flight, with one pending as well,
> and makes for more efficient handling of this type of writeback.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Tested-by: Chris Mason <clm@fb.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Jens Axboe <axboe@kernel.dk>
> ---
>  fs/fs-writeback.c                | 24 ++++++++++++++++++++++++
>  include/linux/backing-dev-defs.h |  1 +
>  2 files changed, 25 insertions(+)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 3916ea2484ae..6205319d0c24 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -53,6 +53,7 @@ struct wb_writeback_work {
>  	unsigned int for_background:1;
>  	unsigned int for_sync:1;	/* sync(2) WB_SYNC_ALL writeback */
>  	unsigned int auto_free:1;	/* free on completion */
> +	unsigned int start_all:1;	/* nr_pages == 0 (all) writeback */
>  	enum wb_reason reason;		/* why was writeback initiated? */
>  
>  	struct list_head list;		/* pending work list */
> @@ -953,12 +954,26 @@ static void wb_start_writeback(struct bdi_writeback *wb, bool range_cyclic,
>  		return;
>  
>  	/*
> +	 * All callers of this function want to start writeback of all
> +	 * dirty pages. Places like vmscan can call this at a very
> +	 * high frequency, causing pointless allocations of tons of
> +	 * work items and keeping the flusher threads busy retrieving
> +	 * that work. Ensure that we only allow one of them pending and
> +	 * inflight at the time
> +	 */
> +	if (test_bit(WB_start_all, &wb->state))
> +		return;
> +
> +	set_bit(WB_start_all, &wb->state);

This should be test_and_set_bit here..

But more importantly once we are not guaranteed that we only have
a single global wb_writeback_work per bdi_writeback we should just
embedd that into struct bdi_writeback instead of dynamically
allocating it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
