Date: Tue, 8 Aug 2006 15:07:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: slab: Do not panic when alloc_kmemlist fails and slab is up
Message-ID: <Pine.LNX.4.64.0608081505350.30724@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It is fairly easy to get a system to oops by simply
sizing a cache via /proc in such a way that one of the chaches
(shared is easiest) becomes bigger than the maximum allowed
slab allocation size. This occurs because enable_cpucache()
fails if it cannot reallocate some caches.

However, enable_cpucache() is used for multiple purposes: 
resizing caches, cache creation and bootstrap.

If the slab is already up then we already have working caches.
The resize can fail without a problem. We just need to return
the proper error code. F.e. after this patch:


# echo "size-64 10000 50 1000" >/proc/slabinfo
-bash: echo: write error: Cannot allocate memory

notice no OOPS.

If we are doing a kmem_cache_create() then we also should not panic but 
return -ENOMEM.

If on the other hand we do not have a fully bootstrapped
slab allocator yet then we should indeed panic since we
are unable to bring up the slab to its full functionality.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4/mm/slab.c
===================================================================
--- linux-2.6.18-rc4.orig/mm/slab.c	2006-08-08 12:29:51.171372961 -0700
+++ linux-2.6.18-rc4/mm/slab.c	2006-08-08 14:53:48.938350090 -0700
@@ -313,7 +313,7 @@ static int drain_freelist(struct kmem_ca
 			struct kmem_list3 *l3, int tofree);
 static void free_block(struct kmem_cache *cachep, void **objpp, int len,
 			int node);
-static void enable_cpucache(struct kmem_cache *cachep);
+static int enable_cpucache(struct kmem_cache *cachep);
 static void cache_reap(void *unused);
 
 /*
@@ -1491,7 +1491,8 @@ void __init kmem_cache_init(void)
 		struct kmem_cache *cachep;
 		mutex_lock(&cache_chain_mutex);
 		list_for_each_entry(cachep, &cache_chain, next)
-			enable_cpucache(cachep);
+			if (enable_cpucache(cachep))
+				BUG();
 		mutex_unlock(&cache_chain_mutex);
 	}
 
@@ -1925,12 +1926,11 @@ static size_t calculate_slab_order(struc
 	return left_over;
 }
 
-static void setup_cpu_cache(struct kmem_cache *cachep)
+static int setup_cpu_cache(struct kmem_cache *cachep)
 {
-	if (g_cpucache_up == FULL) {
-		enable_cpucache(cachep);
-		return;
-	}
+	if (g_cpucache_up == FULL)
+		return enable_cpucache(cachep);
+
 	if (g_cpucache_up == NONE) {
 		/*
 		 * Note: the first kmem_cache_create must create the cache
@@ -1977,6 +1977,7 @@ static void setup_cpu_cache(struct kmem_
 	cpu_cache_get(cachep)->touched = 0;
 	cachep->batchcount = 1;
 	cachep->limit = BOOT_CPUCACHE_ENTRIES;
+	return 0;
 }
 
 /**
@@ -2227,8 +2228,11 @@ kmem_cache_create (const char *name, siz
 	cachep->dtor = dtor;
 	cachep->name = name;
 
-
-	setup_cpu_cache(cachep);
+	if (setup_cpu_cache(cachep)) {
+		__kmem_cache_destroy(cachep);
+		cachep = NULL;
+		goto oops;
+	}
 
 	/* cache setup completed, link it into the list */
 	list_add(&cachep->next, &cache_chain);
@@ -3610,7 +3614,7 @@ static int do_tune_cpucache(struct kmem_
 				int batchcount, int shared)
 {
 	struct ccupdate_struct new;
-	int i, err;
+	int i;
 
 	memset(&new.new, 0, sizeof(new.new));
 	for_each_online_cpu(i) {
@@ -3641,17 +3645,11 @@ static int do_tune_cpucache(struct kmem_
 		kfree(ccold);
 	}
 
-	err = alloc_kmemlist(cachep);
-	if (err) {
-		printk(KERN_ERR "alloc_kmemlist failed for %s, error %d.\n",
-		       cachep->name, -err);
-		BUG();
-	}
-	return 0;
+	return alloc_kmemlist(cachep);
 }
 
 /* Called with cache_chain_mutex held always */
-static void enable_cpucache(struct kmem_cache *cachep)
+static int enable_cpucache(struct kmem_cache *cachep)
 {
 	int err;
 	int limit, shared;
@@ -3703,6 +3701,7 @@ static void enable_cpucache(struct kmem_
 	if (err)
 		printk(KERN_ERR "enable_cpucache failed for %s, error %d.\n",
 		       cachep->name, -err);
+	return err;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
