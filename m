Date: Thu, 17 Jan 2008 06:30:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: crash in kmem_cache_init
In-Reply-To: <84144f020801170414q7d408a74uf47a84b777c36a4a@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0801170628580.19208@schroedinger.engr.sgi.com>
References: <20080115150949.GA14089@aepfle.de>
 <84144f020801170414q7d408a74uf47a84b777c36a4a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jan 2008, Pekka Enberg wrote:

> Looks similar to the one discussed on linux-mm ("[BUG] at
> mm/slab.c:3320" thread). Christoph?

Right. Try the latest version of the patch to fix it:

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2008-01-03 12:26:42.000000000 -0800
+++ linux-2.6/mm/slab.c	2008-01-09 15:59:49.000000000 -0800
@@ -2977,7 +2977,10 @@ retry:
 	}
 	l3 = cachep->nodelists[node];
 
-	BUG_ON(ac->avail > 0 || !l3);
+	if (!l3)
+		return NULL;
+
+	BUG_ON(ac->avail > 0);
 	spin_lock(&l3->list_lock);
 
 	/* See if we can refill from the shared array */
@@ -3224,7 +3227,7 @@ static void *alternate_node_alloc(struct
 		nid_alloc = cpuset_mem_spread_node();
 	else if (current->mempolicy)
 		nid_alloc = slab_node(current->mempolicy);
-	if (nid_alloc != nid_here)
+	if (nid_alloc != nid_here && node_state(nid_alloc, N_NORMAL_MEMORY))
 		return ____cache_alloc_node(cachep, flags, nid_alloc);
 	return NULL;
 }
@@ -3439,8 +3442,14 @@ __do_cache_alloc(struct kmem_cache *cach
 	 * We may just have run out of memory on the local node.
 	 * ____cache_alloc_node() knows how to locate memory on other nodes
 	 */
- 	if (!objp)
- 		objp = ____cache_alloc_node(cache, flags, numa_node_id());
+ 	if (!objp) {
+		int node_id = numa_node_id();
+		if (likely(cache->nodelists[node_id])) /* fast path */
+ 			objp = ____cache_alloc_node(cache, flags, node_id);
+		else /* this function can do good fallback */
+			objp = __cache_alloc_node(cache, flags, node_id,
+					__builtin_return_address(0));
+	}
 
   out:
 	return objp;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
