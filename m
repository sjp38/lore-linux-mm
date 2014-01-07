Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 211E66B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 04:10:07 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so116213pdi.38
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 01:10:06 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id xu6si20170250pab.254.2014.01.07.01.10.04
        for <linux-mm@kvack.org>;
        Tue, 07 Jan 2014 01:10:05 -0800 (PST)
Date: Tue, 7 Jan 2014 18:10:16 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140107091016.GA21965@lge.com>
References: <20140107132100.5b5ad198@kryten>
 <20140107074136.GA4011@lge.com>
 <52cbbf7b.2792420a.571c.ffffd476SMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52cbbf7b.2792420a.571c.ffffd476SMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>, benh@kernel.crashing.org, paulus@samba.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jan 07, 2014 at 04:48:40PM +0800, Wanpeng Li wrote:
> Hi Joonsoo,
> On Tue, Jan 07, 2014 at 04:41:36PM +0900, Joonsoo Kim wrote:
> >On Tue, Jan 07, 2014 at 01:21:00PM +1100, Anton Blanchard wrote:
> >> 
> [...]
> >Hello,
> >
> >I think that we need more efforts to solve unbalanced node problem.
> >
> >With this patch, even if node of current cpu slab is not favorable to
> >unbalanced node, allocation would proceed and we would get the unintended memory.
> >
> 
> We have a machine:
> 
> [    0.000000] Node 0 Memory:
> [    0.000000] Node 4 Memory: 0x0-0x10000000 0x20000000-0x60000000 0x80000000-0xc0000000
> [    0.000000] Node 6 Memory: 0x10000000-0x20000000 0x60000000-0x80000000
> [    0.000000] Node 10 Memory: 0xc0000000-0x180000000
> 
> [    0.041486] Node 0 CPUs: 0-19
> [    0.041490] Node 4 CPUs:
> [    0.041492] Node 6 CPUs:
> [    0.041495] Node 10 CPUs:
> 
> The pages of current cpu slab should be allocated from fallback zones/nodes 
> of the memoryless node in buddy system, how can not favorable happen? 

Hi, Wanpeng.

IIRC, if we call kmem_cache_alloc_node() with certain node #, we try to
allocate the page in fallback zones/node of that node #. So fallback list isn't
related to fallback one of memoryless node #. Am I wrong?

Thanks.

> 
> >And there is one more problem. Even if we have some partial slabs on
> >compatible node, we would allocate new slab, because get_partial() cannot handle
> >this unbalance node case.
> >
> >To fix this correctly, how about following patch?
> >
> 
> So I think we should fold both of your two patches to one.
> 
> Regards,
> Wanpeng Li 
> 
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
> >        object = get_partial_node(s, get_node(s, searchnode), c, flags);
> >        if (object || node != NUMA_NO_NODE)
> >                return object;
> >
> >--
> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >the body to majordomo@kvack.org.  For more info on Linux MM,
> >see: http://www.linux-mm.org/ .
> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
