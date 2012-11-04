Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 141A46B005D
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 10:24:35 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3709616pad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 07:24:34 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part4 3/9] ACPIHP/processor: protect accesses to device->driver_data
Date: Sun,  4 Nov 2012 23:23:56 +0800
Message-Id: <1352042642-7306-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
References: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

CPU hotplug notification handler acpi_cpu_soft_notify() and driver
unbind method acpi_processor_remove() may be concurrently called.
acpi_cpu_soft_notify() will access device->driver_data, but that
data structure may be destroyed by acpi_processor_remove().

On the other hand, acpi_cpu_soft_notify() is always called under
protection of get_online_cpus(), so use get_online_cpus() to serialize
all accesses and modifications to device->driver_data.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 drivers/acpi/processor_driver.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
index 28add34..7d6d794 100644
--- a/drivers/acpi/processor_driver.c
+++ b/drivers/acpi/processor_driver.c
@@ -616,6 +616,8 @@ static int __cpuinit acpi_processor_add(struct acpi_device *device)
 		return 0;
 	BUG_ON((pr->id >= nr_cpu_ids) || (pr->id < 0));
 
+	/* block CPU online/offline operations */
+	get_online_cpus();
 	result = acpi_processor_link(device, pr);
 	if (result)
 		goto err_unlock;
@@ -624,6 +626,7 @@ static int __cpuinit acpi_processor_add(struct acpi_device *device)
 		if (result)
 			goto err_unlink;
 	}
+	put_online_cpus();
 
 	return 0;
 
@@ -654,8 +657,10 @@ static int acpi_processor_remove(struct acpi_device *device, int type)
 			return -EINVAL;
 	}
 
+	get_online_cpus();
 	acpi_processor_stop(device, pr);
 	acpi_processor_unlink(device, pr);
+	put_online_cpus();
 
 free:
 	device->driver_data = NULL;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
