Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7FD6B010F
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:57:46 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id x12so2228394qac.21
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 11:57:46 -0700 (PDT)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id k91si35202997qgd.65.2014.06.12.11.57.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 11:57:45 -0700 (PDT)
Received: by mail-qa0-f44.google.com with SMTP id hw13so1017505qab.17
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 11:57:45 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 4/5] hmm: heterogeneous memory management v2
Date: Thu, 12 Jun 2014 14:57:33 -0400
Message-Id: <1402599454-3526-4-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1402599454-3526-1-git-send-email-j.glisse@gmail.com>
References: <1402598029-3331-1-git-send-email-j.glisse@gmail.com>
 <1402599454-3526-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>

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
code would be responsible to intercept cpu page fault on migrated range of and
to migrate it back to system memory allowing cpu to resume its access to the
memory.

Another feature hmm intend to provide is support for atomic operation for the
device even if the bus linking the device and the cpu do not have any such
capabilities.

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

For better memory management it is highly recommanded that the device also
support the following features :
  - hardware mmu set access bit in its page table on memory access (like cpu).
  - hardware page table can be updated from cpu or through a fast path.
  - hardware provide advanced statistic over which range of memory it access
    the most.
  - hardware differentiate atomic memory access from regular access allowing
    to support atomic operation even on platform that do not have atomic
    support with there bus link with the device.

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

