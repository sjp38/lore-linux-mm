Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 76E156B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 19:19:45 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so2425970pdj.16
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 16:19:45 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id l8si2000797pao.326.2014.01.08.16.19.42
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 16:19:44 -0800 (PST)
Date: Thu, 9 Jan 2014 09:20:00 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140109002000.GB15738@lge.com>
References: <20140107132100.5b5ad198@kryten>
 <20140107074136.GA4011@lge.com>
 <52cbce84.aa71b60a.537c.ffffd9efSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52cbce84.aa71b60a.537c.ffffd9efSMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>, benh@kernel.crashing.org, paulus@samba.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jan 07, 2014 at 05:52:31PM +0800, Wanpeng Li wrote:
> On Tue, Jan 07, 2014 at 04:41:36PM +0900, Joonsoo Kim wrote:
> >On Tue, Jan 07, 2014 at 01:21:00PM +1100, Anton Blanchard wrote:

> >> Index: b/mm/slub.c
> >> ===================================================================
> >> --- a/mm/slub.c
> >> +++ b/mm/slub.c
> >> @@ -2278,10 +2278,17 @@ redo:
> >>  
> >>  	if (unlikely(!node_match(page, node))) {
> >>  		stat(s, ALLOC_NODE_MISMATCH);
> >> -		deactivate_slab(s, page, c->freelist);
> >> -		c->page = NULL;
> >> -		c->freelist = NULL;
> >> -		goto new_slab;
> >> +
> >> +		/*
> >> +		 * If the node contains no memory there is no point in trying
> >> +		 * to allocate a new node local slab
> >> +		 */
> >> +		if (node_spanned_pages(node)) {
> >> +			deactivate_slab(s, page, c->freelist);
> >> +			c->page = NULL;
> >> +			c->freelist = NULL;
> >> +			goto new_slab;
> >> +		}
> >>  	}
> >>  
> >>  	/*
> >
> >Hello,
> >
> >I think that we need more efforts to solve unbalanced node problem.
> >
> >With this patch, even if node of current cpu slab is not favorable to
> >unbalanced node, allocation would proceed and we would get the unintended memory.
> >
> >And there is one more problem. Even if we have some partial slabs on
> >compatible node, we would allocate new slab, because get_partial() cannot handle
> >this unbalance node case.
> >
> >To fix this correctly, how about following patch?
> >
> >Thanks.
> >
> >------------->8--------------------
> >diff --git a/mm/slub.c b/mm/slub.c
> >index c3eb3d3..a1f6dfa 100644
> >--- a/mm/slub.c
> >+++ b/mm/slub.c
> >@@ -1672,7 +1672,19 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
> > {
> >        void *object;
> >        int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
> >+       struct zonelist *zonelist;
> >+       struct zoneref *z;
> >+       struct zone *zone;
> >+       enum zone_type high_zoneidx = gfp_zone(flags);
> >
> >+       if (!node_present_pages(searchnode)) {
> >+               zonelist = node_zonelist(searchnode, flags);
> >+               for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> >+                       searchnode = zone_to_nid(zone);
> >+                       if (node_present_pages(searchnode))
> >+                               break;
> >+               }
> >+       }
> 
> Why change searchnode instead of depending on fallback zones/nodes in 
> get_any_partial() to allocate partial slabs?
> 

If node != NUMA_NO_NODE, get_any_partial() isn't called.
That's why I change searchnode here instead of get_any_partial().

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
