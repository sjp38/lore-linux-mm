Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id EEEEB8E000B
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 19:33:39 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id o23so4967216pll.0
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:33:39 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id m3si7883258pld.331.2019.01.16.16.33.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 16:33:37 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 15/17] vmalloc: New flags for safe vfree on special perms
Date: Wed, 16 Jan 2019 16:32:57 -0800
Message-Id: <20190117003259.23141-16-rick.p.edgecombe@intel.com>
In-Reply-To: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

This adds a new flags VM_HAS_SPECIAL_PERMS, for enabling vfree operations to
immediately clear executable TLB entries to freed pages, and handle freeing
memory with special permissions. It also takes care of reseting the direct map
permissions for the pages being unmapped. So this flag is useful for any kind
of memory with elevated permissions, or where there can be related permissions
changes on the directmap. Today this is RO+X and RO memory.

Although this enables directly vfreeing RO memory now, RO memory cannot be
freed in an interrupt because the allocation itself is used as a node on
deferred free list. So when RO memory needs to be freed in an interrupt the
code doing the vfree needs to have its own work queue, as was the case before
the deferred vfree list handling was added. Today there is only one case where
this happens.

For architectures with set_alias_ implementations this whole operation can be
done with one TLB flush when centralized like this. For others with directmap
permissions, currently only arm64, a backup method using set_memory functions
is used to reset the directmap. When arm64 adds set_alias_ functions, this
backup can be removed.

When the TLB is flushed to both remove TLB entries for the vmalloc range
mapping and the direct map permissions, the lazy purge operation could be done
to try to save a TLB flush later. However today vm_unmap_aliases could flush a
TLB range that does not include the directmap. So a helper is added with extra
parameters that can allow both the vmalloc address and the direct mapping to be
flushed during this operation. The behavior of the normal vm_unmap_aliases
function is unchanged.

Suggested-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Andy Lutomirski <luto@kernel.org>
Suggested-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/vmalloc.h |  13 +++++
 mm/vmalloc.c            | 122 +++++++++++++++++++++++++++++++++-------
 2 files changed, 116 insertions(+), 19 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..9f643f917360 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -21,6 +21,11 @@ struct notifier_block;		/* in notifier.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
+/*
+ * Memory with VM_HAS_SPECIAL_PERMS cannot be freed in an interrupt or with
+ * vfree_atomic.
+ */
+#define VM_HAS_SPECIAL_PERMS	0x00000200      /* Reset directmap and flush TLB on unmap */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
@@ -135,6 +140,14 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
 extern struct vm_struct *remove_vm_area(const void *addr);
 extern struct vm_struct *find_vm_area(const void *addr);
 
+static inline void set_vm_special(void *addr)
+{
+	struct vm_struct *vm = find_vm_area(addr);
+
+	if (vm)
+		vm->flags |= VM_HAS_SPECIAL_PERMS;
+}
+
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
 			struct page **pages);
 #ifdef CONFIG_MMU
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 871e41c55e23..d459b5b9649b 100644
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
@@ -1055,24 +1056,11 @@ static void vb_free(const void *addr, unsigned long size)
 		spin_unlock(&vb->lock);
 }
 
-/**
- * vm_unmap_aliases - unmap outstanding lazy aliases in the vmap layer
- *
- * The vmap/vmalloc layer lazily flushes kernel virtual mappings primarily
- * to amortize TLB flushing overheads. What this means is that any page you
- * have now, may, in a former life, have been mapped into kernel virtual
- * address by the vmap layer and so there might be some CPUs with TLB entries
- * still referencing that page (additional to the regular 1:1 kernel mapping).
- *
- * vm_unmap_aliases flushes all such lazy mappings. After it returns, we can
- * be sure that none of the pages we have control over will have any aliases
- * from the vmap layer.
- */
-void vm_unmap_aliases(void)
+static void _vm_unmap_aliases(unsigned long start, unsigned long end,
+				int must_flush)
 {
-	unsigned long start = ULONG_MAX, end = 0;
 	int cpu;
-	int flush = 0;
+	int flush = must_flush;
 
 	if (unlikely(!vmap_initialized))
 		return;
@@ -1109,6 +1097,27 @@ void vm_unmap_aliases(void)
 		flush_tlb_kernel_range(start, end);
 	mutex_unlock(&vmap_purge_lock);
 }
