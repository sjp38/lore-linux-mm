Date: Fri, 9 Nov 2007 07:45:33 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
In-Reply-To: <20071109143426.23540.44459.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0711090741120.13932@schroedinger.engr.sgi.com>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
 <20071109143426.23540.44459.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007, Mel Gorman wrote:

>  struct page * fastcall
>  __alloc_pages(gfp_t gfp_mask, unsigned int order,
>  		struct zonelist *zonelist)
>  {
> +	/*
> +	 * Use a temporary nodemask for __GFP_THISNODE allocations. If the
> +	 * cost of allocating on the stack or the stack usage becomes
> +	 * noticable, allocate the nodemasks per node at boot or compile time
> +	 */
> +	if (unlikely(gfp_mask & __GFP_THISNODE)) {
> +		nodemask_t nodemask;

Hmmm.. This places a potentially big structure on the stack. nodemask can 
contain up to 1024 bits which means 128 bytes. Maybe keep an array of 
gfp_thisnode nodemasks (node_nodemask?) and use node_nodemask[nid]?

> +
> +		return __alloc_pages_internal(gfp_mask, order,
> +			zonelist, nodemask_thisnode(numa_node_id(), &nodemask));

Argh.... GFP_THISNODE must use the nid passed to alloc_pages_node and 
*not* the local numa node id. Only if the node specified to alloc_pages 
nodes is -1 will this work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
