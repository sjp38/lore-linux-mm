Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA06295
	for <linux-mm@kvack.org>; Thu, 25 Feb 1999 14:30:46 -0500
Date: Thu, 25 Feb 1999 20:29:19 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] kmem_cache_destroy (modules will be happy)
In-Reply-To: <Pine.SCO.3.94.990211112921.10113R-100000@tyne.london.sco.com>
Message-ID: <Pine.LNX.4.05.9902252018230.606-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alexander Viro <viro@math.psu.edu>
Cc: Mark Hemment <markhe@sco.COM>, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I implemented kmem_cache_destroy() in the slab. This will allow a module
to create its slab cache at insmod time and to destroy it _completly_ at
rmmod time.

I also did a little cleanup of the code related to the new slab API.

Here the patch against 2.2.2:

Index: include/linux/slab.h
===================================================================
RCS file: /var/cvs/linux/include/linux/slab.h,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 slab.h
--- slab.h	1999/01/18 01:33:10	1.1.2.1
+++ linux/include/linux/slab.h	1999/02/25 17:04:25
@@ -51,6 +51,7 @@
 extern kmem_cache_t *kmem_cache_create(const char *, size_t, size_t, unsigned long,
 				       void (*)(void *, kmem_cache_t *, unsigned long),
 				       void (*)(void *, kmem_cache_t *, unsigned long));
+extern int kmem_cache_destroy(kmem_cache_t *);
 extern int kmem_cache_shrink(kmem_cache_t *);
 extern void *kmem_cache_alloc(kmem_cache_t *, int);
 extern void kmem_cache_free(kmem_cache_t *, void *);
Index: kernel/ksyms.c
===================================================================
RCS file: /var/cvs/linux/kernel/ksyms.c,v
retrieving revision 1.1.2.11
diff -u -r1.1.2.11 ksyms.c
--- ksyms.c	1999/02/20 15:57:41	1.1.2.11
+++ linux/kernel/ksyms.c	1999/02/25 16:02:39
@@ -92,6 +92,7 @@
 EXPORT_SYMBOL(__free_page);
 EXPORT_SYMBOL(kmem_find_general_cachep);
 EXPORT_SYMBOL(kmem_cache_create);
+EXPORT_SYMBOL(kmem_cache_destroy);
 EXPORT_SYMBOL(kmem_cache_shrink);
 EXPORT_SYMBOL(kmem_cache_alloc);
 EXPORT_SYMBOL(kmem_cache_free);
Index: mm//slab.c
===================================================================
RCS file: /var/cvs/linux/mm/slab.c,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 slab.c
--- slab.c	1999/01/18 01:32:53	1.1.2.1
+++ linux/mm/slab.c	1999/02/25 18:23:31
@@ -3,6 +3,8 @@
  * Written by Mark Hemment, 1996/97.
  * (markhe@nextd.demon.co.uk)
  *
+ * kmem_cache_destroy() + some cleanup - 1999 Andrea Arcangeli
+ *
  * 11 April '97.  Started multi-threading - markhe
  *	The global cache-chain is protected by the semaphore 'cache_chain_sem'.
  *	The sem is only needed when accessing/extending the cache-chain, which
@@ -979,6 +981,59 @@
 	return cachep;
 }
 
