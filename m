Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 67E9D6B0062
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 10:24:40 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so2531187dad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 07:24:40 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part4 4/9] ACPIHP/processor: enhance processor driver to support new hotplug framework
Date: Sun,  4 Nov 2012 23:23:57 +0800
Message-Id: <1352042642-7306-5-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
References: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

Refine ACPI processor driver to support new ACPI system device hotplug
framework with following changes:
1) Remove code to handle ACPI hotplug events from ACPI processor
   driver, now hotplug events will be handled by the framework.
2) Provides callbacks for the framework to add CPU into or remove CPU
   from running system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
---
 drivers/acpi/Kconfig            |   11 +-
 drivers/acpi/processor_driver.c |  336 +++++++++++++--------------------------
 2 files changed, 114 insertions(+), 233 deletions(-)

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 05f0a22..a8f8f75 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -206,12 +206,6 @@ config ACPI_IPMI
 	  To compile this driver as a module, choose M here:
 	  the module will be called as acpi_ipmi.
 
-config ACPI_HOTPLUG_CPU
-	bool
-	depends on EXPERIMENTAL && ACPI_PROCESSOR && HOTPLUG_CPU
-	select ACPI_CONTAINER
-	default y
-
 config ACPI_PROCESSOR_AGGREGATOR
 	tristate "Processor Aggregator"
 	depends on ACPI_PROCESSOR
@@ -378,6 +372,11 @@ config ACPI_HOTPLUG_DRIVER
 	  To compile this driver as a module, choose M here:
 	  the module will be called acpihp_drv.
 
+config ACPI_HOTPLUG_CPU
+	bool
+	depends on ACPI_HOTPLUG && ACPI_PROCESSOR && HOTPLUG_CPU
+	default y
+
 config ACPI_CONTAINER
 	tristate "Container and Module Devices (EXPERIMENTAL)"
 	depends on ACPI_HOTPLUG
diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
index 7d6d794..b8c3684 100644
--- a/drivers/acpi/processor_driver.c
+++ b/drivers/acpi/processor_driver.c
@@ -56,6 +56,7 @@
 #include <acpi/acpi_bus.h>
 #include <acpi/acpi_drivers.h>
 #include <acpi/processor.h>
+#include <acpi/acpi_hotplug.h>
 
 #define PREFIX "ACPI: "
 
@@ -76,9 +77,10 @@ MODULE_LICENSE("GPL");
 static int acpi_processor_add(struct acpi_device *device);
 static int acpi_processor_remove(struct acpi_device *device, int type);
 static void acpi_processor_notify(struct acpi_device *device, u32 event);
-static acpi_status acpi_processor_hotadd_init(struct acpi_processor *pr);
-static int acpi_processor_handle_eject(struct acpi_processor *pr);
 static int acpi_processor_start(struct acpi_processor *pr);
+#ifdef	CONFIG_ACPI_HOTPLUG_CPU
+static struct acpihp_dev_ops acpi_processor_hp_ops;
+#endif
 
 static const struct acpi_device_id processor_device_ids[] = {
 	{ACPI_PROCESSOR_OBJECT_HID, 0},
@@ -98,13 +100,13 @@ static struct acpi_driver acpi_processor_driver = {
 		.add = acpi_processor_add,
 		.remove = acpi_processor_remove,
 		.notify = acpi_processor_notify,
-		},
+#ifdef CONFIG_ACPI_HOTPLUG_CPU
+		.hp_ops = &acpi_processor_hp_ops,
+#endif
+	},
 	.drv.pm = &acpi_processor_pm,
 };
 
-#define INSTALL_NOTIFY_HANDLER		1
-#define UNINSTALL_NOTIFY_HANDLER	2
-
 static DEFINE_PER_CPU(void *, processor_device_array);
 
 DEFINE_PER_CPU(struct acpi_processor *, processors);
@@ -314,15 +316,6 @@ static int acpi_processor_get_info(struct acpi_device *device)
 	pr->id = cpu_index;
 
 	/*
-	 *  Extra Processor objects may be enumerated on MP systems with
-	 *  less than the max # of CPUs. They should be ignored _iff
-	 *  they are physically not present.
-	 */
-	if (pr->id == -1) {
-		if (ACPI_FAILURE(acpi_processor_hotadd_init(pr)))
-			return -ENODEV;
-	}
-	/*
 	 * On some boxes several processors use the same processor bus id.
 	 * But they are located in different scope. For example:
 	 * \_SB.SCK0.CPU0
@@ -649,20 +642,12 @@ static int acpi_processor_remove(struct acpi_device *device, int type)
 		return -EINVAL;
 
 	pr = acpi_driver_data(device);
-	if (pr->id >= nr_cpu_ids)
-		goto free;
-
-	if (type == ACPI_BUS_REMOVAL_EJECT) {
-		if (acpi_processor_handle_eject(pr))
-			return -EINVAL;
-	}
 
 	get_online_cpus();
 	acpi_processor_stop(device, pr);
 	acpi_processor_unlink(device, pr);
 	put_online_cpus();
 
-free:
 	device->driver_data = NULL;
 	free_cpumask_var(pr->throttling.shared_cpu_map);
 	kfree(pr);
@@ -675,258 +660,155 @@ free:
  * 	Acpi processor hotplug support 				       	    *
  ****************************************************************************/
 
