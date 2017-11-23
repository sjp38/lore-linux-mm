Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 66E1E6B027D
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:15:03 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p65so2408546wma.1
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 03:15:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d36si299313eda.310.2017.11.23.03.15.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 03:15:02 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vANBEo3w035124
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:15:01 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2edtdcneer-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:15:00 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Thu, 23 Nov 2017 11:14:58 -0000
Date: Thu, 23 Nov 2017 11:14:52 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: [PATCH v2 4/5] mm: memory_hotplug: Add memory hotremove probe device
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <cover.1511433386.git.ar@linux.vnet.ibm.com>
Message-Id: <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, mhocko@suse.com, realean2@ie.ibm.com

Adding a "remove" sysfs handle that can be used to trigger
memory hotremove manually, exactly simmetrically with
what happens with the "probe" device for hot-add.

This is usueful for architecture that do not rely on
ACPI for memory hot-remove.

Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
Signed-off-by: Maciej Bielski <m.bielski@virtualopensystems.com>
---
 drivers/base/memory.c | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 1d60b58..8ccb67c 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -530,7 +530,36 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
 }
 
 static DEVICE_ATTR(probe, S_IWUSR, NULL, memory_probe_store);
-#endif
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+static ssize_t
+memory_remove_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	u64 phys_addr;
+	int nid, ret;
+	unsigned long pages_per_block = PAGES_PER_SECTION * sections_per_block;
+
+	ret = kstrtoull(buf, 0, &phys_addr);
+	if (ret)
+		return ret;
+
+	if (phys_addr & ((pages_per_block << PAGE_SHIFT) - 1))
+		return -EINVAL;
+
+	nid = memory_add_physaddr_to_nid(phys_addr);
+	ret = lock_device_hotplug_sysfs();
+	if (ret)
+		return ret;
+
+	remove_memory(nid, phys_addr,
+			 MIN_MEMORY_BLOCK_SIZE * sections_per_block);
+	unlock_device_hotplug();
+	return count;
+}
+static DEVICE_ATTR(remove, S_IWUSR, NULL, memory_remove_store);
+#endif /* CONFIG_MEMORY_HOTREMOVE */
+#endif /* CONFIG_ARCH_MEMORY_PROBE */
 
 #ifdef CONFIG_MEMORY_FAILURE
 /*
@@ -790,6 +819,9 @@ bool is_memblock_offlined(struct memory_block *mem)
 static struct attribute *memory_root_attrs[] = {
 #ifdef CONFIG_ARCH_MEMORY_PROBE
 	&dev_attr_probe.attr,
+#ifdef CONFIG_MEMORY_HOTREMOVE
+	&dev_attr_remove.attr,
+#endif
 #endif
 
 #ifdef CONFIG_MEMORY_FAILURE
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
