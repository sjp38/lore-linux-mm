Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 869786B033C
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 14:13:03 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o4so43617440qkb.5
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:13:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e15si8283022qte.159.2017.04.24.11.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 11:13:01 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 08/15] mm/hmm/mirror: mirror process address space on device with HMM helpers v3
Date: Mon, 24 Apr 2017 14:12:36 -0400
Message-Id: <20170424181243.20320-9-jglisse@redhat.com>
In-Reply-To: <20170424181243.20320-1-jglisse@redhat.com>
References: <20170424181243.20320-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

This is a heterogeneous memory management (HMM) process address space
mirroring. In a nutshell this provide an API to mirror process address
space on a device. This boils down to keeping CPU and device page table
synchronize (we assume that both device and CPU are cache coherent like
PCIe device can be).

This patch provide a simple API for device driver to achieve address
space mirroring thus avoiding each device driver to grow its own CPU
page table walker and its own CPU page table synchronization mechanism.

This is useful for NVidia GPU >= Pascal, Mellanox IB >= mlx5 and more
hardware in the future.

Changed since v2:
  - s/device unaddressable/device private/
Changed since v1:
  - Kconfig logic (depend on x86-64 and use ARCH_HAS pattern)

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h | 110 ++++++++++++++++++++++++++++++++++
 mm/Kconfig          |  12 ++++
 mm/hmm.c            | 170 +++++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 277 insertions(+), 15 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index e24c7a7..f72ce59 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -72,6 +72,7 @@
 
 #if IS_ENABLED(CONFIG_HMM)
 
+struct hmm;
 
 /*
  * hmm_pfn_t - HMM uses its own pfn type to keep several flags per page
@@ -134,6 +135,115 @@ static inline hmm_pfn_t hmm_pfn_t_from_pfn(unsigned long pfn)
 }
 
 
+#if IS_ENABLED(CONFIG_HMM_MIRROR)
+/*
+ * Mirroring: how to synchronize device page table with CPU page table.
+ *
+ * A device driver that is participating in HMM mirroring must always
+ * synchronize with CPU page table updates. For this, device drivers can either
+ * directly use mmu_notifier APIs or they can use the hmm_mirror API. Device
+ * drivers can decide to register one mirror per device per process, or just
+ * one mirror per process for a group of devices. The pattern is:
+ *
+ *      int device_bind_address_space(..., struct mm_struct *mm, ...)
+ *      {
+ *          struct device_address_space *das;
+ *
+ *          // Device driver specific initialization, and allocation of das
+ *          // which contains an hmm_mirror struct as one of its fields.
+ *          ...
+ *
+ *          ret = hmm_mirror_register(&das->mirror, mm, &device_mirror_ops);
+ *          if (ret) {
+ *              // Cleanup on error
+ *              return ret;
+ *          }
+ *
+ *          // Other device driver specific initialization
+ *          ...
+ *      }
+ *
+ * Once an hmm_mirror is registered for an address space, the device driver
+ * will get callbacks through sync_cpu_device_pagetables() operation (see
+ * hmm_mirror_ops struct).
+ *
+ * Device driver must not free the struct containing the hmm_mirror struct
+ * before calling hmm_mirror_unregister(). The expected usage is to do that when
+ * the device driver is unbinding from an address space.
+ *
+ *
+ *      void device_unbind_address_space(struct device_address_space *das)
+ *      {
+ *          // Device driver specific cleanup
+ *          ...
+ *
+ *          hmm_mirror_unregister(&das->mirror);
+ *
+ *          // Other device driver specific cleanup, and now das can be freed
+ *          ...
+ *      }
+ */
+
+struct hmm_mirror;
+
+/*
+ * enum hmm_update_type - type of update
+ * @HMM_UPDATE_INVALIDATE: invalidate range (no indication as to why)
+ */
+enum hmm_update_type {
+	HMM_UPDATE_INVALIDATE,
+};
+
+/*
+ * struct hmm_mirror_ops - HMM mirror device operations callback
+ *
+ * @update: callback to update range on a device
+ */
+struct hmm_mirror_ops {
+	/* sync_cpu_device_pagetables() - synchronize page tables
+	 *
+	 * @mirror: pointer to struct hmm_mirror
+	 * @update_type: type of update that occurred to the CPU page table
+	 * @start: virtual start address of the range to update
+	 * @end: virtual end address of the range to update
+	 *
+	 * This callback ultimately originates from mmu_notifiers when the CPU
+	 * page table is updated. The device driver must update its page table
+	 * in response to this callback. The update argument tells what action
+	 * to perform.
+	 *
+	 * The device driver must not return from this callback until the device
+	 * page tables are completely updated (TLBs flushed, etc); this is a
+	 * synchronous call.
+	 */
+	void (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
+					   enum hmm_update_type update_type,
+					   unsigned long start,
+					   unsigned long end);
+};
+
+/*
+ * struct hmm_mirror - mirror struct for a device driver
+ *
+ * @hmm: pointer to struct hmm (which is unique per mm_struct)
+ * @ops: device driver callback for HMM mirror operations
+ * @list: for list of mirrors of a given mm
+ *
+ * Each address space (mm_struct) being mirrored by a device must register one
+ * instance of an hmm_mirror struct with HMM. HMM will track the list of all
+ * mirrors for each mm_struct.
+ */
+struct hmm_mirror {
+	struct hmm			*hmm;
+	const struct hmm_mirror_ops	*ops;
+	struct list_head		list;
+};
+
+int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
+void hmm_mirror_unregister(struct hmm_mirror *mirror);
+#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
+
+
 /* Below are for HMM internal use only! Not to be used by device driver! */
 void hmm_mm_destroy(struct mm_struct *mm);
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 90025b3..3c1ffb1 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -302,6 +302,18 @@ config ARCH_HAS_HMM
 config HMM
 	bool
 
