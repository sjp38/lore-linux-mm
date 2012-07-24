Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 8ECB96B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 10:46:02 -0400 (EDT)
Date: Tue, 24 Jul 2012 09:45:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH v2] SLUB: enhance slub to handle memory nodes without
 normal memory
In-Reply-To: <1343123710-4972-1-git-send-email-jiang.liu@huawei.com>
Message-ID: <alpine.DEB.2.00.1207240931560.29808@router.home>
References: <alpine.DEB.2.00.1207181349370.22907@router.home> <1343123710-4972-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: WuJianguo <wujianguo@huawei.com>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

On Tue, 24 Jul 2012, Jiang Liu wrote:

>
> diff --git a/mm/slub.c b/mm/slub.c
> index 8c691fa..3976745 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2803,6 +2803,17 @@ static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
>
>  static struct kmem_cache *kmem_cache_node;
>
> +static bool node_has_normal_memory(int node)
> +{
> +	int i;
> +
> +	for (i = ZONE_NORMAL; i >= 0; i--)
> +		if (populated_zone(&NODE_DATA(node)->node_zones[i]))
> +			return true;
> +
> +	return false;
> +}

There is already a N_NORMAL_MEMORY node map that contains a list of node
that have *normal* memory usable by slab allocators etc. I think the
cleanest solution would be to clear the corresponding node bits for your
special movable only zones. Then you wont be needing to modify other
subsystems anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
