Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5517028034A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 14:54:17 -0400 (EDT)
Received: by iehx8 with SMTP id x8so2786463ieh.3
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:54:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id oo7si5189762igb.18.2015.07.17.11.54.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 11:54:16 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 15/15] hmm/dummy: dummy driver for testing and showcasing the HMM API
Date: Fri, 17 Jul 2015 14:52:25 -0400
Message-Id: <1437159145-6548-16-git-send-email-jglisse@redhat.com>
In-Reply-To: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

This is a dummy driver which full fill two purposes :
  - showcase the HMM API and gives references on how to use it.
  - provide an extensive user space API to stress test HMM.

This is a particularly dangerous module as it allow to access a
mirror of a process address space through its device file. Hence
it should not be enabled by default and only people actively
developing for hmm should use it.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/char/Kconfig           |   9 +
 drivers/char/Makefile          |   1 +
 drivers/char/hmm_dummy.c       | 925 +++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/hmm_dummy.h |  51 +++
 4 files changed, 986 insertions(+)
 create mode 100644 drivers/char/hmm_dummy.c
 create mode 100644 include/uapi/linux/hmm_dummy.h

diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
index a043107..b19c2ac 100644
--- a/drivers/char/Kconfig
+++ b/drivers/char/Kconfig
@@ -601,6 +601,15 @@ config TILE_SROM
 	  device appear much like a simple EEPROM, and knows
 	  how to partition a single ROM for multiple purposes.
 
+config HMM_DUMMY
+	tristate "hmm dummy driver to test hmm."
+	depends on HMM
+	default n
+	help
+	  Say Y here if you want to build the hmm dummy driver that allow you
+	  to test the hmm infrastructure by mapping a process address space
+	  in hmm dummy driver device file. When in doubt, say "N".
+
 source "drivers/char/xillybus/Kconfig"
 
 endmenu
diff --git a/drivers/char/Makefile b/drivers/char/Makefile
index d8a7579..3531f92 100644
--- a/drivers/char/Makefile
+++ b/drivers/char/Makefile
@@ -60,3 +60,4 @@ js-rtc-y = rtc.o
 
 obj-$(CONFIG_TILE_SROM)		+= tile-srom.o
 obj-$(CONFIG_XILLYBUS)		+= xillybus/
