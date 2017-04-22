Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0728D6B03B6
	for <linux-mm@kvack.org>; Sat, 22 Apr 2017 00:07:52 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f53so26637831qte.15
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 21:07:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x25si11644612qtc.190.2017.04.21.21.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 21:07:50 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 07/15] mm/hmm: heterogeneous memory management (HMM for short) v2
Date: Fri, 21 Apr 2017 23:30:29 -0400
Message-Id: <20170422033037.3028-8-jglisse@redhat.com>
In-Reply-To: <20170422033037.3028-1-jglisse@redhat.com>
References: <20170422033037.3028-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

HMM provides 3 separate types of functionality:
    - Mirroring: synchronize CPU page table and device page table
    - Device memory: allocating struct page for device memory
    - Migration: migrating regular memory to device memory

This patch introduces some common helpers and definitions to all of
those 3 functionality.

Changed since v1:
  - Kconfig logic (depend on x86-64 and use ARCH_HAS pattern)

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 MAINTAINERS              |   7 +++
 include/linux/hmm.h      | 146 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h |   5 ++
 kernel/fork.c            |   2 +
 mm/Kconfig               |  13 +++++
 mm/Makefile              |   1 +
 mm/hmm.c                 |  71 +++++++++++++++++++++++
 7 files changed, 245 insertions(+)
 create mode 100644 include/linux/hmm.h
 create mode 100644 mm/hmm.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 09341a9..6df21a9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6052,6 +6052,13 @@ S:	Supported
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
index 0000000..93b363d
--- /dev/null
+++ b/include/linux/hmm.h
@@ -0,0 +1,146 @@
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
+ * Heterogeneous Memory Management (HMM)
+ *
+ * See Documentation/vm/hmm.txt for reasons and overview of what HMM is and it
+ * is for. Here we focus on the HMM API description, with some explanation of
+ * the underlying implementation.
+ *
+ * Short description: HMM provides a set of helpers to share a virtual address
+ * space between CPU and a device, so that the device can access any valid
+ * address of the process (while still obeying memory protection). HMM also
+ * provides helpers to migrate process memory to device memory, and back. Each
+ * set of functionality (address space mirroring, and migration to and from
+ * device memory) can be used independently of the other.
+ *
+ *
+ * HMM address space mirroring API:
+ *
+ * Use HMM address space mirroring if you want to mirror range of the CPU page
+ * table of a process into a device page table. Here, "mirror" means "keep
+ * synchronized". Prerequisites: the device must provide the ability to write-
+ * protect its page tables (at PAGE_SIZE granularity), and must be able to
+ * recover from the resulting potential page faults.
+ *
+ * HMM guarantees that at any point in time, a given virtual address points to
+ * either the same memory in both CPU and device page tables (that is: CPU and
+ * device page tables each point to the same pages), or that one page table (CPU
+ * or device) points to no entry, while the other still points to the old page
+ * for the address. The latter case happens when the CPU page table update
+ * happens first, and then the update is mirrored over to the device page table.
+ * This does not cause any issue, because the CPU page table cannot start
+ * pointing to a new page until the device page table is invalidated.
+ *
+ * HMM uses mmu_notifiers to monitor the CPU page tables, and forwards any
+ * updates to each device driver that has registered a mirror. It also provides
+ * some API calls to help with taking a snapshot of the CPU page table, and to
+ * synchronize with any updates that might happen concurrently.
+ *
+ *
+ * HMM migration to and from device memory:
+ *
+ * HMM provides a set of helpers to hotplug device memory as ZONE_DEVICE, with
+ * a new MEMORY_DEVICE_UNADDRESSABLE type. This provides a struct page for
+ * each page of the device memory, and allows the device driver to manage its
+ * memory using those struct pages. Having struct pages for device memory makes
+ * migration easier. Because that memory is not addressable by the CPU it must
+ * never be pinned to the device; in other words, any CPU page fault can always
+ * cause the device memory to be migrated (copied/moved) back to regular memory.
+ *
+ * A new migrate helper (migrate_vma()) has been added (see mm/migrate.c) that
+ * allows use of a device DMA engine to perform the copy operation between
+ * regular system memory and device memory.
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
+ * hmm_pfn_t - HMM uses its own pfn type to keep several flags per page
+ *
+ * Flags:
+ * HMM_PFN_VALID: pfn is valid
+ * HMM_PFN_WRITE: CPU page table has write permission set
+ */
+typedef unsigned long hmm_pfn_t;
+
+#define HMM_PFN_VALID (1 << 0)
+#define HMM_PFN_WRITE (1 << 1)
+#define HMM_PFN_SHIFT 2
+
+/*
+ * hmm_pfn_t_to_page() - return struct page pointed to by a valid hmm_pfn_t
+ * @pfn: hmm_pfn_t to convert to struct page
+ * Returns: struct page pointer if pfn is a valid hmm_pfn_t, NULL otherwise
+ *
+ * If the hmm_pfn_t is valid (ie valid flag set) then return the struct page
+ * matching the pfn value stored in the hmm_pfn_t. Otherwise return NULL.
+ */
+static inline struct page *hmm_pfn_t_to_page(hmm_pfn_t pfn)
+{
+	if (!(pfn & HMM_PFN_VALID))
+		return NULL;
+	return pfn_to_page(pfn >> HMM_PFN_SHIFT);
+}
+
+/*
+ * hmm_pfn_t_to_pfn() - return pfn value store in a hmm_pfn_t
+ * @pfn: hmm_pfn_t to extract pfn from
+ * Returns: pfn value if hmm_pfn_t is valid, -1UL otherwise
+ */
+static inline unsigned long hmm_pfn_t_to_pfn(hmm_pfn_t pfn)
+{
+	if (!(pfn & HMM_PFN_VALID))
+		return -1UL;
+	return (pfn >> HMM_PFN_SHIFT);
+}
+
+/*
+ * hmm_pfn_t_from_page() - create a valid hmm_pfn_t value from struct page
+ * @page: struct page pointer for which to create the hmm_pfn_t
+ * Returns: valid hmm_pfn_t for the page
+ */
+static inline hmm_pfn_t hmm_pfn_t_from_page(struct page *page)
+{
+	return (page_to_pfn(page) << HMM_PFN_SHIFT) | HMM_PFN_VALID;
+}
+
+/*
+ * hmm_pfn_t_from_pfn() - create a valid hmm_pfn_t value from pfn
+ * @pfn: pfn value for which to create the hmm_pfn_t
+ * Returns: valid hmm_pfn_t for the pfn
+ */
+static inline hmm_pfn_t hmm_pfn_t_from_pfn(unsigned long pfn)
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
index 45cdb27..5ddeacc7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -23,6 +23,7 @@
 
 struct address_space;
 struct mem_cgroup;
