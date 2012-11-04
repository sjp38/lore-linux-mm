Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 202EB6B006C
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 10:24:52 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so2531187dad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 07:24:51 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part4 6/9] ACPIHP/processor: reject online/offline requests when doing processor hotplug
Date: Sun,  4 Nov 2012 23:23:59 +0800
Message-Id: <1352042642-7306-7-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
References: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

When doing physical processor hotplug, all affected CPUs should be
handled in atomic. In other words, it shouldn't be disturbed by
online/offline requests from CPU device's online sysfs interface.
For example, it's fatal if a CPU is onlined through CPU device's
online sysfs interface between the hotplug driver offlines all affected
CPUs and powers the physical processor off.

So temporarily reject online/offline requests from CPU device's online
sysfs interface by setting the busy flag when doing physical processor
hotplug.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 drivers/acpi/processor_driver.c |   23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
index 53e364d..22214fc 100644
--- a/drivers/acpi/processor_driver.c
+++ b/drivers/acpi/processor_driver.c
@@ -703,7 +703,7 @@ static int acpi_processor_pre_configure(struct acpi_device *device,
 			return result;
 		BUG_ON((pr->id >= nr_cpu_ids) || (pr->id < 0));
 
-		result = arch_register_cpu(pr->id, 0);
+		result = arch_register_cpu(pr->id, 1);
 		if (result) {
 			acpi_unmap_lsapic(pr->id);
 			pr->id = -1;
@@ -751,10 +751,26 @@ static void acpi_processor_post_configure(struct acpi_device *device,
 		if (!cpu_online(pr->id) && cpu_up(pr->id))
 			dev_warn(&device->dev,
 				 "fails to online CPU%d.\n", pr->id);
+		cpu_set_busy(pr->id, 0);
 	} else if (cmd == ACPIHP_DEV_POST_CMD_ROLLBACK)
 		acpi_processor_reset(device, pr);
 }
 
+static int acpi_processor_pre_release(struct acpi_device *device,
+				      struct acpihp_cancel_context *ctx)
+{
+	int result;
+	struct acpi_processor *pr;
+
+	if (!device || !acpi_driver_data(device))
+		return -EINVAL;
+	pr = acpi_driver_data(device);
+
+	result = cpu_set_busy(pr->id, 1);
+
+	return result ? -EBUSY : 0;
+}
+
 static int acpi_processor_release(struct acpi_device *device,
 				  struct acpihp_cancel_context *ctx)
 {
@@ -779,9 +795,11 @@ static void acpi_processor_post_release(struct acpi_device *device,
 	BUG_ON(!device || !acpi_driver_data(device));
 	pr = acpi_driver_data(device);
 
-	if (cmd == ACPIHP_DEV_POST_CMD_ROLLBACK)
+	if (cmd == ACPIHP_DEV_POST_CMD_ROLLBACK) {
 		if (!cpu_online(pr->id))
 			cpu_up(pr->id);
+		cpu_set_busy(pr->id, 0);
+	}
 }
 
 static void acpi_processor_unconfigure(struct acpi_device *device)
@@ -799,6 +817,7 @@ static struct acpihp_dev_ops acpi_processor_hp_ops = {
 	.pre_configure = &acpi_processor_pre_configure,
 	.configure = &acpi_processor_configure,
 	.post_configure = &acpi_processor_post_configure,
+	.pre_release = &acpi_processor_pre_release,
 	.release = &acpi_processor_release,
 	.post_release = &acpi_processor_post_release,
 	.unconfigure = &acpi_processor_unconfigure,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
