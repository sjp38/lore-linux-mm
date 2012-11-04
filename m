Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 127A26B0062
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:52:06 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so2498174dad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:52:05 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 12/13] ACPIHP: implement sysfs interfaces for system device hotplug
Date: Sun,  4 Nov 2012 20:50:14 +0800
Message-Id: <1352033415-5606-13-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

This patch implements sysfs interfaces to access system device hotplug
functionalities. These sysfs interfaces are mainly used to drive the
hotplug slot state machine as below:
 [ABSENT] <-> [PRESENT] <-> [POWERED] <-> [CONNECTED] <-> [CONFIGURED]

[ABSENT]: no devices attached to the hotplug slot
[PRESENT]: devices physically attached to the hotplug slot
[POWERED]: devices attached to the hotplug slot are powered
[CONNECTED]: ACPI device objects have been created for devices attached
	     to the hotplug slot
[CONFIGURED]: devices attached to the slot are in use by system

Two sysfs interfaces have been implemented as below:
SLOT/dependency: show dependency relationship among hotplug slots
SLOT/control: trigger system device hotplug operations
	read from control sysfs file gives some help messages and you may
	write following commands to it:
	poweron: transit to POWERED from PRESENT
	connect: transit to CONNECTED from PRESENT/POWERED
	configure: transit to CONFIGURED from PRESENT/POWERED/CONNECTED
	unconfigure: transit to CONNECTED from CONFIGURED
	disconnect: transit to POWERED from CONFIGURED/CONNECTED
	poweroff: transit PRESENT from CONFIGURED/CONNECTED/POWERED
	enable, 1: the same as configure
	disable, 0: the same as poweroff
	cancel: cancel inprogress hotplug operations

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
---
 drivers/acpi/hotplug/Makefile     |    1 +
 drivers/acpi/hotplug/acpihp_drv.h |    3 +
 drivers/acpi/hotplug/drv_main.c   |    5 +
 drivers/acpi/hotplug/sysfs.c      |  181 +++++++++++++++++++++++++++++++++++++
 4 files changed, 190 insertions(+)
 create mode 100644 drivers/acpi/hotplug/sysfs.c

diff --git a/drivers/acpi/hotplug/Makefile b/drivers/acpi/hotplug/Makefile
index 0f43933..57e348a 100644
--- a/drivers/acpi/hotplug/Makefile
+++ b/drivers/acpi/hotplug/Makefile
@@ -16,3 +16,4 @@ acpihp_drv-y					+= dependency.o
 acpihp_drv-y					+= cancel.o
 acpihp_drv-y					+= configure.o
 acpihp_drv-y					+= state_machine.o
+acpihp_drv-y					+= sysfs.o
diff --git a/drivers/acpi/hotplug/acpihp_drv.h b/drivers/acpi/hotplug/acpihp_drv.h
index 175ef81..2ec2547 100644
--- a/drivers/acpi/hotplug/acpihp_drv.h
+++ b/drivers/acpi/hotplug/acpihp_drv.h
@@ -92,4 +92,7 @@ int acpihp_drv_unconfigure(struct list_head *list);
 /* The heart of the ACPI system device hotplug driver */
 int acpihp_drv_change_state(struct acpihp_slot *slot, enum acpihp_drv_cmd cmd);
 
+int acpihp_drv_create_sysfs(struct acpihp_slot *slot);
+void acpihp_drv_remove_sysfs(struct acpihp_slot *slot);
+
 #endif	/* __ACPIHP_DRV_H__ */
diff --git a/drivers/acpi/hotplug/drv_main.c b/drivers/acpi/hotplug/drv_main.c
index 5a919e7..bd5c97c 100644
--- a/drivers/acpi/hotplug/drv_main.c
+++ b/drivers/acpi/hotplug/drv_main.c
@@ -284,6 +284,10 @@ static int acpihp_drv_slot_add(struct device *dev, struct class_interface *intf)
 		return -ENOMEM;
 	}
 
+	if (acpihp_drv_create_sysfs(slot))
+		ACPIHP_SLOT_DEBUG(slot,
+			"fails to create sysfs interfaces, some functions will not be available to user.\n");
+
 	return 0;
 }
 
