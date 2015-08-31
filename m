Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 87D506B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 15:00:12 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so148038791pab.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 12:00:12 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id sv7si25365740pbc.72.2015.08.31.12.00.10
        for <linux-mm@kvack.org>;
        Mon, 31 Aug 2015 12:00:10 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH] dax, pmem: add support for msync
Date: Mon, 31 Aug 2015 12:59:44 -0600
Message-Id: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

For DAX msync we just need to flush the given range using
wb_cache_pmem(), which is now a public part of the PMEM API.

The inclusion of <linux/dax.h> in fs/dax.c was done to make checkpatch
happy.  Previously it was complaining about a bunch of undeclared
functions that could be made static.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
This patch is based on libnvdimm-for-next from our NVDIMM tree:

https://git.kernel.org/cgit/linux/kernel/git/nvdimm/nvdimm.git/

with some DAX patches on top.  The baseline tree can be found here:

https://github.com/01org/prd/tree/dax_msync
---
 arch/x86/include/asm/pmem.h | 13 +++++++------
 fs/dax.c                    | 17 +++++++++++++++++
 include/linux/dax.h         |  1 +
 include/linux/pmem.h        | 22 +++++++++++++++++++++-
 mm/msync.c                  | 10 +++++++++-
 5 files changed, 55 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/pmem.h b/arch/x86/include/asm/pmem.h
index d8ce3ec..85c07b2 100644
--- a/arch/x86/include/asm/pmem.h
+++ b/arch/x86/include/asm/pmem.h
@@ -67,18 +67,19 @@ static inline void arch_wmb_pmem(void)
 }
 
 /**
- * __arch_wb_cache_pmem - write back a cache range with CLWB
- * @vaddr:	virtual start address
+ * arch_wb_cache_pmem - write back a cache range with CLWB
+ * @addr:	virtual start address
  * @size:	number of bytes to write back
  *
  * Write back a cache range using the CLWB (cache line write back)
  * instruction.  This function requires explicit ordering with an
- * arch_wmb_pmem() call.  This API is internal to the x86 PMEM implementation.
+ * arch_wmb_pmem() call.
  */
-static inline void __arch_wb_cache_pmem(void *vaddr, size_t size)
+static inline void arch_wb_cache_pmem(void __pmem *addr, size_t size)
 {
 	u16 x86_clflush_size = boot_cpu_data.x86_clflush_size;
 	unsigned long clflush_mask = x86_clflush_size - 1;
+	void *vaddr = (void __force *)addr;
 	void *vend = vaddr + size;
 	void *p;
 
@@ -115,7 +116,7 @@ static inline size_t arch_copy_from_iter_pmem(void __pmem *addr, size_t bytes,
 	len = copy_from_iter_nocache(vaddr, bytes, i);
 
 	if (__iter_needs_pmem_wb(i))
-		__arch_wb_cache_pmem(vaddr, bytes);
+		arch_wb_cache_pmem(addr, bytes);
 
 	return len;
 }
@@ -138,7 +139,7 @@ static inline void arch_clear_pmem(void __pmem *addr, size_t size)
 	else
 		memset(vaddr, 0, size);
 
-	__arch_wb_cache_pmem(vaddr, size);
+	arch_wb_cache_pmem(addr, size);
 }
 
 static inline bool __arch_has_wmb_pmem(void)
diff --git a/fs/dax.c b/fs/dax.c
index fbe18b8..ed6aec1 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -17,6 +17,7 @@
 #include <linux/atomic.h>
 #include <linux/blkdev.h>
 #include <linux/buffer_head.h>
+#include <linux/dax.h>
 #include <linux/fs.h>
 #include <linux/genhd.h>
 #include <linux/highmem.h>
@@ -25,6 +26,7 @@
 #include <linux/mutex.h>
 #include <linux/pmem.h>
 #include <linux/sched.h>
+#include <linux/sizes.h>
 #include <linux/uio.h>
 #include <linux/vmstat.h>
 
@@ -753,3 +755,18 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 	return dax_zero_page_range(inode, from, length, get_block);
 }
 EXPORT_SYMBOL_GPL(dax_truncate_page);
+
+void dax_sync_range(unsigned long addr, size_t len)
+{
+	while (len) {
+		size_t chunk_len = min_t(size_t, SZ_1G, len);
+
+		wb_cache_pmem((void __pmem *)addr, chunk_len);
+		len -= chunk_len;
+		addr += chunk_len;
+		if (len)
+			cond_resched();
+	}
+	wmb_pmem();
+}
+EXPORT_SYMBOL_GPL(dax_sync_range);
diff --git a/include/linux/dax.h b/include/linux/dax.h
index b415e52..504b33f 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -14,6 +14,7 @@ int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
 		dax_iodone_t);
 int __dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
 		dax_iodone_t);
+void dax_sync_range(unsigned long addr, size_t len);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 int dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
 				unsigned int flags, get_block_t, dax_iodone_t);
diff --git a/include/linux/pmem.h b/include/linux/pmem.h
index 85f810b3..aa29ebb 100644
--- a/include/linux/pmem.h
+++ b/include/linux/pmem.h
@@ -53,12 +53,18 @@ static inline void arch_clear_pmem(void __pmem *addr, size_t size)
 {
 	BUG();
 }
+
+static inline void arch_wb_cache_pmem(void __pmem *addr, size_t size)
+{
+	BUG();
+}
 #endif
 
 /*
  * Architectures that define ARCH_HAS_PMEM_API must provide
  * implementations for arch_memcpy_to_pmem(), arch_wmb_pmem(),
- * arch_copy_from_iter_pmem(), arch_clear_pmem() and arch_has_wmb_pmem().
+ * arch_copy_from_iter_pmem(), arch_clear_pmem(), arch_wb_cache_pmem()
+ * and arch_has_wmb_pmem().
  */
 static inline void memcpy_from_pmem(void *dst, void __pmem const *src, size_t size)
 {
@@ -202,4 +208,18 @@ static inline void clear_pmem(void __pmem *addr, size_t size)
 	else
 		default_clear_pmem(addr, size);
 }
+
+/**
+ * wb_cache_pmem - write back a range of cache lines
+ * @vaddr:	virtual start address
+ * @size:	number of bytes to write back
+ *
+ * Write back the cache lines starting at 'vaddr' for 'size' bytes.
+ * This function requires explicit ordering with an wmb_pmem() call.
+ */
+static inline void wb_cache_pmem(void __pmem *addr, size_t size)
+{
+	if (arch_has_pmem_api())
+		arch_wb_cache_pmem(addr, size);
+}
 #endif /* __PMEM_H__ */
diff --git a/mm/msync.c b/mm/msync.c
index bb04d53..2a4739c 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -7,6 +7,7 @@
 /*
  * The msync() system call.
  */
+#include <linux/dax.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
@@ -59,6 +60,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	for (;;) {
 		struct file *file;
 		loff_t fstart, fend;
+		unsigned long range_len;
 
 		/* Still start < end. */
 		error = -ENOMEM;
@@ -77,10 +79,16 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 			error = -EBUSY;
 			goto out_unlock;
 		}
+
+		range_len = min(end, vma->vm_end) - start;
+
+		if (vma_is_dax(vma))
+			dax_sync_range(start, range_len);
+
 		file = vma->vm_file;
 		fstart = (start - vma->vm_start) +
 			 ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
-		fend = fstart + (min(end, vma->vm_end) - start) - 1;
+		fend = fstart + range_len - 1;
 		start = vma->vm_end;
 		if ((flags & MS_SYNC) && file &&
 				(vma->vm_flags & VM_SHARED)) {
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
