Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A36A6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 12:57:35 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id ot10so342111951obb.3
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 09:57:35 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0104.outbound.protection.outlook.com. [157.55.234.104])
        by mx.google.com with ESMTPS id k66si7914441oih.173.2016.06.27.09.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 Jun 2016 09:57:34 -0700 (PDT)
Date: Mon, 27 Jun 2016 19:57:23 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm, vmscan: set shrinker to the left page count
Message-ID: <20160627165723.GW21652@esperanza>
References: <1467025335-6748-1-git-send-email-puck.chen@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1467025335-6748-1-git-send-email-puck.chen@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, labbott@redhat.com, suzhuangluan@hisilicon.com, oliver.fu@hisilicon.com, puck.chen@foxmail.com, dan.zhao@hisilicon.com, saberlily.xia@hisilicon.com, xuyiping@hisilicon.com

On Mon, Jun 27, 2016 at 07:02:15PM +0800, Chen Feng wrote:
> In my platform, there can be cache a lot of memory in
> ion page pool. When shrink memory the nr_to_scan to ion
> is always to little.
> to_scan: 395  ion_pool_cached: 27305

That's OK. We want to shrink slabs gradually, not all at once.

> 
> Currently, the shrinker nr_deferred is set to total_scan.
> But it's not the real left of the shrinker.

And it shouldn't. The idea behind nr_deferred is following. A shrinker
may return SHRINK_STOP if the current allocation context doesn't allow
to reclaim its objects (e.g. reclaiming inodes under GFP_NOFS is
deadlock prone). In this case we can't call the shrinker right now, but
if we just forget about the batch we are supposed to reclaim at the
current iteration, we can wind up having too many of these objects so
that they start to exert unfairly high pressure on user memory. So we
add the amount that we wanted to scan but couldn't to nr_deferred, so
that we can catch up when we get to shrink_slab() with a proper context.

> Change it to
> the freeable - freed.
> 
> Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
> ---
>  mm/vmscan.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c4a2f45..1ce3fc4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -357,8 +357,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	 * manner that handles concurrent updates. If we exhausted the
>  	 * scan, there is no need to do an update.
>  	 */
> -	if (total_scan > 0)
> -		new_nr = atomic_long_add_return(total_scan,
> +	if (freeable - freed > 0)
> +		new_nr = atomic_long_add_return(freeable - freed,
>  						&shrinker->nr_deferred[nid]);
>  	else
>  		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
