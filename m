Date: Wed, 14 Sep 2005 11:29:38 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] - Increase max allowed kmalloc size for very large systems
Message-ID: <20050914162937.GA30596@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I'm in the process of changing IA64 to support (at least boot) with
up to 1024p. One of the issues is that kmalloc is being called to
allocate structures that exceed the sizes allowed in kmalloc_sizes.h.

Specifically, the workqueue code allocates a structure with 
a size a few bytes +  NR_CPUS * CACHE_LINE_SIZE (128 bytes on IA64). This
is over the limit allowed by kmalloc_sizes.h. Although workqueues
could be changed to eliminate this specific problem, I expect other places
will encounter the same limit. 

For now, I'm proposing that kmalloc_sizes.h be modified to allow allocation of
larger structures if NR_CPUS exceeds 512. This makes the change a noop
on all current platforms.

Does anyone see any problems with this approach???

	Signed-off-by: Jack Steiner <steiner@sgi.com>




Index: linux/include/linux/kmalloc_sizes.h
===================================================================
--- linux.orig/include/linux/kmalloc_sizes.h	2005-09-12 10:40:20.749999533 -0500
+++ linux/include/linux/kmalloc_sizes.h	2005-09-14 10:47:04.479120684 -0500
@@ -19,8 +19,10 @@
 	CACHE(32768)
 	CACHE(65536)
 	CACHE(131072)
-#ifndef CONFIG_MMU
+#if (NR_CPUS > 512) || !defined(CONFIG_MMU) 
 	CACHE(262144)
+#endif
+#ifndef CONFIG_MMU
 	CACHE(524288)
 	CACHE(1048576)
 #ifdef CONFIG_LARGE_ALLOCS
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
