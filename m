Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8556B00BC
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 16:31:10 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 5/5] writeback: Reporting dirty thresholds in /proc/vmstat
Date: Sun, 12 Sep 2010 13:30:40 -0700
Message-Id: <1284323440-23205-6-git-send-email-mrubin@google.com>
In-Reply-To: <1284323440-23205-1-git-send-email-mrubin@google.com>
References: <1284323440-23205-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kosaki.motohiro@jp.fujitsu.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

The kernel already exposes the user desired thresholds in /proc/sys/vm
with dirty_background_ratio and background_ratio. But the kernel may
alter the number requested without giving the user any indication that
is the case.

Knowing the actual ratios the kernel is honoring can help app developers
understand how their buffered IO will be sent to the disk.

        $ grep threshold /proc/vmstat
        nr_dirty_threshold 409111
        nr_dirty_background_threshold 818223

Signed-off-by: Michael Rubin <mrubin@google.com>
---
 include/linux/mmzone.h |    2 ++
 mm/vmstat.c            |    4 ++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d0d7454..1e87936 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -106,6 +106,8 @@ enum zone_stat_item {
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_FILE_DIRTIED,	/* accumulated dirty pages */
 	NR_WRITTEN,		/* accumulated written pages */
+	NR_DIRTY_THRESHOLD,	/* writeback threshold */
+	NR_DIRTY_BG_THRESHOLD,	/* bg writeback threshold */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
diff --git a/mm/vmstat.c b/mm/vmstat.c
index d448ef4..0c1ddca 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -17,6 +17,7 @@
 #include <linux/vmstat.h>
 #include <linux/sched.h>
 #include <linux/math64.h>
+#include <linux/writeback.h>
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
@@ -734,6 +735,8 @@ static const char * const vmstat_text[] = {
 	"nr_shmem",
 	"nr_dirtied",
 	"nr_written",
+	"nr_dirty_threshold",
+	"nr_dirty_background_threshold",
 
 #ifdef CONFIG_NUMA
 	"numa_hit",
@@ -917,6 +920,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 		return ERR_PTR(-ENOMEM);
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		v[i] = global_page_state(i);
+	global_dirty_limits(v + NR_DIRTY_BG_THRESHOLD, v + NR_DIRTY_THRESHOLD);
 #ifdef CONFIG_VM_EVENT_COUNTERS
 	e = v + NR_VM_ZONE_STAT_ITEMS;
 	all_vm_events(e);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
