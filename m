Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5FB82F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 16:12:30 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so44042685pad.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 13:12:29 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id yw10si4839560pac.86.2015.10.29.13.12.29
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 13:12:29 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC 01/11] pmem: add wb_cache_pmem() to the PMEM API
Date: Thu, 29 Oct 2015 14:12:05 -0600
Message-Id: <1446149535-16200-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

The function __arch_wb_cache_pmem() was already an internal implementation
detail of the x86 PMEM API, but this functionality needs to be exported as
part of the general PMEM API to handle the fsync/msync case for DAX mmaps.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 arch/x86/include/asm/pmem.h | 11 ++++++-----
 include/linux/pmem.h        | 22 +++++++++++++++++++++-
 2 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/pmem.h b/arch/x86/include/asm/pmem.h
index d8ce3ec..6c7ade0 100644
--- a/arch/x86/include/asm/pmem.h
+++ b/arch/x86/include/asm/pmem.h
@@ -67,18 +67,19 @@ static inline void arch_wmb_pmem(void)
 }
 
 /**
- * __arch_wb_cache_pmem - write back a cache range with CLWB
+ * arch_wb_cache_pmem - write back a cache range with CLWB
  * @vaddr:	virtual start address
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
diff --git a/include/linux/pmem.h b/include/linux/pmem.h
index 85f810b3..2cd5003 100644
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
+ * wb_cache_pmem - write back processor cache for PMEM memory range
+ * @addr:	virtual start address
+ * @size:	number of bytes to write back
+ *
+ * Write back the processor cache range starting at 'addr' for 'size' bytes.
+ * This function requires explicit ordering with a wmb_pmem() call.
+ */
+static inline void wb_cache_pmem(void __pmem *addr, size_t size)
+{
+	if (arch_has_pmem_api())
+		arch_wb_cache_pmem(addr, size);
+}
 #endif /* __PMEM_H__ */
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
