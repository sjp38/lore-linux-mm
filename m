Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id B1D3E6B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 16:06:24 -0400 (EDT)
Date: Thu, 10 May 2012 14:39:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: [RFC] slub: Defer sysfs processing into a separate worker thread
Message-ID: <alpine.DEB.2.00.1205101438360.18664@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org


sysfs processing has been causing a lot of trouble in the past. In
particular sysfs can trigger user space events that then will interrupt
slab processing. We do not want that. Defer sysfs event processing
into a kernel thread and let the slab functions finish regardless of
sysfs's actions.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 47 insertions(+), 9 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-05-10 04:57:46.962582494 -0500
+++ linux-2.6/mm/slub.c	2012-05-10 08:36:07.742311030 -0500
@@ -3921,6 +3921,28 @@ static struct kmem_cache *find_mergeable
 	return NULL;
 }

+/*
+ * Defer sysfs work into a kernel event thread so that userspace actions by
+ * sysfs do not cause havoc.
+ */
+struct sysfs_work_struct {
+	struct work_struct w;
+	struct kmem_cache *s;
+};
+
+void sysfs_slab_add_work(struct work_struct *w)
+{
+	struct kmem_cache *s = ((struct sysfs_work_struct *)w)->s;
+
+	kfree(w);
+	down_write(&slub_lock);
+	if (sysfs_slab_add(s))
+		printk(KERN_ERR "SLUB: Unable to add slab %s to /sys/kernel/slab\n", s->name);
+	up_write(&slub_lock);
+	/* Decrease refcount and free the cache if it was freed in the meantime */
+	kmem_cache_destroy(s);
+}
+
 struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
@@ -3957,11 +3979,32 @@ struct kmem_cache *kmem_cache_create(con
 	if (s) {
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
-			list_add(&s->list, &slab_caches);
+			/*
+			 * Deferred adding to sysfs since we do not want
+			 * to wait for potential userspace processing
+			 */
+			struct sysfs_work_struct *w;
+
+			if (slab_state < UP) {
+				w = kmalloc(sizeof(*w), GFP_KERNEL);
+
+				if (w) {
+					list_add(&s->list, &slab_caches);
+					/*
+					 * Prevent kmem_cache from being
+					 * released until work is complete.
+					 */
+					s->refcount++;
+					INIT_WORK(&w->w, sysfs_slab_add_work);
+					w->s = s;
+					queue_work(system_unbound_wq, &w->w);
+				}
+			} else
+				w = ZERO_SIZE_PTR;
+
 			up_write(&slub_lock);
-			if (sysfs_slab_add(s)) {
+			if (!w) {
 				down_write(&slub_lock);
-				list_del(&s->list);
 				kfree(n);
 				kfree(s);
 				goto err;
@@ -5281,13 +5324,8 @@ static int sysfs_slab_add(struct kmem_ca
 {
 	int err;
 	const char *name;
-	int unmergeable;
-
-	if (slab_state < SYSFS)
-		/* Defer until later */
-		return 0;
+	int unmergeable = slab_unmergeable(s);

-	unmergeable = slab_unmergeable(s);
 	if (unmergeable) {
 		/*
 		 * Slabcache can never be merged so we can use the name proper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
