Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30ABF6B0033
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 21:39:15 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 26so23697134pfs.22
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 18:39:15 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e1si22273151pgt.98.2017.11.26.18.39.13
        for <linux-mm@kvack.org>;
        Sun, 26 Nov 2017 18:39:13 -0800 (PST)
Date: Mon, 27 Nov 2017 11:39:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/vmscan: make do_shrink_slab more robust.
Message-ID: <20171127023912.GB27255@bbox>
References: <1511746650-51945-1-git-send-email-jiang.biao2@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511746650-51945-1-git-send-email-jiang.biao2@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Biao <jiang.biao2@zte.com.cn>
Cc: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn

Hello,

On Mon, Nov 27, 2017 at 09:37:30AM +0800, Jiang Biao wrote:
> When running ltp stress test for 7*24 hours, the kernel occasionally
> complains the following warning continuously,
> 
> mb_cache_shrink_scan+0x0/0x3f0 negative objects to delete
> nr=-9222526086287711848
> mb_cache_shrink_scan+0x0/0x3f0 negative objects to delete
> nr=-9222420761333860545
> mb_cache_shrink_scan+0x0/0x3f0 negative objects to delete
> nr=-9222287677544280360
> ...
> 
> The tracing result shows the freeable(mb_cache_shrink_scan returns)
> is -1, which causes the continuous accumulation and overflow of
> total_scan.

Good catch.

> 
> This patch make do_shrink_slab more robust when
> shrinker->count_objects return negative freeable.

Shrinker.h says count_objects should return 0 if there are no
freeable objects, not -1.

So if something returns -1, changing it with returning 0 would
be more proper fix.

Thanks.


> 
> Signed-off-by: Jiang Biao <jiang.biao2@zte.com.cn>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eb2f031..3ea28f0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -323,7 +323,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	long scanned = 0, next_deferred;
>  
>  	freeable = shrinker->count_objects(shrinker, shrinkctl);
> -	if (freeable == 0)
> +	if (freeable <= 0)
>  		return 0;
>  
>  	/*
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
