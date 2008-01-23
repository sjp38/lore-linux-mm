Date: Wed, 23 Jan 2008 19:42:11 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Fix boot problem in situations where the boot CPU is
 running on a memoryless node
In-Reply-To: <Pine.LNX.4.64.0801231906520.1028@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0801231941220.3647@sbz-30.cs.Helsinki.FI>
References: <20080122214505.GA15674@aepfle.de>
 <Pine.LNX.4.64.0801221417480.1912@schroedinger.engr.sgi.com>
 <20080123075821.GA17713@aepfle.de> <20080123105044.GD21455@csn.ul.ie>
 <20080123121459.GA18631@aepfle.de> <20080123125236.GA18876@aepfle.de>
 <20080123135513.GA14175@csn.ul.ie> <Pine.LNX.4.64.0801231611160.20050@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0801231626320.21475@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0801231648140.23343@sbz-30.cs.Helsinki.FI>
 <20080123155655.GB20156@csn.ul.ie> <Pine.LNX.4.64.0801231906520.1028@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, Olaf Hering <olaf@aepfle.de>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008, Pekka J Enberg wrote:
> As far as I can tell, there are two ways to fix this:

[snip]
 
>   (2) initialize cache_cache.nodelists with initmem_list3 equivalents
>       for *each node hat has normal memory*

An untested patch follows:

---
 mm/slab.c |   39 ++++++++++++++++++++-------------------
 1 file changed, 20 insertions(+), 19 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -304,11 +304,11 @@ struct kmem_list3 {
 /*
  * Need this for bootstrapping a per node allocator.
  */
-#define NUM_INIT_LISTS (2 * MAX_NUMNODES + 1)
+#define NUM_INIT_LISTS (3 * MAX_NUMNODES)
 struct kmem_list3 __initdata initkmem_list3[NUM_INIT_LISTS];
 #define	CACHE_CACHE 0
-#define	SIZE_AC 1
-#define	SIZE_L3 (1 + MAX_NUMNODES)
+#define	SIZE_AC MAX_NUMNODES
+#define	SIZE_L3 (2 * MAX_NUMNODES)
 
 static int drain_freelist(struct kmem_cache *cache,
 			struct kmem_list3 *l3, int tofree);
@@ -1410,6 +1410,22 @@ static void init_list(struct kmem_cache 
 }
 
 /*
+ * For setting up all the kmem_list3s for cache whose buffer_size is same as
+ * size of kmem_list3.
+ */
+static void __init set_up_list3s(struct kmem_cache *cachep, int index)
+{
+	int node;
+
+	for_each_node_state(node, N_NORMAL_MEMORY) {
+		cachep->nodelists[node] = &initkmem_list3[index + node];
+		cachep->nodelists[node]->next_reap = jiffies +
+		    REAPTIMEOUT_LIST3 +
+		    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
+	}
+}
+
+/*
  * Initialisation.  Called after the page allocator have been initialised and
  * before smp_init().
  */
@@ -1432,6 +1448,7 @@ void __init kmem_cache_init(void)
 		if (i < MAX_NUMNODES)
 			cache_cache.nodelists[i] = NULL;
 	}
+	set_up_list3s(&cache_cache, CACHE_CACHE);
 
 	/*
 	 * Fragmentation resistance on low memory - only use bigger
@@ -1964,22 +1981,6 @@ static void slab_destroy(struct kmem_cac
 	}
 }
 
-/*
- * For setting up all the kmem_list3s for cache whose buffer_size is same as
- * size of kmem_list3.
- */
-static void __init set_up_list3s(struct kmem_cache *cachep, int index)
-{
-	int node;
-
-	for_each_node_state(node, N_NORMAL_MEMORY) {
-		cachep->nodelists[node] = &initkmem_list3[index + node];
-		cachep->nodelists[node]->next_reap = jiffies +
-		    REAPTIMEOUT_LIST3 +
-		    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
-	}
-}
-
 static void __kmem_cache_destroy(struct kmem_cache *cachep)
 {
 	int i;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
