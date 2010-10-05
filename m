Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A85F86B0085
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:58:18 -0400 (EDT)
Message-Id: <20101005185812.949429401@linux.com>
Date: Tue, 05 Oct 2010 13:57:27 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 02/16] slub: Move functions to reduce #ifdefs
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=shuffle
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

There is a lot of #ifdef/#endifs that can be avoided if functions would be in different
places. Move them around and reduce #ifdef.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |  297 +++++++++++++++++++++++++++++---------------------------------
 1 file changed, 141 insertions(+), 156 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-04 08:17:49.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-04 08:18:03.000000000 -0500
@@ -3476,71 +3476,6 @@ static long validate_slab_cache(struct k
 	kfree(map);
 	return count;
 }
-#endif
-
-#ifdef SLUB_RESILIENCY_TEST
-static void resiliency_test(void)
-{
-	u8 *p;
-
-	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 16 || SLUB_PAGE_SHIFT < 10);
-
-	printk(KERN_ERR "SLUB resiliency testing\n");
-	printk(KERN_ERR "-----------------------\n");
-	printk(KERN_ERR "A. Corruption after allocation\n");
-
-	p = kzalloc(16, GFP_KERNEL);
-	p[16] = 0x12;
-	printk(KERN_ERR "\n1. kmalloc-16: Clobber Redzone/next pointer"
-			" 0x12->0x%p\n\n", p + 16);
-
-	validate_slab_cache(kmalloc_caches[4]);
-
-	/* Hmmm... The next two are dangerous */
-	p = kzalloc(32, GFP_KERNEL);
-	p[32 + sizeof(void *)] = 0x34;
-	printk(KERN_ERR "\n2. kmalloc-32: Clobber next pointer/next slab"
-			" 0x34 -> -0x%p\n", p);
-	printk(KERN_ERR
-		"If allocated object is overwritten then not detectable\n\n");
-
-	validate_slab_cache(kmalloc_caches[5]);
-	p = kzalloc(64, GFP_KERNEL);
-	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
-	*p = 0x56;
-	printk(KERN_ERR "\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
-									p);
-	printk(KERN_ERR
-		"If allocated object is overwritten then not detectable\n\n");
-	validate_slab_cache(kmalloc_caches[6]);
-
-	printk(KERN_ERR "\nB. Corruption after free\n");
-	p = kzalloc(128, GFP_KERNEL);
-	kfree(p);
-	*p = 0x78;
-	printk(KERN_ERR "1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[7]);
-
-	p = kzalloc(256, GFP_KERNEL);
-	kfree(p);
-	p[50] = 0x9a;
-	printk(KERN_ERR "\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n",
-			p);
-	validate_slab_cache(kmalloc_caches[8]);
-
-	p = kzalloc(512, GFP_KERNEL);
-	kfree(p);
-	p[512] = 0xab;
-	printk(KERN_ERR "\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[9]);
-}
-#else
-#ifdef CONFIG_SYSFS
-static void resiliency_test(void) {};
-#endif
-#endif
-
-#ifdef CONFIG_DEBUG
 /*
  * Generate lists of code addresses where slabcache objects are allocated
  * and freed.
@@ -3771,6 +3706,68 @@ static int list_locations(struct kmem_ca
 }
 #endif
 
+#ifdef SLUB_RESILIENCY_TEST
+static void resiliency_test(void)
+{
+	u8 *p;
+
+	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 16 || SLUB_PAGE_SHIFT < 10);
+
+	printk(KERN_ERR "SLUB resiliency testing\n");
+	printk(KERN_ERR "-----------------------\n");
+	printk(KERN_ERR "A. Corruption after allocation\n");
+
+	p = kzalloc(16, GFP_KERNEL);
+	p[16] = 0x12;
+	printk(KERN_ERR "\n1. kmalloc-16: Clobber Redzone/next pointer"
+			" 0x12->0x%p\n\n", p + 16);
+
+	validate_slab_cache(kmalloc_caches[4]);
+
+	/* Hmmm... The next two are dangerous */
+	p = kzalloc(32, GFP_KERNEL);
+	p[32 + sizeof(void *)] = 0x34;
+	printk(KERN_ERR "\n2. kmalloc-32: Clobber next pointer/next slab"
+			" 0x34 -> -0x%p\n", p);
+	printk(KERN_ERR
+		"If allocated object is overwritten then not detectable\n\n");
+
+	validate_slab_cache(kmalloc_caches[5]);
+	p = kzalloc(64, GFP_KERNEL);
+	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
+	*p = 0x56;
+	printk(KERN_ERR "\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
+									p);
+	printk(KERN_ERR
+		"If allocated object is overwritten then not detectable\n\n");
+	validate_slab_cache(kmalloc_caches[6]);
+
+	printk(KERN_ERR "\nB. Corruption after free\n");
+	p = kzalloc(128, GFP_KERNEL);
+	kfree(p);
+	*p = 0x78;
+	printk(KERN_ERR "1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
+	validate_slab_cache(kmalloc_caches[7]);
+
+	p = kzalloc(256, GFP_KERNEL);
+	kfree(p);
+	p[50] = 0x9a;
+	printk(KERN_ERR "\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n",
+			p);
+	validate_slab_cache(kmalloc_caches[8]);
+
+	p = kzalloc(512, GFP_KERNEL);
+	kfree(p);
+	p[512] = 0xab;
+	printk(KERN_ERR "\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
+	validate_slab_cache(kmalloc_caches[9]);
+}
+#else
+#ifdef CONFIG_SYSFS
+static void resiliency_test(void) {};
+#endif
+#endif
+
 #ifdef CONFIG_SYSFS
 enum slab_stat_type {
 	SL_ALL,			/* All slabs */
@@ -3987,14 +3984,6 @@ static ssize_t aliases_show(struct kmem_
 }
 SLAB_ATTR_RO(aliases);
 
-#ifdef CONFIG_SLUB_DEBUG
-static ssize_t slabs_show(struct kmem_cache *s, char *buf)
-{
-	return show_slab_objects(s, buf, SO_ALL);
-}
-SLAB_ATTR_RO(slabs);
-#endif
-
 static ssize_t partial_show(struct kmem_cache *s, char *buf)
 {
 	return show_slab_objects(s, buf, SO_PARTIAL);
@@ -4019,7 +4008,48 @@ static ssize_t objects_partial_show(stru
 }
 SLAB_ATTR_RO(objects_partial);
 
+static ssize_t reclaim_account_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_RECLAIM_ACCOUNT));
+}
+
+static ssize_t reclaim_account_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	s->flags &= ~SLAB_RECLAIM_ACCOUNT;
+	if (buf[0] == '1')
+		s->flags |= SLAB_RECLAIM_ACCOUNT;
+	return length;
+}
+SLAB_ATTR(reclaim_account);
+
+static ssize_t hwcache_align_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_HWCACHE_ALIGN));
+}
+SLAB_ATTR_RO(hwcache_align);
+
+#ifdef CONFIG_ZONE_DMA
+static ssize_t cache_dma_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_CACHE_DMA));
+}
+SLAB_ATTR_RO(cache_dma);
+#endif
+
+static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_DESTROY_BY_RCU));
+}
+SLAB_ATTR_RO(destroy_by_rcu);
+
 #ifdef CONFIG_SLUB_DEBUG