@@ -294,6 +298,7 @@ static void acpihp_drv_intf_remove(struct device *dev,
 	struct acpihp_slot *slot =
 			container_of(dev, struct acpihp_slot, dev);
 
+	acpihp_drv_remove_sysfs(slot);
 	acpihp_drv_uninstall_handler(slot);
 	acpihp_drv_remove_devices(slot);
 	acpihp_slot_detach_drv_data(slot, intf, (void **)&drv_data);
diff --git a/drivers/acpi/hotplug/sysfs.c b/drivers/acpi/hotplug/sysfs.c
new file mode 100644
index 0000000..4519eea
--- /dev/null
+++ b/drivers/acpi/hotplug/sysfs.c
@@ -0,0 +1,181 @@
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
+#include <linux/device.h>
+#include <linux/mutex.h>
+#include <acpi/acpi_hotplug.h>
+#include "acpihp_drv.h"
+
+static ssize_t acpihp_drv_control_show(struct device *dev,
+		struct device_attribute *attr, char *page)
+{
+	ssize_t off;
+	struct acpihp_slot *slot = container_of(dev, struct acpihp_slot, dev);
+
+	off = snprintf(page, PAGE_SIZE, "supported commands:\n");
+	if (slot->capabilities & ACPIHP_SLOT_CAP_POWERON)
+		off += snprintf(page + off, PAGE_SIZE - off,
+				"\tpoweron: power on the hotplug slot\n");
+	off += snprintf(page + off, PAGE_SIZE - off,
+			"\tconnect: create ACPI device nodes and bind ACPI device drivers\n");
+	off += snprintf(page + off, PAGE_SIZE - off,
+			"\tconfigure: put system devices into running state\n");
+	off += snprintf(page + off, PAGE_SIZE - off,
+			"\tunconfigure: stop system devices from running state\n");
+	off += snprintf(page + off, PAGE_SIZE - off,
+			"\tdisconnect: unbind ACPI device drivers and destroy ACPI device nodes\n");
+	if (slot->capabilities & ACPIHP_SLOT_CAP_POWEROFF)
+		off += snprintf(page + off, PAGE_SIZE - off,
+				"\tpoweroff: power off the hotplug slot\n");
+	off += snprintf(page + off, PAGE_SIZE - off,
+			"\tcancel: cancel inprogress hotplug operations\n");
+	off += snprintf(page + off, PAGE_SIZE - off,
+			"\tenable, 1: the same as configure\n");
+	off += snprintf(page + off, PAGE_SIZE - off,
+			"\tdisable, 0: the same as poweroff\n");
+
+	return off;
+}
+
+static ssize_t acpihp_drv_control_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	int result = -EINVAL;
+	char *temp, *pos, *token;
+	enum acpihp_drv_cmd cmd = ACPIHP_DRV_CMD_NOOP;
+	struct acpihp_slot *slot = container_of(dev, struct acpihp_slot, dev);
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	temp = pos = kstrndup(buf, PAGE_SIZE - 1, GFP_KERNEL);
+	if (!temp)
+		return -ENOMEM;
+
+	token = strsep(&pos, " \t\r\n");
+	if (!token)
+		goto out;
+
+	if (!strcmp(token, "enable"))
+		cmd = ACPIHP_DRV_CMD_CONFIGURE;
+	else if (!strcmp(token, "1"))
+		cmd = ACPIHP_DRV_CMD_CONFIGURE;
+	else if (!strcmp(token, "disable"))
+		cmd = ACPIHP_DRV_CMD_POWEROFF;
+	else if (!strcmp(token, "0"))
+		cmd = ACPIHP_DRV_CMD_POWEROFF;
+	else if (!strcmp(token, "connect"))
+		cmd = ACPIHP_DRV_CMD_CONNECT;
+	else if (!strcmp(token, "configure"))
+		cmd = ACPIHP_DRV_CMD_CONFIGURE;
+	else if (!strcmp(token, "unconfigure"))
+		cmd = ACPIHP_DRV_CMD_UNCONFIGURE;
+	else if (!strcmp(token, "disconnect"))
+		cmd = ACPIHP_DRV_CMD_DISCONNECT;
+	else if (!strcmp(token, "cancel"))
+		cmd = ACPIHP_DRV_CMD_CANCEL;
+	else if (!strcmp(token, "poweron")) {
+		if (slot->capabilities & ACPIHP_SLOT_CAP_POWERON)
+			cmd = ACPIHP_DRV_CMD_POWERON;
+	} else if (!strcmp(token, "poweroff")) {
+		if (slot->capabilities & ACPIHP_SLOT_CAP_POWEROFF)
+			cmd = ACPIHP_DRV_CMD_POWEROFF;
+	}
+
+	if (cmd != ACPIHP_DRV_CMD_NOOP)
+		result = acpihp_drv_change_state(slot, cmd);
+out:
+	kfree(temp);
+
+	return result < 0 ? result : count;
+}
+
+static DEVICE_ATTR(control, S_IRUGO | S_IWUSR,
+	    &acpihp_drv_control_show, &acpihp_drv_control_store);
+
+static ssize_t acpihp_drv_dependency_show(struct device *dev,
+		struct device_attribute *attr, char *page)
+{
+	int ret;
+	char *p, *end;
+	struct list_head list;
+	enum acpihp_drv_cmd cmd;
+	struct acpihp_slot_dependency *dep;
+	struct acpihp_slot *slot = container_of(dev, struct acpihp_slot, dev);
+
+	INIT_LIST_HEAD(&list);
+	mutex_lock(&state_machine_mutex);
+	cmd = acpihp_slot_powered(slot) ? ACPIHP_DRV_CMD_POWEROFF :
+					  ACPIHP_DRV_CMD_POWERON;
+	ret = acpihp_drv_generate_dependency_list(slot, &list, cmd);
+	if (ret) {
+		ret = -ENXIO;
+	} else {
+		p = page;
+		end = page + PAGE_SIZE;
+
+		list_for_each_entry(dep, &list, node) {
+			if (dep->slot == slot)
+				continue;
+			if (p + strlen(dep->slot->name) + 2 >= end)
+				break;
+			p += snprintf(p, end - p, "%s\n", dep->slot->name);
+		}
+
+		acpihp_drv_destroy_dependency_list(&list);
+		ret = p - page;
+	}
+	mutex_unlock(&state_machine_mutex);
+
+	return ret;
+}
+
+static DEVICE_ATTR(dependency, S_IRUGO,
+		   &acpihp_drv_dependency_show, NULL);
+
+int acpihp_drv_create_sysfs(struct acpihp_slot *slot)
+{
+	int retval;
+	struct device *dev = &slot->dev;
+
+	retval = device_create_file(dev, &dev_attr_control);
+	if (retval)
+		goto out;
+	retval = device_create_file(dev, &dev_attr_dependency);
+	if (!retval)
+		return 0;
+
+	device_remove_file(dev, &dev_attr_control);
+out:
+	ACPIHP_SLOT_DEBUG(slot, "fails to create sysfs interfaces for slot.\n");
+	return retval;
+}
+
+void acpihp_drv_remove_sysfs(struct acpihp_slot *slot)
+{
+	struct device *dev = &slot->dev;
+
+	device_remove_file(dev, &dev_attr_dependency);
+	device_remove_file(dev, &dev_attr_control);
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
