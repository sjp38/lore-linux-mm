Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 641AF440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 10:18:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u110so11355708wrb.14
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 07:18:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j63si2396218wmg.3.2017.07.14.07.18.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 07:18:26 -0700 (PDT)
Date: Fri, 14 Jul 2017 15:18:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/9] mm, page_alloc: simplify zonelist initialization
Message-ID: <20170714141823.2j7t37t6zdzdf3sv@suse.de>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-7-mhocko@kernel.org>
 <20170714124645.i3duhuie6cczlybr@suse.de>
 <20170714130242.GQ2618@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170714130242.GQ2618@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 14, 2017 at 03:02:42PM +0200, Michal Hocko wrote:
> > It *might* be safer given the next patch to zero out the remainder of
> > the _zonerefs to that there is no combination of node add/remove that has
> > an iterator working with a semi-valid _zoneref which is beyond the last
> > correct value. It *should* be safe as the very last entry will always
> > be null but if you don't zero it out, it is possible for iterators to be
> > working beyond the "end" of the zonelist for a short window.
> 
> yes that is true but there will always be terminating NULL zone and I
> found that acceptable. It is basically the same thing as accessing an
> empty zone or a zone twice. Or do you think this is absolutely necessary
> to handle?
> 

I don't think it's absolutely necessary. While you could construct some
odd behaviour for iterators currently past the end of the list, they would
eventually encounter a NULL.

> > Otherwise think it's ok including my stupid comment about node_order
> > stack usage.
> 
> What do you think about this on top?
> ---
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 49bade7ff049..3b98524c04ec 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4913,20 +4913,21 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
>   * This results in maximum locality--normal zone overflows into local
>   * DMA zone, if any--but risks exhausting DMA zone.
>   */
> -static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order)
> +static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
> +		unsigned nr_nodes)
>  {
>  	struct zonelist *zonelist;
> -	int i, zoneref_idx = 0;
> +	int i, nr_zones = 0;
>  
>  	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
>  
> -	for (i = 0; i < MAX_NUMNODES; i++) {
> +	for (i = 0; i < nr_nodes; i++) {

The first iteration is then -- for (i = 0; i < 0; i++)

Fairly sure that's not what you meant.


>  		pg_data_t *node = NODE_DATA(node_order[i]);
>  
> -		zoneref_idx = build_zonelists_node(node, zonelist, zoneref_idx);
> +		nr_zones = build_zonelists_node(node, zonelist, nr_zones);

I meant converting build_zonelists_node and passing in &nr_zones and
returning false when an empty node is encountered. In this context,
it's also not about zones, it really is nr_zonerefs. Rename nr_zones in
build_zonelists_node as well.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
