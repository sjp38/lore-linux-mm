Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3BA280017
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 13:29:19 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k15so5775787qaq.1
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 10:29:19 -0800 (PST)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id f34si32464027qgd.35.2014.11.10.10.29.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 10:29:17 -0800 (PST)
Received: by mail-qg0-f54.google.com with SMTP id q108so5938924qgd.13
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 10:29:16 -0800 (PST)
From: j.glisse@gmail.com
Subject: [PATCH 4/5] hmm: heterogeneous memory management v6
Date: Mon, 10 Nov 2014 13:28:16 -0500
Message-Id: <1415644096-3513-5-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Motivation:

Heterogeneous memory management is intended to allow a device to transparently
access a process address space without having to lock pages of the process or
take references on them. In other word mirroring a process address space while
allowing the regular memory management event such as page reclamation or page
migration, to happen seamlessly.

Recent years have seen a surge into the number of specialized devices that are
part of a computer platform (from desktop to phone). So far each of those
devices have operated on there own private address space that is not link or
expose to the process address space that is using them. This separation often
leads to multiple memory copy happening between the device owned memory and the
process memory. This of course is both a waste of cpu cycle and memory.

Over the last few years most of those devices have gained a full mmu allowing
them to support multiple page table, page fault and other features that are
found inside cpu mmu. There is now a strong incentive to start leveraging
capabilities of such devices and to start sharing process address to avoid
any unnecessary memory copy as well as simplifying the programming model of
those devices by sharing an unique and common address space with the process
that use them.

The aim of the heterogeneous memory management is to provide a common API that
can be use by any such devices in order to mirror process address. The hmm code
provide an unique entry point and interface itself with the core mm code of the
linux kernel avoiding duplicate implementation and shielding device driver code
from core mm code.

Moreover, hmm also intend to provide support for migrating memory to device
private memory, allowing device to work on its own fast local memory. The hmm
code would be responsible to intercept cpu page fault on migrated range and
to migrate it back to system memory allowing cpu to resume its access to the
memory.

Another feature hmm intend to provide is support for atomic operation for the
device even if the bus linking the device and the cpu do not have any such
capabilities. On such hardware atomic operation require the page to only be
mapped on the device or on the cpu but not both at the same time.

We expect that graphic processing unit and network interface to be among the
first users of such api.

Hardware requirement:

Because hmm is intended to be use by device driver there are minimum features
requirement for the hardware mmu :
  - hardware have its own page table per process (can be share btw != devices)
  - hardware mmu support page fault and suspend execution until the page fault
    is serviced by hmm code. The page fault must also trigger some form of
    interrupt so that hmm code can be call by the device driver.
  - hardware must support at least read only mapping (otherwise it can not
    access read only range of the process address space).
  - hardware access to system memory must be cache coherent with the cpu.

For better memory management it is highly recommanded that the device also
support the following features :
  - hardware mmu set access bit in its page table on memory access (like cpu).
  - hardware page table can be updated from cpu or through a fast path.
  - hardware provide advanced statistic over which range of memory it access
    the most.
  - hardware differentiate atomic memory access from regular access allowing
    to support atomic operation even on platform that do not have atomic
    support on the bus linking the device with the cpu.

Implementation:

The hmm layer provide a simple API to the device driver. Each device driver
have to register and hmm device that holds pointer to all the callback the hmm
code will make to synchronize the device page table with the cpu page table of
a given process.

For each process it wants to mirror the device driver must register a mirror
hmm structure that holds all the informations specific to the process being
mirrored. Each hmm mirror uniquely link an hmm device with a process address
space (the mm struct).

This design allow several different device driver to mirror concurrently the
same process. The hmm layer will dispatch approprietly to each device driver
modification that are happening to the process address space.

The hmm layer rely on the mmu notifier api to monitor change to the process
address space. Because update to device page table can have unbound completion
time, the hmm layer need the capability to sleep during mmu notifier callback.

This patch only implement the core of the hmm layer and do not support feature
such as migration to device memory.

Changed since v1:
  - convert fence to refcounted object
  - change the api to provide pte value directly avoiding useless temporary
    special hmm pfn value
  - cleanups & fixes ...

Changed since v2:
  - fixed checkpatch.pl warnings & errors
  - converted to a staging feature

Changed since v3:
  - Use mmput notifier chain instead of adding hmm destroy call to mmput.
  - Clear mm->hmm inside mm_init to be match mmu_notifier.
  - Separate cpu page table invalidation from device page table fault to
    have cleaner and simpler code for synchronization btw this two types
    of event.
  - Removing hmm_mirror kref and rely on user to manage lifetime of the
    hmm_mirror.

Changed since v4:
  - Invalidate either in range_start() or in range_end() depending on the
    kind of mmu event.
  - Use the new generic page table implementation to keep an hmm mirror of
    the cpu page table.
  - Get rid of the range lock exclusion as it is no longer needed.
  - Simplify the driver api.
  - Support for hugue page.

