Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m85HM104003270
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 13:22:01 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m85HM1Gl111316
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 11:22:01 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m85HLuut001294
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 11:22:00 -0600
Date: Fri, 5 Sep 2008 10:21:54 -0700
From: Gary Hade <garyhade@us.ibm.com>
Subject: [PATCH] [RESEND] mm: show memory section to node relationship in
	sysfs
Message-ID: <20080905172154.GB11692@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Resending with linux-kernel@vger.kernel.org copied this time.  No changes
other than this and the Subject line.  Based on linux-mm discussion
yesterday I will be revising this patch to include proper documentation
and symlinks instead of node number containing files.  If there are any
other comments please fire away.


Show memory section to node relationship in sysfs

Add /sys/devices/system/memory/memoryX/node files to show
the node on which each memory section resides.

Signed-off-by: Gary Hade <garyhade@us.ibm.com>

---
 Documentation/memory-hotplug.txt |    1 -
 drivers/base/memory.c            |   20 ++++++++++++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)

Index: linux-2.6.27-rc5/drivers/base/memory.c
===================================================================
--- linux-2.6.27-rc5.orig/drivers/base/memory.c	2008-09-03 14:24:54.000000000 -0700
+++ linux-2.6.27-rc5/drivers/base/memory.c	2008-09-03 14:25:14.000000000 -0700
@@ -150,6 +150,22 @@
 	return len;
 }

+/*
+ * node on which memory section resides
+ */
+static ssize_t show_mem_node(struct sys_device *dev,
+			struct sysdev_attribute *attr, char *buf)
+{
+	unsigned long start_pfn;
+	int ret;
+	struct memory_block *mem =
+		container_of(dev, struct memory_block, sysdev);
+
+	start_pfn = section_nr_to_pfn(mem->phys_index);
+	ret = pfn_to_nid(start_pfn);
+	return sprintf(buf, "%d\n", ret);
+}
+
 int memory_notify(unsigned long val, void *v)
 {
 	return blocking_notifier_call_chain(&memory_chain, val, v);
@@ -278,6 +294,7 @@
 static SYSDEV_ATTR(state, 0644, show_mem_state, store_mem_state);
 static SYSDEV_ATTR(phys_device, 0444, show_phys_device, NULL);
 static SYSDEV_ATTR(removable, 0444, show_mem_removable, NULL);
+static SYSDEV_ATTR(node, 0444, show_mem_node, NULL);

 #define mem_create_simple_file(mem, attr_name)	\
 	sysdev_create_file(&mem->sysdev, &attr_##attr_name)
@@ -368,6 +385,8 @@
 		ret = mem_create_simple_file(mem, phys_device);
 	if (!ret)
 		ret = mem_create_simple_file(mem, removable);
+	if (!ret)
+		ret = mem_create_simple_file(mem, node);

 	return ret;
 }
@@ -413,6 +432,7 @@
 	mem_remove_simple_file(mem, state);
 	mem_remove_simple_file(mem, phys_device);
 	mem_remove_simple_file(mem, removable);
+	mem_remove_simple_file(mem, node);
 	unregister_memory(mem, section);

 	return 0;
Index: linux-2.6.27-rc5/Documentation/memory-hotplug.txt
===================================================================
--- linux-2.6.27-rc5.orig/Documentation/memory-hotplug.txt	2008-09-03 14:25:54.000000000 -0700
+++ linux-2.6.27-rc5/Documentation/memory-hotplug.txt	2008-09-03 14:26:15.000000000 -0700
@@ -365,7 +365,6 @@
   - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
     sysctl or new control file.
   - showing memory section and physical device relationship.
-  - showing memory section and node relationship (maybe good for NUMA)
   - showing memory section is under ZONE_MOVABLE or not
   - test and make it better memory offlining.
   - support HugeTLB page migration and offlining.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
