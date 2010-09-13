Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0796B00DC
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 01:58:37 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 5/5] writeback: Reporting dirty thresholds in /proc/vmstat
Date: Sun, 12 Sep 2010 22:58:13 -0700
Message-Id: <1284357493-20078-6-git-send-email-mrubin@google.com>
In-Reply-To: <1284357493-20078-1-git-send-email-mrubin@google.com>
References: <1284357493-20078-1-git-send-email-mrubin@google.com>
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
 mm/vmstat.c |   39 +++++++++++++++++++++++++--------------
 1 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index d448ef4..76c37cd 100644
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
@@ -894,36 +897,44 @@ static const struct file_operations proc_zoneinfo_file_operations = {
 	.release	= seq_release,
 };
 
+enum writeback_stat_item {
+	NR_DIRTY_THRESHOLD,
+	NR_DIRTY_BG_THRESHOLD,
+	NR_VM_WRITEBACK_STAT_ITEMS,
+};
+
 static void *vmstat_start(struct seq_file *m, loff_t *pos)
 {
 	unsigned long *v;
-#ifdef CONFIG_VM_EVENT_COUNTERS
-	unsigned long *e;
-#endif
-	int i;
+	int i, stat_items_size;
 
 	if (*pos >= ARRAY_SIZE(vmstat_text))
 		return NULL;
+	stat_items_size = NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long) +
+			  NR_VM_WRITEBACK_STAT_ITEMS * sizeof(unsigned long);
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
-	v = kmalloc(NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long)
-			+ sizeof(struct vm_event_state), GFP_KERNEL);
-#else
-	v = kmalloc(NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long),
-			GFP_KERNEL);
+	stat_items_size += sizeof(struct vm_event_state);
 #endif
+
+	v = kmalloc(stat_items_size, GFP_KERNEL);
 	m->private = v;
 	if (!v)
 		return ERR_PTR(-ENOMEM);
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		v[i] = global_page_state(i);
+	v += NR_VM_ZONE_STAT_ITEMS;
+
+	global_dirty_limits(v + NR_DIRTY_BG_THRESHOLD,
+			    v + NR_DIRTY_THRESHOLD);
+	v += NR_VM_WRITEBACK_STAT_ITEMS;
+
 #ifdef CONFIG_VM_EVENT_COUNTERS
-	e = v + NR_VM_ZONE_STAT_ITEMS;
-	all_vm_events(e);
-	e[PGPGIN] /= 2;		/* sectors -> kbytes */
-	e[PGPGOUT] /= 2;
+	all_vm_events(v);
+	v[PGPGIN] /= 2;		/* sectors -> kbytes */
+	v[PGPGOUT] /= 2;
 #endif
-	return v + *pos;
+	return m->private + *pos;
 }
 
 static void *vmstat_next(struct seq_file *m, void *arg, loff_t *pos)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
