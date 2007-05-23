Date: Wed, 23 May 2007 11:04:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070523074636.GA10070@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705231102530.20395@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705222154280.28140@schroedinger.engr.sgi.com>
 <20070523045938.GA29045@wotan.suse.de> <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com>
 <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com>
 <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com>
 <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
 <20070523061702.GA9449@wotan.suse.de> <20070523074636.GA10070@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Could you try this patch and tell me how much memory it saves?

SLUB embedded: Reduce memory use

If we do not have CONFIG_SLUB_DEBUG set then assume that we need
to conserve memory. So

1. Reduce size of kmem_cache_node

2. Do not keep empty partial slabs around

3. Remove all empty cpu slabs when bootstrap of the kernel
   is complete. New cpu slabs will only be added for
   the slabs actually used by user space.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slub_def.h |    2 ++
 mm/slub.c                |   14 ++++++++++++--
 2 files changed, 14 insertions(+), 2 deletions(-)

Index: slub/include/linux/slub_def.h
===================================================================
--- slub.orig/include/linux/slub_def.h	2007-05-22 22:46:06.000000000 -0700
+++ slub/include/linux/slub_def.h	2007-05-22 23:31:18.000000000 -0700
@@ -17,7 +17,9 @@ struct kmem_cache_node {
 	unsigned long nr_partial;
 	atomic_long_t nr_slabs;
 	struct list_head partial;
+#ifdef CONFIG_SLUB_DEBUG
 	struct list_head full;
+#endif
 };
 
 /*
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-22 22:46:06.000000000 -0700
+++ slub/mm/slub.c	2007-05-23 10:32:36.000000000 -0700
@@ -183,7 +183,11 @@ static inline void ClearSlabDebug(struct
  * Mininum number of partial slabs. These will be left on the partial
  * lists even if they are empty. kmem_cache_shrink may reclaim them.
  */
+#ifdef CONFIG_SLUB_DEBUG
+#define MIN_PARTIAL 2
+#else
 #define MIN_PARTIAL 0
+#endif
 
 /*
  * Maximum number of desirable partial slabs.
@@ -1792,7 +1796,9 @@ static void init_kmem_cache_node(struct 
 	atomic_long_set(&n->nr_slabs, 0);
 	spin_lock_init(&n->list_lock);
 	INIT_LIST_HEAD(&n->partial);
+#ifdef CONFIG_SLUB_DEBUG
 	INIT_LIST_HEAD(&n->full);
+#endif
 }
 
 #ifdef CONFIG_NUMA
@@ -3659,17 +3665,20 @@ static int sysfs_slab_alias(struct kmem_
 	return 0;
 }
 
+#endif
 static int __init slab_sysfs_init(void)
 {
 	struct list_head *h;
 	int err;
 
+#ifdef CONFIG_SLUB_DEBUG
 	err = subsystem_register(&slab_subsys);
 	if (err) {
 		printk(KERN_ERR "Cannot register slab subsystem.\n");
 		return -ENOSYS;
 	}
 
+#endif
 	slab_state = SYSFS;
 
 	list_for_each(h, &slab_caches) {
@@ -3678,8 +3687,10 @@ static int __init slab_sysfs_init(void)
 
 		err = sysfs_slab_add(s);
 		BUG_ON(err);
+		kmem_cache_shrink(s);
 	}
 
+#ifdef CONFIG_SLUB_DEBUG
 	while (alias_list) {
 		struct saved_alias *al = alias_list;
 
@@ -3690,8 +3701,7 @@ static int __init slab_sysfs_init(void)
 	}
 
 	resiliency_test();
+#endif
 	return 0;
 }
-
 __initcall(slab_sysfs_init);
-#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
