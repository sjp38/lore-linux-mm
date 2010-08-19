Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DC3C66B02B9
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:57:58 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 3/3] writeback: Reporting dirty thresholds in /proc/vmstat
Date: Thu, 19 Aug 2010 13:57:27 -0700
Message-Id: <1282251447-16937-4-git-send-email-mrubin@google.com>
In-Reply-To: <1282251447-16937-1-git-send-email-mrubin@google.com>
References: <1282251447-16937-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, npiggin@suse.de, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

The kernel already exposes the desired thresholds in /proc/sys/vm with
dirty_background_ratio and background_ratio. Instead the kernel may
alter the number requested without giving the user any indication that
is the case.

Knowing the actual ratios the kernel is honoring can help app developers
understand how their buffered IO will be sent to the disk.

	$ grep threshold /proc/vmstat
	nr_pages_dirty_threshold 409111
	nr_pages_dirty_background_threshold 818223

Signed-off-by: Michael Rubin <mrubin@google.com>
---
 include/linux/mmzone.h |    2 ++
 mm/vmstat.c            |    8 ++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f160481..7c4a3bf 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -114,6 +114,8 @@ enum zone_stat_item {
 #endif
 	NR_PAGES_ENTERED_WRITEBACK, /* number of times pages enter writeback */
 	NR_FILE_PAGES_DIRTIED,      /* number of times pages get dirtied */
+	NR_PAGES_DIRTY_THRESHOLD,   /* writeback threshold */
+	NR_PAGES_DIRTY_BG_THRESHOLD,/* bg writeback threshold */
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index e177a40..8b5bc78 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -17,6 +17,7 @@
 #include <linux/vmstat.h>
 #include <linux/sched.h>
 #include <linux/math64.h>
+#include <linux/writeback.h>
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
@@ -742,6 +743,8 @@ static const char * const vmstat_text[] = {
 #endif
 	"nr_pages_entered_writeback",
 	"nr_file_pages_dirtied",
+	"nr_pages_dirty_threshold",
+	"nr_pages_dirty_background_threshold",
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 	"pgpgin",
@@ -901,6 +904,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 #ifdef CONFIG_VM_EVENT_COUNTERS
 	unsigned long *e;
 #endif
+	unsigned long dirty_thresh, dirty_bg_thresh;
 	int i;
 
 	if (*pos >= ARRAY_SIZE(vmstat_text))
@@ -918,6 +922,10 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 		return ERR_PTR(-ENOMEM);
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		v[i] = global_page_state(i);
+
+	get_dirty_limits(&dirty_thresh, &dirty_bg_thresh, NULL, NULL);
+	v[NR_PAGES_DIRTY_THRESHOLD] = dirty_thresh;
+	v[NR_PAGES_DIRTY_BG_THRESHOLD] = dirty_bg_thresh;
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