+
+/**
+ * vm_unmap_aliases - unmap outstanding lazy aliases in the vmap layer
+ *
+ * The vmap/vmalloc layer lazily flushes kernel virtual mappings primarily
+ * to amortize TLB flushing overheads. What this means is that any page you
+ * have now, may, in a former life, have been mapped into kernel virtual
+ * address by the vmap layer and so there might be some CPUs with TLB entries
+ * still referencing that page (additional to the regular 1:1 kernel mapping).
+ *
+ * vm_unmap_aliases flushes all such lazy mappings. After it returns, we can
+ * be sure that none of the pages we have control over will have any aliases
+ * from the vmap layer.
+ */
+void vm_unmap_aliases(void)
+{
+	unsigned long start = ULONG_MAX, end = 0;
+	int must_flush = 0;
+
+	_vm_unmap_aliases(start, end, must_flush);
+}
 EXPORT_SYMBOL_GPL(vm_unmap_aliases);
 
 /**
@@ -1494,6 +1503,79 @@ struct vm_struct *remove_vm_area(const void *addr)
 	return NULL;
 }
 
+static inline void set_area_alias(const struct vm_struct *area,
+			int (*set_alias)(struct page *page))
+{
+	int i;
+
+	for (i = 0; i < area->nr_pages; i++) {
+		unsigned long addr =
+			(unsigned long)page_address(area->pages[i]);
+
+		if (addr)
+			set_alias(area->pages[i]);
+	}
+}
+
+/* This handles removing and resetting vm mappings related to the vm_struct. */
+static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
+{
+	unsigned long addr = (unsigned long)area->addr;
+	unsigned long start = ULONG_MAX, end = 0;
+	int special = area->flags & VM_HAS_SPECIAL_PERMS;
+	int i;
+
+	/*
+	 * The below block can be removed when all architectures that have
+	 * direct map permissions also have set_alias_ implementations. This is
+	 * to do resetting on the directmap for any special permissions (today
+	 * only X), without leaving a RW+X window.
+	 */
+	if (special && !IS_ENABLED(CONFIG_ARCH_HAS_SET_ALIAS)) {
+		set_memory_nx(addr, area->nr_pages);
+		set_memory_rw(addr, area->nr_pages);
+	}
+
+	remove_vm_area(area->addr);
+
+	/* If this is not special memory, we can skip the below. */
+	if (!special)
+		return;
+
+	/*
+	 * If we are not deallocating pages, we can just do the flush of the VM
+	 * area and return.
+	 */
+	if (!deallocate_pages) {
+		vm_unmap_aliases();
+		return;
+	}
+
+	/*
+	 * If we are here, we need to flush the vm mapping and reset the direct
+	 * map.
+	 * First find the start and end range of the direct mappings to make
+	 * sure the vm_unmap_aliases flush includes the direct map.
+	 */
+	for (i = 0; i < area->nr_pages; i++) {
+		unsigned long addr =
+			(unsigned long)page_address(area->pages[i]);
+		if (addr) {
+			start = min(addr, start);
+			end = max(addr, end);
+		}
+	}
+
+	/*
+	 * First we set direct map to something not valid so that it won't be
+	 * cached if there are any accesses after the TLB flush, then we flush
+	 * the TLB, and reset the directmap permissions to the default.
+	 */
+	set_area_alias(area, set_alias_nv_noflush);
+	_vm_unmap_aliases(start, end, 1);
+	set_area_alias(area, set_alias_default_noflush);
+}
+
 static void __vunmap(const void *addr, int deallocate_pages)
 {
 	struct vm_struct *area;
@@ -1515,7 +1597,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
 	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
-	remove_vm_area(addr);
+	vm_remove_mappings(area, deallocate_pages);
+
 	if (deallocate_pages) {
 		int i;
 
@@ -1925,8 +2008,9 @@ EXPORT_SYMBOL(vzalloc_node);
 
 void *vmalloc_exec(unsigned long size)
 {
-	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL_EXEC,
-			      NUMA_NO_NODE, __builtin_return_address(0));
+	return __vmalloc_node_range(size, 1, VMALLOC_START, VMALLOC_END,
+			GFP_KERNEL, PAGE_KERNEL_EXEC, VM_HAS_SPECIAL_PERMS,
+			NUMA_NO_NODE, __builtin_return_address(0));
 }
 
 #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
-- 
2.17.1
