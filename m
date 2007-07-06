Date: Fri, 6 Jul 2007 12:53:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Move sysfs operations outside of slub_lock
Message-ID: <Pine.LNX.4.64.0707061253010.24389@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sysfs can do a gazillion things when called. Make sure that we do
not call any sysfs functions while holding the slub_lock.

Just protect the essentials:

1. The list of all slab caches
2. The kmalloc_dma array
3. The ref counters of the slabs.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

Index: linux-2.6.22-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-04 09:10:16.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-04 09:14:35.000000000 -0700
@@ -2204,12 +2204,13 @@ void kmem_cache_destroy(struct kmem_cach
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
 
@@ -2700,26 +2701,31 @@ struct kmem_cache *kmem_cache_create(con
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
 				size, align, flags, ctor)) {
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
+			return s;
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
