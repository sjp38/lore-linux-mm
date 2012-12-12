Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 5FB046B0093
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:27:10 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 03/11] cpu: Add cpu hotplug handlers
Date: Wed, 12 Dec 2012 16:17:15 -0700
Message-Id: <1355354243-18657-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

Added cpu hotplug handlers.  cpu_add_execute() onlines requested
cpus for hot-add and online operations, and cpu_del_execute() 
offlines them for hot-delete and offline operations.  They are
also used for rollback as well.

cpu_del_validate() fails a request if cpu0 is requested to delete.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 drivers/base/cpu.c | 95 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 95 insertions(+)

diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
index 6345294..3870231 100644
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -13,6 +13,8 @@
 #include <linux/gfp.h>
 #include <linux/slab.h>
 #include <linux/percpu.h>
+#include <linux/list.h>
+#include <linux/hotplug.h>
 
 #include "base.h"
 
@@ -324,10 +326,103 @@ static void __init cpu_dev_register_generic(void)
 #endif
 }
 
+#ifdef CONFIG_HOTPLUG_CPU
+static int cpu_del_execute(struct hp_request *req, int rollback);
+
+static int cpu_add_execute(struct hp_request *req, int rollback)
+{
+	struct hp_device *hp_dev;
+	u32 cpu;
+	int ret;
+
+	if (rollback)
+		return cpu_del_execute(req, 0);
+
+	list_for_each_entry(hp_dev, &req->dev_list, list) {
+		if (hp_dev->class != HP_CLS_CPU)
+			continue;
+
+		cpu = hp_dev->data.cpu.cpu_id;
+
+		if (cpu_online(cpu))
+			continue;
+
+		ret = cpu_up(cpu);
+		/* REVISIT: need a way to set a cpu dev for hot-plug op */
+		if (!ret && hp_is_online_op(req->operation))
+			kobject_uevent(&hp_dev->device->kobj, KOBJ_ONLINE);
+	}
+
+	return 0;
+}
+
+static int cpu_del_validate(struct hp_request *req, int rollback)
+{
+	struct hp_device *hp_dev;
+
+	if (rollback)
+		return 0;
+
+	list_for_each_entry(hp_dev, &req->dev_list, list) {
+		if (hp_dev->class != HP_CLS_CPU)
+			continue;
+
+		/*
+		 * cpu 0 cannot be offlined.  This check can be removed when
+		 * cpu 0 offline is supported.
+		 */
+		if (hp_dev->data.cpu.cpu_id == 0)
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int cpu_del_execute(struct hp_request *req, int rollback)
+{
+	struct hp_device *hp_dev;
+	u32 cpu;
+	int ret;
+
+	if (rollback)
+		return cpu_add_execute(req, 0);
+
+	list_for_each_entry(hp_dev, &req->dev_list, list) {
+		if (hp_dev->class != HP_CLS_CPU)
+			continue;
+
+		cpu = hp_dev->data.cpu.cpu_id;
+
+		if (!cpu_online(cpu))
+			continue;
+
+		ret = cpu_down(cpu);
+		/* REVISIT: need a way to set a cpu dev for hot-plug op */
+		if (!ret && hp_is_online_op(req->operation))
+			kobject_uevent(&hp_dev->device->kobj, KOBJ_OFFLINE);
+	}
+
+	return 0;
+}
+
+static void __init cpu_hp_init(void)
+{
+	hp_register_handler(HP_ADD_EXECUTE, cpu_add_execute,
+				HP_CPU_ADD_EXECUTE_ORDER);
+	hp_register_handler(HP_DEL_VALIDATE, cpu_del_validate,
+				HP_CPU_DEL_VALIDATE_ORDER);
+	hp_register_handler(HP_DEL_EXECUTE, cpu_del_execute,
+				HP_CPU_DEL_EXECUTE_ORDER);
+}
+#endif	/* CONFIG_HOTPLUG_CPU */
+
 void __init cpu_dev_init(void)
 {
 	if (subsys_system_register(&cpu_subsys, cpu_root_attr_groups))
 		panic("Failed to register CPU subsystem");
 
 	cpu_dev_register_generic();
+#ifdef CONFIG_HOTPLUG_CPU
+	cpu_hp_init();
+#endif
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
