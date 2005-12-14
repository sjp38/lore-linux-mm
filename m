Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBE7uZwe004437
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 02:56:35 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBE7wFkD108382
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 00:58:15 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jBE7uZL4011383
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 00:56:35 -0700
Message-ID: <439FD031.1040608@us.ibm.com>
Date: Tue, 13 Dec 2005 23:56:33 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 3/6] Slab Prep: get/return_object
References: <439FCECA.3060909@us.ibm.com>
In-Reply-To: <439FCECA.3060909@us.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------020304050109020200000006"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, pavel@suse.cz, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020304050109020200000006
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Create 2 helper functions in mm/slab.c: get_object() and return_object().
These functions reduce some existing duplicated code in the slab allocator
and will be used when adding Critical Page Pool support to the slab allocator.

-Matt

--------------020304050109020200000006
Content-Type: text/x-patch;
 name="slab_prep-get_return_object.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="slab_prep-get_return_object.patch"

Create two helper functions: get_object_from_slab() & return_object_to_slab().
Use these two helper function to replace duplicated code in mm/slab.c

These functions will also be reused by a later patch in this series.

Signed-off-by: Matthew Dobson <colpatch@us.ibm.com>

Index: linux-2.6.15-rc5+critical_pool/mm/slab.c
===================================================================
--- linux-2.6.15-rc5+critical_pool.orig/mm/slab.c	2005-12-13 15:56:55.459287208 -0800
+++ linux-2.6.15-rc5+critical_pool/mm/slab.c	2005-12-13 16:05:21.308386456 -0800
@@ -2140,6 +2140,42 @@ static void kmem_flagcheck(kmem_cache_t 
 	}
 }
 
+static void *get_object(kmem_cache_t *cachep, struct slab *slabp, int nodeid)
+{
+	void *objp = slabp->s_mem + (slabp->free * cachep->objsize);
+	kmem_bufctl_t next;
+
+	slabp->inuse++;
+	next = slab_bufctl(slabp)[slabp->free];
+#if DEBUG
+	slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
+	WARN_ON(slabp->nodeid != nodeid);
+#endif
+	slabp->free = next;
+
+	return objp;
+}
+
+static void return_object(kmem_cache_t *cachep, struct slab *slabp, void *objp,
+			  int nodeid)
+{
+	unsigned int objnr = (objp - slabp->s_mem) / cachep->objsize;
+
+#if DEBUG
+	/* Verify that the slab belongs to the intended node */
+	WARN_ON(slabp->nodeid != nodeid);
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
@@ -2418,22 +2454,12 @@ retry:
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
-			WARN_ON(numa_node_id() != slabp->nodeid);
-#endif
-		       	slabp->free = next;
+			ac->entry[ac->avail++] = get_object(cachep, slabp,
+							    numa_node_id());
 		}
 		check_slabp(cachep, slabp);
 
@@ -2565,7 +2591,6 @@ static void *__cache_alloc_node(kmem_cac
  	struct slab *slabp;
  	struct kmem_list3 *l3;
  	void *obj;
- 	kmem_bufctl_t next;
  	int x;
 
  	l3 = cachep->nodelists[nodeid];
@@ -2591,14 +2616,7 @@ retry:
 
  	BUG_ON(slabp->inuse == cachep->num);
 
- 	/* get obj pointer */
- 	obj =  slabp->s_mem + slabp->free*cachep->objsize;
- 	slabp->inuse++;
- 	next = slab_bufctl(slabp)[slabp->free];
-#if DEBUG
- 	slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
-#endif
- 	slabp->free = next;
+	obj = get_object(cachep, slabp, nodeid);
  	check_slabp(cachep, slabp);
  	l3->free_objects--;
  	/* move slabp to correct slabp list: */
@@ -2637,29 +2655,14 @@ static void free_block(kmem_cache_t *cac
 	for (i = 0; i < nr_objects; i++) {
 		void *objp = objpp[i];
 		struct slab *slabp;
-		unsigned int objnr;
 
 		slabp = page_get_slab(virt_to_page(objp));
 		l3 = cachep->nodelists[node];
 		list_del(&slabp->list);
-		objnr = (objp - slabp->s_mem) / cachep->objsize;
 		check_spinlock_acquired_node(cachep, node);
 		check_slabp(cachep, slabp);
-
-#if DEBUG
-		/* Verify that the slab belongs to the intended node */
-		WARN_ON(slabp->nodeid != node);
-
-		if (slab_bufctl(slabp)[objnr] != BUFCTL_FREE) {
-			printk(KERN_ERR "slab: double free detected in cache "
-					"'%s', objp %p\n", cachep->name, objp);
-			BUG();
-		}
-#endif
-		slab_bufctl(slabp)[objnr] = slabp->free;
-		slabp->free = objnr;
+		return_object(cachep, slabp, objp, node);
 		STATS_DEC_ACTIVE(cachep);
-		slabp->inuse--;
 		l3->free_objects++;
 		check_slabp(cachep, slabp);
 

--------------020304050109020200000006--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
