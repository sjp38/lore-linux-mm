Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 23AB66B0255
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:06:53 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so13920351pdb.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:06:52 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id v11si1302371pas.164.2015.08.12.20.06.51
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:06:52 -0700 (PDT)
Subject: [PATCH v5 2/5] allow mapping page-less memremaped areas into KVA
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:01:09 -0400
Message-ID: <20150813030109.36703.21738.stgit@otcpl-skl-sds-2.jf.intel.com>
In-Reply-To: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: axboe@kernel.dk, riel@redhat.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, mgorman@suse.de, torvalds@linux-foundation.org, hch@lst.de

Introduce a type that encapsulates a page-frame-number that can also be
used to encode other information.  This other information is the
traditional "page_link" encoding in a scatterlist, but can also denote
"device memory".  Where "device memory" is a set of pfns that are not
part of the kernel's linear mapping, but are accessed via the same
memory controller as ram.  The motivation for this conversion is large
capacity persistent memory that does not enjoy struct page coverage,
entries in 'memmap' by default.

This type will be used in replace usage of 'struct page *' in cases
where only a pfn is required, i.e. scatterlists for drivers, dma mapping
api, and potentially biovecs for the block layer.  The operations in
those i/o paths that formerly required a 'struct page *' are converted
to use __pfn_t aware equivalent helpers.

It turns out that while 'struct page' references are used broadly in the
kernel I/O stacks the usage of 'struct page' based capabilities is very
shallow for block-i/o.  It is only used for populating bio_vecs and
scatterlists for the retrieval of dma addresses, and for temporary
kernel mappings (kmap).  Aside from kmap, these usages can be trivially
converted to operate on a pfn.

Indeed, kmap_atomic() is more problematic as it uses mm infrastructure,
via struct page, to setup and track temporary kernel mappings.  It would
be unfortunate if the kmap infrastructure escaped its 32-bit/HIGHMEM
bonds and leaked into 64-bit code.  Thankfully, it seems all that is
needed here is to convert kmap_atomic() callers, that want to opt-in to
supporting persistent memory, to use a new kmap_atomic_pfn_t().  Where
kmap_atomic_pfn_t() is enabled to re-use the existing ioremap() mapping
established by the driver for persistent memory.

Note, that as far as conceptually understanding __pfn_t is concerned,
'persistent memory' is really any address range in host memory not
covered by memmap.  Contrast this with pure iomem that is on an mmio
mapped bus like PCI and cannot be converted to a dma_addr_t by "pfn <<
PAGE_SHIFT".

It would be unfortunate if the kmap infrastructure escaped its current
32-bit/HIGHMEM bonds and leaked into 64-bit code.  Instead, if the user
has enabled CONFIG_DEV_PFN we direct the kmap_atomic_pfn_t()
implementation to scan a list of pre-mapped persistent memory address
ranges inserted by the pmem driver.

The __pfn_t to resource lookup is indeed inefficient walking of a linked list,
but there are two mitigating factors:

1/ The number of persistent memory ranges is bounded by the number of
   DIMMs which is on the order of 10s of DIMMs, not hundreds.

2/ The lookup yields the entire range, if it becomes inefficient to do a
   kmap_atomic_pfn_t() a PAGE_SIZE at a time the caller can take
   advantage of the fact that the lookup can be amortized for all kmap
   operations it needs to perform in a given range.

[hch: various changes]
Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/kmap_pfn.h |   31 ++++++++++++
 include/linux/mm.h       |   57 ++++++++++++++++++++++
 mm/Kconfig               |    3 +
 mm/Makefile              |    1 
 mm/kmap_pfn.c            |  117 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 209 insertions(+)
 create mode 100644 include/linux/kmap_pfn.h
 create mode 100644 mm/kmap_pfn.c

diff --git a/include/linux/kmap_pfn.h b/include/linux/kmap_pfn.h
new file mode 100644
index 000000000000..fa44971d8e95
--- /dev/null
+++ b/include/linux/kmap_pfn.h
@@ -0,0 +1,31 @@
+#ifndef _LINUX_KMAP_PFN_H
+#define _LINUX_KMAP_PFN_H 1
+
+#include <linux/highmem.h>
+
+struct device;
+struct resource;
+#ifdef CONFIG_KMAP_PFN
+extern void *kmap_atomic_pfn_t(__pfn_t pfn);
+extern void kunmap_atomic_pfn_t(void *addr);
+extern int devm_register_kmap_pfn_range(struct device *dev,
+		struct resource *res, void *base);
+#else
+static inline void *kmap_atomic_pfn_t(__pfn_t pfn)
+{
+	return kmap_atomic(__pfn_t_to_page(pfn));
+}
+
+static inline void kunmap_atomic_pfn_t(void *addr)
+{
+	__kunmap_atomic(addr);
+}
+
+static inline int devm_register_kmap_pfn_range(struct device *dev,
+		struct resource *res, void *base)
+{
+	return 0;
+}
+#endif /* CONFIG_KMAP_PFN */
+
+#endif /* _LINUX_KMAP_PFN_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 84b05ebedb2d..57ba5ca6be72 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -924,6 +924,63 @@ static inline void set_page_links(struct page *page, enum zone_type zone,
 }
 
 /*
+ * __pfn_t: encapsulates a page-frame number that is optionally backed
+ * by memmap (struct page).  This type will be used in place of a
+ * 'struct page *' instance in contexts where unmapped memory (usually
+ * persistent memory) is being referenced (scatterlists for drivers,
+ * biovecs for the block layer, etc).  Whether a __pfn_t has a struct
+ * page backing is indicated by flags in the low bits of the value;
+ */
+typedef struct {
+	unsigned long val;
+} __pfn_t;
+
+/*
+ * PFN_SG_CHAIN - pfn is a pointer to the next scatterlist entry
+ * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
+ * PFN_DEV - pfn is not covered by system memmap
+ */
+enum {
+	PFN_MASK = (1UL << PAGE_SHIFT) - 1,
+	PFN_SG_CHAIN = (1UL << 0),
+	PFN_SG_LAST = (1UL << 1),
+#ifdef CONFIG_KMAP_PFN
+	PFN_DEV = (1UL << 2),
+#else
+	PFN_DEV = 0,
+#endif
+};
+
+static inline bool __pfn_t_has_page(__pfn_t pfn)
+{
+	return (pfn.val & PFN_DEV) == 0;
+}
+
+static inline unsigned long __pfn_t_to_pfn(__pfn_t pfn)
+{
+	return pfn.val >> PAGE_SHIFT;
+}
+
+static inline struct page *__pfn_t_to_page(__pfn_t pfn)
+{
+	if (!__pfn_t_has_page(pfn))
+		return NULL;
+	return pfn_to_page(__pfn_t_to_pfn(pfn));
+}
+
+static inline dma_addr_t __pfn_t_to_phys(__pfn_t pfn)
+{
+	return __pfn_to_phys(__pfn_t_to_pfn(pfn));
+}
+
+static inline __pfn_t page_to_pfn_t(struct page *page)
+{
+	__pfn_t pfn = { .val = page_to_pfn(page) << PAGE_SHIFT, };
+
+	return pfn;
+}
+
+/*
  * Some inline functions in vmstat.h depend on page_zone()
  */
 #include <linux/vmstat.h>
