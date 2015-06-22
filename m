Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 05C856B0073
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:30:55 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so134253471pdb.1
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 01:30:54 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id xq11si28523081pac.200.2015.06.22.01.30.53
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 01:30:53 -0700 (PDT)
Subject: [PATCH v5 6/6] arch,
 x86: pmem api for ensuring durability of persistent memory updates
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 22 Jun 2015 04:24:50 -0400
Message-ID: <20150622082449.35954.91411.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org
Cc: jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, benh@kernel.crashing.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org, hch@lst.de

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Based on an original patch by Ross Zwisler [1].

Writes to persistent memory have the potential to be posted to cpu
cache, cpu write buffers, and platform write buffers (memory controller)
before being committed to persistent media.  Provide apis,
memcpy_to_pmem(), wmb_pmem(), and memremap_pmem(), to write data to
pmem and assert that it is durable in PMEM (a persistent linear address
range).  A '__pmem' attribute is added so sparse can track proper usage
of pointers to pmem.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-May/000932.html

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
[djbw: various reworks]
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/Kconfig                  |    1 
 arch/x86/include/asm/cacheflush.h |   71 ++++++++++++++++++++++++
 arch/x86/include/asm/io.h         |    6 ++
 drivers/block/pmem.c              |   45 +++++++++++++--
 include/linux/compiler.h          |    2 +
 include/linux/pmem.h              |  110 +++++++++++++++++++++++++++++++++++++
 lib/Kconfig                       |    3 +
 7 files changed, 231 insertions(+), 7 deletions(-)
 create mode 100644 include/linux/pmem.h

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index f16caf7eac27..5dfb8f31ac48 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -28,6 +28,7 @@ config X86
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_MEMREMAP
+	select ARCH_HAS_PMEM_API
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
index b6f7457d12e4..2c78c796d679 100644
--- a/arch/x86/include/asm/cacheflush.h
+++ b/arch/x86/include/asm/cacheflush.h
@@ -4,6 +4,7 @@
 /* Caches aren't brain-dead on the intel. */
 #include <asm-generic/cacheflush.h>
 #include <asm/special_insns.h>
+#include <asm/uaccess.h>
 
 /*
  * The set_memory_* API can be used to change various attributes of a virtual
@@ -108,4 +109,74 @@ static inline int rodata_test(void)
 }
 #endif
 
+#ifdef ARCH_HAS_NOCACHE_UACCESS
+
+/**
+ * arch_memcpy_to_pmem - copy data to persistent memory
+ * @dst: destination buffer for the copy
+ * @src: source buffer for the copy
+ * @n: length of the copy in bytes
+ *
+ * Copy data to persistent memory media via non-temporal stores so that
+ * a subsequent arch_wmb_pmem() can flush cpu and memory controller
+ * write buffers to guarantee durability.
+ */
+static inline void arch_memcpy_to_pmem(void __pmem *dst, const void *src, size_t n)
+{
+	int unwritten;
+
+	/*
+	 * We are copying between two kernel buffers, if
+	 * __copy_from_user_inatomic_nocache() returns an error (page
+	 * fault) we would have already reported a general protection fault
+	 * before the WARN+BUG.
+	 */
+	unwritten = __copy_from_user_inatomic_nocache((void __force *) dst,
+			(void __user *) src, n);
+	if (WARN(unwritten, "%s: fault copying %p <- %p unwritten: %d\n",
+				__func__, dst, src, unwritten))
+		BUG();
+}
+
+/**
+ * arch_wmb_pmem - synchronize writes to persistent memory
+ *
+ * After a series of arch_memcpy_to_pmem() operations this drains data
+ * from cpu write buffers and any platform (memory controller) buffers
+ * to ensure that written data is durable on persistent memory media.
+ */
+static inline void arch_wmb_pmem(void)
+{
+	/*
+	 * wmb() to 'sfence' all previous writes such that they are
+	 * architecturally visible to 'pcommit'.  Note, that we've
+	 * already arranged for pmem writes to avoid the cache via
+	 * arch_memcpy_to_pmem().
+	 */
+	wmb();
+	pcommit_sfence();
+}
+
+static inline bool __arch_has_wmb_pmem(void)
+{
+#ifdef CONFIG_X86_64
+	/*
+	 * We require that wmb() be an 'sfence', that is only guaranteed on
+	 * 64-bit builds
+	 */
+	return static_cpu_has(X86_FEATURE_PCOMMIT);
+#else
+	return false;
+#endif
+}
+#else /* ARCH_HAS_NOCACHE_UACCESS i.e. ARCH=um */
+extern void arch_memcpy_to_pmem(void __pmem *dst, const void *src, size_t n);
+extern void arch_wmb_pmem(void);
+
+static inline bool __arch_has_wmb_pmem(void)
+{
+	return false;
+}
+#endif
+
 #endif /* _ASM_X86_CACHEFLUSH_H */
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 97ae3b748d9e..0d3e43f679aa 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -249,6 +249,12 @@ static inline void flush_write_buffers(void)
 #endif
 }
 
