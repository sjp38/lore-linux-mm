Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B35D46B025F
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 11:51:05 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 24so2097495qts.23
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 08:51:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k6si518849qkc.302.2017.10.12.08.51.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 08:51:04 -0700 (PDT)
From: Pankaj Gupta <pagupta@redhat.com>
Subject: [RFC 1/2] pmem: Move reusable code to base header files
Date: Thu, 12 Oct 2017 21:20:25 +0530
Message-Id: <20171012155027.3277-2-pagupta@redhat.com>
In-Reply-To: <20171012155027.3277-1-pagupta@redhat.com>
References: <20171012155027.3277-1-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org
Cc: jack@suse.cz, stefanha@redhat.com, dan.j.williams@intel.com, riel@redhat.com, haozhong.zhang@intel.com, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross.zwisler@intel.com, david@redhat.com, xiaoguangrong.eric@gmail.com, pagupta@redhat.com

 This patch moves common code to base header files
 so that it can be used for both ACPI pmem and VIRTIO pmem
 drivers. More common code needs to be moved out in future
 based on functionality required for virtio_pmem driver and 
 coupling of code with existing ACPI pmem driver.

Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
---
 drivers/nvdimm/pfn.h        | 14 ------------
 drivers/nvdimm/pfn_devs.c   | 20 -----------------
 drivers/nvdimm/pmem.c       | 40 ----------------------------------
 drivers/nvdimm/pmem.h       |  5 +----
 include/linux/memremap.h    | 23 ++++++++++++++++++++
 include/linux/pfn.h         | 15 +++++++++++++
 include/linux/pmem_common.h | 52 +++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 91 insertions(+), 78 deletions(-)
 create mode 100644 include/linux/pmem_common.h

diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index dde9853453d3..1a853f651faf 100644
--- a/drivers/nvdimm/pfn.h
+++ b/drivers/nvdimm/pfn.h
@@ -40,18 +40,4 @@ struct nd_pfn_sb {
 	__le64 checksum;
 };
 
-#ifdef CONFIG_SPARSEMEM
-#define PFN_SECTION_ALIGN_DOWN(x) SECTION_ALIGN_DOWN(x)
-#define PFN_SECTION_ALIGN_UP(x) SECTION_ALIGN_UP(x)
-#else
-/*
- * In this case ZONE_DEVICE=n and we will disable 'pfn' device support,
- * but we still want pmem to compile.
- */
-#define PFN_SECTION_ALIGN_DOWN(x) (x)
-#define PFN_SECTION_ALIGN_UP(x) (x)
-#endif
-
-#define PHYS_SECTION_ALIGN_DOWN(x) PFN_PHYS(PFN_SECTION_ALIGN_DOWN(PHYS_PFN(x)))
-#define PHYS_SECTION_ALIGN_UP(x) PFN_PHYS(PFN_SECTION_ALIGN_UP(PHYS_PFN(x)))
 #endif /* __NVDIMM_PFN_H */
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 9576c444f0ab..52d6923e92fc 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -513,26 +513,6 @@ int nd_pfn_probe(struct device *dev, struct nd_namespace_common *ndns)
 }
 EXPORT_SYMBOL(nd_pfn_probe);
 
