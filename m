Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 230366B01E3
	for <linux-mm@kvack.org>; Fri, 14 May 2010 13:50:28 -0400 (EDT)
Date: Fri, 14 May 2010 12:46:52 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Defrag in shrinkers (was Re: [PATCH 0/5] Per-superblock shrinkers)
In-Reply-To: <1273821863-29524-1-git-send-email-david@fromorbit.com>
Message-ID: <alpine.DEB.2.00.1005141244380.9466@router.home>
References: <1273821863-29524-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Would it also be possible to add some defragmentation logic when you
revise the shrinkers? Here is a prototype patch that would allow you to
determine the other objects sitting in the same page as a given object.

With that I hope that you have enough information to determine if its
worth to evict the other objects as well to reclaim the slab page.


From: Christoph Lameter <cl@linux-foundation.org>
Subject: Slab allocators: Introduce function to determine other objects in the same slab page

kmem_cache_objects() can be used to determin other objects sharing the same
slab. With such knowledge a slab user can intentionally free all slab objects
in a slab to allow the freeing of the slab as a whole. This is particularly
important for the dentry and inode cache handling since they reclaim objects
in LRU fashion. With this function they can see if the object is sitting in
a sparsely populated slab page and if so decide to reclaim the other objects
in the slab page. In many situations we can otherwise get high memory use
since only a very small portion of the available object slots are in use
(this can occur after a file scan or when the computational load on a server
changes).

kmem_cache_object() returns the number of objects currently in use. A parameter
allows the retrieval of the maximum number of objects that would fit into this
slab page.

The user must then use these numbers to determine if an effort should be made
to free the remaining objects. The allocated objects are returned in an array
of pointers.

Objects can only stay allocated if the user has some way of locking out
kmem_cache_free() operations on the slab. Otherwise the operations on the
returned object pointers cause race conditions.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slab.h |   18 ++++++++++++++++++
 mm/slab.c            |   23 +++++++++++++++++++++++
 mm/slob.c            |    6 ++++++
 mm/slub.c            |   42 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 89 insertions(+)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2010-05-14 12:24:44.000000000 -0500
+++ linux-2.6/include/linux/slab.h	2010-05-14 12:37:36.000000000 -0500
@@ -110,6 +110,24 @@ int kern_ptr_validate(const void *ptr, u
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);

 /*
+ * Determine objects in the same slab page as a given object.
+ *
+ * The return value is the number of objects currently allocated in the slab
+ * or a negative error value and the maximum number of objects that this
+ * slab page could handle.
+ *
+ * Warning: The objects returned can be freed at any time and therefore the
+ * pointer can be invalid unless other measures are taken to avoid objects
+ * being freed while looping through the list of objects.
+ *
+ * Return codes:
+ *	-E2BIG	More objects than fit into the provided list.
+ *	-EBUSY	Objects in the slab are allocation queues.
+ */
+int kmem_cache_objects(struct kmem_cache *slab, const void *x,
+		 const void **list, int max, int *capacity);
+
+/*
  * Please use this macro to create slab caches. Simply specify the
  * name of the structure and maybe some flags that are listed above.
  *
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-05-14 12:37:27.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-05-14 12:40:10.000000000 -0500
@@ -2868,6 +2868,48 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);

+static void get_object(struct kmem_cache *s, void *object, void *private)
+{
+	const void ***list = private;
+
+	*(*list)++ = object;
+}
+
+int kmem_cache_objects(struct kmem_cache *s, const void *x,
+		const void **list, int list_size, int *capacity)
+{
+	int r;
+	struct page *page;
+	unsigned long *map;
+
+	page = virt_to_head_page(x);
+	BUG_ON(!PageSlab(page));
+	BUG_ON(page->slab != s);
+	*capacity = page->objects;
+
+	map = kmalloc(BITS_TO_LONGS(page->objects), GFP_KERNEL);
+
+	slab_lock(page);
+	r = page->inuse;
+
+	if (page->inuse > list_size) {
+		r = -E2BIG;
+		goto abort;
+	}
+
+	if (PageSlubFrozen(page)) {
+		r = -EBUSY;
+		goto abort;
+	}
+
+	traverse_objects(s, page, get_object, &list, map);
+
+abort:
+	slab_unlock(page);
+	kfree(map);
+	return r;
+}
+
 /*
  * kmem_cache_shrink removes empty slabs from the partial lists and sorts
  * the remaining slabs by the number of items in use. The slabs with the
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2010-05-14 12:24:44.000000000 -0500
+++ linux-2.6/mm/slab.c	2010-05-14 12:37:36.000000000 -0500
@@ -3617,6 +3617,29 @@ out:
 	return 0;
 }

+int kmem_cache_objects(struct kmem_cache *cachep, const void *objp,
+		const void **list, int list_size, int *capacity)
+{
+	struct slab *slabp = virt_to_slab(objp);
+	void *p;
+	int i;
+
+	BUG_ON(cachep != virt_to_cache(objp));
+
+	*capacity = cachep->num;
+	if (slabp->inuse > list_size)
+		return -E2BIG;
+
+	for (i = 0, p = slabp->s_mem; i < cachep->num;
+				 i++, p += cachep->buffer_size) {
+
+		if (slab_bufctl(slabp)[i] == BUFCTL_ACTIVE)
+			*(list) ++ = p;
+
+	}
+	return slabp->inuse;
+}
+
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2010-05-14 12:24:44.000000000 -0500
+++ linux-2.6/mm/slob.c	2010-05-14 12:37:36.000000000 -0500
@@ -658,6 +658,12 @@ void kmem_cache_free(struct kmem_cache *
 }
 EXPORT_SYMBOL(kmem_cache_free);

+void kmem_cache_objects(struct kmem_cache *c, const void *b, void **list,
+						int list_size, int *capacity)
+{
+	return -EBUSY;
+}
+
 unsigned int kmem_cache_size(struct kmem_cache *c)
 {
 	return c->size;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
