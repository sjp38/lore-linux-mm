Date: Tue, 8 Aug 2006 15:12:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: slab: Do not panic when alloc_kmemlist fails and slab is up
In-Reply-To: <Pine.LNX.4.64.0608081505350.30724@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0608081512070.30775@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608081505350.30724@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Juck. There is an additional patch that needs to come before this one:


Extract __kmem_cache_destroy from kmem_cache_destroy

The ability to free memory allocated to a slab cache is also
useful if an error occurs during setup of a slab. So extract the
function.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc3/mm/slab.c
===================================================================
--- linux-2.6.18-rc3.orig/mm/slab.c	2006-07-29 23:15:36.000000000 -0700
+++ linux-2.6.18-rc3/mm/slab.c	2006-08-03 22:42:40.237820130 -0700
@@ -1834,6 +1834,27 @@ static void set_up_list3s(struct kmem_ca
 	}
 }
 
+static void __kmem_cache_destroy(struct kmem_cache *cachep)
+{
+	int i;
+	struct kmem_list3 *l3;
+
+	for_each_online_cpu(i)
+	    kfree(cachep->array[i]);
+
+	/* NUMA: free the list3 structures */
+	for_each_online_node(i) {
+		l3 = cachep->nodelists[i];
+		if (l3) {
+			kfree(l3->shared);
+			free_alien_cache(l3->alien);
+			kfree(l3);
+		}
+	}
+	kmem_cache_free(&cache_cache, cachep);
+}
+
+
 /**
  * calculate_slab_order - calculate size (page order) of slabs
  * @cachep: pointer to the cache that is being created
@@ -2389,9 +2410,6 @@ EXPORT_SYMBOL(kmem_cache_shrink);
  */
 int kmem_cache_destroy(struct kmem_cache *cachep)
 {
-	int i;
-	struct kmem_list3 *l3;
-
 	BUG_ON(!cachep || in_interrupt());
 
 	/* Don't let CPUs to come and go */
@@ -2417,19 +2435,7 @@ int kmem_cache_destroy(struct kmem_cache
 	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
 		synchronize_rcu();
 
-	for_each_online_cpu(i)
-	    kfree(cachep->array[i]);
-
-	/* NUMA: free the list3 structures */
-	for_each_online_node(i) {
-		l3 = cachep->nodelists[i];
-		if (l3) {
-			kfree(l3->shared);
-			free_alien_cache(l3->alien);
-			kfree(l3);
-		}
-	}
-	kmem_cache_free(&cache_cache, cachep);
+	__kmem_cache_destroy(cachep);
 	unlock_cpu_hotplug();
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
