Date: Wed, 23 Aug 2006 12:39:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Extract the allocpercpu functions from the slab allocator
In-Reply-To: <20060818232905.8fdacad4.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0608231238170.30842@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608182108400.3097@schroedinger.engr.sgi.com>
 <20060818232905.8fdacad4.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Aug 2006, Andrew Morton wrote:

> On Fri, 18 Aug 2006 21:14:06 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > The allocpercpu functions __alloc_percpu and __free_percpu() are heavily 
> > using the slab allocator.
> 
> These functions don't exist since cpu-hotplug-compatible-alloc_percpu.patch.
> 
> Can you please see whether this cleanup is applicable to -mm?

Here is the earlier patch for 2.6.18-rc4-mm2:


Separate the allocpercpu functions from the slab allocator

The allocpercpu functions __alloc_percpu and __free_percpu() are
heavily using the slab allocator. However, they are conceptually
different allocators that can be used independently from the
slab. This also simplifies SLOB (at this point slob may
be broken in mm. This should fix it).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4-mm2/mm/allocpercpu.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.18-rc4-mm2/mm/allocpercpu.c	2006-08-23 12:32:06.928511026 -0700
@@ -0,0 +1,130 @@
+/*
+ * linux/mm/allocpercpu.c
+ *
+ * Separated out from slab.c August 11, 2006 Christoph Lameter <clameter@sgi.com>
+ */
+#include <linux/mm.h>
+#include <linux/module.h>
+
+/**
+ * percpu_depopulate - depopulate per-cpu data for given cpu
+ * @__pdata: per-cpu data to depopulate
+ * @cpu: depopulate per-cpu data for this cpu
+ *
+ * Depopulating per-cpu data for a cpu going offline would be a typical
+ * use case. You need to register a cpu hotplug handler for that purpose.
+ */
+void percpu_depopulate(void *__pdata, int cpu)
+{
+	struct percpu_data *pdata = __percpu_disguise(__pdata);
+	if (pdata->ptrs[cpu]) {
+		kfree(pdata->ptrs[cpu]);
+		pdata->ptrs[cpu] = NULL;
+	}
+}
+EXPORT_SYMBOL_GPL(percpu_depopulate);
+
+/**
+ * percpu_depopulate_mask - depopulate per-cpu data for some cpu's
+ * @__pdata: per-cpu data to depopulate
+ * @mask: depopulate per-cpu data for cpu's selected through mask bits
+ */
+void __percpu_depopulate_mask(void *__pdata, cpumask_t *mask)
+{
+	int cpu;
+	for_each_cpu_mask(cpu, *mask)
+		percpu_depopulate(__pdata, cpu);
+}
+EXPORT_SYMBOL_GPL(__percpu_depopulate_mask);
+
+/**
+ * percpu_populate - populate per-cpu data for given cpu
+ * @__pdata: per-cpu data to populate further
+ * @size: size of per-cpu object
+ * @gfp: may sleep or not etc.
+ * @cpu: populate per-data for this cpu
+ *
+ * Populating per-cpu data for a cpu coming online would be a typical
+ * use case. You need to register a cpu hotplug handler for that purpose.
+ * Per-cpu object is populated with zeroed buffer.
+ */
+void *percpu_populate(void *__pdata, size_t size, gfp_t gfp, int cpu)
+{
+	struct percpu_data *pdata = __percpu_disguise(__pdata);
+	int node = cpu_to_node(cpu);
+
+	BUG_ON(pdata->ptrs[cpu]);
+	if (node_online(node)) {
+		/* FIXME: kzalloc_node(size, gfp, node) */
+		pdata->ptrs[cpu] = kmalloc_node(size, gfp, node);
+		if (pdata->ptrs[cpu])
+			memset(pdata->ptrs[cpu], 0, size);
+	} else
+		pdata->ptrs[cpu] = kzalloc(size, gfp);
+	return pdata->ptrs[cpu];
+}
+EXPORT_SYMBOL_GPL(percpu_populate);
+
+/**
+ * percpu_populate_mask - populate per-cpu data for more cpu's
+ * @__pdata: per-cpu data to populate further
+ * @size: size of per-cpu object
+ * @gfp: may sleep or not etc.
+ * @mask: populate per-cpu data for cpu's selected through mask bits
+ *
+ * Per-cpu objects are populated with zeroed buffers.
+ */
+int __percpu_populate_mask(void *__pdata, size_t size, gfp_t gfp,
+			   cpumask_t *mask)
+{
+	cpumask_t populated = CPU_MASK_NONE;
+	int cpu;
+
+	for_each_cpu_mask(cpu, *mask)
+		if (unlikely(!percpu_populate(__pdata, size, gfp, cpu))) {
+			__percpu_depopulate_mask(__pdata, &populated);
+			return -ENOMEM;
+		} else
+			cpu_set(cpu, populated);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__percpu_populate_mask);
+
+/**
+ * percpu_alloc_mask - initial setup of per-cpu data
+ * @size: size of per-cpu object
+ * @gfp: may sleep or not etc.
+ * @mask: populate per-data for cpu's selected through mask bits
+ *
+ * Populating per-cpu data for all online cpu's would be a typical use case,
+ * which is simplified by the percpu_alloc() wrapper.
+ * Per-cpu objects are populated with zeroed buffers.
+ */
+void *__percpu_alloc_mask(size_t size, gfp_t gfp, cpumask_t *mask)
+{
+	void *pdata = kzalloc(sizeof(struct percpu_data), gfp);
+	void *__pdata = __percpu_disguise(pdata);
+
+	if (unlikely(!pdata))
+		return NULL;
+	if (likely(!__percpu_populate_mask(__pdata, size, gfp, mask)))
+		return __pdata;
+	kfree(pdata);
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(__percpu_alloc_mask);
+
+/**
+ * percpu_free - final cleanup of per-cpu data
+ * @__pdata: object to clean up
+ *
+ * We simply clean up any per-cpu object left. No need for the client to
+ * track and specify through a bis mask which per-cpu objects are to free.
+ */
+void percpu_free(void *__pdata)
+{
+	__percpu_depopulate_mask(__pdata, &cpu_possible_map);
+	kfree(__percpu_disguise(__pdata));
+}
+EXPORT_SYMBOL_GPL(percpu_free);
+
Index: linux-2.6.18-rc4-mm2/mm/slab.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/slab.c	2006-08-20 16:17:35.371551737 -0700
+++ linux-2.6.18-rc4-mm2/mm/slab.c	2006-08-23 12:16:44.728638839 -0700
@@ -3464,130 +3464,6 @@ void *__kmalloc_track_caller(size_t size
 EXPORT_SYMBOL(__kmalloc_track_caller);
 #endif
 
-#ifdef CONFIG_SMP
-/**
- * percpu_depopulate - depopulate per-cpu data for given cpu
- * @__pdata: per-cpu data to depopulate
- * @cpu: depopulate per-cpu data for this cpu
- *
- * Depopulating per-cpu data for a cpu going offline would be a typical
- * use case. You need to register a cpu hotplug handler for that purpose.
- */
-void percpu_depopulate(void *__pdata, int cpu)
-{
-	struct percpu_data *pdata = __percpu_disguise(__pdata);
-	if (pdata->ptrs[cpu]) {
-		kfree(pdata->ptrs[cpu]);
-		pdata->ptrs[cpu] = NULL;
-	}
-}
-EXPORT_SYMBOL_GPL(percpu_depopulate);
-
-/**
- * percpu_depopulate_mask - depopulate per-cpu data for some cpu's
- * @__pdata: per-cpu data to depopulate
- * @mask: depopulate per-cpu data for cpu's selected through mask bits
- */
-void __percpu_depopulate_mask(void *__pdata, cpumask_t *mask)
-{
-	int cpu;
-	for_each_cpu_mask(cpu, *mask)
-		percpu_depopulate(__pdata, cpu);
-}
-EXPORT_SYMBOL_GPL(__percpu_depopulate_mask);
-
-/**
- * percpu_populate - populate per-cpu data for given cpu
- * @__pdata: per-cpu data to populate further
- * @size: size of per-cpu object
- * @gfp: may sleep or not etc.
- * @cpu: populate per-data for this cpu
- *
- * Populating per-cpu data for a cpu coming online would be a typical
- * use case. You need to register a cpu hotplug handler for that purpose.
- * Per-cpu object is populated with zeroed buffer.
- */
-void *percpu_populate(void *__pdata, size_t size, gfp_t gfp, int cpu)
-{
-	struct percpu_data *pdata = __percpu_disguise(__pdata);
-	int node = cpu_to_node(cpu);
-
-	BUG_ON(pdata->ptrs[cpu]);
-	if (node_online(node)) {
-		/* FIXME: kzalloc_node(size, gfp, node) */
-		pdata->ptrs[cpu] = kmalloc_node(size, gfp, node);
-		if (pdata->ptrs[cpu])
-			memset(pdata->ptrs[cpu], 0, size);
-	} else
-		pdata->ptrs[cpu] = kzalloc(size, gfp);
-	return pdata->ptrs[cpu];
-}
-EXPORT_SYMBOL_GPL(percpu_populate);
-
-/**
- * percpu_populate_mask - populate per-cpu data for more cpu's
- * @__pdata: per-cpu data to populate further
- * @size: size of per-cpu object
- * @gfp: may sleep or not etc.
- * @mask: populate per-cpu data for cpu's selected through mask bits
- *
- * Per-cpu objects are populated with zeroed buffers.
- */
-int __percpu_populate_mask(void *__pdata, size_t size, gfp_t gfp,
-			   cpumask_t *mask)
-{
-	cpumask_t populated = CPU_MASK_NONE;
-	int cpu;
-
-	for_each_cpu_mask(cpu, *mask)
-		if (unlikely(!percpu_populate(__pdata, size, gfp, cpu))) {
-			__percpu_depopulate_mask(__pdata, &populated);
-			return -ENOMEM;
-		} else
-			cpu_set(cpu, populated);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(__percpu_populate_mask);
-
-/**
- * percpu_alloc_mask - initial setup of per-cpu data
- * @size: size of per-cpu object
- * @gfp: may sleep or not etc.
- * @mask: populate per-data for cpu's selected through mask bits
- *
- * Populating per-cpu data for all online cpu's would be a typical use case,
- * which is simplified by the percpu_alloc() wrapper.
- * Per-cpu objects are populated with zeroed buffers.
- */
-void *__percpu_alloc_mask(size_t size, gfp_t gfp, cpumask_t *mask)
-{
-	void *pdata = kzalloc(sizeof(struct percpu_data), gfp);
-	void *__pdata = __percpu_disguise(pdata);
-
-	if (unlikely(!pdata))
-		return NULL;
-	if (likely(!__percpu_populate_mask(__pdata, size, gfp, mask)))
-		return __pdata;
-	kfree(pdata);
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(__percpu_alloc_mask);
-
-/**
- * percpu_free - final cleanup of per-cpu data
- * @__pdata: object to clean up
- *
- * We simply clean up any per-cpu object left. No need for the client to
- * track and specify through a bis mask which per-cpu objects are to free.
- */
-void percpu_free(void *__pdata)
-{
-	__percpu_depopulate_mask(__pdata, &cpu_possible_map);
-	kfree(__percpu_disguise(__pdata));
-}
-EXPORT_SYMBOL_GPL(percpu_free);
-#endif	/* CONFIG_SMP */
-
 /**
  * kmem_cache_free - Deallocate an object
  * @cachep: The cache the allocation was from.
Index: linux-2.6.18-rc4-mm2/mm/slob.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/slob.c	2006-08-06 11:20:11.000000000 -0700
+++ linux-2.6.18-rc4-mm2/mm/slob.c	2006-08-23 12:15:47.263435113 -0700
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
Index: linux-2.6.18-rc4-mm2/mm/Makefile
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/Makefile	2006-08-20 16:17:35.290502052 -0700
+++ linux-2.6.18-rc4-mm2/mm/Makefile	2006-08-23 12:31:02.784040263 -0700
@@ -24,4 +24,5 @@ obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
+obj-$(CONFIG_SMP) += allocpercpu.o
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