Changed since v5:
  - Take advantages of mmu_notifier tracking active invalidation range.
  - Adapt to change to arch independant page table.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/hmm.h      |  364 +++++++++++++++
 include/linux/mm.h       |   11 +
 include/linux/mm_types.h |   14 +
 kernel/fork.c            |    2 +
 mm/Kconfig               |   15 +
 mm/Makefile              |    1 +
 mm/hmm.c                 | 1156 ++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 1563 insertions(+)
 create mode 100644 include/linux/hmm.h
 create mode 100644 mm/hmm.c

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
new file mode 100644
index 0000000..3331798
--- /dev/null
+++ b/include/linux/hmm.h
@@ -0,0 +1,364 @@
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
+/* This is a heterogeneous memory management (hmm). In a nutshell this provide
+ * an API to mirror a process address on a device which has its own mmu using
+ * its own page table for the process. It supports everything except special
+ * vma.
+ *
+ * Mandatory hardware features :
+ *   - An mmu with pagetable.
+ *   - Read only flag per cpu page.
+ *   - Page fault ie hardware must stop and wait for kernel to service fault.
+ *
+ * Optional hardware features :
+ *   - Dirty bit per cpu page.
+ *   - Access bit per cpu page.
+ *
+ * The hmm code handle all the interfacing with the core kernel mm code and
+ * provide a simple API. It does support migrating system memory to device
+ * memory and handle migration back to system memory on cpu page fault.
+ *
+ * Migrated memory is considered as swaped from cpu and core mm code point of
+ * view.
+ */
+#ifndef _HMM_H
+#define _HMM_H
+
+#ifdef CONFIG_HMM
+
+#include <linux/list.h>
+#include <linux/rwsem.h>
+#include <linux/spinlock.h>
+#include <linux/atomic.h>
+#include <linux/mm_types.h>
+#include <linux/mmu_notifier.h>
+#include <linux/workqueue.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/mman.h>
+
+
+struct hmm_device;
+struct hmm_device_ops;
+struct hmm_mirror;
+struct hmm_event;
+struct hmm;
+
+
+/* hmm_fence - device driver fence to wait for device driver operations.
+ *
+ * In order to concurrently update several different devices mmu the hmm rely
+ * on device driver fence to wait for operation hmm schedules to complete on
+ * devices. It is strongly recommanded to implement fences and have the hmm
+ * callback do as little as possible (just scheduling the update and returning
+ * a fence). Moreover the hmm code will reschedule for i/o the current process
+ * if necessary once it has scheduled all updates on all devices.
+ *
+ * Each fence is created as a result of either an update to range of memory or
+ * for remote memory to/from local memory dma.
+ *
+ * Update to range of memory correspond to a specific event type. For instance
+ * range of memory is unmap for page reclamation, or range of memory is unmap
+ * from process address space as result of munmap syscall (HMM_MUNMAP), or a
+ * memory protection change on the range. There is one hmm_etype for each of
+ * those event allowing the device driver to take appropriate action like for
+ * instance freeing device page table on HMM_MUNMAP but keeping it when it is
+ * just an access protection change or temporary unmap.
+ */
+enum hmm_etype {
+	HMM_NONE = 0,
+	HMM_ISDIRTY,
+	HMM_MIGRATE,
+	HMM_MUNMAP,
+	HMM_RFAULT,
+	HMM_WFAULT,
+	HMM_WRITE_PROTECT,
+};
+
+struct hmm_fence {
+	struct hmm_mirror	*mirror;
+	struct list_head	list;
+};
+
+
+/* struct hmm_event - used to serialize change to overlapping range of address.
+ *
+ * @list: Core hmm keep track of all active events.
+ * @start: First address (inclusive).
+ * @end: Last address (exclusive).
+ * @fences: List of device fences associated with this event.
+ * @etype: Event type (munmap, migrate, truncate, ...).
+ * @backoff: Only meaningful for device page fault.
+ */
+struct hmm_event {
+	struct list_head	list;
+	unsigned long		start;
+	unsigned long		end;
+	struct list_head	fences;
+	enum hmm_etype		etype;
+	bool			backoff;
+};
+
+
+/* struct hmm_range - used to communicate range infos to various callback.
+ *
+ * @pte: The hmm page table entry for the range.
+ * @ptp: The page directory page struct.
+ * @start: First address (inclusive).
+ * @end: Last address (exclusive).
+ */
+struct hmm_range {
+	unsigned long		*pte;
+	struct page		*pdp;
+	unsigned long		start;
+	unsigned long		end;
+};
+
+static inline unsigned long hmm_range_size(struct hmm_range *range)
+{
+	return range->end - range->start;
+}
+
+#define HMM_PTE_VALID_PDIR_BIT	0UL
+#define HMM_PTE_VALID_SMEM_BIT	1UL
+#define HMM_PTE_WRITE_BIT	2UL
+#define HMM_PTE_DIRTY_BIT	3UL
+
+static inline unsigned long hmm_pte_from_pfn(unsigned long pfn)
+{
+	return (pfn << PAGE_SHIFT) | (1UL << HMM_PTE_VALID_SMEM_BIT);
+}
+
+static inline void hmm_pte_mk_dirty(volatile unsigned long *hmm_pte)
+{
+	set_bit(HMM_PTE_DIRTY_BIT, hmm_pte);
+}
+
+static inline void hmm_pte_mk_write(volatile unsigned long *hmm_pte)
+{
+	set_bit(HMM_PTE_WRITE_BIT, hmm_pte);
+}
+
+static inline bool hmm_pte_clear_valid_smem(volatile unsigned long *hmm_pte)
+{
+	return test_and_clear_bit(HMM_PTE_VALID_SMEM_BIT, hmm_pte);
+}
+
+static inline bool hmm_pte_clear_write(volatile unsigned long *hmm_pte)
+{
+	return test_and_clear_bit(HMM_PTE_WRITE_BIT, hmm_pte);
+}
+
+static inline bool hmm_pte_is_valid_smem(const volatile unsigned long *hmm_pte)
+{
+	return test_bit(HMM_PTE_VALID_SMEM_BIT, hmm_pte);
+}
+
+static inline bool hmm_pte_is_write(const volatile unsigned long *hmm_pte)
+{
+	return test_bit(HMM_PTE_WRITE_BIT, hmm_pte);
+}
+
+static inline unsigned long hmm_pte_pfn(unsigned long hmm_pte)
+{
+	return hmm_pte >> PAGE_SHIFT;
+}
+
+
+/* hmm_device - Each device driver must register one and only one hmm_device.
+ *
+ * The hmm_device is the link btw hmm and each device driver.
+ */
+
+/* struct hmm_device_operations - hmm device operation callback
+ */
+struct hmm_device_ops {
+	/* mirror_ref() - take reference on mirror struct.
+	 *
+	 * @mirror: Struct being referenced.
+	 */
+	struct hmm_mirror *(*mirror_ref)(struct hmm_mirror *mirror);
+
+	/* mirror_unref() - drop reference on mirror struct.
+	 *
+	 * @mirror: Struct being dereferenced.
+	 */
+	struct hmm_mirror *(*mirror_unref)(struct hmm_mirror *mirror);
+
+	/* mirror_release() - device must stop using the address space.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 *
+	 * This callback is call either on mm destruction or as result to a
+	 * call of hmm_mirror_release(). Device driver have to stop all hw
+	 * thread and all usage of the address space, it has to dirty all
+	 * pages that have been dirty by the device.
+	 */
+	void (*mirror_release)(struct hmm_mirror *mirror);
+
+	/* fence_wait() - to wait on device driver fence.
+	 *
+	 * @fence: The device driver fence struct.
+	 * Returns: 0 on success,-EIO on error, -EAGAIN to wait again.
+	 *
+	 * Called when hmm want to wait for all operations associated with a
+	 * fence to complete (including device cache flush if the event mandate
+	 * it).
+	 *
+	 * Device driver must free fence and associated resources if it returns
+	 * something else thant -EAGAIN. On -EAGAIN the fence must not be free
+	 * as hmm will call back again.
+	 *
+	 * Return error if scheduled operation failed or if need to wait again.
+	 * -EIO Some input/output error with the device.
+	 * -EAGAIN The fence not yet signaled, hmm reschedule waiting thread.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	int (*fence_wait)(struct hmm_fence *fence);
+
+	/* fence_ref() - take a reference fence structure.
+	 *
+	 * @fence: Fence structure hmm is referencing.
+	 */
+	void (*fence_ref)(struct hmm_fence *fence);
+
+	/* fence_unref() - drop a reference fence structure.
+	 *
+	 * @fence: Fence structure hmm is dereferencing.
+	 */
+	void (*fence_unref)(struct hmm_fence *fence);
+
+	/* update() - update device mmu for a range of address.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 * @event: The event that triggered the update.
+	 * @range: All informations about the range that needs to be updated.
+	 * Returns: Valid fence ptr or NULL on success otherwise ERR_PTR.
+	 *
+	 * Called to update device page table for a range of address.
+	 * The event type provide the nature of the update :
+	 *   - Range is no longer valid (munmap).
+	 *   - Range protection changes (mprotect, COW, ...).
+	 *   - Range is unmapped (swap, reclaim, page migration, ...).
+	 *   - Device page fault.
+	 *   - ...
+	 *
+	 * Any event that block further write to the memory must also trigger a
+	 * device cache flush and everything has to be flush to local memory by
+	 * the time the wait callback return (if this callback returned a fence
+	 * otherwise everything must be flush by the time the callback return).
+	 *
+	 * Device must properly set the dirty bit using hmm_pte_mk_dirty helper
+	 * on each hmm page table entry.
+	 *
+	 * The driver should return a fence pointer or NULL on success. Device
+	 * driver should return fence and delay wait for the operation to the
+	 * fence wait callback. Returning a fence allow hmm to batch update to
+	 * several devices and delay wait on those once they all have scheduled
+	 * the update.
+	 *
+	 * Device driver must not fail lightly, any failure result in device
+	 * process being kill.
+	 *
+	 * Return fence or NULL on success, error value otherwise :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	struct hmm_fence *(*update)(struct hmm_mirror *mirror,
+				    struct hmm_event *event,
+				    const struct hmm_range *range);
+};
+
+
+/* struct hmm_device - per device hmm structure
+ *
+ * @name: Device name (uniquely identify the device on the system).
+ * @ops: The hmm operations callback.
+ * @mirrors: List of all active mirrors for the device.
+ * @mutex: Mutex protecting mirrors list.
+ *
+ * Each device that want to mirror an address space must register one of this
+ * struct (only once).
+ */
+struct hmm_device {
+	const char			*name;
+	const struct hmm_device_ops	*ops;
+	struct list_head		mirrors;
+	struct mutex			mutex;
+};
+
+int hmm_device_register(struct hmm_device *device);
+int hmm_device_unregister(struct hmm_device *device);
+
+
+/* hmm_mirror - device specific mirroring functions.
+ *
+ * Each device that mirror a process has a uniq hmm_mirror struct associating
+ * the process address space with the device. Same process can be mirrored by
+ * several different devices at the same time.
+ */
+
+/* struct hmm_mirror - per device and per mm hmm structure
+ *
+ * @device: The hmm_device struct this hmm_mirror is associated to.
+ * @hmm: The hmm struct this hmm_mirror is associated to.
+ * @dlist: List of all hmm_mirror for same device.
+ * @mlist: List of all hmm_mirror for same process.
+ * @work: Work struct for delayed unreference.
+ *
+ * Each device that want to mirror an address space must register one of this
+ * struct for each of the address space it wants to mirror. Same device can
+ * mirror several different address space. As well same address space can be
+ * mirror by different devices.
+ */
+struct hmm_mirror {
+	struct hmm_device	*device;
+	struct hmm		*hmm;
+	struct list_head	dlist;
+	struct list_head	mlist;
+	struct work_struct	work;
+};
+
+int hmm_mirror_register(struct hmm_mirror *mirror,
+			struct hmm_device *device,
+			struct mm_struct *mm);
+void hmm_mirror_unregister(struct hmm_mirror *mirror);
+
+static inline struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror)
+{
+	if (!mirror || !mirror->device)
+		return NULL;
+
+	return mirror->device->ops->mirror_ref(mirror);
+}
+
+static inline struct hmm_mirror *hmm_mirror_unref(struct hmm_mirror *mirror)
+{
+	if (!mirror || !mirror->device)
+		return NULL;
+
+	return mirror->device->ops->mirror_unref(mirror);
+}
+
+void hmm_mirror_release(struct hmm_mirror *mirror);
+int hmm_mirror_fault(struct hmm_mirror *mirror, struct hmm_event *event);
+
+
+#endif /* CONFIG_HMM */
+#endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b922a16..1f07826 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2172,5 +2172,16 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+#ifdef CONFIG_HMM
+static inline void hmm_mm_init(struct mm_struct *mm)
+{
+	mm->hmm = NULL;
+}
+#else /* !CONFIG_HMM */
+static inline void hmm_mm_init(struct mm_struct *mm)
+{
+}
+#endif /* !CONFIG_HMM */
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 33a8acf..57ea037 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -16,6 +16,10 @@
 #include <asm/page.h>
 #include <asm/mmu.h>
 
