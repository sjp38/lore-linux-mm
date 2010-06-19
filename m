Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 416856B01C3
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 20:30:55 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 1/3] writeback: Creating /sys/kernel/mm/writeback/writeback
Date: Fri, 18 Jun 2010 17:30:13 -0700
Message-Id: <1276907415-504-2-git-send-email-mrubin@google.com>
In-Reply-To: <1276907415-504-1-git-send-email-mrubin@google.com>
References: <1276907415-504-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

Adding the /sys/kernel/mm/writeback/writeback file.  It contains data
to help developers and applications gain visibility into writeback
behaviour.

    # cat /sys/kernel/mm/writeback/writeback
    pages_dirtied:    3747
    pages_cleaned:    3618
    dirty_threshold:  816673
    bg_threshold:     408336

The motivation of a sys file as opposed to debugfs is that applications
that do not have permissions to mount file systems often need this data.

In order to track the "cleaned" and "dirtied" counts we added two
vm_stat_items.  Per memory node stats have been added also. So we can
see per node granularity:

    # cat /sys/devices/system/node/node20/writebackstat
    Node 20 pages_writeback: 0 times
    Node 20 pages_dirtied: 0 times

Signed-off-by: Michael Rubin <mrubin@google.com>
---
 drivers/base/node.c    |   14 ++++++++++++++
 fs/nilfs2/segment.c    |    4 +++-
 include/linux/mmzone.h |    2 ++
 mm/mm_init.c           |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c    |    6 ++++--
 mm/vmstat.c            |    2 ++
 6 files changed, 73 insertions(+), 3 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 2bdd8a9..b321d32 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -160,6 +160,18 @@ static ssize_t node_read_numastat(struct sys_device * dev,
 }
 static SYSDEV_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
 
+static ssize_t node_read_writebackstat(struct sys_device *dev,
+				struct sysdev_attribute *attr, char *buf)
+{
+	int nid = dev->id;
+	return sprintf(buf,
+		"Node %d pages_writeback: %lu times\n"
+		"Node %d pages_dirtied: %lu times\n",
+		nid, node_page_state(nid, NR_PAGES_ENTERED_WRITEBACK),
+		nid, node_page_state(nid, NR_FILE_PAGES_DIRTIED));
+}
+static SYSDEV_ATTR(writebackstat, S_IRUGO, node_read_writebackstat, NULL);
+
 static ssize_t node_read_distance(struct sys_device * dev,
 			struct sysdev_attribute *attr, char * buf)
 {
@@ -243,6 +255,7 @@ int register_node(struct node *node, int num, struct node *parent)
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
+		sysdev_create_file(&node->sysdev, &attr_writebackstat);
 
 		scan_unevictable_register_node(node);
 
@@ -267,6 +280,7 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_meminfo);
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
+	sysdev_remove_file(&node->sysdev, &attr_writebackstat);
 
 	scan_unevictable_unregister_node(node);
 	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index c920164..84b0181 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -1598,8 +1598,10 @@ nilfs_copy_replace_page_buffers(struct page *page, struct list_head *out)
 	} while (bh = bh->b_this_page, bh2 = bh2->b_this_page, bh != head);
 	kunmap_atomic(kaddr, KM_USER0);
 
-	if (!TestSetPageWriteback(clone_page))
+	if (!TestSetPageWriteback(clone_page)) {
 		inc_zone_page_state(clone_page, NR_WRITEBACK);
+		inc_zone_page_state(clone_page, NR_PAGES_ENTERED_WRITEBACK);
+	}
 	unlock_page(clone_page);
 
 	return 0;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b4d109e..c0cd2bd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -112,6 +112,8 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
+	NR_PAGES_ENTERED_WRITEBACK, /* number of times pages enter writeback */
+	NR_FILE_PAGES_DIRTIED,    /* number of times pages get dirtied */
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
diff --git a/mm/mm_init.c b/mm/mm_init.c
index 4e0e265..8f2ebdb 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -9,6 +9,7 @@
 #include <linux/init.h>
 #include <linux/kobject.h>
 #include <linux/module.h>
+#include <linux/writeback.h>
 #include "internal.h"
 
 #ifdef CONFIG_DEBUG_MEMORY_INIT
@@ -137,6 +138,52 @@ static __init int set_mminit_loglevel(char *str)
 early_param("mminit_loglevel", set_mminit_loglevel);
 #endif /* CONFIG_DEBUG_MEMORY_INIT */
 
+#define KERNEL_ATTR_RO(_name) \
+static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
+
+static ssize_t writeback_show(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	unsigned long dirty, background;
+	get_dirty_limits(&background, &dirty, NULL, NULL);
+	return sprintf(buf,
+		       "pages_dirtied:    %lu\n"
+		       "pages_cleaned:    %lu\n"
+		       "dirty_threshold:  %lu\n"
+		       "bg_threshold:     %lu\n",
+		       global_page_state(NR_FILE_PAGES_DIRTIED),
+		       global_page_state(NR_PAGES_ENTERED_WRITEBACK),
+		       dirty, background);
+}
+
+KERNEL_ATTR_RO(writeback);
+
+static struct attribute *writeback_attrs[] = {
+	&writeback_attr.attr,
+	NULL,
+};
+
+static struct attribute_group writeback_attr_group = {
+	.attrs = writeback_attrs,
+};
+
+static int mm_sysfs_writeback_init(void)
+{
+	int error;
+
+	struct kobject *writeback_kobj =
+		kobject_create_and_add("writeback", mm_kobj);
+	if (writeback_kobj == NULL)
+		return -ENOMEM;
+
+	error = sysfs_create_group(writeback_kobj, &writeback_attr_group);
+	if (error) {
+		kobject_put(mm_kobj);
+		return -ENOMEM;
+	}
+	return 0;
+}
+
 struct kobject *mm_kobj;
 EXPORT_SYMBOL_GPL(mm_kobj);
 
@@ -146,6 +193,7 @@ static int __init mm_sysfs_init(void)
 	if (!mm_kobj)
 		return -ENOMEM;
 
+	mm_sysfs_writeback_init();
 	return 0;
 }
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index bbd396a..4cea5c0 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1093,6 +1093,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
+		__inc_zone_page_state(page, NR_FILE_PAGES_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
@@ -1333,10 +1334,11 @@ int test_set_page_writeback(struct page *page)
 	} else {
 		ret = TestSetPageWriteback(page);
 	}
-	if (!ret)
+	if (!ret) {
 		inc_zone_page_state(page, NR_WRITEBACK);
+		inc_zone_page_state(page, NR_PAGES_ENTERED_WRITEBACK);
+	}
 	return ret;
-
 }
 EXPORT_SYMBOL(test_set_page_writeback);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7759941..e177a40 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -740,6 +740,8 @@ static const char * const vmstat_text[] = {
 	"numa_local",
 	"numa_other",
 #endif
+	"nr_pages_entered_writeback",
+	"nr_file_pages_dirtied",
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 	"pgpgin",
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
