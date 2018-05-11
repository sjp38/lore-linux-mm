Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3A66B0686
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:08:12 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id r104-v6so4351335ota.19
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:08:12 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j63-v6si1225531oiy.456.2018.05.11.12.08.10
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:08:10 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 07/40] iommu: Add a page fault handler
Date: Fri, 11 May 2018 20:06:08 +0100
Message-Id: <20180511190641.23008-8-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

Some systems allow devices to handle I/O Page Faults in the core mm. For
example systems implementing the PCI PRI extension or Arm SMMU stall
model. Infrastructure for reporting these recoverable page faults was
recently added to the IOMMU core for SVA virtualisation. Add a page fault
handler for host SVA.

IOMMU driver can now instantiate several fault workqueues and link them to
IOPF-capable devices. Drivers can choose between a single global
workqueue, one per IOMMU device, one per low-level fault queue, one per
domain, etc.

When it receives a fault event, supposedly in an IRQ handler, the IOMMU
driver reports the fault using iommu_report_device_fault(), which calls
the registered handler. The page fault handler then calls the mm fault
handler, and reports either success or failure with iommu_page_response().
When the handler succeeded, the IOMMU retries the access.

The iopf_param pointer could be embedded into iommu_fault_param. But
putting iopf_param into the iommu_param structure allows us not to care
about ordering between calls to iopf_queue_add_device() and
iommu_register_device_fault_handler().

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2: multiple queues registered by IOMMU driver
---
 drivers/iommu/Kconfig      |   4 +
 drivers/iommu/Makefile     |   1 +
 drivers/iommu/io-pgfault.c | 363 +++++++++++++++++++++++++++++++++++++
 include/linux/iommu.h      |  58 ++++++
 4 files changed, 426 insertions(+)
 create mode 100644 drivers/iommu/io-pgfault.c

diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index 38434899e283..09f13a7c4b60 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -79,6 +79,10 @@ config IOMMU_SVA
 	select IOMMU_API
 	select MMU_NOTIFIER
 
+config IOMMU_PAGE_FAULT
+	bool
+	select IOMMU_API
+
 config FSL_PAMU
 	bool "Freescale IOMMU support"
 	depends on PCI
diff --git a/drivers/iommu/Makefile b/drivers/iommu/Makefile
index 1dbcc89ebe4c..4b744e399a1b 100644
--- a/drivers/iommu/Makefile
+++ b/drivers/iommu/Makefile
@@ -4,6 +4,7 @@ obj-$(CONFIG_IOMMU_API) += iommu-traces.o
 obj-$(CONFIG_IOMMU_API) += iommu-sysfs.o
 obj-$(CONFIG_IOMMU_DMA) += dma-iommu.o
 obj-$(CONFIG_IOMMU_SVA) += iommu-sva.o
+obj-$(CONFIG_IOMMU_PAGE_FAULT) += io-pgfault.o
 obj-$(CONFIG_IOMMU_IO_PGTABLE) += io-pgtable.o
 obj-$(CONFIG_IOMMU_IO_PGTABLE_ARMV7S) += io-pgtable-arm-v7s.o
 obj-$(CONFIG_IOMMU_IO_PGTABLE_LPAE) += io-pgtable-arm.o
