Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 673F66B0092
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:26:59 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 01/11] Add hotplug.h for hotplug framework
Date: Wed, 12 Dec 2012 16:17:13 -0700
Message-Id: <1355354243-18657-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

Added include/linux/hotplug.h, which defines the hotplug framework
interfaces used by the framework itself and handlers.

The order values define the calling sequence of handlers.  For add
execute, the ordering is ACPI->MEM->CPU.  Memory is onlined before
CPU so that threads on new CPUs can start using their local memory.
The ordering of the delete execute is symmetric to the add execute.

struct hp_request defines a hot-plug request information.  The
device resource information is managed with a list so that a single
request may target to multiple devices.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 include/linux/hotplug.h | 187 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 187 insertions(+)
 create mode 100644 include/linux/hotplug.h

diff --git a/include/linux/hotplug.h b/include/linux/hotplug.h
new file mode 100644
index 0000000..b64f91b
--- /dev/null
+++ b/include/linux/hotplug.h
@@ -0,0 +1,187 @@
+/*
+ * hotplug.h - Hot-plug framework for system devices
+ *
+ * Copyright (C) 2012 Hewlett-Packard Development Company, L.P.
+ *	Toshi Kani <toshi.kani@hp.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _LINUX_HOTPLUG_H
+#define _LINUX_HOTPLUG_H
+
+#include <linux/list.h>
+#include <linux/device.h>
+
+/*
+ * A hot-plug operation proceeds in the following order.
+ *   Validate phase -> Execute phase -> Commit phase
+ *
+ * The order values below define the calling sequence of each phase
+ * in ascending order.
+ */
+
+/* All order values must be smaller than this value */
+#define HP_ORDER_MAX				0xffffff
+
+/* Add Validate order values */
+#define HP_ACPI_BUS_ADD_VALIDATE_ORDER		0	/* must be first */
+
+/* Add Execute order values */
+#define HP_ACPI_BUS_ADD_EXECUTE_ORDER		10
+#define HP_ACPI_RES_ADD_EXECUTE_ORDER		20
+#define HP_MEM_ADD_EXECUTE_ORDER		30
+#define HP_CPU_ADD_EXECUTE_ORDER		40
+
+/* Add Commit order values */
+#define HP_ACPI_BUS_ADD_COMMIT_ORDER		10
+
+/* Delete Validate order values */
+#define HP_ACPI_BUS_DEL_VALIDATE_ORDER		0	/* must be first */
+#define HP_ACPI_RES_DEL_VALIDATE_ORDER		10
+#define HP_CPU_DEL_VALIDATE_ORDER		20
+#define HP_MEM_DEL_VALIDATE_ORDER		30
+
+/* Delete Execute order values */
+#define HP_CPU_DEL_EXECUTE_ORDER		10
+#define HP_MEM_DEL_EXECUTE_ORDER		20
+#define HP_ACPI_BUS_DEL_EXECUTE_ORDER		30
+
+/* Delete Commit order values */
+#define HP_ACPI_BUS_DEL_COMMIT_ORDER		10
+
+/*
+ * Hot-plug request types
+ */
+#define HP_REQ_ADD		0x000000
+#define HP_REQ_DELETE		0x000001
+#define HP_REQ_MASK		0x0000ff
+
+/*
+ * Hot-plug phase types
+ */
+#define HP_PH_VALIDATE		0x000000
+#define HP_PH_EXECUTE		0x000100
+#define HP_PH_COMMIT		0x000200
+#define HP_PH_MASK		0x00ff00
+
+/*
+ * Hot-plug operation types
+ */
+#define HP_OP_HOTPLUG		0x000000
+#define HP_OP_ONLINE		0x010000
+#define HP_OP_MASK		0xff0000
+
+/*
+ * Hot-plug phases
+ */
+enum hp_phase {
+	HP_ADD_VALIDATE	= (HP_REQ_ADD|HP_PH_VALIDATE),
+	HP_ADD_EXECUTE	= (HP_REQ_ADD|HP_PH_EXECUTE),
+	HP_ADD_COMMIT	= (HP_REQ_ADD|HP_PH_COMMIT),
+	HP_DEL_VALIDATE	= (HP_REQ_DELETE|HP_PH_VALIDATE),
+	HP_DEL_EXECUTE	= (HP_REQ_DELETE|HP_PH_EXECUTE),
+	HP_DEL_COMMIT	= (HP_REQ_DELETE|HP_PH_COMMIT)
+};
+
+/*
+ * Hot-plug operations
+ */
+enum hp_operation {
+	HP_HOTPLUG_ADD = (HP_OP_HOTPLUG|HP_REQ_ADD),
+	HP_HOTPLUG_DEL = (HP_OP_HOTPLUG|HP_REQ_DELETE),
+	HP_ONLINE_ADD  = (HP_OP_ONLINE|HP_REQ_ADD),
+	HP_ONLINE_DEL  = (HP_OP_ONLINE|HP_REQ_DELETE)
+};
+
+/*
+ * Hot-plug device classes
+ */
+enum hp_class {
+	HP_CLS_INVALID		= 0,
+	HP_CLS_CPU		= 1,
+	HP_CLS_MEMORY		= 2,
+	HP_CLS_HOSTBRIDGE	= 3,
+	HP_CLS_CONTAINER	= 4,
+};
+
+/*
+ * Hot-plug device information
+ */
+union hp_dev_info {
+	struct hp_cpu {
+		u32		cpu_id;
+	} cpu;
+
+	struct hp_memory {
+		int		node;
+		u64		start_addr;
+		u64		length;
+	} mem;
+
+	struct hp_hostbridge {
+	} hb;
+
+	struct hp_container {
+	} con;
+};
+
+struct hp_device {
+	struct list_head	list;
+	struct device		*device;
+	enum hp_class		class;
+	union hp_dev_info	data;
+};
+
+/*
+ * Hot-plug request
+ */
+struct hp_request {
+	/* common info */
+	enum hp_operation	operation;	/* operation */
+
+	/* hot-plug event info: only valid for hot-plug operations */
+	void			*handle;	/* FW handle */
+	u32			event;		/* FW event */
+
+	/* device resource info */
+	struct list_head	dev_list;	/* hp_device list */
+};
+
+/*
+ * Inline Utility Functions
+ */
+static inline bool hp_is_hotplug_op(enum hp_operation operation)
+{
+	return (operation & HP_OP_MASK) == HP_OP_HOTPLUG;
+}
+
+static inline bool hp_is_online_op(enum hp_operation operation)
+{
+	return (operation & HP_OP_MASK) == HP_OP_ONLINE;
+}
+
+static inline bool hp_is_add_op(enum hp_operation operation)
+{
+	return (operation & HP_REQ_MASK) == HP_REQ_ADD;
+}
+
+static inline bool hp_is_add_phase(enum hp_phase phase)
+{
+	return (phase & HP_REQ_MASK) == HP_REQ_ADD;
+}
+
+/*
+ * Externs
+ */
+typedef int (*hp_func)(struct hp_request *req, int rollback);
+extern int hp_register_handler(enum hp_phase phase, hp_func func, u32 order);
+extern int hp_unregister_handler(enum hp_phase phase, hp_func func);
+extern int hp_submit_req(struct hp_request *req);
+extern struct hp_request *hp_alloc_request(enum hp_operation operation);
+extern void hp_add_dev_info(struct hp_request *hp_req,
+		struct hp_device *hp_dev);
+
+#endif	/* _LINUX_HOTPLUG_H */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
