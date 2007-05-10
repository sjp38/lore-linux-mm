Message-ID: <4642C6A2.1090809@yahoo.com.au>
Date: Thu, 10 May 2007 17:15:46 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch] slob: implement RCU freeing
References: <Pine.LNX.4.64.0705081746500.16914@schroedinger.engr.sgi.com> <20070509012725.GZ11115@waste.org> <Pine.LNX.4.64.0705081828300.17376@schroedinger.engr.sgi.com> <20070508.185141.85412154.davem@davemloft.net> <46412BB5.1060605@yahoo.com.au> <20070509174238.b4152887.akpm@linux-foundation.org> <46426EA1.4030408@yahoo.com.au> <20070510022707.GO11115@waste.org>
In-Reply-To: <20070510022707.GO11115@waste.org>
Content-Type: multipart/mixed;
 boundary="------------040502000505000809040805"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040502000505000809040805
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Matt Mackall wrote:

> Looks good to me, but haven't had time to actually test it.
> 
> Acked-by: Matt Mackall <mpm@selenic.com>

Updated to current, added a comment, and test booted it again.
Works OK.

-- 
SUSE Labs, Novell Inc.

--------------040502000505000809040805
Content-Type: text/plain;
 name="slob-add-rcu.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="slob-add-rcu.patch"

The SLOB allocator should implement SLAB_DESTROY_BY_RCU correctly, because even
on UP, RCU freeing semantics are not equivalent to simply freeing immediately.
This also allows SLOB to be used on SMP.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Acked-by: Matt Mackall <mpm@selenic.com>

Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig	2007-05-10 14:17:38.000000000 +1000
+++ linux-2.6/init/Kconfig	2007-05-10 14:18:11.000000000 +1000
@@ -519,7 +519,8 @@
 	  slab allocator.
 
 config SLUB
-	depends on EXPERIMENTAL && !ARCH_USES_SLAB_PAGE_STRUCT
+#	depends on EXPERIMENTAL && !ARCH_USES_SLAB_PAGE_STRUCT
+	depends on EXPERIMENTAL
 	bool "SLUB (Unqueued Allocator)"
 	help
 	   SLUB is a slab allocator that minimizes cache line usage
@@ -529,15 +530,11 @@
 	   way and has enhanced diagnostics.
 
 config SLOB
-#
-#	SLOB cannot support SMP because SLAB_DESTROY_BY_RCU does not work
-#	properly.
-#
-	depends on EMBEDDED && !SMP && !SPARSEMEM
+	depends on EMBEDDED && !SPARSEMEM
 	bool "SLOB (Simple Allocator)"
 	help
 	   SLOB replaces the SLAB allocator with a drastically simpler
-	   allocator.  SLOB is more space efficient that SLAB but does not
+	   allocator.  SLOB is more space efficient than SLAB but does not
 	   scale well (single lock for all operations) and is more susceptible
 	   to fragmentation. SLOB it is a great choice to reduce
 	   memory usage and code size for embedded systems.
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2007-05-10 14:17:38.000000000 +1000
+++ linux-2.6/mm/slob.c	2007-05-10 14:59:35.000000000 +1000
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/timer.h>
+#include <linux/rcupdate.h>
 
 struct slob_block {
 	int units;
@@ -53,6 +54,16 @@
 };
 typedef struct bigblock bigblock_t;
 
+/*
+ * struct slob_rcu is inserted at the tail of allocated slob blocks, which
+ * were created with a SLAB_DESTROY_BY_RCU slab. slob_rcu is used to free
+ * the block using call_rcu.
+ */
+struct slob_rcu {
+	struct rcu_head head;
+	int size;
+};
+
 static slob_t arena = { .next = &arena, .units = 1 };
 static slob_t *slobfree = &arena;
 static bigblock_t *bigblocks;
@@ -266,6 +277,7 @@
 
 struct kmem_cache {
 	unsigned int size, align;
+	unsigned long flags;
 	const char *name;
 	void (*ctor)(void *, struct kmem_cache *, unsigned long);
 	void (*dtor)(void *, struct kmem_cache *, unsigned long);
@@ -283,6 +295,12 @@
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
@@ -328,15 +346,35 @@
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
-		free_pages((unsigned long)b, get_order(c->size));
+		free_pages((unsigned long)b, get_order(size));
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
 

--------------040502000505000809040805--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
