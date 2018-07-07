Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC51C6B0005
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 20:35:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o7-v6so5642614pll.13
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 17:35:29 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 1-v6si9618339pla.509.2018.07.06.17.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 17:35:28 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 1/3] vmalloc: Add __vmalloc_node_try_addr function
Date: Fri,  6 Jul 2018 17:35:42 -0700
Message-Id: <1530923744-25687-2-git-send-email-rick.p.edgecombe@intel.com>
In-Reply-To: <1530923744-25687-1-git-send-email-rick.p.edgecombe@intel.com>
References: <1530923744-25687-1-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com
Cc: kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Create __vmalloc_node_try_addr function that tries to allocate at a specific
address and supports caller specified behavior for whether any lazy purging
happens if there is a collision.

Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/vmalloc.h |   3 +
 mm/vmalloc.c            | 174 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 177 insertions(+)

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
index cfea25b..b6f2449 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1710,6 +1710,180 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 }
 
 /**
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
+ *	returned. If it fails NULL is returned. If try_purge is zero, it will
+ *	return an EBUSY ERR_PTR if it could have allocated if it was allowed to
+ *	purge. It may trigger TLB flushes if a purge is needed, and try_purge is
+ *	set.
+ */
+void *__vmalloc_node_try_addr(unsigned long addr, unsigned long size,
+			gfp_t gfp_mask,	pgprot_t prot, unsigned long vm_flags,
+			int node, int try_purge, const void *caller)
+{
+	struct vmap_area *va;
+	struct vm_struct *area;
+	struct rb_node *n;
+	struct vmap_area *cur_va = NULL;
+	struct vmap_area *first_before = NULL;
+
+	int not_at_end = 0;
+	int need_purge = 0;
+	int blocked = 0;
+	int purged = 0;
+
+	unsigned long real_size = size;
+	unsigned long addr_end;
+
+	size = PAGE_ALIGN(size);
+	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
+		return NULL;
+
+	WARN_ON(in_interrupt());
+
+	va = kmalloc_node(sizeof(struct vmap_area),
+			gfp_mask & GFP_RECLAIM_MASK, node);
+	if (unlikely(!va)) {
+		warn_alloc(gfp_mask, NULL,
+			"kmalloc: allocation failure");
+		return NULL;
+	}
+
+	area = kzalloc_node(sizeof(*area), gfp_mask & GFP_RECLAIM_MASK, node);
+	if (unlikely(!area)) {
+		warn_alloc(gfp_mask, NULL,
+			"kmalloc: allocation failure");
+		goto failva;
+	}
+	/*
+	 * Only scan the relevant parts containing pointers to other objects
+	 * to avoid false negatives.
+	 */
+	kmemleak_scan_area(&va->rb_node, SIZE_MAX, gfp_mask & GFP_RECLAIM_MASK);
+
+	if (!(vm_flags & VM_NO_GUARD))
+		size += PAGE_SIZE;
+
+	addr_end = addr + size;
+	if (addr > addr_end)
+		return NULL;
+
+retry:
+	spin_lock(&vmap_area_lock);
+
+	n = vmap_area_root.rb_node;
+	while (n) {
+		cur_va = rb_entry(n, struct vmap_area, rb_node);
+		if (addr < cur_va->va_end) {
+			not_at_end = 1;
+			if (cur_va->va_start == addr) {
+				first_before = cur_va;
+				break;
+			}
+			n = n->rb_left;
+		} else {
+			first_before = cur_va;
+			n = n->rb_right;
+		}
+	}
+
+	/*
+	 * Linearly search through to make sure there is a hole, unless we are
+	 * at the end of the VA list.
+	 */
+	if (not_at_end) {
+		/*
+		 * If there is no VA that starts before the
+		 * target address, start the check from the closest VA.
+		 */
+		if (first_before)
+			cur_va = first_before;
+
+		while (cur_va->va_start < addr_end) {
+			if (cur_va->va_end > addr) {
+				if (cur_va->flags & VM_LAZY_FREE) {
+					need_purge = 1;
+				} else {
+					blocked = 1;
+					break;
+				}
+			}
+
+			if (list_is_last(&cur_va->list, &vmap_area_list))
+				break;
+
+			cur_va = list_next_entry(cur_va, list);
+		}
+
+		if (blocked || (!try_purge && need_purge)) {
+			/*
+			 * If a non-lazy free va blocks the allocation, or
+			 * we are not supposed to purge, but we need to the
+			 * allocation fails.
+			 */
+			goto fail;
+		}
+		if (try_purge && need_purge) {
+			if (purged) {
+				/* if purged once before, give up */
+				goto fail;
+			} else {
+				/*
+				 * If the va blocking the allocation is set to
+				 * be purged then purge all vmap_areas that are
+				 * set to purged since this will flush the TLBs
+				 * anyway.
+				 */
+				spin_unlock(&vmap_area_lock);
+				purge_vmap_area_lazy();
+				need_purge = 0;
+				purged = 1;
+				goto retry;
+			}
+		}
+	}
+
+	va->va_start = addr;
+	va->va_end = addr_end;
+	va->flags = 0;
+	__insert_vmap_area(va);
+
+	spin_unlock(&vmap_area_lock);
+
+	setup_vmalloc_vm(area, va, vm_flags, caller);
+
+	addr = (unsigned long)__vmalloc_area_node(area, gfp_mask, prot, node);
+	if (!addr) {
+		warn_alloc(gfp_mask, NULL,
+			"vmalloc: allocation failure: %lu bytes", real_size);
+		return NULL;
+	}
+
+	clear_vm_uninitialized_flag(area);
+
+	kmemleak_vmalloc(area, size, gfp_mask);
+
+	return (void *)addr;
+fail:
+	kfree(area);
+	spin_unlock(&vmap_area_lock);
+failva:
+	kfree(va);
+	if (need_purge && !blocked)
+		return ERR_PTR(-EBUSY);
+	return NULL;
+}
+
+/**
  *	__vmalloc_node_range  -  allocate virtually contiguous memory
  *	@size:		allocation size
  *	@align:		desired alignment
-- 
2.7.4
