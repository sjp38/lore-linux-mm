Date: Thu, 14 Jun 2007 00:07:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
In-Reply-To: <1181769033.6148.116.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706140004070.11676@schroedinger.engr.sgi.com>
References: <20070612204843.491072749@sgi.com>  <20070612205738.548677035@sgi.com>
 <1181769033.6148.116.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jun 2007, Lee Schermerhorn wrote:

> --- Linux.orig/include/linux/gfp.h	2007-06-13 16:36:02.000000000 -0400
> +++ Linux/include/linux/gfp.h	2007-06-13 16:38:41.000000000 -0400
> @@ -168,6 +168,9 @@ FASTCALL(__alloc_pages(gfp_t, unsigned i
>  static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
>  {
> +	pg_data_t *pgdat;
> +	struct zonelist *zonelist;
> +
>  	if (unlikely(order >= MAX_ORDER))
>  		return NULL;
>  
> @@ -179,11 +182,13 @@ static inline struct page *alloc_pages_n
>  	 * Check for the special case that GFP_THISNODE is used on a
>  	 * memoryless node
>  	 */
> -	if ((gfp_mask & __GFP_THISNODE) && !node_memory(nid))
> +	pgdat = NODE_DATA(nid);
> +	zonelist = pgdat->node_zonelists + gfp_zone(gfp_mask);
> +	if ((gfp_mask & __GFP_THISNODE) &&
> +		pgdat != zonelist->zones[0]->zone_pgdat)
>  		return NULL;
>  
> -	return __alloc_pages(gfp_mask, order,
> -		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
> +	return __alloc_pages(gfp_mask, order, zonelist);
>  }

Good idea but I think this does not address the case where the DMA zone of 
a node was moved to the end of the zonelist. In that case the first zone 
is not on the first pgdat but the node has memory. The memory of the node 
is listed elsewhere in the nodelist. I can probably modify __alloc_pages 
to make GFP_THISNODE to check all zones but we do not have the pgdat 
reference there. Sigh.

How about generating a special THISNODE zonelist in build_zonelist that 
only contains the zones of a single node. Then just use that one if 
GFP_THISNODE is set. Then we get rid of all the GFP_THISNODE crap that I 
added to __alloc_pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
