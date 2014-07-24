Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B17EE6B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 03:43:32 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so3399487pad.38
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 00:43:32 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id kw2si5050017pab.141.2014.07.24.00.43.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 00:43:31 -0700 (PDT)
Message-ID: <53D0B8B6.8040104@huawei.com>
Date: Thu, 24 Jul 2014 15:41:42 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] memory-hotplug: add sysfs zone_index attribute
References: <1406187138-27911-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1406187138-27911-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, Yinghai Lu <yinghai@kernel.org>, mgorman@suse.de, akpm@linux-foundation.org, dave.hansen@intel.com, zhangyanfei@cn.fujitsu.com
Cc: wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Currently memory-hotplug has two limits:
1. If the memory block is in ZONE_NORMAL, you can change it to
ZONE_MOVABLE, but this memory block must be adjacent to ZONE_MOVABLE.
2. If the memory block is in ZONE_MOVABLE, you can change it to
ZONE_NORMAL, but this memory block must be adjacent to ZONE_NORMAL.

Without this patch, we don't know which zone a memory block is in.
So we don't know which memory block is adjacent to ZONE_MOVABLE or
ZONE_NORMAL.

On the other hand, with this patch, we can easy to know newly added
memory is added as ZONE_NORMAL (for powerpc, ZONE_DMA, for x86_32,
ZONE_HIGHMEM).

Updated the related Documentation.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 Documentation/ABI/testing/sysfs-devices-memory |  9 +++++++++
 Documentation/memory-hotplug.txt               |  4 +++-
 drivers/base/memory.c                          | 15 ++++++++++++++-
 3 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
index 7405de2..39d3423 100644
--- a/Documentation/ABI/testing/sysfs-devices-memory
+++ b/Documentation/ABI/testing/sysfs-devices-memory
@@ -61,6 +61,15 @@ Users:		hotplug memory remove tools
 		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils


+What:           /sys/devices/system/memory/memoryX/zone_index
+Date:           July 2014
+Contact:	Zhang Zhen <zhenzhang.zhang@huawei.com>
+Description:
+		The file /sys/devices/system/memory/memoryX/zone_index
+		is read-only and is designed to show which zone this memory block is in.
+Users:		hotplug memory remove tools
+		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils			
+
 What:		/sys/devices/system/memoryX/nodeY
 Date:		October 2009
 Contact:	Linux Memory Management list <linux-mm@kvack.org>
diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 45134dc..07019133 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -155,6 +155,7 @@ Under each memory block, you can see 4 files:
 /sys/devices/system/memory/memoryXXX/phys_device
 /sys/devices/system/memory/memoryXXX/state
 /sys/devices/system/memory/memoryXXX/removable
+/sys/devices/system/memory/memoryXXX/zone_index

 'phys_index'      : read-only and contains memory block id, same as XXX.
 'state'           : read-write
@@ -170,6 +171,8 @@ Under each memory block, you can see 4 files:
                     block is removable and a value of 0 indicates that
                     it is not removable. A memory block is removable only if
                     every section in the block is removable.
+'zone_index' 	  : read-only: designed to show which zone this memory block
+		    is in.

 NOTE:
   These directories/files appear after physical memory hotplug phase.
@@ -408,7 +411,6 @@ node if necessary.
   - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
     sysctl or new control file.
   - showing memory block and physical device relationship.
-  - showing memory block is under ZONE_MOVABLE or not
   - test and make it better memory offlining.
   - support HugeTLB page migration and offlining.
   - memmap removing at memory offline.
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 89f752d..3434d97 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -373,11 +373,23 @@ static ssize_t show_phys_device(struct device *dev,
 	return sprintf(buf, "%d\n", mem->phys_device);
 }

+static ssize_t show_mem_zone_index(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct memory_block *mem = to_memory_block(dev);
+	struct page *first_page;
+	struct zone *zone;
+
+	first_page = pfn_to_page(mem->start_section_nr << PFN_SECTION_SHIFT);
+	zone = page_zone(first_page);
+	return sprintf(buf, "%s\n", zone->name);
+}
+
 static DEVICE_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
 static DEVICE_ATTR(state, 0644, show_mem_state, store_mem_state);
 static DEVICE_ATTR(phys_device, 0444, show_phys_device, NULL);
 static DEVICE_ATTR(removable, 0444, show_mem_removable, NULL);
-
+static DEVICE_ATTR(zone_index, 0444, show_mem_zone_index, NULL);
 /*
  * Block size attribute stuff
  */
@@ -521,6 +533,7 @@ static struct attribute *memory_memblk_attrs[] = {
 	&dev_attr_state.attr,
 	&dev_attr_phys_device.attr,
 	&dev_attr_removable.attr,
+	&dev_attr_zone_index.attr,
 	NULL
 };

-- 
1.8.1.2


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
