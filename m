Date: Wed, 11 Jul 2007 17:06:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 11/12] Memoryless nodes: Fix GFP_THISNODE behavior
Message-Id: <20070711170639.51ebb2d8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070710215456.642568985@sgi.com>
References: <20070710215339.110895755@sgi.com>
	<20070710215456.642568985@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, kxr@sgi.com, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

some nitpicks...

On Tue, 10 Jul 2007 14:52:16 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> +static void build_thisnode_zonelists(pg_data_t *pgdat)
> +{
> +	enum zone_type i;
> +	int j;
> +	struct zonelist *zonelist;
> +
> +	for (i = 0; i < MAX_NR_ZONES; i++) {
> +		zonelist = pgdat->node_zonelists + MAX_NR_ZONES + i;
> + 		j = build_zonelists_node(pgdat, zonelist, 0, i);
> +		zonelist->zones[j] = NULL;
> +	}
> +}
adding explanation as following is maybe good.
==
	/* 
         * NUMA default zonelist is structured as
	 * [0....MAX_NR_ZONES) : allows fallbacks to other node for each GFP_MASK.
	 * [MAX_NR_ZONES...MAX_ZONELISTS) : disallow fallbacks for GFP_XXX |GFP_THISNODE
	 */
==
> +
> +/*
>   * Build zonelists ordered by zone and nodes within zones.
>   * This results in conserving DMA zone[s] until all Normal memory is
>   * exhausted, but results in overflowing to remote node while memory
> @@ -2267,7 +2283,7 @@ static void build_zonelists(pg_data_t *p
>  	int order = current_zonelist_order;
>  
>  	/* initialize zonelists */
> -	for (i = 0; i < MAX_NR_ZONES; i++) {
> +	for (i = 0; i < 2 * MAX_NR_ZONES; i++) {

please use MAX_ZONELISTS here.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
