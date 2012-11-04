Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 65F7B6B004D
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:51:48 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3650067pbb.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:51:48 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 10/13] ACPIHP: implement the core state machine to manage hotplug slots
Date: Sun,  4 Nov 2012 20:50:12 +0800
Message-Id: <1352033415-5606-11-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

This patch implements the core of the new ACPI hotplug framework,
a state machine for ACPI hotplug slots. The state machine is:

       (plug in)     (power on)    (connect)      (configure)
 [ABSENT] <-> [PRESENT] <-> [POWERED] <-> [CONNECTED] <-> [CONFIGURED]
       (plug out)   (power off)   (disconnect)   (unconfigure)

[...]: state
(...): action
(connect): create ACPI devices and bind ACPI device drivers
(disconnect): unbind ACPI device drivers and destroy ACPI devices
(configure): allocate resources and add system device into running system
(unconfigure): remove system device from running system and free resources

It provides a simple interface to drive the state machine:
int acpihp_drv_change_state(struct acpihp_slot *slot,
			    enum acpihp_drv_cmd cmd);

It glues all hotplug logic together, including resolving dependencies
among slots, cancalling inprogress hotplug operations and configuring/
unconfigure system devices etc.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
---
 drivers/acpi/hotplug/Makefile        |    1 +
 drivers/acpi/hotplug/acpihp_drv.h    |    7 +
 drivers/acpi/hotplug/drv_main.c      |    1 +
 drivers/acpi/hotplug/state_machine.c |  639 ++++++++++++++++++++++++++++++++++
 4 files changed, 648 insertions(+)
 create mode 100644 drivers/acpi/hotplug/state_machine.c

diff --git a/drivers/acpi/hotplug/Makefile b/drivers/acpi/hotplug/Makefile
index 6cb6aa1..0f43933 100644
--- a/drivers/acpi/hotplug/Makefile
+++ b/drivers/acpi/hotplug/Makefile
@@ -15,3 +15,4 @@ acpihp_drv-y					= drv_main.o
 acpihp_drv-y					+= dependency.o
 acpihp_drv-y					+= cancel.o
 acpihp_drv-y					+= configure.o