+config HMM_MIRROR
+	bool "HMM mirror CPU page table into a device page table"
+	depends on ARCH_HAS_HMM
+	select MMU_NOTIFIER
+	select HMM
+	help
+	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
+	  process into a device page table. Here, mirror means "keep synchronized".
+	  Prerequisites: the device must provide the ability to write-protect its
+	  page tables (at PAGE_SIZE granularity), and must be able to recover from
+	  the resulting potential page faults.
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
diff --git a/mm/hmm.c b/mm/hmm.c
index acadb49..7ed4b4c 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -21,14 +21,26 @@
 #include <linux/hmm.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/mmu_notifier.h>
+
+static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
+
 
 /*
  * struct hmm - HMM per mm struct
  *
  * @mm: mm struct this HMM struct is bound to
+ * @sequence: we track updates to the CPU page table with a sequence number
+ * @mirrors: list of mirrors for this mm
+ * @mmu_notifier: mmu notifier to track updates to CPU page table
+ * @mirrors_sem: read/write semaphore protecting the mirrors list
  */
 struct hmm {
 	struct mm_struct	*mm;
+	atomic_t		sequence;
+	struct list_head	mirrors;
+	struct mmu_notifier	mmu_notifier;
+	struct rw_semaphore	mirrors_sem;
 };
 
 /*
@@ -41,27 +53,48 @@ struct hmm {
  */
 static struct hmm *hmm_register(struct mm_struct *mm)
 {
-	if (!mm->hmm) {
-		struct hmm *hmm = NULL;
-
-		hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
-		if (!hmm)
-			return NULL;
-		hmm->mm = mm;
-
-		spin_lock(&mm->page_table_lock);
-		if (!mm->hmm)
-			mm->hmm = hmm;
-		else
-			kfree(hmm);
-		spin_unlock(&mm->page_table_lock);
-	}
+	struct hmm *hmm = READ_ONCE(mm->hmm);
+	bool cleanup = false;
 
 	/*
 	 * The hmm struct can only be freed once the mm_struct goes away,
 	 * hence we should always have pre-allocated an new hmm struct
 	 * above.
 	 */
+	if (hmm)
+		return hmm;
+
+	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
+	if (!hmm)
+		return NULL;
+	INIT_LIST_HEAD(&hmm->mirrors);
+	init_rwsem(&hmm->mirrors_sem);
+	atomic_set(&hmm->sequence, 0);
+	hmm->mmu_notifier.ops = NULL;
+	hmm->mm = mm;
+
+	/*
+	 * We should only get here if hold the mmap_sem in write mode ie on
+	 * registration of first mirror through hmm_mirror_register()
+	 */
+	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
+	if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
+		kfree(hmm);
+		return NULL;
+	}
+
+	spin_lock(&mm->page_table_lock);
+	if (!mm->hmm)
+		mm->hmm = hmm;
+	else
+		cleanup = true;
+	spin_unlock(&mm->page_table_lock);
+
+	if (cleanup) {
+		mmu_notifier_unregister(&hmm->mmu_notifier, mm);
+		kfree(hmm);
+	}
+
 	return mm->hmm;
 }
 
