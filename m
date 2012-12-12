Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 26C1D6B0092
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:27:06 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 02/11] drivers/base: Add hotplug framework code
Date: Wed, 12 Dec 2012 16:17:14 -0700
Message-Id: <1355354243-18657-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

Added hotplug.c, which is the hotplug framework code.

hp_register_handler() allows modules to register their hotplug handlers
to the framework.  hp_submit_req() provides the interface to submit
a hotplug or online/offline request.  The request is then put into
hp_workqueue.  hp_start_req() calls all registered handlers in ascending
order for each phase.  If any handler failed in validate or execute phase,
hp_start_req() initiates the rollback procedure.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 drivers/base/Makefile  |   1 +
 drivers/base/hotplug.c | 283 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 284 insertions(+)
 create mode 100644 drivers/base/hotplug.c

diff --git a/drivers/base/Makefile b/drivers/base/Makefile
index 5aa2d70..af2e013 100644
--- a/drivers/base/Makefile
+++ b/drivers/base/Makefile
@@ -21,6 +21,7 @@ endif
 obj-$(CONFIG_SYS_HYPERVISOR) += hypervisor.o
 obj-$(CONFIG_REGMAP)	+= regmap/
 obj-$(CONFIG_SOC_BUS) += soc.o
+obj-$(CONFIG_HOTPLUG)	+= hotplug.o
 
 ccflags-$(CONFIG_DEBUG_DRIVER) := -DDEBUG
 
