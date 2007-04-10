From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 3/5] Validation of slabs (metadata and guard zones)
Date: Tue, 10 Apr 2007 12:19:21 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Implement validation of slabs

This enables validation of slab. Validation means that all objects are checked
to see if there are redzone violations, if padding has been overwritten or any
pointers have been corrupted. Also checks the consistency of slab counters.

Validation enables the detection of metadata corruption without the kernel
having to execute code that actually uses (allocs/frees) and object. It allows
one to make sure that the slab metainformation and the guard values around
an object have not been compromised.

A single slabcache can be checked by writing a 1 to the "validate" file.

i.e.

echo 1 >/sys/slab/kmalloc-128/validate

or use the slabinfo tool to check all slabs

slabinfo -v

Error messages will show up in the syslog.

Note that validation can only reach slabs that are on a list. This means
that we are usually restricted to partial slabs and active slabs unless
SLAB_STORE_USER is active which will build a full slab list and allows
validation of slabs that are fully in use. Booting with "slub_debug" set
will enable SLAB_STORE_USER and then full diagnostic are available.

Note that we attempt to push cpu slabs back to the lists when we start the
check. If the cpu slab is reactivated before we get to it (another processor
grabs it before we get to it) then it cannot be checked.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   87 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 86 insertions(+), 1 deletion(-)

Index: linux-2.6.21-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-rc6-mm1.orig/mm/slub.c	2007-04-09 22:30:09.000000000 -0700
+++ linux-2.6.21-rc6-mm1/mm/slub.c	2007-04-09 22:30:11.000000000 -0700
@@ -2321,6 +2321,92 @@ void *__kmalloc_node_track_caller(size_t
 
 #ifdef CONFIG_SYSFS
 
+static int validate_slab(struct kmem_cache *s, struct page *page)
+{
+	void *p;
+	void *addr = page_address(page);
+	unsigned long map[BITS_TO_LONGS(s->objects)];
+
+	if (!check_slab(s, page) ||
+			!on_freelist(s, page, NULL))
+		return 0;
+
+	/* Now we know that a valid freelist exists */
+	bitmap_zero(map, s->objects);
+
+	for(p = page->freelist; p; p = get_freepointer(s, p)) {
+		set_bit((p - addr) / s->size, map);
+		if (!check_object(s, page, p, 0))
+			return 0;
+	}
+
+	for(p = addr; p < addr + s->objects * s->size; p += s->size)
+		if (!test_bit((p - addr) / s->size, map))
+			if (!check_object(s, page, p, 1))
+				return 0;
+	return 1;
+}
+
+static void validate_slab_slab(struct kmem_cache *s, struct page *page)
+{
+	if (slab_trylock(page)) {
+		validate_slab(s, page);
+		slab_unlock(page);
+	} else
+		printk(KERN_INFO "SLUB: %s Skipped busy slab %p\n",
+			s->name, page);
+
+	if (!PageError(page))
+		printk(KERN_ERR "SLUB: %s PageError not set on slab %p\n",
+			s->name, page);
+}
+
+static int validate_slab_node(struct kmem_cache *s, struct kmem_cache_node *n)
+{
+	unsigned long count = 0;
+	struct page *page;
+	unsigned long flags;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+
+	list_for_each_entry(page, &n->partial, lru) {
+		validate_slab_slab(s, page);
+		count++;
+	}
+	if (count != n->nr_partial)
+		printk("SLUB: %s %ld partial slabs counted but counter=%ld\n",
+			s->name, count, n->nr_partial);
+
+	if (!(s->flags & SLAB_STORE_USER))
+		goto out;
+
+	list_for_each_entry(page, &n->full, lru) {
+		validate_slab_slab(s, page);
+		count++;
+	}
+	if (count != atomic_long_read(&n->nr_slabs))
+		printk("SLUB: %s %ld slabs counted but counter=%ld\n",
+		s->name, count, atomic_long_read(&n->nr_slabs));
+
+out:
+	spin_unlock_irqrestore(&n->list_lock, flags);
+	return count;
+}
+
+static unsigned long validate_slab_cache(struct kmem_cache *s)
+{
+	int node;
+	unsigned long count = 0;
+
+	flush_all(s);
+	for_each_online_node(node) {
+		struct kmem_cache_node *n = get_node(s, node);
+
+		count += validate_slab_node(s, n);
+	}
+	return count;
+}
+
 static unsigned long count_partial(struct kmem_cache_node *n)
 {
 	unsigned long flags;
@@ -2450,7 +2536,6 @@ struct slab_attribute {
 	static struct slab_attribute _name##_attr =  \
 	__ATTR(_name, 0644, _name##_show, _name##_store)
 
-
 static ssize_t slab_size_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", s->size);
@@ -2656,6 +2741,22 @@ static ssize_t store_user_store(struct k
 }
 SLAB_ATTR(store_user);
 
+static ssize_t validate_show(struct kmem_cache *s, char *buf)
+{
+	return 0;
+}
+
+static ssize_t validate_store(struct kmem_cache *s,
+			const char *buf, size_t length)
+{
+	if (buf[0] == '1')
+		validate_slab_cache(s);
+	else
+		return -EINVAL;
+	return length;
+}
+SLAB_ATTR(validate);
+
 #ifdef CONFIG_NUMA
 static ssize_t defrag_ratio_show(struct kmem_cache *s, char *buf)
 {
@@ -2695,6 +2796,7 @@ static struct attribute * slab_attrs[] =
 	&red_zone_attr.attr,
 	&poison_attr.attr,
 	&store_user_attr.attr,
+	&validate_attr.attr,
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
