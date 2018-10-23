Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD9B6B000E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 17:36:11 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id r24-v6so956230ljr.18
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:36:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p20-v6sor851492lfp.41.2018.10.23.14.36.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 14:36:09 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 08/17] prmem: struct page: track vmap_area
Date: Wed, 24 Oct 2018 00:34:55 +0300
Message-Id: <20181023213504.28905-9-igor.stoppa@huawei.com>
In-Reply-To: <20181023213504.28905-1-igor.stoppa@huawei.com>
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When a page is used for virtual memory, it is often necessary to obtain
a handler to the corresponding vmap_area, which refers to the virtually
continuous area generated, when invoking vmalloc.

The struct page has a "private" field, which can be re-used, to store a
pointer to the parent area.

Note: in practice a virtual memory area is characterized both by a
struct vmap_area and a struct vm_struct.

The reason for referring from a page to its vmap_area, rather than to
the vm_struct, is that the vmap_area contains a struct vm_struct *vm
field, which can be used to reach also the information stored in the
corresponding vm_struct. This link, however, is unidirectional, and it's
not possible to easily identify the corresponding vmap_area, given a
reference to a vm_struct.

Furthermore, the struct vmap_area contains a list head node which is
normally used only when it's queued for free and can be put to some
other use during normal operations.

The connection between each page and its vmap_area avoids more expensive
searches through the btree of vmap_areas.

