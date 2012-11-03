Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id D4C316B0062
	for <linux-mm@kvack.org>; Sat,  3 Nov 2012 12:08:23 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so2258335dad.14
        for <linux-mm@kvack.org>; Sat, 03 Nov 2012 09:08:23 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part1 3/4] ACPIHP: detect ACPI hotplug slots by checking ACPI _EJ0 method
Date: Sun,  4 Nov 2012 00:07:44 +0800
Message-Id: <1351958865-24394-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1351958865-24394-1-git-send-email-jiang.liu@huawei.com>
References: <1351958865-24394-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Gaohuai Han <hangaohuai@huawei.com>

This patch implements a default mechanism to detect and manage ACPI
system device hotplug slots based on standard ACPI interfaces.
1) Detech hotplug slot by checking existence of _EJ0 and _STA methods.
2) Power off a slot by evaluating _EJ0 method.

It's the default hotplug slot enumerating mechanism, platform specifc
drivers may provide advanced implementation to override the default
implementation.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Gaohuai Han <hangaohuai@huawei.com>
---
 drivers/acpi/hotplug/Makefile   |    1 +
 drivers/acpi/hotplug/acpihp.h   |    1 +
 drivers/acpi/hotplug/slot.c     |    1 +
 drivers/acpi/hotplug/slot_ej0.c |  143 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 146 insertions(+)
 create mode 100644 drivers/acpi/hotplug/slot_ej0.c

diff --git a/drivers/acpi/hotplug/Makefile b/drivers/acpi/hotplug/Makefile
index 2cbb03c..5420ae7 100644
--- a/drivers/acpi/hotplug/Makefile
+++ b/drivers/acpi/hotplug/Makefile
@@ -7,3 +7,4 @@ acpihp-y					= core.o
 
 obj-$(CONFIG_ACPI_HOTPLUG_SLOT)			+= acpihp_slot.o
 acpihp_slot-y					= slot.o
+acpihp_slot-y					+= slot_ej0.o
diff --git a/drivers/acpi/hotplug/acpihp.h b/drivers/acpi/hotplug/acpihp.h
index 7467895..278c8c2 100644
--- a/drivers/acpi/hotplug/acpihp.h
+++ b/drivers/acpi/hotplug/acpihp.h
@@ -28,5 +28,6 @@
 #include <acpi/acpi_hotplug.h>
 
 extern struct acpi_device *acpi_root;
+extern struct acpihp_slot_ops acpihp_slot_ej0;
 
 #endif
diff --git a/drivers/acpi/hotplug/slot.c b/drivers/acpi/hotplug/slot.c
index b76cb16..e5861fc 100644
--- a/drivers/acpi/hotplug/slot.c
+++ b/drivers/acpi/hotplug/slot.c
@@ -43,6 +43,7 @@ static struct acpihp_slot_ops *slot_ops_curr;
  * The first entry whose init() method returns success will be used.
  */
 static struct acpihp_slot_ops *slot_ops_array[] = {
+	&acpihp_slot_ej0,
 	NULL
 };
 
