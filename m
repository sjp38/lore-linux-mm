Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE41C6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:06:49 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so28711936lbb.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:06:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uq9si5880769wjb.114.2016.06.16.08.06.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 08:06:48 -0700 (PDT)
Subject: Re: [PATCH 13/27] mm, memcg: Move memcg limit enforcement from zones
 to nodes
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-14-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2aea9490-99aa-4e55-e7ca-22b695eee1da@suse.cz>
Date: Thu, 16 Jun 2016 17:06:46 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-14-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> Memcg was broken by the move of all LRUs to nodes because it is tracking
> limits on a per-zone basis while receiving reclaim requests on a per-node
> basis. This patch moves limit enforcement to the nodes. Technically, all
> the variable names should also change but people are already familiar by
> the meaning of "mz" even if "mn" would be a more appropriate name now.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Didn't spot bugs, but I'm not that familiar with memcg. Noticed some 
things below to further optimize/cleanup.

[...]

> @@ -323,13 +319,10 @@ EXPORT_SYMBOL(memcg_kmem_enabled_key);
>
>  #endif /* !CONFIG_SLOB */
>
> -static struct mem_cgroup_per_zone *
> -mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
> +static struct mem_cgroup_per_node *
> +mem_cgroup_nodeinfo(struct mem_cgroup *memcg, pg_data_t *pgdat)
>  {
> -	int nid = zone_to_nid(zone);
> -	int zid = zone_idx(zone);
> -
> -	return &memcg->nodeinfo[nid]->zoneinfo[zid];
> +	return memcg->nodeinfo[pgdat->node_id];

I've noticed most callers pass NODE_DATA(nid) as second parameter, which 
is quite wasteful to just obtain back the node_id (I doubt the compiler 
can know that they will be the same?). So it would be more efficient to 
use nid instead of pg_data_t pointer in the signature.

>  }
>
>  /**
> @@ -383,37 +376,35 @@ ino_t page_cgroup_ino(struct page *page)
>  	return ino;
>  }
>
> -static struct mem_cgroup_per_zone *
> +static struct mem_cgroup_per_node *
>  mem_cgroup_page_zoneinfo(struct mem_cgroup *memcg, struct page *page)

This could be renamed to _nodeinfo()?

>  {
>  	int nid = page_to_nid(page);
> -	int zid = page_zonenum(page);
>
> -	return &memcg->nodeinfo[nid]->zoneinfo[zid];
> +	return memcg->nodeinfo[nid];
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