+static inline void __pmem *arch_memremap_pmem(resource_size_t offset,
+	unsigned long size)
+{
+	return (void __force __pmem *) ioremap_cache(offset, size);
+}
+
 #endif /* __KERNEL__ */
 
 extern void native_io_delay(void);
diff --git a/drivers/block/pmem.c b/drivers/block/pmem.c
index b00b97314b57..8507a5fff464 100644
--- a/drivers/block/pmem.c
+++ b/drivers/block/pmem.c
@@ -23,6 +23,7 @@
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/slab.h>
+#include <linux/pmem.h>
 #include <linux/io.h>
 
 #define PMEM_MINORS		16
@@ -33,26 +34,47 @@ struct pmem_device {
 
 	/* One contiguous memory region per device */
 	phys_addr_t		phys_addr;
-	void			*virt_addr;
+	void __pmem		*virt_addr;
 	size_t			size;
 };
 
 static int pmem_major;
 static atomic_t pmem_index;
 
+/*
+ * These defaults seek to offer decent performance and minimize the
+ * window between i/o completion and writes being durable on media.
+ * However, it is undefined / architecture specific whether
+ * default_memremap_pmem + default_memcpy_to_pmem is sufficient for
+ * making data durable relative to i/o completion.
+ */
+static void default_memcpy_to_pmem(void __pmem *dst, const void *src, size_t size)
+{
+	memcpy((void __force *) dst, src, size);
+}
+
+static void __pmem *default_memremap_pmem(resource_size_t offset, unsigned long size)
+{
+	return (void __pmem *)memremap_wt(offset, size);
+}
+
 static void pmem_do_bvec(struct pmem_device *pmem, struct page *page,
 			unsigned int len, unsigned int off, int rw,
 			sector_t sector)
 {
 	void *mem = kmap_atomic(page);
 	size_t pmem_off = sector << 9;
+	void __pmem *pmem_addr = pmem->virt_addr + pmem_off;
 
 	if (rw == READ) {
-		memcpy(mem + off, pmem->virt_addr + pmem_off, len);
+		memcpy_from_pmem(mem + off, pmem_addr, len);
 		flush_dcache_page(page);
 	} else {
 		flush_dcache_page(page);
-		memcpy(pmem->virt_addr + pmem_off, mem + off, len);
+		if (arch_has_pmem_api())
+			memcpy_to_pmem(pmem_addr, mem + off, len);
+		else
+			default_memcpy_to_pmem(pmem_addr, mem + off, len);
 	}
 
 	kunmap_atomic(mem);
@@ -83,6 +105,8 @@ static void pmem_make_request(struct request_queue *q, struct bio *bio)
 		sector += bvec.bv_len >> 9;
 	}
 
+	if (rw && arch_has_pmem_api())
+		wmb_pmem();
 out:
 	bio_endio(bio, err);
 }
