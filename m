Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id DD0916B0074
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:50:49 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH v2 03/12] drivers/base: Add system device hotplug framework
Date: Thu, 10 Jan 2013 16:40:21 -0700
Message-Id: <1357861230-29549-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

Added sys_hotplug.c, which is the system device hotplug framework code.

shp_register_handler() allows modules to register their hotplug handlers
to the framework.  shp_submit_req() provides the interface to submit
a hotplug or online/offline request of system devices.  The request is
then put into hp_workqueue.  shp_start_req() calls all registered handlers
in ascending order for each phase.  If any handler failed in validate or
execute phase, shp_start_req() initiates its rollback procedure.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 drivers/base/Makefile      |    1 
 drivers/base/sys_hotplug.c |  313 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 314 insertions(+)
 create mode 100644 drivers/base/sys_hotplug.c

diff --git a/drivers/base/Makefile b/drivers/base/Makefile
index 5aa2d70..2e9b2f1 100644
--- a/drivers/base/Makefile
+++ b/drivers/base/Makefile
@@ -21,6 +21,7 @@ endif
 obj-$(CONFIG_SYS_HYPERVISOR) += hypervisor.o
 obj-$(CONFIG_REGMAP)	+= regmap/
 obj-$(CONFIG_SOC_BUS) += soc.o
+obj-y			+= sys_hotplug.o
 
 ccflags-$(CONFIG_DEBUG_DRIVER) := -DDEBUG
 
