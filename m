Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id B50B528034A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 14:53:34 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so43891523igb.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:53:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h22si9952430ioi.41.2015.07.17.11.53.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 11:53:33 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 05/15] HMM: introduce heterogeneous memory management v4.
Date: Fri, 17 Jul 2015 14:52:15 -0400
Message-Id: <1437159145-6548-6-git-send-email-jglisse@redhat.com>
In-Reply-To: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

This patch only introduce core HMM functions for registering a new
mirror and stopping a mirror as well as HMM device registering and
unregistering.

The lifecycle of HMM object is handled differently then the one of
mmu_notifier because unlike mmu_notifier there can be concurrent
call from both mm code to HMM code and/or from device driver code
to HMM code. Moreover lifetime of HMM can be uncorrelated from the
lifetime of the process that is being mirror (GPU might take longer
time to cleanup).

Changed since v1:
  - Updated comment of hmm_device_register().

Changed since v2:
  - Expose struct hmm for easy access to mm struct.
  - Simplify hmm_mirror_register() arguments.
  - Removed the device name.
  - Refcount the mirror struct internaly to HMM allowing to get
    rid of the srcu and making the device driver callback error
    handling simpler.
  - Safe to call several time hmm_mirror_unregister().
  - Rework the mmu_notifier unregistration and release callback.

Changed since v3:
  - Rework hmm_mirror lifetime rules.
  - Synchronize with mmu_notifier srcu before droping mirror last
    reference in hmm_mirror_unregister()
  - Use spinlock for device's mirror list.
  - Export mirror ref/unref functions.
  - English syntax fixes.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 MAINTAINERS              |   7 +
 include/linux/hmm.h      | 173 +++++++++++++++++++++
 include/linux/mm.h       |  11 ++
 include/linux/mm_types.h |  14 ++
 kernel/fork.c            |   2 +
 mm/Kconfig               |  14 ++
 mm/Makefile              |   1 +
 mm/hmm.c                 | 381 +++++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 603 insertions(+)
 create mode 100644 include/linux/hmm.h
 create mode 100644 mm/hmm.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 2d3d55c..8ebdc17 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4870,6 +4870,13 @@ F:	include/uapi/linux/if_hippi.h
 F:	net/802/hippi.c
 F:	drivers/net/hippi/
 
+HMM - Heterogeneous Memory Management
+M:	JA(C)rA'me Glisse <jglisse@redhat.com>
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	mm/hmm.c
+F:	include/linux/hmm.h
+
 HOST AP DRIVER
 M:	Jouni Malinen <j@w1.fi>
 L:	hostap@shmoo.com (subscribers-only)
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
new file mode 100644
index 0000000..b559c0b
--- /dev/null
+++ b/include/linux/hmm.h
@@ -0,0 +1,173 @@
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
+#include <linux/spinlock.h>
+#include <linux/atomic.h>
+#include <linux/mm_types.h>
+#include <linux/mmu_notifier.h>
+#include <linux/workqueue.h>
+#include <linux/mman.h>
+
+
+struct hmm_device;
+struct hmm_mirror;
+struct hmm;
+
+
+/* hmm_device - Each device must register one and only one hmm_device.
+ *
+ * The hmm_device is the link btw HMM and each device driver.
+ */
+
+/* struct hmm_device_operations - HMM device operation callback
+ */
+struct hmm_device_ops {
+	/* release() - mirror must stop using the address space.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 *
+	 * When this is called, device driver must kill all device thread using
+	 * this mirror. It is call either from :
+	 *   - mm dying (all process using this mm exiting).
+	 *   - hmm_mirror_unregister() (if no other thread holds a reference)
+	 *   - outcome of some device error reported by any of the device
+	 *     callback against that mirror.
+	 */
+	void (*release)(struct hmm_mirror *mirror);
+
+	/* free() - mirror can be freed.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 *
+	 * When this is called, device driver can free the underlying memory
+	 * associated with that mirror. Note this is call from atomic context
+	 * so device driver callback can not sleep.
+	 */
+	void (*free)(struct hmm_mirror *mirror);
+};
+
+
+/* struct hmm - per mm_struct HMM states.
+ *
+ * @mm: The mm struct this hmm is associated with.
+ * @mirrors: List of all mirror for this mm (one per device).
+ * @vm_end: Last valid address for this mm (exclusive).
+ * @kref: Reference counter.
+ * @rwsem: Serialize the mirror list modifications.
+ * @mmu_notifier: The mmu_notifier of this mm.
+ * @rcu: For delayed cleanup call from mmu_notifier.release() callback.
+ *
+ * For each process address space (mm_struct) there is one and only one hmm
+ * struct. hmm functions will redispatch to each devices the change made to
+ * the process address space.
+ *
+ * Device driver must not access this structure other than for getting the
+ * mm pointer.
+ */
+struct hmm {
+	struct mm_struct	*mm;
+	struct hlist_head	mirrors;
+	unsigned long		vm_end;
+	struct kref		kref;
+	struct rw_semaphore	rwsem;
+	struct mmu_notifier	mmu_notifier;
+	struct rcu_head		rcu;
+};
+
+
+/* struct hmm_device - per device HMM structure
+ *
+ * @dev: Linux device structure pointer.
+ * @ops: The hmm operations callback.
+ * @mirrors: List of all active mirrors for the device.
+ * @lock: Lock protecting mirrors list.
+ *
+ * Each device that want to mirror an address space must register one of this
+ * struct (only once per linux device).
+ */
+struct hmm_device {
+	struct device			*dev;
+	const struct hmm_device_ops	*ops;
+	struct list_head		mirrors;
+	spinlock_t			lock;
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
+/* struct hmm_mirror - per device and per mm HMM structure
+ *
+ * @device: The hmm_device struct this hmm_mirror is associated to.
+ * @hmm: The hmm struct this hmm_mirror is associated to.
+ * @kref: Reference counter (private to HMM do not use).
+ * @dlist: List of all hmm_mirror for same device.
+ * @mlist: List of all hmm_mirror for same process.
+ *
+ * Each device that want to mirror an address space must register one of this
+ * struct for each of the address space it wants to mirror. Same device can
+ * mirror several different address space. As well same address space can be
+ * mirror by different devices.
+ */
+struct hmm_mirror {
+	struct hmm_device	*device;
+	struct hmm		*hmm;
+	struct kref		kref;
+	struct list_head	dlist;
+	struct hlist_node	mlist;
+};
+
+int hmm_mirror_register(struct hmm_mirror *mirror);
+void hmm_mirror_unregister(struct hmm_mirror *mirror);
+struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror);
+void hmm_mirror_unref(struct hmm_mirror **mirror);
+
+
+#endif /* CONFIG_HMM */
+#endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2e872f9..b5bf210 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2243,5 +2243,16 @@ void __init setup_nr_node_ids(void);
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
index 0038ac7..fa05917 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -15,6 +15,10 @@
 #include <asm/page.h>
 #include <asm/mmu.h>
 