-static int is_processor_present(acpi_handle handle)
+static void acpi_processor_reset(struct acpi_device *device, struct acpi_processor *pr)
 {
-	acpi_status status;
-	unsigned long long sta = 0;
-
-
-	status = acpi_evaluate_integer(handle, "_STA", NULL, &sta);
-
-	if (ACPI_SUCCESS(status) && (sta & ACPI_STA_DEVICE_PRESENT))
-		return 1;
-
-	/*
-	 * _STA is mandatory for a processor that supports hot plug
-	 */
-	if (status == AE_NOT_FOUND)
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-				"Processor does not support hot plug\n"));
-	else
-		ACPI_EXCEPTION((AE_INFO, status,
-				"Processor Device is not present"));
-	return 0;
+	get_online_cpus();
+	acpi_processor_unlink(device, pr);
+	put_online_cpus();
+	arch_unregister_cpu(pr->id);
+	acpi_unmap_lsapic(pr->id);
+	pr->id = -1;
 }
 
-static
-int acpi_processor_device_add(acpi_handle handle, struct acpi_device **device)
+static int acpi_processor_get_dev_info(struct acpi_device *device,
+				       struct acpihp_dev_info *info)
 {
-	acpi_handle phandle;
-	struct acpi_device *pdev;
-
-
-	if (acpi_get_parent(handle, &phandle)) {
-		return -ENODEV;
-	}
+	struct acpi_processor *pr;
 
-	if (acpi_bus_get_device(phandle, &pdev)) {
-		return -ENODEV;
-	}
+	if (!device || !acpi_driver_data(device))
+		return -EINVAL;
+	pr = acpi_driver_data(device);
 
-	if (acpi_bus_add(device, pdev, handle, ACPI_BUS_TYPE_PROCESSOR)) {
-		return -ENODEV;
-	}
+	info->type = ACPIHP_DEV_TYPE_CPU;
+	if (pr->id >= 0)
+		info->status |= ACPIHP_DEV_STATUS_STARTED;
 
 	return 0;
 }
 
-static void acpi_processor_hotplug_notify(acpi_handle handle,
-					  u32 event, void *data)
+static int acpi_processor_pre_configure(struct acpi_device *device,
+					struct acpihp_cancel_context *ctx)
 {
-	struct acpi_processor *pr;
-	struct acpi_device *device = NULL;
-	u32 ost_code = ACPI_OST_SC_NON_SPECIFIC_FAILURE; /* default */
 	int result;
+	struct acpi_processor *pr;
 
-	switch (event) {
-	case ACPI_NOTIFY_BUS_CHECK:
-	case ACPI_NOTIFY_DEVICE_CHECK:
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-		"Processor driver received %s event\n",
-		       (event == ACPI_NOTIFY_BUS_CHECK) ?
-		       "ACPI_NOTIFY_BUS_CHECK" : "ACPI_NOTIFY_DEVICE_CHECK"));
-
-		if (!is_processor_present(handle))
-			break;
-
-		if (!acpi_bus_get_device(handle, &device))
-			break;
+	if (!device || !acpi_driver_data(device))
+		return -EINVAL;
+	pr = acpi_driver_data(device);
 