+acpihp_drv-y					+= state_machine.o
diff --git a/drivers/acpi/hotplug/acpihp_drv.h b/drivers/acpi/hotplug/acpihp_drv.h
index aa239f6..175ef81 100644
--- a/drivers/acpi/hotplug/acpihp_drv.h
+++ b/drivers/acpi/hotplug/acpihp_drv.h
@@ -49,6 +49,7 @@ enum acpihp_drv_cancel_state {
 
 struct acpihp_slot_drv {
 	struct mutex		op_mutex;
+	struct list_head	depend_list;
 	atomic_t		cancel_state;
 	atomic_t		cancel_users;
 	struct acpihp_cancel_context	cancel_ctx;
@@ -61,6 +62,9 @@ struct acpihp_slot_dependency {
 	u32				execute_stages;
 };
 
+extern struct mutex state_machine_mutex;
+extern wait_queue_head_t acpihp_drv_event_wq;
+
 void acpihp_drv_get_data(struct acpihp_slot *slot,
 			 struct acpihp_slot_drv **data);
 int acpihp_drv_enumerate_devices(struct acpihp_slot *slot);
@@ -85,4 +89,7 @@ int acpihp_drv_cancel_wait(struct list_head *list);
 int acpihp_drv_configure(struct list_head *list);
 int acpihp_drv_unconfigure(struct list_head *list);
 
+/* The heart of the ACPI system device hotplug driver */
+int acpihp_drv_change_state(struct acpihp_slot *slot, enum acpihp_drv_cmd cmd);
+
 #endif	/* __ACPIHP_DRV_H__ */
diff --git a/drivers/acpi/hotplug/drv_main.c b/drivers/acpi/hotplug/drv_main.c
index 8ab298a..5a919e7 100644
--- a/drivers/acpi/hotplug/drv_main.c
+++ b/drivers/acpi/hotplug/drv_main.c
@@ -273,6 +273,7 @@ static int acpihp_drv_slot_add(struct device *dev, struct class_interface *intf)
 	drv_data = kzalloc(sizeof(*drv_data), GFP_KERNEL);
 	if (drv_data) {
 		mutex_init(&drv_data->op_mutex);
+		INIT_LIST_HEAD(&drv_data->depend_list);
 	}
 	if (drv_data == NULL ||
 	    acpihp_slot_attach_drv_data(slot, intf, (void *)drv_data)) {
diff --git a/drivers/acpi/hotplug/state_machine.c b/drivers/acpi/hotplug/state_machine.c
new file mode 100644
index 0000000..7604da1
--- /dev/null
+++ b/drivers/acpi/hotplug/state_machine.c
@@ -0,0 +1,639 @@
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
+#include <linux/mutex.h>
+#include <linux/wait.h>
+#include <acpi/acpi_hotplug.h>
+#include "acpihp_drv.h"
+
+/*
+ * Global lock to serialize manipulating of dependency list among hotplug slots
+ * to avoid deadlock among slots. The lock order is:
+ * 1) acquire state_machine_mutex
+ * 2) acquire drv_data->op_mutex
+ * 3) acquire slot's device lock
+ */
+DEFINE_MUTEX(state_machine_mutex);
+DECLARE_WAIT_QUEUE_HEAD(acpihp_drv_event_wq);
+
+static int acpihp_drv_lock_slot(struct acpihp_slot *slot)
+{
+	int retval = 0;
+	struct acpihp_slot_drv *drv_data;
+
+	acpihp_drv_get_data(slot, &drv_data);
+	if (!mutex_trylock(&drv_data->op_mutex)) {
+		ACPIHP_SLOT_DEBUG(slot, "slot is busy in state %d.\n",
+				  slot->state);
+		retval = -EBUSY;
+	}
+
+	return retval;
+}
+
+static void acpihp_drv_unlock_slot(struct acpihp_slot *slot)
+{
+	struct acpihp_slot_drv *drv_data;
+
+	acpihp_drv_get_data(slot, &drv_data);
+	BUG_ON(!mutex_is_locked(&drv_data->op_mutex));
+	mutex_unlock(&drv_data->op_mutex);
+}
+
+/*
+ * Lock all slots in the dependency list to serialize concurrent operations.
+ * Caller must hold state_machine_mutex.
+ */
+static int acpihp_drv_lock_slots(struct list_head *list,
+				 struct acpihp_slot *slot)
+{
+	struct acpihp_slot_dependency *dep;
+
+	list_for_each_entry(dep, list, node)
+		if (acpihp_drv_lock_slot(dep->slot))
+			goto unlock;
+
+	return 0;
+
+unlock:
+	list_for_each_entry_continue_reverse(dep, list, node)
+		acpihp_drv_unlock_slot(dep->slot);
+
+	return -EBUSY;
+}
+
+static void acpihp_drv_unlock_slots(struct list_head *list)
+{
+	struct acpihp_slot_dependency *dep;
+
+	list_for_each_entry(dep, list, node)
+		acpihp_drv_unlock_slot(dep->slot);
+}
+
+static bool acpihp_drv_is_ancestor(struct acpihp_slot *ancestor,
+				   struct acpihp_slot *slot)
+{
+	while (slot) {
+		if (slot->parent == ancestor)
+			return true;
+		slot = slot->parent;
+	};
+
+	return false;
+}
+
+/*
+ * Check whether the command is valid according to current slot state,
+ * and get required operations for this slot if command is valid.
+ */
+static int acpihp_drv_validate_transition(struct acpihp_slot_dependency *dep,
+					  struct acpihp_slot *target,
+					  enum acpihp_drv_cmd cmd)
+{
+	u32 op1, op2;
+	struct acpihp_slot *slot = dep->slot;
+
+	if (slot->state <= ACPIHP_SLOT_STATE_UNKNOWN ||
+	    slot->state >= ACPIHP_SLOT_STATE_MAX) {
+		ACPIHP_SLOT_DEBUG(slot, "invalid state %d.\n", slot->state);
+		return -EINVAL;
+	} else if (slot->state >= ACPIHP_SLOT_STATE_POWERING_ON) {
+		/*
+		 * It shouldn't happen, transcendant states are protected
+		 * by slot->op_mutex.
+		 */
+		BUG_ON(slot->state);
+		return -EINVAL;
+	}
+
+	op1 = op2 = ACPIHP_DRV_CMD_NOOP;
+	dep->opcodes = ACPIHP_DRV_CMD_NOOP;
+
+	/*
+	 * To be compatible with legacy OSes, the PCI host bridges built into
+	 * physical processor may be hosted directly under \\__SB instead of
+	 * under the CONTAINER device corresponding to physical processor.
+	 * That's really a corner case to deal with.
+	 */
+	switch (cmd) {
+	case ACPIHP_DRV_CMD_POWERON:
+		if (slot->state == ACPIHP_SLOT_STATE_ABSENT)
+			return -ENODEV;
+		else if (slot->state == ACPIHP_SLOT_STATE_PRESENT)
+			dep->opcodes = ACPIHP_DRV_CMD_POWERON;
+		break;
+
+	case ACPIHP_DRV_CMD_CONNECT:
+		/*
+		 * Its parent must have already been connected when connecting
+		 * a slot, otherwise the device tree topology becomes incorrect.
+		 */
+		if (target == slot || acpihp_drv_is_ancestor(slot, target))
+			op2 = ACPIHP_DRV_CMD_CONNECT;
+
+		if (slot->state == ACPIHP_SLOT_STATE_ABSENT)
+			return -ENODEV;
+		else if (slot->state == ACPIHP_SLOT_STATE_PRESENT)
+			dep->opcodes = ACPIHP_DRV_CMD_POWERON | op2;
+		else if (slot->state == ACPIHP_SLOT_STATE_POWERED)
+			dep->opcodes = op2;
+		break;
+
+	case ACPIHP_DRV_CMD_CONFIGURE:
+		/* Only CONFIGURE the requested slot */
+		if (slot == target)
+			op1 = ACPIHP_DRV_CMD_CONFIGURE;
+		/*
+		 * Its parent must have already been connected when configuring
+		 * a slot, otherwise the device tree topology becomes incorrect.
+		 */
+		if (target == slot || acpihp_drv_is_ancestor(slot, target))
+			op2 = ACPIHP_DRV_CMD_CONNECT;
+
+		if (slot->state == ACPIHP_SLOT_STATE_ABSENT)
+			return -ENODEV;
+		else if (slot->state == ACPIHP_SLOT_STATE_PRESENT)
+			dep->opcodes = ACPIHP_DRV_CMD_POWERON | op1 | op2;
+		else if (slot->state == ACPIHP_SLOT_STATE_POWERED)
+			dep->opcodes = op1 | op2;
+		else if (slot->state == ACPIHP_SLOT_STATE_CONNECTED)
+			dep->opcodes = op1;
+		break;
+
+	case ACPIHP_DRV_CMD_UNCONFIGURE:
+		/* Only UNCONFIGURE the requested slot */
+		if (slot->state == ACPIHP_SLOT_STATE_CONFIGURED &&
+		    slot == target)
+			dep->opcodes = ACPIHP_DRV_CMD_UNCONFIGURE;
+		break;
+
+	case ACPIHP_DRV_CMD_DISCONNECT:
+		/*
+		 * all descedant slots must be unconfigured/disconnected
+		 * when disconnecting a slot.
+		 */
+		if (target == slot || acpihp_drv_is_ancestor(target, slot)) {
+			op1 = ACPIHP_DRV_CMD_UNCONFIGURE;
+			op2 = ACPIHP_DRV_CMD_DISCONNECT;
+		}
+
+		if (slot->state == ACPIHP_SLOT_STATE_CONFIGURED)
+			dep->opcodes = op1 | op2;
+		else if (slot->state == ACPIHP_SLOT_STATE_CONNECTED)
+			dep->opcodes = op2;
+		break;
+
+	case ACPIHP_DRV_CMD_POWEROFF:
+		/*
+		 * All slots have dependency on the target slot must be
+		 * powered off when powering the target slot off.
+		 */
+		if (slot->state == ACPIHP_SLOT_STATE_CONFIGURED)
+			dep->opcodes = ACPIHP_DRV_CMD_UNCONFIGURE |
+				       ACPIHP_DRV_CMD_DISCONNECT |
+				       ACPIHP_DRV_CMD_POWEROFF;
+		else if (slot->state == ACPIHP_SLOT_STATE_CONNECTED)
+			dep->opcodes = ACPIHP_DRV_CMD_DISCONNECT |
+				       ACPIHP_DRV_CMD_POWEROFF;
+		else if (slot->state == ACPIHP_SLOT_STATE_POWERED)
+			dep->opcodes = ACPIHP_DRV_CMD_POWEROFF;
+		break;
+
+	default:
+		ACPIHP_SLOT_DEBUG(slot, "invalid command %d.\n", cmd);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int acpihp_drv_validate_command(struct list_head *list,
+		struct acpihp_slot *target, enum acpihp_drv_cmd cmd)
+{
+	int retval;
+	struct acpihp_slot *slot;
+	struct acpihp_slot_dependency *dep;
+
+	list_for_each_entry(dep, list, node) {
+		slot = dep->slot;
+		acpihp_drv_update_slot_status(slot);
+
+		retval = acpihp_drv_validate_transition(dep, target, cmd);
+		if (retval) {
+			ACPIHP_SLOT_DEBUG(slot,
+				"invalid transition for slot in state %d.\n",
+				slot->state);
+			return retval;
+		}
+
+		/* Check whether the slot is in good shape */
+		if (dep->opcodes &&
+		    acpihp_slot_get_flag(slot, ACPIHP_SLOT_FLAG_FAULT)) {
+			ACPIHP_SLOT_WARN(slot,
+					 "slot has been marked as faulty.\n");
+			return -EINVAL;
+		} else if ((dep->opcodes & ACPIHP_DRV_CMD_UNCONFIGURE) &&
+		    acpihp_slot_get_flag(slot, ACPIHP_SLOT_FLAG_IRREMOVABLE)) {
+			ACPIHP_SLOT_WARN(slot, "slot is busy.\n");
+			return -EBUSY;
+		}
+	}
+
+	return 0;
+}
+
+static int acpihp_drv_pre_execute(struct acpihp_slot *slot,
+				  enum acpihp_drv_cmd cmd,
+				  struct list_head **head)
+{
+	int retval;
+	struct list_head *list;
+	struct acpihp_slot_drv *drv_data;
+
+	acpihp_drv_get_data(slot, &drv_data);
+	mutex_lock(&state_machine_mutex);
+	*head = list = &drv_data->depend_list;
+
+	/*
+	 * Set cancellation flags on all affected slots.
+	 * All affected slots should already be on drv_data->depend_list
+	 * if there's inprogress operation for the slot.
+	 *
+	 * state_machine_mutex must be held to serialize calls to
+	 *	acpihp_drv_cancel_init(),
+	 *	acpihp_drv_cancel_start(),
+	 *	acpihp_drv_cancel_fini(),
+	 */
+	if (cmd == ACPIHP_DRV_CMD_CANCEL) {
+		retval = acpihp_drv_cancel_start(list);
+		goto out;
+	}
+
+	/* bail out if slot has already been locked to avoid deadlock */
+	if (mutex_is_locked(&drv_data->op_mutex)) {
+		ACPIHP_SLOT_DEBUG(slot, "is busy.\n");
+		retval = -EBUSY;
+		goto out;
+	}
+
+	BUG_ON(!list_empty(list));
+	retval = acpihp_drv_generate_dependency_list(slot, list, cmd);
+	if (retval) {
+		ACPIHP_SLOT_DEBUG(slot, "fails to get dependency lists.\n");
+		goto out;
+	}
+
+	retval = acpihp_drv_lock_slots(list, slot);
+	if (retval) {
+		ACPIHP_SLOT_DEBUG(slot, "fails to lock slots.\n");
+		acpihp_drv_destroy_dependency_list(list);
+		goto out;
+	}
+
+	retval = acpihp_drv_validate_command(list, slot, cmd);
+	if (retval) {
+		ACPIHP_SLOT_DEBUG(slot, "invalid command.\n");
+		acpihp_drv_unlock_slots(list);
+		acpihp_drv_destroy_dependency_list(list);
+	} else {
+		acpihp_drv_cancel_init(list);
+	}
+
+out:
+	mutex_unlock(&state_machine_mutex);
+
+	return retval;
+}
+
+static void acpihp_drv_post_execute(struct list_head *list,
+				    enum acpihp_drv_cmd cmd)
+{
+	if (cmd == ACPIHP_DRV_CMD_CANCEL)
+		return;
+
+	mutex_lock(&state_machine_mutex);
+	if (list && !list_empty(list)) {
+		acpihp_drv_cancel_fini(list);
+		acpihp_drv_unlock_slots(list);
+		acpihp_drv_destroy_dependency_list(list);
+	}
+	mutex_unlock(&state_machine_mutex);
+}
+
+static int acpihp_drv_poweron_slot(struct acpihp_slot *slot)
+{
+	acpi_status status;
+	struct acpihp_slot_drv *drv_data;
+
+	if (acpihp_slot_powered(slot))
+		return 0;
+
+	acpihp_drv_get_data(slot, &drv_data);
+
+	status = acpihp_slot_poweron(slot);
+	if (ACPI_FAILURE(status)) {
+		if (status == AE_SUPPORT)
+			return -ENOSYS;
+		else {
+			ACPIHP_SLOT_WARN(slot, "fails to power on slot.\n");
+			acpihp_slot_set_flag(slot, ACPIHP_SLOT_FLAG_FAULT);
+			return -ENXIO;
+		}
+	}
+
+	if (!acpihp_slot_powered(slot)) {
+		ACPIHP_SLOT_WARN(slot, "fails to power on.\n");
+		acpihp_slot_set_flag(slot, ACPIHP_SLOT_FLAG_FAULT);
+		return -ENXIO;
+	}
+
+	return 0;
+}
+
+static int acpihp_drv_poweron(struct list_head *list)
+{
+	int retval = 0;
+	struct acpihp_slot_dependency *dep;
+
+	list_for_each_entry(dep, list, node) {
+		if (!(dep->opcodes & ACPIHP_DRV_CMD_POWERON))
+			continue;
+
+		acpihp_slot_change_state(dep->slot,
+					 ACPIHP_SLOT_STATE_POWERING_ON);
+		retval = acpihp_drv_poweron_slot(dep->slot);
+		if (!retval) {
+			ACPIHP_SLOT_DEBUG(dep->slot, "succeed to power on!\n");
+			acpihp_slot_change_state(dep->slot,
+						 ACPIHP_SLOT_STATE_POWERED);
+		} else {
+			acpihp_slot_change_state(dep->slot,
+						 ACPIHP_SLOT_STATE_PRESENT);
+			break;
+		}
+	}
+
+	return retval;
+}
+
+static int acpihp_drv_poweroff_slot(struct acpihp_slot *slot)
+{
+	acpi_status status;
+
+	if (acpihp_slot_powered(slot))
+		return 0;
+
+	status = acpihp_slot_poweroff(slot);
+	if (ACPI_FAILURE(status)) {
+		if (status == AE_SUPPORT)
+			return -ENOSYS;
+		else {
+			ACPIHP_SLOT_WARN(slot, "fails to power off slot.\n");
+			acpihp_slot_set_flag(slot, ACPIHP_SLOT_FLAG_FAULT);
+			return -ENXIO;
+		}
+	}
+
+	if (acpihp_slot_powered(slot)) {
+		ACPIHP_SLOT_WARN(slot, "fails to power off slot.\n");
+		acpihp_slot_set_flag(slot, ACPIHP_SLOT_FLAG_FAULT);
+		return -ENXIO;
+	}
+
+	return 0;
+}
+
+static int acpihp_drv_poweroff(struct list_head *list)
+{
+	int retval = 0;
+	struct acpihp_slot_dependency *dep;
+
+	list_for_each_entry(dep, list, node) {
+		if (!(dep->opcodes & ACPIHP_DRV_CMD_POWEROFF))
+			continue;
+
+		acpihp_slot_change_state(dep->slot,
+					 ACPIHP_SLOT_STATE_POWERING_OFF);
+		retval = acpihp_drv_poweroff_slot(dep->slot);
+		if (!retval) {
+			ACPIHP_SLOT_DEBUG(dep->slot,
+					  "succeed to power off slot!\n");
+			acpihp_slot_change_state(dep->slot,
+						 ACPIHP_SLOT_STATE_PRESENT);
+		} else {
+			acpihp_slot_change_state(dep->slot,
+						 ACPIHP_SLOT_STATE_POWERED);
+			break;
+		}
+	}
+
+	return retval;
+}
+
+static int acpihp_drv_connect_slot(struct acpihp_slot *slot)
+{
+	int retval;
+
+	retval = acpihp_add_devices(slot->handle, NULL);
+	if (retval)
+		ACPIHP_SLOT_DEBUG(slot,
+				  "fails to add ACPI devices for slot.\n");
+	else {
+		retval = acpihp_drv_enumerate_devices(slot);
+		if (retval)
+			ACPIHP_SLOT_DEBUG(slot,
+				"fails to enumerate device for slot.\n");
+	}
+
+	return retval;
+}
+
+static int acpihp_drv_connect(struct list_head *list)
+{
+	int retval = 0;
+	struct acpihp_slot_dependency *dep;
+
+	list_for_each_entry(dep, list, node) {
+		if (!(dep->opcodes & ACPIHP_DRV_CMD_CONNECT))
+			continue;
+
+		acpihp_slot_change_state(dep->slot,
+					 ACPIHP_SLOT_STATE_CONNECTING);
+		retval = acpihp_drv_connect_slot(dep->slot);
+		if (!retval) {
+			ACPIHP_SLOT_DEBUG(dep->slot,
+					  "succeed to connect slot!\n");
+			acpihp_slot_change_state(dep->slot,
+						 ACPIHP_SLOT_STATE_CONNECTED);
+		} else {
+			acpihp_slot_set_flag(dep->slot, ACPIHP_SLOT_FLAG_FAULT);
+			acpihp_drv_update_slot_state(dep->slot);
+			break;
+		}
+	}
+
+	return retval;
+}
+
+static int acpihp_drv_disconnect_slot(struct acpihp_slot *slot)
+{
+	int retval = 0;
+	enum acpihp_dev_type i;
+	struct acpi_device *device = NULL;
+
+	/* remove all devices attached to a slot */
+	for (i = ACPIHP_DEV_TYPE_UNKNOWN; i < ACPIHP_DEV_TYPE_MAX; i++) {
+		retval = acpihp_remove_device_list(&slot->dev_lists[i]);
+		if (retval) {
+			ACPIHP_SLOT_DEBUG(slot,
+					  "fails to remove ACPI devices.\n");
+			return retval;
+		}
+	}
+
+	/* remove ACPI devices */
+	retval = acpi_bus_get_device(slot->handle, &device);
+	if (!retval && device) {
+		retval = acpi_bus_trim(device, 1);
+		if (retval)
+			ACPIHP_SLOT_WARN(slot,
+					 "fails to remove ACPI devices.\n");
+	} else {
+		ACPIHP_SLOT_WARN(slot, "fails to get ACPI device for slot.\n");
+		retval = -ENXIO;
+	}
+
+	return retval;
+}
+
+static int acpihp_drv_disconnect(struct list_head *list)
+{
+	int retval = 0;
+	struct acpihp_slot_dependency *dep;
+
+	list_for_each_entry(dep, list, node) {
+		if (!(dep->opcodes & ACPIHP_DRV_CMD_DISCONNECT))
+			continue;
+
+		acpihp_slot_change_state(dep->slot,
+					 ACPIHP_SLOT_STATE_DISCONNECTING);
+		retval = acpihp_drv_disconnect_slot(dep->slot);
+		if (!retval) {
+			ACPIHP_SLOT_DEBUG(dep->slot,
+					  "succeed to disconnect slot!\n");
+			acpihp_slot_change_state(dep->slot,
+						 ACPIHP_SLOT_STATE_POWERED);
+		} else {
+			acpihp_slot_set_flag(dep->slot, ACPIHP_SLOT_FLAG_FAULT);
+			acpihp_drv_update_slot_state(dep->slot);
+			break;
+		}
+	}
+
+	return retval;
+}
+
+static int acpihp_drv_execute(struct list_head *list, enum acpihp_drv_cmd cmd)
+{
+	int retval = 0;
+	bool connect = false, configure = false;
+	bool disconnect = false, poweroff = false;
+
+	if (!list || list_empty(list)) {
+		ACPIHP_DEBUG("slot dependency list is NULL or empty!\n");
+		retval = -EINVAL;
+		goto out;
+	}
+
+	switch (cmd) {
+	case ACPIHP_DRV_CMD_CONFIGURE:
+		configure = true;
+		/* fall through */
+	case ACPIHP_DRV_CMD_CONNECT:
+		connect = true;
+		/* fall through */
+	case ACPIHP_DRV_CMD_POWERON:
+		retval = acpihp_drv_poweron(list);
+		if (!retval && connect)
+			retval = acpihp_drv_connect(list);
+		if (!retval && configure)
+			retval = acpihp_drv_configure(list);
+		break;
+
+	case ACPIHP_DRV_CMD_POWEROFF:
+		poweroff = true;
+		/* fall through */
+	case ACPIHP_DRV_CMD_DISCONNECT:
+		disconnect = true;
+		/* fall through */
+	case ACPIHP_DRV_CMD_UNCONFIGURE:
+		retval = acpihp_drv_unconfigure(list);
+		if (!retval && disconnect)
+			retval = acpihp_drv_disconnect(list);
+		if (!retval && poweroff)
+			retval = acpihp_drv_poweroff(list);
+		break;
+
+	case ACPIHP_DRV_CMD_CANCEL:
+		retval = acpihp_drv_cancel_wait(list);
+		break;
+
+	default:
+		ACPIHP_DEBUG("unsupported command %d.\n", cmd);
+		retval = -EINVAL;
+		break;
+	}
+
+out:
+	return retval;
+}
+
+/*
+ * The heart of ACPI based system device hotplug driver, which implements
+ * a state machine as below for hotplug slots.
+ *
+ *       (plug in)     (power on)    (connect)      (configure)
+ * [ABSENT] <-> [PRESENT] <-> [POWERED] <-> [CONNECTED] <-> [CONFIGURED]
+ *       (plug out)   (power off)   (disconnect)   (unconfigure)
+ *
+ * [...]: state
+ * (...): action
+ * (connect): create ACPI devices and bind ACPI device drivers
+ * (disconnect): unbind ACPI device drivers and destroy ACPI devices
+ * (configure): allocate resources and add system device into running system
+ * (unconfigure): remove system device from running system and free resources
+ */
+int acpihp_drv_change_state(struct acpihp_slot *slot, enum acpihp_drv_cmd cmd)
+{
+	int retval;
+	struct list_head *list = NULL;
+
+	retval = acpihp_drv_pre_execute(slot, cmd, &list);
+	if (!retval) {
+		retval = acpihp_drv_execute(list, cmd);
+		acpihp_drv_post_execute(list, cmd);
+	}
+
+	return retval;
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
