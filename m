Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ADCF76B007D
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 02:08:46 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 3/5] writeback: nr_dirtied and nr_written in /proc/vmstat
Date: Tue, 14 Sep 2010 23:08:27 -0700
Message-Id: <1284530908-13430-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kosaki.motohiro@jp.fujitsu.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

To help developers and applications gain visibility into writeback
behaviour adding two entries to vm_stat_items and /proc/vmstat. This
will allow us to track the "written" and "dirtied" counts.

   # grep nr_dirtied /proc/vmstat
   nr_dirtied 3747
   # grep nr_written /proc/vmstat
   nr_written 3618

Signed-off-by: Michael Rubin <mrubin@google.com>
---
 include/linux/mmzone.h |    2 ++
 mm/page-writeback.c    |    2 ++
 mm/vmstat.c            |    3 +++
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6e6e626..bd6c7fc 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -104,6 +104,8 @@ enum zone_stat_item {
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
+	NR_DIRTIED,		/* page dirtyings since bootup */
+	NR_WRITTEN,		/* page writings since bootup */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index ae5f5d5..79feaa0 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1126,6 +1126,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
+		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
@@ -1141,6 +1142,7 @@ EXPORT_SYMBOL(account_page_dirtied);
 void account_page_writeback(struct page *page)
 {
 	inc_zone_page_state(page, NR_WRITEBACK);
+	inc_zone_page_state(page, NR_WRITTEN);
 }
 EXPORT_SYMBOL(account_page_writeback);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f389168..d448ef4 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -732,6 +732,9 @@ static const char * const vmstat_text[] = {
 	"nr_isolated_anon",
 	"nr_isolated_file",
 	"nr_shmem",
+	"nr_dirtied",
+	"nr_written",
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
