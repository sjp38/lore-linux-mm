Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19C906B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 10:42:05 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r74so3049610wme.5
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 07:42:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si1758590edm.99.2017.09.20.07.42.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Sep 2017 07:42:04 -0700 (PDT)
Date: Wed, 20 Sep 2017 16:41:59 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/6] fs-writeback: move nr_pages == 0 logic to one
 location
Message-ID: <20170920144159.GF11106@quack2.suse.cz>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-6-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505850787-18311-6-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On Tue 19-09-17 13:53:06, Jens Axboe wrote:
> Now that we have no external callers of wb_start_writeback(),
> we can move the nr_pages == 0 logic into that function.
> 
> Signed-off-by: Jens Axboe <axboe@kernel.dk>

...

> +static unsigned long get_nr_dirty_pages(void)
> +{
> +	return global_node_page_state(NR_FILE_DIRTY) +
> +		global_node_page_state(NR_UNSTABLE_NFS) +
> +		get_nr_dirty_inodes();
> +}
> +
>  static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  			       bool range_cyclic, enum wb_reason reason)
>  {
> @@ -942,6 +953,12 @@ static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  		return;
>  
>  	/*
> +	 * If someone asked for zero pages, we write out the WORLD
> +	 */
> +	if (!nr_pages)
> +		nr_pages = get_nr_dirty_pages();
> +

So for 'wb' we have a better estimate of the amount we should write - use
wb_stat_sum(wb, WB_RECLAIMABLE) statistics - that is essentially dirty +
unstable_nfs broken down to bdi_writeback.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
