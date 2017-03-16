Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B8476B0390
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:04:02 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n37so38764208qtb.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:04:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o16si4094904qto.176.2017.03.16.08.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:04:00 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 09/16] mm/hmm: heterogeneous memory management (HMM for short)
Date: Thu, 16 Mar 2017 12:05:28 -0400
Message-Id: <1489680335-6594-10-git-send-email-jglisse@redhat.com>
In-Reply-To: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

HMM provides 3 separate types of functionality:
    - Mirroring: synchronize CPU page table and device page table
    - Device memory: allocating struct page for device memory
    - Migration: migrating regular memory to device memory

This patch introduces some common helpers and definitions to all of
those 3 functionality.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 MAINTAINERS              |   7 +++
 include/linux/hmm.h      | 153 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h |   5 ++
 kernel/fork.c            |   2 +
 mm/Kconfig               |   4 ++
 mm/Makefile              |   1 +
 mm/hmm.c                 |  81 +++++++++++++++++++++++++
 7 files changed, 253 insertions(+)
 create mode 100644 include/linux/hmm.h
 create mode 100644 mm/hmm.c

diff --git a/MAINTAINERS b/MAINTAINERS
index c776906..af37f7c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5964,6 +5964,13 @@ S:	Supported
 F:	drivers/scsi/hisi_sas/
 F:	Documentation/devicetree/bindings/scsi/hisilicon-sas.txt
 
