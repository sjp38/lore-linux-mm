Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2B34A9003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 21:33:35 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so142019472pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 18:33:34 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id aq3si35696543pbc.190.2015.08.25.18.33.34
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 18:33:34 -0700 (PDT)
Subject: [PATCH v2 5/9] x86, pmem: push fallback handling to arch code
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Aug 2015 21:27:51 -0400
Message-ID: <20150826012751.8851.78564.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: boaz@plexistor.com, Toshi Kani <toshi.kani@hp.com>, david@fromorbit.com, linux-kernel@vger.kernel.org, mingo@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, hpa@zytor.com, ross.zwisler@linux.intel.com, hch@lst.de

The decision of when to fallback to the default pmem apis is currently
done at too high of a level.  In particular the test for
arch_has_pmem_api() in memcpy_to_pmem() really wants to decide whether
the arch_memcpy_to_pmem() implementation is placing data in a location
that a subsequent wmb_pmem() can flush.

For x86 this equates to an arch_memcpy_to_pmem() implementation that
guarantees that write data is at most sitting in the local cpu write
buffer.  The current usage of __copy_from_user_inatomic_nocache()
guarantees this property on all 64-bit x86 implementations (at least
according to the Intel SDM that says Pentium M implementations may leave
dirty-data in the cache after a non-temporal store).  In the 32-bit case
waiting until memcpy_to_pmem() time to perform a fallback is too late.
Instead 32-bit x86 is converted to use write-through mappings for pmem.

arch_has_pmem_api() is updated to only indicate whether the arch
provides the proper helpers.  Code that cares whether wmb_pmem()
actually flushes writes to pmem must now call arch_has_wmb_pmem()
directly.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/include/asm/io.h   |    2 -
 arch/x86/include/asm/pmem.h |   41 ++++++++++++++++++++++--
 drivers/acpi/nfit.c         |    2 +
 drivers/nvdimm/pmem.c       |    2 +
 include/asm-generic/pmem.h  |   72 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/pmem.h        |   73 +++++++------------------------------------
 6 files changed, 123 insertions(+), 69 deletions(-)
 create mode 100644 include/asm-generic/pmem.h

diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index d241fbd5c87b..83ec9b1d77cc 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -248,8 +248,6 @@ static inline void flush_write_buffers(void)
 #endif
 }
 
-#define ARCH_MEMREMAP_PMEM MEMREMAP_WB
-
 #endif /* __KERNEL__ */
 
 extern void native_io_delay(void);
diff --git a/arch/x86/include/asm/pmem.h b/arch/x86/include/asm/pmem.h
index a3a0df6545ee..6eb3c1da5d57 100644
--- a/arch/x86/include/asm/pmem.h
+++ b/arch/x86/include/asm/pmem.h
@@ -16,9 +16,12 @@
 #include <linux/uaccess.h>
 #include <asm/cacheflush.h>
 #include <asm/cpufeature.h>
+#include <asm-generic/pmem.h>
 #include <asm/special_insns.h>
 
 #ifdef CONFIG_ARCH_HAS_PMEM_API
+#ifdef CONFIG_X86_64
+#define ARCH_MEMREMAP_PMEM MEMREMAP_WB
 /**
  * arch_memcpy_to_pmem - copy data to persistent memory
  * @dst: destination buffer for the copy
@@ -141,18 +144,48 @@ static inline void arch_clear_pmem(void __pmem *addr, size_t size)
 	__arch_wb_cache_pmem(vaddr, size);
 }
 
-static inline bool arch_has_wmb_pmem(void)
+static inline bool __arch_has_wmb_pmem(void)
 {
-#ifdef CONFIG_X86_64
 	/*
 	 * We require that wmb() be an 'sfence', that is only guaranteed on
 	 * 64-bit builds
 	 */
 	return static_cpu_has(X86_FEATURE_PCOMMIT);
+}
 #else
