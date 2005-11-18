Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAIJiYJe018909
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 14:44:34 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAIJjqLY071262
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 12:45:53 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAIJiY3W029493
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 12:44:34 -0700
Message-ID: <437E2F20.9090302@us.ibm.com>
Date: Fri, 18 Nov 2005 11:44:32 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 6/8] slab_destruct
References: <437E2C69.4000708@us.ibm.com>
In-Reply-To: <437E2C69.4000708@us.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------090902050305040107070309"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090902050305040107070309
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Break the current slab_destroy() into 2 functions: slab_destroy and
slab_destruct.  slab_destruct calls the destructor code and any necessary
debug code.

-Matt

--------------090902050305040107070309
Content-Type: text/x-patch;
 name="slab_prep-slab_destruct.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="slab_prep-slab_destruct.patch"

Create a helper function, slab_destruct(), called from slab_destroy().  This
makes slab_destroy() smaller and more readable, and moves ifdefs outside the
function body.

Signed-off-by: Matthew Dobson <colpatch@us.ibm.com>

Index: linux-2.6.14+critical_pool/mm/slab.c
===================================================================
--- linux-2.6.14+critical_pool.orig/mm/slab.c	2005-11-14 10:52:22.427207392 -0800
+++ linux-2.6.14+critical_pool/mm/slab.c	2005-11-14 10:52:27.514434016 -0800
@@ -1388,16 +1388,13 @@ static void check_poison_obj(kmem_cache_
 }
 #endif
 
-/*
- * Destroy all the objs in a slab, and release the mem back to the system.
- * Before calling the slab must have been unlinked from the cache.
- * The cache-lock is not held/needed.
+#if DEBUG
+/**
+ * slab_destruct - call the registered destructor for each object in
+ *      a slab that is to be destroyed.
  */
-static void slab_destroy(kmem_cache_t *cachep, struct slab *slabp)
+static void slab_destruct(kmem_cache_t *cachep, struct slab *slabp)
 {
-	void *addr = slabp->s_mem - slabp->colouroff;
-
-#if DEBUG
 	int i;
 	for (i = 0; i < cachep->num; i++) {
 		void *objp = slabp->s_mem + cachep->objsize * i;
@@ -1425,7 +1422,10 @@ static void slab_destroy(kmem_cache_t *c
 		if (cachep->dtor && !(cachep->flags & SLAB_POISON))
 			(cachep->dtor)(objp + obj_dbghead(cachep), cachep, 0);
 	}
+}
 #else
+static void slab_destruct(kmem_cache_t *cachep, struct slab *slabp)
+{
 	if (cachep->dtor) {
 		int i;
 		for (i = 0; i < cachep->num; i++) {
@@ -1433,8 +1433,19 @@ static void slab_destroy(kmem_cache_t *c
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
 

--------------090902050305040107070309--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