+HMM - Heterogeneous Memory Management
+M:	JA(C)rA'me Glisse <jglisse@redhat.com>
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	mm/hmm*
+F:	include/linux/hmm*
+
 HOST AP DRIVER
 M:	Jouni Malinen <j@w1.fi>
 L:	linux-wireless@vger.kernel.org
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
new file mode 100644
index 0000000..9fb6767
--- /dev/null
+++ b/include/linux/hmm.h
@@ -0,0 +1,153 @@
+/*
+ * Copyright 2013 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/*
+ * HMM provides 3 separate types of functionality:
+ *   - Mirroring: synchronize CPU page table and device page table
+ *   - Device memory: allocating struct pages for device memory
+ *   - Migration: migrating regular memory to device memory
+ *
+ * Each can be used independently from the others.
+ *
+ *
+ * Mirroring:
+ *
+ * HMM provides helpers to mirror a process address space on a device. For this,
+ * it provides several helpers to order device page table updates with respect
+ * to CPU page table updates. The requirement is that for any given virtual
+ * address the CPU and device page table cannot point to different physical
+ * pages. It uses the mmu_notifier API behind the scenes.
+ *
+ * Device memory:
+ *
+ * HMM provides helpers to help leverage device memory. Device memory is, at any
+ * given time, either CPU-addressable like regular memory, or completely
+ * unaddressable. In both cases the device memory is associated with dedicated
+ * struct pages (which are allocated as if for hotplugged memory). Device memory
+ * management is under the responsibility of the device driver. HMM only
+ * allocates and initializes the struct pages associated with the device memory,
+ * by hotplugging a ZONE_DEVICE memory range.
+ *
+ * Allocating struct pages for device memory allows us to use device memory
+ * almost like regular CPU memory. Unlike regular memory, however, it cannot be
+ * added to the lru, nor can any memory allocation can use device memory
+ * directly. Device memory will only end up in use by a process if the device
+ * driver migrates some of the process memory from regular memory to device
+ * memory.
+ *
+ * Migration:
+ *
+ * The existing memory migration mechanism (mm/migrate.c) does not allow using
+ * anything other than the CPU to copy from source to destination memory.
+ * Moreover, existing code does not provide a way to migrate based on a virtual
+ * address range. Existing code only supports struct-page-based migration. Also,
+ * the migration flow does not allow for graceful failure at intermediate stages
+ * of the migration process.
+ *
+ * HMM solves all of the above, by providing a simple API:
+ *
+ *      hmm_vma_migrate(ops, vma, src_pfns, dst_pfns, start, end, private);
+ *
+ * finalize_and_map(). The first,  alloc_and_copy(), allocates the destination
+ * memory and initializes it using source memory. Migration can fail at this
+ * point, and the device driver then has a place to abort the migration. The
+ * finalize_and_map() callback allows the device driver to know which pages
+ * were successfully migrated and which were not.
+ *
+ * This can easily be used outside of the original HMM use case.
+ *
+ *
+ * This header file contain all the APIs related to hmm_vma_migrate. Additional
+ * detailed documentation may be found below.
+ */
+#ifndef LINUX_HMM_H
+#define LINUX_HMM_H
+
+#include <linux/kconfig.h>
+
+#if IS_ENABLED(CONFIG_HMM)
+
+
+/*
+ * hmm_pfn_t - HMM use its own pfn type to keep several flags per page
+ *
+ * Flags:
+ * HMM_PFN_VALID: pfn is valid
+ * HMM_PFN_WRITE: CPU page table have the write permission set
+ */
+typedef unsigned long hmm_pfn_t;
+
+#define HMM_PFN_VALID (1 << 0)
+#define HMM_PFN_WRITE (1 << 1)
+#define HMM_PFN_SHIFT 2
+
+/*
+ * hmm_pfn_to_page() - return struct page pointed to by a valid hmm_pfn_t
+ * @pfn: hmm_pfn_t to convert to struct page
+ * Returns: struct page pointer if pfn is a valid hmm_pfn_t, NULL otherwise
+ *
+ * If the hmm_pfn_t is valid (ie valid flag set) then return the struct page
+ * matching the pfn value store in the hmm_pfn_t. Otherwise return NULL.
+ */
+static inline struct page *hmm_pfn_to_page(hmm_pfn_t pfn)
+{
+	if (!(pfn & HMM_PFN_VALID))
+		return NULL;
+	return pfn_to_page(pfn >> HMM_PFN_SHIFT);
+}
+
+/*
+ * hmm_pfn_to_pfn() - return pfn value store in a hmm_pfn_t
+ * @pfn: hmm_pfn_t to extract pfn from
+ * Returns: pfn value if hmm_pfn_t is valid, -1UL otherwise
+ */
+static inline unsigned long hmm_pfn_to_pfn(hmm_pfn_t pfn)
+{
+	if (!(pfn & HMM_PFN_VALID))
+		return -1UL;
+	return (pfn >> HMM_PFN_SHIFT);
+}
+
+/*
+ * hmm_pfn_from_page() - create a valid hmm_pfn_t value from struct page
+ * @page: struct page pointer for which to create the hmm_pfn_t
+ * Returns: valid hmm_pfn_t for the page
+ */
+static inline hmm_pfn_t hmm_pfn_from_page(struct page *page)
+{
+	return (page_to_pfn(page) << HMM_PFN_SHIFT) | HMM_PFN_VALID;
+}
+
+/*
+ * hmm_pfn_from_pfn() - create a valid hmm_pfn_t value from pfn
+ * @pfn: pfn value for which to create the hmm_pfn_t
+ * Returns: valid hmm_pfn_t for the pfn
+ */
+static inline hmm_pfn_t hmm_pfn_from_pfn(unsigned long pfn)
+{
+	return (pfn << HMM_PFN_SHIFT) | HMM_PFN_VALID;
+}
+
+
+/* Below are for HMM internal use only! Not to be used by device driver! */
+void hmm_mm_destroy(struct mm_struct *mm);
+
+#else /* IS_ENABLED(CONFIG_HMM) */
+
+/* Below are for HMM internal use only! Not to be used by device driver! */
+static inline void hmm_mm_destroy(struct mm_struct *mm) {}
+
+#endif /* IS_ENABLED(CONFIG_HMM) */
+#endif /* LINUX_HMM_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f60f45f..81068ce 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -23,6 +23,7 @@
 
 struct address_space;
 struct mem_cgroup;
