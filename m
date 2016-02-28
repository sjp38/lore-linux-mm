Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE896B0255
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 11:17:18 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id n186so18326816wmn.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 08:17:18 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x10si27515409wjf.206.2016.02.28.08.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 08:17:17 -0800 (PST)
Date: Sun, 28 Feb 2016 11:17:13 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 15/27] mm, workingset: Make working set detection
 node-aware
Message-ID: <20160228161713.GF25622@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-16-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456239890-20737-16-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 03:04:38PM +0000, Mel Gorman wrote:
> @@ -167,33 +167,30 @@
>   */
>  static unsigned int bucket_order __read_mostly;
>  
> -static void *pack_shadow(int memcgid, struct zone *zone, unsigned long eviction)
> +static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
>  {
>  	eviction >>= bucket_order;
>  	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
> -	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
> -	eviction = (eviction << ZONES_SHIFT) | zone_idx(zone);
> +	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
>  	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);

You need to remove ZONES_SHIFT from the EVICTION_SHIFT as well.

Other than that it looks good to me.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
