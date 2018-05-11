Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 109D36B06A4
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:09:19 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id d61-v6so4277335otb.21
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:09:19 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u88-v6si1279751otb.285.2018.05.11.12.09.17
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:09:17 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 19/40] iommu: Add generic PASID table library
Date: Fri, 11 May 2018 20:06:20 +0100
Message-Id: <20180511190641.23008-20-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

Add a small API within the IOMMU subsystem to handle different formats of
PASID tables. It uses the same principle as io-pgtable:

* The IOMMU driver registers a PASID table with some invalidation
  callbacks.
* The pasid-table lib allocates a set of tables of the right format, and
  returns an iommu_pasid_table_ops structure.
* The IOMMU driver allocates entries and writes them using the provided
  ops.
* The pasid-table lib calls the IOMMU driver back for invalidation when
  necessary.
* The IOMMU driver unregisters the ops which frees the tables when
  finished.

An example user will be Arm SMMU in a subsequent patch. Other IOMMU
drivers (e.g. paravirtualized ones) will be able to use the same PASID
table code.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2: remove free_entry from the ops. The table driver now registers a
standalone release callback to each entry, because it may be freed after
the tables.
---
 drivers/iommu/Kconfig             |   7 ++
 drivers/iommu/Makefile            |   1 +
 drivers/iommu/iommu-pasid-table.c |  51 +++++++++++
 drivers/iommu/iommu-pasid-table.h | 146 ++++++++++++++++++++++++++++++
 4 files changed, 205 insertions(+)
 create mode 100644 drivers/iommu/iommu-pasid-table.c
 create mode 100644 drivers/iommu/iommu-pasid-table.h

diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index 09f13a7c4b60..fae34d6a522d 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -60,6 +60,13 @@ config IOMMU_IO_PGTABLE_ARMV7S_SELFTEST
 
 endmenu
 
+menu "Generic PASID table support"
+
+config IOMMU_PASID_TABLE
+	bool
+
+endmenu
+
 config IOMMU_IOVA
 	tristate
 
diff --git a/drivers/iommu/Makefile b/drivers/iommu/Makefile
index 4b744e399a1b..8e335a7f10aa 100644
--- a/drivers/iommu/Makefile
+++ b/drivers/iommu/Makefile
@@ -8,6 +8,7 @@ obj-$(CONFIG_IOMMU_PAGE_FAULT) += io-pgfault.o
 obj-$(CONFIG_IOMMU_IO_PGTABLE) += io-pgtable.o
 obj-$(CONFIG_IOMMU_IO_PGTABLE_ARMV7S) += io-pgtable-arm-v7s.o
 obj-$(CONFIG_IOMMU_IO_PGTABLE_LPAE) += io-pgtable-arm.o
+obj-$(CONFIG_IOMMU_PASID_TABLE) += iommu-pasid-table.o
 obj-$(CONFIG_IOMMU_IOVA) += iova.o
 obj-$(CONFIG_OF_IOMMU)	+= of_iommu.o
 obj-$(CONFIG_MSM_IOMMU) += msm_iommu.o