-		result = acpi_processor_device_add(handle, &device);
+	/* Generate CPUID for hot-added CPUs */
+	if (pr->id == -1) {
+		result = acpi_map_lsapic(device->handle, &pr->id);
+		if (result)
+			return result;
+		BUG_ON((pr->id >= nr_cpu_ids) || (pr->id < 0));
+		result = arch_register_cpu(pr->id);
 		if (result) {
-			printk(KERN_ERR PREFIX "Unable to add the device\n");
-			break;
+			acpi_unmap_lsapic(pr->id);
+			pr->id = -1;
+			return result;
 		}
 
-		ost_code = ACPI_OST_SC_SUCCESS;
-		break;
-
-	case ACPI_NOTIFY_EJECT_REQUEST:
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-				  "received ACPI_NOTIFY_EJECT_REQUEST\n"));
-
-		if (acpi_bus_get_device(handle, &device)) {
-			printk(KERN_ERR PREFIX
-				    "Device don't exist, dropping EJECT\n");
-			break;
-		}
-		pr = acpi_driver_data(device);
-		if (!pr) {
-			printk(KERN_ERR PREFIX
-				    "Driver data is NULL, dropping EJECT\n");
-			break;
-		}
-
-		/* REVISIT: update when eject is supported */
-		ost_code = ACPI_OST_SC_EJECT_NOT_SUPPORTED;
-		break;
-
-	default:
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-				  "Unsupported event [0x%x]\n", event));
-
-		/* non-hotplug event; possibly handled by other handler */
-		return;
+		/*
+		 * CPU got hot-plugged, but cpu_data is not initialized yet.
+		 * Set flag to let acpi_cpu_soft_notify() initialize cpu_data
+		 * by calling acpi_processor_start
+		 */
+		pr->flags.need_hotplug_init = 1;
+		dev_info(&device->dev, "CPU %d got hotplugged\n", pr->id);
 	}
 
-	/* Inform firmware that the hotplug operation has completed */
-	(void) acpi_evaluate_hotplug_ost(handle, event, ost_code, NULL);
-	return;
+	return 0;
 }
 
-static acpi_status is_processor_device(acpi_handle handle)
+static int acpi_processor_configure(struct acpi_device *device,
+				    struct acpihp_cancel_context *ctx)
 {
-	struct acpi_device_info *info;
-	char *hid;
-	acpi_status status;
-
-	status = acpi_get_object_info(handle, &info);
-	if (ACPI_FAILURE(status))
-		return status;
-
-	if (info->type == ACPI_TYPE_PROCESSOR) {
-		kfree(info);
-		return AE_OK;	/* found a processor object */
-	}
+	int result;
+	struct acpi_processor *pr;
 
-	if (!(info->valid & ACPI_VALID_HID)) {
-		kfree(info);
-		return AE_ERROR;
-	}
+	if (!device || !acpi_driver_data(device))
+		return -EINVAL;
+	pr = acpi_driver_data(device);
 
-	hid = info->hardware_id.string;
-	if ((hid == NULL) || strcmp(hid, ACPI_PROCESSOR_DEVICE_HID)) {
-		kfree(info);
-		return AE_ERROR;
-	}
+	get_online_cpus();
+	result = acpi_processor_link(device, pr);
+	put_online_cpus();
 
-	kfree(info);
-	return AE_OK;	/* found a processor device object */
+	return result;
 }
 
-static acpi_status
-processor_walk_namespace_cb(acpi_handle handle,
-			    u32 lvl, void *context, void **rv)
+static void acpi_processor_post_configure(struct acpi_device *device,
+					  enum acpihp_dev_post_cmd cmd)
 {
-	acpi_status status;
-	int *action = context;
-
-	status = is_processor_device(handle);
-	if (ACPI_FAILURE(status))
-		return AE_OK;	/* not a processor; continue to walk */
-
-	switch (*action) {
-	case INSTALL_NOTIFY_HANDLER:
-		acpi_install_notify_handler(handle,
-					    ACPI_SYSTEM_NOTIFY,
-					    acpi_processor_hotplug_notify,
-					    NULL);
-		break;
-	case UNINSTALL_NOTIFY_HANDLER:
-		acpi_remove_notify_handler(handle,
-					   ACPI_SYSTEM_NOTIFY,
-					   acpi_processor_hotplug_notify);
-		break;
-	default:
-		break;
-	}
+	struct acpi_processor *pr;
+
+	BUG_ON(!device || !acpi_driver_data(device));
+	pr = acpi_driver_data(device);
 
-	/* found a processor; skip walking underneath */
-	return AE_CTRL_DEPTH;
+	if (cmd == ACPIHP_DEV_POST_CMD_COMMIT) {
+		if (!cpu_online(pr->id) && cpu_up(pr->id))
+			dev_warn(&device->dev,
+				 "fails to online CPU%d.\n", pr->id);
+	} else if (cmd == ACPIHP_DEV_POST_CMD_ROLLBACK)
+		acpi_processor_reset(device, pr);
 }
 
