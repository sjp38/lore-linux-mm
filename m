Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2476B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 04:31:15 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id x187so205053942vkx.2
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 01:31:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 98si16998077qks.30.2016.09.06.01.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 01:31:14 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u868RT6m127227
	for <linux-mm@kvack.org>; Tue, 6 Sep 2016 04:31:14 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 259rhk63ef-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Sep 2016 04:31:14 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 6 Sep 2016 18:31:11 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id D421D2CE8056
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 18:31:07 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u868V7373866944
	for <linux-mm@kvack.org>; Tue, 6 Sep 2016 18:31:07 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u868V7Ms027818
	for <linux-mm@kvack.org>; Tue, 6 Sep 2016 18:31:07 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V3] mm: Add sysfs interface to dump each node's zonelist information
Date: Tue,  6 Sep 2016 14:01:06 +0530
In-Reply-To: <1473140072-24137-2-git-send-email-khandual@linux.vnet.ibm.com>
References: <1473140072-24137-2-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org

Each individual node in the system has a ZONELIST_FALLBACK zonelist
and a ZONELIST_NOFALLBACK zonelist. These zonelists decide fallback
order of zones during memory allocations. Sometimes it helps to dump
these zonelists to see the priority order of various zones in them.

Particularly platforms which support memory hotplug into previously
non existing zones (at boot), this interface helps in visualizing
which all zonelists of the system at what priority level, the new
hot added memory ends up in. POWER is such a platform where all the
memory detected during boot time remains with ZONE_DMA for good but
then hot plug process can actually get new memory into ZONE_MOVABLE.
So having a way to get the snapshot of the zonelists on the system
after memory or node hot[un]plug is desirable. This change adds one
new sysfs interface (/sys/devices/system/memory/system_zone_details)
which will fetch and dump this information.

Example zonelist information from a KVM guest.

[NODE (0)]
        ZONELIST_FALLBACK
        (0) (node 0) (zone DMA c00000000140c000)
        (1) (node 1) (zone DMA c000000100000000)
        (2) (node 2) (zone DMA c000000200000000)
        (3) (node 3) (zone DMA c000000300000000)
        ZONELIST_NOFALLBACK
        (0) (node 0) (zone DMA c00000000140c000)
[NODE (1)]
        ZONELIST_FALLBACK
        (0) (node 1) (zone DMA c000000100000000)
        (1) (node 2) (zone DMA c000000200000000)
        (2) (node 3) (zone DMA c000000300000000)
        (3) (node 0) (zone DMA c00000000140c000)
        ZONELIST_NOFALLBACK
        (0) (node 1) (zone DMA c000000100000000)
[NODE (2)]
        ZONELIST_FALLBACK
        (0) (node 2) (zone DMA c000000200000000)
        (1) (node 3) (zone DMA c000000300000000)
        (2) (node 0) (zone DMA c00000000140c000)
        (3) (node 1) (zone DMA c000000100000000)
        ZONELIST_NOFALLBACK
        (0) (node 2) (zone DMA c000000200000000)
[NODE (3)]
        ZONELIST_FALLBACK
        (0) (node 3) (zone DMA c000000300000000)
        (1) (node 0) (zone DMA c00000000140c000)
        (2) (node 1) (zone DMA c000000100000000)
        (3) (node 2) (zone DMA c000000200000000)
        ZONELIST_NOFALLBACK
        (0) (node 3) (zone DMA c000000300000000)

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
Changes in V3:
- Moved all these new sysfs code inside CONFIG_NUMA

Changes in V2:
- Added more details into the commit message
- Added sysfs interface file details into the commit message
- Added ../ABI/testing/sysfs-system-zone-details file

 .../ABI/testing/sysfs-system-zone-details          |  9 ++++
 drivers/base/memory.c                              | 52 ++++++++++++++++++++++
 2 files changed, 61 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-system-zone-details

diff --git a/Documentation/ABI/testing/sysfs-system-zone-details b/Documentation/ABI/testing/sysfs-system-zone-details
new file mode 100644
index 0000000..9c13b2e
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-system-zone-details
@@ -0,0 +1,9 @@
+What:		/sys/devices/system/memory/system_zone_details
+Date:		Sep 2016
+KernelVersion:	4.8
+Contact:	khandual@linux.vnet.ibm.com
+Description:
+		This read only file dumps the zonelist and it's constituent
+		zones information for both ZONELIST_FALLBACK and ZONELIST_
+		NOFALLBACK zonelists for each online node of the system at
+		any given point of time.
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index dc75de9..65fd30e 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -442,7 +442,56 @@ print_block_size(struct device *dev, struct device_attribute *attr,
 	return sprintf(buf, "%lx\n", get_memory_block_size());
 }
 
+#ifdef CONFIG_NUMA
+static ssize_t dump_zonelist(char *buf, struct zonelist *zonelist)
+{
+	unsigned int i;
+	ssize_t count = 0;
+
+	for (i = 0; zonelist->_zonerefs[i].zone; i++) {
+		count += sprintf(buf + count,
+			"\t\t(%d) (node %d) (%-10s %lx)\n", i,
+			zonelist->_zonerefs[i].zone->zone_pgdat->node_id,
+			zone_names[zonelist->_zonerefs[i].zone_idx],
+			(unsigned long) zonelist->_zonerefs[i].zone);
+	}
+	return count;
+}
+
+static ssize_t dump_zonelists(char *buf)
+{
+	struct zonelist *zonelist;
+	unsigned int node;
+	ssize_t count = 0;
+
+	for_each_online_node(node) {
+		zonelist = &(NODE_DATA(node)->
+				node_zonelists[ZONELIST_FALLBACK]);
+		count += sprintf(buf + count, "[NODE (%d)]\n", node);
+		count += sprintf(buf + count, "\tZONELIST_FALLBACK\n");
+		count += dump_zonelist(buf + count, zonelist);
+
+		zonelist = &(NODE_DATA(node)->
+				node_zonelists[ZONELIST_NOFALLBACK]);
+		count += sprintf(buf + count, "\tZONELIST_NOFALLBACK\n");
+		count += dump_zonelist(buf + count, zonelist);
+	}
+	return count;
+}
+
+static ssize_t
+print_system_zone_details(struct device *dev, struct device_attribute *attr,
+		 char *buf)
+{
+	return dump_zonelists(buf);
+}
+#endif
+
+
 static DEVICE_ATTR(block_size_bytes, 0444, print_block_size, NULL);
+#ifdef CONFIG_NUMA
+static DEVICE_ATTR(system_zone_details, 0444, print_system_zone_details, NULL);
+#endif
 
 /*
  * Memory auto online policy.
@@ -783,6 +832,9 @@ static struct attribute *memory_root_attrs[] = {
 #endif
 
 	&dev_attr_block_size_bytes.attr,
+#ifdef CONFIG_NUMA
+	&dev_attr_system_zone_details.attr,
+#endif
 	&dev_attr_auto_online_blocks.attr,
 	NULL
 };
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
