Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id A46F46B0070
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:51:30 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3650067pbb.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:51:30 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 08/13] ACPIHP: provide interface to cancel inprogress hotplug operations
Date: Sun,  4 Nov 2012 20:50:10 +0800
Message-Id: <1352033415-5606-9-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

Some hotplug operations, such as hot-removal of memory device, may take
very long or even infinite time. One possible solution is to time out
and retry, but it's sub-optimal.

This patch implements interfaces to cancel inprogress ACPI system device
hotplug operations, so user could cancel a long-standing hotplug request
on demand.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
---
 drivers/acpi/hotplug/Makefile     |    1 +
 drivers/acpi/hotplug/acpihp_drv.h |   19 ++++
 drivers/acpi/hotplug/cancel.c     |  174 +++++++++++++++++++++++++++++++++++++
 3 files changed, 194 insertions(+)
 create mode 100644 drivers/acpi/hotplug/cancel.c

diff --git a/drivers/acpi/hotplug/Makefile b/drivers/acpi/hotplug/Makefile
index bfb677f..f72f2c3 100644
--- a/drivers/acpi/hotplug/Makefile
+++ b/drivers/acpi/hotplug/Makefile
@@ -13,3 +13,4 @@ acpihp_slot-$(CONFIG_ACPI_HOTPLUG_SLOT_FAKE)	+= slot_fake.o
 obj-$(CONFIG_ACPI_HOTPLUG_DRIVER)		+= acpihp_drv.o
 acpihp_drv-y					= drv_main.o
 acpihp_drv-y					+= dependency.o
+acpihp_drv-y					+= cancel.o
diff --git a/drivers/acpi/hotplug/acpihp_drv.h b/drivers/acpi/hotplug/acpihp_drv.h
index 32ea054..dd8ea92 100644
--- a/drivers/acpi/hotplug/acpihp_drv.h
+++ b/drivers/acpi/hotplug/acpihp_drv.h
@@ -38,8 +38,20 @@ enum acpihp_drv_cmd {
 	ACPIHP_DRV_CMD_MAX
 };
 