+obj-$(CONFIG_HMM_DUMMY)		+= hmm_dummy.o
diff --git a/drivers/char/hmm_dummy.c b/drivers/char/hmm_dummy.c
new file mode 100644
index 0000000..edf4b8a
--- /dev/null
+++ b/drivers/char/hmm_dummy.c
@@ -0,0 +1,925 @@
+/*
+ * Copyright 2013 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/*
+ * This is a dummy driver to exercice the HMM (heterogeneous memory management)
+ * API of the kernel. It allow an userspace program to map its whole address
+ * space through the hmm dummy driver file.
+ *
+ * In some way it can also serve as an example driver for people wanting to use
+ * HMM inside there device driver.
+ */
+#include <linux/init.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/major.h>
+#include <linux/cdev.h>
+#include <linux/device.h>
+#include <linux/mutex.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/highmem.h>
+#include <linux/delay.h>
+#include <linux/hmm.h>
+
+#include <uapi/linux/hmm_dummy.h>
+
+#define HMM_DUMMY_DEVICE_NAME "hmm_dummy_device"
+#define HMM_DUMMY_MAX_DEVICES 4
+#define HMM_DUMMY_MAX_MIRRORS 4
+/* Number of page to prefault. */
+
+struct dummy_device;
+
+struct dummy_mirror {
+	struct file		*filp;
+	unsigned		minor;
+	pid_t			pid;
+	struct dummy_device	*ddevice;
+	struct hmm_mirror	mirror;
+	struct hmm_pt		pt;
+	struct list_head	events;
+	spinlock_t		lock;
+	wait_queue_head_t	wait_queue;
+	unsigned		naccess;
+	atomic_t		nworkers;
+	bool			dead;
+};
+
+struct dummy_device {
+	struct cdev		cdevice;
+	struct hmm_device	hdevice;
+	dev_t			dev;
+	int			major;
+	struct mutex		mutex;
+	char			name[32];
+	/* device file mapping tracking (keep track of all vma) */
+	struct dummy_mirror	*dmirrors[HMM_DUMMY_MAX_MIRRORS];
+	struct address_space	*fmapping[HMM_DUMMY_MAX_MIRRORS];
+};
+
+struct dummy_event {
+	struct hmm_event	hevent;
+	struct list_head	list;
+	uint64_t		nsys_pages;
+	uint64_t		nfaulted_sys_pages;
+	bool			backoff;
+};
+
+static struct dummy_device ddevices[HMM_DUMMY_MAX_DEVICES];
+
+
+static void dummy_mirror_release(struct hmm_mirror *mirror)
+{
+	struct dummy_mirror *dmirror;
+	struct dummy_device *ddevice;
+
+	dmirror = container_of(mirror, struct dummy_mirror, mirror);
+	ddevice = dmirror->ddevice;
+	dmirror->dead = true;
+}
+
+static void dummy_mirror_free(struct hmm_mirror *mirror)
+{
+	struct dummy_mirror *dmirror;
+
+	dmirror = container_of(mirror, struct dummy_mirror, mirror);
+	kfree(dmirror);
+}
+
+static void dummy_mirror_access_wait(struct dummy_mirror *dmirror,
+				     const struct hmm_event *event)
+{
+	struct dummy_event *devent;
+
+again:
+	spin_lock(&dmirror->lock);
+	list_for_each_entry(devent, &dmirror->events, list) {
+		if (hmm_event_overlap(event, &devent->hevent)) {
+			unsigned tmp = dmirror->naccess;
+
+			devent->backoff = true;
+			spin_unlock(&dmirror->lock);
+			wait_event(dmirror->wait_queue,
+				   dmirror->naccess != tmp);
+			goto again;
+		}
+	}
+	spin_unlock(&dmirror->lock);
+}
+
+static void dummy_mirror_access_start(struct dummy_mirror *dmirror,
+				      struct dummy_event *devent)
+{
+	spin_lock(&dmirror->lock);
+	list_add_tail(&devent->list, &dmirror->events);
+	dmirror->naccess++;
+	spin_unlock(&dmirror->lock);
+}
+
+static void dummy_mirror_access_stop(struct dummy_mirror *dmirror,
+				     struct dummy_event *devent)
+{
+	spin_lock(&dmirror->lock);
+	list_del_init(&devent->list);
+	dmirror->naccess--;
+	spin_unlock(&dmirror->lock);
+	wake_up(&dmirror->wait_queue);
+}
+
+
+/*
+ * The various HMM callback are the core of HMM API, the device driver gets all
+ * its information through thus callbacks. For the dummy driver we simply use a
+ * page table to store the page frame number backing address the dummy mirror
+ * user wants to access.
+ *
+ * A real device driver would schedule update to the mirror's device page table
+ * and would synchronize with the device to wait for the update to go through.
+ */
+static int dummy_mirror_pt_populate(struct hmm_mirror *mirror,
+				    struct hmm_event *event)
+{
+	unsigned long addr = event->start;
+	struct hmm_pt_iter miter, diter;
+	struct dummy_mirror *dmirror;
+	struct dummy_event *devent;
+	int ret = 0;
+
+	dmirror = container_of(mirror, struct dummy_mirror, mirror);
+	devent = container_of(event, struct dummy_event, hevent);
+
+	hmm_pt_iter_init(&diter, &dmirror->pt);
+	hmm_pt_iter_init(&miter, &mirror->pt);
+
+	do {
+		unsigned long next = event->end;
+		dma_addr_t *mpte, *dpte;
+
+		dpte = hmm_pt_iter_populate(&diter, addr, &next);
+		if (!dpte) {
+			ret = -ENOMEM;
+			break;
+		}
+
+		mpte = hmm_pt_iter_lookup(&miter, addr, &next);
+		/*
+		 * Sanity check, this is only important for debugging HMM, a
+		 * device driver can ignore those test and assume mpte is not
+		 * NULL as NULL would be a serious HMM bug.
+		 */
+		if (!mpte || !hmm_pte_test_valid_pfn(mpte) ||
+		    !hmm_pte_test_select(mpte)) {
+			pr_debug("(%s:%4d) (HMM FATAL) empty pt at 0x%lX\n",
+				 __FILE__, __LINE__, addr);
+			ret = -ENOENT;
+			break;
+		}
+		/*
+		 * Sanity check, this is only important for debugging HMM, a
+		 * device driver can ignore this write test permission.
+		 */
+		if (event->etype == HMM_DEVICE_WFAULT &&
+		    !hmm_pte_test_write(mpte)) {
+			pr_debug("(%s:%4d) (HMM FATAL) RO instead of RW (%pad) at 0x%lX\n",
+				 __FILE__, __LINE__, mpte, addr);
+			ret = -EACCES;
+			break;
+		}
+
+		/*
+		 * This is bit inefficient to lock directoy per entry instead
+		 * of locking directory and going over all its entry. But this
+		 * is a dummy driver and we do not care about efficiency here.
+		 */
+		hmm_pt_iter_directory_lock(&diter);
+		/*
+		 * Simply copy entry, this is a dmmy device, real device would
+		 * reformat the page table entry for the device format and most
+		 * likely write it to some command buffer that would be send to
+		 * device once fill with the update.
+		 */
+		*dpte = *mpte;
+		/* Also increment ref count of dummy page table directory. */
+		hmm_pt_iter_directory_ref(&diter);
+		hmm_pt_iter_directory_unlock(&diter);
+
+		devent->nfaulted_sys_pages++;
+
+		addr += PAGE_SIZE;
+	} while (addr < event->end);
+	hmm_pt_iter_fini(&diter);
+	hmm_pt_iter_fini(&miter);
+
+	return ret;
+}
+
+static int dummy_mirror_pt_invalidate(struct hmm_mirror *mirror,
+				      struct hmm_event *event)
+{
+	unsigned long addr = event->start;
+	struct hmm_pt_iter miter, diter;
+	struct dummy_mirror *dmirror;
+	int ret = 0;
+
+	dmirror = container_of(mirror, struct dummy_mirror, mirror);
+
+	hmm_pt_iter_init(&diter, &dmirror->pt);
+	hmm_pt_iter_init(&miter, &mirror->pt);
+
+	do {
+		dma_addr_t *mpte, *dpte;
+		unsigned long next = event->end;
+
+		dpte = hmm_pt_iter_lookup(&diter, addr, &next);
+		if (!dpte) {
+			addr = next;
+			continue;
+		}
+
+		mpte = hmm_pt_iter_lookup(&miter, addr, &next);
+
+		/*
+		 * This is bit inefficient to lock directoy per entry instead
+		 * of locking directory and going over all its entry. But this
+		 * is a dummy driver and we do not care about efficiency here.
+		 */
+		hmm_pt_iter_directory_lock(&diter);
+
+		/*
+		 * Just skip this entry if it is not valid inside the dummy
+		 * mirror page table.
+		 */
+		if (!hmm_pte_test_valid_pfn(dpte)) {
+			addr += PAGE_SIZE;
+			hmm_pt_iter_directory_unlock(&diter);
+			continue;
+		}
+
+		/*
+		 * Sanity check, this is only important for debugging HMM, a
+		 * device driver can ignore those test and assume mpte is not
+		 * NULL as NULL would be a serious HMM bug.
+		 */
+		if (!mpte || !hmm_pte_test_valid_pfn(mpte)) {
+			hmm_pt_iter_directory_unlock(&diter);
+			pr_debug("(%s:%4d) (HMM FATAL) empty pt at 0x%lX\n",
+				 __FILE__, __LINE__, addr);
+			ret = -ENOENT;
+			break;
+		}
+
+		/*
+		 * Transfer dirty bit. Real device would schedule update to the
+		 * device page table first and then gather the dirtyness from
+		 * device page table before setting the mirror page table entry
+		 * dirty accordingly.
+		 */
+		if (hmm_pte_test_and_clear_dirty(dpte))
+			hmm_pte_set_dirty(mpte);
+
+		/*
+		 * Clear the dummy mirror page table using event mask as dummy
+		 * page table format is same as mirror page table format.
+		 *
+		 * Reall device driver would schedule device page table update
+		 * inside a command buffer, execute the command buffer and wait
+		 * for completion to make sure device and HMM are in sync.
+		 */
+		*dpte &= event->pte_mask;
+
+		/*
+		 * Also decrement ref count of dummy page table directory if
+		 * necessary. We know here for sure that no one could have race
+		 * us to clear the valid entry bit as dummy mirror directory
+		 * is lock.
+		 */
+		if (!hmm_pte_test_valid_pfn(dpte))
+			hmm_pt_iter_directory_unref(&diter);
+
+		hmm_pt_iter_directory_unlock(&diter);
+
+		addr += PAGE_SIZE;
+	} while (addr < event->end);
+	hmm_pt_iter_fini(&diter);
+	hmm_pt_iter_fini(&miter);
+
+	dummy_mirror_access_wait(dmirror, event);
+
+	return ret;
+}
+
+static int dummy_mirror_update(struct hmm_mirror *mirror,
+			       struct hmm_event *event)
+{
+	switch (event->etype) {
+	case HMM_MIGRATE:
+	case HMM_MUNMAP:
+	case HMM_FORK:
+	case HMM_WRITE_PROTECT:
+		return dummy_mirror_pt_invalidate(mirror, event);
+	case HMM_DEVICE_RFAULT:
+	case HMM_DEVICE_WFAULT:
+		return dummy_mirror_pt_populate(mirror, event);
+	default:
+		pr_debug("(%s:%4d) (DUMMY FATAL) unknown event %d\n",
+			 __FILE__, __LINE__, event->etype);
+		return -EIO;
+	}
+}
+
+static const struct hmm_device_ops hmm_dummy_ops = {
+	.release		= &dummy_mirror_release,
+	.free			= &dummy_mirror_free,
+	.update			= &dummy_mirror_update,
+};
+
+
+/* dummy_mirror_alloc() - allocate and initialize dummy mirror struct.
+ *
+ * @ddevice: The dummy device this mirror is associated with.
+ * @filp: The active device file descriptor this mirror is associated with.
+ * @minor: Minor device number or index into dummy device mirror array.
+ */
+static struct dummy_mirror *dummy_mirror_alloc(struct dummy_device *ddevice,
+					       struct file *filp,
+					       unsigned minor)
+{
+	struct dummy_mirror *dmirror;
+
+	/* Mirror this process address space */
+	dmirror = kzalloc(sizeof(*dmirror), GFP_KERNEL);
+	if (dmirror == NULL)
+		return NULL;
+	dmirror->pt.last = TASK_SIZE - 1;
+	if (hmm_pt_init(&dmirror->pt)) {
+		kfree(dmirror);
+		return NULL;
+	}
+	dmirror->ddevice = ddevice;
+	dmirror->mirror.device = &ddevice->hdevice;
+	dmirror->pid = task_pid_nr(current);
+	dmirror->dead = false;
+	dmirror->minor = minor;
+	dmirror->filp = filp;
+	INIT_LIST_HEAD(&dmirror->events);
+	spin_lock_init(&dmirror->lock);
+	init_waitqueue_head(&dmirror->wait_queue);
+	dmirror->naccess = 0;
+	atomic_set(&dmirror->nworkers, 0);
+	return dmirror;
+}
+
+/* dummy_mirror_fault() - fault an address.
+ *
+ * @dmirror: The dummy mirror against which we want to fault.
+ * @event: The dummy event structure describing range to fault.
+ * @write: Is this a write fault.
+ */
+static int dummy_mirror_fault(struct dummy_mirror *dmirror,
+			      struct dummy_event *event,
+			      bool write)
+{
+	struct hmm_mirror *mirror = &dmirror->mirror;
+	int ret;
+
+	event->hevent.etype = write ? HMM_DEVICE_WFAULT : HMM_DEVICE_RFAULT;
+
+	do {
+		cond_resched();
+
+		ret = hmm_mirror_fault(mirror, &event->hevent);
+	} while (ret == -EBUSY);
+
+	return ret;
+}
+
+/* dummy_mirror_worker_thread_sart() - account for a worker thread.
+ *
+ * @dmirror: The dummy mirror.
+ *
+ * Each time we perform an operation on the dummy mirror (fread, fwrite, ioctl,
+ * ...) we pretend a worker thread start. The worker thread count is use to
+ * keep track of active thread that might access the dummy mirror page table.
+ */
+static void dummy_mirror_worker_thread_start(struct dummy_mirror *dmirror)
+{
+	if (dmirror)
+		atomic_inc(&dmirror->nworkers);
+}
+
+/* dummy_mirror_worker_thread_stop() - cleanup after worker thread.
+ *
+ * @dmirror: The dummy mirror.
+ *
+ * Each time we perform an operation on the dummy mirror (fread, fwrite, ioctl,
+ * ...) we pretend a worker thread start and each time we are done we cleanup
+ * after the thread and this also involve freeing the dummy mirror page table
+ * if the mirror is dead.
+ */
+static void dummy_mirror_worker_thread_stop(struct dummy_mirror *dmirror)
+{
+	if (atomic_dec_and_test(&dmirror->nworkers) && dmirror->dead) {
+		/* Free the page table. */
+		hmm_pt_fini(&dmirror->pt);
+	}
+}
+
+static int dummy_read(struct dummy_mirror *dmirror,
+		      struct dummy_event *devent,
+		      char __user *buf,
+		      size_t size)
+{
+	struct hmm_event *event = &devent->hevent;
+	long r = 0;
+
+	while (!r && size) {
+		struct hmm_pt_iter diter;
+		unsigned long offset;
+
+		offset = event->start - (event->start & PAGE_MASK);
+
+		hmm_pt_iter_init(&diter, &dmirror->pt);
+		for (r = 0; !r && size; offset = 0) {
+			unsigned long count = min(PAGE_SIZE - offset, size);
+			unsigned long next = event->end;
+			dma_addr_t *dptep, dpte;
+			struct page *page;
+			char *ptr;
+
+			cond_resched();
+
+			dptep = hmm_pt_iter_lookup(&diter, event->start, &next);
+			if (!dptep)
+				break;
+
+			/*
+			 * This is inefficient but we do not care. Access is a
+			 * barrier for page table invalidation. All information
+			 * extracted from the page table btw start and stop is
+			 * valid.
+			 *
+			 * Real device driver do not need this. It should be
+			 * part of there device page table update.
+			 */
+			dummy_mirror_access_start(dmirror, devent);
+
+			/*
+			 * Because we allow concurrent invalidation of dummy
+			 * mirror page table we need to make sure we use one
+			 * coherent value for each page table entry.
+			 */
+			dpte = ACCESS_ONCE(*dptep);
+			if (!hmm_pte_test_valid_pfn(&dpte)) {
+				dummy_mirror_access_stop(dmirror, devent);
+				break;
+			}
+
+			devent->nsys_pages++;
+
+			page = pfn_to_page(hmm_pte_pfn(dpte));
+			ptr = kmap(page);
+			r = copy_to_user(buf, ptr + offset, count);
+
+			dummy_mirror_access_stop(dmirror, devent);
+
+			event->start += count;
+			size -= count;
+			buf += count;
+			kunmap(page);
+		}
+		hmm_pt_iter_fini(&diter);
+
+		if (!r && size)
+			r = dummy_mirror_fault(dmirror, devent, false);
+	}
+
+	return r;
+}
+
+static int dummy_write(struct dummy_mirror *dmirror,
+		       struct dummy_event *devent,
+		       char __user *buf,
+		       size_t size)
+{
+	struct hmm_event *event = &devent->hevent;
+	long r = 0;
+
+	while (!r && size) {
+		struct hmm_pt_iter diter;
+		unsigned long offset;
+
+		offset = event->start - (event->start & PAGE_MASK);
+
+		hmm_pt_iter_init(&diter, &dmirror->pt);
+		for (r = 0; !r && size; offset = 0) {
+			unsigned long count = min(PAGE_SIZE - offset, size);
+			unsigned long next = event->end;
+			dma_addr_t *dptep, dpte;
+			struct page *page;
+			char *ptr;
+
+			cond_resched();
+
+			dptep = hmm_pt_iter_lookup(&diter, event->start, &next);
+			if (!dptep)
+				break;
+
+			/*
+			 * This is inefficient but we do not care. Access is a
+			 * barrier for page table invalidation. All information
+			 * extracted from the page table btw start and stop is
+			 * valid.
+			 *
+			 * Real device driver do not need this. It should be
+			 * part of there device page table update.
+			 */
+			dummy_mirror_access_start(dmirror, devent);
+
+			/*
+			 * Because we allow concurrent invalidation of dummy
+			 * mirror page table we need to make sure we use one
+			 * coherent value for each page table entry.
+			 */
+			dpte = ACCESS_ONCE(*dptep);
+			if (!hmm_pte_test_valid_pfn(&dpte) ||
+			    !hmm_pte_test_write(&dpte)) {
+				dummy_mirror_access_stop(dmirror, devent);
+				break;
+			}
+
+			devent->nsys_pages++;
+
+			page = pfn_to_page(hmm_pte_pfn(dpte));
+			ptr = kmap(page);
+			r = copy_from_user(ptr + offset, buf, count);
+
+			dummy_mirror_access_stop(dmirror, devent);
+
+			event->start += count;
+			size -= count;
+			buf += count;
+			kunmap(page);
+		}
+		hmm_pt_iter_fini(&diter);
+
+		if (!r && size)
+			r = dummy_mirror_fault(dmirror, devent, true);
+	}
+
+	return r;
+}
+
+
+/*
+ * Below are the vm operation for the dummy device file. Sadly we can not allow
+ * to use the device file through mmap as there is no way to make a page from
+ * the mirror process without having the core mm assume it is a regular page
+ * and thus perform regular operation on it. Allowing this to happen would not
+ * allow to perform proper sanity check and debugging check on HMM and one of
+ * the purpose of the dummy driver is to provide a device driver through which
+ * HMM can be tested and debugged.
+ */
+static int dummy_mmap_fault(struct vm_area_struct *vma,
+				struct vm_fault *vmf)
+{
+	/* Forbid mmap of the dummy device file, see above for the reasons. */
+	return VM_FAULT_SIGBUS;
+}
+
+static void dummy_mmap_open(struct vm_area_struct *vma)
+{
+	/* nop */
+}
+
+static void dummy_mmap_close(struct vm_area_struct *vma)
+{
+	/* nop */
+}
+
+static const struct vm_operations_struct mmap_mem_ops = {
+	.fault			= dummy_mmap_fault,
+	.open			= dummy_mmap_open,
+	.close			= dummy_mmap_close,
+};
+
+
+/*
+ * Below are the file operation for the dummy device file. Only ioctl matter.
+ *
+ * Note this is highly specific to the dummy device driver and should not be
+ * construed as an example on how to design the API a real device driver would
+ * expose to userspace.
+ *
+ * The dummy_mirror.nworkers field is use to mimic the count of device thread
+ * actively using a mirror.
+ */
+static ssize_t dummy_fops_read(struct file *filp,
+			       char __user *buf,
+			       size_t count,
+			       loff_t *ppos)
+{
+	return -EINVAL;
+}
+
+static ssize_t dummy_fops_write(struct file *filp,
+				const char __user *buf,
+				size_t count,
+				loff_t *ppos)
+{
+	return -EINVAL;
+}
+
+static int dummy_fops_mmap(struct file *filp, struct vm_area_struct *vma)
+{
+	/*
+	 * Forbid mmap of the dummy device file, see comment preceding the vm
+	 * operation functions.
+	 */
+	return -EINVAL;
+}
+
+static int dummy_fops_open(struct inode *inode, struct file *filp)
+{
+	struct cdev *cdev = inode->i_cdev;
+	const int minor = iminor(inode);
+	struct dummy_device *ddevice;
+
+	/* No exclusive opens. */
+	if (filp->f_flags & O_EXCL)
+		return -EINVAL;
+
+	ddevice = container_of(cdev, struct dummy_device, cdevice);
+	filp->private_data = ddevice;
+	ddevice->fmapping[minor] = &inode->i_data;
+
+	return 0;
+}
+
+static int dummy_fops_release(struct inode *inode, struct file *filp)
+{
+	struct cdev *cdev = inode->i_cdev;
+	const int minor = iminor(inode);
+	struct dummy_device *ddevice;
+	struct dummy_mirror *dmirror;
+
+	ddevice = container_of(cdev, struct dummy_device, cdevice);
+	mutex_lock(&ddevice->mutex);
+	dmirror = ddevice->dmirrors[minor];
+	ddevice->dmirrors[minor] = NULL;
+	mutex_unlock(&ddevice->mutex);
+
+	/* Nothing to do if no active mirror. */
+	if (!dmirror)
+		return 0;
+
+	/*
+	 * Unregister the mirror this will also drop the reference and lead to
+	 * dummy mirror struct being free through the HMM free() callback once
+	 * all thread holding a reference on the mirror drop it.
+	 */
+	hmm_mirror_unregister(&dmirror->mirror);
+	return 0;
+}
+
+static long dummy_fops_unlocked_ioctl(struct file *filp,
+				      unsigned int command,
+				      unsigned long arg)
+{
+	void __user *uarg = (void __user *)arg;
+	struct dummy_device *ddevice;
+	struct dummy_mirror *dmirror;
+	struct hmm_dummy_write dwrite;
+	struct hmm_dummy_read dread;
+	struct dummy_event devent;
+	unsigned minor;
+	int ret;
+
+	minor = iminor(file_inode(filp));
+	ddevice = filp->private_data;
+
+	mutex_lock(&ddevice->mutex);
+	dmirror = ddevice->dmirrors[minor];
+	if (dmirror)
+		dummy_mirror_worker_thread_start(dmirror);
+	mutex_unlock(&ddevice->mutex);
+
+	switch (command) {
+	case HMM_DUMMY_EXPOSE_MM:
+		if (dmirror) {
+			dummy_mirror_worker_thread_stop(dmirror);
+			return -EBUSY;
+		}
+
+		/* Allocate a new dummy mirror. */
+		dmirror = dummy_mirror_alloc(ddevice, filp, minor);
+		if (!dmirror)
+			return -ENOMEM;
+		dummy_mirror_worker_thread_start(dmirror);
+
+		/* Register the current process mm as being mirrored. */
+		ret = hmm_mirror_register(&dmirror->mirror);
+		if (ret) {
+			dmirror->dead = true;
+			dummy_mirror_worker_thread_stop(dmirror);
+			dummy_mirror_free(&dmirror->mirror);
+			return ret;
+		}
+
+		/*
+		 * Now we can expose the dummy mirror so other file operation
+		 * on the device can start using it.
+		 */
+		mutex_lock(&ddevice->mutex);
+		if (ddevice->dmirrors[minor]) {
+			/* This really should not happen. */
+			mutex_unlock(&ddevice->mutex);
+			dmirror->dead = true;
+			dummy_mirror_worker_thread_stop(dmirror);
+			hmm_mirror_unregister(&dmirror->mirror);
+			return -EBUSY;
+		}
+		ddevice->dmirrors[minor] = dmirror;
+		mutex_unlock(&ddevice->mutex);
+
+		/* Success. */
+		pr_info("mirroring address space of %d\n", dmirror->pid);
+		dummy_mirror_worker_thread_stop(dmirror);
+		return 0;
+	case HMM_DUMMY_READ:
+		if (copy_from_user(&dread, uarg, sizeof(dread))) {
+			dummy_mirror_worker_thread_stop(dmirror);
+			return -EFAULT;
+		}
+
+		memset(&devent, 0, sizeof(devent));
+		devent.hevent.start = dread.address;
+		devent.hevent.end = dread.address + dread.size;
+		ret = dummy_read(dmirror, &devent,
+				 (void __user *)dread.dst,
+				 dread.size);
+
+		dread.nsys_pages = devent.nsys_pages;
+		dread.nfaulted_sys_pages = devent.nfaulted_sys_pages;
+		if (copy_to_user(uarg, &dread, sizeof(dread))) {
+			dummy_mirror_worker_thread_stop(dmirror);
+			return -EFAULT;
+		}
+
+		dummy_mirror_worker_thread_stop(dmirror);
+		return ret;
+	case HMM_DUMMY_WRITE:
+		if (copy_from_user(&dwrite, uarg, sizeof(dwrite))) {
+			dummy_mirror_worker_thread_stop(dmirror);
+			return -EFAULT;
+		}
+
+		memset(&devent, 0, sizeof(devent));
+		devent.hevent.start = dwrite.address;
+		devent.hevent.end = dwrite.address + dwrite.size;
+		ret = dummy_write(dmirror, &devent,
+				  (void __user *)dwrite.dst,
+				  dwrite.size);
+
+		dwrite.nsys_pages = devent.nsys_pages;
+		dwrite.nfaulted_sys_pages = devent.nfaulted_sys_pages;
+		if (copy_to_user(uarg, &dwrite, sizeof(dwrite))) {
+			dummy_mirror_worker_thread_stop(dmirror);
+			return -EFAULT;
+		}
+
+		dummy_mirror_worker_thread_stop(dmirror);
+		return ret;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static const struct file_operations hmm_dummy_fops = {
+	.read		= dummy_fops_read,
+	.write		= dummy_fops_write,
+	.mmap		= dummy_fops_mmap,
+	.open		= dummy_fops_open,
+	.release	= dummy_fops_release,
+	.unlocked_ioctl = dummy_fops_unlocked_ioctl,
+	.llseek		= default_llseek,
+	.owner		= THIS_MODULE,
+};
+
+
+/*
+ * The usual char device driver boiler plate, nothing fancy here.
+ */
+static int dummy_device_init(struct dummy_device *ddevice)
+{
+	int ret, i;
+
+	ret = alloc_chrdev_region(&ddevice->dev, 0,
+				  HMM_DUMMY_MAX_DEVICES,
+				  ddevice->name);
+	if (ret < 0)
+		return ret;
+	ddevice->major = MAJOR(ddevice->dev);
+
+	cdev_init(&ddevice->cdevice, &hmm_dummy_fops);
+	ret = cdev_add(&ddevice->cdevice, ddevice->dev, HMM_DUMMY_MAX_MIRRORS);
+	if (ret) {
+		unregister_chrdev_region(ddevice->dev, HMM_DUMMY_MAX_MIRRORS);
+		return ret;
+	}
+
+	/* Register the hmm device. */
+	for (i = 0; i < HMM_DUMMY_MAX_MIRRORS; i++)
+		ddevice->dmirrors[i] = NULL;
+	mutex_init(&ddevice->mutex);
+	ddevice->hdevice.ops = &hmm_dummy_ops;
+	ddevice->hdevice.dev = NULL;
+
+	ret = hmm_device_register(&ddevice->hdevice);
+	if (ret) {
+		cdev_del(&ddevice->cdevice);
+		unregister_chrdev_region(ddevice->dev, HMM_DUMMY_MAX_MIRRORS);
+	}
+	return ret;
+}
+
+static void dummy_device_fini(struct dummy_device *ddevice)
+{
+	struct dummy_mirror *dmirror;
+	unsigned i;
+
+	/* First unregister all mirror. */
+	do {
+		mutex_lock(&ddevice->mutex);
+		for (i = 0; i < HMM_DUMMY_MAX_MIRRORS; i++) {
+			dmirror = ddevices->dmirrors[i];
+			ddevices->dmirrors[i] = NULL;
+			if (dmirror)
+				break;
+		}
+		mutex_unlock(&ddevice->mutex);
+		if (dmirror)
+			hmm_mirror_unregister(&dmirror->mirror);
+	} while (dmirror);
+
+	hmm_device_unregister(&ddevice->hdevice);
+
+	cdev_del(&ddevice->cdevice);
+	unregister_chrdev_region(ddevice->dev, HMM_DUMMY_MAX_MIRRORS);
+}
+
+static int __init hmm_dummy_init(void)
+{
+	int i, ret;
+
+	for (i = 0; i < HMM_DUMMY_MAX_DEVICES; ++i) {
+		snprintf(ddevices[i].name, sizeof(ddevices[i].name),
+			 "%s%d", HMM_DUMMY_DEVICE_NAME, i);
+		ret = dummy_device_init(&ddevices[i]);
+		if (ret) {
+			/* Empty name means device is not valid. */
+			ddevices[i].name[0] = 0;
+			/*
+			 * Report failure only if we fail to create at least
+			 * one device.
+			 */
+			if (!i)
+				return ret;
+		}
+	}
+
+	pr_info("hmm_dummy loaded THIS IS A DANGEROUS MODULE !!!\n");
+	return 0;
+}
+
+static void __exit hmm_dummy_exit(void)
+{
+	int i;
+
+	for (i = 0; i < HMM_DUMMY_MAX_DEVICES; ++i) {
+		/* Empty name means device is not valid. */
+		if (!ddevices[i].name[0])
+			continue;
+		dummy_device_fini(&ddevices[i]);
+	}
+}
+
+module_init(hmm_dummy_init);
+module_exit(hmm_dummy_exit);
+MODULE_LICENSE("GPL");
diff --git a/include/uapi/linux/hmm_dummy.h b/include/uapi/linux/hmm_dummy.h
new file mode 100644
index 0000000..ed7f03e
--- /dev/null
+++ b/include/uapi/linux/hmm_dummy.h
@@ -0,0 +1,51 @@
+/*
+ * Copyright 2013 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/*
+ * This is a dummy driver to exercice the HMM (heterogeneous memory management)
+ * API of the kernel. It allow an userspace program to expose its whole address
+ * space through the hmm dummy driver file.
+ */
+#ifndef _UAPI_LINUX_HMM_DUMMY_H
+#define _UAPI_LINUX_HMM_DUMMY_H
+
+#include <linux/types.h>
+#include <linux/ioctl.h>
+#include <linux/irqnr.h>
+
+struct hmm_dummy_read {
+	uint64_t		address;
+	uint64_t		size;
+	uint64_t		dst;
+	uint64_t		nsys_pages;
+	uint64_t		nfaulted_sys_pages;
+	uint64_t		reserved[11];
+};
+
+struct hmm_dummy_write {
+	uint64_t		address;
+	uint64_t		size;
+	uint64_t		dst;
+	uint64_t		nsys_pages;
+	uint64_t		nfaulted_sys_pages;
+	uint64_t		reserved[11];
+};
+
+/* Expose the address space of the calling process through hmm dummy dev file */
+#define HMM_DUMMY_EXPOSE_MM	_IO('H', 0x00)
+#define HMM_DUMMY_READ		_IOWR('H', 0x01, struct hmm_dummy_read)
+#define HMM_DUMMY_WRITE		_IOWR('H', 0x02, struct hmm_dummy_write)
+
+#endif /* _UAPI_LINUX_HMM_DUMMY_H */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
