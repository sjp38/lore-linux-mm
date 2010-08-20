Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 12F616B02E9
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 05:31:47 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 3/4] writeback: nr_dirtied and nr_entered_writeback in /proc/vmstat
Date: Fri, 20 Aug 2010 02:31:28 -0700
Message-Id: <1282296689-25618-4-git-send-email-mrubin@google.com>
In-Reply-To: <1282296689-25618-1-git-send-email-mrubin@google.com>
References: <1282296689-25618-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

To help developers and applications gain visibility into writeback
behaviour adding two entries to /proc/vmstat.

   # grep nr_dirtied /proc/vmstat
   nr_dirtied 3747
   # grep nr_entered_writeback /proc/vmstat
   nr_entered_writeback 3618

In order to track the "cleaned" and "dirtied" counts we added two
vm_stat_items.  Per memory node stats have been added also. So we can
see per node granularity:

   # cat /sys/devices/system/node/node20/writebackstat
   Node 20 pages_writeback: 0 times
   Node 20 pages_dirtied: 0 times

Signed-off-by: Michael Rubin <mrubin@google.com>
---
 drivers/base/node.c    |   14 ++++++++++++++
 include/linux/mmzone.h |    2 ++
 mm/page-writeback.c    |    2 ++
 mm/vmstat.c            |    3 +++
 4 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 2872e86..2d05421 100644
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
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6e6e626..fe4e6dd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -104,6 +104,8 @@ enum zone_stat_item {
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
+	NR_FILE_PAGES_DIRTIED,	/* number of times pages get dirtied */
+	NR_PAGES_ENTERED_WRITEBACK, /* number of times pages enter writeback */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index ae5f5d5..1b1763c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1126,6 +1126,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
+		__inc_zone_page_state(page, NR_FILE_PAGES_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
@@ -1141,6 +1142,7 @@ EXPORT_SYMBOL(account_page_dirtied);
 void account_page_writeback(struct page *page)
 {
 	inc_zone_page_state(page, NR_WRITEBACK);
+	inc_zone_page_state(page, NR_PAGES_ENTERED_WRITEBACK);
 }
 EXPORT_SYMBOL(account_page_writeback);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f389168..073a496 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -732,6 +732,9 @@ static const char * const vmstat_text[] = {
 	"nr_isolated_anon",
 	"nr_isolated_file",
 	"nr_shmem",
+	"nr_dirtied",
+	"nr_entered_writeback",
+
 #ifdef CONFIG_NUMA
 	"numa_hit",
 	"numa_miss",
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
