Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id 955506B0031
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 15:25:14 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id u14so2507479bkz.39
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 12:25:13 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ue4si4426001bkb.81.2013.12.16.12.25.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 12:25:13 -0800 (PST)
Date: Mon, 16 Dec 2013 15:25:07 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/7] mm: page_alloc: Use zone node IDs to approximate
 locality
Message-ID: <20131216202507.GZ21724@cmpxchg.org>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386943807-29601-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 13, 2013 at 02:10:03PM +0000, Mel Gorman wrote:
> zone_local is using node_distance which is a more expensive call than
> necessary. On x86, it's another function call in the allocator fast path
> and increases cache footprint. This patch makes the assumption zones on a
> local node will share the same node ID. The necessary information should
> already be cache hot.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 64020eb..fd9677e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1816,7 +1816,7 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
>  
>  static bool zone_local(struct zone *local_zone, struct zone *zone)
>  {
> -	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
> +	return zone_to_nid(zone) == numa_node_id();

Why numa_node_id()?  We pass in the preferred zone as @local_zone:

return zone_to_nid(local_zone) == zone_to_nid(zone)

Or even just compare the ->zone_pgdat pointers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