diff --git a/drivers/iommu/iommu-pasid-table.c b/drivers/iommu/iommu-pasid-table.c
new file mode 100644
index 000000000000..ed62591dcc26
--- /dev/null
+++ b/drivers/iommu/iommu-pasid-table.c
@@ -0,0 +1,51 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * PASID table management for the IOMMU
+ *
+ * Copyright (C) 2018 ARM Ltd.
+ */
+
+#include <linux/kernel.h>
+
+#include "iommu-pasid-table.h"
+
+static const struct iommu_pasid_init_fns *
+pasid_table_init_fns[PASID_TABLE_NUM_FMTS] = {
+};
+
+struct iommu_pasid_table_ops *
+iommu_alloc_pasid_ops(enum iommu_pasid_table_fmt fmt,
+		      struct iommu_pasid_table_cfg *cfg, void *cookie)
+{
+	struct iommu_pasid_table *table;
+	const struct iommu_pasid_init_fns *fns;
+
+	if (fmt >= PASID_TABLE_NUM_FMTS)
+		return NULL;
+
+	fns = pasid_table_init_fns[fmt];
+	if (!fns)
+		return NULL;
+
+	table = fns->alloc(cfg, cookie);
+	if (!table)
+		return NULL;
+
+	table->fmt = fmt;
+	table->cookie = cookie;
+	table->cfg = *cfg;
+
+	return &table->ops;
+}
+
+void iommu_free_pasid_ops(struct iommu_pasid_table_ops *ops)
+{
+	struct iommu_pasid_table *table;
+
+	if (!ops)
+		return;
+
+	table = container_of(ops, struct iommu_pasid_table, ops);
+	iommu_pasid_flush_all(table);
+	pasid_table_init_fns[table->fmt]->free(table);
+}
diff --git a/drivers/iommu/iommu-pasid-table.h b/drivers/iommu/iommu-pasid-table.h
new file mode 100644
index 000000000000..d5bd098fef19
--- /dev/null
+++ b/drivers/iommu/iommu-pasid-table.h
@@ -0,0 +1,146 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * PASID table management for the IOMMU
+ *
+ * Copyright (C) 2018 ARM Ltd.
+ */
+#ifndef __IOMMU_PASID_TABLE_H
+#define __IOMMU_PASID_TABLE_H
+
+#include <linux/bug.h>
+#include <linux/types.h>
+#include "io-pgtable.h"
+
+struct mm_struct;
+
+enum iommu_pasid_table_fmt {
+	PASID_TABLE_NUM_FMTS,
+};
+
+/**
+ * iommu_pasid_entry - Entry of a PASID table
+ *
+ * @tag: architecture-specific data needed to uniquely identify the entry. Most
+ * notably used for TLB invalidation
+ * @release: function that frees the entry and its content. PASID entries may be
+ * freed well after the PASID table ops are released, and may be shared between
+ * different PASID tables, so the release method has to be standalone.
+ */
+struct iommu_pasid_entry {
+	u64 tag;
+	void (*release)(struct iommu_pasid_entry *);
+};
+
+/**
+ * iommu_pasid_table_ops - Operations on a PASID table
+ *
+ * @alloc_shared_entry: allocate an entry for sharing an mm (SVA). Returns the
+ * pointer to a new entry or an error.
+ * @alloc_priv_entry: allocate an entry for map/unmap operations. Returns the
+ * pointer to a new entry or an error.
+ * @set_entry: write PASID table entry
+ * @clear_entry: clear PASID table entry
+ */
+struct iommu_pasid_table_ops {
+	struct iommu_pasid_entry *
+	(*alloc_shared_entry)(struct iommu_pasid_table_ops *ops,
+			      struct mm_struct *mm);
+	struct iommu_pasid_entry *
+	(*alloc_priv_entry)(struct iommu_pasid_table_ops *ops,
+			    enum io_pgtable_fmt fmt,
+			    struct io_pgtable_cfg *cfg);
+	int (*set_entry)(struct iommu_pasid_table_ops *ops, int pasid,
+			 struct iommu_pasid_entry *entry);
+	void (*clear_entry)(struct iommu_pasid_table_ops *ops, int pasid,
+			    struct iommu_pasid_entry *entry);
+};
+
+/**
+ * iommu_pasid_sync_ops - Callbacks into the IOMMU driver
+ *
+ * @cfg_flush: flush cached configuration for one entry. For a multi-level PASID
+ * table, 'leaf' tells whether to only flush cached leaf entries or intermediate
+ * levels as well.
+ * @cfg_flush_all: flush cached configuration for all entries of the PASID table
+ * @tlb_flush: flush TLB entries for one entry
+ */
+struct iommu_pasid_sync_ops {
+	void (*cfg_flush)(void *cookie, int pasid, bool leaf);
+	void (*cfg_flush_all)(void *cookie);
+	void (*tlb_flush)(void *cookie, int pasid,
+			  struct iommu_pasid_entry *entry);
+};
+
+/**
+ * struct iommu_pasid_table_cfg - Configuration data for a set of PASID tables.
+ *
+ * @iommu_dev device performing the DMA table walks
+ * @order: number of PASID bits, set by IOMMU driver
+ * @flush: TLB management callbacks for this set of tables.
+ *
+ * @base: DMA address of the allocated table, set by the allocator.
+ */
+struct iommu_pasid_table_cfg {
+	struct device				*iommu_dev;
+	size_t					order;
+	const struct iommu_pasid_sync_ops	*sync;
+	dma_addr_t				base;
+};
+
+struct iommu_pasid_table_ops *
+iommu_alloc_pasid_ops(enum iommu_pasid_table_fmt fmt,
+		      struct iommu_pasid_table_cfg *cfg,
+		      void *cookie);
+void iommu_free_pasid_ops(struct iommu_pasid_table_ops *ops);
+
+static inline void iommu_free_pasid_entry(struct iommu_pasid_entry *entry)
+{
+	if (WARN_ON(!entry->release))
+		return;
+	entry->release(entry);
+}
+
+/**
+ * struct iommu_pasid_table - describes a set of PASID tables
+ *
+ * @fmt: The PASID table format.
+ * @cookie: An opaque token provided by the IOMMU driver and passed back to any
+ * callback routine.
+ * @cfg: A copy of the PASID table configuration.
+ * @ops: The PASID table operations in use for this set of page tables.
+ */
+struct iommu_pasid_table {
+	enum iommu_pasid_table_fmt	fmt;
+	void				*cookie;
+	struct iommu_pasid_table_cfg	cfg;
+	struct iommu_pasid_table_ops	ops;
+};
+
+#define iommu_pasid_table_ops_to_table(ops) \
+	container_of((ops), struct iommu_pasid_table, ops)
+
+struct iommu_pasid_init_fns {
+	struct iommu_pasid_table *(*alloc)(struct iommu_pasid_table_cfg *cfg,
+					   void *cookie);
+	void (*free)(struct iommu_pasid_table *table);
+};
+
+static inline void iommu_pasid_flush_all(struct iommu_pasid_table *table)
+{
+	table->cfg.sync->cfg_flush_all(table->cookie);
+}
+
+static inline void iommu_pasid_flush(struct iommu_pasid_table *table,
+					 int pasid, bool leaf)
+{
+	table->cfg.sync->cfg_flush(table->cookie, pasid, leaf);
+}
+
+static inline void iommu_pasid_flush_tlbs(struct iommu_pasid_table *table,
+					  int pasid,
+					  struct iommu_pasid_entry *entry)
+{
+	table->cfg.sync->tlb_flush(table->cookie, pasid, entry);
+}
+
+#endif /* __IOMMU_PASID_TABLE_H */
-- 
2.17.0
