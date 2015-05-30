Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF806B0071
	for <linux-mm@kvack.org>; Sat, 30 May 2015 15:02:22 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so77080016pdf.3
        for <linux-mm@kvack.org>; Sat, 30 May 2015 12:02:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id pm11si14020774pdb.55.2015.05.30.12.02.20
        for <linux-mm@kvack.org>;
        Sat, 30 May 2015 12:02:21 -0700 (PDT)
Subject: [PATCH v2 4/4] arch,
 x86: cache management apis for persistent memory
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 30 May 2015 14:59:40 -0400
Message-ID: <20150530185940.32590.37804.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org
Cc: jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, hmh@hmh.eng.br, tj@kernel.org, hch@lst.de

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Based on an original patch by Ross Zwisler [1].

Writes to persistent memory have the potential to be posted to cpu
cache, cpu write buffers, and platform write buffers (memory controller)
before being committed to persistent media.  Provide apis
(persistent_copy() and persistent_sync()) to copy data and assert that
it is durable in PMEM (a persistent linear address range).

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-May/000932.html

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
[djbw: s/arch_persistent_flush()/io_flush_cache_range()/]
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/Kconfig                  |    1 
 arch/x86/include/asm/cacheflush.h |   24 ++++++++++
 arch/x86/include/asm/io.h         |    6 ++
 drivers/block/pmem.c              |   58 ++++++++++++++++++++++-
 include/linux/pmem.h              |   93 +++++++++++++++++++++++++++++++++++++
 lib/Kconfig                       |    3 +
 6 files changed, 183 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/pmem.h

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 73a4d0330ad0..6412d92e6f1e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -102,6 +102,7 @@ config X86
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select HAVE_ARCH_HUGE_VMAP if X86_64 || X86_PAE
 	select ARCH_HAS_SG_CHAIN
+	select ARCH_HAS_PMEM_API
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select GENERIC_IOMAP
diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
index b6f7457d12e4..6b8bd5c43bf6 100644
--- a/arch/x86/include/asm/cacheflush.h
+++ b/arch/x86/include/asm/cacheflush.h
@@ -4,6 +4,7 @@
 /* Caches aren't brain-dead on the intel. */
 #include <asm-generic/cacheflush.h>
 #include <asm/special_insns.h>
+#include <asm/uaccess.h>
 
 /*
  * The set_memory_* API can be used to change various attributes of a virtual
@@ -108,4 +109,27 @@ static inline int rodata_test(void)
 }
 #endif
 
+static inline void arch_persistent_copy(void *dst, const void *src, size_t n)
+{
+	/*
+	 * We are copying between two kernel buffers, if
+	 * __copy_from_user_inatomic_nocache() returns an error (page
+	 * fault) we would have already taken an unhandled fault before
+	 * the BUG_ON.  The BUG_ON is simply here to satisfy
+	 * __must_check and allow reuse of the common non-temporal store
+	 * implementation for persistent_copy().
+	 */
+	BUG_ON(__copy_from_user_inatomic_nocache(dst, src, n));
+}
+
+static inline void arch_persistent_sync(void)
+{
+	wmb();
+	pcommit_sfence();
+}
+
+static inline bool __arch_has_persistent_sync(void)
+{
+	return boot_cpu_has(X86_FEATURE_PCOMMIT);
+}
 #endif /* _ASM_X86_CACHEFLUSH_H */
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 956f2768bdc1..f3c32bb207cf 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -250,6 +250,12 @@ static inline void flush_write_buffers(void)
 #endif
 }
 
+static inline void *arch_persistent_remap(resource_size_t offset,
+	unsigned long size)
+{
+	return (void __force *) ioremap_cache(offset, size);
+}
+
 #endif /* __KERNEL__ */
 
 extern void native_io_delay(void);
diff --git a/drivers/block/pmem.c b/drivers/block/pmem.c
index 799acff6bd7c..10cbe557165c 100644
--- a/drivers/block/pmem.c
+++ b/drivers/block/pmem.c
@@ -23,9 +23,16 @@
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/slab.h>
+#include <linux/pmem.h>
 
 #define PMEM_MINORS		16
 
+struct pmem_ops {
+	void *(*remap)(resource_size_t offset, unsigned long size);
+	void (*copy)(void *dst, const void *src, size_t size);
+	void (*sync)(void);
+};
+
 struct pmem_device {
 	struct request_queue	*pmem_queue;
 	struct gendisk		*pmem_disk;
@@ -34,11 +41,54 @@ struct pmem_device {
 	phys_addr_t		phys_addr;
 	void			*virt_addr;
 	size_t			size;
+	struct pmem_ops		ops;
 };
 
 static int pmem_major;
 static atomic_t pmem_index;
 
+static void default_pmem_sync(void)
+{
+	wmb();
+}
+
+static void default_pmem_copy(void *dst, const void *src, size_t size)
+{
+	memcpy(dst, src, size);
+}
+
+static void pmem_ops_default_init(struct pmem_device *pmem)
+{
+	/*
+	 * These defaults seek to offer decent performance and minimize
+	 * the window between i/o completion and writes being durable on
+	 * media.  However, it is undefined / architecture specific
+	 * whether acknowledged data may be lost in transit if a power
+	 * fail occurs after bio_endio().
+	 */
+	pmem->ops.remap = memremap_wt;
+	pmem->ops.copy = default_pmem_copy;
+	pmem->ops.sync = default_pmem_sync;
+}
+
+static bool pmem_ops_init(struct pmem_device *pmem)
+{
+	if (IS_ENABLED(CONFIG_ARCH_HAS_PMEM_API) &&
+			arch_has_persistent_sync()) {
+		/*
+		 * This arch + cpu guarantees that bio_endio() == data
+		 * durable on media.
+		 */
+		pmem->ops.remap = persistent_remap;
+		pmem->ops.copy = persistent_copy;
+		pmem->ops.sync = persistent_sync;
+		return true;
+	}
+
+	pmem_ops_default_init(pmem);
+	return false;
+}
+
 static void pmem_do_bvec(struct pmem_device *pmem, struct page *page,
 			unsigned int len, unsigned int off, int rw,
 			sector_t sector)
@@ -51,7 +101,7 @@ static void pmem_do_bvec(struct pmem_device *pmem, struct page *page,
 		flush_dcache_page(page);
 	} else {
 		flush_dcache_page(page);
-		memcpy(pmem->virt_addr + pmem_off, mem + off, len);
+		pmem->ops.copy(pmem->virt_addr + pmem_off, mem + off, len);
 	}
 
 	kunmap_atomic(mem);
@@ -82,6 +132,8 @@ static void pmem_make_request(struct request_queue *q, struct bio *bio)
 		sector += bvec.bv_len >> 9;
 	}
 