+enum acpihp_drv_cancel_state {
+	ACPIHP_DRV_CANCEL_INIT = 0,
+	ACPIHP_DRV_CANCEL_STARTED,
+	ACPIHP_DRV_CANCEL_OK,
+	ACPIHP_DRV_CANCEL_FAILED,
+	ACPIHP_DRV_CANCEL_MISSED,
+	ACPIHP_DRV_CANCEL_FINISHED
+};
+
 struct acpihp_slot_drv {
 	struct mutex		op_mutex;
+	atomic_t		cancel_state;
+	atomic_t		cancel_users;
+	struct acpihp_cancel_context	cancel_ctx;
 };
 
 struct acpihp_slot_dependency {
@@ -62,4 +74,11 @@ int acpihp_drv_filter_dependency_list(struct list_head *old_head,
 int acpihp_drv_generate_dependency_list(struct acpihp_slot *slot,
 		struct list_head *slot_list, enum acpihp_drv_cmd cmd);
 
+void acpihp_drv_cancel_init(struct list_head *list);
+void acpihp_drv_cancel_notify(struct acpihp_slot *slot,
+			      enum acpihp_drv_cancel_state state);
+void acpihp_drv_cancel_fini(struct list_head *list);
+int acpihp_drv_cancel_start(struct list_head *list);
+int acpihp_drv_cancel_wait(struct list_head *list);
+
 #endif	/* __ACPIHP_DRV_H__ */
diff --git a/drivers/acpi/hotplug/cancel.c b/drivers/acpi/hotplug/cancel.c
new file mode 100644
index 0000000..c515c28
--- /dev/null
+++ b/drivers/acpi/hotplug/cancel.c
@@ -0,0 +1,174 @@
+/*
+ * Copyright (C) 2012 Huawei Tech. Co., Ltd.
+ * Copyright (C) 2012 Jiang Liu <jiang.liu@huawei.com>
+ * Copyright (C) 2012 Hanjun Guo <guohanjun@huawei.com>
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ */
+
+#include <linux/wait.h>
+#include <acpi/acpi_hotplug.h>
+#include "acpihp_drv.h"
+
+/*
+ * Implement interfaces to cancel inprogress hotplug operations.
+ * Currently only CONFIGURE and RELEASE operation stages support cancellation.
+ * Caller must serialize calls to following functions by holding the
+ * state_machine_mutex lock:
+ *	acpihp_drv_cancel_init()
+ *	acpihp_drv_cancel_start()
+ *	acpihp_drv_cancel_fini()
+ */
+static DECLARE_WAIT_QUEUE_HEAD(acpihp_drv_cancel_queue);
+
+static int acpihp_drv_check_cancel(struct acpihp_cancel_context *ctx)
+{
+	struct acpihp_slot_drv *drv_data;
+
+	BUG_ON(ctx == NULL);
+	drv_data = container_of(ctx, struct acpihp_slot_drv, cancel_ctx);
+
+	return atomic_read(&drv_data->cancel_state) != ACPIHP_DRV_CANCEL_INIT;
+}
+
+void acpihp_drv_cancel_init(struct list_head *list)
+{
+	struct acpihp_slot_drv *drv_data;
+	struct acpihp_slot_dependency *dep;
+
+	list_for_each_entry(dep, list, node) {
+		acpihp_drv_get_data(dep->slot, &drv_data);
+		drv_data->cancel_ctx.check_cancel = acpihp_drv_check_cancel;
+		atomic_set(&drv_data->cancel_state, ACPIHP_DRV_CANCEL_INIT);
+		atomic_set(&drv_data->cancel_users, 0);
+	}
+}
+
+/*
+ * Start cancellation on a list of hotplug slots.
+ *
+ * Caller must provide mechanism to avoid currently running
+ * acpihp_drv_cancel_start() and acpihp_drv_cancel_fini()
+ * on the same list.
+ */
+int acpihp_drv_cancel_start(struct list_head *list)
+{
+	struct acpihp_slot_drv *drv_data;
+	struct acpihp_slot_dependency *dep;
+
+	if (list_empty(list)) {
+		ACPIHP_DEBUG("dependency list is empty.\n");
+		return 0;
+	}
+
+	/* Start cancellation on all slots. */
+	list_for_each_entry(dep, list, node) {
+		acpihp_drv_get_data(dep->slot, &drv_data);
+		atomic_inc(&drv_data->cancel_users);
+		atomic_cmpxchg(&drv_data->cancel_state,
+			       ACPIHP_DRV_CANCEL_INIT,
+			       ACPIHP_DRV_CANCEL_STARTED);
+	}
+
+	return 0;
+}
+
+/* Notify that the slot reaches a stable state */
+void acpihp_drv_cancel_notify(struct acpihp_slot *slot,
+			      enum acpihp_drv_cancel_state state)
+{
+	int old;
+	struct acpihp_slot_drv *drv_data;
+
+	acpihp_drv_get_data(slot, &drv_data);
+	old = atomic_cmpxchg(&drv_data->cancel_state, ACPIHP_DRV_CANCEL_INIT,
+			     ACPIHP_DRV_CANCEL_FINISHED);
+	if (old != ACPIHP_DRV_CANCEL_INIT) {
+		atomic_set(&drv_data->cancel_state, state);
+		wake_up_all(&acpihp_drv_cancel_queue);
+	}
+}
+
+/*
+ * Wait for all slots on the list to reach a stable state and then check
+ * cancellation result.
+ */
+int acpihp_drv_cancel_wait(struct list_head *list)
+{
+	int state, result = 0;
+	struct acpihp_slot_drv *drv_data;
+	struct acpihp_slot_dependency *dep;
+
+	list_for_each_entry(dep, list, node) {
+		acpihp_drv_get_data(dep->slot, &drv_data);
+		wait_event(acpihp_drv_cancel_queue,
+			   atomic_read(&drv_data->cancel_state)
+				!= ACPIHP_DRV_CANCEL_STARTED);
+
+		state = atomic_read(&drv_data->cancel_state);
+		if (state == ACPIHP_DRV_CANCEL_FAILED) {
+			ACPIHP_SLOT_DEBUG(dep->slot,
+					  "fails to cancel operation.\n");
+			result = result ? : -EBUSY;
+		} else if (state == ACPIHP_DRV_CANCEL_MISSED) {
+			ACPIHP_SLOT_DEBUG(dep->slot,
+					  "misses to cancel operation.\n");
+			result = result ? : -EBUSY;
+		}
+
+		atomic_set(&drv_data->cancel_state,
+			   ACPIHP_DRV_CANCEL_FINISHED);
+		atomic_dec(&drv_data->cancel_users);
+		wake_up_all(&acpihp_drv_cancel_queue);
+	}
+
+	return result;
+}
+
+/*
+ * Wait for all cancellation threads to give up their reference count.
+ *
+ * Caller must provide mechanism to avoid currently running
+ * acpihp_drv_cancel_start() and acpihp_drv_cancel_fini()
+ * on the same list.
+ */
+void acpihp_drv_cancel_fini(struct list_head *list)
+{
+	int state;
+	struct acpihp_slot_drv *drv_data;
+	struct acpihp_slot_dependency *dep;
+
+	list_for_each_entry(dep, list, node) {
+		acpihp_drv_get_data(dep->slot, &drv_data);
+
+		/*
+		 * Wake up all cancellation threads if they are still
+		 * STARTED state.
+		 */
+		state = atomic_cmpxchg(&drv_data->cancel_state,
+				       ACPIHP_DRV_CANCEL_STARTED,
+				       ACPIHP_DRV_CANCEL_MISSED);
+		if (state == ACPIHP_DRV_CANCEL_STARTED)
+			wake_up_all(&acpihp_drv_cancel_queue);
+
+		/* Wait for all cancellation threads to exit */
+		wait_event(acpihp_drv_cancel_queue,
+			   !atomic_read(&drv_data->cancel_users));
+	}
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
