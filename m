Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 143156B026D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 16:34:22 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id q2-v6so1265920plh.12
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 13:34:22 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id n3-v6si18917408pld.146.2018.08.15.13.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 13:34:20 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 1/3] vmalloc: Add __vmalloc_node_try_addr function
Date: Wed, 15 Aug 2018 13:30:17 -0700
Message-Id: <1534365020-18943-2-git-send-email-rick.p.edgecombe@intel.com>
In-Reply-To: <1534365020-18943-1-git-send-email-rick.p.edgecombe@intel.com>
References: <1534365020-18943-1-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org
Cc: kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Create __vmalloc_node_try_addr function that tries to allocate at a specific
address and supports caller specified behavior for whether any lazy purging
happens if there is a collision.

Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/vmalloc.h |   3 +
 mm/vmalloc.c            | 177 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 180 insertions(+)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c9..c7712c8 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -82,6 +82,9 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller);
+extern void *__vmalloc_node_try_addr(unsigned long addr, unsigned long size,
+			gfp_t gfp_mask,	pgprot_t prot, unsigned long vm_flags,
+			int node, int try_purge, const void *caller);
 #ifndef CONFIG_MMU
 extern void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
 static inline void *__vmalloc_node_flags_caller(unsigned long size, int node,
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index cfea25b..fb85ec9 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -709,6 +709,7 @@ static void purge_vmap_area_lazy(void)
 	__purge_vmap_area_lazy(ULONG_MAX, 0);
 	mutex_unlock(&vmap_purge_lock);
 }