+	if (rw)
+		pmem->ops.sync();
 out:
 	bio_endio(bio, err);
 }
@@ -131,6 +183,8 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
 
 	pmem->phys_addr = res->start;
 	pmem->size = resource_size(res);
+	if (!pmem_ops_init(pmem))
+		dev_warn(dev, "unable to guarantee persistence of writes\n");
 
 	err = -EINVAL;
 	if (!request_mem_region(pmem->phys_addr, pmem->size, "pmem")) {
@@ -143,7 +197,7 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
 	 * of the CPU caches in case of a crash.
 	 */
 	err = -ENOMEM;
-	pmem->virt_addr = memremap_wt(pmem->phys_addr, pmem->size);
+	pmem->virt_addr = pmem->ops.remap(pmem->phys_addr, pmem->size);
 	if (!pmem->virt_addr)
 		goto out_release_region;
 
diff --git a/include/linux/pmem.h b/include/linux/pmem.h
new file mode 100644
index 000000000000..e9a63ee1d361
--- /dev/null
+++ b/include/linux/pmem.h
@@ -0,0 +1,93 @@
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
+#ifndef __PMEM_H__
+#define __PMEM_H__
+
+#include <linux/io.h>
+#include <asm/cacheflush.h>
+
+/*
+ * Architectures that define ARCH_HAS_PMEM_API must provide
+ * implementations for arch_persistent_remap(), arch_persistent_copy(),
+ * arch_persistent_sync(), and __arch_has_persistent_sync().
+ */
+
+#ifdef CONFIG_ARCH_HAS_PMEM_API
+/**
+ * persistent_remap - map physical persistent memory for pmem api
+ * @offset: physical address of persistent memory
+ * @size: size of the mapping
+ *
+ * Establish a mapping of the architecture specific memory type expected
+ * by persistent_copy() and persistent_sync().  For example, it may be
+ * the case that an uncacheable or writethrough mapping is sufficient,
+ * or a writeback mapping provided persistent_copy() and
+ * persistent_sync() arrange for the data to be written through the
+ * cache to persistent media.
+ */
+static inline void *persistent_remap(resource_size_t offset, unsigned long size)
+{
+	return arch_persistent_remap(offset, size);
+}
+
+/**
+ * persistent_copy - copy data to persistent memory
+ * @dst: destination buffer for the copy
+ * @src: source buffer for the copy
+ * @n: length of the copy in bytes
+ *
+ * Perform a memory copy that results in the destination of the copy
+ * being effectively evicted from, or never written to, the processor
+ * cache hierarchy after the copy completes.  After persistent_copy()
+ * data may still reside in cpu or platform buffers, so this operation
+ * must be followed by a persistent_sync().
+ */
+static inline void persistent_copy(void *dst, const void *src, size_t n)
+{
+	arch_persistent_copy(dst, src, n);
+}
+
+/**
+ * persistent_sync - synchronize writes to persistent memory
+ *
+ * After a series of persistent_copy() operations this drains data from
+ * cpu write buffers and any platform (memory controller) buffers to
+ * ensure that written data is durable on persistent memory media.
+ */
+static inline void persistent_sync(void)
+{
+	arch_persistent_sync();
+}
+
+/**
+ * arch_has_persistent_sync - true if persistent_sync() ensures durability
+ *
+ * For a given cpu implementation within an architecture it is possible
+ * that persistent_sync() resolves to a nop.  In the case this returns
+ * false, pmem api users are unable to ensure durabilty and may want to
+ * fall back to a different data consistency model, or otherwise notify
+ * the user.
+ */
+static inline bool arch_has_persistent_sync(void)
+{
+	return __arch_has_persistent_sync();
+}
+#else
+/* undefined symbols */
+extern void *persistent_remap(resource_size_t offet, unsigned long size);
+extern void persistent_copy(void *dst, const void *src, size_t n);
+extern void persistent_sync(void);
+extern bool arch_has_persistent_sync(void);
+#endif /* CONFIG_ARCH_HAS_PMEM_API */
+
+#endif /* __PMEM_H__ */
diff --git a/lib/Kconfig b/lib/Kconfig
index 601965a948e8..e6a3c892d514 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -522,4 +522,7 @@ source "lib/fonts/Kconfig"
 config ARCH_HAS_SG_CHAIN
 	def_bool n
 
+config ARCH_HAS_PMEM_API
+	def_bool n
+
 endmenu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