diff --git a/mm/Kconfig b/mm/Kconfig
index e79de2bd12cd..ed1be8ff982e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -654,3 +654,6 @@ config DEFERRED_STRUCT_PAGE_INIT
 	  when kswapd starts. This has a potential performance impact on
 	  processes running early in the lifetime of the systemm until kswapd
 	  finishes the initialisation.
+
+config KMAP_PFN
+	bool
diff --git a/mm/Makefile b/mm/Makefile
index 98c4eaeabdcb..f7b27958ea69 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -78,3 +78,4 @@ obj-$(CONFIG_CMA)	+= cma.o
 obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
 obj-$(CONFIG_PAGE_EXTENSION) += page_ext.o
 obj-$(CONFIG_CMA_DEBUGFS) += cma_debug.o
+obj-$(CONFIG_KMAP_PFN) += kmap_pfn.o
diff --git a/mm/kmap_pfn.c b/mm/kmap_pfn.c
new file mode 100644
index 000000000000..2d58e167dfbc
--- /dev/null
+++ b/mm/kmap_pfn.c
@@ -0,0 +1,117 @@
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
+#include <linux/rcupdate.h>
+#include <linux/rculist.h>
+#include <linux/highmem.h>
+#include <linux/device.h>
+#include <linux/mutex.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+
+static LIST_HEAD(ranges);
+static DEFINE_MUTEX(register_lock);
+
+struct kmap {
+	struct list_head list;
+	struct resource *res;
+	struct device *dev;
+	void *base;
+};
+
+static void teardown_kmap(void *data)
+{
+	struct kmap *kmap = data;
+
+	dev_dbg(kmap->dev, "kmap unregister %pr\n", kmap->res);
+	mutex_lock(&register_lock);
+	list_del_rcu(&kmap->list);
+	mutex_unlock(&register_lock);
+	synchronize_rcu();
+	kfree(kmap);
+}
+
+int devm_register_kmap_pfn_range(struct device *dev, struct resource *res,
+		void *base)
+{
+	struct kmap *kmap = kzalloc(sizeof(*kmap), GFP_KERNEL);
+	int rc;
+
+	if (!kmap)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&kmap->list);
+	kmap->res = res;
+	kmap->base = base;
+	kmap->dev = dev;
+	rc = devm_add_action(dev, teardown_kmap, kmap);
+	if (rc) {
+		kfree(kmap);
+		return rc;
+	}
+	dev_dbg(kmap->dev, "kmap register %pr\n", kmap->res);
+
+	mutex_lock(&register_lock);
+	list_add_rcu(&kmap->list, &ranges);
+	mutex_unlock(&register_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(devm_register_kmap_pfn_range);
+
+void *kmap_atomic_pfn_t(__pfn_t pfn)
+{
+	struct page *page = __pfn_t_to_page(pfn);
+	resource_size_t addr;
+	struct kmap *kmap;
+
+	rcu_read_lock();
+	if (page)
+		return kmap_atomic(page);
+	addr = __pfn_t_to_phys(pfn);
+	list_for_each_entry_rcu(kmap, &ranges, list)
+		if (addr >= kmap->res->start && addr <= kmap->res->end)
+			return kmap->base + addr - kmap->res->start;
+
+	/* only unlock in the error case */
+	rcu_read_unlock();
+	return NULL;
+}
+EXPORT_SYMBOL(kmap_atomic_pfn_t);
+
+void kunmap_atomic_pfn_t(void *addr)
+{
+	struct kmap *kmap;
+	bool dev_pfn = false;
+
+	if (!addr)
+		return;
+
+	/*
+	 * If the original __pfn_t had an entry in the memmap (i.e.
+	 * !PFN_DEV) then 'addr' will be outside of the registered
+	 * ranges and we'll need to kunmap_atomic() it.
+	 */
+	list_for_each_entry_rcu(kmap, &ranges, list)
+		if (addr < kmap->base + resource_size(kmap->res)
+				&& addr >= kmap->base) {
+			dev_pfn = true;
+			break;
+		}
+
+	if (!dev_pfn)
+		kunmap_atomic(addr);
+
+	/* signal that we are done with the range */
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(kunmap_atomic_pfn_t);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
