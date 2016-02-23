Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9A56B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:13:23 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id g62so6265534wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:13:23 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gk3si46132852wjd.195.2016.02.23.10.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 10:13:22 -0800 (PST)
Date: Tue, 23 Feb 2016 10:13:18 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 03/27] mm, vmstat: Add infrastructure for per-node vmstats
Message-ID: <20160223181318.GC13816@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456239890-20737-4-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 03:04:26PM +0000, Mel Gorman wrote:
> VM statistic counters for reclaim decisions are zone-based. If the kernel
> is to reclaim on a per-node basis then we need to track per-node statistics
> but there is no infrastructure for that. The most notable change is that
> the old node_page_state is renamed to sum_zone_node_page_state.  The new
> node_page_state takes a pglist_data and uses per-node stats but none exist
> yet. There is some renaming such as vm_stat to vm_zone_stat and the addition
> of vm_node_stat and the renaming of mod_state to mod_zone_state. Otherwise,
> this is mostly a mechanical patch with no functional change. There is a
> lot of similarity between the node and zone helpers which is unfortunate
> but there was no obvious way of reusing the code and maintaining type safety.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Hopefully we can eventually ditch /proc/zoneinfo in favor of a
/proc/nodeinfo and get rid of the per-zone stats accounting.

In general, this patch looks good to me.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Only one thing I noticed:

> @@ -349,12 +349,14 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
>  	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
>  	local_irq_enable();
>  
> -	if (memcg_kmem_enabled())
> +	if (memcg_kmem_enabled()) {
>  		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
>  						     LRU_ALL_FILE);
> -	else
> -		pages = node_page_state(sc->nid, NR_ACTIVE_FILE) +
> -			node_page_state(sc->nid, NR_INACTIVE_FILE);
> +	} else {
> +		pg_data_t *pgdat = NODE_DATA(sc->nid);
> +		pages = node_page_state(pgdat, NR_ACTIVE_FILE) +
> +			node_page_state(pgdat, NR_INACTIVE_FILE);
> +	}

That should also be sum_zone_node_page_state, right? These are not
valid node items (yet).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
