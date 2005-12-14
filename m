Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBE7w8iH024591
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 02:58:08 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBE7vINh131288
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 00:57:18 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jBE7w8ZZ013506
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 00:58:08 -0700
Message-ID: <439FD08E.3020401@us.ibm.com>
Date: Tue, 13 Dec 2005 23:58:06 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 4/6] Slab Prep: slab_destruct()
References: <439FCECA.3060909@us.ibm.com>
In-Reply-To: <439FCECA.3060909@us.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------030308000601030406020504"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, pavel@suse.cz, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030308000601030406020504
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Create a helper function for slab_destroy() called slab_destruct().  Remove
some ifdefs inside functions and generally make the slab destroying code
more readable prior to slab support for the Critical Page Pool.

-Matt

--------------030308000601030406020504
Content-Type: text/x-patch;
 name="slab_prep-slab_destruct.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="slab_prep-slab_destruct.patch"

Create a helper function, slab_destruct(), called from slab_destroy().  This
makes slab_destroy() smaller and more readable, and moves ifdefs outside the
function body.

Signed-off-by: Matthew Dobson <colpatch@us.ibm.com>

Index: linux-2.6.15-rc5+critical_pool/mm/slab.c
===================================================================
--- linux-2.6.15-rc5+critical_pool.orig/mm/slab.c	2005-12-05 10:20:43.886907432 -0800
+++ linux-2.6.15-rc5+critical_pool/mm/slab.c	2005-12-05 10:20:45.289694176 -0800
@@ -1401,15 +1401,13 @@ static void check_poison_obj(kmem_cache_
 }
 #endif
 
-/* Destroy all the objs in a slab, and release the mem back to the system.
- * Before calling the slab must have been unlinked from the cache.
- * The cache-lock is not held/needed.
+#if DEBUG
+/**
+ * slab_destruct - call the registered destructor for each object in
+ *      a slab that is to be destroyed.
  */
-static void slab_destroy (kmem_cache_t *cachep, struct slab *slabp)
+static void slab_destruct(kmem_cache_t *cachep, struct slab *slabp)
 {
-	void *addr = slabp->s_mem - slabp->colouroff;
-
-#if DEBUG
 	int i;
 	for (i = 0; i < cachep->num; i++) {
 		void *objp = slabp->s_mem + cachep->objsize * i;
@@ -1435,7 +1433,10 @@ static void slab_destroy (kmem_cache_t *
 		if (cachep->dtor && !(cachep->flags & SLAB_POISON))
 			(cachep->dtor)(objp+obj_dbghead(cachep), cachep, 0);
 	}
+}
 #else
+static void slab_destruct(kmem_cache_t *cachep, struct slab *slabp)
+{
 	if (cachep->dtor) {
 		int i;
 		for (i = 0; i < cachep->num; i++) {
@@ -1443,8 +1444,19 @@ static void slab_destroy (kmem_cache_t *
 			(cachep->dtor)(objp, cachep, 0);
 		}
 	}
+}
 #endif
 
+/**
+ * Destroy all the objs in a slab, and release the mem back to the system.
+ * Before calling the slab must have been unlinked from the cache.
+ * The cache-lock is not held/needed.
+ */
+static void slab_destroy(kmem_cache_t *cachep, struct slab *slabp)
+{
+	void *addr = slabp->s_mem - slabp->colouroff;
+
+	slab_destruct(cachep, slabp);
 	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {
 		struct slab_rcu *slab_rcu;
 

--------------030308000601030406020504--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