-/*
- * We hotplug memory at section granularity, pad the reserved area from
- * the previous section base to the namespace base address.
- */
-static unsigned long init_altmap_base(resource_size_t base)
-{
-	unsigned long base_pfn = PHYS_PFN(base);
-
-	return PFN_SECTION_ALIGN_DOWN(base_pfn);
-}
-
-static unsigned long init_altmap_reserve(resource_size_t base)
-{
-	unsigned long reserve = PHYS_PFN(SZ_8K);
-	unsigned long base_pfn = PHYS_PFN(base);
-
-	reserve += base_pfn - PFN_SECTION_ALIGN_DOWN(base_pfn);
-	return reserve;
-}
-
 static struct vmem_altmap *__nvdimm_setup_pfn(struct nd_pfn *nd_pfn,
 		struct resource *res, struct vmem_altmap *altmap)
 {
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 39dfd7affa31..5075131b715b 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -77,46 +77,6 @@ static blk_status_t pmem_clear_poison(struct pmem_device *pmem,
 	return rc;
 }
 
-static void write_pmem(void *pmem_addr, struct page *page,
-		unsigned int off, unsigned int len)
-{
-	unsigned int chunk;
-	void *mem;
-
-	while (len) {
-		mem = kmap_atomic(page);
-		chunk = min_t(unsigned int, len, PAGE_SIZE);
-		memcpy_flushcache(pmem_addr, mem + off, chunk);
-		kunmap_atomic(mem);
-		len -= chunk;
-		off = 0;
-		page++;
-		pmem_addr += PAGE_SIZE;
-	}
-}
-
-static blk_status_t read_pmem(struct page *page, unsigned int off,
-		void *pmem_addr, unsigned int len)
-{
-	unsigned int chunk;
-	int rc;
-	void *mem;
-
-	while (len) {
-		mem = kmap_atomic(page);
-		chunk = min_t(unsigned int, len, PAGE_SIZE);
-		rc = memcpy_mcsafe(mem + off, pmem_addr, chunk);
-		kunmap_atomic(mem);
-		if (rc)
-			return BLK_STS_IOERR;
-		len -= chunk;
-		off = 0;
-		page++;
-		pmem_addr += PAGE_SIZE;
-	}
-	return BLK_STS_OK;
-}
-
 static blk_status_t pmem_do_bvec(struct pmem_device *pmem, struct page *page,
 			unsigned int len, unsigned int off, bool is_write,
 			sector_t sector)
diff --git a/drivers/nvdimm/pmem.h b/drivers/nvdimm/pmem.h
index c5917f040fa7..8c5620614ec0 100644
--- a/drivers/nvdimm/pmem.h
+++ b/drivers/nvdimm/pmem.h
@@ -1,9 +1,6 @@
 #ifndef __NVDIMM_PMEM_H__
 #define __NVDIMM_PMEM_H__
-#include <linux/badblocks.h>
-#include <linux/types.h>
-#include <linux/pfn_t.h>
-#include <linux/fs.h>
+#include <linux/pmem_common.h>
 
 /* this definition is in it's own header for tools/testing/nvdimm to consume */
 struct pmem_device {
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 79f8ba7c3894..e4eb81020306 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -3,12 +3,35 @@
 #include <linux/mm.h>
 #include <linux/ioport.h>
 #include <linux/percpu-refcount.h>
+#include <linux/sizes.h>
+#include <linux/pfn.h>
 
 #include <asm/pgtable.h>
 
 struct resource;
 struct device;
 
+/*
+ * We hotplug memory at section granularity, pad the reserved area from
+ * the previous section base to the namespace base address.
+ */
+static inline unsigned long init_altmap_base(resource_size_t base)
+{
+	unsigned long base_pfn = PHYS_PFN(base);
+
+	return PFN_SECTION_ALIGN_DOWN(base_pfn);
+}
+
+static inline unsigned long init_altmap_reserve(resource_size_t base)
+{
+	unsigned long reserve = PHYS_PFN(SZ_8K);
+	unsigned long base_pfn = PHYS_PFN(base);
+
+	reserve += base_pfn - PFN_SECTION_ALIGN_DOWN(base_pfn);
+	return reserve;
+}
+
+
 /**
  * struct vmem_altmap - pre-allocated storage for vmemmap_populate
  * @base_pfn: base of the entire dev_pagemap mapping
diff --git a/include/linux/pfn.h b/include/linux/pfn.h
index 1132953235c0..2d8f69cc1470 100644
--- a/include/linux/pfn.h
+++ b/include/linux/pfn.h
@@ -20,4 +20,19 @@ typedef struct {
 #define PFN_PHYS(x)	((phys_addr_t)(x) << PAGE_SHIFT)
 #define PHYS_PFN(x)	((unsigned long)((x) >> PAGE_SHIFT))
 
+#ifdef CONFIG_SPARSEMEM
+#define PFN_SECTION_ALIGN_DOWN(x) SECTION_ALIGN_DOWN(x)
+#define PFN_SECTION_ALIGN_UP(x) SECTION_ALIGN_UP(x)
+#else
+/*
+ * In this case ZONE_DEVICE=n and we will disable 'pfn' device support,
+ * but we still want pmem to compile.
+ */
+#define PFN_SECTION_ALIGN_DOWN(x) (x)
+#define PFN_SECTION_ALIGN_UP(x) (x)
+#endif
+
+#define PHYS_SECTION_ALIGN_DOWN(x) PFN_PHYS(PFN_SECTION_ALIGN_DOWN(PHYS_PFN(x)))
+#define PHYS_SECTION_ALIGN_UP(x) PFN_PHYS(PFN_SECTION_ALIGN_UP(PHYS_PFN(x)))
+
 #endif
diff --git a/include/linux/pmem_common.h b/include/linux/pmem_common.h
new file mode 100644
index 000000000000..e2e718c74b3f
--- /dev/null
+++ b/include/linux/pmem_common.h
@@ -0,0 +1,52 @@
+#ifndef __PMEM_COMMON_H__
+#define __PMEM_COMMON_H__
+
+#include <linux/badblocks.h>
+#include <linux/types.h>
+#include <linux/pfn_t.h>
+#include <linux/fs.h>
+#include <linux/pfn_t.h>
+#include <linux/memremap.h>
+#include <linux/vmalloc.h>
+#include <linux/mmzone.h>
+#include <linux/dax.h>
+#include <linux/highmem.h>
+#include <linux/blkdev.h>
+
+static void write_pmem(void *pmem_addr, struct page *page,
+	unsigned int off, unsigned int len)
+{
+	void *mem = kmap_atomic(page);
+
+	memcpy_flushcache(pmem_addr, mem + off, len);
+	kunmap_atomic(mem);
+}
+
+static blk_status_t read_pmem(struct page *page, unsigned int off,
+	void *pmem_addr, unsigned int len)
+{
+	int rc;
+	void *mem = kmap_atomic(page);
+
+	rc = memcpy_mcsafe(mem + off, pmem_addr, len);
+	kunmap_atomic(mem);
+	if (rc)
+		return BLK_STS_IOERR;
+	return BLK_STS_OK;
+}
+
+#endif /* __PMEM_COMMON_H__ */
+
+#ifdef CONFIG_ARCH_HAS_PMEM_API
+#define ARCH_MEMREMAP_PMEM MEMREMAP_WB
+void arch_wb_cache_pmem(void *addr, size_t size);
+void arch_invalidate_pmem(void *addr, size_t size);
+#else
+#define ARCH_MEMREMAP_PMEM MEMREMAP_WT
+static inline void arch_wb_cache_pmem(void *addr, size_t size)
+{
+}
+static inline void arch_invalidate_pmem(void *addr, size_t size)
+{
+}
+#endif
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