-static acpi_status acpi_processor_hotadd_init(struct acpi_processor *pr)
+static int acpi_processor_release(struct acpi_device *device,
+				  struct acpihp_cancel_context *ctx)
 {
-	acpi_handle handle = pr->handle;
-
-	if (!is_processor_present(handle)) {
-		return AE_ERROR;
-	}
-
-	if (acpi_map_lsapic(handle, &pr->id))
-		return AE_ERROR;
+	int result = 0;
+	struct acpi_processor *pr;
 
-	if (arch_register_cpu(pr->id)) {
-		acpi_unmap_lsapic(pr->id);
-		return AE_ERROR;
-	}
+	if (!device || !acpi_driver_data(device))
+		return -EINVAL;
+	pr = acpi_driver_data(device);
 
-	/* CPU got hot-plugged, but cpu_data is not initialized yet
-	 * Set flag to delay cpu_idle/throttling initialization
-	 * in:
-	 * acpi_processor_add()
-	 *   acpi_processor_get_info()
-	 * and do it when the CPU gets online the first time
-	 * TBD: Cleanup above functions and try to do this more elegant.
-	 */
-	printk(KERN_INFO "CPU %d got hotplugged\n", pr->id);
-	pr->flags.need_hotplug_init = 1;
+	if (cpu_online(pr->id))
+		result = cpu_down(pr->id);
 
-	return AE_OK;
+	return result;
 }
 
-static int acpi_processor_handle_eject(struct acpi_processor *pr)
+static void acpi_processor_post_release(struct acpi_device *device,
+				        enum acpihp_dev_post_cmd cmd)
 {
-	if (cpu_online(pr->id))
-		cpu_down(pr->id);
+	struct acpi_processor *pr;
 
-	arch_unregister_cpu(pr->id);
-	acpi_unmap_lsapic(pr->id);
-	return (0);
-}
-#else
-static acpi_status acpi_processor_hotadd_init(struct acpi_processor *pr)
-{
-	return AE_ERROR;
-}
-static int acpi_processor_handle_eject(struct acpi_processor *pr)
-{
-	return (-EINVAL);
-}
-#endif
+	BUG_ON(!device || !acpi_driver_data(device));
+	pr = acpi_driver_data(device);
 
-static
-void acpi_processor_install_hotplug_notify(void)
-{
-#ifdef CONFIG_ACPI_HOTPLUG_CPU
-	int action = INSTALL_NOTIFY_HANDLER;
-	acpi_walk_namespace(ACPI_TYPE_ANY,
-			    ACPI_ROOT_OBJECT,
-			    ACPI_UINT32_MAX,
-			    processor_walk_namespace_cb, NULL, &action, NULL);
-#endif
-	register_hotcpu_notifier(&acpi_cpu_notifier);
+	if (cmd == ACPIHP_DEV_POST_CMD_ROLLBACK)
+		if (!cpu_online(pr->id))
+			cpu_up(pr->id);
 }
 
-static
-void acpi_processor_uninstall_hotplug_notify(void)
+static void acpi_processor_unconfigure(struct acpi_device *device)
 {
-#ifdef CONFIG_ACPI_HOTPLUG_CPU
-	int action = UNINSTALL_NOTIFY_HANDLER;
-	acpi_walk_namespace(ACPI_TYPE_ANY,
-			    ACPI_ROOT_OBJECT,
-			    ACPI_UINT32_MAX,
-			    processor_walk_namespace_cb, NULL, &action, NULL);
-#endif
-	unregister_hotcpu_notifier(&acpi_cpu_notifier);
+	struct acpi_processor *pr;
+
+	BUG_ON(!device || !acpi_driver_data(device));
+	pr = acpi_driver_data(device);
+	acpi_processor_stop(device, pr);
+	acpi_processor_reset(device, pr);
 }
 
+static struct acpihp_dev_ops acpi_processor_hp_ops = {
+	.get_info = &acpi_processor_get_dev_info,
+	.pre_configure = &acpi_processor_pre_configure,
+	.configure = &acpi_processor_configure,
+	.post_configure = &acpi_processor_post_configure,
+	.release = &acpi_processor_release,
+	.post_release = &acpi_processor_post_release,
+	.unconfigure = &acpi_processor_unconfigure,
+};
+#endif	/* CONFIG_ACPI_HOTPLUG_CPU */
+
 /*
  * We keep the driver loaded even when ACPI is not running.
  * This is needed for the powernow-k8 driver, that works even without
  * ACPI, but needs symbols from this driver
  */
-
 static int __init acpi_processor_init(void)
 {
 	int result = 0;
@@ -938,7 +820,7 @@ static int __init acpi_processor_init(void)
 	if (result < 0)
 		return result;
 
-	acpi_processor_install_hotplug_notify();
+	register_hotcpu_notifier(&acpi_cpu_notifier);
 
 	acpi_thermal_cpufreq_init();
 
@@ -958,7 +840,7 @@ static void __exit acpi_processor_exit(void)
 
 	acpi_thermal_cpufreq_exit();
 
-	acpi_processor_uninstall_hotplug_notify();
+	unregister_hotcpu_notifier(&acpi_cpu_notifier);
 
 	acpi_bus_unregister_driver(&acpi_processor_driver);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
