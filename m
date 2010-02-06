Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F220B6B0047
	for <linux-mm@kvack.org>; Sat,  6 Feb 2010 17:31:15 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id o16MVF6c030761
	for <linux-mm@kvack.org>; Sat, 6 Feb 2010 14:31:15 -0800
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by spaceape10.eur.corp.google.com with ESMTP id o16MVBHr018464
	for <linux-mm@kvack.org>; Sat, 6 Feb 2010 14:31:12 -0800
Received: by pxi9 with SMTP id 9so5287213pxi.24
        for <linux-mm@kvack.org>; Sat, 06 Feb 2010 14:31:10 -0800 (PST)
Date: Sat, 6 Feb 2010 14:31:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [1/4] SLAB: Handle node-not-up case in
 fallback_alloc()
In-Reply-To: <20100206155624.GA2777@one.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002061418590.23073@chino.kir.corp.google.com>
References: <201002031039.710275915@firstfloor.org> <20100203213912.D3081B1620@basil.firstfloor.org> <alpine.DEB.2.00.1002051251390.2376@chino.kir.corp.google.com> <20100206072508.GN29555@one.firstfloor.org> <alpine.DEB.2.00.1002060148300.17897@chino.kir.corp.google.com>
 <20100206155624.GA2777@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Feb 2010, Andi Kleen wrote:

> > If a hot-added node has not been initialized for the cache, your code is 
> > picking an existing one in zonelist order which may be excluded by 
> > current's cpuset.  Thus, your code has a very real chance of having 
> > kmem_getpages() return NULL because get_page_from_freelist() will reject 
> > non-atomic ALLOC_CPUSET allocations for prohibited nodes.  That isn't a 
> > scenario that requires a "funny cpuset," it just has to not allow whatever 
> > initialized node comes first in the zonelist.
> 
> The point was that you would need to run whoever triggers the memory
> hotadd in a cpuset with limitations. That would be a clear
> don't do that if hurts(tm)
>  

With a subset of memory nodes, yes.  What else prohibits that except for 
your new code?  

There's a second issue with this approach that I eluded to above: you're 
picking the first initialized node for the cache based solely on whether 
it is allocated or not.  kmem_getpages() may still return NULL when it 
would return new slab for any other initialized node, so you're better off 
trying them all.

In other words, my earlier (untested) suggestion:

diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3172,6 +3172,7 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	gfp_t local_flags;
 	struct zoneref *z;
 	struct zone *zone;
+	nodemask_t allowed_nodes = NODE_MASK_NONE;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
 	int nid;
@@ -3197,6 +3198,7 @@ retry:
 					flags | GFP_THISNODE, nid);
 				if (obj)
 					break;
+				node_set(nid, allowed_nodes);
 		}
 	}
 
@@ -3210,7 +3212,15 @@ retry:
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
 		kmem_flagcheck(cache, flags);
-		obj = kmem_getpages(cache, local_flags, numa_node_id());
+		nid = numa_node_id();
+		if (cache->nodelists[nid])
+			obj = kmem_getpages(cache, local_flags, nid);
+		else
+			for_each_node_mask(nid, allowed_nodes) {
+				obj = kmem_getpages(cache, local_flags, nid);
+				if (obj)
+					break;
+			}
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
 		if (obj) {

Anyway, I'll leave these otherwise unnecessary limitations to Pekka.  
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
