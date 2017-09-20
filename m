Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 249606B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 21:57:16 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d8so2580738pgt.1
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 18:57:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m85sor1598748pfk.64.2017.09.19.18.57.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 18:57:14 -0700 (PDT)
Subject: Re: [PATCH 6/6] fs-writeback: only allow one inflight and pending
 !nr_pages flush
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-7-git-send-email-axboe@kernel.dk>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <dd57027c-55f3-6d9d-7fd6-a842bb16e11f@kernel.dk>
Date: Tue, 19 Sep 2017 19:57:10 -0600
MIME-Version: 1.0
In-Reply-To: <1505850787-18311-7-git-send-email-axboe@kernel.dk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On 09/19/2017 01:53 PM, Jens Axboe wrote:
> @@ -948,15 +949,25 @@ static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  			       bool range_cyclic, enum wb_reason reason)
>  {
>  	struct wb_writeback_work *work;
> +	bool zero_pages = false;
>  
>  	if (!wb_has_dirty_io(wb))
>  		return;
>  
>  	/*
> -	 * If someone asked for zero pages, we write out the WORLD
> +	 * If someone asked for zero pages, we write out the WORLD.
> +	 * Places like vmscan and laptop mode want to queue a wakeup to
> +	 * the flusher threads to clean out everything. To avoid potentially
> +	 * having tons of these pending, ensure that we only allow one of
> +	 * them pending and inflight at the time
>  	 */
> -	if (!nr_pages)
> +	if (!nr_pages) {
> +		if (test_bit(WB_zero_pages, &wb->state))
> +			return;
> +		set_bit(WB_zero_pages, &wb->state);
>  		nr_pages = get_nr_dirty_pages();
> +		zero_pages = true;
> +	}

Later fix added here to ensure we clear WB_zero_pages, if work
allocation fails:

work = kzalloc(sizeof(*work),                                           
                GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);           
if (!work) {                                                            
        if (zero_pages)                                                 
                clear_bit(WB_zero_pages, &wb->state);
	[...]

Updated patch here:

http://git.kernel.dk/cgit/linux-block/commit/?h=writeback-fixup&id=21ea70657894fda9fccf257543cbec112b2813ef

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