+struct hmm;
 
 /*
  * Each physical page in the system has a struct page associated with
@@ -495,6 +496,10 @@ struct mm_struct {
 	atomic_long_t hugetlb_usage;
 #endif
 	struct work_struct async_put_work;
+#if IS_ENABLED(CONFIG_HMM)
+	/* HMM need to track few things per mm */
+	struct hmm *hmm;
+#endif
 };
 
 extern struct mm_struct init_mm;
diff --git a/kernel/fork.c b/kernel/fork.c
index 6c463c80..1f8d612 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -37,6 +37,7 @@
 #include <linux/binfmts.h>
 #include <linux/mman.h>
 #include <linux/mmu_notifier.h>
+#include <linux/hmm.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/vmacache.h>
@@ -863,6 +864,7 @@ void __mmdrop(struct mm_struct *mm)
 	BUG_ON(mm == &init_mm);
 	mm_free_pgd(mm);
 	destroy_context(mm);
+	hmm_mm_destroy(mm);
 	mmu_notifier_mm_destroy(mm);
 	check_mm(mm);
 	put_user_ns(mm->user_ns);
diff --git a/mm/Kconfig b/mm/Kconfig
index 9502315..fe8ad24 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -289,6 +289,10 @@ config MIGRATION
 config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	bool
 
+config HMM
+	bool
+	depends on MMU
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
diff --git a/mm/Makefile b/mm/Makefile
index 026f6a8..9eb4121 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -75,6 +75,7 @@ obj-$(CONFIG_FAILSLAB) += failslab.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_MEMTEST)		+= memtest.o
 obj-$(CONFIG_MIGRATION) += migrate.o
+obj-$(CONFIG_HMM) += hmm.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o khugepaged.o
 obj-$(CONFIG_PAGE_COUNTER) += page_counter.o
diff --git a/mm/hmm.c b/mm/hmm.c
new file mode 100644
index 0000000..ed3a847
--- /dev/null
+++ b/mm/hmm.c
@@ -0,0 +1,81 @@
+/*
+ * Copyright 2013 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/*
+ * Refer to include/linux/hmm.h for information about heterogeneous memory
+ * management or HMM for short.
+ */
+#include <linux/mm.h>
+#include <linux/hmm.h>
+#include <linux/slab.h>
+#include <linux/sched.h>
+
+/*
+ * struct hmm - HMM per mm struct
+ *
+ * @mm: mm struct this HMM struct is bound to
+ */
+struct hmm {
+	struct mm_struct	*mm;
+};
+
+/*
+ * hmm_register - register HMM against an mm (HMM internal)
+ *
+ * @mm: mm struct to attach to
+ *
+ * This is not intended to be used directly by device drivers. It allocates an
+ * HMM struct if mm does not have one, and initializes it.
+ */
+static struct hmm *hmm_register(struct mm_struct *mm)
+{
+	if (!mm->hmm) {
+		struct hmm *hmm = NULL;
+
+		hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
+		if (!hmm)
+			return NULL;
+		hmm->mm = mm;
+
+		spin_lock(&mm->page_table_lock);
+		if (!mm->hmm)
+			mm->hmm = hmm;
+		else
+			kfree(hmm);
+		spin_unlock(&mm->page_table_lock);
+	}
+
+	/*
+	 * The hmm struct can only be freed once the mm_struct goes away,
+	 * hence we should always have pre-allocated an new hmm struct
+	 * above.
+	 */
+	return mm->hmm;
+}
+
+void hmm_mm_destroy(struct mm_struct *mm)
+{
+	struct hmm *hmm;
+
+	/*
+	 * We should not need to lock here as no one should be able to register
+	 * a new HMM while an mm is being destroy. But just to be safe ...
+	 */
+	spin_lock(&mm->page_table_lock);
+	hmm = mm->hmm;
+	mm->hmm = NULL;
+	spin_unlock(&mm->page_table_lock);
+	kfree(hmm);
+}
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