Change since v1:
  - convert fence to refcounted object
  - change the api to provide pte value directly avoiding useless temporary
    special hmm pfn value
  - cleanups & fixes ...

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 include/linux/hmm.h      |  435 +++++++++++++++++++
 include/linux/mm.h       |   14 +
 include/linux/mm_types.h |   14 +
 kernel/fork.c            |    6 +
 mm/Kconfig               |   12 +
 mm/Makefile              |    1 +
 mm/hmm.c                 | 1078 ++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 1560 insertions(+)
 create mode 100644 include/linux/hmm.h
 create mode 100644 mm/hmm.c

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
new file mode 100644
index 0000000..6c96920
--- /dev/null
+++ b/include/linux/hmm.h
@@ -0,0 +1,435 @@
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
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/* This is a heterogeneous memory management (hmm). In a nutshell this provide
+ * an API to mirror a process address on a device which has its own mmu and its
+ * own page table for the process. It supports everything except special/mixed
+ * vma.
+ *
+ * To use this the hardware must have :
+ *   - mmu with pagetable
+ *   - pagetable must support read only (supporting dirtyness accounting is
+ *     preferable but is not mandatory).
+ *   - support pagefault ie hardware thread should stop on fault and resume
+ *     once hmm has provided valid memory to use.
+ *   - some way to report fault.
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
+#include <linux/swap.h>
+#include <linux/kref.h>
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
+	HMM_UNREGISTER,
+	HMM_MPROT_RONLY,
+	HMM_MPROT_NONE,
+	HMM_COW,
+	HMM_MUNMAP,
+	HMM_RFAULT,
+	HMM_WFAULT,
+};
+
+struct hmm_fence {
+	struct kref		kref;
+	struct hmm_mirror	*mirror;
+	struct list_head	list;
+};
+
+/* struct hmm_event - used to serialize change to overlapping range of address.
+ *
+ * @list:       List of pending|in progress event.
+ * @faddr:      First address (inclusive) for the range this event affect.
+ * @laddr:      Last address (exclusive) for the range this event affect.
+ * @iaddr:      First invalid address.
+ * @fences:     List of device fences associated with this event.
+ * @etype:      Event type (munmap, migrate, truncate, ...).
+ * @backoff:    Should this event backoff ie a new event render it obsolete.
+ */
+struct hmm_event {
+	struct list_head	list;
+	unsigned long		faddr;
+	unsigned long		laddr;
+	unsigned long		iaddr;
+	struct list_head	fences;
+	enum hmm_etype		etype;
+	bool			backoff;
+};
+
+
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
+	/* device_destroy - free hmm_device (call when refcount drop to 0).
+	 *
+	 * @device: The device hmm specific structure.
+	 */
+	void (*device_destroy)(struct hmm_device *device);
+
+	/* mirror_release() - device must stop using the address space.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 *
+	 * Called when as result of hmm_mirror_unregister or when mm is being
+	 * destroy.
+	 *
+	 * It's illegal for the device to call any hmm helper function after
+	 * this call back. The device driver must kill any pending device
+	 * thread and wait for completion of all of them.
+	 *
+	 * Note that even after this callback returns the device driver might
+	 * get call back from hmm. Callback will stop only once mirror_destroy
+	 * is call.
+	 */
+	void (*mirror_release)(struct hmm_mirror *hmm_mirror);
+
+	/* mirror_destroy - free hmm_mirror (call when refcount drop to 0).
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 */
+	void (*mirror_destroy)(struct hmm_mirror *mirror);
+
+	/* fence_wait() - to wait on device driver fence.
+	 *
+	 * @fence:      The device driver fence struct.
+	 * Returns:     0 on success,-EIO on error, -EAGAIN to wait again.
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
+	 * -EIO    Some input/output error with the device.
+	 * -EAGAIN The fence not yet signaled, hmm reschedule waiting thread.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	int (*fence_wait)(struct hmm_fence *fence);
+
+	/* fence_destroy() - destroy fence structure.
+	 *
+	 * @fence:  Fence structure to destroy.
+	 *
+	 * Called when all reference on a fence are gone.
+	 */
+	void (*fence_destroy)(struct hmm_fence *fence);
+
+	/* update() - update device mmu for a range of address.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 * @vma:    The vma into which the update is taking place.
+	 * @faddr:  First address in range (inclusive).
+	 * @laddr:  Last address in range (exclusive).
+	 * @etype:  The type of memory event (unmap, read only, ...).
+	 * Returns: Valid fence ptr or NULL on success otherwise ERR_PTR.
+	 *
+	 * Called to update device mmu permission/usage for a range of address.
+	 * The event type provide the nature of the update :
+	 *   - range is no longer valid (munmap).
+	 *   - range protection changes (mprotect, COW, ...).
+	 *   - range is unmapped (swap, reclaim, page migration, ...).
+	 *   - ...
+	 *
+	 * Any event that block further write to the memory must also trigger a
+	 * device cache flush and everything has to be flush to local memory by
+	 * the time the wait callback return (if this callback returned a fence
+	 * otherwise everything must be flush by the time the callback return).
+	 *
+	 * Device must properly call set_page_dirty on any page the device did
+	 * write to since last call to update.
+	 *
+	 * The driver should return a fence pointer or NULL on success. Device
+	 * driver should return fence and delay wait for the operation to the
+	 * febce wait callback. Returning a fence allow hmm to batch update to
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
+				    struct vm_area_struct *vma,
+				    unsigned long faddr,
+				    unsigned long laddr,
+				    enum hmm_etype etype);
+
+	/* fault() - fault range of address on the device mmu.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 * @faddr:  First address in range (inclusive).
+	 * @laddr:  Last address in range (exclusive).
+	 * @pfns:   Array of pfn for the range (each of the pfn is valid).
+	 * @fault:  The fault structure provided by device driver.
+	 * Returns: 0 on success, error value otherwise.
+	 *
+	 * Called to give the device driver each of the pfn backing a range of
+	 * address. It is only call as a result of a call to hmm_mirror_fault.
+	 *
+	 * Note that the pfns array content is only valid for the duration of
+	 * the callback. Once the device driver callback return further memory
+	 * activities might invalidate the value of the pfns array. The device
+	 * driver will be inform of such changes through the update callback.
+	 *
+	 * Allowed return value are :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * Device driver must not fail lightly, any failure result in device
+	 * process being kill.
+	 *
+	 * Return error if scheduled operation failed. Valid value :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	int (*fault)(struct hmm_mirror *mirror,
+		     unsigned long faddr,
+		     unsigned long laddr,
+		     pte_t *ptep,
+		     struct hmm_event *event);
+};
+
+
+
+
+/* struct hmm_device - per device hmm structure
+ *
+ * @kref:       Reference count.
+ * @mirrors:    List of all active mirrors for the device.
+ * @mutex:      Mutex protecting mirrors list.
+ * @name:       Device name (uniquely identify the device on the system).
+ * @ops:        The hmm operations callback.
+ * @fuid:       First uid assigned to this device (inclusive).
+ * @luid:       Last uid assigned to this device (exclusive).
+ * @rpages:     Array of rpage.
+ * @wait_queue: Wait queue for remote memory operations.
+ *
+ * Each device that want to mirror an address space must register one of this
+ * struct (only once).
+ */
+struct hmm_device {
+	struct kref			kref;
+	struct list_head		mirrors;
+	struct mutex			mutex;
+	const char			*name;
+	const struct hmm_device_ops	*ops;
+	wait_queue_head_t		wait_queue;
+};
+
+/* hmm_device_register() - register a device with hmm.
+ *
+ * @device: The hmm_device struct.
+ * @name:   Unique name string for the device (use in error messages).
+ * Returns: 0 on success, -EINVAL otherwise.
+ *
+ * Call when device driver want to register itself with hmm. Device driver can
+ * only register once. It will return a reference on the device thus to release
+ * a device the driver must unreference the device.
+ */
+int hmm_device_register(struct hmm_device *device,
+			const char *name);
+
+struct hmm_device *hmm_device_ref(struct hmm_device *device);
+struct hmm_device *hmm_device_unref(struct hmm_device *device);
+
+
+
+
+/* hmm_mirror - device specific mirroring functions.
+ *
+ * Each device that mirror a process has a uniq hmm_mirror struct associating
+ * the process address space with the device. A process can be mirrored by
+ * several different devices at the same time.
+ */
+
+/* struct hmm_mirror - per device and per mm hmm structure
+ *
+ * @kref:       Reference count.
+ * @dlist:      List of all hmm_mirror for same device.
+ * @mlist:      List of all hmm_mirror for same mm.
+ * @device:     The hmm_device struct this hmm_mirror is associated to.
+ * @hmm:        The hmm struct this hmm_mirror is associated to.
+ * @dead:       The hmm_mirror is dead and should no longer be use.
+ *
+ * Each device that want to mirror an address space must register one of this
+ * struct for each of the address space it wants to mirror. Same device can
+ * mirror several different address space. As well same address space can be
+ * mirror by different devices.
+ */
+struct hmm_mirror {
+	struct kref		kref;
+	struct list_head	dlist;
+	struct list_head	mlist;
+	struct hmm_device	*device;
+	struct hmm		*hmm;
+	bool			dead;
+};
+
+/* hmm_mirror_register() - register a device mirror against an mm struct
+ *
+ * @mirror: The mirror that link process address space with the device.
+ * @device: The device struct to associate this mirror with.
+ * @mm:     The mm struct of the process.
+ * Returns: 0 success, -ENOMEM, -EBUSY or -EINVAL if process already mirrored.
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
+ *
+ * If the mm or previous hmm is in transient state then this will return -EBUSY
+ * and device driver must retry the call after unpinning the mm and checking
+ * again that the mm is valid.
+ *
+ * On success the mirror is returned with one reference for the caller, thus to
+ * release mirror call hmm_mirror_unref.
+ */
+int hmm_mirror_register(struct hmm_mirror *mirror,
+			struct hmm_device *device,
+			struct mm_struct *mm);
+
+/* hmm_mirror_unregister() - unregister an hmm_mirror.
+ *
+ * @mirror: The mirror that link process address space with the device.
+ *
+ * Call when device driver want to stop mirroring a process address space.
+ */
+void hmm_mirror_unregister(struct hmm_mirror *mirror);
+
+/* hmm_mirror_fault() - call by the device driver on device memory fault.
+ *
+ * @mirror:     Mirror linking process address space with the device.
+ * @event:      Event describing the fault.
+ *
+ * Device driver call this function either if it needs to fill its page table
+ * for a range of address or if it needs to migrate memory between system and
+ * remote memory.
+ *
+ * This function perform vma lookup and access permission check on behalf of
+ * the device. If device ask for range [A; D] but there is only a valid vma
+ * starting at B with B > A then callback will return -EFAULT and update range
+ * to [A; B] so device driver can either report an issue back or recall again
+ * the hmm_mirror_fault with updated range to [B; D].
+ *
+ * This allows device driver to optimistically fault range of address without
+ * having to know about valid vma range. Device driver can then take proper
+ * action if a real memory access happen inside an invalid address range.
+ *
+ * Also the fault will clamp the requested range to valid vma range (unless the
+ * vma into which event->faddr falls to, can grow). So in previous example if D
+ * D is not cover by any vma then hmm_mirror_fault will stop a C with C < D and
+ * C being the last address of a valid vma.
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
+ */
+int hmm_mirror_fault(struct hmm_mirror *mirror,
+		     struct hmm_event *event);
+
+struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror);
+struct hmm_mirror *hmm_mirror_unref(struct hmm_mirror *mirror);
+
+static inline struct page *hmm_pte_to_page(pte_t pte, bool *write)
+{
+	if (pte_none(pte) || !pte_present(pte)) {
+		return NULL;
+	}
+	*write = pte_write(pte);
+	return pfn_to_page(pte_pfn(pte));
+}
+
+#endif /* CONFIG_HMM */
+#endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5ac1cea..d7fc593 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2125,5 +2125,19 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+#ifdef CONFIG_HMM
+void __hmm_destroy(struct mm_struct *mm);
+static inline void hmm_destroy(struct mm_struct *mm)
+{
+	if (mm->hmm) {
+		__hmm_destroy(mm);
+	}
+}
+#else /* !CONFIG_HMM */
+static inline void hmm_destroy(struct mm_struct *mm)
+{
+}
+#endif /* !CONFIG_HMM */
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 96c5750..37eb293 100644
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
@@ -425,6 +429,16 @@ struct mm_struct {
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
index d2799d1..9463eeb 100644
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
@@ -602,6 +603,8 @@ void __mmdrop(struct mm_struct *mm)
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);
+	/* hmm_destroy needs to be call after mmu_notifier_mm_destroy */
+	hmm_destroy(mm);
 	check_mm(mm);
 	free_mm(mm);
 }
