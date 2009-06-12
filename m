Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 86DBD6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 04:12:59 -0400 (EDT)
Date: Fri, 12 Jun 2009 11:13:19 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 1/2] init: Use GFP_NOWAIT for early slab allocations
Message-ID: <Pine.LNX.4.64.0906121110530.29129@melkki.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, npiggin@suse.de, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

We setup slab allocators very early now while interrupts can still be disabled.
Therefore, make sure call-sites that use slab_is_available() to switch to slab
during boot use GFP_NOWAIT.

Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
Ingo, Ben, can you confirm that x86 and powerpc work with these two 
patches applied?

 include/linux/vmalloc.h |    1 +
 kernel/params.c         |    2 +-
 kernel/profile.c        |    6 +++---
 mm/page_alloc.c         |    2 +-
 mm/sparse-vmemmap.c     |    2 +-
 mm/sparse.c             |    2 +-
 mm/vmalloc.c            |   18 ++++++++++++++++++
 7 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index a43ebec..7bcb9d7 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -53,6 +53,7 @@ static inline void vmalloc_init(void)
 extern void *vmalloc(unsigned long size);
 extern void *vmalloc_user(unsigned long size);
 extern void *vmalloc_node(unsigned long size, int node);
+extern void *vmalloc_node_boot(unsigned long size, int node);
 extern void *vmalloc_exec(unsigned long size);
 extern void *vmalloc_32(unsigned long size);
 extern void *vmalloc_32_user(unsigned long size);
diff --git a/kernel/params.c b/kernel/params.c
index de273ec..5c239c3 100644
--- a/kernel/params.c
+++ b/kernel/params.c
@@ -227,7 +227,7 @@ int param_set_charp(const char *val, struct kernel_param *kp)
 	 * don't need to; this mangled commandline is preserved. */
 	if (slab_is_available()) {
 		kp->perm |= KPARAM_KMALLOCED;
-		*(char **)kp->arg = kstrdup(val, GFP_KERNEL);
+		*(char **)kp->arg = kstrdup(val, GFP_NOWAIT);
 		if (!kp->arg)
 			return -ENOMEM;
 	} else
diff --git a/kernel/profile.c b/kernel/profile.c
index 28cf26a..86ada09 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -112,16 +112,16 @@ int __ref profile_init(void)
 	prof_len = (_etext - _stext) >> prof_shift;
 	buffer_bytes = prof_len*sizeof(atomic_t);
 
-	if (!alloc_cpumask_var(&prof_cpu_mask, GFP_KERNEL))
+	if (!alloc_cpumask_var(&prof_cpu_mask, GFP_NOWAIT))
 		return -ENOMEM;
 
 	cpumask_copy(prof_cpu_mask, cpu_possible_mask);
 
-	prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL);
+	prof_buffer = kzalloc(buffer_bytes, GFP_NOWAIT);
 	if (prof_buffer)
 		return 0;
 
-	prof_buffer = alloc_pages_exact(buffer_bytes, GFP_KERNEL|__GFP_ZERO);
+	prof_buffer = alloc_pages_exact(buffer_bytes, GFP_NOWAIT|__GFP_ZERO);
 	if (prof_buffer)
 		return 0;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 17d5f53..7760ef9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2903,7 +2903,7 @@ int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 		 * To use this new node's memory, further consideration will be
 		 * necessary.
 		 */
-		zone->wait_table = vmalloc(alloc_size);
+		zone->wait_table = __vmalloc(alloc_size, GFP_NOWAIT, PAGE_KERNEL);
 	}
 	if (!zone->wait_table)
 		return -ENOMEM;
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index a13ea64..9df6d99 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -49,7 +49,7 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 	/* If the main allocator is up use that, fallback to bootmem. */
 	if (slab_is_available()) {
 		struct page *page = alloc_pages_node(node,
-				GFP_KERNEL | __GFP_ZERO, get_order(size));
+				GFP_NOWAIT | __GFP_ZERO, get_order(size));
 		if (page)
 			return page_address(page);
 		return NULL;
diff --git a/mm/sparse.c b/mm/sparse.c
index da432d9..dd558d2 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -63,7 +63,7 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
 				   sizeof(struct mem_section);
 
 	if (slab_is_available())
-		section = kmalloc_node(array_size, GFP_KERNEL, nid);
+		section = kmalloc_node(array_size, GFP_NOWAIT, nid);
 	else
 		section = alloc_bootmem_node(NODE_DATA(nid), array_size);
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f8189a4..3bec46d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1559,6 +1559,24 @@ void *vmalloc_node(unsigned long size, int node)
 }
 EXPORT_SYMBOL(vmalloc_node);
 
+/**
+ *	vmalloc_node_boot  -  allocate memory on a specific node during boot
+ *	@size:		allocation size
+ *	@node:		numa node
+ *
+ *	Allocate enough pages to cover @size from the page level
+ *	allocator and map them into contiguous kernel virtual space.
+ *
+ *	For tight control over page level allocator and protection flags
+ *	use __vmalloc() instead.
+ */
+void *vmalloc_node_boot(unsigned long size, int node)
+{
+	return __vmalloc_node(size, GFP_NOWAIT | __GFP_HIGHMEM, PAGE_KERNEL,
+					node, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(vmalloc_node_boot);
+
 #ifndef PAGE_KERNEL_EXEC
 # define PAGE_KERNEL_EXEC PAGE_KERNEL
 #endif
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
