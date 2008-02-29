Date: Fri, 29 Feb 2008 17:48:15 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] Filter based on a nodemask as well as a gfp_mask
In-Reply-To: <20080227214747.6858.46514.sendpatchset@localhost>
References: <20080227214708.6858.53458.sendpatchset@localhost> <20080227214747.6858.46514.sendpatchset@localhost>
Message-Id: <20080229174540.66FC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Hi 

> The MPOL_BIND policy creates a zonelist that is used for allocations
> controlled by that mempolicy. As the per-node zonelist is already being
> filtered based on a zone id, this patch adds a version of __alloc_pages()
> that takes a nodemask for further filtering. This eliminates the need
> for MPOL_BIND to create a custom zonelist.
> 
> A positive benefit of this is that allocations using MPOL_BIND now use the
> local node's distance-ordered zonelist instead of a custom node-id-ordered
> zonelist.  I.e., pages will be allocated from the closest allowed node with
> available memory.

Great.
this is not only clean up, but also great mempolicy improvement.


> -/* Generate a custom zonelist for the BIND policy. */
> -static struct zonelist *bind_zonelist(nodemask_t *nodes)
> +/* Check that the nodemask contains at least one populated zone */
> +static int is_valid_nodemask(nodemask_t *nodemask)
>  {
(snip)
> +	for_each_node_mask(nd, *nodemask) {
> +		struct zone *z;
> +
> +		for (k = 0; k <= policy_zone; k++) {
> +			z = &NODE_DATA(nd)->node_zones[k];
> +			if (z->present_pages > 0)
> +				return 1;

could we use populated_zone()?


-kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