+/*
+ * Some 32-bit implementations may leave dirty-data in cache after a
+ * series of non-temporal stores, so set pmem ranges to write-through
+ * caching.
+ */
+#define ARCH_MEMREMAP_PMEM MEMREMAP_WT
+
+static inline void arch_memcpy_to_pmem(void __pmem *dst, const void *src,
+		size_t n)
+{
+	default_memcpy_pmem(dst, src, n);
+}
+
+static inline size_t arch_copy_from_iter_pmem(void __pmem *addr, size_t bytes,
+		struct iov_iter *i)
+{
+	return default_copy_from_iter_pmem(addr, bytes, i);
+}
+
+static inline void arch_clear_pmem(void __pmem *addr, size_t size)
+{
+	default_clear_pmem(addr, size);
+}
+
+static inline void arch_wmb_pmem(void)
+{
+	wmb();
+}
+
+static inline bool __arch_has_wmb_pmem(void)
+{
 	return false;
-#endif
 }
+#endif /* CONFIG_X86_64 */
 #endif /* CONFIG_ARCH_HAS_PMEM_API */
-
 #endif /* __ASM_X86_PMEM_H__ */
diff --git a/drivers/acpi/nfit.c b/drivers/acpi/nfit.c
index 7c2638f914a9..c3fe20635562 100644
--- a/drivers/acpi/nfit.c
+++ b/drivers/acpi/nfit.c
@@ -1364,7 +1364,7 @@ static int acpi_nfit_blk_region_enable(struct nvdimm_bus *nvdimm_bus,
 			return -ENOMEM;
 	}
 
-	if (!arch_has_pmem_api() && !nfit_blk->nvdimm_flush)
+	if (!arch_has_wmb_pmem() && !nfit_blk->nvdimm_flush)
 		dev_warn(dev, "unable to guarantee persistence of writes\n");
 
 	if (mmio->line_size == 0)
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 3b5b9cb758b6..20bf122328da 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -125,7 +125,7 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 
 	pmem->phys_addr = res->start;
 	pmem->size = resource_size(res);
