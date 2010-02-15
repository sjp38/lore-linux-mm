Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 466EA6B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 01:04:09 -0500 (EST)
Date: Mon, 15 Feb 2010 17:04:00 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [1/4] SLAB: Handle node-not-up case in
 fallback_alloc() v2
Message-ID: <20100215060400.GG5723@laptop>
References: <20100211953.850854588@firstfloor.org>
 <20100211205401.002CFB1978@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100211205401.002CFB1978@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Thu, Feb 11, 2010 at 09:54:00PM +0100, Andi Kleen wrote:
> 
> When fallback_alloc() runs the node of the CPU might not be initialized yet.
> Handle this case by allocating in another node.
> 
> v2: Try to allocate from all nodes (David Rientjes)
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> ---
>  mm/slab.c |   19 ++++++++++++++++++-
>  1 file changed, 18 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.32-memhotadd/mm/slab.c
> ===================================================================
> --- linux-2.6.32-memhotadd.orig/mm/slab.c
> +++ linux-2.6.32-memhotadd/mm/slab.c
> @@ -3188,7 +3188,24 @@ retry:
>  		if (local_flags & __GFP_WAIT)
>  			local_irq_enable();
>  		kmem_flagcheck(cache, flags);
> -		obj = kmem_getpages(cache, local_flags, numa_node_id());
> +
> +		/*
> +		 * Node not set up yet? Try one that the cache has been set up
> +		 * for.
> +		 */
> +		nid = numa_node_id();
> +		if (cache->nodelists[nid] == NULL) {
> +			for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> +				nid = zone_to_nid(zone);
> +				if (cache->nodelists[nid]) {
> +					obj = kmem_getpages(cache, local_flags, nid);
> +					if (obj)
> +						break;
> +				}
> +			}
> +		} else
> +			obj = kmem_getpages(cache, local_flags, nid);
> +
>  		if (local_flags & __GFP_WAIT)
>  			local_irq_disable();
>  		if (obj) {

This is a better way to go anyway because it really is a proper
"fallback" alloc. I think that possibly used to work (ie. kmem_getpages
would be able to pass -1 for the node there) but got broken along the
line.

Although it's not such a hot path to begin with, care to put a branch
annotation there?

Acked-by: Nick Piggin <npiggin@suse.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