@@ -107,7 +131,8 @@ static long pmem_direct_access(struct block_device *bdev, sector_t sector,
 	if (!pmem)
 		return -ENODEV;
 
-	*kaddr = pmem->virt_addr + offset;
+	/* FIXME convert DAX to comprehend that this mapping has a lifetime */
+	*kaddr = (void __force *) pmem->virt_addr + offset;
 	*pfn = (pmem->phys_addr + offset) >> PAGE_SHIFT;
 
 	return pmem->size - offset;
@@ -132,6 +157,8 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
 
 	pmem->phys_addr = res->start;
 	pmem->size = resource_size(res);
+	if (!arch_has_pmem_api())
+		dev_warn(dev, "unable to guarantee persistence of writes\n");
 
 	err = -EINVAL;
 	if (!request_mem_region(pmem->phys_addr, pmem->size, "pmem")) {
@@ -144,7 +171,11 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
 	 * of the CPU caches in case of a crash.
 	 */
 	err = -ENOMEM;
-	pmem->virt_addr = memremap_wt(pmem->phys_addr, pmem->size);
+	if (arch_has_pmem_api())
+		pmem->virt_addr = memremap_pmem(pmem->phys_addr, pmem->size);
+	else
+		pmem->virt_addr = default_memremap_pmem(pmem->phys_addr,
+				pmem->size);
 	if (!pmem->virt_addr)
 		goto out_release_region;
 
@@ -180,7 +211,7 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
 out_free_queue:
 	blk_cleanup_queue(pmem->pmem_queue);
 out_unmap:
-	memunmap(pmem->virt_addr);
+	memunmap_pmem(pmem->virt_addr);
 out_release_region:
 	release_mem_region(pmem->phys_addr, pmem->size);
 out_free_dev:
@@ -194,7 +225,7 @@ static void pmem_free(struct pmem_device *pmem)
 	del_gendisk(pmem->pmem_disk);
 	put_disk(pmem->pmem_disk);
 	blk_cleanup_queue(pmem->pmem_queue);
-	memunmap(pmem->virt_addr);
+	memunmap_pmem(pmem->virt_addr);
 	release_mem_region(pmem->phys_addr, pmem->size);
 	kfree(pmem);
 }
diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index 05be2352fef8..26fc8bc77f85 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -21,6 +21,7 @@
 # define __rcu		__attribute__((noderef, address_space(4)))
 #else
 # define __rcu
+# define __pmem		__attribute__((noderef, address_space(5)))
 #endif
 extern void __chk_user_ptr(const volatile void __user *);
 extern void __chk_io_ptr(const volatile void __iomem *);
@@ -42,6 +43,7 @@ extern void __chk_io_ptr(const volatile void __iomem *);
 # define __cond_lock(x,c) (c)
 # define __percpu
 # define __rcu
+# define __pmem
 #endif
 
 /* Indirect macros required for expanded argument pasting, eg. __LINE__. */
diff --git a/include/linux/pmem.h b/include/linux/pmem.h
new file mode 100644
index 000000000000..5575b524c51a
--- /dev/null
+++ b/include/linux/pmem.h
@@ -0,0 +1,110 @@
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
+ * implementations for arch_memremap_pmem(), arch_memcpy_to_pmem(),
+ * arch_wmb_pmem(), and __arch_has_wmb_pmem().
+ */
+
+#ifdef CONFIG_ARCH_HAS_PMEM_API
+/**
+ * memremap_pmem - map physical persistent memory for pmem api
+ * @offset: physical address of persistent memory
+ * @size: size of the mapping
+ *
+ * Establish a mapping of the architecture specific memory type expected
+ * by memcpy_to_pmem() and wmb_pmem().  For example, it may be
+ * the case that an uncacheable or writethrough mapping is sufficient,
+ * or a writeback mapping provided memcpy_to_pmem() and
+ * wmb_pmem() arrange for the data to be written through the
+ * cache to persistent media.
+ */
+static inline void __pmem *memremap_pmem(resource_size_t offset, unsigned long size)
+{
+	return arch_memremap_pmem(offset, size);
+}
+
+/**
+ * memcpy_to_pmem - copy data to persistent memory
+ * @dst: destination buffer for the copy
+ * @src: source buffer for the copy
+ * @n: length of the copy in bytes
+ *
+ * Perform a memory copy that results in the destination of the copy
+ * being effectively evicted from, or never written to, the processor
+ * cache hierarchy after the copy completes.  After memcpy_to_pmem()
+ * data may still reside in cpu or platform buffers, so this operation
+ * must be followed by a wmb_pmem().
+ */
+static inline void memcpy_to_pmem(void __pmem *dst, const void *src, size_t n)
+{
+	arch_memcpy_to_pmem(dst, src, n);
+}
+
+/**
+ * wmb_pmem - synchronize writes to persistent memory
+ *
+ * After a series of memcpy_to_pmem() operations this drains data from
+ * cpu write buffers and any platform (memory controller) buffers to
+ * ensure that written data is durable on persistent memory media.
+ */
+static inline void wmb_pmem(void)
+{
+	arch_wmb_pmem();
+}
+
+/**
+ * arch_has_wmb_pmem - true if wmb_pmem() ensures durability
+ *
+ * For a given cpu implementation within an architecture it is possible
+ * that wmb_pmem() resolves to a nop.  In the case this returns
+ * false, pmem api users are unable to ensure durability and may want to
+ * fall back to a different data consistency model, or otherwise notify
+ * the user.
+ */
+static inline bool arch_has_wmb_pmem(void)
+{
+	return __arch_has_wmb_pmem();
+}
+#else
+/* undefined symbols */
+extern void __pmem *memremap_pmem(resource_size_t offet, unsigned long size);
+extern void memcpy_to_pmem(void __pmem *dst, const void *src, size_t n);
+extern void wmb_pmem(void);
+static inline bool arch_has_wmb_pmem(void)
+{
+	return false;
+}
+#endif /* CONFIG_ARCH_HAS_PMEM_API */
+
+static inline void memcpy_from_pmem(void *dst, void __pmem const *src, size_t size)
+{
+	memcpy(dst, (void __force const *) src, size);
+}
+
+static inline void memunmap_pmem(void __pmem *addr)
+{
+	memunmap((void __force *) addr);
+}
+
+static inline bool arch_has_pmem_api(void)
+{
+	return IS_ENABLED(CONFIG_ARCH_HAS_PMEM_API) && arch_has_wmb_pmem();
+}
+#endif /* __PMEM_H__ */
diff --git a/lib/Kconfig b/lib/Kconfig
index bc7bc0278921..0d28cc560c6b 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -525,4 +525,7 @@ config ARCH_HAS_SG_CHAIN
 config ARCH_HAS_MEMREMAP
 	bool
 
+config ARCH_HAS_PMEM_API
+	bool
+
 endmenu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