+static ssize_t slabs_show(struct kmem_cache *s, char *buf)
+{
+	return show_slab_objects(s, buf, SO_ALL);
+}
+SLAB_ATTR_RO(slabs);
+
 static ssize_t total_objects_show(struct kmem_cache *s, char *buf)
 {
 	return show_slab_objects(s, buf, SO_ALL|SO_TOTAL);
@@ -4056,60 +4086,6 @@ static ssize_t trace_store(struct kmem_c
 }
 SLAB_ATTR(trace);
 
-#ifdef CONFIG_FAILSLAB
-static ssize_t failslab_show(struct kmem_cache *s, char *buf)
-{
-	return sprintf(buf, "%d\n", !!(s->flags & SLAB_FAILSLAB));
-}
-
-static ssize_t failslab_store(struct kmem_cache *s, const char *buf,
-							size_t length)
-{
-	s->flags &= ~SLAB_FAILSLAB;
-	if (buf[0] == '1')
-		s->flags |= SLAB_FAILSLAB;
-	return length;
-}
-SLAB_ATTR(failslab);
-#endif
-#endif
-
-static ssize_t reclaim_account_show(struct kmem_cache *s, char *buf)
-{
-	return sprintf(buf, "%d\n", !!(s->flags & SLAB_RECLAIM_ACCOUNT));
-}
-
-static ssize_t reclaim_account_store(struct kmem_cache *s,
-				const char *buf, size_t length)
-{
-	s->flags &= ~SLAB_RECLAIM_ACCOUNT;
-	if (buf[0] == '1')
-		s->flags |= SLAB_RECLAIM_ACCOUNT;
-	return length;
-}
-SLAB_ATTR(reclaim_account);
-
-static ssize_t hwcache_align_show(struct kmem_cache *s, char *buf)
-{
-	return sprintf(buf, "%d\n", !!(s->flags & SLAB_HWCACHE_ALIGN));
-}
-SLAB_ATTR_RO(hwcache_align);
-
-#ifdef CONFIG_ZONE_DMA
-static ssize_t cache_dma_show(struct kmem_cache *s, char *buf)
-{
-	return sprintf(buf, "%d\n", !!(s->flags & SLAB_CACHE_DMA));
-}
-SLAB_ATTR_RO(cache_dma);
-#endif
-
-static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
-{
-	return sprintf(buf, "%d\n", !!(s->flags & SLAB_DESTROY_BY_RCU));
-}
-SLAB_ATTR_RO(destroy_by_rcu);
-
-#ifdef CONFIG_SLUB_DEBUG
 static ssize_t red_zone_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", !!(s->flags & SLAB_RED_ZONE));
@@ -4185,6 +4161,39 @@ static ssize_t validate_store(struct kme
 	return ret;
 }
 SLAB_ATTR(validate);
+
+static ssize_t alloc_calls_show(struct kmem_cache *s, char *buf)
+{
+	if (!(s->flags & SLAB_STORE_USER))
+		return -ENOSYS;
+	return list_locations(s, buf, TRACK_ALLOC);
+}
+SLAB_ATTR_RO(alloc_calls);
+
+static ssize_t free_calls_show(struct kmem_cache *s, char *buf)
+{
+	if (!(s->flags & SLAB_STORE_USER))
+		return -ENOSYS;
+	return list_locations(s, buf, TRACK_FREE);
+}
+SLAB_ATTR_RO(free_calls);
+#endif /* CONFIG_SLUB_DEBUG */
+
+#ifdef CONFIG_FAILSLAB
+static ssize_t failslab_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_FAILSLAB));
+}
+
+static ssize_t failslab_store(struct kmem_cache *s, const char *buf,
+							size_t length)
+{
+	s->flags &= ~SLAB_FAILSLAB;
+	if (buf[0] == '1')
+		s->flags |= SLAB_FAILSLAB;
+	return length;
+}
+SLAB_ATTR(failslab);
 #endif
 
 static ssize_t shrink_show(struct kmem_cache *s, char *buf)