-	if (!arch_has_pmem_api())
+	if (!arch_has_wmb_pmem())
 		dev_warn(dev, "unable to guarantee persistence of writes\n");
 
 	if (!devm_request_mem_region(dev, pmem->phys_addr, pmem->size,
diff --git a/include/asm-generic/pmem.h b/include/asm-generic/pmem.h
new file mode 100644
index 000000000000..95d1a6ac0df7
--- /dev/null
+++ b/include/asm-generic/pmem.h
@@ -0,0 +1,72 @@
+/*
+ * Copyright(c) 2015 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+#ifndef __ASM_GENERIC_PMEM_H__
+#define __ASM_GENERIC_PMEM_H__
+/*
+ * These defaults seek to offer decent performance and minimize the
+ * window between i/o completion and writes being durable on media.
+ * However, it is undefined / architecture specific whether
+ * default_memremap_pmem + default_memcpy_to_pmem is sufficient for
+ * making data durable relative to i/o completion.
+ */
+static inline void default_memcpy_to_pmem(void __pmem *dst, const void *src,
+		size_t size)
+{
+	memcpy((void __force *) dst, src, size);
+}
+
+static inline size_t default_copy_from_iter_pmem(void __pmem *addr,
+		size_t bytes, struct iov_iter *i)
+{
+	return copy_from_iter_nocache((void __force *)addr, bytes, i);
+}
+
+static inline void default_clear_pmem(void __pmem *addr, size_t size)
+{
+	if (size == PAGE_SIZE && ((unsigned long)addr & ~PAGE_MASK) == 0)
+		clear_page((void __force *)addr);
+	else
+		memset((void __force *)addr, 0, size);
+}
+
+#ifndef CONFIG_ARCH_HAS_PMEM_API
+/*
+ * These are simply here to enable compilation, all call sites gate
+ * calling these symbols with arch_has_pmem_api() and redirect to the
+ * implementation in asm/pmem.h.
+ */
+
+static inline bool __arch_has_wmb_pmem(void)
+{
+	return false;
+}
+
+static inline void arch_memcpy_to_pmem(void __pmem *dst, const void *src,
+		size_t n)
+{
+	BUG();
+}
+
+static inline size_t arch_copy_from_iter_pmem(void __pmem *addr, size_t bytes,
+		struct iov_iter *i)
+{
+	BUG();
+	return 0;
+}
+
+static inline void arch_clear_pmem(void __pmem *addr, size_t size)
+{
+	BUG();
+}
+#endif /* CONFIG_ARCH_HAS_PMEM_API */
+#endif /* __ASM_GENERIC_PMEM_H__ */
diff --git a/include/linux/pmem.h b/include/linux/pmem.h
index a9d84bf335ee..f7f5a713a860 100644
--- a/include/linux/pmem.h
+++ b/include/linux/pmem.h
@@ -15,37 +15,9 @@
 
 #include <linux/io.h>
 #include <linux/uio.h>
-
+#include <asm-generic/pmem.h>
 #ifdef CONFIG_ARCH_HAS_PMEM_API
 #include <asm/pmem.h>
-#else
-static inline void arch_wmb_pmem(void)
-{
-	BUG();
-}
-
-static inline bool arch_has_wmb_pmem(void)
-{
-	return false;
-}
-
-static inline void arch_memcpy_to_pmem(void __pmem *dst, const void *src,
-		size_t n)
-{
-	BUG();
-}
-
-static inline size_t arch_copy_from_iter_pmem(void __pmem *addr, size_t bytes,
-		struct iov_iter *i)
-{
-	BUG();
-	return 0;
-}
-
-static inline void arch_clear_pmem(void __pmem *addr, size_t size)
-{
-	BUG();
-}
 #endif
 
 /*
@@ -53,7 +25,6 @@ static inline void arch_clear_pmem(void __pmem *addr, size_t size)
  * implementations for arch_memcpy_to_pmem(), arch_wmb_pmem(),
  * arch_copy_from_iter_pmem(), arch_clear_pmem() and arch_has_wmb_pmem().
  */
-
 static inline void memcpy_from_pmem(void *dst, void __pmem const *src, size_t size)
 {
 	memcpy(dst, (void __force const *) src, size);
@@ -64,8 +35,13 @@ static inline void memunmap_pmem(struct device *dev, void __pmem *addr)
 	devm_memunmap(dev, (void __force *) addr);
 }
 
+static inline bool arch_has_pmem_api(void)
+{
+	return IS_ENABLED(CONFIG_ARCH_HAS_PMEM_API);
+}
+
 /**
- * arch_has_pmem_api - true if wmb_pmem() ensures durability
+ * arch_has_wmb_pmem - true if wmb_pmem() ensures durability
  *
  * For a given cpu implementation within an architecture it is possible
  * that wmb_pmem() resolves to a nop.  In the case this returns
@@ -73,36 +49,9 @@ static inline void memunmap_pmem(struct device *dev, void __pmem *addr)
  * fall back to a different data consistency model, or otherwise notify
  * the user.
  */
-static inline bool arch_has_pmem_api(void)
-{
-	return IS_ENABLED(CONFIG_ARCH_HAS_PMEM_API) && arch_has_wmb_pmem();
-}
-
-/*
- * These defaults seek to offer decent performance and minimize the
- * window between i/o completion and writes being durable on media.
- * However, it is undefined / architecture specific whether
- * default_memremap_pmem + default_memcpy_to_pmem is sufficient for
- * making data durable relative to i/o completion.
- */
-static inline void default_memcpy_to_pmem(void __pmem *dst, const void *src,
-		size_t size)
-{
-	memcpy((void __force *) dst, src, size);
-}
-
-static inline size_t default_copy_from_iter_pmem(void __pmem *addr,
-		size_t bytes, struct iov_iter *i)
-{
-	return copy_from_iter_nocache((void __force *)addr, bytes, i);
-}
-
-static inline void default_clear_pmem(void __pmem *addr, size_t size)
+static inline bool arch_has_wmb_pmem(void)
 {
-	if (size == PAGE_SIZE && ((unsigned long)addr & ~PAGE_MASK) == 0)
-		clear_page((void __force *)addr);
-	else
-		memset((void __force *)addr, 0, size);
+	return arch_has_pmem_api() && __arch_has_wmb_pmem();
 }
 
 /**
@@ -158,8 +107,10 @@ static inline void memcpy_to_pmem(void __pmem *dst, const void *src, size_t n)
  */
 static inline void wmb_pmem(void)
 {
-	if (arch_has_pmem_api())
+	if (arch_has_wmb_pmem())
 		arch_wmb_pmem();
+	else
+		wmb();
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
