From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 3/4] mm: Export remap_io_mapping()
Date: Sat, 21 Jun 2014 16:53:55 +0100
Message-ID: <1403366036-10169-3-git-send-email-chris@chris-wilson.co.uk>
References: <20140619135944.20837E00A3@blue.fi.intel.com>
 <1403366036-10169-1-git-send-email-chris@chris-wilson.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <1403366036-10169-1-git-send-email-chris@chris-wilson.co.uk>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
To: intel-gfx@lists.freedesktop.org
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
List-Id: linux-mm.kvack.org

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
index d6777060449f..aa766bbc6981 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1941,6 +1941,10 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
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
index d2c7fe88a289..8af2bd2de98e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -61,6 +61,7 @@
 #include <linux/string.h>
 #include <linux/dma-debug.h>
 #include <linux/debugfs.h>
+#include <linux/io-mapping.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -2443,6 +2444,51 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
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
2.0.0