@@ -69,3 +102,110 @@ void hmm_mm_destroy(struct mm_struct *mm)
 {
 	kfree(mm->hmm);
 }
+
+
+#if IS_ENABLED(CONFIG_HMM_MIRROR)
+static void hmm_invalidate_range(struct hmm *hmm,
+				 enum hmm_update_type action,
+				 unsigned long start,
+				 unsigned long end)
+{
+	struct hmm_mirror *mirror;
+
+	down_read(&hmm->mirrors_sem);
+	list_for_each_entry(mirror, &hmm->mirrors, list)
+		mirror->ops->sync_cpu_device_pagetables(mirror, action,
+							start, end);
+	up_read(&hmm->mirrors_sem);
+}
+
+static void hmm_invalidate_page(struct mmu_notifier *mn,
+				struct mm_struct *mm,
+				unsigned long addr)
+{
+	unsigned long start = addr & PAGE_MASK;
+	unsigned long end = start + PAGE_SIZE;
+	struct hmm *hmm = mm->hmm;
+
+	VM_BUG_ON(!hmm);
+
+	atomic_inc(&hmm->sequence);
+	hmm_invalidate_range(mm->hmm, HMM_UPDATE_INVALIDATE, start, end);
+}
+
+static void hmm_invalidate_range_start(struct mmu_notifier *mn,
+				       struct mm_struct *mm,
+				       unsigned long start,
+				       unsigned long end)
+{
+	struct hmm *hmm = mm->hmm;
+
+	VM_BUG_ON(!hmm);
+
+	atomic_inc(&hmm->sequence);
+}
+
+static void hmm_invalidate_range_end(struct mmu_notifier *mn,
+				     struct mm_struct *mm,
+				     unsigned long start,
+				     unsigned long end)
+{
+	struct hmm *hmm = mm->hmm;
+
+	VM_BUG_ON(!hmm);
+
+	hmm_invalidate_range(mm->hmm, HMM_UPDATE_INVALIDATE, start, end);
+}
+
+static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
+	.invalidate_page	= hmm_invalidate_page,
+	.invalidate_range_start	= hmm_invalidate_range_start,
+	.invalidate_range_end	= hmm_invalidate_range_end,
+};
+
+/*
+ * hmm_mirror_register() - register a mirror against an mm
+ *
+ * @mirror: new mirror struct to register
+ * @mm: mm to register against
+ *
+ * To start mirroring a process address space, the device driver must register
+ * an HMM mirror struct.
+ *
+ * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
+ */
+int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
+{
+	/* Sanity check */
+	if (!mm || !mirror || !mirror->ops)
+		return -EINVAL;
+
+	mirror->hmm = hmm_register(mm);
+	if (!mirror->hmm)
+		return -ENOMEM;
+
+	down_write(&mirror->hmm->mirrors_sem);
+	list_add(&mirror->list, &mirror->hmm->mirrors);
+	up_write(&mirror->hmm->mirrors_sem);
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_mirror_register);
+
+/*
+ * hmm_mirror_unregister() - unregister a mirror
+ *
+ * @mirror: new mirror struct to register
+ *
+ * Stop mirroring a process address space, and cleanup.
+ */
+void hmm_mirror_unregister(struct hmm_mirror *mirror)
+{
+	struct hmm *hmm = mirror->hmm;
+
+	down_write(&hmm->mirrors_sem);
+	list_del(&mirror->list);
+	up_write(&hmm->mirrors_sem);
+}
+EXPORT_SYMBOL(hmm_mirror_unregister);
+#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