diff --git a/drivers/acpi/hotplug/slot_ej0.c b/drivers/acpi/hotplug/slot_ej0.c
new file mode 100644
index 0000000..fa987dc
--- /dev/null
+++ b/drivers/acpi/hotplug/slot_ej0.c
@@ -0,0 +1,143 @@
+/*
+ * Copyright (C) 2012 Huawei Tech. Co., Ltd.
+ * Copyright (C) 2012 Gaohuai Han <hangaohuai@huawei.com>
+ * Copyright (C) 2012 Jiang Liu <jiang.liu@huawei.com>
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or (at
+ *  your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful, but
+ *  WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License along
+ *  with this program.
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ */
+
+#include <linux/acpi.h>
+#include <acpi/acpi.h>
+#include <acpi/acpi_hotplug.h>
+
+static acpi_status acpihp_slot_ej0_capable(acpi_handle handle)
+{
+	acpi_handle tmp;
+
+	/* Assume a device object with _EJ0 and _STA is a hotplug slot. */
+	if (ACPI_FAILURE(acpi_get_handle(handle, "_EJ0", &tmp)))
+		return AE_ERROR;
+	if (ACPI_FAILURE(acpi_get_handle(handle, METHOD_NAME__STA, &tmp)))
+		return AE_ERROR;
+
+	return AE_OK;
+}
+
+static acpi_status
+acpihp_slot_ej0_check(acpi_handle handle, u32 lvl, void *context, void **rv)
+{
+	acpi_status rc = AE_OK;
+	enum acpihp_dev_type type;
+
+	if (!acpihp_dev_get_type(handle, &type)) {
+		switch (type) {
+		case ACPIHP_DEV_TYPE_CPU:
+		case ACPIHP_DEV_TYPE_MEM:
+		case ACPIHP_DEV_TYPE_HOST_BRIDGE:
+		case ACPIHP_DEV_TYPE_CONTAINER:
+			if (ACPI_SUCCESS(acpihp_slot_ej0_capable(handle))) {
+				*(int *)rv = 1;
+				rc = AE_CTRL_TERMINATE;
+			} else if (type == ACPIHP_DEV_TYPE_HOST_BRIDGE) {
+				rc = AE_CTRL_DEPTH;
+			}
+			break;
+		default:
+			break;
+		}
+	}
+
+	return rc;
+}
+
+static acpi_status acpihp_slot_ej0_init(void)
+{
+	int cap = 0;
+
+	acpi_walk_namespace(ACPI_TYPE_DEVICE, ACPI_ROOT_OBJECT,
+			ACPI_UINT32_MAX, acpihp_slot_ej0_check,
+			NULL, NULL, (void **)&cap);
+	acpi_walk_namespace(ACPI_TYPE_PROCESSOR, ACPI_ROOT_OBJECT,
+			ACPI_UINT32_MAX, acpihp_slot_ej0_check,
+			NULL, NULL, (void **)&cap);
+
+	return cap ? AE_OK : AE_ERROR;
+}
+
+static acpi_status acpihp_slot_ej0_create(struct acpihp_slot *slot)
+{
+	/*
+	 * Assume device objects with _EJ0 are capable of:
+	 * ONLINE, OFFLINE, POWEROFF, HOTPLUG
+	 */
+	slot->capabilities = ACPIHP_SLOT_CAP_ONLINE | ACPIHP_SLOT_CAP_OFFLINE |
+			     ACPIHP_SLOT_CAP_POWEROFF | ACPIHP_SLOT_CAP_HOTPLUG;
+
+	return AE_OK;
+}
+
+static acpi_status acpihp_slot_ej0_poweroff(struct acpihp_slot *slot)
+{
+	acpi_status status;
+	unsigned long long sta;
+	union acpi_object arg;
+	struct acpi_object_list arg_list;
+	acpi_handle handle = slot->handle;
+	acpi_handle dummy_handle;
+
+	if (ACPI_SUCCESS(acpi_get_handle(handle, "_PS3", &dummy_handle))) {
+		status = acpi_evaluate_object(handle, "_PS3", NULL, NULL);
+		if (ACPI_FAILURE(status)) {
+			ACPIHP_SLOT_DEBUG(slot, "fails to evaluate _PS3.\n");
+			return status;
+		}
+	}
+
+	arg_list.count = 1;
+	arg_list.pointer = &arg;
+	arg.type = ACPI_TYPE_INTEGER;
+	arg.integer.value = 1;
+	status = acpi_evaluate_object(handle, "_EJ0", &arg_list, NULL);
+	if (ACPI_FAILURE(status)) {
+		ACPIHP_SLOT_WARN(slot, "fails to power off.\n");
+		return status;
+	}
+
+	status = acpi_evaluate_integer(handle, METHOD_NAME__STA, NULL, &sta);
+	if (ACPI_FAILURE(status)) {
+		ACPIHP_SLOT_WARN(slot, "fails to evaluate _STA method\n");
+		return status;
+	}
+
+	if (sta & (ACPI_STA_DEVICE_FUNCTIONING | ACPI_STA_DEVICE_ENABLED)) {
+		ACPIHP_SLOT_WARN(slot,
+			 "object is still active after executing _EJ0.\n");
+		return AE_ERROR;
+	}
+
+	return AE_OK;
+}
+
+struct acpihp_slot_ops acpihp_slot_ej0 = {
+	.owner = THIS_MODULE,
+	.desc = "Control Hotplug Slots by ACPI _EJ0 Method",
+	.init = acpihp_slot_ej0_init,
+	.check = acpihp_slot_ej0_capable,
+	.create = acpihp_slot_ej0_create,
+	.poweroff = acpihp_slot_ej0_poweroff,
+};
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