+EXPORT_SYMBOL(purge_vmap_area_lazy);
 
 /*
  * Free a vmap area, caller ensuring that the area has been unmapped
@@ -1709,6 +1710,182 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	return NULL;
 }
 
+static bool pvm_find_next_prev(unsigned long end,
+			       struct vmap_area **pnext,
+			       struct vmap_area **pprev);
+
+/* Try to allocate a region of KVA of the specified address and size. */
+static struct vmap_area *try_alloc_vmap_area(unsigned long addr,
+				unsigned long size, int node, gfp_t gfp_mask,
+				int try_purge)
+{
+	struct vmap_area *va;
+	struct vmap_area *cur_va = NULL;
+	struct vmap_area *first_before = NULL;
+	int need_purge = 0;
+	int blocked = 0;
+	int purged = 0;
+	unsigned long addr_end;
+
+	WARN_ON(!size);
+	WARN_ON(offset_in_page(size));
+
+	addr_end = addr + size;
+	if (addr > addr_end)
+		return ERR_PTR(-EOVERFLOW);
+
+	might_sleep();
+
+	va = kmalloc_node(sizeof(struct vmap_area),
+			gfp_mask & GFP_RECLAIM_MASK, node);
+	if (unlikely(!va))
+		return ERR_PTR(-ENOMEM);
+
+	/*
+	 * Only scan the relevant parts containing pointers to other objects
+	 * to avoid false negatives.
+	 */
+	kmemleak_scan_area(&va->rb_node, SIZE_MAX, gfp_mask & GFP_RECLAIM_MASK);
+
+retry:
+	spin_lock(&vmap_area_lock);
+
+	pvm_find_next_prev(addr, &cur_va, &first_before);
+
+	if (!cur_va)
+		goto found;
+
+	/*
+	 * If there is no VA that starts before the target address, start the
+	 * check from the closest VA to still check for the case allocation
+	 * overlaps it at the end.
+	 */
+	if (first_before && addr < first_before->va_end)
+		cur_va = first_before;
+
+	/* Linearly search through to make sure there is a hole */
+	while (cur_va->va_start < addr_end) {
+		if (cur_va->va_end > addr) {
+			if (cur_va->flags & VM_LAZY_FREE) {
+				need_purge = 1;
+			} else {
+				blocked = 1;
+				break;
+			}
+		}
+
+		if (list_is_last(&cur_va->list, &vmap_area_list))
+			break;
+
+		cur_va = list_next_entry(cur_va, list);
+	}
+
+	/*
+	 * If a non-lazy free va blocks the allocation, or
+	 * we are not supposed to purge, but we need to the
+	 * allocation fails.
+	 */
+	if (blocked || (need_purge && !try_purge))
+		goto fail;
+
+	if (try_purge && need_purge) {
+		/* if purged once before, give up */
+		if (purged)
+			goto fail;
+
+		/*
+		 * If the va blocking the allocation is set to
+		 * be purged then purge all vmap_areas that are
+		 * set to purged since this will flush the TLBs
+		 * anyway.
+		 */
+		spin_unlock(&vmap_area_lock);
+		purge_vmap_area_lazy();
+		need_purge = 0;
+		purged = 1;
+		goto retry;
+	}
+
+found:
+	va->va_start = addr;
+	va->va_end = addr_end;
+	va->flags = 0;
+	__insert_vmap_area(va);
+	spin_unlock(&vmap_area_lock);
+
+	return va;
+fail:
+	spin_unlock(&vmap_area_lock);
+	kfree(va);
+	if (need_purge && !blocked)
+		return ERR_PTR(-EUCLEAN);
+	return ERR_PTR(-EBUSY);
+}
+
+/**
+ *	__vmalloc_try_addr  -  try to alloc at a specific address
+ *	@addr:		address to try
+ *	@size:		size to try
+ *	@gfp_mask:	flags for the page level allocator
+ *	@prot:		protection mask for the allocated pages
+ *	@vm_flags:	additional vm area flags (e.g. %VM_NO_GUARD)
+ *	@node:		node to use for allocation or NUMA_NO_NODE
+ *	@try_purge:	try to purge if needed to fulfill and allocation
+ *	@caller:	caller's return address
+ *
+ *	Try to allocate at the specific address. If it succeeds the address is
+ *	returned. If it fails an EBUSY ERR_PTR is returned. If try_purge is
+ *	zero, it will return an EUCLEAN ERR_PTR if it could have allocated if it
+ *	was allowed to purge. It may trigger TLB flushes if a purge is needed,
+ *	and try_purge is set.
+ */
+void *__vmalloc_node_try_addr(unsigned long addr, unsigned long size,
+			gfp_t gfp_mask,	pgprot_t prot, unsigned long vm_flags,
+			int node, int try_purge, const void *caller)
+{
+	struct vmap_area *va;
+	struct vm_struct *area;
+	void *alloc_addr;
+	unsigned long real_size = size;
+
+	size = PAGE_ALIGN(size);
+	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
+		return NULL;
+
+	WARN_ON(in_interrupt());
+
+	area = kzalloc_node(sizeof(*area), gfp_mask & GFP_RECLAIM_MASK, node);
+	if (unlikely(!area)) {
+		warn_alloc(gfp_mask, NULL, "kmalloc: allocation failure");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	if (!(vm_flags & VM_NO_GUARD))
+		size += PAGE_SIZE;
+
+	va = try_alloc_vmap_area(addr, size, node, gfp_mask, try_purge);
+	if (IS_ERR(va))
+		goto fail;
+
+	setup_vmalloc_vm(area, va, vm_flags, caller);
+
+	alloc_addr = __vmalloc_area_node(area, gfp_mask, prot, node);
+	if (!alloc_addr) {
+		warn_alloc(gfp_mask, NULL,
+			"vmalloc: allocation failure: %lu bytes", real_size);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	clear_vm_uninitialized_flag(area);
+
+	kmemleak_vmalloc(area, size, gfp_mask);
+
+	return alloc_addr;
+fail:
+	kfree(area);
+	return va;
+}
+
 /**
  *	__vmalloc_node_range  -  allocate virtually contiguous memory
  *	@size:		allocation size
-- 
2.7.4