diff --git a/drivers/base/hotplug.c b/drivers/base/hotplug.c
new file mode 100644
index 0000000..9e85e25
--- /dev/null
+++ b/drivers/base/hotplug.c
@@ -0,0 +1,283 @@
+/*
+ * hotplug.c - Hot-plug framework for system devices
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
+#include <linux/hotplug.h>
+#include <linux/kallsyms.h>
+
+/*
+ * Hot-plug handler list
+ */
+struct hp_handler {
+	struct list_head	hp_list;
+	int			hp_order;
+	hp_func			hp_func;
+};
+
+LIST_HEAD(hp_add_list_head);
+LIST_HEAD(hp_del_list_head);
+
+#define HP_VALIDATE_ORDER_BASE		(HP_ORDER_MAX+1)
+#define HP_EXECUTE_ORDER_BASE		((HP_ORDER_MAX+1) << 1)
+#define HP_COMMIT_ORDER_BASE		((HP_ORDER_MAX+1) << 2)
+
+/*
+ * Hot-plug request work queue
+ */
+struct hp_work {
+	struct hp_request	*request;
+	struct work_struct	work;
+};
+
+static struct workqueue_struct *hp_workqueue;
+
+/* trace messages */
+static int hp_trace = 1;
+static char hp_ksym_buf[KSYM_NAME_LEN];
+
+static char *hp_operation_string(enum hp_operation operation)
+{
+	switch (operation) {
+	case HP_HOTPLUG_ADD:
+		return "Hot-Add";
+	case HP_HOTPLUG_DEL:
+		return "Hot-Delete";
+	case HP_ONLINE_ADD:
+		return "Online";
+	case HP_ONLINE_DEL:
+		return "Offline";
+	}
+
+	return "n/a";
+}
+
+static u32 hp_get_order_base(enum hp_phase phase)
+{
+	switch (phase) {
+	case HP_ADD_VALIDATE:
+	case HP_DEL_VALIDATE:
+		return HP_VALIDATE_ORDER_BASE;
+	case HP_ADD_EXECUTE:
+	case HP_DEL_EXECUTE:
+		return HP_EXECUTE_ORDER_BASE;
+	case HP_ADD_COMMIT:
+	case HP_DEL_COMMIT:
+		return HP_COMMIT_ORDER_BASE;
+	}
+
+	return 0;
+}
+
+/**
+ * hp_register_handler - register a hot-plug handler to the framework
+ * @phase: hot-plug phase
+ * @func: Hot-plug function
+ * @order: Pre-defined order value
+ */
+int hp_register_handler(enum hp_phase phase, hp_func func, u32 order)
+{
+	struct list_head *head;
+	struct hp_handler *hdr, *cur;
+	u32 order_base;
+	int insert = 0;
+
+	if (!func || order > HP_ORDER_MAX)
+		return -EINVAL;
+
+	if (hp_is_add_phase(phase))
+		head = &hp_add_list_head;
+	else
+		head = &hp_del_list_head;
+
+	order_base = hp_get_order_base(phase);
+
+	hdr = kzalloc(sizeof(*hdr), GFP_KERNEL);
+	if (!hdr)
+		return -ENOMEM;
+
+	hdr->hp_order = order + order_base;
+	hdr->hp_func = func;
+
+	/*
+	 * Add this handler to the list in ascending order
+	 */
+	if (list_empty(head)) {
+		list_add(&hdr->hp_list, head);
+	} else {
+		list_for_each_entry(cur, head, hp_list)
+			if (cur->hp_order > hdr->hp_order) {
+				insert = 1;
+				break;
+			}
+
+		if (insert)
+			__list_add(&hdr->hp_list,
+				cur->hp_list.prev, &cur->hp_list);
+		else
+			list_add_tail(&hdr->hp_list, head);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(hp_register_handler);
+
+/**
+ * hp_unregister_handler - unregister a hot-plug handler from the framework
+ * @phase: hot-plug phase
+ * @func: Hot-plug function
+ */
+int hp_unregister_handler(enum hp_phase phase, hp_func func)
+{
+	/* REVISIT: implement later */
+	return 0;
+}
+EXPORT_SYMBOL(hp_unregister_handler);
+
+static void hp_start_req(struct work_struct *work)
+{
+	struct hp_work *hp_work = container_of(work, struct hp_work, work);
+	struct hp_request *req = hp_work->request;
+	struct hp_handler *hdr;
+	struct hp_device *hp_dev, *tmp;
+	struct list_head *head;
+	int rollback = 0;
+	int ret;
+
+	if (hp_is_add_op(req->operation))
+		head = &hp_add_list_head;
+	else
+		head = &hp_del_list_head;
+
+	if (hp_trace)
+		pr_info("Starting %s Operation\n",
+				hp_operation_string(req->operation));
+
+	/*
+	 * Call hot-plug handlers in the list
+	 */
+	list_for_each_entry(hdr, head, hp_list) {
+		if (hp_trace)
+			pr_info("-> %s\n",
+				kallsyms_lookup((unsigned long)hdr->hp_func,
+					NULL, NULL, NULL, hp_ksym_buf));
+
+		ret = hdr->hp_func(req, 0);
+		if (ret) {
+			if (hdr->hp_order < HP_COMMIT_ORDER_BASE) {
+				if (hp_trace)
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
+		list_for_each_entry_continue_reverse(hdr, head, hp_list) {
+			if (hp_trace)
+				pr_info("RB-> %s\n",
+					kallsyms_lookup(
+					   (unsigned long)hdr->hp_func,
+					   NULL, NULL, NULL, hp_ksym_buf));
+
+			ret = hdr->hp_func(req, 1);
+			if (ret)
+				pr_err("Rollback handler failed: continuing\n");
+		}
+	}
+
+	/* free up the hot-plug request information */
+	list_for_each_entry_safe(hp_dev, tmp, &req->dev_list, list) {
+		list_del(&hp_dev->list);
+		kfree(hp_dev);
+	}
+	kfree(req);
+	kfree(hp_work);
+}
+
+/**
+ * hp_submit_req - submit a hot-plug request
+ * @req: Hot-plug request pointer
+ */
+int hp_submit_req(struct hp_request *req)
+{
+	struct hp_work *hp_work;
+
+	hp_work = kzalloc(sizeof(*hp_work), GFP_KERNEL);
+	if (!hp_work)
+		return -ENOMEM;
+
+	hp_work->request = req;
+	INIT_WORK(&hp_work->work, hp_start_req);
+
+	if (!queue_work(hp_workqueue, &hp_work->work)) {
+		kfree(hp_work);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(hp_submit_req);
+
+/**
+ * hp_alloc_request - allocate a hot-plug request
+ * @operation: Hot-plug operation
+ */
+struct hp_request *hp_alloc_request(enum hp_operation operation)
+{
+	struct hp_request *hp_req;
+
+	hp_req = kzalloc(sizeof(*hp_req), GFP_KERNEL);
+	if (!hp_req)
+		return NULL;
+
+	hp_req->operation = operation;
+	INIT_LIST_HEAD(&hp_req->dev_list);
+
+	return hp_req;
+}
+EXPORT_SYMBOL(hp_alloc_request);
+
+/**
+ * hp_add_dev_info - add hp_device to the hotplug request
+ * @hp_req: hot-plug request pointer
+ * @hp_dev: hot-plug device info pointer
+ */
+void hp_add_dev_info(struct hp_request *hp_req, struct hp_device *hp_dev)
+{
+	list_add_tail(&hp_dev->list, &hp_req->dev_list);
+}
+EXPORT_SYMBOL(hp_add_dev_info);
+
+static int __init hp_init(void)
+{
+	/*
+	 * Allocate hp_workqueue with max_active set to 1.  This serializes
+	 * hot-plug and online/offline operations on the workqueue.
+	 */
+	hp_workqueue = alloc_workqueue("hotplug", 0, 1);
+
+	return 0;
+}
+device_initcall(hp_init);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
