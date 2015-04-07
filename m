Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE076B0072
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 17:05:49 -0400 (EDT)
Received: by yhla23 with SMTP id a23so2787328yhl.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 14:05:49 -0700 (PDT)
Received: from relay.fireflyinternet.com (hostedrelay.fireflyinternet.com. [109.228.30.76])
        by mx.google.com with ESMTP id pd7si13721155wic.106.2015.04.07.09.31.44
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 09:31:44 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 4/5] mm: Export remap_io_mapping()
Date: Tue,  7 Apr 2015 17:31:38 +0100
Message-Id: <1428424299-13721-5-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <1428424299-13721-1-git-send-email-chris@chris-wilson.co.uk>
References: <1428424299-13721-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

This is similar to remap_pfn_range(), and uses the recently refactor
code to do the page table walking. The key difference is that is back
propagates its error as this is required for use from within a pagefault
handler. The other difference, is that it combine the page protection
from io-mapping, which is known from when the io-mapping is created,
with the per-vma page protection flags. This avoids having to walk the
entire system description to rediscover the special page protection
established for the io-mapping.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
---
 include/linux/mm.h |  4 ++++
 mm/memory.c        | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47a93928b90f..3dfecd58adb0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2083,6 +2083,10 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
+struct io_mapping;
+int remap_io_mapping(struct vm_area_struct *,
+		     unsigned long addr, unsigned long pfn, unsigned long size,
+		     struct io_mapping *iomap);
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
diff --git a/mm/memory.c b/mm/memory.c
index acb06f40d614..83bc5df3fafc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -61,6 +61,7 @@
 #include <linux/string.h>
 #include <linux/dma-debug.h>
 #include <linux/debugfs.h>
+#include <linux/io-mapping.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -1762,6 +1763,51 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 EXPORT_SYMBOL(remap_pfn_range);
 
 /**
+ * remap_io_mapping - remap an IO mapping to userspace
+ * @vma: user vma to map to
+ * @addr: target user address to start at
+ * @pfn: physical address of kernel memory
+ * @size: size of map area
+ * @iomap: the source io_mapping
+ *
+ *  Note: this is only safe if the mm semaphore is held when called.
+ */
+int remap_io_mapping(struct vm_area_struct *vma,
+		     unsigned long addr, unsigned long pfn, unsigned long size,
+		     struct io_mapping *iomap)
+{
+	unsigned long end = addr + PAGE_ALIGN(size);
+	struct remap_pfn r;
+	pgd_t *pgd;
+	int err;
+
+	if (WARN_ON(addr >= end))
+		return -EINVAL;
+
+#define MUST_SET (VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP)
+	BUG_ON(is_cow_mapping(vma->vm_flags));
+	BUG_ON((vma->vm_flags & MUST_SET) != MUST_SET);
+#undef MUST_SET
+
+	r.mm = vma->vm_mm;
+	r.addr = addr;
+	r.pfn = pfn;
+	r.prot = __pgprot((pgprot_val(iomap->prot) & _PAGE_CACHE_MASK) |
+			  (pgprot_val(vma->vm_page_prot) & ~_PAGE_CACHE_MASK));
+
+	pgd = pgd_offset(r.mm, addr);
+	do {
+		err = remap_pud_range(&r, pgd++, pgd_addr_end(r.addr, end));
+	} while (err == 0 && r.addr < end);
+
+	if (err)
+		zap_page_range_single(vma, addr, r.addr - addr, NULL);
+
+	return err;
+}
+EXPORT_SYMBOL(remap_io_mapping);
+
+/**
  * vm_iomap_memory - remap memory to userspace
  * @vma: user vma to map to
  * @start: start of area
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