@@ -4206,24 +4215,6 @@ static ssize_t shrink_store(struct kmem_
 }
 SLAB_ATTR(shrink);
 
-#ifdef CONFIG_SLUB_DEBUG
-static ssize_t alloc_calls_show(struct kmem_cache *s, char *buf)
-{
-	if (!(s->flags & SLAB_STORE_USER))
-		return -ENOSYS;
-	return list_locations(s, buf, TRACK_ALLOC);
-}
-SLAB_ATTR_RO(alloc_calls);
-
-static ssize_t free_calls_show(struct kmem_cache *s, char *buf)
-{
-	if (!(s->flags & SLAB_STORE_USER))
-		return -ENOSYS;
-	return list_locations(s, buf, TRACK_FREE);
-}
-SLAB_ATTR_RO(free_calls);
-#endif
-
 #ifdef CONFIG_NUMA
 static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
 {
@@ -4329,30 +4320,24 @@ static struct attribute *slab_attrs[] = 
 	&min_partial_attr.attr,
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
-#ifdef CONFIG_SLUB_DEBUG
-	&total_objects_attr.attr,
-	&slabs_attr.attr,
-#endif
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
 	&ctor_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
-#ifdef CONFIG_SLUB_DEBUG
-	&sanity_checks_attr.attr,
-	&trace_attr.attr,
-#endif
 	&hwcache_align_attr.attr,
 	&reclaim_account_attr.attr,
 	&destroy_by_rcu_attr.attr,
+	&shrink_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
+	&total_objects_attr.attr,
+	&slabs_attr.attr,
+	&sanity_checks_attr.attr,
+	&trace_attr.attr,
 	&red_zone_attr.attr,
 	&poison_attr.attr,
 	&store_user_attr.attr,
 	&validate_attr.attr,
-#endif
-	&shrink_attr.attr,
-#ifdef CONFIG_SLUB_DEBUG
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
