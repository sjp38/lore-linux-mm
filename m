Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id F06FE6B0071
	for <linux-mm@kvack.org>; Sun,  1 Mar 2015 23:00:06 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id v1so24965868oia.9
        for <linux-mm@kvack.org>; Sun, 01 Mar 2015 20:00:06 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id h66si2795238oif.39.2015.03.01.20.00.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 01 Mar 2015 20:00:05 -0800 (PST)
From: Sheng Yong <shengyong1@huawei.com>
Subject: [RFC PATCH 1/2] mem-hotplug: introduce sysfs `range' attribute
Date: Mon, 2 Mar 2015 04:04:59 +0000
Message-ID: <1425269100-15842-1-git-send-email-shengyong1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, nfont@austin.ibm.com
Cc: linux-mm@kvack.org, zhenzhang.zhang@huawei.com

There may be memory holes in a memory section, and because of that we can
not know the real size of the section. In order to know the physical memory
area used int one memory section, we walks through iomem resources and
report the memory range in /sys/devices/system/memory/memoryX/range, like,

root@ivybridge:~# cat /sys/devices/system/memory/memory0/range
00001000-0008efff
00090000-0009ffff
00100000-07ffffff

Signed-off-by: Sheng Yong <shengyong1@huawei.com>
---
 drivers/base/memory.c |   66 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 85be040..e72e5e4 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -21,6 +21,7 @@
 #include <linux/mutex.h>
 #include <linux/stat.h>
 #include <linux/slab.h>
+#include <linux/ioport.h>
 
 #include <linux/atomic.h>
 #include <asm/uaccess.h>
@@ -373,6 +374,69 @@ static ssize_t show_phys_device(struct device *dev,
 	return sprintf(buf, "%d\n", mem->phys_device);
 }
 
+static int get_range(u64 start, u64 end, void *arg)
+{
+	struct resource **head, *p, *tmp;
+
+	head = (struct resource **) arg;
+
+	if (!(*head)) {
+		*head = kmalloc(sizeof(struct resource), GFP_KERNEL);
+		if (!(*head))
+			return -ENOMEM;
+		(*head)->start = start;
+		(*head)->end = end;
+		(*head)->sibling = NULL;
+	} else {
+		p = *head;
+		while (p->sibling != NULL)
+			p = p->sibling;
+		if (p->end == start - 1) {
+			p->end = end;
+			return 0;
+		}
+		tmp = kmalloc(sizeof(struct resource), GFP_KERNEL);
+		if (!tmp)
+			return -ENOMEM;
+		tmp->start = start;
+		tmp->end = end;
+		tmp->sibling = NULL;
+		p->sibling = tmp;
+	}
+
+	return 0;
+}
+
+static ssize_t show_mem_range(struct device *dev,
+			      struct device_attribute *attr, char *buf)
+{
+	struct memory_block *mem = to_memory_block(dev);
+	unsigned long start_pfn, end_pfn, nr_pages;
+	struct resource *ranges = NULL, *p;
+	u64 start, end;
+	int cnt, err;
+
+	nr_pages = PAGES_PER_SECTION * sections_per_block;
+	start_pfn = section_nr_to_pfn(mem->start_section_nr);
+	end_pfn = start_pfn + nr_pages;
+
+	start = (u64) start_pfn << PAGE_SHIFT;
+	end = ((u64) end_pfn << PAGE_SHIFT) - 1;
+	err = walk_system_ram_res(start, end, &ranges, get_range);
+
+	cnt = 0;
+	while (ranges != NULL) {
+		p = ranges;
+		if (err == 0)
+			cnt += sprintf(buf, "%s%08llx-%08llx\n", buf,
+				       ranges->start, ranges->end);
+		ranges = ranges->sibling;
+		kfree(p);
+	}
+
+	return cnt;
+}
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 static ssize_t show_valid_zones(struct device *dev,
 				struct device_attribute *attr, char *buf)
@@ -416,6 +480,7 @@ static DEVICE_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
 static DEVICE_ATTR(state, 0644, show_mem_state, store_mem_state);
 static DEVICE_ATTR(phys_device, 0444, show_phys_device, NULL);
 static DEVICE_ATTR(removable, 0444, show_mem_removable, NULL);
+static DEVICE_ATTR(range, 0444, show_mem_range, NULL);
 
 /*
  * Block size attribute stuff
@@ -565,6 +630,7 @@ static struct attribute *memory_memblk_attrs[] = {
 #ifdef CONFIG_MEMORY_HOTREMOVE
 	&dev_attr_valid_zones.attr,
 #endif
+	&dev_attr_range.attr,
 	NULL
 };
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
