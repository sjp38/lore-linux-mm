Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2DE6B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 01:46:46 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lf10so472362pab.36
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 22:46:45 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id uc10si5557638pac.194.2014.09.11.22.46.41
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 22:46:45 -0700 (PDT)
Date: Fri, 12 Sep 2014 14:46:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 00/10] implement zsmalloc shrinking
Message-ID: <20140912054640.GB2160@bbox>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

On Thu, Sep 11, 2014 at 04:53:51PM -0400, Dan Streetman wrote:
> Now that zswap can use zsmalloc as a storage pool via zpool, it will
> try to shrink its zsmalloc zs_pool once it reaches its max_pool_percent
> limit.  These patches implement zsmalloc shrinking.  The way the pool is
> shrunk is by finding a zspage and reclaiming it, by evicting each of its
> objects that is in use.
> 
> Without these patches zswap, and any other future user of zpool/zsmalloc
> that attempts to shrink the zpool/zs_pool, will only get errors and will
> be unable to shrink its zpool/zs_pool.  With the ability to shrink, zswap
> can keep the most recent compressed pages in memory.
> 
> Note that the design of zsmalloc makes it impossible to actually find the
> LRU zspage, so each class and fullness group is searched in a round-robin
> method to find the next zspage to reclaim.  Each fullness group orders its
> zspages in LRU order, so the oldest zspage is used for each fullness group.
> 

1. Pz, Cc Mel who was strong against zswap with zsmalloc.
2. I don't think LRU stuff should be in allocator layer. Exp, it's really
   hard to work well in zsmalloc design.
3. If you want to add another writeback, make zswap writeback sane first.
   current implemenation(zswap store -> zbud reclaim -> zswap writeback,
   even) is really ugly.
4. Don't make zsmalloc complicated without any data(benefit, regression)
   I will never ack if you don't give any number and real usecase.

> ---
> 
> This patch set applies to linux-next.
> 
> Dan Streetman (10):
>   zsmalloc: fix init_zspage free obj linking
>   zsmalloc: add fullness group list for ZS_FULL zspages
>   zsmalloc: always update lru ordering of each zspage
>   zsmalloc: move zspage obj freeing to separate function
>   zsmalloc: add atomic index to find zspage to reclaim
>   zsmalloc: add zs_ops to zs_pool
>   zsmalloc: add obj_handle_is_free()
>   zsmalloc: add reclaim_zspage()
>   zsmalloc: add zs_shrink()
>   zsmalloc: implement zs_zpool_shrink() with zs_shrink()
> 
>  drivers/block/zram/zram_drv.c |   2 +-
>  include/linux/zsmalloc.h      |   7 +-
>  mm/zsmalloc.c                 | 314 +++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 290 insertions(+), 33 deletions(-)
> 
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
