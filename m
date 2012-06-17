Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 2C7A76B004D
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 22:19:06 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6826532dak.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 19:19:05 -0700 (PDT)
Date: Sat, 16 Jun 2012 19:19:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] trivial, memory hotplug: add kswapd_is_running() for
 better readability
In-Reply-To: <1339663776-196-1-git-send-email-jiang.liu@huawei.com>
Message-ID: <alpine.DEB.2.00.1206161913370.797@chino.kir.corp.google.com>
References: <4FD97718.6060008@kernel.org> <1339663776-196-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

On Thu, 14 Jun 2012, Jiang Liu wrote:

> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index c84ec68..36249d5 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -301,6 +301,11 @@ static inline void scan_unevictable_unregister_node(struct node *node)
>  
>  extern int kswapd_run(int nid);
>  extern void kswapd_stop(int nid);
> +static inline bool kswapd_is_running(int nid)
> +{
> +	return !!(NODE_DATA(nid)->kswapd);
> +}
> +
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  extern int mem_cgroup_swappiness(struct mem_cgroup *mem);
>  #else
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 0d7e3ec..88e479d 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -522,7 +522,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
>  	init_per_zone_wmark_min();
>  
>  	if (onlined_pages) {
> -		kswapd_run(zone_to_nid(zone));
> +		if (!kswapd_is_running(zone_to_nid(zone)))
> +			kswapd_run(zone_to_nid(zone));
>  		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
>  	}
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7585101..3dafdbe 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2941,8 +2941,7 @@ int kswapd_run(int nid)
>  	pg_data_t *pgdat = NODE_DATA(nid);
>  	int ret = 0;
>  
> -	if (pgdat->kswapd)
> -		return 0;
> +	BUG_ON(pgdat->kswapd);
>  
>  	pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
>  	if (IS_ERR(pgdat->kswapd)) {

This isn't better, there's no functional change and you've just added a 
second conditional for no reason and an unnecessary kswapd_is_running() 
function.

More concerning is that online_pages() doesn't check the return value of 
kswapd_run().  We should probably fail the memory hotplug operation that 
onlines a new node and doesn't have a kswapd running and cleanup after 
ourselves in online_pages() with some sane error handling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