+#ifdef CONFIG_HMM
+struct hmm;
+#endif
+
 #ifndef AT_VECTOR_SIZE_ARCH
 #define AT_VECTOR_SIZE_ARCH 0
 #endif
@@ -430,6 +434,16 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+#ifdef CONFIG_HMM
+	/*
+	 * hmm always register an mmu_notifier we rely on mmu notifier to keep
+	 * refcount on mm struct as well as forbiding registering hmm on a
+	 * dying mm
+	 *
+	 * This field is set with mmap_sem old in write mode.
+	 */
+	struct hmm *hmm;
+#endif
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index 4dc2dda..0bb9dc4 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -27,6 +27,7 @@
 #include <linux/binfmts.h>
 #include <linux/mman.h>
 #include <linux/mmu_notifier.h>
+#include <linux/hmm.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/vmacache.h>
@@ -568,6 +569,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 	mmu_notifier_mm_init(mm);
+	hmm_mm_init(mm);
 	clear_tlb_flush_pending(mm);
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
diff --git a/mm/Kconfig b/mm/Kconfig
index 1d1ae6b..b249db0 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -618,3 +618,18 @@ config MAX_STACK_SIZE_MB
 	  changed to a smaller value in which case that is used.
 
 	  A sane initial value is 80 MB.
+
+if STAGING
+config HMM
+	bool "Enable heterogeneous memory management (HMM)"
+	depends on MMU
+	select MMU_NOTIFIER
+	select GENERIC_PAGE_TABLE
+	default n
+	help
+	  Heterogeneous memory management provide infrastructure for a device
+	  to mirror a process address space into an hardware mmu or into any
+	  things supporting pagefault like event.
+
+	  If unsure, say N to disable hmm.
+endif # STAGING
diff --git a/mm/Makefile b/mm/Makefile
index 9c4371d..8e78060 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -71,3 +71,4 @@ obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
 obj-$(CONFIG_CMA)	+= cma.o
 obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
