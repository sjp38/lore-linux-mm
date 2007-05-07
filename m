Message-Id: <20070507212409.184643518@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:48 -0700
From: clameter@sgi.com
Subject: [patch 08/17] SLUB: Get rid of finish_bootstrap
Content-Disposition: inline; filename=die_finish_bootstrap
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Its only purpose was to bring some sort of symmetry to sysfs usage
when dealing with bootstrapping per cpu flushing. Since we do not
time out slabs anymore we have no need to run finish_bootstrap even
without sysfs. Fold it back into slab_sysfs_init and drop the
initcall for the !SYFS case.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   30 ++++++++++--------------------
 1 file changed, 10 insertions(+), 20 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 13:52:51.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 13:52:54.000000000 -0700
@@ -1711,23 +1711,6 @@ static int calculate_sizes(struct kmem_c
 
 }
 
-static int __init finish_bootstrap(void)
-{
-	struct list_head *h;
-	int err;
-
-	slab_state = SYSFS;
-
-	list_for_each(h, &slab_caches) {
-		struct kmem_cache *s =
-			container_of(h, struct kmem_cache, list);
-
-		err = sysfs_slab_add(s);
-		BUG_ON(err);
-	}
-	return 0;
-}
-
 static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
 		const char *name, size_t size,
 		size_t align, unsigned long flags,
@@ -3415,6 +3398,7 @@ static int sysfs_slab_alias(struct kmem_
 
 static int __init slab_sysfs_init(void)
 {
+	struct list_head *h;
 	int err;
 
 	err = subsystem_register(&slab_subsys);
@@ -3423,7 +3407,15 @@ static int __init slab_sysfs_init(void)
 		return -ENOSYS;
 	}
 
-	finish_bootstrap();
+	slab_state = SYSFS;
+
+	list_for_each(h, &slab_caches) {
+		struct kmem_cache *s =
+			container_of(h, struct kmem_cache, list);
+
+		err = sysfs_slab_add(s);
+		BUG_ON(err);
+	}
 
 	while (alias_list) {
 		struct saved_alias *al = alias_list;
@@ -3439,6 +3431,4 @@ static int __init slab_sysfs_init(void)
 }
 
 __initcall(slab_sysfs_init);
-#else
-__initcall(finish_bootstrap);
 #endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
