Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8972A6B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 08:46:30 -0400 (EDT)
Date: Fri, 24 Apr 2009 08:46:15 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] MM: Rewrite some tests with is_power_of_2() for clarity.
Message-ID: <alpine.LFD.2.00.0904240834270.22152@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


Replace some conditional tests with the semantically clearer call to
is_power_of_2().

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

  there are other tests of the form "n & (n - 1)" in mm/, but they are
testing for single bitness so they should be left alone.

  compile-tested on x86_64 with "make defconfig".


diff --git a/mm/bootmem.c b/mm/bootmem.c
index daf9271..5b379c2 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -12,6 +12,7 @@
 #include <linux/pfn.h>
 #include <linux/bootmem.h>
 #include <linux/module.h>
+#include <linux/log2.h>

 #include <asm/bug.h>
 #include <asm/io.h>
@@ -438,7 +439,7 @@ static void * __init alloc_bootmem_core(struct bootmem_data *bdata,
 		align, goal, limit);

 	BUG_ON(!size);
-	BUG_ON(align & (align - 1));
+	BUG_ON(!is_power_of_2(align));
 	BUG_ON(limit && goal + size > limit);

 	if (!bdata->node_bootmem_map)
diff --git a/mm/dmapool.c b/mm/dmapool.c
index b1f0885..2a26e5e 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -36,6 +36,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/wait.h>
+#include <linux/log2.h>

 #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB_DEBUG_ON)
 #define DMAPOOL_DEBUG 1
@@ -135,7 +136,7 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,

 	if (align == 0) {
 		align = 1;
-	} else if (align & (align - 1)) {
+	} else if (!is_power_of_2(align)) {
 		return NULL;
 	}

@@ -152,7 +153,7 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,

 	if (!boundary) {
 		boundary = allocation;
-	} else if ((boundary < size) || (boundary & (boundary - 1))) {
+	} else if ((boundary < size) || !is_power_of_2(boundary)) {
 		return NULL;
 	}

diff --git a/mm/slub.c b/mm/slub.c
index 7ab54ec..640831a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -26,6 +26,7 @@
 #include <linux/memory.h>
 #include <linux/math64.h>
 #include <linux/fault-inject.h>
+#include <linux/log2.h>

 /*
  * Lock order:
@@ -3056,7 +3057,7 @@ void __init kmem_cache_init(void)
 	 * around with ARCH_KMALLOC_MINALIGN
 	 */
 	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
-		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
+		(!is_power_of_2(KMALLOC_MIN_SIZE)));

 	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8)
 		size_index[(i - 1) / 8] = KMALLOC_SHIFT_LOW;




========================================================================
Robert P. J. Day                               Waterloo, Ontario, CANADA

        Linux Consulting, Training and Annoying Kernel Pedantry.

Web page:                                          http://crashcourse.ca
Linked In:                             http://www.linkedin.com/in/rpjday
Twitter:                                       http://twitter.com/rpjday
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
