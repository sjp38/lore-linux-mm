Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1988E00E5
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 19:12:11 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id u20so14031288pfa.1
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 16:12:11 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u7si14323549pfu.270.2018.12.11.16.12.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 16:12:09 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 1/4] vmalloc: New flags for safe vfree on special perms
Date: Tue, 11 Dec 2018 16:03:51 -0800
Message-Id: <20181212000354.31955-2-rick.p.edgecombe@intel.com>
In-Reply-To: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, luto@kernel.org, will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, mhiramat@kernel.org, rostedt@goodmis.org, mingo@redhat.com, ast@kernel.org, daniel@iogearbox.net, jeyu@kernel.org, namit@vmware.com, netdev@vger.kernel.org, ard.biesheuvel@linaro.org, jannh@google.com
Cc: kristen@linux.intel.com, dave.hansen@intel.com, deneen.t.dock@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

This adds two new flags VM_IMMEDIATE_UNMAP and VM_HAS_SPECIAL_PERMS, for
enabling vfree operations to immediately clear executable TLB entries to freed
pages, and handle freeing memory with special permissions.

In order to support vfree being called on memory that might be RO, the vfree
deferred list node is moved to a kmalloc allocated struct, from where it is
today, reusing the allocation being freed.

arch_vunmap is a new __weak function that implements the actual unmapping and
resetting of the direct map permissions. It can be overridden by more efficient
architecture specific implementations.

For the default implementation, it uses architecture agnostic methods which are
equivalent to what most usages do before calling vfree. So now it is just
centralized here.

This implementation derives from two sketches from Dave Hansen and Andy
Lutomirski.

Suggested-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Andy Lutomirski <luto@kernel.org>
Suggested-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/vmalloc.h |  2 ++
 mm/vmalloc.c            | 73 +++++++++++++++++++++++++++++++++++++----
 2 files changed, 69 insertions(+), 6 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..872bcde17aca 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -21,6 +21,8 @@ struct notifier_block;		/* in notifier.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
+#define VM_IMMEDIATE_UNMAP	0x00000200	/* flush before releasing pages */
+#define VM_HAS_SPECIAL_PERMS	0x00000400	/* may be freed with special perms */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 97d4b25d0373..02b284d2245a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -18,6 +18,7 @@
 #include <linux/interrupt.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <linux/set_memory.h>
 #include <linux/debugobjects.h>
 #include <linux/kallsyms.h>
 #include <linux/list.h>
@@ -38,6 +39,11 @@
 
 #include "internal.h"
 
+struct vfree_work {
+	struct llist_node node;
+	void *addr;
+};
+
 struct vfree_deferred {
 	struct llist_head list;
 	struct work_struct wq;
@@ -50,9 +56,13 @@ static void free_work(struct work_struct *w)
 {
 	struct vfree_deferred *p = container_of(w, struct vfree_deferred, wq);
 	struct llist_node *t, *llnode;
+	struct vfree_work *cur;
 
-	llist_for_each_safe(llnode, t, llist_del_all(&p->list))
-		__vunmap((void *)llnode, 1);
+	llist_for_each_safe(llnode, t, llist_del_all(&p->list)) {
+		cur = container_of(llnode, struct vfree_work, node);
+		__vunmap(cur->addr, 1);
+		kfree(cur);
+	}
 }
 
 /*** Page table manipulation functions ***/
@@ -1494,6 +1504,48 @@ struct vm_struct *remove_vm_area(const void *addr)
 	return NULL;
 }
 
+/*
+ * This function handles unmapping and resetting the direct map as efficiently
+ * as it can with cross arch functions. The three categories of architectures
+ * are:
+ *   1. Architectures with no set_memory implementations and no direct map
+ *      permissions.
+ *   2. Architectures with set_memory implementations but no direct map
+ *      permissions
+ *   3. Architectures with set_memory implementations and direct map permissions
+ */
+void __weak arch_vunmap(struct vm_struct *area, int deallocate_pages)
+{
+	unsigned long addr = (unsigned long)area->addr;
+	int immediate = area->flags & VM_IMMEDIATE_UNMAP;
+	int special = area->flags & VM_HAS_SPECIAL_PERMS;
+
+	/*
+	 * In case of 2 and 3, use this general way of resetting the permissions
+	 * on the directmap. Do NX before RW, in case of X, so there is no W^X
+	 * violation window.
+	 *
+	 * For case 1 these will be noops.
+	 */
+	if (immediate)
+		set_memory_nx(addr, area->nr_pages);
+	if (deallocate_pages && special)
+		set_memory_rw(addr, area->nr_pages);
+
+	/* Always actually remove the area */
+	remove_vm_area(area->addr);
+
+	/*
+	 * Need to flush the TLB before freeing pages in the case of this flag.
+	 * As long as that's happening, unmap aliases.
+	 *
+	 * For 2 and 3, this will not be needed because of the set_memory_nx
+	 * above, because the stale TLBs will be NX.
+	 */
+	if (immediate && !IS_ENABLED(ARCH_HAS_SET_MEMORY))
+		vm_unmap_aliases();
+}
+
 static void __vunmap(const void *addr, int deallocate_pages)
 {
 	struct vm_struct *area;
@@ -1515,7 +1567,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
 	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
-	remove_vm_area(addr);
+	arch_vunmap(area, deallocate_pages);
+
 	if (deallocate_pages) {
 		int i;
 
@@ -1542,8 +1595,15 @@ static inline void __vfree_deferred(const void *addr)
 	 * nother cpu's list.  schedule_work() should be fine with this too.
 	 */
 	struct vfree_deferred *p = raw_cpu_ptr(&vfree_deferred);
+	struct vfree_work *w = kmalloc(sizeof(struct vfree_work), GFP_ATOMIC);
+
+	/* If no memory for the deferred list node, give up */
+	if (!w)
+		return;
 
-	if (llist_add((struct llist_node *)addr, &p->list))
+	w->addr = (void *)addr;
+
+	if (llist_add(&w->node, &p->list))
 		schedule_work(&p->wq);
 }
 
@@ -1925,8 +1985,9 @@ EXPORT_SYMBOL(vzalloc_node);
 
 void *vmalloc_exec(unsigned long size)
 {
-	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL_EXEC,
-			      NUMA_NO_NODE, __builtin_return_address(0));
+	return __vmalloc_node_range(size, 1, VMALLOC_START, VMALLOC_END,
+			GFP_KERNEL, PAGE_KERNEL_EXEC, VM_IMMEDIATE_UNMAP,
+			NUMA_NO_NODE, __builtin_return_address(0));
 }
 
 #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
-- 
2.17.1