+struct hmm;
 
 /*
  * Each physical page in the system has a struct page associated with
@@ -500,6 +501,10 @@ struct mm_struct {
 	atomic_long_t hugetlb_usage;
 #endif
 	struct work_struct async_put_work;
+#if IS_ENABLED(CONFIG_HMM)
+	/* HMM needs to track a few things per mm */
+	struct hmm *hmm;
+#endif
 };
 
 extern struct mm_struct init_mm;
diff --git a/kernel/fork.c b/kernel/fork.c
index 81347bd..65a3e94f 100644
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
@@ -891,6 +892,7 @@ void __mmdrop(struct mm_struct *mm)
 	BUG_ON(mm == &init_mm);
 	mm_free_pgd(mm);
 	destroy_context(mm);
+	hmm_mm_destroy(mm);
 	mmu_notifier_mm_destroy(mm);
 	check_mm(mm);
 	put_user_ns(mm->user_ns);
diff --git a/mm/Kconfig b/mm/Kconfig
index ad4bd50..90025b3 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -289,6 +289,19 @@ config MIGRATION
 config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	bool
 
+config ARCH_HAS_HMM
+	bool
+	default y
+	depends on X86_64
+	depends on ZONE_DEVICE
+	depends on MMU && 64BIT
+	depends on MEMORY_HOTPLUG
+	depends on MEMORY_HOTREMOVE
+	depends on SPARSEMEM_VMEMMAP
+
+config HMM
+	bool
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
index 0000000..acadb49
--- /dev/null
+++ b/mm/hmm.c
@@ -0,0 +1,71 @@
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
+	kfree(mm->hmm);
+}
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
