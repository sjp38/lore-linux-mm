Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3552A6B025E
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 05:47:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y29so22331196pff.6
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 02:47:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y22si7370422pli.509.2017.09.27.02.47.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 02:47:07 -0700 (PDT)
Date: Wed, 27 Sep 2017 11:40:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH ] mm/backing-dev.c: remove a null kfree and fix a false
 kmemleak in backing-dev
Message-ID: <20170927094049.GC25746@quack2.suse.cz>
References: <1506496508-31715-1-git-send-email-zumeng.chen@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506496508-31715-1-git-send-email-zumeng.chen@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zumeng Chen <zumeng.chen@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, axboe@fb.com, jack@suse.cz, tj@kernel.org, geliangtang@gmail.com

On Wed 27-09-17 15:15:08, Zumeng Chen wrote:
> It seems kfree(new_congested) does nothing since new_congested has already
> been set null pointer before kfree, so remove it.
> 
> Meanwhile kmemleak reports the following memory leakage:
> 
> unreferenced object 0xcadbb440 (size 64):
> comm "kworker/0:4", pid 1399, jiffies 4294946504 (age 808.290s)
> hex dump (first 32 bytes):
>   00 00 00 00 01 00 00 00 00 00 00 00 01 00 00 00  ................
>   01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> backtrace:
>   [<c028fb64>] kmem_cache_alloc_trace+0x2c4/0x3cc
>   [<c025fe70>] wb_congested_get_create+0x9c/0x140
>   [<c0260100>] wb_init+0x184/0x1f4
>   [<c02601fc>] bdi_init+0x8c/0xd4
>   [<c051f75c>] blk_alloc_queue_node+0x9c/0x2d8
>   [<c05227e8>] blk_init_queue_node+0x2c/0x64
>   [<c052283c>] blk_init_queue+0x1c/0x20
>   [<c06c7b30>] __scsi_alloc_queue+0x28/0x44
>   [<c06caf4c>] scsi_alloc_queue+0x24/0x80
>   [<c06cc0b8>] scsi_alloc_sdev+0x21c/0x34c
>   [<c06ccc00>] scsi_probe_and_add_lun+0x878/0xb04
>   [<c06cd114>] __scsi_scan_target+0x288/0x59c
>   [<c06cd4b0>] scsi_scan_channel+0x88/0x9c
>   [<c06cd9b8>] scsi_scan_host_selected+0x118/0x130
>   [<c06cda70>] do_scsi_scan_host+0xa0/0xa4
>   [<c06cdbe4>] scsi_scan_host+0x170/0x1b4
> 
> wb_congested allocates memory for congested when wb_congested_get_create,
> and release it when exit or failure by wb_congested_put.
> 

The patch is just wrong. Think what will happen if we decide to allocate
new_congested but then loose a race with somebody creating the same congested
structure (so we find it in the rb-tree).

								Honza

> Signed-off-by: Zumeng Chen <zumeng.chen@gmail.com>
> ---
>  mm/backing-dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index e19606b..d816b2a 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -457,6 +457,7 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
>  
>  	/* allocate storage for new one and retry */
>  	new_congested = kzalloc(sizeof(*new_congested), gfp);
> +	kmemleak_ignore(new_congested);
>  	if (!new_congested)
>  		return NULL;
>  
> @@ -468,7 +469,6 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
>  found:
>  	atomic_inc(&congested->refcnt);
>  	spin_unlock_irqrestore(&cgwb_lock, flags);
> -	kfree(new_congested);
>  	return congested;
>  }
>  
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
