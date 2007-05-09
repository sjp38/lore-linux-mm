Message-ID: <46414B4C.8020900@yahoo.com.au>
Date: Wed, 09 May 2007 14:17:16 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch] slob: implement RCU freeing
Content-Type: multipart/mixed;
 boundary="------------030504050308020604050100"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030504050308020604050100
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

-- 

--------------030504050308020604050100
Content-Type: text/plain;
 name="slob-add-rcu.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="slob-add-rcu.patch"

SLOB allocator should implement SLAB_DESTROY_BY_RCU correctly, because even
on UP, RCU freeing semantics are not equivalent to simply freeing immediately.
This also allows SLOB to be used on SMP.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig	2007-05-09 11:54:11.000000000 +1000
+++ linux-2.6/init/Kconfig	2007-05-09 11:54:50.000000000 +1000
@@ -476,7 +476,7 @@
 
 config SLAB
 	default y
-	bool "Use full SLAB allocator" if (EMBEDDED && !SMP && !SPARSEMEM)
+	bool "Use full SLAB allocator" if (EMBEDDED && !SPARSEMEM)
 	help
 	  Disabling this replaces the advanced SLAB allocator and
 	  kmalloc support with the drastically simpler SLOB allocator.
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2007-05-09 11:54:11.000000000 +1000
+++ linux-2.6/mm/slob.c	2007-05-09 11:54:55.000000000 +1000
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/timer.h>
+#include <linux/rcupdate.h>
 
 struct slob_block {
 	int units;
@@ -53,6 +54,11 @@
 };
 typedef struct bigblock bigblock_t;
 
+struct slob_rcu {
+	struct rcu_head head;
+	int size;
+};
+
 static slob_t arena = { .next = &arena, .units = 1 };
 static slob_t *slobfree = &arena;
 static bigblock_t *bigblocks;
@@ -242,6 +248,7 @@
 
 struct kmem_cache {
 	unsigned int size, align;
+	unsigned long flags;
 	const char *name;
 	void (*ctor)(void *, struct kmem_cache *, unsigned long);
 	void (*dtor)(void *, struct kmem_cache *, unsigned long);
@@ -259,6 +266,12 @@
 	if (c) {
 		c->name = name;
 		c->size = size;
+		if (flags & SLAB_DESTROY_BY_RCU) {
+			BUG_ON(c->dtor);
+			/* leave room for rcu footer at the end of object */
+			c->size += sizeof(struct slob_rcu);
+		}
+		c->flags = flags;
 		c->ctor = ctor;
 		c->dtor = dtor;
 		/* ignore alignment unless it's forced */
@@ -303,15 +316,35 @@
 }
 EXPORT_SYMBOL(kmem_cache_zalloc);
 
-void kmem_cache_free(struct kmem_cache *c, void *b)
+static void __kmem_cache_free(void *b, int size)
 {
-	if (c->dtor)
-		c->dtor(b, c, 0);
-
-	if (c->size < PAGE_SIZE)
-		slob_free(b, c->size);
+	if (size < PAGE_SIZE)
+		slob_free(b, size);
 	else
-		free_pages((unsigned long)b, find_order(c->size));
+		free_pages((unsigned long)b, find_order(size));
+}
+
+static void kmem_rcu_free(struct rcu_head *head)
+{
+	struct slob_rcu *slob_rcu = (struct slob_rcu *)head;
+	void *b = (void *)slob_rcu - (slob_rcu->size - sizeof(struct slob_rcu));
+
+	__kmem_cache_free(b, slob_rcu->size);
+}
+
+void kmem_cache_free(struct kmem_cache *c, void *b)
+{
+	if (unlikely(c->flags & SLAB_DESTROY_BY_RCU)) {
+		struct slob_rcu *slob_rcu;
+		slob_rcu = b + (c->size - sizeof(struct slob_rcu));
+		INIT_RCU_HEAD(&slob_rcu->head);
+		slob_rcu->size = c->size;
+		call_rcu(&slob_rcu->head, kmem_rcu_free);
+	} else {
+		if (c->dtor)
+			c->dtor(b, c, 0);
+		__kmem_cache_free(b, c->size);
+	}
 }
 EXPORT_SYMBOL(kmem_cache_free);
 

--------------030504050308020604050100--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
