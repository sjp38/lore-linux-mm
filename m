Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C93D8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 23:18:38 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 2-v6so1814095plc.11
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 20:18:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c17-v6sor2234835pgf.80.2018.09.18.20.18.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 20:18:37 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCH 2/3] drivers/base/memory: introduce a new state 'isolate' for memblock
Date: Wed, 19 Sep 2018 11:17:45 +0800
Message-Id: <1537327066-27852-3-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1537327066-27852-1-git-send-email-kernelfans@gmail.com>
References: <1537327066-27852-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@techsingularity.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Michal Hocko <mhocko@suse.com>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Currently, offline pages in the unit of memblock, and normally, it is done
one by one on each memblock. If there is only one numa node, then the dst
pages may come from the next memblock to be offlined, which wastes time
during memory offline. For a system with multi numa node, if only replacing
part of mem on a node, and the migration dst page can be allocated from
local node (which is done by [3/3]), it also faces such issue.
This patch suggests to introduce a new state, named 'isolate', the state
transition can be isolate -> online or reversion. And another slight
benefit of "isolated" state is no further allocation on this memblock,
which can block potential unmovable page allocated again from this
memblock for a long time.

After this patch, the suggested ops to offline pages
will looks like:
  for i in {s..e}; do  echo isolate > memory$i/state; done
  for i in {s..e}; do  echo offline > memory$i/state; done

Since this patch does not change the original offline path, hence
  for i in (s..e); do  echo offline > memory$i/state; done
still works.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/base/memory.c  | 31 ++++++++++++++++++++++++++++++-
 include/linux/memory.h |  1 +
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index c8a1cb0..3b714be 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -19,6 +19,7 @@
 #include <linux/memory.h>
 #include <linux/memory_hotplug.h>
 #include <linux/mm.h>
+#include <linux/page-isolation.h>
 #include <linux/mutex.h>
 #include <linux/stat.h>
 #include <linux/slab.h>
@@ -166,6 +167,9 @@ static ssize_t show_mem_state(struct device *dev,
 	case MEM_GOING_OFFLINE:
 		len = sprintf(buf, "going-offline\n");
 		break;
+	case MEM_ISOLATED:
+		len = sprintf(buf, "isolated\n");
+		break;
 	default:
 		len = sprintf(buf, "ERROR-UNKNOWN-%ld\n",
 				mem->state);
@@ -323,6 +327,9 @@ store_mem_state(struct device *dev,
 {
 	struct memory_block *mem = to_memory_block(dev);
 	int ret, online_type;
+	int isolated = 0;
+	unsigned long start_pfn;
+	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
 
 	ret = lock_device_hotplug_sysfs();
 	if (ret)
@@ -336,7 +343,13 @@ store_mem_state(struct device *dev,
 		online_type = MMOP_ONLINE_KEEP;
 	else if (sysfs_streq(buf, "offline"))
 		online_type = MMOP_OFFLINE;
-	else {
+	else if (sysfs_streq(buf, "isolate")) {
+		isolated = 1;
+		goto memblock_isolated;
+	} else if (sysfs_streq(buf, "unisolate")) {
+		isolated = -1;
+		goto memblock_isolated;
+	} else {
 		ret = -EINVAL;
 		goto err;
 	}
@@ -366,6 +379,20 @@ store_mem_state(struct device *dev,
 
 	mem_hotplug_done();
 err:
+memblock_isolated:
+	if (isolated == 1 && mem->state == MEM_ONLINE) {
+		start_pfn = section_nr_to_pfn(mem->start_section_nr);
+		ret = start_isolate_page_range(start_pfn, start_pfn + nr_pages,
+			MIGRATE_MOVABLE, true, true);
+		if (!ret)
+			mem->state = MEM_ISOLATED;
+	} else if (isolated == -1 && mem->state == MEM_ISOLATED) {
+		start_pfn = section_nr_to_pfn(mem->start_section_nr);
+		ret = undo_isolate_page_range(start_pfn, start_pfn + nr_pages,
+			MIGRATE_MOVABLE, true);
+		if (!ret)
+			mem->state = MEM_ONLINE;
+	}
 	unlock_device_hotplug();
 
 	if (ret < 0)
@@ -455,6 +482,7 @@ static DEVICE_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
 static DEVICE_ATTR(state, 0644, show_mem_state, store_mem_state);
 static DEVICE_ATTR(phys_device, 0444, show_phys_device, NULL);
 static DEVICE_ATTR(removable, 0444, show_mem_removable, NULL);
+//static DEVICE_ATTR(isolate, 0600, show_mem_isolate, store_mem_isolate);
 
 /*
  * Block size attribute stuff
@@ -631,6 +659,7 @@ static struct attribute *memory_memblk_attrs[] = {
 #ifdef CONFIG_MEMORY_HOTREMOVE
 	&dev_attr_valid_zones.attr,
 #endif
+	//&dev_attr_isolate.attr,
 	NULL
 };
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index a6ddefc..e00f22c 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -47,6 +47,7 @@ int set_memory_block_size_order(unsigned int order);
 #define	MEM_GOING_ONLINE	(1<<3)
 #define	MEM_CANCEL_ONLINE	(1<<4)
 #define	MEM_CANCEL_OFFLINE	(1<<5)
+#define	MEM_ISOLATED	(1<<6)
 
 struct memory_notify {
 	unsigned long start_pfn;
-- 
2.7.4
