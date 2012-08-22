Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id DBAA76B006C
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 02:10:19 -0400 (EDT)
Message-ID: <50347906.4030101@cn.fujitsu.com>
Date: Wed, 22 Aug 2012 14:15:34 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: add build zonelists when offline pages
References: <5033843E.8000902@gmail.com>
In-Reply-To: <5033843E.8000902@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qiuxishi <qiuxishi@gmail.com>
Cc: akpm@linux-foundation.org, liuj97@gmail.com, paul.gortmaker@windriver.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bessel.wang@huawei.com, wujianguo@huawei.com, qiuxishi@huawei.com, jiang.liu@huawei.com, guohanjun@huawei.com, chenkeping@huawei.com, yinghai@kernel.org

At 08/21/2012 08:51 PM, qiuxishi Wrote:
> From: Xishi Qiu <qiuxishi@huawei.com>
> 
> online_pages() does build_all_zonelists() and zone_pcp_update(),
> I think offline_pages() should do it too. The node has no memory
> to allocate, so remove this node's zones form other nodes' zonelists.
> 
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/memory_hotplug.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index bc7e7a2..5172bd4 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -979,7 +979,11 @@ repeat:
>  	if (!node_present_pages(node)) {
>  		node_clear_state(node, N_HIGH_MEMORY);
>  		kswapd_stop(node);
> -	}
> +		mutex_lock(&zonelists_mutex);
> +		build_all_zonelists(NODE_DATA(node), NULL);

The node is still onlined now, so there is no need to pass
this node's pgdat to build_all_zonelists().

I think we should build all zonelists when the zone has no
pages.

> +		mutex_unlock(&zonelists_mutex);
> +	} else
> +		zone_pcp_update(zone);

There is more than one zone in a node. So the zone can have
no pages when the node has some pages.

And we have called drain_all_pages(), I think there is no need
to call zone_pcp_update() here.

Thanks
Wen Congyang

> 
>  	vm_total_pages = nr_free_pagecache_pages();
>  	writeback_set_ratelimit();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