+obj-$(CONFIG_HMM) += hmm.o
diff --git a/mm/hmm.c b/mm/hmm.c
new file mode 100644
index 0000000..25c20ac
--- /dev/null
+++ b/mm/hmm.c
@@ -0,0 +1,1156 @@
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
+/* This is the core code for heterogeneous memory management (HMM). HMM intend
+ * to provide helper for mirroring a process address space on a device as well
+ * as allowing migration of data between system memory and device memory refer
+ * as remote memory from here on out.
+ *
+ * Refer to include/linux/hmm.h for further informations on general design.
+ */
+#include <linux/export.h>
+#include <linux/bitmap.h>
+#include <linux/list.h>
+#include <linux/rculist.h>
+#include <linux/slab.h>
+#include <linux/mmu_notifier.h>
+#include <linux/mm.h>
+#include <linux/hugetlb.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/ksm.h>
+#include <linux/rmap.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/mmu_context.h>
+#include <linux/memcontrol.h>
+#include <linux/hmm.h>
+#include <linux/wait.h>
+#include <linux/mman.h>
+#include <linux/delay.h>
+#include <linux/workqueue.h>
+#include <linux/gpt.h>
+
+#include "internal.h"
+
+/* global SRCU for all HMMs */
+static struct srcu_struct srcu;
+
+
+/* struct hmm - per mm_struct hmm structure
+ *
+ * @device_faults: List of all active device page faults.
+ * @mirrors: List of all mirror for this mm (one per device).
+ * @mm: The mm struct this hmm is associated with.
+ * @ndevice_faults: Number of active device page faults.
+ * @kref: Reference counter
+ * @lock: Serialize the mirror list modifications.
+ * @wait_queue: Wait queue for event synchronization.
+ * @mmu_notifier: The mmu_notifier of this mm.
+ *
+ * For each process address space (mm_struct) there is one and only one hmm
+ * struct. hmm functions will redispatch to each devices the change made to
+ * the process address space.
+ */
+struct hmm {
+	struct list_head	device_faults;
+	struct list_head	mirrors;
+	struct mm_struct	*mm;
+	unsigned long		ndevice_faults;
+	struct kref		kref;
+	spinlock_t		lock;
+	wait_queue_head_t	wait_queue;
+	struct mmu_notifier	mmu_notifier;
+	struct gpt		pt;
+};
+
+static struct mmu_notifier_ops hmm_notifier_ops;
+
+static inline struct hmm *hmm_ref(struct hmm *hmm);
+static inline struct hmm *hmm_unref(struct hmm *hmm);
+
+static void hmm_mirror_delayed_unref(struct work_struct *work);
+static void hmm_mirror_handle_error(struct hmm_mirror *mirror);
+
+static void hmm_device_fence_wait(struct hmm_device *device,
+				  struct hmm_fence *fence);
+
+
+/* hmm_event - use to track information relating to an event.
+ *
+ * Each change to cpu page table or fault from a device is considered as an
+ * event by hmm. For each event there is a common set of things that need to
+ * be tracked. The hmm_event struct centralize those and the helper functions
+ * help dealing with all this.
+ */
+
+static inline bool hmm_event_overlap(struct hmm_event *a, struct hmm_event *b)
+{
+	return !((a->end <= b->start) || (a->start >= b->end));
+}
+
+static inline void hmm_event_init(struct hmm_event *event,
+				  unsigned long start,
+				  unsigned long end)
+{
+	event->start = start & PAGE_MASK;
+	event->end = PAGE_ALIGN(end);
+	INIT_LIST_HEAD(&event->fences);
+}
+
+static inline void hmm_event_wait(struct hmm_event *event)
+{
+	struct hmm_fence *fence, *tmp;
+
+	if (list_empty(&event->fences))
+		/* Nothing to wait for. */
+		return;
+
+	io_schedule();
+
+	list_for_each_entry_safe(fence, tmp, &event->fences, list) {
+		hmm_device_fence_wait(fence->mirror->device, fence);
+	}
+}
+
+
+/* hmm_range - range helper functions.
+ *
+ * Range are use to communicate btw various hmm function and device driver.
+ */
+
+static void hmm_range_update_mirrors(struct hmm_range *range,
+				     struct hmm *hmm,
+				     struct hmm_event *event)
+{
+	struct hmm_mirror *mirror;
+	int id;
+
+	id = srcu_read_lock(&srcu);
+	list_for_each_entry(mirror, &hmm->mirrors, mlist) {
+		struct hmm_device *device = mirror->device;
+		struct hmm_fence *fence;
+
+		fence = device->ops->update(mirror, event, range);
+		if (fence) {
+			if (IS_ERR(fence)) {
+				hmm_mirror_handle_error(mirror);
+			} else {
+				fence->mirror = hmm_mirror_ref(mirror);
+				list_add_tail(&fence->list, &event->fences);
+			}
+		}
+	}
+	srcu_read_unlock(&srcu, id);
+}
+
+static bool hmm_range_wprot(struct hmm_range *range, struct hmm *hmm)
+{
+	unsigned long i;
+	bool update = false;
+
+	for (i = 0; i < (hmm_range_size(range) >> PAGE_SHIFT); ++i) {
+		update |= hmm_pte_clear_write(&range->pte[i]);
+	}
+	return update;
+}
+
+static void hmm_range_clear(struct hmm_range *range, struct hmm *hmm)
+{
+	unsigned long i;
+
+	for (i = 0; i < (hmm_range_size(range) >> PAGE_SHIFT); ++i)
+		if (hmm_pte_clear_valid_smem(&range->pte[i]))
+			gpt_pdp_unref(&hmm->pt, range->pdp);
+}
+
+
+/* hmm - core hmm functions.
+ *
+ * Core hmm functions that deal with all the process mm activities and use
+ * event for synchronization. Those function are use mostly as result of cpu
+ * mm event.
+ */
+
+static uint64_t hmm_pde_from_pdp(struct gpt *gpt, struct page *pdp)
+{
+	uint64_t pde;
+
+	pde = (page_to_pfn(pdp) << PAGE_SHIFT);
+	pde |= (1UL << HMM_PTE_VALID_PDIR_BIT);
+	return pde;
+}
+
+static int hmm_init(struct hmm *hmm, struct mm_struct *mm)
+{
+	int ret;
+
+	hmm->mm = mm;
+	kref_init(&hmm->kref);
+	INIT_LIST_HEAD(&hmm->device_faults);
+	INIT_LIST_HEAD(&hmm->mirrors);
+	spin_lock_init(&hmm->lock);
+	init_waitqueue_head(&hmm->wait_queue);
+	hmm->ndevice_faults = 0;
+
+	/* Initialize page table. */
+	hmm->pt.last_idx = (mm->highest_vm_end - 1UL) >> PAGE_SHIFT;
+	hmm->pt.pde_mask = PAGE_MASK;
+	hmm->pt.pde_shift = PAGE_SHIFT;
+	hmm->pt.pde_valid = 1UL << HMM_PTE_VALID_PDIR_BIT;
+	hmm->pt.pde_from_pdp = &hmm_pde_from_pdp;
+	hmm->pt.gfp_flags = GFP_HIGHUSER;
+	ret = gpt_ulong_init(&hmm->pt);
+	if (ret)
+		return ret;
+
+	/* register notifier */
+	hmm->mmu_notifier.ops = &hmm_notifier_ops;
+	return __mmu_notifier_register(&hmm->mmu_notifier, mm);
+}
+
+static void hmm_del_mirror_locked(struct hmm *hmm, struct hmm_mirror *mirror)
+{
+	list_del_rcu(&mirror->mlist);
+}
+
+static int hmm_add_mirror(struct hmm *hmm, struct hmm_mirror *mirror)
+{
+	struct hmm_mirror *tmp_mirror;
+
+	spin_lock(&hmm->lock);
+	list_for_each_entry_rcu (tmp_mirror, &hmm->mirrors, mlist)
+		if (tmp_mirror->device == mirror->device) {
+			/* Same device can mirror only once. */
+			spin_unlock(&hmm->lock);
+			return -EINVAL;
+		}
+	list_add_rcu(&mirror->mlist, &hmm->mirrors);
+	spin_unlock(&hmm->lock);
+
+	return 0;
+}
+
+static inline struct hmm *hmm_ref(struct hmm *hmm)
+{
+	if (hmm) {
+		if (!kref_get_unless_zero(&hmm->kref))
+			return NULL;
+		return hmm;
+	}
+	return NULL;
+}
+
+static void hmm_destroy(struct kref *kref)
+{
+	struct hmm *hmm;
+
+	hmm = container_of(kref, struct hmm, kref);
+
+	down_write(&hmm->mm->mmap_sem);
+	/* A new hmm might have been register before we get call. */
+	if (hmm->mm->hmm == hmm)
+		hmm->mm->hmm = NULL;
+	up_write(&hmm->mm->mmap_sem);
+	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
+
+	mmu_notifier_synchronize();
+
+	gpt_free(&hmm->pt);
+	kfree(hmm);
+}
+
+static inline struct hmm *hmm_unref(struct hmm *hmm)
+{
+	if (hmm)
+		kref_put(&hmm->kref, hmm_destroy);
+	return NULL;
+}
+
+static int hmm_device_fault_start(struct hmm *hmm, struct hmm_event *fevent)
+{
+	int ret = 0;
+
+	mmu_notifier_range_wait_valid(hmm->mm, fevent->start, fevent->end);
+
+	spin_lock(&hmm->lock);
+	if (mmu_notifier_range_is_valid(hmm->mm, fevent->start, fevent->end)) {
+		list_add_tail(&fevent->list, &hmm->device_faults);
+		hmm->ndevice_faults++;
+		fevent->backoff = false;
+	} else
+		ret = -EAGAIN;
+	spin_unlock(&hmm->lock);
+	wake_up(&hmm->wait_queue);
+
+	return ret;
+}
+
+static void hmm_device_fault_end(struct hmm *hmm, struct hmm_event *fevent)
+{
+	spin_lock(&hmm->lock);
+	list_del_init(&fevent->list);
+	hmm->ndevice_faults--;
+	spin_unlock(&hmm->lock);
+	wake_up(&hmm->wait_queue);
+}
+
+static void hmm_wait_device_fault(struct hmm *hmm, struct hmm_event *ievent)
+{
+	struct hmm_event *fevent;
+	unsigned long wait_for = 0;
+
+again:
+	spin_lock(&hmm->lock);
+	list_for_each_entry (fevent, &hmm->device_faults, list) {
+		if (!hmm_event_overlap(fevent, ievent))
+			continue;
+		fevent->backoff = true;
+		wait_for = hmm->ndevice_faults;
+	}
+	spin_unlock(&hmm->lock);
+
+	if (wait_for > 0) {
+		wait_event(hmm->wait_queue, wait_for != hmm->ndevice_faults);
+		wait_for = 0;
+		goto again;
+	}
+}
+
+static void hmm_update(struct hmm *hmm,
+		       struct hmm_event *event)
+{
+	struct hmm_range range;
+	struct gpt_lock lock;
+	struct gpt_iter iter;
+	struct gpt *pt = &hmm->pt;
+
+	/* This hmm is already fully stop. */
+	if (hmm->mm->hmm != hmm)
+		return;
+
+	hmm_wait_device_fault(hmm, event);
+
+	lock.first = event->start >> PAGE_SHIFT;
+	lock.last = (event->end - 1UL) >> PAGE_SHIFT;
+	gpt_ulong_lock_update(&hmm->pt, &lock);
+	gpt_iter_init(&iter, &hmm->pt, &lock);
+	if (!gpt_ulong_iter_first(&iter, event->start >> PAGE_SHIFT,
+				  (event->end - 1UL) >> PAGE_SHIFT)) {
+		/* Empty range nothing to invalidate. */
+		gpt_ulong_unlock_update(&hmm->pt, &lock);
+		return;
+	}
+
+	for (range.start = iter.idx << PAGE_SHIFT; iter.pdep;) {
+		bool update_mirrors = true;
+
+		range.pte = iter.pdep;
+		range.pdp = iter.pdp;
+		range.end = min((gpt_pdp_last(pt, iter.pdp) + 1UL) <<
+				PAGE_SHIFT, (uint64_t)event->end);
+		if (event->etype == HMM_WRITE_PROTECT)
+			update_mirrors = hmm_range_wprot(&range, hmm);
+		if (update_mirrors)
+			hmm_range_update_mirrors(&range, hmm, event);
+
+		range.start = range.end;
+		gpt_ulong_iter_first(&iter, range.start >> PAGE_SHIFT,
+				     (event->end - 1UL) >> PAGE_SHIFT);
+	}
+
+	hmm_event_wait(event);
+
+	if (event->etype == HMM_MUNMAP || event->etype == HMM_MIGRATE) {
+		BUG_ON(!gpt_ulong_iter_first(&iter, event->start >> PAGE_SHIFT,
+					     (event->end - 1UL) >> PAGE_SHIFT));
+		for (range.start = iter.idx << PAGE_SHIFT; iter.pdep;) {
+			range.pte = iter.pdep;
+			range.pdp = iter.pdp;
+			range.end = min((gpt_pdp_last(pt, iter.pdp) + 1UL) <<
+					PAGE_SHIFT, (uint64_t)event->end);
+			hmm_range_clear(&range, hmm);
+			range.start = range.end;
+			gpt_ulong_iter_first(&iter, range.start >> PAGE_SHIFT,
+					     (event->end - 1UL) >> PAGE_SHIFT);
+		}
+	}
+
+	gpt_ulong_unlock_update(&hmm->pt, &lock);
+}
+
+static int hmm_do_mm_fault(struct hmm *hmm,
+			   struct hmm_event *event,
+			   struct vm_area_struct *vma,
+			   unsigned long addr)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	int r;
+
+	for (; addr < event->end; addr += PAGE_SIZE) {
+		unsigned flags = 0;
+
+		flags |= event->etype == HMM_WFAULT ? FAULT_FLAG_WRITE : 0;
+		flags |= FAULT_FLAG_ALLOW_RETRY;
+		do {
+			r = handle_mm_fault(mm, vma, addr, flags);
+			if (!(r & VM_FAULT_RETRY) && (r & VM_FAULT_ERROR)) {
+				if (r & VM_FAULT_OOM)
+					return -ENOMEM;
+				/* Same error code for all other cases. */
+				return -EFAULT;
+			}
+			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+		} while (r & VM_FAULT_RETRY);
+	}
+
+	return 0;
+}
+
+
+/* hmm_notifier - HMM callback for mmu_notifier tracking change to process mm.
+ *
+ * HMM use use mmu notifier to track change made to process address space.
+ */
+
+static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	struct hmm_mirror *mirror;
+	struct hmm *hmm;
+
+	/* The hmm structure can not be free because the mmu_notifier srcu is
+	 * read locked thus any concurrent hmm_mirror_unregister that would
+	 * free hmm would have to wait on the mmu_notifier.
+	 */
+	hmm = container_of(mn, struct hmm, mmu_notifier);
+	spin_lock(&hmm->lock);
+	mirror = list_first_or_null_rcu(&hmm->mirrors,
+					struct hmm_mirror,
+					mlist);
+	while (mirror) {
+		hmm_del_mirror_locked(hmm, mirror);
+		spin_unlock(&hmm->lock);
+
+		mirror->device->ops->mirror_release(mirror);
+		INIT_WORK(&mirror->work, hmm_mirror_delayed_unref);
+		schedule_work(&mirror->work);
+
+		spin_lock(&hmm->lock);
+		mirror = list_first_or_null_rcu(&hmm->mirrors,
+						struct hmm_mirror,
+						mlist);
+	}
+	spin_unlock(&hmm->lock);
+
+	synchronize_srcu(&srcu);
+
+	wake_up(&hmm->wait_queue);
+}
+
+static void hmm_mmu_mprot_to_etype(struct mm_struct *mm,
+				   unsigned long addr,
+				   enum mmu_event mmu_event,
+				   enum hmm_etype *etype)
+{
+	struct vm_area_struct *vma;
+
+	vma = find_vma(mm, addr);
+	if (!vma || vma->vm_start > addr || !(vma->vm_flags & VM_READ)) {
+		*etype = HMM_MUNMAP;
+		return;
+	}
+
+	if (!(vma->vm_flags & VM_WRITE)) {
+		*etype = HMM_WRITE_PROTECT;
+		return;
+	}
+
+	*etype = HMM_NONE;
+}
+
+static void hmm_notifier_invalidate_range_start(struct mmu_notifier *mn,
+						struct mm_struct *mm,
+						const struct mmu_notifier_range *range)
+{
+	struct hmm_event event;
+	unsigned long start = range->start, end = range->end;
+	struct hmm *hmm;
+
+	/* FIXME this should not happen beside when process is exiting. */
+	if (start >= mm->highest_vm_end)
+		return;
+	if (end > mm->highest_vm_end)
+		end = mm->highest_vm_end;
+
+	switch (range->event) {
+	case MMU_HSPLIT:
+	case MMU_MUNLOCK:
+		/* Still same physical ram backing same address. */
+		return;
+	case MMU_MPROT:
+		hmm_mmu_mprot_to_etype(mm, start, range->event, &event.etype);
+		if (event.etype == HMM_NONE)
+			return;
+		break;
+	case MMU_WRITE_BACK:
+	case MMU_WRITE_PROTECT:
+		event.etype = HMM_WRITE_PROTECT;
+		break;
+	case MMU_ISDIRTY:
+		event.etype = HMM_ISDIRTY;
+		break;
+	case MMU_MUNMAP:
+		event.etype = HMM_MUNMAP;
+		break;
+	case MMU_MIGRATE:
+	default:
+		event.etype = HMM_MIGRATE;
+		break;
+	}
+
+	hmm = container_of(mn, struct hmm, mmu_notifier);
+	hmm_event_init(&event, start, end);
+
+	hmm_update(hmm, &event);
+}
+
+static void hmm_notifier_invalidate_page(struct mmu_notifier *mn,
+					 struct mm_struct *mm,
+					 unsigned long addr,
+					 enum mmu_event mmu_event)
+{
+	struct mmu_notifier_range range;
+
+	range.start = addr & PAGE_MASK;
+	range.end = range.start + PAGE_SIZE;
+	range.event = mmu_event;
+	hmm_notifier_invalidate_range_start(mn, mm, &range);
+}
+
+static struct mmu_notifier_ops hmm_notifier_ops = {
+	.release		= hmm_notifier_release,
+	/* .clear_flush_young FIXME we probably want to do something. */
+	/* .test_young FIXME we probably want to do something. */
+	/* WARNING .change_pte must always bracketed by range_start/end there
+	 * was patches to remove that behavior we must make sure that those
+	 * patches are not included as there are alternative solutions to issue
+	 * they are trying to solve.
+	 *
+	 * Fact is hmm can not use the change_pte callback as non sleeping lock
+	 * are held during change_pte callback.
+	 */
+	.change_pte		= NULL,
+	.invalidate_page	= hmm_notifier_invalidate_page,
+	.invalidate_range_start	= hmm_notifier_invalidate_range_start,
+};
+
+
+/* hmm_mirror - per device mirroring functions.
+ *
+ * Each device that mirror a process has a uniq hmm_mirror struct. A process
+ * can be mirror by several devices at the same time.
+ *
+ * Below are all the functions and their helpers use by device driver to mirror
+ * the process address space. Those functions either deals with updating the
+ * device page table (through hmm callback). Or provide helper functions use by
+ * the device driver to fault in range of memory in the device page table.
+ */
+
+/* hmm_mirror_register() - register a device mirror against an mm struct
+ *
+ * @mirror: The mirror that link process address space with the device.
+ * @device: The device struct to associate this mirror with.
+ * @mm: The mm struct of the process.
+ * Returns: 0 success, -ENOMEM or -EINVAL if process already mirrored.
+ *
+ * Call when device driver want to start mirroring a process address space. The
+ * hmm shim will register mmu_notifier and start monitoring process address
+ * space changes. Hence callback to device driver might happen even before this
+ * function return.
+ *
+ * The mm pin must also be hold (either task is current or using get_task_mm).
+ *
+ * Only one mirror per mm and hmm_device can be created, it will return -EINVAL
+ * if the hmm_device already has an hmm_mirror for the the mm.
+ */
+int hmm_mirror_register(struct hmm_mirror *mirror,
+			struct hmm_device *device,
+			struct mm_struct *mm)
+{
+	struct hmm *hmm = NULL;
+	int ret = 0;
+
+	/* Sanity checks. */
+	BUG_ON(!mirror);
+	BUG_ON(!device);
+	BUG_ON(!mm);
+
+	/*
+	 * Initialize the mirror struct fields, the mlist init and del dance is
+	 * necessary to make the error path easier for driver and for hmm.
+	 */
+	INIT_LIST_HEAD(&mirror->mlist);
+	list_del(&mirror->mlist);
+	INIT_LIST_HEAD(&mirror->dlist);
+	mutex_lock(&device->mutex);
+	mirror->device = device;
+	list_add(&mirror->dlist, &device->mirrors);
+	mutex_unlock(&device->mutex);
+	mirror->hmm = NULL;
+	mirror = hmm_mirror_ref(mirror);
+	if (!mirror) {
+		mutex_lock(&device->mutex);
+		list_del_init(&mirror->dlist);
+		mutex_unlock(&device->mutex);
+		return -EINVAL;
+	}
+
+	down_write(&mm->mmap_sem);
+
+	hmm = mm->hmm ? hmm_ref(hmm) : NULL;
+	if (hmm == NULL) {
+		/* no hmm registered yet so register one */
+		hmm = kzalloc(sizeof(*mm->hmm), GFP_KERNEL);
+		if (hmm == NULL) {
+			up_write(&mm->mmap_sem);
+			hmm_mirror_unref(mirror);
+			return -ENOMEM;
+		}
+
+		ret = hmm_init(hmm, mm);
+		if (ret) {
+			up_write(&mm->mmap_sem);
+			hmm_mirror_unref(mirror);
+			kfree(hmm);
+			return ret;
+		}
+
+		mm->hmm = hmm;
+	}
+
+	mirror->hmm = hmm;
+	ret = hmm_add_mirror(hmm, mirror);
+	up_write(&mm->mmap_sem);
+	if (ret) {
+		mirror->hmm = NULL;
+		hmm_mirror_unref(mirror);
+		hmm_unref(hmm);
+		return ret;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_mirror_register);
+
+static void hmm_mirror_delayed_unref(struct work_struct *work)
+{
+	struct hmm_mirror *mirror;
+
+	mirror = container_of(work, struct hmm_mirror, work);
+	hmm_mirror_unref(mirror);
+}
+
+static void hmm_mirror_handle_error(struct hmm_mirror *mirror)
+{
+	struct hmm *hmm = mirror->hmm;
+
+	spin_lock(&hmm->lock);
+	if (mirror->mlist.prev != LIST_POISON2) {
+		hmm_del_mirror_locked(hmm, mirror);
+		spin_unlock(&hmm->lock);
+
+		mirror->device->ops->mirror_release(mirror);
+		INIT_WORK(&mirror->work, hmm_mirror_delayed_unref);
+		schedule_work(&mirror->work);
+	} else
+		spin_unlock(&hmm->lock);
+}
+
+/* hmm_mirror_unregister() - unregister an hmm_mirror.
+ *
+ * @mirror: The mirror that link process address space with the device.
+ *
+ * Device driver must call this function when it is destroying a registered
+ * mirror structure. If destruction was initiated by the device driver then
+ * it must have call hmm_mirror_release() prior to calling this function.
+ */
+void hmm_mirror_unregister(struct hmm_mirror *mirror)
+{
+	BUG_ON(!mirror || !mirror->device);
+	BUG_ON(mirror->mlist.prev != LIST_POISON2);
+
+	mirror->hmm = hmm_unref(mirror->hmm);
+
+	mutex_lock(&mirror->device->mutex);
+	list_del_init(&mirror->dlist);
+	mutex_unlock(&mirror->device->mutex);
+	mirror->device = NULL;
+}
+EXPORT_SYMBOL(hmm_mirror_unregister);
+
+/* hmm_mirror_release() - release an hmm_mirror.
+ *
+ * @mirror: The mirror that link process address space with the device.
+ *
+ * Device driver must call this function when it wants to stop mirroring the
+ * process.
+ */
+void hmm_mirror_release(struct hmm_mirror *mirror)
+{
+	if (!mirror->hmm)
+		return;
+
+	spin_lock(&mirror->hmm->lock);
+	/* Check if the mirror is already removed from the mirror list in which
+	 * case there is no reason to call release.
+	 */
+	if (mirror->mlist.prev != LIST_POISON2) {
+		hmm_del_mirror_locked(mirror->hmm, mirror);
+		spin_unlock(&mirror->hmm->lock);
+
+		mirror->device->ops->mirror_release(mirror);
+		synchronize_srcu(&srcu);
+
+		hmm_mirror_unref(mirror);
+	} else
+		spin_unlock(&mirror->hmm->lock);
+}
+EXPORT_SYMBOL(hmm_mirror_release);
+
+static int hmm_mirror_update(struct hmm_mirror *mirror,
+			     struct hmm_event *event,
+			     unsigned long *start,
+			     struct gpt_iter *iter)
+{
+	unsigned long addr = *start & PAGE_MASK;
+
+	if (!gpt_ulong_iter_idx(iter, addr >> PAGE_SHIFT))
+		return -EINVAL;
+
+	do {
+		struct hmm_device *device = mirror->device;
+		unsigned long *pte = (unsigned long *)iter->pdep;
+		struct hmm_fence *fence;
+		struct hmm_range range;
+
+		if (event->backoff)
+			return -EAGAIN;
+
+		range.start = addr;
+		range.end = min((gpt_pdp_last(iter->gpt, iter->pdp) + 1UL) <<
+				PAGE_SHIFT, (uint64_t)event->end);
+		range.pte = iter->pdep;
+		for (; addr < range.end; addr += PAGE_SIZE, ++pte) {
+			if (!hmm_pte_is_valid_smem(pte)) {
+				*start = addr;
+				return 0;
+			}
+			if (event->etype == HMM_WFAULT &&
+			    !hmm_pte_is_write(pte)) {
+				*start = addr;
+				return 0;
+			}
+		}
+
+		fence = device->ops->update(mirror, event, &range);
+		if (fence) {
+			if (IS_ERR(fence)) {
+				*start = range.start;
+				return -EIO;
+			}
+			fence->mirror = hmm_mirror_ref(mirror);
+			list_add_tail(&fence->list, &event->fences);
+		}
+
+	} while (addr < event->end &&
+		 gpt_ulong_iter_idx(iter, addr >> PAGE_SHIFT));
+
+	*start = addr;
+	return 0;
+}
+
+struct hmm_mirror_fault {
+	struct hmm_mirror	*mirror;
+	struct hmm_event	*event;
+	struct vm_area_struct	*vma;
+	unsigned long		addr;
+	struct gpt_iter		*iter;
+};
+
+static int hmm_mirror_fault_hpmd(struct hmm_mirror *mirror,
+				 struct hmm_event *event,
+				 struct vm_area_struct *vma,
+				 struct gpt_iter *iter,
+				 pmd_t *pmdp,
+				 unsigned long start,
+				 unsigned long end)
+{
+	struct page *page;
+	unsigned long *hmm_pte, i;
+	unsigned flags = FOLL_TOUCH;
+	spinlock_t *ptl;
+
+	ptl = pmd_lock(mirror->hmm->mm, pmdp);
+	if (unlikely(!pmd_trans_huge(*pmdp))) {
+		spin_unlock(ptl);
+		return -EAGAIN;
+	}
+	if (unlikely(pmd_trans_splitting(*pmdp))) {
+		spin_unlock(ptl);
+		wait_split_huge_page(vma->anon_vma, pmdp);
+		return -EAGAIN;
+	}
+	flags |= event->etype == HMM_WFAULT ? FOLL_WRITE : 0;
+	page = follow_trans_huge_pmd(vma, start, pmdp, flags);
+	spin_unlock(ptl);
+
+	BUG_ON(!gpt_ulong_iter_idx(iter, start >> PAGE_SHIFT));
+	hmm_pte = iter->pdep;
+
+	gpt_pdp_lock(&mirror->hmm->pt, iter->pdp);
+	for (i = 0; start < end; start += PAGE_SIZE, ++i, ++page) {
+		if (!hmm_pte_is_valid_smem(&hmm_pte[i])) {
+			hmm_pte[i] = hmm_pte_from_pfn(page_to_pfn(page));
+			gpt_pdp_ref(&mirror->hmm->pt, iter->pdp);
+		}
+		BUG_ON(hmm_pte_pfn(hmm_pte[i]) != page_to_pfn(page));
+		if (pmd_write(*pmdp))
+			hmm_pte_mk_write(&hmm_pte[i]);
+	}
+	gpt_pdp_unlock(&mirror->hmm->pt, iter->pdp);
+
+	return 0;
+}
+
+static int hmm_mirror_fault_pmd(pmd_t *pmdp,
+				unsigned long start,
+				unsigned long end,
+				struct mm_walk *walk)
+{
+	struct hmm_mirror_fault *mirror_fault = walk->private;
+	struct vm_area_struct *vma = mirror_fault->vma;
+	struct hmm_mirror *mirror = mirror_fault->mirror;
+	struct hmm_event *event = mirror_fault->event;
+	struct gpt_iter *iter = mirror_fault->iter;
+	unsigned long addr = start, i, *hmm_pte;
+	struct hmm *hmm = mirror->hmm;
+	pte_t *ptep;
+	int ret = 0;
+
+	/* Make sure there was no gap. */
+	if (start != mirror_fault->addr)
+		return -ENOENT;
+
+	if (event->backoff)
+		return -EAGAIN;
+
+	if (pmd_none(*pmdp))
+		return -ENOENT;
+
+	if (pmd_trans_huge(*pmdp)) {
+		ret = hmm_mirror_fault_hpmd(mirror, event, vma, iter,
+					    pmdp, start, end);
+		mirror_fault->addr = ret ? start : end;
+		return ret;
+	}
+
+	if (pmd_none_or_trans_huge_or_clear_bad(pmdp))
+		return -EFAULT;
+
+	BUG_ON(!gpt_ulong_iter_idx(iter, start >> PAGE_SHIFT));
+	hmm_pte = iter->pdep;
+
+	ptep = pte_offset_map(pmdp, start);
+	gpt_pdp_lock(&hmm->pt, iter->pdp);
+	for (i = 0; addr < end; addr += PAGE_SIZE, ++i) {
+		if (!pte_present(*ptep) ||
+		    ((event->etype == HMM_WFAULT) && !pte_write(*ptep))) {
+			ptep++;
+			ret = -ENOENT;
+			break;
+		}
+
+		if (!hmm_pte_is_valid_smem(&hmm_pte[i])) {
+			hmm_pte[i] = hmm_pte_from_pfn(pte_pfn(*ptep));
+			gpt_pdp_ref(&hmm->pt, iter->pdp);
+		}
+		BUG_ON(hmm_pte_pfn(hmm_pte[i]) != pte_pfn(*ptep));
+		if (pte_write(*ptep))
+			hmm_pte_mk_write(&hmm_pte[i]);
+		ptep++;
+	}
+	gpt_pdp_unlock(&hmm->pt, iter->pdp);
+	pte_unmap(ptep - 1);
+	mirror_fault->addr = addr;
+
+	return ret;
+}
+
+static int hmm_mirror_handle_fault(struct hmm_mirror *mirror,
+				   struct hmm_event *event,
+				   struct vm_area_struct *vma)
+{
+	struct hmm_mirror_fault mirror_fault;
+	struct mm_walk walk = {0};
+	struct gpt_lock lock;
+	struct gpt_iter iter;
+	unsigned long addr;
+	int ret = 0;
+
+	if ((event->etype == HMM_WFAULT) && !(vma->vm_flags & VM_WRITE))
+		return -EACCES;
+
+	ret = hmm_device_fault_start(mirror->hmm, event);
+	if (ret)
+		return ret;
+
+	addr = event->start;
+	lock.first = event->start >> PAGE_SHIFT;
+	lock.last = (event->end - 1UL) >> PAGE_SHIFT;
+	ret = gpt_ulong_lock_fault(&mirror->hmm->pt, &lock);
+	if (ret) {
+		hmm_device_fault_end(mirror->hmm, event);
+		return ret;
+	}
+	gpt_iter_init(&iter, &mirror->hmm->pt, &lock);
+
+again:
+	ret = hmm_mirror_update(mirror, event, &addr, &iter);
+	if (ret)
+		goto out;
+
+	if (event->backoff) {
+		ret = -EAGAIN;
+		goto out;
+	}
+	if (addr >= event->end)
+		goto out;
+
+	mirror_fault.event = event;
+	mirror_fault.mirror = mirror;
+	mirror_fault.vma = vma;
+	mirror_fault.addr = addr;
+	mirror_fault.iter = &iter;
+	walk.mm = mirror->hmm->mm;
+	walk.private = &mirror_fault;
+	walk.pmd_entry = hmm_mirror_fault_pmd;
+	ret = walk_page_range(addr, event->end, &walk);
+	hmm_event_wait(event);
+	if (!ret)
+		goto again;
+	addr = mirror_fault.addr;
+
+out:
+	gpt_ulong_unlock_fault(&mirror->hmm->pt, &lock);
+	hmm_device_fault_end(mirror->hmm, event);
+	if (ret == -ENOENT) {
+		ret = hmm_do_mm_fault(mirror->hmm, event, vma, addr);
+		ret = ret ? ret : -EAGAIN;
+	}
+	return ret;
+}
+
+/* hmm_mirror_fault() - call by the device driver on device memory fault.
+ *
+ * @mirror: Mirror related to the fault if any.
+ * @event: Event describing the fault.
+ *
+ * Device driver call this function either if it needs to fill its page table
+ * for a range of address or if it needs to migrate memory between system and
+ * remote memory.
+ *
+ * This function perform vma lookup and access permission check on behalf of
+ * the device. If device ask for range [A; D] but there is only a valid vma
+ * starting at B with B > A and B < D then callback will return -EFAULT and
+ * set event->end to B so device driver can either report an issue back or
+ * call again the hmm_mirror_fault with range updated to [B; D].
+ *
+ * This allows device driver to optimistically fault range of address without
+ * having to know about valid vma range. Device driver can then take proper
+ * action if a real memory access happen inside an invalid address range.
+ *
+ * Also the fault will clamp the requested range to valid vma range (unless the
+ * vma into which event->start falls to, can grow). So in previous example if D
+ * D is not cover by any vma then hmm_mirror_fault will stop a C with C < D and
+ * C being the last address of a valid vma. Also event->end will be set to C.
+ *
+ * All error must be handled by device driver and most likely result in the
+ * process device tasks to be kill by the device driver.
+ *
+ * Returns:
+ * > 0 Number of pages faulted.
+ * -EINVAL if invalid argument.
+ * -ENOMEM if failing to allocate memory.
+ * -EACCES if trying to write to read only address.
+ * -EFAULT if trying to access an invalid address.
+ * -ENODEV if mirror is in process of being destroy.
+ * -EIO if device driver update callback failed.
+ */
+int hmm_mirror_fault(struct hmm_mirror *mirror, struct hmm_event *event)
+{
+	struct vm_area_struct *vma;
+	int ret = 0;
+
+	if (!mirror || !event || event->start >= event->end)
+		return -EINVAL;
+
+	hmm_event_init(event, event->start, event->end);
+	if (event->end > mirror->hmm->mm->highest_vm_end)
+		return -EFAULT;
+
+retry:
+	if (!mirror->hmm->mm->hmm)
+		return -ENODEV;
+
+	/*
+	 * So synchronization with the cpu page table is the most important
+	 * and tedious aspect of device page fault. There must be a strong
+	 * ordering btw call to device->update() for device page fault and
+	 * device->update() for cpu page table invalidation/update.
+	 *
+	 * Page that are exposed to device driver must stay valid while the
+	 * callback is in progress ie any cpu page table invalidation that
+	 * render those pages obsolete must call device->update() after the
+	 * device->update() call that faulted those pages.
+	 *
+	 * To achieve this we rely on few things. First the mmap_sem insure
+	 * us that any munmap() syscall will serialize with us. So issue are
+	 * with unmap_mapping_range() and with migrate or merge page. For this
+	 * hmm keep track of affected range of address and block device page
+	 * fault that hit overlapping range.
+	 */
+	down_read(&mirror->hmm->mm->mmap_sem);
+	vma = find_vma_intersection(mirror->hmm->mm, event->start, event->end);
+	if (!vma) {
+		ret = -EFAULT;
+		goto out;
+	}
+	if (vma->vm_start > event->start) {
+		event->end = vma->vm_start;
+		ret = -EFAULT;
+		goto out;
+	}
+	event->end = min(event->end, vma->vm_end);
+	if ((vma->vm_flags & (VM_IO | VM_PFNMAP | VM_MIXEDMAP | VM_HUGETLB))) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	switch (event->etype) {
+	case HMM_RFAULT:
+	case HMM_WFAULT:
+		ret = hmm_mirror_handle_fault(mirror, event, vma);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+out:
+	/* Drop the mmap_sem so anyone waiting on it have a chance. */
+	up_read(&mirror->hmm->mm->mmap_sem);
+	if (ret == -EAGAIN)
+		goto retry;
+	return ret;
+}
+EXPORT_SYMBOL(hmm_mirror_fault);
+
+
+/* hmm_device - Each device driver must register one and only one hmm_device
+ *
+ * The hmm_device is the link btw hmm and each device driver.
+ */
+
+/* hmm_device_register() - register a device with hmm.
+ *
+ * @device: The hmm_device struct.
+ * Returns: 0 on success, -EINVAL otherwise.
+ *
+ * Call when device driver want to register itself with hmm. Device driver can
+ * only register once. It will return a reference on the device thus to release
+ * a device the driver must unreference the device.
+ */
+int hmm_device_register(struct hmm_device *device)
+{
+	/* sanity check */
+	BUG_ON(!device);
+	BUG_ON(!device->ops);
+	BUG_ON(!device->ops->mirror_ref);
+	BUG_ON(!device->ops->mirror_unref);
+	BUG_ON(!device->ops->mirror_release);
+	BUG_ON(!device->ops->fence_wait);
+	BUG_ON(!device->ops->fence_ref);
+	BUG_ON(!device->ops->fence_unref);
+	BUG_ON(!device->ops->update);
+
+	mutex_init(&device->mutex);
+	INIT_LIST_HEAD(&device->mirrors);
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_device_register);
+
+/* hmm_device_unregister() - unregister a device with hmm.
+ *
+ * @device: The hmm_device struct.
+ *
+ * Call when device driver want to unregister itself with hmm. This will check
+ * if there is any active mirror and return -EBUSY if so. It is device driver
+ * responsability to cleanup and stop all mirror before calling this.
+ */
+int hmm_device_unregister(struct hmm_device *device)
+{
+	struct hmm_mirror *mirror;
+
+	mutex_lock(&device->mutex);
+	mirror = list_first_entry_or_null(&device->mirrors,
+					  struct hmm_mirror,
+					  dlist);
+	mutex_unlock(&device->mutex);
+	if (mirror)
+		return -EBUSY;
+	return 0;
+}
+EXPORT_SYMBOL(hmm_device_unregister);
+
+static void hmm_device_fence_wait(struct hmm_device *device,
+				  struct hmm_fence *fence)
+{
+	struct hmm_mirror *mirror;
+	int r;
+
+	if (fence == NULL)
+		return;
+
+	list_del_init(&fence->list);
+	do {
+		r = device->ops->fence_wait(fence);
+		if (r == -EAGAIN)
+			io_schedule();
+	} while (r == -EAGAIN);
+
+	mirror = fence->mirror;
+	device->ops->fence_unref(fence);
+	if (r)
+		hmm_mirror_handle_error(mirror);
+	hmm_mirror_unref(mirror);
+}
+
+
+static int __init hmm_subsys_init(void)
+{
+	return init_srcu_struct(&srcu);
+}
+subsys_initcall(hmm_subsys_init);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
