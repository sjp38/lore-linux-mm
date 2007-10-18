Message-ID: <47172303.2010601@openvz.org>
Date: Thu, 18 Oct 2007 13:10:27 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: [PATCH] Create the caches with "calculated" names
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Many code in the kernel needs to create the caches with
some "formatted" names. E.g. the net/core/sock.c creates 
the caches with names
   ("request_sock_%s", proto->name)
dccp need caches like
   ("%s_hc_rx_sock", ccid_ops->ccid_name)
and so on.

The proposal is to create the generic method for creating
such a caches. The code is spread across sl[auo]b, so
maybe its better to move it to mm/util.c

The question is: does it worth sending to mainline?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/slab.h b/include/linux/slab.h
index f3a8eec..6b57826 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -54,7 +54,14 @@ int slab_is_available(void);
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(struct kmem_cache *, void *));
+
+#define KMEM_CACHE_NAME_MAX	128
+struct kmem_cache *kmem_cache_create_name(size_t, size_t,
+		unsigned long, void (*)(struct kmem_cache *, void *),
+		const char *fmt, ...) __attribute__ ((format (printf, 5, 6)));
+
 void kmem_cache_destroy(struct kmem_cache *);
+void kmem_cache_destroy_name(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
diff --git a/mm/slab.c b/mm/slab.c
index 3ce9bc0..0245807 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2377,6 +2377,37 @@ oops:
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
+struct kmem_cache *kmem_cache_create_name(size_t size, size_t align,
+		unsigned long flags, void (* ctor)(struct kmem_cache *, void *),
+		const char *fmt, ...)
+{
+	char *name, tmp[KMEM_CACHE_NAME_MAX];
+	va_list args;
+	struct kmem_cache *c;
+
+	va_start(args, fmt);
+	vsnprintf(tmp, sizeof(tmp), fmt, args);
+	va_end(args);
+
+	name = kstrdup(tmp, GFP_KERNEL);
+	if (name == NULL)
+		goto err_name;
+
+	c = kmem_cache_create(name, size, align, flags, ctor);
+	if (c == NULL)
+		goto err_cache;
+
+	return c;
+
+err_cache:
+	kfree(name);
+err_name:
+	if (flags & SLAB_PANIC)
+		panic("Canot create slabcache %s\n", name);
+	return NULL;
+}
+EXPORT_SYMBOL(kmem_cache_create_name);
+
 #if DEBUG
 static void check_irq_off(void)
 {
@@ -2572,6 +2603,16 @@ void kmem_cache_destroy(struct kmem_cache *cachep)
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
+void kmem_cache_destroy_name(struct kmem_cache *s)
+{
+	const char *name;
+
+	name = s->name;
+	kmem_cache_destroy(s);
+	kfree(name);
+}
+EXPORT_SYMBOL(kmem_cache_destroy_name);
+
 /*
  * Get the memory for a slab management obj.
  * For a slab cache when the slab descriptor is off-slab, slab descriptors
diff --git a/mm/slob.c b/mm/slob.c
index 5bc2ceb..015647b 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -532,12 +532,53 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
+struct kmem_cache *kmem_cache_create_name(size_t size, size_t align,
+		unsigned long flags, void (* ctor)(struct kmem_cache *, void *),
+		const char *fmt, ...)
+{
+	char *name, tmp[KMEM_CACHE_NAME_MAX];
+	va_list args;
+	struct kmem_cache *c;
+
+	va_start(args, fmt);
+	vsnprintf(tmp, sizeof(tmp), fmt, args);
+	va_end(args);
+
+	name = kstrdup(tmp, GFP_KERNEL);
+	if (name == NULL)
+		goto err_name;
+
+	c = kmem_cache_create(name, size, align, flags, ctor);
+	if (c == NULL)
+		goto err_cache;
+
+	return c;
+
+err_cache:
+	kfree(name);
+err_name:
+	if (flags & SLAB_PANIC)
+		panic("Canot create slabcache %s\n", name);
+	return NULL;
+}
+EXPORT_SYMBOL(kmem_cache_create_name);
+
 void kmem_cache_destroy(struct kmem_cache *c)
 {
 	slob_free(c, sizeof(struct kmem_cache));
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
+void kmem_cache_destroy_name(struct kmem_cache *s)
+{
+	const char *name;
+
+	name = s->name;
+	kmem_cache_destroy(s);
+	kfree(name);
+}
+EXPORT_SYMBOL(kmem_cache_destroy_name);
+
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
 	void *b;
diff --git a/mm/slub.c b/mm/slub.c
index e29a429..c91f8e5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2347,6 +2347,16 @@ void kmem_cache_destroy(struct kmem_cache *s)
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
+void kmem_cache_destroy_name(struct kmem_cache *s)
+{
+	const char *name;
+
+	name = s->name;
+	kmem_cache_destroy(s);
+	kfree(name);
+}
+EXPORT_SYMBOL(kmem_cache_destroy_name);
+
 /********************************************************************
  *		Kmalloc subsystem
  *******************************************************************/
@@ -2893,6 +2903,37 @@ err:
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
+struct kmem_cache *kmem_cache_create_name(size_t size, size_t align,
+		unsigned long flags, void (* ctor)(struct kmem_cache *, void *),
+		const char *fmt, ...)
+{
+	char *name, tmp[KMEM_CACHE_NAME_MAX];
+	va_list args;
+	struct kmem_cache *c;
+
+	va_start(args, fmt);
+	vsnprintf(tmp, sizeof(tmp), fmt, args);
+	va_end(args);
+
+	name = kstrdup(tmp, GFP_KERNEL);
+	if (name == NULL)
+		goto err_name;
+
+	c = kmem_cache_create(name, size, align, flags, ctor);
+	if (c == NULL)
+		goto err_cache;
+
+	return c;
+
+err_cache:
+	kfree(name);
+err_name:
+	if (flags & SLAB_PANIC)
+		panic("Canot create slabcache %s\n", name);
+	return NULL;
+}
+EXPORT_SYMBOL(kmem_cache_create_name);
+
 #ifdef CONFIG_SMP
 /*
  * Use the cpu notifier to insure that the cpu slabs are flushed when

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
