Date: Fri, 18 Aug 2006 21:14:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Extract the allocpercpu functions from the slab allocator
Message-ID: <Pine.LNX.4.64.0608182108400.3097@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The allocpercpu functions __alloc_percpu and __free_percpu() are heavily 
using the slab allocator. However, they are conceptually different 
allocators that can be used independently from the slab. Currently the 
slab code is duplicated in slob. This patch also 
simplifies SLOB.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4/mm/allocpercpu.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.18-rc4/mm/allocpercpu.c	2006-08-18 20:57:49.812228291 -0700
@@ -0,0 +1,76 @@
+/*
+ * linux/mm/allocpercpu.c
+ *
+ * From slab.c August,2006 Christoph Lameter <clameter@sgi.com>
+ */
+#include <linux/mm.h>
+#include <linux/module.h>
+
+/**
+ * __alloc_percpu - allocate one copy of the object for every present
+ * cpu in the system, zeroing them.
+ * Objects should be dereferenced using the per_cpu_ptr macro only.
+ *
+ * @size: how many bytes of memory are required.
+ */
+void *__alloc_percpu(size_t size)
+{
+	int i;
+	struct percpu_data *pdata = kmalloc(sizeof(*pdata), GFP_KERNEL);
+
+	if (!pdata)
+		return NULL;
+
+	/*
+	 * Cannot use for_each_online_cpu since a cpu may come online
+	 * and we have no way of figuring out how to fix the array
+	 * that we have allocated then....
+	 */
+	for_each_possible_cpu(i) {
+		int node = cpu_to_node(i);
+
+		if (node_online(node))
+			pdata->ptrs[i] = kmalloc_node(size, GFP_KERNEL, node);
+		else
+			pdata->ptrs[i] = kmalloc(size, GFP_KERNEL);
+
+		if (!pdata->ptrs[i])
+			goto unwind_oom;
+		memset(pdata->ptrs[i], 0, size);
+	}
+
+	/* Catch derefs w/o wrappers */
+	return (void *)(~(unsigned long)pdata);
+
+unwind_oom:
+	while (--i >= 0) {
+		if (!cpu_possible(i))
+			continue;
+		kfree(pdata->ptrs[i]);
+	}
+	kfree(pdata);
+	return NULL;
+}
+EXPORT_SYMBOL(__alloc_percpu);
+
+/**
+ * free_percpu - free previously allocated percpu memory
+ * @objp: pointer returned by alloc_percpu.
+ *
+ * Don't free memory not originally allocated by alloc_percpu()
+ * The complemented objp is to check for that.
+ */
+void free_percpu(const void *objp)
+{
+	int i;
+	struct percpu_data *p = (struct percpu_data *)(~(unsigned long)objp);
+
+	/*
+	 * We allocate for all cpus so we cannot use for online cpu here.
+	 */
+	for_each_possible_cpu(i)
+	    kfree(p->ptrs[i]);
+	kfree(p);
+}
+EXPORT_SYMBOL(free_percpu);
+
Index: linux-2.6.18-rc4/mm/Makefile
===================================================================
--- linux-2.6.18-rc4.orig/mm/Makefile	2006-08-06 11:20:11.000000000 -0700
+++ linux-2.6.18-rc4/mm/Makefile	2006-08-18 20:57:49.844452865 -0700
@@ -13,6 +13,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   prio_tree.o util.o mmzone.o vmstat.o $(mmu-y)
 
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_SMP)	+= allocpercpu.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
Index: linux-2.6.18-rc4/mm/slab.c
===================================================================
--- linux-2.6.18-rc4.orig/mm/slab.c	2006-08-06 11:20:11.000000000 -0700
+++ linux-2.6.18-rc4/mm/slab.c	2006-08-18 20:57:49.858123897 -0700
@@ -3370,55 +3370,6 @@ void *__kmalloc_track_caller(size_t size
 EXPORT_SYMBOL(__kmalloc_track_caller);
 #endif
 
-#ifdef CONFIG_SMP
-/**
- * __alloc_percpu - allocate one copy of the object for every present
- * cpu in the system, zeroing them.
- * Objects should be dereferenced using the per_cpu_ptr macro only.
- *
- * @size: how many bytes of memory are required.
- */
-void *__alloc_percpu(size_t size)
-{
-	int i;
-	struct percpu_data *pdata = kmalloc(sizeof(*pdata), GFP_KERNEL);
-
-	if (!pdata)
-		return NULL;
-
-	/*
-	 * Cannot use for_each_online_cpu since a cpu may come online
-	 * and we have no way of figuring out how to fix the array
-	 * that we have allocated then....
-	 */
-	for_each_possible_cpu(i) {
-		int node = cpu_to_node(i);
-
-		if (node_online(node))
-			pdata->ptrs[i] = kmalloc_node(size, GFP_KERNEL, node);
-		else
-			pdata->ptrs[i] = kmalloc(size, GFP_KERNEL);
-
-		if (!pdata->ptrs[i])
-			goto unwind_oom;
-		memset(pdata->ptrs[i], 0, size);
-	}
-
-	/* Catch derefs w/o wrappers */
-	return (void *)(~(unsigned long)pdata);
-
-unwind_oom:
-	while (--i >= 0) {
-		if (!cpu_possible(i))
-			continue;
-		kfree(pdata->ptrs[i]);
-	}
-	kfree(pdata);
-	return NULL;
-}
-EXPORT_SYMBOL(__alloc_percpu);
-#endif
-
 /**
  * kmem_cache_free - Deallocate an object
  * @cachep: The cache the allocation was from.
@@ -3464,29 +3415,6 @@ void kfree(const void *objp)
 }
 EXPORT_SYMBOL(kfree);
 
-#ifdef CONFIG_SMP
-/**
- * free_percpu - free previously allocated percpu memory
- * @objp: pointer returned by alloc_percpu.
- *
- * Don't free memory not originally allocated by alloc_percpu()
- * The complemented objp is to check for that.
- */
-void free_percpu(const void *objp)
-{
-	int i;
-	struct percpu_data *p = (struct percpu_data *)(~(unsigned long)objp);
-
-	/*
-	 * We allocate for all cpus so we cannot use for online cpu here.
-	 */
-	for_each_possible_cpu(i)
-	    kfree(p->ptrs[i]);
-	kfree(p);
-}
-EXPORT_SYMBOL(free_percpu);
-#endif
-
 unsigned int kmem_cache_size(struct kmem_cache *cachep)
 {
 	return obj_size(cachep);
Index: linux-2.6.18-rc4/mm/slob.c
===================================================================
--- linux-2.6.18-rc4.orig/mm/slob.c	2006-08-06 11:20:11.000000000 -0700
+++ linux-2.6.18-rc4/mm/slob.c	2006-08-18 20:57:49.859100399 -0700
@@ -343,48 +343,3 @@ void kmem_cache_init(void)
 atomic_t slab_reclaim_pages = ATOMIC_INIT(0);
 EXPORT_SYMBOL(slab_reclaim_pages);
 
-#ifdef CONFIG_SMP
-
-void *__alloc_percpu(size_t size)
-{
-	int i;
-	struct percpu_data *pdata = kmalloc(sizeof (*pdata), GFP_KERNEL);
-
-	if (!pdata)
-		return NULL;
-
-	for_each_possible_cpu(i) {
-		pdata->ptrs[i] = kmalloc(size, GFP_KERNEL);
-		if (!pdata->ptrs[i])
-			goto unwind_oom;
-		memset(pdata->ptrs[i], 0, size);
-	}
-
-	/* Catch derefs w/o wrappers */
-	return (void *) (~(unsigned long) pdata);
-
-unwind_oom:
-	while (--i >= 0) {
-		if (!cpu_possible(i))
-			continue;
-		kfree(pdata->ptrs[i]);
-	}
-	kfree(pdata);
-	return NULL;
-}
-EXPORT_SYMBOL(__alloc_percpu);
-
-void
-free_percpu(const void *objp)
-{
-	int i;
-	struct percpu_data *p = (struct percpu_data *) (~(unsigned long) objp);
-
-	for_each_possible_cpu(i)
-		kfree(p->ptrs[i]);
-
-	kfree(p);
-}
-EXPORT_SYMBOL(free_percpu);
-
-#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