+#ifdef CONFIG_HMM
+struct hmm;
+#endif
+
 #ifndef AT_VECTOR_SIZE_ARCH
 #define AT_VECTOR_SIZE_ARCH 0
 #endif
@@ -451,6 +455,16 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+#ifdef CONFIG_HMM
+	/*
+	 * hmm always register an mmu_notifier we rely on mmu notifier to keep
+	 * refcount on mm struct as well as forbiding registering hmm on a
+	 * dying mm
+	 *
+	 * This field is set with mmap_sem held in write mode.
+	 */
+	struct hmm *hmm;
+#endif
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index 1bfefc6..0d1f446 100644
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
@@ -597,6 +598,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 	mmu_notifier_mm_init(mm);
+	hmm_mm_init(mm);
 	clear_tlb_flush_pending(mm);
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
diff --git a/mm/Kconfig b/mm/Kconfig
index e79de2b..e1e0a82 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -654,3 +654,17 @@ config DEFERRED_STRUCT_PAGE_INIT
 	  when kswapd starts. This has a potential performance impact on
 	  processes running early in the lifetime of the systemm until kswapd
 	  finishes the initialisation.
+
+if STAGING
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
+endif # STAGING
diff --git a/mm/Makefile b/mm/Makefile
index 98c4eae..90ca9c4 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -78,3 +78,4 @@ obj-$(CONFIG_CMA)	+= cma.o
 obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
 obj-$(CONFIG_PAGE_EXTENSION) += page_ext.o
 obj-$(CONFIG_CMA_DEBUGFS) += cma_debug.o
