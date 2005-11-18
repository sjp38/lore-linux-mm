Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAIJhJAH017089
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 14:43:19 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAIJh3T9051442
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 12:43:03 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAIJhIYm026024
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 12:43:19 -0700
Message-ID: <437E2ED4.9010202@us.ibm.com>
Date: Fri, 18 Nov 2005 11:43:16 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 5/8] get_object/return_object
References: <437E2C69.4000708@us.ibm.com>
In-Reply-To: <437E2C69.4000708@us.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------020401040109010106090806"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020401040109010106090806
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Move the code to get/return an object back to its slab into their own
functions.

-Matt

--------------020401040109010106090806
Content-Type: text/x-patch;
 name="slab_prep-get_return_object.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="slab_prep-get_return_object.patch"

Create two helper functions: get_object_from_slab() & return_object_to_slab().
Use these two helper function to replace duplicated code in mm/slab.c

These functions will also be reused by a later patch in this series.

Signed-off-by: Matthew Dobson <colpatch@us.ibm.com>

Index: linux-2.6.15-rc1+critical_pool/mm/slab.c
===================================================================
--- linux-2.6.15-rc1+critical_pool.orig/mm/slab.c	2005-11-17 16:39:24.401412160 -0800
+++ linux-2.6.15-rc1+critical_pool/mm/slab.c	2005-11-17 16:45:07.337277984 -0800
@@ -2148,6 +2148,42 @@ static void kmem_flagcheck(kmem_cache_t 
 	}
 }
 
+static void *get_object(kmem_cache_t *cachep, struct slab *slabp, int nid)
+{
+	void *obj = slabp->s_mem + (slabp->free * cachep->objsize);
+	kmem_bufctl_t next;
+
+	slabp->inuse++;
+	next = slab_bufctl(slabp)[slabp->free];
+#if DEBUG
+	slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
+	WARN_ON(slabp->nid != nid);
+#endif
+	slabp->free = next;
+
+	return obj;
+}
+
+static void return_object(kmem_cache_t *cachep, struct slab *slabp, void *objp,
+			  int nid)
+{
+	unsigned int objnr = (objp - slabp->s_mem) / cachep->objsize;
+
+#if DEBUG
+	/* Verify that the slab belongs to the intended node */
+	WARN_ON(slabp->nid != nid);
+
+	if (slab_bufctl(slabp)[objnr] != BUFCTL_FREE) {
+		printk(KERN_ERR "slab: double free detected in cache "
+		       "'%s', objp %p\n", cachep->name, objp);
+		BUG();
+	}
+#endif
+	slab_bufctl(slabp)[objnr] = slabp->free;
+	slabp->free = objnr;
+	slabp->inuse--;
+}
+
 static void set_slab_attr(kmem_cache_t *cachep, struct slab *slabp, void *objp)
 {
 	int i;
@@ -2436,22 +2472,12 @@ retry:
 		check_slabp(cachep, slabp);
 		check_spinlock_acquired(cachep);
 		while (slabp->inuse < cachep->num && batchcount--) {
-			kmem_bufctl_t next;
 			STATS_INC_ALLOCED(cachep);
 			STATS_INC_ACTIVE(cachep);
 			STATS_SET_HIGH(cachep);
 
-			/* get obj pointer */
-			ac->entry[ac->avail++] = slabp->s_mem +
-				slabp->free*cachep->objsize;
-
-			slabp->inuse++;
-			next = slab_bufctl(slabp)[slabp->free];
-#if DEBUG
-			slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
-			WARN_ON(numa_node_id() != slabp->nid);
-#endif
-			slabp->free = next;
+			ac->entry[ac->avail++] = get_object(cachep, slabp,
+							    numa_node_id());
 		}
 		check_slabp(cachep, slabp);
 
@@ -2586,7 +2612,6 @@ static void *__cache_alloc_node(kmem_cac
 	struct slab *slabp;
 	struct kmem_list3 *l3;
 	void *obj;
-	kmem_bufctl_t next;
 	int x;
 
 	l3 = cachep->nodelists[nid];
@@ -2612,14 +2637,7 @@ retry:
 
 	BUG_ON(slabp->inuse == cachep->num);
 
-	/* get obj pointer */
-	obj =  slabp->s_mem + slabp->free * cachep->objsize;
-	slabp->inuse++;
-	next = slab_bufctl(slabp)[slabp->free];
-#if DEBUG
-	slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
-#endif
-	slabp->free = next;
+	obj = get_object(cachep, slabp, nid);
 	check_slabp(cachep, slabp);
 	l3->free_objects--;
 	/* move slabp to correct slabp list: */
@@ -2659,29 +2677,14 @@ static void free_block(kmem_cache_t *cac
 	for (i = 0; i < nr_objects; i++) {
 		void *objp = objpp[i];
 		struct slab *slabp;
-		unsigned int objnr;
 
 		slabp = GET_PAGE_SLAB(virt_to_page(objp));
 		l3 = cachep->nodelists[nid];
 		list_del(&slabp->list);
-		objnr = (objp - slabp->s_mem) / cachep->objsize;
 		check_spinlock_acquired_node(cachep, nid);
 		check_slabp(cachep, slabp);
-
-#if DEBUG
-		/* Verify that the slab belongs to the intended node */
-		WARN_ON(slabp->nid != nid);
-
-		if (slab_bufctl(slabp)[objnr] != BUFCTL_FREE) {
-			printk(KERN_ERR "slab: double free detected in cache "
-					"'%s', objp %p\n", cachep->name, objp);
-			BUG();
-		}
-#endif
-		slab_bufctl(slabp)[objnr] = slabp->free;
-		slabp->free = objnr;
+		return_object(cachep, slabp, objp, nid);
 		STATS_DEC_ACTIVE(cachep);
-		slabp->inuse--;
 		l3->free_objects++;
 		check_slabp(cachep, slabp);
 

--------------020401040109010106090806--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
