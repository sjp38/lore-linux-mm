Date: Fri, 6 Jul 2007 12:52:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Do not allocate object bit array on stack
Message-ID: <Pine.LNX.4.64.0707061252030.24364@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The objects per slab increase with the current patches in mm since we
allow up to order 3 allocs by default. More patches in mm actually allow
to use 2M or higher sized slabs. For slab validation we need per object
bitmaps in order to check a slab. We end up with up to 64k objects per
slab resulting in a potential requirement of 8K stack space. That does
not look good.

Allocate the bit arrays via kmalloc.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   39 +++++++++++++++++++++++++--------------
 1 file changed, 25 insertions(+), 14 deletions(-)

Index: linux-2.6.22-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-04 13:37:41.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-04 13:38:51.000000000 -0700
@@ -2784,11 +2784,11 @@ void *__kmalloc_node_track_caller(size_t
 }
 
 #if defined(CONFIG_SYSFS) && defined(CONFIG_SLUB_DEBUG)
-static int validate_slab(struct kmem_cache *s, struct page *page)
+static int validate_slab(struct kmem_cache *s, struct page *page,
+						unsigned long *map)
 {
 	void *p;
 	void *addr = page_address(page);
-	DECLARE_BITMAP(map, s->objects);
 
 	if (!check_slab(s, page) ||
 			!on_freelist(s, page, NULL))
@@ -2810,10 +2810,11 @@ static int validate_slab(struct kmem_cac
 	return 1;
 }
 
-static void validate_slab_slab(struct kmem_cache *s, struct page *page)
+static void validate_slab_slab(struct kmem_cache *s, struct page *page,
+						unsigned long *map)
 {
 	if (slab_trylock(page)) {
-		validate_slab(s, page);
+		validate_slab(s, page, map);
 		slab_unlock(page);
 	} else
 		printk(KERN_INFO "SLUB %s: Skipped busy slab 0x%p\n",
@@ -2830,7 +2831,8 @@ static void validate_slab_slab(struct km
 	}
 }
 
-static int validate_slab_node(struct kmem_cache *s, struct kmem_cache_node *n)
+static int validate_slab_node(struct kmem_cache *s,
+		struct kmem_cache_node *n, unsigned long *map)
 {
 	unsigned long count = 0;
 	struct page *page;
@@ -2839,7 +2841,7 @@ static int validate_slab_node(struct kme
 	spin_lock_irqsave(&n->list_lock, flags);
 
 	list_for_each_entry(page, &n->partial, lru) {
-		validate_slab_slab(s, page);
+		validate_slab_slab(s, page, map);
 		count++;
 	}
 	if (count != n->nr_partial)
@@ -2850,7 +2852,7 @@ static int validate_slab_node(struct kme
 		goto out;
 
 	list_for_each_entry(page, &n->full, lru) {
-		validate_slab_slab(s, page);
+		validate_slab_slab(s, page, map);
 		count++;
 	}
 	if (count != atomic_long_read(&n->nr_slabs))
@@ -2863,17 +2865,23 @@ out:
 	return count;
 }
 
-static unsigned long validate_slab_cache(struct kmem_cache *s)
+static long validate_slab_cache(struct kmem_cache *s)
 {
 	int node;
 	unsigned long count = 0;
+	unsigned long *map = kmalloc(BITS_TO_LONGS(s->objects) *
+				sizeof(unsigned long), GFP_KERNEL);
+
+	if (!map)
+		return -ENOMEM;
 
 	flush_all(s);
 	for_each_online_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
-		count += validate_slab_node(s, n);
+		count += validate_slab_node(s, n, map);
 	}
+	kfree(map);
 	return count;
 }
 
@@ -3487,11 +3495,14 @@ static ssize_t validate_show(struct kmem
 static ssize_t validate_store(struct kmem_cache *s,
 			const char *buf, size_t length)
 {
-	if (buf[0] == '1')
-		validate_slab_cache(s);
-	else
-		return -EINVAL;
-	return length;
+	int ret = -EINVAL;
+
+	if (buf[0] == '1') {
+		ret = validate_slab_cache(s);
+		if (ret >= 0)
+			ret = length;
+	}
+	return ret;
 }
 SLAB_ATTR(validate);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
