Message-Id: <20070618095918.872887071@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:59:01 -0700
From: clameter@sgi.com
Subject: [patch 23/26] SLUB: Move sysfs operations outside of slub_lock
Content-Disposition: inline; filename=slub_lock_cleanup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

Sysfs can do a gazillion things when called. Make sure that we do
not call any sysfs functions while holding the slub_lock.

Just protect the essentials:

1. The list of all slab caches
2. The kmalloc_dma array
3. The ref counters of the slabs.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-17 18:12:37.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-17 18:12:44.000000000 -0700
@@ -2217,12 +2217,13 @@ void kmem_cache_destroy(struct kmem_cach
 	s->refcount--;
 	if (!s->refcount) {
 		list_del(&s->list);
+		up_write(&slub_lock);
 		if (kmem_cache_close(s))
 			WARN_ON(1);
 		sysfs_slab_remove(s);
 		kfree(s);
-	}
-	up_write(&slub_lock);
+	} else
+		up_write(&slub_lock);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
@@ -3027,26 +3028,33 @@ struct kmem_cache *kmem_cache_create(con
 		 */
 		s->objsize = max(s->objsize, (int)size);
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
+		up_write(&slub_lock);
+
 		if (sysfs_slab_alias(s, name))
 			goto err;
-	} else {
-		s = kmalloc(kmem_size, GFP_KERNEL);
-		if (s && kmem_cache_open(s, GFP_KERNEL, name,
+
+		return s;
+	}
+
+	s = kmalloc(kmem_size, GFP_KERNEL);
+	if (s) {
+		if (kmem_cache_open(s, GFP_KERNEL, name,
 				size, align, flags, ctor, ops)) {
-			if (sysfs_slab_add(s)) {
-				kfree(s);
-				goto err;
-			}
 			list_add(&s->list, &slab_caches);
+			up_write(&slub_lock);
 			raise_kswapd_order(s->order);
-		} else
-			kfree(s);
+
+			if (sysfs_slab_add(s))
+				goto err;
+
+			return s;
+
+		}
+		kfree(s);
 	}
 	up_write(&slub_lock);
-	return s;
 
 err:
-	up_write(&slub_lock);
 	if (flags & SLAB_PANIC)
 		panic("Cannot create slabcache %s\n", name);
 	else

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