Therefore, it is possible for find_vamp_area to be again a static
function, while the rest of the code will rely on the direct reference
from struct page.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
CC: Michal Hocko <mhocko@kernel.org>
CC: Vlastimil Babka <vbabka@suse.cz>
CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Pavel Tatashin <pasha.tatashin@oracle.com>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 include/linux/mm_types.h | 25 ++++++++++++++++++-------
 include/linux/prmem.h    | 13 ++++++++-----
 include/linux/vmalloc.h  |  1 -
 mm/prmem.c               |  2 +-
 mm/test_pmalloc.c        | 12 ++++--------
 mm/vmalloc.c             |  9 ++++++++-
 6 files changed, 39 insertions(+), 23 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5ed8f6292a53..8403bdd12d1f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -87,13 +87,24 @@ struct page {
 			/* See page-flags.h for PAGE_MAPPING_FLAGS */
 			struct address_space *mapping;
 			pgoff_t index;		/* Our offset within mapping. */
-			/**
-			 * @private: Mapping-private opaque data.
-			 * Usually used for buffer_heads if PagePrivate.
-			 * Used for swp_entry_t if PageSwapCache.
-			 * Indicates order in the buddy system if PageBuddy.
-			 */
-			unsigned long private;
+			union {
+				/**
+				 * @private: Mapping-private opaque data.
+				 * Usually used for buffer_heads if
+				 * PagePrivate.
+				 * Used for swp_entry_t if PageSwapCache.
+				 * Indicates order in the buddy system if
+				 * PageBuddy.
+				 */
+				unsigned long private;
+				/**
+				 * @area: reference to the containing area
+				 * For pages that are mapped into a virtually
+				 * contiguous area, avoids performing a more
+				 * expensive lookup.
+				 */
+				struct vmap_area *area;
+			};
 		};
 		struct {	/* slab, slob and slub */
 			union {
diff --git a/include/linux/prmem.h b/include/linux/prmem.h
index 26fd48410d97..cf713fc1c8bb 100644
--- a/include/linux/prmem.h
+++ b/include/linux/prmem.h
@@ -54,14 +54,17 @@ static __always_inline bool __is_wr_after_init(const void *ptr, size_t size)
 
 static __always_inline bool __is_wr_pool(const void *ptr, size_t size)
 {
-	struct vmap_area *area;
+	struct vm_struct *vm;
+	struct page *page;
 
 	if (!is_vmalloc_addr(ptr))
 		return false;
-	area = find_vmap_area((unsigned long)ptr);
-	return area && area->vm && (area->vm->size >= size) &&
-		((area->vm->flags & (VM_PMALLOC | VM_PMALLOC_WR)) ==
-		 (VM_PMALLOC | VM_PMALLOC_WR));
+	page = vmalloc_to_page(ptr);
+	if (!(page && page->area && page->area->vm))
+		return false;
+	vm = page->area->vm;
+	return ((vm->size >= size) &&
+		((vm->flags & VM_PMALLOC_WR_MASK) == VM_PMALLOC_WR_MASK));
 }
 
 /**
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 4d14a3b8089e..43a444f8b1e9 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -143,7 +143,6 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
 					const void *caller);
 extern struct vm_struct *remove_vm_area(const void *addr);
 extern struct vm_struct *find_vm_area(const void *addr);
-extern struct vmap_area *find_vmap_area(unsigned long addr);
 
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
 			struct page **pages);
diff --git a/mm/prmem.c b/mm/prmem.c
index 7dd13ea43304..96abf04909e7 100644
--- a/mm/prmem.c
+++ b/mm/prmem.c
@@ -150,7 +150,7 @@ static int grow(struct pmalloc_pool *pool, size_t min_size)
 	if (WARN(!addr, "Failed to allocate %zd bytes", PAGE_ALIGN(size)))
 		return -ENOMEM;
 
-	new_area = find_vmap_area((uintptr_t)addr);
+	new_area = vmalloc_to_page(addr)->area;
 	tag_mask = VM_PMALLOC;
 	if (pool->mode & PMALLOC_WR)
 		tag_mask |= VM_PMALLOC_WR;
diff --git a/mm/test_pmalloc.c b/mm/test_pmalloc.c
index f9ee8fb29eea..c64872ff05ea 100644
--- a/mm/test_pmalloc.c
+++ b/mm/test_pmalloc.c
@@ -38,15 +38,11 @@ static bool is_address_protected(void *p)
 	if (unlikely(!is_vmalloc_addr(p)))
 		return false;
 	page = vmalloc_to_page(p);
-	if (unlikely(!page))
+	if (unlikely(!(page && page->area && page->area->vm)))
 		return false;
-	wmb(); /* Flush changes to the page table - is it needed? */
-	area = find_vmap_area((uintptr_t)p);
-	if (unlikely((!area) || (!area->vm) ||
-		     ((area->vm->flags & VM_PMALLOC_PROTECTED_MASK) !=
-		      VM_PMALLOC_PROTECTED_MASK)))
-		return false;
-	return true;
+	area = page->area;
+	return (area->vm->flags & VM_PMALLOC_PROTECTED_MASK) ==
+		VM_PMALLOC_PROTECTED_MASK;
 }
 
 static bool create_and_destroy_pool(void)
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 15850005fea5..ffef705f0523 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -742,7 +742,7 @@ static void free_unmap_vmap_area(struct vmap_area *va)
 	free_vmap_area_noflush(va);
 }
 
-struct vmap_area *find_vmap_area(unsigned long addr)
+static struct vmap_area *find_vmap_area(unsigned long addr)
 {
 	struct vmap_area *va;
 
@@ -1523,6 +1523,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			struct page *page = area->pages[i];
 
 			BUG_ON(!page);
+			page->area = NULL;
 			__free_pages(page, 0);
 		}
 
@@ -1731,8 +1732,10 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			const void *caller)
 {
 	struct vm_struct *area;
+	struct vmap_area *va;
 	void *addr;
 	unsigned long real_size = size;
+	unsigned int i;
 
 	size = PAGE_ALIGN(size);
 	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
@@ -1747,6 +1750,10 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	if (!addr)
 		return NULL;
 
+	va = __find_vmap_area((unsigned long)addr);
+	for (i = 0; i < va->vm->nr_pages; i++)
+		va->vm->pages[i]->area = va;
+
 	/*
 	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED
 	 * flag. It means that vm_struct is not fully initialized.
-- 
2.17.1
