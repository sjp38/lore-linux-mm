Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DACAF6B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 06:14:48 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so31443171pad.9
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 03:14:48 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ke10si22713342pbc.235.2015.01.12.03.14.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 03:14:47 -0800 (PST)
Date: Mon, 12 Jan 2015 14:14:40 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 2/3] mm: memcontrol: consolidate memory controller
 initialization
Message-ID: <20150112111440.GC384@esperanza>
References: <1420856041-27647-1-git-send-email-hannes@cmpxchg.org>
 <1420856041-27647-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1420856041-27647-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jan 09, 2015 at 09:14:00PM -0500, Johannes Weiner wrote:
> The initialization code for the per-cpu charge stock and the soft
> limit tree is compact enough to inline it into mem_cgroup_init().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 57 ++++++++++++++++++++++++---------------------------------
>  1 file changed, 24 insertions(+), 33 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index aad254b30708..f66bb8f83ac9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> @@ -5927,10 +5896,32 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>   */
>  static int __init mem_cgroup_init(void)
>  {
> +	int cpu, nid;
> +
>  	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
> +
> +	for_each_possible_cpu(cpu)
> +		INIT_WORK(&per_cpu_ptr(&memcg_stock, cpu)->work,
> +			  drain_local_stock);
> +
> +	for_each_node(nid) {
> +		struct mem_cgroup_tree_per_node *rtpn;
> +		int zone;
> +
> +		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, nid);

I'd like to see BUG_ON(!rtpn) here, just for clarity. Not critical
though.

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

> +
> +		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
> +			struct mem_cgroup_tree_per_zone *rtpz;
> +
> +			rtpz = &rtpn->rb_tree_per_zone[zone];
> +			rtpz->rb_root = RB_ROOT;
> +			spin_lock_init(&rtpz->lock);
> +		}
> +		soft_limit_tree.rb_tree_per_node[nid] = rtpn;
> +	}
> +
>  	enable_swap_cgroup();
> -	mem_cgroup_soft_limit_tree_init();
> -	memcg_stock_init();
> +
>  	return 0;
>  }
>  subsys_initcall(mem_cgroup_init);
> -- 
> 2.2.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
