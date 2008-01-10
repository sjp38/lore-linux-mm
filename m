Date: Wed, 9 Jan 2008 16:02:18 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG]  at mm/slab.c:3320
In-Reply-To: <20080109221315.GB26941@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0801091601080.14723@schroedinger.engr.sgi.com>
References: <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com>
 <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
 <20080109065015.GG7602@us.ibm.com> <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com>
 <20080109185859.GD11852@skywalker> <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com>
 <20080109214707.GA26941@us.ibm.com> <Pine.LNX.4.64.0801091349430.12505@schroedinger.engr.sgi.com>
 <20080109221315.GB26941@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

New patch that also checks in alternate_node_alloc if the node has normal 
memory because we cannot call ____cache_alloc_node with an invalid node.


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