+obj-$(CONFIG_HMM) += hmm.o
diff --git a/mm/hmm.c b/mm/hmm.c
new file mode 100644
index 0000000..198fe37
--- /dev/null
+++ b/mm/hmm.c
@@ -0,0 +1,381 @@
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
+ * Refer to include/linux/hmm.h for further information on general design.
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
+
+#include "internal.h"
+
+static struct mmu_notifier_ops hmm_notifier_ops;
+
+
+/* hmm - core HMM functions.
+ *
+ * Core HMM functions that deal with all the process mm activities.
+ */
+
+static int hmm_init(struct hmm *hmm)
+{
+	hmm->mm = current->mm;
+	hmm->vm_end = TASK_SIZE;
+	kref_init(&hmm->kref);
+	INIT_HLIST_HEAD(&hmm->mirrors);
+	init_rwsem(&hmm->rwsem);
+
+	/* register notifier */
+	hmm->mmu_notifier.ops = &hmm_notifier_ops;
+	return __mmu_notifier_register(&hmm->mmu_notifier, current->mm);
+}
+
+static int hmm_add_mirror(struct hmm *hmm, struct hmm_mirror *mirror)
+{
+	struct hmm_mirror *tmp;
+
+	down_write(&hmm->rwsem);
+	hlist_for_each_entry(tmp, &hmm->mirrors, mlist)
+		if (tmp->device == mirror->device) {
+			/* Same device can mirror only once. */
+			up_write(&hmm->rwsem);
+			return -EINVAL;
+		}
+	hlist_add_head(&mirror->mlist, &hmm->mirrors);
+	hmm_mirror_ref(mirror);
+	up_write(&hmm->rwsem);
+
+	return 0;
+}
+
+static inline struct hmm *hmm_ref(struct hmm *hmm)
+{
+	if (!hmm || !kref_get_unless_zero(&hmm->kref))
+		return NULL;
+	return hmm;
+}
+
+static void hmm_destroy_delayed(struct rcu_head *rcu)
+{
+	struct hmm *hmm;
+
+	hmm = container_of(rcu, struct hmm, rcu);
+	kfree(hmm);
+}
+
+static void hmm_destroy(struct kref *kref)
+{
+	struct hmm *hmm;
+
+	hmm = container_of(kref, struct hmm, kref);
+	BUG_ON(!hlist_empty(&hmm->mirrors));
+
+	down_write(&hmm->mm->mmap_sem);
+	/* A new hmm might have been register before reaching that point. */
+	if (hmm->mm->hmm == hmm)
+		hmm->mm->hmm = NULL;
+	up_write(&hmm->mm->mmap_sem);
+
+	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
+
+	mmu_notifier_call_srcu(&hmm->rcu, &hmm_destroy_delayed);
+}
+
+static inline struct hmm *hmm_unref(struct hmm *hmm)
+{
+	if (hmm)
+		kref_put(&hmm->kref, hmm_destroy);
+	return NULL;
+}
+
+
+/* hmm_notifier - HMM callback for mmu_notifier tracking change to process mm.
+ *
+ * HMM use use mmu notifier to track change made to process address space.
+ */
+static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	struct hmm *hmm;
+
+	hmm = hmm_ref(container_of(mn, struct hmm, mmu_notifier));
+	if (!hmm)
+		return;
+
+	down_write(&hmm->rwsem);
+	while (hmm->mirrors.first) {
+		struct hmm_mirror *mirror;
+
+		/*
+		 * Here we are holding the mirror reference from the mirror
+		 * list. As list removal is synchronized through rwsem, no
+		 * other thread can assume it holds that reference.
+		 */
+		mirror = hlist_entry(hmm->mirrors.first,
+				     struct hmm_mirror,
+				     mlist);
+		hlist_del_init(&mirror->mlist);
+		up_write(&hmm->rwsem);
+
+		mirror->device->ops->release(mirror);
+		hmm_mirror_unref(&mirror);
+
+		down_write(&hmm->rwsem);
+	}
+	up_write(&hmm->rwsem);
+
+	hmm_unref(hmm);
+}
+
+static struct mmu_notifier_ops hmm_notifier_ops = {
+	.release		= hmm_notifier_release,
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
+struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror)
+{
+	if (!mirror || !kref_get_unless_zero(&mirror->kref))
+		return NULL;
+	return mirror;
+}
+EXPORT_SYMBOL(hmm_mirror_ref);
+
+static void hmm_mirror_destroy(struct kref *kref)
+{
+	struct hmm_device *device;
+	struct hmm_mirror *mirror;
+
+	mirror = container_of(kref, struct hmm_mirror, kref);
+	device = mirror->device;
+
+	hmm_unref(mirror->hmm);
+
+	spin_lock(&device->lock);
+	list_del_init(&mirror->dlist);
+	device->ops->free(mirror);
+	spin_unlock(&device->lock);
+}
+
+void hmm_mirror_unref(struct hmm_mirror **mirror)
+{
+	struct hmm_mirror *tmp = mirror ? *mirror : NULL;
+
+	if (tmp) {
+		*mirror = NULL;
+		kref_put(&tmp->kref, hmm_mirror_destroy);
+	}
+}
+EXPORT_SYMBOL(hmm_mirror_unref);
+
+/* hmm_mirror_register() - register mirror against current process for a device.
+ *
+ * @mirror: The mirror struct being registered.
+ * Returns: 0 on success or -ENOMEM, -EINVAL on error.
+ *
+ * Call when device driver want to start mirroring a process address space. The
+ * HMM shim will register mmu_notifier and start monitoring process address
+ * space changes. Hence callback to device driver might happen even before this
+ * function return.
+ *
+ * The task device driver want to mirror must be current !
+ *
+ * Only one mirror per mm and hmm_device can be created, it will return NULL if
+ * the hmm_device already has an hmm_mirror for the the mm.
+ */
+int hmm_mirror_register(struct hmm_mirror *mirror)
+{
+	struct mm_struct *mm = current->mm;
+	struct hmm *hmm = NULL;
+	int ret = 0;
+
+	/* Sanity checks. */
+	BUG_ON(!mirror);
+	BUG_ON(!mirror->device);
+	BUG_ON(!mm);
+
+	/*
+	 * Initialize the mirror struct fields, the mlist init and del dance is
+	 * necessary to make the error path easier for driver and for hmm.
+	 */
+	kref_init(&mirror->kref);
+	INIT_HLIST_NODE(&mirror->mlist);
+	INIT_LIST_HEAD(&mirror->dlist);
+	spin_lock(&mirror->device->lock);
+	list_add(&mirror->dlist, &mirror->device->mirrors);
+	spin_unlock(&mirror->device->lock);
+
+	down_write(&mm->mmap_sem);
+
+	hmm = mm->hmm ? hmm_ref(hmm) : NULL;
+	if (hmm == NULL) {
+		/* no hmm registered yet so register one */
+		hmm = kzalloc(sizeof(*mm->hmm), GFP_KERNEL);
+		if (hmm == NULL) {
+			up_write(&mm->mmap_sem);
+			ret = -ENOMEM;
+			goto error;
+		}
+
+		ret = hmm_init(hmm);
+		if (ret) {
+			up_write(&mm->mmap_sem);
+			kfree(hmm);
+			goto error;
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
+		hmm_unref(hmm);
+		goto error;
+	}
+	return 0;
+
+error:
+	spin_lock(&mirror->device->lock);
+	list_del_init(&mirror->dlist);
+	spin_unlock(&mirror->device->lock);
+	return ret;
+}
+EXPORT_SYMBOL(hmm_mirror_register);
+
+static void hmm_mirror_kill(struct hmm_mirror *mirror)
+{
+	struct hmm_device *device = mirror->device;
+	struct hmm *hmm = hmm_ref(mirror->hmm);
+
+	if (!hmm)
+		return;
+
+	down_write(&hmm->rwsem);
+	if (!hlist_unhashed(&mirror->mlist)) {
+		hlist_del_init(&mirror->mlist);
+		up_write(&hmm->rwsem);
+		device->ops->release(mirror);
+		hmm_mirror_unref(&mirror);
+	} else
+		up_write(&hmm->rwsem);
+
+	hmm_unref(hmm);
+}
+
+/* hmm_mirror_unregister() - unregister a mirror.
+ *
+ * @mirror: The mirror that link process address space with the device.
+ *
+ * Driver can call this function when it wants to stop mirroring a process.
+ * This will trigger a call to the ->release() callback if it did not aleady
+ * happen.
+ *
+ * Note that caller must hold a reference on the mirror.
+ *
+ * THIS CAN NOT BE CALL FROM device->release() CALLBACK OR IT WILL DEADLOCK.
+ */
+void hmm_mirror_unregister(struct hmm_mirror *mirror)
+{
+	if (mirror == NULL)
+		return;
+
+	hmm_mirror_kill(mirror);
+	mmu_notifier_synchronize();
+	hmm_mirror_unref(&mirror);
+}
+EXPORT_SYMBOL(hmm_mirror_unregister);
+
+
+/* hmm_device - Each device driver must register one and only one hmm_device
+ *
+ * The hmm_device is the link btw HMM and each device driver.
+ */
+
+/* hmm_device_register() - register a device with HMM.
+ *
+ * @device: The hmm_device struct.
+ * Returns: 0 on success or -EINVAL otherwise.
+ *
+ *
+ * Call when device driver want to register itself with HMM. Device driver must
+ * only register once.
+ */
+int hmm_device_register(struct hmm_device *device)
+{
+	/* sanity check */
+	BUG_ON(!device);
+	BUG_ON(!device->ops);
+	BUG_ON(!device->ops->release);
+
+	spin_lock_init(&device->lock);
+	INIT_LIST_HEAD(&device->mirrors);
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_device_register);
+
+/* hmm_device_unregister() - unregister a device with HMM.
+ *
+ * @device: The hmm_device struct.
+ * Returns: 0 on success or -EBUSY otherwise.
+ *
+ * Call when device driver want to unregister itself with HMM. This will check
+ * that there is no any active mirror and returns -EBUSY if so.
+ */
+int hmm_device_unregister(struct hmm_device *device)
+{
+	spin_lock(&device->lock);
+	if (!list_empty(&device->mirrors)) {
+		spin_unlock(&device->lock);
+		return -EBUSY;
+	}
+	spin_unlock(&device->lock);
+	return 0;
+}
+EXPORT_SYMBOL(hmm_device_unregister);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
