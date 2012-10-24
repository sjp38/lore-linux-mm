Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 9D6A86B0072
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 09:59:39 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 1/2] kmem_cache: include allocators code directly into slab_common
Date: Wed, 24 Oct 2012 17:59:17 +0400
Message-Id: <1351087158-8524-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1351087158-8524-1-git-send-email-glommer@parallels.com>
References: <1351087158-8524-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

While the goal of slab_common.c is to have a common place for all
allocators, we face two different goals that are in opposition to each
other:

1) Have the different layouts be the business of each allocator, in
their .c
2) inline as much as we can for fast paths

Because of that, we either have to move all the entry points to the
mm/slab.h and rely heavily on the pre-processor, or include all .c files
in here.

The pre-processor solution has the disadvantage that some quite
non-trivial code gets even more non-trivial, and we end up leaving for
readers a non-pleasant indirection.

To keep this sane, we'll include the allocators .c files in here.  Which
means we will be able to inline any code they produced, but never the
other way around!

Doing this produced a name clash. This was resolved in this patch
itself.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Joonsoo Kim <js1304@gmail.com>
CC: David Rientjes <rientjes@google.com>
CC: Pekka Enberg <penberg@kernel.org>
CC: Christoph Lameter <cl@linux.com>
---
 mm/Makefile      |  3 ---
 mm/slab.c        |  9 ---------
 mm/slab_common.c | 33 +++++++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/mm/Makefile b/mm/Makefile
index 6b025f8..796d893 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -36,12 +36,9 @@ obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
-obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
-obj-$(CONFIG_SLAB) += slab.o
-obj-$(CONFIG_SLUB) += slub.o
 obj-$(CONFIG_KMEMCHECK) += kmemcheck.o
 obj-$(CONFIG_FAILSLAB) += failslab.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
diff --git a/mm/slab.c b/mm/slab.c
index 98b3460..72dadce 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4583,15 +4583,6 @@ static const struct file_operations proc_slabstats_operations = {
 	.release	= seq_release_private,
 };
 #endif
-
-static int __init slab_proc_init(void)
-{
-#ifdef CONFIG_DEBUG_SLAB_LEAK
-	proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
-#endif
-	return 0;
-}
-module_init(slab_proc_init);
 #endif
 
 /**
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 06f87db..66416ee 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -21,6 +21,36 @@
 
 #include "slab.h"
 
+/*
+ * While the goal of this file is to have a common place for all allocators,
+ * we face two different goals that are in opposition to each other:
+ *
+ * 1) Have the different layouts be the business of each allocator, in their .c
+ * 2) inline as much as we can for fast paths
+ *
+ * Because of that, we either have to move all the entry points to the mm/slab.h
+ * and rely heavily on the pre-processor, or include all .c files in here.
+ *
+ * The pre-processor solution has the disadvantage that some quite non-trivial
+ * code gets even more non-trivial, and we end up leaving for readers a
+ * non-pleasant indirection.
+ *
+ * To keep this sane, we'll include the allocators .c files in here. Which
+ * means we will be able to inline any code they produced, but never the other
+ * way around!
+ *
+ * Please also always make sure that the functions being called have the same
+ * name and signature in all alocators to avoid cumbersome conditionals in
+ * here.
+ */
+#ifdef CONFIG_SLUB
+#include "slub.c"
+#elif defined(CONFIG_SLOB)
+#include "slob.c"
+#else
+#include "slab.c"
+#endif
+
 enum slab_state slab_state;
 LIST_HEAD(slab_caches);
 DEFINE_MUTEX(slab_mutex);
@@ -302,6 +332,9 @@ static const struct file_operations proc_slabinfo_operations = {
 static int __init slab_proc_init(void)
 {
 	proc_create("slabinfo", S_IRUSR, NULL, &proc_slabinfo_operations);
+#ifdef CONFIG_DEBUG_SLAB_LEAK
+	proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
+#endif
 	return 0;
 }
 module_init(slab_proc_init);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