@@ -820,6 +823,9 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 
 	memcpy(mm, oldmm, sizeof(*mm));
 	mm_init_cpumask(mm);
+#ifdef CONFIG_HMM
+	mm->hmm = NULL;
+#endif
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
diff --git a/mm/Kconfig b/mm/Kconfig
index 3e9977a..53be52b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -592,3 +592,15 @@ config MAX_STACK_SIZE_MB
 	  changed to a smaller value in which case that is used.
 
 	  A sane initial value is 80 MB.
+
+config HMM
+	bool "Enable heterogeneous memory management (HMM)"
+	depends on MMU
+	select MMU_NOTIFIER
+	default n
+	help
+	  Heterogeneous memory management provide infrastructure for a device
+	  to mirror a process address space into an hardware mmu or into any
+	  things supporting pagefault like event.
+
+	  If unsure, say N to disable hmm.
diff --git a/mm/Makefile b/mm/Makefile
index 1eaa70b..09b9f83 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -62,3 +62,4 @@ obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
 obj-$(CONFIG_ZBUD)	+= zbud.o
 obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
+obj-$(CONFIG_HMM) += hmm.o
diff --git a/mm/hmm.c b/mm/hmm.c
new file mode 100644
index 0000000..62f73d4
--- /dev/null
+++ b/mm/hmm.c
@@ -0,0 +1,1078 @@
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
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/* This is the core code for heterogeneous memory management (HMM). HMM intend
+ * to provide helper for mirroring a process address space on a device as well
+ * as allowing migration of data between local memory and device memory.
+ *
+ * Refer to include/linux/hmm.h for further informations on general design.
+ */
+/* Locking :
+ *
+ *   To synchronize with various mm event there is a simple serialization of
+ *   event touching overlapping range of address. Each mm event is associated
+ *   with an hmm_event structure which store the address range of the event.
+ *
+ *   When a new mm event call in hmm (most call comes through the mmu_notifier
+ *   call backs) hmm allocate an hmm_event structure and wait for all pending
+ *   event that overlap with the new event.
+ *
+ *   To avoid deadlock with mmap_sem the rules it to always allocate new hmm
+ *   event after taking the mmap_sem lock. In case of mmu_notifier call we do
+ *   not take the mmap_sem lock as if it was needed it would have been taken
+ *   by the caller of the mmu_notifier API.
+ *
+ *   Hence hmm only need to make sure to allocate new hmm event after taking
+ *   the mmap_sem.
+ */
+#include <linux/export.h>
+#include <linux/bitmap.h>
+#include <linux/srcu.h>
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
+#include <asm/tlb.h>
+#include <asm/tlbflush.h>
+#include <linux/delay.h>
+
+#include "internal.h"
+
+#define HMM_MAX_EVENTS		16
+
+/* global SRCU for all MMs */
+static struct srcu_struct srcu;
+
+
+
+
+/* struct hmm - per mm_struct hmm structure
+ *
+ * @mm:             The mm struct.
+ * @kref:           Reference counter
+ * @lock:           Serialize the mirror list modifications.
+ * @pending:        List of pending event (hmm_event).
+ * @mirrors:        List of all mirror for this mm (one per device).
+ * @mmu_notifier:   The mmu_notifier of this mm.
+ * @wait_queue:     Wait queue for event synchronization.
+ * @events:         Preallocated array of hmm_event for mmu_notifier.
+ * @nevents:        Number of preallocated event currently in use.
+ * @dead:           The mm is being destroy.
+ *
+ * For each process address space (mm_struct) there is one and only one hmm
+ * struct. hmm functions will redispatch to each devices the change into the
+ * process address space.
+ */
+struct hmm {
+	struct mm_struct 	*mm;
+	struct kref		kref;
+	spinlock_t		lock;
+	struct list_head	pending;
+	struct list_head	mirrors;
+	struct mmu_notifier	mmu_notifier;
+	wait_queue_head_t	wait_queue;
+	struct hmm_event	events[HMM_MAX_EVENTS];
+	int			nevents;
+	bool			dead;
+};
+
+static struct mmu_notifier_ops hmm_notifier_ops;
+
+static inline struct hmm *hmm_ref(struct hmm *hmm);
+static inline struct hmm *hmm_unref(struct hmm *hmm);
+
+static void hmm_mirror_cleanup(struct hmm_mirror *mirror);
+
+static int hmm_device_fence_wait(struct hmm_device *device,
+				 struct hmm_fence *fence);
+
+
+
+
+/* hmm_event - use to synchronize various mm events with each others.
+ *
+ * During life time of process various mm events will happen, hmm serialize
+ * event that affect overlapping range of address. The hmm_event are use for
+ * that purpose.
+ */
+
+static inline bool hmm_event_overlap(struct hmm_event *a, struct hmm_event *b)
+{
+	return !((a->laddr <= b->faddr) || (a->faddr >= b->laddr));
+}
+
+static inline unsigned long hmm_event_size(struct hmm_event *event)
+{
+	return (event->laddr - event->faddr);
+}
+
+struct hmm_fence *hmm_fence_ref(struct hmm_fence *fence)
+{
+	if (fence) {
+		kref_get(&fence->kref);
+		return fence;
+	}
+	return NULL;
+}
+
+static void hmm_fence_destroy(struct kref *kref)
+{
+	struct hmm_device *device;
+	struct hmm_fence *fence;
+
+	fence = container_of(kref, struct hmm_fence, kref);
+	device = fence->mirror->device;
+	device->ops->fence_destroy(fence);
+}
+
+struct hmm_fence *hmm_fence_unref(struct hmm_fence *fence)
+{
+	if (fence) {
+		kref_put(&fence->kref, hmm_fence_destroy);
+	}
+	return NULL;
+}
+
+
+
+
+/* hmm - core hmm functions.
+ *
+ * Core hmm functions that deal with all the process mm activities and use
+ * event for synchronization. Those function are use mostly as result of cpu
+ * mm event.
+ */
+
+static int hmm_init(struct hmm *hmm, struct mm_struct *mm)
+{
+	int i, ret;
+
+	hmm->mm = mm;
+	kref_init(&hmm->kref);
+	INIT_LIST_HEAD(&hmm->mirrors);
+	INIT_LIST_HEAD(&hmm->pending);
+	spin_lock_init(&hmm->lock);
+	init_waitqueue_head(&hmm->wait_queue);
+
+	for (i = 0; i < HMM_MAX_EVENTS; ++i) {
+		hmm->events[i].etype = HMM_NONE;
+		INIT_LIST_HEAD(&hmm->events[i].fences);
+	}
+
+	/* register notifier */
+	hmm->mmu_notifier.ops = &hmm_notifier_ops;
+	ret = __mmu_notifier_register(&hmm->mmu_notifier, mm);
+	return ret;
+}
+
+static enum hmm_etype hmm_event_mmu(enum mmu_action action)
+{
+	switch (action) {
+	case MMU_MPROT_RONLY:
+		return HMM_MPROT_RONLY;
+	case MMU_COW:
+		return HMM_COW;
+	case MMU_MPROT_WONLY:
+	case MMU_MPROT_NONE:
+	case MMU_KSM:
+	case MMU_KSM_RONLY:
+	case MMU_UNMAP:
+	case MMU_VMSCAN:
+	case MMU_MIGRATE:
+	case MMU_FILE_WB:
+	case MMU_FAULT_WP:
+	case MMU_THP_SPLIT:
+	case MMU_THP_FAULT_WP:
+		return HMM_MPROT_NONE;
+	case MMU_POISON:
+	case MMU_MREMAP:
+	case MMU_MUNMAP:
+		return HMM_MUNMAP;
+	case MMU_SOFT_DIRTY:
+	case MMU_MUNLOCK:
+	default:
+		return HMM_NONE;
+	}
+}
+
+static void hmm_event_unqueue_and_release_locked(struct hmm *hmm,
+						 struct hmm_event *event)
+{
+	list_del_init(&event->list);
+	event->etype = HMM_NONE;
+	hmm->nevents--;
+}
+
+static void hmm_event_unqueue_and_release(struct hmm *hmm,
+					  struct hmm_event *event)
+{
+	spin_lock(&hmm->lock);
+	list_del_init(&event->list);
+	event->etype = HMM_NONE;
+	hmm->nevents--;
+	spin_unlock(&hmm->lock);
+}
+
+static void hmm_event_unqueue(struct hmm *hmm,
+			      struct hmm_event *event)
+{
+	spin_lock(&hmm->lock);
+	list_del_init(&event->list);
+	spin_unlock(&hmm->lock);
+}
+
+static void hmm_event_wait_queue(struct hmm *hmm,
+				 struct hmm_event *event)
+{
+	struct hmm_event *wait;
+
+again:
+	wait = event;
+	list_for_each_entry_continue_reverse (wait, &hmm->pending, list) {
+		enum hmm_etype wait_type;
+
+		if (!hmm_event_overlap(event, wait)) {
+			continue;
+		}
+		wait_type = wait->etype;
+		spin_unlock(&hmm->lock);
+		wait_event(hmm->wait_queue, wait->etype != wait_type);
+		spin_lock(&hmm->lock);
+		goto again;
+	}
+}
+
+static void hmm_event_queue(struct hmm *hmm, struct hmm_event *event)
+{
+	spin_lock(&hmm->lock);
+	list_add_tail(&event->list, &hmm->pending);
+	hmm_event_wait_queue(hmm, event);
+	spin_unlock(&hmm->lock);
+}
+
+static void hmm_destroy_kref(struct kref *kref)
+{
+	struct hmm *hmm;
+	struct mm_struct *mm;
+
+	hmm = container_of(kref, struct hmm, kref);
+	mm = hmm->mm;
+	mm->hmm = NULL;
+	mmu_notifier_unregister(&hmm->mmu_notifier, mm);
+
+	if (!list_empty(&hmm->mirrors)) {
+		BUG();
+		printk(KERN_ERR "destroying an hmm with still active mirror\n"
+		       "Leaking memory instead to avoid something worst.\n");
+		return;
+	}
+	kfree(hmm);
+}
+
+static inline struct hmm *hmm_ref(struct hmm *hmm)
+{
+	if (hmm) {
+		kref_get(&hmm->kref);
+		return hmm;
+	}
+	return NULL;
+}
+
+static inline struct hmm *hmm_unref(struct hmm *hmm)
+{
+	if (hmm) {
+		kref_put(&hmm->kref, hmm_destroy_kref);
+	}
+	return NULL;
+}
+
+static struct hmm_event *hmm_event_get(struct hmm *hmm,
+				       unsigned long faddr,
+				       unsigned long laddr,
+				       enum hmm_etype etype)
+{
+	struct hmm_event *event;
+	unsigned id;
+
+	do {
+		spin_lock(&hmm->lock);
+		for (id = 0; id < HMM_MAX_EVENTS; ++id) {
+			if (hmm->events[id].etype == HMM_NONE) {
+				event = &hmm->events[id];
+				goto out;
+			}
+		}
+		spin_unlock(&hmm->lock);
+		wait_event(hmm->wait_queue, hmm->nevents < HMM_MAX_EVENTS);
+	} while (1);
+
+out:
+	event->etype = etype;
+	event->faddr = faddr;
+	event->laddr = laddr;
+	event->backoff = false;
+	INIT_LIST_HEAD(&event->fences);
+	hmm->nevents++;
+	list_add_tail(&event->list, &hmm->pending);
+	hmm_event_wait_queue(hmm, event);
+	spin_unlock(&hmm->lock);
+
+	return event;
+}
+
+static void hmm_update_mirrors(struct hmm *hmm,
+			       struct vm_area_struct *vma,
+			       struct hmm_event *event)
+{
+	struct hmm_mirror *mirror;
+	struct hmm_fence *fence = NULL, *tmp;
+	int ticket;
+
+retry:
+	ticket = srcu_read_lock(&srcu);
+	/* Because of retry we might already have scheduled some mirror
+	 * skip those.
+	 */
+	mirror = list_first_entry(&hmm->mirrors,
+				  struct hmm_mirror,
+				  mlist);
+	mirror = fence ? fence->mirror : mirror;
+	list_for_each_entry_continue (mirror, &hmm->mirrors, mlist) {
+		struct hmm_device *device = mirror->device;
+
+		fence = device->ops->update(mirror, vma, event->faddr,
+					    event->laddr, event->etype);
+		if (fence) {
+			if (IS_ERR(fence)) {
+				srcu_read_unlock(&srcu, ticket);
+				hmm_mirror_cleanup(mirror);
+				goto retry;
+			}
+			kref_init(&fence->kref);
+			fence->mirror = mirror;
+			list_add_tail(&fence->list, &event->fences);
+		}
+	}
+	srcu_read_unlock(&srcu, ticket);
+
+	if (!fence) {
+		/* Nothing to wait for. */
+		return;
+	}
+
+	io_schedule();
+	list_for_each_entry_safe (fence, tmp, &event->fences, list) {
+		struct hmm_device *device;
+		int r;
+
+		mirror = fence->mirror;
+		device = mirror->device;
+
+		r = hmm_device_fence_wait(device, fence);
+		if (r) {
+			hmm_mirror_cleanup(mirror);
+		}
+	}
+}
+
+
+
+
+/* hmm_notifier - mmu_notifier hmm funcs tracking change to process mm.
+ *
+ * Callbacks for mmu notifier. We use use mmu notifier to track change made to
+ * process address space.
+ *
+ * Note that none of this callback needs to take a reference, as we sure that
+ * mm won't be destroy thus hmm won't be destroy either and it's fine if some
+ * hmm_mirror/hmm_device are destroy during those callbacks because this is
+ * serialize through either the hmm lock or the device lock.
+ */
+
+static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	struct hmm *hmm;
+
+	if (!(hmm = hmm_ref(mm->hmm)) || hmm->dead) {
+		/* Already clean. */
+		hmm_unref(hmm);
+		return;
+	}
+
+	hmm->dead = true;
+
+	/*
+	 * hmm->lock allow synchronization with hmm_mirror_unregister() an
+	 * hmm_mirror can be removed only once.
+	 */
+	spin_lock(&hmm->lock);
+	while (unlikely(!list_empty(&hmm->mirrors))) {
+		struct hmm_mirror *mirror;
+		struct hmm_device *device;
+
+		mirror = list_first_entry(&hmm->mirrors,
+					  struct hmm_mirror,
+					  mlist);
+		device = mirror->device;
+		if (!mirror->dead) {
+			/* Update mirror as being dead and remove it from the
+			 * mirror list before freeing up any of its resources.
+			 */
+			mirror->dead = true;
+			list_del_init(&mirror->mlist);
+			spin_unlock(&hmm->lock);
+
+			synchronize_srcu(&srcu);
+
+			device->ops->mirror_release(mirror);
+			hmm_mirror_cleanup(mirror);
+			spin_lock(&hmm->lock);
+		}
+	}
+	spin_unlock(&hmm->lock);
+	hmm_unref(hmm);
+}
+
+static void hmm_notifier_invalidate_range_start(struct mmu_notifier *mn,
+						struct mm_struct *mm,
+						struct vm_area_struct *vma,
+						unsigned long faddr,
+						unsigned long laddr,
+						enum mmu_action action)
+{
+	struct hmm_event *event;
+	enum hmm_etype etype;
+	struct hmm *hmm;
+
+	if (!(hmm = hmm_ref(mm->hmm))) {
+		return;
+	}
+
+	etype = hmm_event_mmu(action);
+	switch (etype) {
+	case HMM_NONE:
+		hmm_unref(hmm);
+		return;
+	default:
+		break;
+	}
+
+	faddr = faddr & PAGE_MASK;
+	laddr = PAGE_ALIGN(laddr);
+
+	event = hmm_event_get(hmm, faddr, laddr, etype);
+	hmm_update_mirrors(hmm, vma, event);
+	/* Do not drop hmm reference here but in the range_end instead. */
+}
+
+static void hmm_notifier_invalidate_range_end(struct mmu_notifier *mn,
+					      struct mm_struct *mm,
+					      struct vm_area_struct *vma,
+					      unsigned long faddr,
+					      unsigned long laddr,
+					      enum mmu_action action)
+{
+	struct hmm_event *event = NULL;
+	enum hmm_etype etype;
+	struct hmm *hmm;
+	int i;
+
+	if (!(hmm = mm->hmm)) {
+		return;
+	}
+
+	etype = hmm_event_mmu(action);
+	switch (etype) {
+	case HMM_NONE:
+		return;
+	default:
+		break;
+	}
+
+	faddr = faddr & PAGE_MASK;
+	laddr = PAGE_ALIGN(laddr);
+
+	spin_lock(&hmm->lock);
+	for (i = 0; i < HMM_MAX_EVENTS; ++i, event = NULL) {
+		event = &hmm->events[i];
+		if (event->etype == etype &&
+		    event->faddr == faddr &&
+		    event->laddr == laddr &&
+		    !list_empty(&event->list)) {
+			hmm_event_unqueue_and_release_locked(hmm, event);
+			break;
+		}
+	}
+	spin_unlock(&hmm->lock);
+
+	/* Drop reference from invalidate_range_start. */
+	hmm_unref(hmm);
+}
+
+static void hmm_notifier_invalidate_page(struct mmu_notifier *mn,
+					 struct mm_struct *mm,
+					 struct vm_area_struct *vma,
+					 unsigned long faddr,
+					 enum mmu_action action)
+{
+	unsigned long laddr;
+	struct hmm_event *event;
+	enum hmm_etype etype;
+	struct hmm *hmm;
+
+	if (!(hmm = hmm_ref(mm->hmm))) {
+		return;
+	}
+
+	etype = hmm_event_mmu(action);
+	switch (etype) {
+	case HMM_NONE:
+		return;
+	default:
+		break;
+	}
+
+	faddr = faddr & PAGE_MASK;
+	laddr = faddr + PAGE_SIZE;
+
+	event = hmm_event_get(hmm, faddr, laddr, etype);
+	hmm_update_mirrors(hmm, vma, event);
+	hmm_event_unqueue_and_release(hmm, event);
+	hmm_unref(hmm);
+}
+
+static struct mmu_notifier_ops hmm_notifier_ops = {
+	.release		= hmm_notifier_release,
+	/* .clear_flush_young FIXME we probably want to do something. */
+	/* .test_young FIXME we probably want to do something. */
+	/* WARNING .change_pte must always bracketed by range_start/end there
+	 * was patches to remove that behavior we must make sure that those
+	 * patches are not included as alternative solution to issue they are
+	 * trying to solve can be use.
+	 *
+	 * While hmm can not use the change_pte callback as non sleeping lock
+	 * are held during change_pte callback.
+	 */
+	.change_pte		= NULL,
+	.invalidate_page	= hmm_notifier_invalidate_page,
+	.invalidate_range_start	= hmm_notifier_invalidate_range_start,
+	.invalidate_range_end	= hmm_notifier_invalidate_range_end,
+};
+
+
+
+
+/* hmm_mirror - per device mirroring functions.
+ *
+ * Each device that mirror a process has a uniq hmm_mirror struct. A process
+ * can be mirror by several devices at the same time.
+ *
+ * Below are all the functions and there helpers use by device driver to mirror
+ * the process address space. Those functions either deals with updating the
+ * device page table (through hmm callback). Or provide helper functions use by
+ * the device driver to fault in range of memory in the device page table.
+ */
+
+static void hmm_mirror_cleanup(struct hmm_mirror *mirror)
+{
+	struct vm_area_struct *vma;
+	struct hmm_device *device = mirror->device;
+	struct hmm_event event;
+	struct hmm *hmm = mirror->hmm;
+
+	spin_lock(&hmm->lock);
+	if (mirror->dead) {
+		spin_unlock(&hmm->lock);
+		return;
+	}
+	mirror->dead = true;
+	list_del(&mirror->mlist);
+	spin_unlock(&hmm->lock);
+	synchronize_srcu(&srcu);
+	INIT_LIST_HEAD(&mirror->mlist);
+
+	event.etype = HMM_UNREGISTER;
+	event.faddr = 0UL;
+	event.laddr = -1L;
+	vma = find_vma_intersection(hmm->mm, event.faddr, event.laddr);
+	for (; vma; vma = vma->vm_next) {
+		struct hmm_fence *fence;
+
+		fence = device->ops->update(mirror, vma, vma->vm_start,
+					    vma->vm_end, event.etype);
+		if (fence && !IS_ERR(fence)) {
+			kref_init(&fence->kref);
+			fence->mirror = mirror;
+			INIT_LIST_HEAD(&fence->list);
+			hmm_device_fence_wait(device, fence);
+		}
+	}
+
+	mutex_lock(&device->mutex);
+	list_del_init(&mirror->dlist);
+	mutex_unlock(&device->mutex);
+
+	mirror->hmm = hmm_unref(hmm);
+	hmm_mirror_unref(mirror);
+}
+
+static void hmm_mirror_destroy(struct kref *kref)
+{
+	struct hmm_mirror *mirror;
+	struct hmm_device *device;
+
+	mirror = container_of(kref, struct hmm_mirror, kref);
+	device = mirror->device;
+
+	BUG_ON(!list_empty(&mirror->mlist));
+	BUG_ON(!list_empty(&mirror->dlist));
+
+	device->ops->mirror_destroy(mirror);
+	hmm_device_unref(device);
+}
+
+struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror)
+{
+	if (mirror) {
+		kref_get(&mirror->kref);
+		return mirror;
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(hmm_mirror_ref);
+
+struct hmm_mirror *hmm_mirror_unref(struct hmm_mirror *mirror)
+{
+	if (mirror) {
+		kref_put(&mirror->kref, hmm_mirror_destroy);
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(hmm_mirror_unref);
+
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
+	/* Take reference on device only on success. */
+	kref_init(&mirror->kref);
+	mirror->device = device;
+	mirror->dead = false;
+	INIT_LIST_HEAD(&mirror->mlist);
+	INIT_LIST_HEAD(&mirror->dlist);
+
+	down_write(&mm->mmap_sem);
+	if (mm->hmm == NULL) {
+		/* no hmm registered yet so register one */
+		hmm = kzalloc(sizeof(*mm->hmm), GFP_KERNEL);
+		if (hmm == NULL) {
+			ret = -ENOMEM;
+			goto out_cleanup;
+		}
+
+		ret = hmm_init(hmm, mm);
+		if (ret) {
+			kfree(hmm);
+			hmm = NULL;
+			goto out_cleanup;
+		}
+
+		/* now set hmm, make sure no mmu notifer callback might be call */
+		ret = mm_take_all_locks(mm);
+		if (unlikely(ret)) {
+			goto out_cleanup;
+		}
+		mm->hmm = hmm;
+		mirror->hmm = hmm;
+		hmm = NULL;
+	} else {
+		struct hmm_mirror *tmp;
+		int id;
+
+		id = srcu_read_lock(&srcu);
+		list_for_each_entry(tmp, &mm->hmm->mirrors, mlist) {
+			if (tmp->device == mirror->device) {
+				/* A process can be mirrored only once by same
+				 * device.
+				 */
+				srcu_read_unlock(&srcu, id);
+				ret = -EINVAL;
+				goto out_cleanup;
+			}
+		}
+		srcu_read_unlock(&srcu, id);
+
+		ret = mm_take_all_locks(mm);
+		if (unlikely(ret)) {
+			goto out_cleanup;
+		}
+		mirror->hmm = hmm_ref(mm->hmm);
+	}
+
+	/*
+	 * A side note: hmm_notifier_release() can't run concurrently with
+	 * us because we hold the mm_users pin (either implicitly as
+	 * current->mm or explicitly with get_task_mm() or similar).
+	 *
+	 * We can't race against any other mmu notifier method either
+	 * thanks to mm_take_all_locks().
+	 */
+	spin_lock(&mm->hmm->lock);
+	list_add_rcu(&mirror->mlist, &mm->hmm->mirrors);
+	spin_unlock(&mm->hmm->lock);
+	mm_drop_all_locks(mm);
+
+out_cleanup:
+	if (hmm) {
+		mmu_notifier_unregister(&hmm->mmu_notifier, mm);
+		kfree(hmm);
+	}
+	up_write(&mm->mmap_sem);
+
+	if (!ret) {
+		struct hmm_device *device = mirror->device;
+
+		hmm_device_ref(device);
+		mutex_lock(&device->mutex);
+		list_add(&mirror->dlist, &device->mirrors);
+		mutex_unlock(&device->mutex);
+	}
+	return ret;
+}
+EXPORT_SYMBOL(hmm_mirror_register);
+
+void hmm_mirror_unregister(struct hmm_mirror *mirror)
+{
+	struct hmm *hmm;
+
+	if (!mirror) {
+		return;
+	}
+	hmm = hmm_ref(mirror->hmm);
+	if (!hmm) {
+		return;
+	}
+
+	down_read(&hmm->mm->mmap_sem);
+	hmm_mirror_cleanup(mirror);
+	up_read(&hmm->mm->mmap_sem);
+	hmm_unref(hmm);
+}
+EXPORT_SYMBOL(hmm_mirror_unregister);
+
+struct hmm_mirror_fault {
+	struct hmm_mirror	*mirror;
+	struct hmm_event	*event;
+	struct vm_area_struct	*vma;
+	struct mmu_gather	tlb;
+	int			flush;
+};
+
+static int hmm_mirror_fault_pmd(pmd_t *pmdp,
+				unsigned long faddr,
+				unsigned long laddr,
+				struct mm_walk *walk)
+{
+	struct hmm_mirror_fault *mirror_fault = walk->private;
+	struct hmm_mirror *mirror = mirror_fault->mirror;
+	struct hmm_device *device = mirror->device;
+	struct hmm_event *event = mirror_fault->event;
+	pte_t *ptep;
+	int ret;
+
+	event->iaddr = faddr;
+
+	if (pmd_none(*pmdp)) {
+		return -ENOENT;
+	}
+
+	if (pmd_trans_huge(*pmdp)) {
+		/* FIXME */
+		return -EINVAL;
+	}
+
+	if (pmd_none_or_trans_huge_or_clear_bad(pmdp)) {
+		return -EFAULT;
+	}
+
+	ptep = pte_offset_map(pmdp, faddr);
+	ret = device->ops->fault(mirror, faddr, laddr, ptep, event);
+	pte_unmap(ptep);
+	return ret;
+}
+
+static int hmm_fault_mm(struct hmm *hmm,
+			struct vm_area_struct *vma,
+			unsigned long faddr,
+			unsigned long laddr,
+			bool write)
+{
+	int r;
+
+	if (laddr <= faddr) {
+		return -EINVAL;
+	}
+
+	for (; faddr < laddr; faddr += PAGE_SIZE) {
+		unsigned flags = 0;
+
+		flags |= write ? FAULT_FLAG_WRITE : 0;
+		flags |= FAULT_FLAG_ALLOW_RETRY;
+		do {
+			r = handle_mm_fault(hmm->mm, vma, faddr, flags);
+			if (!(r & VM_FAULT_RETRY) && (r & VM_FAULT_ERROR)) {
+				if (r & VM_FAULT_OOM) {
+					return -ENOMEM;
+				}
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
+/* see include/linux/hmm.h */
+int hmm_mirror_fault(struct hmm_mirror *mirror,
+		     struct hmm_event *event)
+{
+	struct vm_area_struct *vma;
+	struct hmm_mirror_fault mirror_fault;
+	struct hmm_device *device;
+	struct mm_walk walk = {0};
+	unsigned long npages;
+	struct hmm *hmm;
+	int ret = 0;
+
+	if (!mirror || !event || event->faddr >= event->laddr) {
+		return -EINVAL;
+	}
+	if (mirror->dead) {
+		return -ENODEV;
+	}
+	device = mirror->device;
+	hmm = mirror->hmm;
+
+	event->faddr = event->faddr & PAGE_MASK;
+	event->laddr = PAGE_ALIGN(event->laddr);
+	event->iaddr = event->faddr;
+	npages = (event->laddr - event->faddr) >> PAGE_SHIFT;
+
+retry:
+	down_read(&hmm->mm->mmap_sem);
+	hmm_event_queue(hmm, event);
+
+	vma = find_extend_vma(hmm->mm, event->faddr);
+	if (!vma) {
+		if (event->iaddr > event->faddr) {
+			/* Fault succeed up to iaddr. */
+			event->laddr = event->iaddr;
+			goto out;
+		}
+		/* Allow device driver to learn about first valid address in
+		 * the range it was trying to fault in so it can restart the
+		 * fault at this address.
+		 */
+		vma = find_vma_intersection(hmm->mm,event->faddr,event->laddr);
+		if (vma) {
+			event->laddr = vma->vm_start;
+		}
+		ret = -EFAULT;
+		goto out;
+	}
+
+	if ((vma->vm_flags & (VM_IO | VM_PFNMAP | VM_MIXEDMAP | VM_HUGETLB))) {
+		event->laddr = min(event->laddr, vma->vm_end);
+		ret = -EFAULT;
+		goto out;
+	}
+
+	event->laddr = min(event->laddr, vma->vm_end);
+	mirror_fault.vma = vma;
+	mirror_fault.flush = 0;
+	mirror_fault.event = event;
+	mirror_fault.mirror = mirror;
+	walk.mm = hmm->mm;
+	walk.private = &mirror_fault;
+
+	switch (event->etype) {
+	case HMM_RFAULT:
+	case HMM_WFAULT:
+		walk.pmd_entry = hmm_mirror_fault_pmd;
+		ret = walk_page_range(event->faddr, event->laddr, &walk);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+out:
+	hmm_event_unqueue(hmm, event);
+	if (!event->backoff && (ret == -ENOENT || ret == -EACCES)) {
+		bool write = (event->etype == HMM_WFAULT);
+
+		ret = hmm_fault_mm(hmm, vma, event->iaddr, event->laddr, write);
+		if (!ret) {
+			ret = -EAGAIN;
+		}
+	}
+	up_read(&hmm->mm->mmap_sem);
+	wake_up(&device->wait_queue);
+	wake_up(&hmm->wait_queue);
+	if (mirror->dead || hmm->dead) {
+		return -ENODEV;
+	}
+	if (event->backoff || ret == -EAGAIN) {
+		event->backoff = false;
+		goto retry;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(hmm_mirror_fault);
+
+
+
+
+/* hmm_device - Each device driver must register one and only one hmm_device
+ *
+ * The hmm_device is the link btw hmm and each device driver.
+ */
+
+static void hmm_device_destroy(struct kref *kref)
+{
+	struct hmm_device *device;
+
+	device = container_of(kref, struct hmm_device, kref);
+	BUG_ON(!list_empty(&device->mirrors));
+
+	device->ops->device_destroy(device);
+}
+
+struct hmm_device *hmm_device_ref(struct hmm_device *device)
+{
+	if (device) {
+		kref_get(&device->kref);
+		return device;
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(hmm_device_ref);
+
+struct hmm_device *hmm_device_unref(struct hmm_device *device)
+{
+	if (device) {
+		kref_put(&device->kref, hmm_device_destroy);
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(hmm_device_unref);
+
+/* see include/linux/hmm.h */
+int hmm_device_register(struct hmm_device *device,
+			const char *name)
+{
+	/* sanity check */
+	BUG_ON(!device);
+	BUG_ON(!device->ops);
+	BUG_ON(!device->ops->device_destroy);
+	BUG_ON(!device->ops->mirror_release);
+	BUG_ON(!device->ops->mirror_destroy);
+	BUG_ON(!device->ops->fence_wait);
+	BUG_ON(!device->ops->fence_destroy);
+	BUG_ON(!device->ops->update);
+	BUG_ON(!device->ops->fault);
+
+	kref_init(&device->kref);
+	device->name = name;
+	mutex_init(&device->mutex);
+	INIT_LIST_HEAD(&device->mirrors);
+	init_waitqueue_head(&device->wait_queue);
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_device_register);
+
+static int hmm_device_fence_wait(struct hmm_device *device,
+				 struct hmm_fence *fence)
+{
+	int ret;
+
+	if (fence == NULL) {
+		return 0;
+	}
+
+	list_del_init(&fence->list);
+	do {
+		io_schedule();
+		ret = device->ops->fence_wait(fence);
+	} while (ret == -EAGAIN);
+
+	hmm_fence_unref(fence);
+
+	return ret;
+}
+
+
+
+
+/* This is called after the last hmm_notifier_release() returned */
+void __hmm_destroy(struct mm_struct *mm)
+{
+	kref_put(&mm->hmm->kref, hmm_destroy_kref);
+}
+
+static int __init hmm_module_init(void)
+{
+	int ret;
+
+	ret = init_srcu_struct(&srcu);
+	if (ret) {
+		return ret;
+	}
+	return 0;
+}
+module_init(hmm_module_init);
+
+static void __exit hmm_module_exit(void)
+{
+	cleanup_srcu_struct(&srcu);
+}
+module_exit(hmm_module_exit);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
