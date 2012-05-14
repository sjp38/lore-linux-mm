Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B9BBC6B00E9
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:16:14 -0400 (EDT)
Message-Id: <20120514201612.828855077@linux.com>
Date: Mon, 14 May 2012 15:15:51 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC] SL[AUO]B common code 7/9] slabs: Move kmem_cache_create mutex handling to common code
References: <20120514201544.334122849@linux.com>
Content-Disposition: inline; filename=move_mutex_to_common
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

Move the mutex handling into the common kmem_cache_create()
function.

Then we can also move more checks out of SLAB's kmem_cache_create()
into the common code.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c        |   52 +---------------------------------------------------
 mm/slab_common.c |   41 ++++++++++++++++++++++++++++++++++++++++-
 mm/slub.c        |   30 ++++++++++++++----------------
 3 files changed, 55 insertions(+), 68 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-05-14 08:51:51.819130415 -0500
+++ linux-2.6/mm/slab.c	2012-05-14 08:52:41.707129382 -0500
@@ -2252,55 +2252,10 @@ __kmem_cache_create (const char *name, s
 	unsigned long flags, void (*ctor)(void *))
 {
 	size_t left_over, slab_size, ralign;
-	struct kmem_cache *cachep = NULL, *pc;
+	struct kmem_cache *cachep = NULL;
 	gfp_t gfp;
 
-	/*
-	 * Sanity checks... these are all serious usage bugs.
-	 */
-	if (!name || in_interrupt() || (size < BYTES_PER_WORD) ||
-	    size > KMALLOC_MAX_SIZE) {
-		printk(KERN_ERR "%s: Early error in slab %s\n", __func__,
-				name);
-		BUG();
-	}
-
-	/*
-	 * We use cache_chain_mutex to ensure a consistent view of
-	 * cpu_online_mask as well.  Please see cpuup_callback
-	 */
-	if (slab_is_available()) {
-		get_online_cpus();
-		mutex_lock(&cache_chain_mutex);
-	}
-
-	list_for_each_entry(pc, &cache_chain, list) {
-		char tmp;
-		int res;
-
-		/*
-		 * This happens when the module gets unloaded and doesn't
-		 * destroy its slab cache and no-one else reuses the vmalloc
-		 * area of the module.  Print a warning.
-		 */
-		res = probe_kernel_address(pc->name, tmp);
-		if (res) {
-			printk(KERN_ERR
-			       "SLAB: cache with size %d has lost its name\n",
-			       pc->buffer_size);
-			continue;
-		}
-
-		if (!strcmp(pc->name, name)) {
-			printk(KERN_ERR
-			       "kmem_cache_create: duplicate cache %s\n", name);
-			dump_stack();
-			goto oops;
-		}
-	}
-
 #if DEBUG
-	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
 #if FORCED_DEBUG
 	/*
 	 * Enable redzoning and last user accounting, except for caches with
@@ -2518,11 +2473,6 @@ __kmem_cache_create (const char *name, s
 
 	/* cache setup completed, link it into the list */
 	list_add(&cachep->list, &slab_caches);
-oops:
-	if (slab_is_available()) {
-		mutex_unlock(&slab_mutex);
-		put_online_cpus();
-	}
 	return cachep;
 }
 
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-05-14 08:51:51.839130415 -0500
+++ linux-2.6/mm/slab_common.c	2012-05-14 08:52:11.407130009 -0500
@@ -11,7 +11,8 @@
 #include <linux/memory.h>
 #include <linux/compiler.h>
 #include <linux/module.h>
-
+#include <linux/cpu.h>
+#include <linux/uaccess.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 #include <asm/page.h>
@@ -61,8 +62,46 @@ struct kmem_cache *kmem_cache_create(con
 	}
 #endif
 
+	get_online_cpus();
+	mutex_lock(&slab_mutex);
+
+#ifdef CONFIG_DEBUG_VM
+	list_for_each_entry(s, &slab_caches, list) {
+		char tmp;
+		int res;
+
+		/*
+		 * This happens when the module gets unloaded and doesn't
+		 * destroy its slab cache and no-one else reuses the vmalloc
+		 * area of the module.  Print a warning.
+		 */
+		res = probe_kernel_address(s->name, tmp);
+		if (res) {
+			printk(KERN_ERR
+			       "Slab cache with size %d has lost its name\n",
+			       s->size);
+			continue;
+		}
+
+		if (!strcmp(s->name, name)) {
+			printk(KERN_ERR "kmem_cache_create(%s): Cache name"
+				" already exists.\n",
+				name);
+			dump_stack();
+			s = NULL;
+			goto oops;
+		}
+	}
+
+	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
+#endif
+
 	s = __kmem_cache_create(name, size, align, flags, ctor);
 
+oops:
+	mutex_unlock(&slab_mutex);
+	put_online_cpus();
+
 out:
 	if (!s && (flags & SLAB_PANIC))
 		panic("kmem_cache_create: Failed to create slab '%s'\n", name);
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-05-14 08:51:51.827130415 -0500
+++ linux-2.6/mm/slub.c	2012-05-14 08:52:11.411130009 -0500
@@ -3912,7 +3912,6 @@ struct kmem_cache *__kmem_cache_create(c
 	struct kmem_cache *s;
 	char *n;
 
-	mutex_lock(&slab_mutex);
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
 		s->refcount++;
@@ -3925,37 +3924,36 @@ struct kmem_cache *__kmem_cache_create(c
 
 		if (sysfs_slab_alias(s, name)) {
 			s->refcount--;
-			goto err;
+			return NULL;
 		}
-		mutex_unlock(&slab_mutex);
 		return s;
 	}
 
 	n = kstrdup(name, GFP_KERNEL);
 	if (!n)
-		goto err;
+		return NULL;
 
 	s = kmalloc(kmem_size, GFP_KERNEL);
 	if (s) {
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
+			int r;
+
 			list_add(&s->list, &slab_caches);
 			mutex_unlock(&slab_mutex);
-			if (sysfs_slab_add(s)) {
-				mutex_lock(&slab_mutex);
-				list_del(&s->list);
-				kfree(n);
-				kfree(s);
-				goto err;
-			}
-			return s;
+			r = sysfs_slab_add(s);
+			mutex_lock(&slab_mutex);
+
+			if (!r)
+				return s;
+
+			list_del(&s->list);
+			kmem_cache_close(s);
 		}
-		kfree(n);
 		kfree(s);
 	}
-err:
-	mutex_unlock(&slab_mutex);
-	return s;
+	kfree(n);
+	return NULL;
 }
 
 #ifdef CONFIG_SMP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
