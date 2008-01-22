Date: Tue, 22 Jan 2008 15:12:20 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: crash in kmem_cache_init
In-Reply-To: <47967560.8080101@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0801221501240.2565@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
 <20080117211511.GA25320@aepfle.de> <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com>
 <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com>
 <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie>
 <Pine.LNX.4.64.0801221203340.27950@schroedinger.engr.sgi.com>
 <20080122212654.GB15567@csn.ul.ie> <Pine.LNX.4.64.0801221330390.1652@schroedinger.engr.sgi.com>
 <20080122225046.GA866@csn.ul.ie> <47967560.8080101@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008, Pekka Enberg wrote:

> When we call fallback_alloc() because the current node has ->nodelists set to
> NULL, we end up calling kmem_getpages() with -1 as the node id which is then
> translated to numa_node_id() by alloc_pages_node. But the reason we called
> fallback_alloc() in the first place is because numa_node_id() doesn't have a
> ->nodelist which makes cache_grow() oops.

Right, if nodeid == -1 then we need to call alloc_pages... 
Essentiall a revert of 50c85a19e7b3928b5b5188524c44ffcbacdd4e35 from 2005.

But I doubt that this is it. The fallback logic was added later and it 
worked fine.


---
 mm/slab.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2008-01-22 15:05:26.185452369 -0800
+++ linux-2.6/mm/slab.c	2008-01-22 15:05:59.301637009 -0800
@@ -1668,7 +1668,11 @@ static void *kmem_getpages(struct kmem_c
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		flags |= __GFP_RECLAIMABLE;
 
-	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
+	if (nodeid == -1)
+		page = alloc_pages(flags, cachep->gfporder);
+	else
+		page = alloc_pages_node(nodeid, flags, cachep->gfporder);
+
 	if (!page)
 		return NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