diff --git a/drivers/base/sys_hotplug.c b/drivers/base/sys_hotplug.c
new file mode 100644
index 0000000..c5f5285
--- /dev/null
+++ b/drivers/base/sys_hotplug.c
@@ -0,0 +1,313 @@
+/*
+ * sys_hotplug.c - System device hot-plug framework
+ *
+ * Copyright (C) 2012 Hewlett-Packard Development Company, L.P.
+ *	Toshi Kani <toshi.kani@hp.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/list.h>
+#include <linux/workqueue.h>
+#include <linux/sys_hotplug.h>
+#include <linux/kallsyms.h>
+
+/*
+ * Hot-plug handler list
+ */
+struct shp_handler {
+	struct list_head	shp_list;
+	int			shp_order;
+	shp_func		shp_func;
+};
+
+LIST_HEAD(shp_add_list_head);
+LIST_HEAD(shp_del_list_head);
+
+static DEFINE_MUTEX(shp_hdr_list_lock);
+
+#define SHP_VALIDATE_ORDER_BASE		(SHP_ORDER_MAX+1)
+#define SHP_EXECUTE_ORDER_BASE		((SHP_ORDER_MAX+1) << 1)
+#define SHP_COMMIT_ORDER_BASE		((SHP_ORDER_MAX+1) << 2)
+
+/*
+ * Hot-plug request work queue
+ */
+struct shp_work {
+	struct shp_request	*request;
+	struct work_struct	work;
+};
+
+static struct workqueue_struct *shp_workqueue;
+
+/* trace messages */
+static int shp_trace = 1;
+static char shp_ksym_buf[KSYM_NAME_LEN];
+module_param(shp_trace, int, 0644);
+MODULE_PARM_DESC(shp_trace, "Enable system device hot-plug trace messages");
+
+static char *shp_operation_string(enum shp_operation operation)
+{
+	switch (operation) {
+	case SHP_HOTPLUG_ADD:
+		return "Hot-Add";
+	case SHP_HOTPLUG_DEL:
+		return "Hot-Delete";
+	case SHP_ONLINE_ADD:
+		return "Online";
+	case SHP_ONLINE_DEL:
+		return "Offline";
+	}
+
+	return "n/a";
+}
+
+static u32 shp_get_order_base(enum shp_phase phase)
+{
+	switch (phase) {
+	case SHP_ADD_VALIDATE:
+	case SHP_DEL_VALIDATE:
+		return SHP_VALIDATE_ORDER_BASE;
+	case SHP_ADD_EXECUTE:
+	case SHP_DEL_EXECUTE:
+		return SHP_EXECUTE_ORDER_BASE;
+	case SHP_ADD_COMMIT:
+	case SHP_DEL_COMMIT:
+		return SHP_COMMIT_ORDER_BASE;
+	}
+
+	return 0;
+}
+
+/**
+ * shp_register_handler - register a hot-plug handler to the framework
+ * @phase: hot-plug phase
+ * @func: Hot-plug function
+ * @order: Pre-defined order value
+ */
+int shp_register_handler(enum shp_phase phase, shp_func func, u32 order)
+{
+	struct list_head *head;
+	struct shp_handler *hdr, *cur;
+	u32 order_base;
+	int insert = 0;
+
+	if (!func || order > SHP_ORDER_MAX)
+		return -EINVAL;
+
+	if (shp_is_add_phase(phase))
+		head = &shp_add_list_head;
+	else
+		head = &shp_del_list_head;
+
+	order_base = shp_get_order_base(phase);
+
+	hdr = kzalloc(sizeof(*hdr), GFP_KERNEL);
+	if (!hdr)
+		return -ENOMEM;
+
+	hdr->shp_order = order + order_base;
+	hdr->shp_func = func;
+
+	/*
+	 * Add this handler to the list in ascending order
+	 */
+	mutex_lock(&shp_hdr_list_lock);
+	if (list_empty(head)) {
+		list_add(&hdr->shp_list, head);
+	} else {
+		list_for_each_entry(cur, head, shp_list)
+			if (cur->shp_order > hdr->shp_order) {
+				insert = 1;
+				break;
+			}
+
+		if (insert)
+			__list_add(&hdr->shp_list,
+				cur->shp_list.prev, &cur->shp_list);
+		else
+			list_add_tail(&hdr->shp_list, head);
+	}
+	mutex_unlock(&shp_hdr_list_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(shp_register_handler);
+
+/**
+ * shp_unregister_handler - unregister a hot-plug handler from the framework
+ * @phase: hot-plug phase
+ * @func: Hot-plug function
+ */
+int shp_unregister_handler(enum shp_phase phase, shp_func func)
+{
+	struct list_head *head;
+	struct shp_handler *cur;
+
+	if (!func)
+		return -EINVAL;
+
+	if (shp_is_add_phase(phase))
+		head = &shp_add_list_head;
+	else
+		head = &shp_del_list_head;
+
+	/*
+	 * Delete this handler from the list
+	 */
+	mutex_lock(&shp_hdr_list_lock);
+	list_for_each_entry(cur, head, shp_list)
+		if (cur->shp_func == func) {
+			list_del(&cur->shp_list);
+			kfree(cur);
+			break;
+		}
+	mutex_unlock(&shp_hdr_list_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(shp_unregister_handler);
+
+static void shp_start_req(struct work_struct *work)
+{
+	struct shp_work *shp_work = container_of(work, struct shp_work, work);
+	struct shp_request *req = shp_work->request;
+	struct shp_handler *hdr;
+	struct shp_device *shp_dev, *tmp;
+	struct list_head *head;
+	int rollback = 0;
+	int ret;
+
+	if (shp_is_add_op(req->operation))
+		head = &shp_add_list_head;
+	else
+		head = &shp_del_list_head;
+
+	if (shp_trace)
+		pr_info("Starting %s Operation\n",
+				shp_operation_string(req->operation));
+
+	/*
+	 * Call hot-plug handlers in the list
+	 */
+	mutex_lock(&shp_hdr_list_lock);
+	list_for_each_entry(hdr, head, shp_list) {
+		if (shp_trace)
+			pr_info("-> %s\n",
+				kallsyms_lookup((unsigned long)hdr->shp_func,
+					NULL, NULL, NULL, shp_ksym_buf));
+
+		ret = hdr->shp_func(req, 0);
+		if (ret) {
+			if (hdr->shp_order < SHP_COMMIT_ORDER_BASE) {
+				if (shp_trace)
+					pr_info("Initiating Rollback\n");
+				rollback = 1;
+				break;
+			} else {
+				pr_err("Commit handler failed: continuing\n");
+				continue;
+			}
+		}
+	}
+
+	/*
+	 * If rollback is requested, call hot-plug handlers in the reversed
+	 * order from the failed handler.  The failed handler is not called
+	 * again.
+	 */
+	if (rollback) {
+		list_for_each_entry_continue_reverse(hdr, head, shp_list) {
+			if (shp_trace)
+				pr_info("RB-> %s\n",
+					kallsyms_lookup(
+					   (unsigned long)hdr->shp_func,
+					   NULL, NULL, NULL, shp_ksym_buf));
+
+			ret = hdr->shp_func(req, 1);
+			if (ret)
+				pr_err("Rollback handler failed: continuing\n");
+		}
+	}
+	mutex_unlock(&shp_hdr_list_lock);
+
+	/* free up the hot-plug request information */
+	list_for_each_entry_safe(shp_dev, tmp, &req->dev_list, list) {
+		list_del(&shp_dev->list);
+		kfree(shp_dev);
+	}
+	kfree(req);
+	kfree(shp_work);
+}
+
+/**
+ * shp_submit_req - submit a hot-plug request
+ * @req: Hot-plug request pointer
+ */
+int shp_submit_req(struct shp_request *req)
+{
+	struct shp_work *shp_work;
+
+	shp_work = kzalloc(sizeof(*shp_work), GFP_KERNEL);
+	if (!shp_work)
+		return -ENOMEM;
+
+	shp_work->request = req;
+	INIT_WORK(&shp_work->work, shp_start_req);
+
+	if (!queue_work(shp_workqueue, &shp_work->work)) {
+		kfree(shp_work);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(shp_submit_req);
+
+/**
+ * shp_alloc_request - allocate a hot-plug request
+ * @operation: Hot-plug operation
+ */
+struct shp_request *shp_alloc_request(enum shp_operation operation)
+{
+	struct shp_request *shp_req;
+
+	shp_req = kzalloc(sizeof(*shp_req), GFP_KERNEL);
+	if (!shp_req)
+		return NULL;
+
+	shp_req->operation = operation;
+	INIT_LIST_HEAD(&shp_req->dev_list);
+
+	return shp_req;
+}
+EXPORT_SYMBOL(shp_alloc_request);
+
+/**
+ * shp_add_dev_info - add shp_device to the hotplug request
+ * @shp_req: hot-plug request pointer
+ * @shp_dev: hot-plug device info pointer
+ */
+void shp_add_dev_info(struct shp_request *shp_req, struct shp_device *shp_dev)
+{
+	list_add_tail(&shp_dev->list, &shp_req->dev_list);
+}
+EXPORT_SYMBOL(shp_add_dev_info);
+
+static int __init shp_init(void)
+{
+	/*
+	 * Allocate shp_workqueue with max_active set to 1.  This serializes
+	 * hot-plug and online/offline operations on the workqueue.
+	 */
+	shp_workqueue = alloc_workqueue("hotplug", 0, 1);
+
+	return 0;
+}
+device_initcall(shp_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
