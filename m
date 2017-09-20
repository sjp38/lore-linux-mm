Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC136B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 10:17:30 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 97so3225016wrb.1
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 07:17:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l13si1195893edi.34.2017.09.20.07.17.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Sep 2017 07:17:29 -0700 (PDT)
Date: Wed, 20 Sep 2017 16:17:27 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/6] buffer: cleanup free_more_memory() flusher wakeup
Message-ID: <20170920141727.GB11106@quack2.suse.cz>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-2-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505850787-18311-2-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On Tue 19-09-17 13:53:02, Jens Axboe wrote:
> This whole function is... interesting. Change the wakeup call
> to the flusher threads to pass in nr_pages == 0, instead of
> some random number of pages. This matches more closely what
> similar cases do for memory shortage/reclaim.
> 
> Signed-off-by: Jens Axboe <axboe@kernel.dk>

Ok, probably makes sense. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

BTW, after this nobody seems to use the number of pages for
wakeup_flusher_threads() so can you just delete the argument for the
function? After all system-wide wakeup is useful only for system wide
sync(2) or memory reclaim so number of pages isn't very useful...

								Honza

> ---
>  fs/buffer.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 170df856bdb9..9471a445e370 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -260,7 +260,7 @@ static void free_more_memory(void)
>  	struct zoneref *z;
>  	int nid;
>  
> -	wakeup_flusher_threads(1024, WB_REASON_FREE_MORE_MEM);
> +	wakeup_flusher_threads(0, WB_REASON_FREE_MORE_MEM);
>  	yield();
>  
>  	for_each_online_node(nid) {
> -- 
> 2.7.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
