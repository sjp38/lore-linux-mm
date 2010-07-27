Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5FC61600044
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 03:57:39 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6R7vm6Y006321
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Jul 2010 16:57:48 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CBF5D45DD6E
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:57:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B09E145DE4E
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:57:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 923781DB8012
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:57:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 22C671DB8013
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:57:47 +0900 (JST)
Date: Tue, 27 Jul 2010 16:53:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/7][memcg] virtually indexed array library.
Message-Id: <20100727165303.7d7d18e9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This virt-array allocates a virtally contiguous array via get_vm_area()
and allows object allocation per an element of array.
Physical pages are used only for used items in the array.

 - At first, the user has to create an array by create_virt_array().
 - At using an element, virt_array_alloc_index(index) should be called.
 - At freeing an element, virt_array_free_index(index) should be called.
 - At destroying, destroy_virt_array() should be called.

Item used/unused status is controlled by bitmap and back-end physical
pages are automatically allocated/freed. This is useful when you
want to access objects by index in light weight. For example,

	create_virt_array(va);
	struct your_struct *objmap = va->address;
	Then, you can access your objects by objmap[i].

In usual case, holding reference by index rather than pointer can save memory.
But index -> object lookup cost cannot be negligible. In such case,
this virt-array may be helpful. Ah yes, if lookup performance is not important,
using radix-tree will be better (from TLB point of view). This virty-array
may consume VMALLOC area too much. and alloc/free routine is very slow.

Changelog:
 - fixed bugs in bitmap ops.
 - add offset for find_free_index.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/virt-array.h |   22 ++++
 lib/Makefile               |    2 
 lib/virt-array.c           |  227 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 250 insertions(+), 1 deletion(-)

Index: mmotm-0719/lib/Makefile
===================================================================
--- mmotm-0719.orig/lib/Makefile
+++ mmotm-0719/lib/Makefile
@@ -14,7 +14,7 @@ lib-y := ctype.o string.o vsprintf.o cmd
 	 proportions.o prio_heap.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o flex_array.o
 
-lib-$(CONFIG_MMU) += ioremap.o
+lib-$(CONFIG_MMU) += ioremap.o virt-array.o
 lib-$(CONFIG_SMP) += cpumask.o
 
 lib-y	+= kobject.o kref.o klist.o