diff --git a/drivers/iommu/io-pgfault.c b/drivers/iommu/io-pgfault.c
new file mode 100644
index 000000000000..321c00dd3a3d
--- /dev/null
+++ b/drivers/iommu/io-pgfault.c
@@ -0,0 +1,363 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Handle device page faults
+ *
+ * Copyright (C) 2018 ARM Ltd.
+ */
+
+#include <linux/iommu.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/workqueue.h>
+
+/**
+ * struct iopf_queue - IO Page Fault queue
+ * @wq: the fault workqueue
+ * @flush: low-level flush callback
+ * @flush_arg: flush() argument
+ * @refs: references to this structure taken by producers
+ */
+struct iopf_queue {
+	struct workqueue_struct		*wq;
+	iopf_queue_flush_t		flush;
+	void				*flush_arg;
+	refcount_t			refs;
+};
+
+/**
+ * struct iopf_device_param - IO Page Fault data attached to a device
+ * @queue: IOPF queue
+ * @partial: faults that are part of a Page Request Group for which the last
+ *           request hasn't been submitted yet.
+ */
+struct iopf_device_param {
+	struct iopf_queue		*queue;
+	struct list_head		partial;
+};
+
+struct iopf_context {
+	struct device			*dev;
+	struct iommu_fault_event	evt;
+	struct list_head		head;
+};
+
+struct iopf_group {
+	struct iopf_context		last_fault;
+	struct list_head		faults;
+	struct work_struct		work;
+};
+
+static int iopf_complete(struct device *dev, struct iommu_fault_event *evt,
+			 enum page_response_code status)
+{
+	struct page_response_msg resp = {
+		.addr			= evt->addr,
+		.pasid			= evt->pasid,
+		.pasid_present		= evt->pasid_valid,
+		.page_req_group_id	= evt->page_req_group_id,
+		.private_data		= evt->iommu_private,
+		.resp_code		= status,
+	};
+
+	return iommu_page_response(dev, &resp);
+}
+
+static enum page_response_code
+iopf_handle_single(struct iopf_context *fault)
+{
+	/* TODO */
+	return -ENODEV;
+}
+
+static void iopf_handle_group(struct work_struct *work)
+{
+	struct iopf_group *group;
+	struct iopf_context *fault, *next;
+	enum page_response_code status = IOMMU_PAGE_RESP_SUCCESS;
+
+	group = container_of(work, struct iopf_group, work);
+
+	list_for_each_entry_safe(fault, next, &group->faults, head) {
+		struct iommu_fault_event *evt = &fault->evt;
+		/*
+		 * Errors are sticky: don't handle subsequent faults in the
+		 * group if there is an error.
+		 */
+		if (status == IOMMU_PAGE_RESP_SUCCESS)
+			status = iopf_handle_single(fault);
+
+		if (!evt->last_req)
+			kfree(fault);
+	}
+
+	iopf_complete(group->last_fault.dev, &group->last_fault.evt, status);
+	kfree(group);
+}
+
+/**
+ * iommu_queue_iopf - IO Page Fault handler
+ * @evt: fault event
+ * @cookie: struct device, passed to iommu_register_device_fault_handler.
+ *
+ * Add a fault to the device workqueue, to be handled by mm.
+ */
+int iommu_queue_iopf(struct iommu_fault_event *evt, void *cookie)
+{
+	struct iopf_group *group;
+	struct iopf_context *fault, *next;
+	struct iopf_device_param *iopf_param;
+
+	struct device *dev = cookie;
+	struct iommu_param *param = dev->iommu_param;
+
+	if (WARN_ON(!mutex_is_locked(&param->lock)))
+		return -EINVAL;
+
+	if (evt->type != IOMMU_FAULT_PAGE_REQ)
+		/* Not a recoverable page fault */
+		return IOMMU_PAGE_RESP_CONTINUE;
+
+	/*
+	 * As long as we're holding param->lock, the queue can't be unlinked
+	 * from the device and therefore cannot disappear.
+	 */
+	iopf_param = param->iopf_param;
+	if (!iopf_param)
+		return -ENODEV;
+
+	if (!evt->last_req) {
+		fault = kzalloc(sizeof(*fault), GFP_KERNEL);
+		if (!fault)
+			return -ENOMEM;
+
+		fault->evt = *evt;
+		fault->dev = dev;
+
+		/* Non-last request of a group. Postpone until the last one */
+		list_add(&fault->head, &iopf_param->partial);
+
+		return IOMMU_PAGE_RESP_HANDLED;
+	}
+
+	group = kzalloc(sizeof(*group), GFP_KERNEL);
+	if (!group)
+		return -ENOMEM;
+
+	group->last_fault.evt = *evt;
+	group->last_fault.dev = dev;
+	INIT_LIST_HEAD(&group->faults);
+	list_add(&group->last_fault.head, &group->faults);
+	INIT_WORK(&group->work, iopf_handle_group);
+
+	/* See if we have partial faults for this group */
+	list_for_each_entry_safe(fault, next, &iopf_param->partial, head) {
+		if (fault->evt.page_req_group_id == evt->page_req_group_id)
+			/* Insert *before* the last fault */
+			list_move(&fault->head, &group->faults);
+	}
+
+	queue_work(iopf_param->queue->wq, &group->work);
+
+	/* Postpone the fault completion */
+	return IOMMU_PAGE_RESP_HANDLED;
+}
+EXPORT_SYMBOL_GPL(iommu_queue_iopf);
+
+/**
+ * iopf_queue_flush_dev - Ensure that all queued faults have been processed
+ * @dev: the endpoint whose faults need to be flushed.
+ *
+ * Users must call this function when releasing a PASID, to ensure that all
+ * pending faults for this PASID have been handled, and won't hit the address
+ * space of the next process that uses this PASID.
+ *
+ * Return 0 on success.
+ */
+int iopf_queue_flush_dev(struct device *dev)
+{
+	int ret = 0;
+	struct iopf_queue *queue;
+	struct iommu_param *param = dev->iommu_param;
+
+	if (!param)
+		return -ENODEV;
+
+	/*
+	 * It is incredibly easy to find ourselves in a deadlock situation if
+	 * we're not careful, because we're taking the opposite path as
+	 * iommu_queue_iopf:
+	 *
+	 *   iopf_queue_flush_dev()   |  PRI queue handler
+	 *    lock(mutex)             |   iommu_queue_iopf()
+	 *     queue->flush()         |    lock(mutex)
+	 *      wait PRI queue empty  |
+	 *
+	 * So we can't hold the device param lock while flushing. We don't have
+	 * to, because the queue or the device won't disappear until all flush
+	 * are finished.
+	 */
+	mutex_lock(&param->lock);
+	if (param->iopf_param) {
+		queue = param->iopf_param->queue;
+	} else {
+		ret = -ENODEV;
+	}
+	mutex_unlock(&param->lock);
+	if (ret)
+		return ret;
+
+	queue->flush(queue->flush_arg, dev);
+
+	/*
+	 * No need to clear the partial list. All PRGs containing the PASID that
+	 * needs to be decommissioned are whole (the device driver made sure of
+	 * it before this function was called). They have been submitted to the
+	 * queue by the above flush().
+	 */
+	flush_workqueue(queue->wq);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(iopf_queue_flush_dev);
+
+/**
+ * iopf_queue_add_device - Add producer to the fault queue
+ * @queue: IOPF queue
+ * @dev: device to add
+ */
+int iopf_queue_add_device(struct iopf_queue *queue, struct device *dev)
+{
+	int ret = -EINVAL;
+	struct iopf_device_param *iopf_param;
+	struct iommu_param *param = dev->iommu_param;
+
+	if (!param)
+		return -ENODEV;
+
+	iopf_param = kzalloc(sizeof(*iopf_param), GFP_KERNEL);
+	if (!iopf_param)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&iopf_param->partial);
+	iopf_param->queue = queue;
+
+	mutex_lock(&param->lock);
+	if (!param->iopf_param) {
+		refcount_inc(&queue->refs);
+		param->iopf_param = iopf_param;
+		ret = 0;
+	}
+	mutex_unlock(&param->lock);
+
+	if (ret)
+		kfree(iopf_param);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(iopf_queue_add_device);
+
+/**
+ * iopf_queue_remove_device - Remove producer from fault queue
+ * @dev: device to remove
+ *
+ * Caller makes sure that no more fault is reported for this device, and no more
+ * flush is scheduled for this device.
+ *
+ * Note: safe to call unconditionally on a cleanup path, even if the device
+ * isn't registered to any IOPF queue.
+ *
+ * Return 0 if the device was attached to the IOPF queue
+ */
+int iopf_queue_remove_device(struct device *dev)
+{
+	struct iopf_context *fault, *next;
+	struct iopf_device_param *iopf_param;
+	struct iommu_param *param = dev->iommu_param;
+
+	if (!param)
+		return -EINVAL;
+
+	mutex_lock(&param->lock);
+	iopf_param = param->iopf_param;
+	if (iopf_param) {
+		refcount_dec(&iopf_param->queue->refs);
+		param->iopf_param = NULL;
+	}
+	mutex_unlock(&param->lock);
+	if (!iopf_param)
+		return -EINVAL;
+
+	list_for_each_entry_safe(fault, next, &iopf_param->partial, head)
+		kfree(fault);
+
+	/*
+	 * No more flush is scheduled, and the caller removed all bonds from
+	 * this device. unbind() waited until any concurrent mm_exit() finished,
+	 * therefore there is no flush() running anymore and we can free the
+	 * param.
+	 */
+	kfree(iopf_param);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(iopf_queue_remove_device);
+
+/**
+ * iopf_queue_alloc - Allocate and initialize a fault queue
+ * @name: a unique string identifying the queue (for workqueue)
+ * @flush: a callback that flushes the low-level queue
+ * @cookie: driver-private data passed to the flush callback
+ *
+ * The callback is called before the workqueue is flushed. The IOMMU driver must
+ * commit all faults that are pending in its low-level queues at the time of the
+ * call, into the IOPF queue (with iommu_report_device_fault). The callback
+ * takes a device pointer as argument, hinting what endpoint is causing the
+ * flush. When the device is NULL, all faults should be committed.
+ */
+struct iopf_queue *
+iopf_queue_alloc(const char *name, iopf_queue_flush_t flush, void *cookie)
+{
+	struct iopf_queue *queue;
+
+	queue = kzalloc(sizeof(*queue), GFP_KERNEL);
+	if (!queue)
+		return NULL;
+
+	/*
+	 * The WQ is unordered because the low-level handler enqueues faults by
+	 * group. PRI requests within a group have to be ordered, but once
+	 * that's dealt with, the high-level function can handle groups out of
+	 * order.
+	 */
+	queue->wq = alloc_workqueue("iopf_queue/%s", WQ_UNBOUND, 0, name);
+	if (!queue->wq) {
+		kfree(queue);
+		return NULL;
+	}
+
+	queue->flush = flush;
+	queue->flush_arg = cookie;
+	refcount_set(&queue->refs, 1);
+
+	return queue;
+}
+EXPORT_SYMBOL_GPL(iopf_queue_alloc);
+
+/**
+ * iopf_queue_free - Free IOPF queue
+ * @queue: queue to free
+ *
+ * Counterpart to iopf_queue_alloc(). Caller must make sure that all producers
+ * have been removed.
+ */
+void iopf_queue_free(struct iopf_queue *queue)
+{
+
+	/* Caller should have removed all producers first */
+	if (WARN_ON(!refcount_dec_and_test(&queue->refs)))
+		return;
+
+	destroy_workqueue(queue->wq);
+	kfree(queue);
+}
+EXPORT_SYMBOL_GPL(iopf_queue_free);
diff --git a/include/linux/iommu.h b/include/linux/iommu.h
index faf3390ce89d..fad3a60e1c14 100644
--- a/include/linux/iommu.h
+++ b/include/linux/iommu.h
@@ -461,11 +461,20 @@ struct iommu_fault_param {
 	void *data;
 };
 
+/**
+ * iopf_queue_flush_t - Flush low-level page fault queue
+ *
+ * Report all faults currently pending in the low-level page fault queue
+ */
+struct iopf_queue;
+typedef int (*iopf_queue_flush_t)(void *cookie, struct device *dev);
+
 /**
  * struct iommu_param - collection of per-device IOMMU data
  *
  * @fault_param: IOMMU detected device fault reporting data
  * @sva_param: SVA parameters
+ * @iopf_param: I/O Page Fault queue and data
  *
  * TODO: migrate other per device data pointers under iommu_dev_data, e.g.
  *	struct iommu_group	*iommu_group;
@@ -475,6 +484,7 @@ struct iommu_param {
 	struct mutex lock;
 	struct iommu_fault_param *fault_param;
 	struct iommu_sva_param *sva_param;
+	struct iopf_device_param *iopf_param;
 };
 
 int  iommu_device_register(struct iommu_device *iommu);
@@ -874,6 +884,12 @@ static inline int iommu_report_device_fault(struct device *dev, struct iommu_fau
 	return 0;
 }
 
+static inline int iommu_page_response(struct device *dev,
+				      struct page_response_msg *msg)
+{
+	return -ENODEV;
+}
+
 static inline int iommu_group_id(struct iommu_group *group)
 {
 	return -ENODEV;
@@ -1038,4 +1054,46 @@ static inline struct mm_struct *iommu_sva_find(int pasid)
 }
 #endif /* CONFIG_IOMMU_SVA */
 
+#ifdef CONFIG_IOMMU_PAGE_FAULT
+extern int iommu_queue_iopf(struct iommu_fault_event *evt, void *cookie);
+
+extern int iopf_queue_add_device(struct iopf_queue *queue, struct device *dev);
+extern int iopf_queue_remove_device(struct device *dev);
+extern int iopf_queue_flush_dev(struct device *dev);
+extern struct iopf_queue *
+iopf_queue_alloc(const char *name, iopf_queue_flush_t flush, void *cookie);
+extern void iopf_queue_free(struct iopf_queue *queue);
+#else /* CONFIG_IOMMU_PAGE_FAULT */
+static inline int iommu_queue_iopf(struct iommu_fault_event *evt, void *cookie)
+{
+	return -ENODEV;
+}
+
+static inline int iopf_queue_add_device(struct iopf_queue *queue,
+					struct device *dev)
+{
+	return -ENODEV;
+}
+
+static inline int iopf_queue_remove_device(struct device *dev)
+{
+	return -ENODEV;
+}
+
+static inline int iopf_queue_flush_dev(struct device *dev)
+{
+	return -ENODEV;
+}
+
+static inline struct iopf_queue *
+iopf_queue_alloc(const char *name, iopf_queue_flush_t flush, void *cookie)
+{
+	return NULL;
+}
+
+static inline void iopf_queue_free(struct iopf_queue *queue)
+{
+}
+#endif /* CONFIG_IOMMU_PAGE_FAULT */
+
 #endif /* __LINUX_IOMMU_H */
-- 
2.17.0