+/*
+ * This check if the kmem_cache_t pointer is chained in the cache_cache
+ * list. -arca
+ */
+static int is_chained_kmem_cache(kmem_cache_t * cachep)
+{
+	kmem_cache_t * searchp;
+	int ret = 0;
+
+	/* Find the cache in the chain of caches. */
+	down(&cache_chain_sem);
+	for (searchp = &cache_cache; searchp->c_nextp != &cache_cache;
+	     searchp = searchp->c_nextp)
+	{
+		if (searchp->c_nextp != cachep)
+			continue;
+
+		/* Accessing clock_searchp is safe - we hold the mutex. */
+		if (cachep == clock_searchp)
+			clock_searchp = cachep->c_nextp;
+		ret = 1;
+		break;
+	}
+	up(&cache_chain_sem);
+
+	return ret;
+}
+
+/* returns 0 if every slab is been freed -arca */
+static int __kmem_cache_shrink(kmem_cache_t *cachep)
+{
+	kmem_slab_t	*slabp;
+	int	ret;
+
+	spin_lock_irq(&cachep->c_spinlock);
+
+	/* If the cache is growing, stop shrinking. */
+	while (!cachep->c_growing) {
+		slabp = cachep->c_lastp;
+		if (slabp->s_inuse || slabp == kmem_slab_end(cachep))
+			break;
+		kmem_slab_unlink(slabp);
+		spin_unlock_irq(&cachep->c_spinlock);
+		kmem_slab_destroy(cachep, slabp);
+		spin_lock_irq(&cachep->c_spinlock);
+	}
+	ret = 1;
+	if (cachep->c_lastp == kmem_slab_end(cachep))
+		ret = 0;		/* Cache is empty. */
+	spin_unlock_irq(&cachep->c_spinlock);
+	return ret;
+}
+
 /* Shrink a cache.  Releases as many slabs as possible for a cache.
  * It is expected this function will be called by a module when it is
  * unloaded.  The cache is _not_ removed, this creates too many problems and
@@ -990,10 +1045,6 @@
 int
 kmem_cache_shrink(kmem_cache_t *cachep)
 {
-	kmem_cache_t	*searchp;
-	kmem_slab_t	*slabp;
-	int	ret;
-
 	if (!cachep) {
 		printk(KERN_ERR "kmem_shrink: NULL ptr\n");
 		return 2;
@@ -1003,43 +1054,77 @@
 		return 2;
 	}
 
+	if (!is_chained_kmem_cache(cachep))
+	{
+		printk(KERN_ERR "kmem_shrink: Invalid cache addr %p\n",
+		       cachep);
+		return 2;
+	}
+
+	return __kmem_cache_shrink(cachep);
+}
+
+/*
+ * Remove a kmem_cache_t object from the slab cache. When returns 0 it
+ * completed succesfully. -arca
+ */
+int kmem_cache_destroy(kmem_cache_t * cachep)
+{
+	kmem_cache_t * prev;
+	int ret;
+
+	if (!cachep) {
+		printk(KERN_ERR "kmem_destroy: NULL ptr\n");
+		return 1;
+	}
+	if (in_interrupt()) {
+		printk(KERN_ERR "kmem_destroy: Called during int - %s\n",
+		       cachep->c_name);
+		return 1;
+	}
+
+	ret = 0;
 	/* Find the cache in the chain of caches. */
-	down(&cache_chain_sem);		/* Semaphore is needed. */
-	searchp = &cache_cache;
-	for (;searchp->c_nextp != &cache_cache; searchp = searchp->c_nextp) {
-		if (searchp->c_nextp != cachep)
+	down(&cache_chain_sem);
+	for (prev = &cache_cache; prev->c_nextp != &cache_cache;
+	     prev = prev->c_nextp)
+	{
+		if (prev->c_nextp != cachep)
 			continue;
 
 		/* Accessing clock_searchp is safe - we hold the mutex. */
 		if (cachep == clock_searchp)
 			clock_searchp = cachep->c_nextp;
-		goto found;
+
+		/* remove the cachep from the cache_cache list. -arca */
+		prev->c_nextp = cachep->c_nextp;
+
+		ret = 1;
+		break;
 	}
 	up(&cache_chain_sem);
-	printk(KERN_ERR "kmem_shrink: Invalid cache addr %p\n", cachep);
-	return 2;
-found:
-	/* Release the semaphore before getting the cache-lock.  This could
-	 * mean multiple engines are shrinking the cache, but so what.
-	 */
-	up(&cache_chain_sem);
-	spin_lock_irq(&cachep->c_spinlock);
 
-	/* If the cache is growing, stop shrinking. */
-	while (!cachep->c_growing) {
-		slabp = cachep->c_lastp;
-		if (slabp->s_inuse || slabp == kmem_slab_end(cachep))
-			break;
-		kmem_slab_unlink(slabp);
-		spin_unlock_irq(&cachep->c_spinlock);
-		kmem_slab_destroy(cachep, slabp);
-		spin_lock_irq(&cachep->c_spinlock);
+	if (!ret)
+	{
+		printk(KERN_ERR "kmem_destroy: Invalid cache addr %p\n",
+		       cachep);
+		return 1;
 	}
-	ret = 1;
-	if (cachep->c_lastp == kmem_slab_end(cachep))
-		ret--;		/* Cache is empty. */
-	spin_unlock_irq(&cachep->c_spinlock);
-	return ret;
+
+	if (__kmem_cache_shrink(cachep))
+	{
+		printk(KERN_ERR "kmem_destroy: Can't free all objects %p\n",
+		       cachep);
+		down(&cache_chain_sem);
+		cachep->c_nextp = cache_cache.c_nextp;
+		cache_cache.c_nextp = cachep;
+		up(&cache_chain_sem);
+		return 1;
+	}
+
+	kmem_cache_free(&cache_cache, cachep);
+
+	return 0;
 }
 
 /* Get the memory for a slab management obj. */



And here a kernel module I developed to test the new API. This new kernel
module simply alloc an array of slab cache headers, and for each of them
alloc tons of slab object. Then initialize the slab object to a known
value and check that the value it's unchanged before deallocing the
object.

I tried for example to alloc 60Mbyte of RAM distributed between 20 slab
headers and everything get released fine when the module got released from
the kernel.

Here the slab-test module I written today:

begin 644 slab-test-0.tar.gz
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
7''+((8<<<L@AAQS^`/@/^U)`6P`H````
`
end

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