Index: mmotm-0719/lib/virt-array.c
===================================================================
--- /dev/null
+++ mmotm-0719/lib/virt-array.c
@@ -0,0 +1,227 @@
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+#include <linux/slab.h>
+#include <linux/virt-array.h>
+#include <asm/cacheflush.h>
+
+
+/*
+ * Why define this here is because this function should be
+ * defined by user for getting better code. This generic one is slow
+ * because the compiler cannot know what the "size" is.
+ */
+static unsigned long idx_to_addr(struct virt_array *v, int idx)
+{
+	return (unsigned long)v->vm_area->addr + idx * v->size;
+}
+
+static unsigned long addr_index(struct virt_array *v, unsigned long addr)
+{
+	return (addr - (unsigned long)v->vm_area->addr) >> PAGE_SHIFT;
+}
+
+static int idx_used(const struct virt_array *v, int idx)
+{
+	return test_bit(idx, v->map);
+}
+
+static void unmap_free_page(struct virt_array *v, unsigned long page)
+{
+	struct page *pg;
+	unsigned long page_idx;
+
+	page_idx = addr_index(v, page);
+	/* alloc_idx's undo routine may find !pg */
+	pg = radix_tree_delete(&v->phys_pages, page_idx);
+	if (!pg)
+		return;
+	unmap_kernel_range(page, PAGE_SIZE);
+	__free_page(pg);
+
+}
+
+static void __free_head_page(struct virt_array *v, int idx)
+{
+	int i;
+	unsigned long page;
+
+	page = idx_to_addr(v, idx) & PAGE_MASK;
+
+	/* check backword */
+	for (i = idx - 1; i >= 0; i--) {
+		unsigned long address = idx_to_addr(v, i) + v->size - 1;
+		if ((address & PAGE_MASK) != page)
+			break;
+		/* A used object shares this page ? */
+		if (idx_used(v, i))
+			return;
+	}
+	unmap_free_page(v, page);
+}
+
+
+static void __free_middle_page(struct virt_array *v, int idx)
+{
+	unsigned long page, end_page;
+
+	page = (idx_to_addr(v, idx)) & PAGE_MASK;
+	end_page = (idx_to_addr(v, idx) + v->size) & PAGE_MASK;
+	if (end_page - page <= PAGE_SIZE)
+		return;
+	/* free all pages between head and tail */
+	for (page += PAGE_SIZE; page != end_page; page += PAGE_SIZE)
+		unmap_free_page(v, page);
+}
+
+
+static void __free_tail_page(struct virt_array *v, int idx)
+{
+	int i;
+	unsigned long page;
+
+	page = (idx_to_addr(v, idx) + v->size) & PAGE_MASK;
+	/* check forword */
+	for (i = idx + 1; i < v->nelem ; i++) {
+		unsigned long address = idx_to_addr(v, i);
+		if ((address & PAGE_MASK) != page)
+			break;
+		/* A used object shares this page ? */
+		if (idx_used(v, i))
+			return;
+	}
+	/* we can free this page */
+	unmap_free_page(v, page);
+}
+
+static void __free_this_page(struct virt_array *v, int idx, unsigned long page)
+{
+	int i;
+
+	/* check backword */
+	for (i = idx - 1; i >= 0; i--) {
+		unsigned long address = idx_to_addr(v, i) + v->size - 1;
+		if ((address & PAGE_MASK) != page)
+			break;
+		/* A used object shares this page ? */
+		if (idx_used(v, i))
+			return;
+	}
+	/* check forward */
+	for (i = idx + 1; i < v->nelem; i++) {
+		unsigned long address = idx_to_addr(v, i);
+		if ((address & PAGE_MASK) != page)
+			break;
+		/* A used object shares this page ? */
+		if (idx_used(v, i))
+			return;
+	}
+	/* we can free this page */
+	unmap_free_page(v, page);
+}
+
+static void __free_unmap_entry(struct virt_array *v, int idx)
+{
+	unsigned long address, end;
+
+	address = idx_to_addr(v, idx);
+	end = address + v->size;
+	if ((address & PAGE_MASK) == (end & PAGE_MASK)) {
+		__free_this_page(v, idx, address & PAGE_MASK);
+	} else {
+		__free_head_page(v, idx);
+		__free_middle_page(v, idx);
+		__free_tail_page(v, idx);
+	}
+	clear_bit(idx, v->map);
+}
+
+void free_varray_item(struct virt_array *v, int idx)
+{
+	mutex_lock(&v->mutex);
+	__free_unmap_entry(v, idx);
+	mutex_unlock(&v->mutex);
+}
+
+void *alloc_varray_item(struct virt_array *v, int idx)
+{
+	unsigned long obj, tmp, start, end, addr_idx;
+	struct page *pg[1];
+	void *ret = ERR_PTR(-EBUSY);
+
+	mutex_lock(&v->mutex);
+	if (idx_used(v, idx))
+		goto out;
+
+	obj = idx_to_addr(v, idx);
+	start = obj & PAGE_MASK;
+	end = PAGE_ALIGN(obj + v->size);
+
+	for (tmp = start; tmp < end; tmp+=PAGE_SIZE) {
+		addr_idx = addr_index(v, tmp);
+		pg[0] = radix_tree_lookup(&v->phys_pages, addr_idx);
+		if (pg[0])
+			continue;
+		pg[0] = alloc_page(GFP_KERNEL);
+		if (map_kernel_range_noflush(tmp, PAGE_SIZE,
+			PAGE_KERNEL, pg) == -ENOMEM) {
+				__free_page(pg[0]);
+				goto out_unmap;
+		}
+
+		radix_tree_preload(GFP_KERNEL);
+		if (radix_tree_insert(&v->phys_pages, addr_idx, pg[0])) {
+			BUG();
+		}
+		radix_tree_preload_end();
+	}
+	flush_cache_vmap(start, end);
+	ret = (void *)obj;
+	set_bit(idx, v->map);
+out:
+	mutex_unlock(&v->mutex);
+	return ret;
+out_unmap:
+	ret = ERR_PTR(-ENOMEM);
+	__free_unmap_entry(v, idx);
+	goto out;
+}
+
+void *create_varray(struct virt_array *v,int size, int nelem)
+{
+	unsigned long total = size * nelem;
+	unsigned long bits;
+
+	bits = ((nelem/BITS_PER_LONG)+1) * sizeof(long);
+	v->map = kzalloc(bits, GFP_KERNEL);
+	if (!v->map)
+		return NULL;
+	total = PAGE_ALIGN(total);
+	v->vm_area = get_vm_area(total, 0);
+	if (!v->vm_area) {
+		kfree(v->map);
+		return NULL;
+	}
+
+	v->size = size;
+	v->nelem = nelem;
+	INIT_RADIX_TREE(&v->phys_pages, GFP_KERNEL);
+	mutex_init(&v->mutex);
+	return v->vm_area->addr;
+}
+
+void destroy_varray(struct virt_array *v)
+{
+	int i;
+
+	for_each_set_bit(i, v->map, v->nelem)
+		__free_unmap_entry(v, i);
+	kfree(v->map);
+	free_vm_area(v->vm_area);
+	return;
+}
+
+int varray_find_free_index(struct virt_array *v, int base)
+{
+	return find_next_zero_bit(v->map, v->nelem, base);
+}
+
Index: mmotm-0719/include/linux/virt-array.h
===================================================================
--- /dev/null
+++ mmotm-0719/include/linux/virt-array.h
@@ -0,0 +1,22 @@
+#ifndef __LINUX_VIRTARRAY_H
+#define __LINUX_VIRTARRAY_H
+
+#include <linux/vmalloc.h>
+#include <linux/radix-tree.h>
+
+struct virt_array {
+	struct vm_struct *vm_area;
+	int size;
+	int nelem;
+	struct mutex mutex;
+	struct radix_tree_root phys_pages;
+	unsigned long *map;
+};
+
+void *create_varray(struct virt_array *va, int size, int nelems);
+void *alloc_varray_item(struct virt_array *va, int index);
+void free_varray_item(struct virt_array *va, int index);
+void destroy_varray(struct virt_array *va);
+int varray_find_free_index(struct virt_array *va, int base);
+
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
