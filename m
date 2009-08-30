Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 467306B004F
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 22:54:15 -0400 (EDT)
From: Theodore Ts'o <tytso@mit.edu>
Subject: [PATCH, RFC] vm: Add an tuning knob for vm.max_writeback_pages
Date: Sat, 29 Aug 2009 22:54:18 -0400
Message-Id: <1251600858-21294-1-git-send-email-tytso@mit.edu>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Ext4 Developers List <linux-ext4@vger.kernel.org>
Cc: Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

MAX_WRITEBACK_PAGES was hard-coded to 1024 because of a concern of not
holding I_SYNC for too long.  But this shouldn't be a concern since
I_LOCK and I_SYNC have been separated.  So make it be a tunable and
change the default to be 32768.

This change is helpful for ext4 since it means we write out large file
in bigger chunks than just 4 megabytes at a time, so that when we have
multiple large files in the page cache waiting for writeback, the
files don't end up getting interleaved.  There shouldn't be any downside.

http://bugzilla.kernel.org/show_bug.cgi?id=13930

Signed-off-by: "Theodore Ts'o" <tytso@mit.edu>
---
 include/linux/writeback.h |    1 +
 kernel/sysctl.c           |    8 ++++++++
 mm/page-writeback.c       |   27 ++++++++++++++-------------
 3 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 3224820..c1e6c08 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -110,6 +110,7 @@ extern int vm_dirty_ratio;
 extern unsigned long vm_dirty_bytes;
 extern unsigned int dirty_writeback_interval;
 extern unsigned int dirty_expire_interval;
+extern unsigned int max_writeback_pages;
 extern int vm_highmem_is_dirtyable;
 extern int block_dump;
 extern int laptop_mode;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 58be760..06d1c4c 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1104,6 +1104,14 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "max_writeback_pages",
+		.data		= &max_writeback_pages,
+		.maxlen		= sizeof(max_writeback_pages),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 		.ctl_name	= VM_NR_PDFLUSH_THREADS,
 		.procname	= "nr_pdflush_threads",
 		.data		= &nr_pdflush_threads,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 81627eb..eac8026 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -36,15 +36,6 @@
 #include <linux/pagevec.h>
 
 /*
- * The maximum number of pages to writeout in a single bdflush/kupdate
- * operation.  We do this so we don't hold I_SYNC against an inode for
- * enormous amounts of time, which would block a userspace task which has
- * been forced to throttle against that inode.  Also, the code reevaluates
- * the dirty each time it has written this many pages.
- */
-#define MAX_WRITEBACK_PAGES	1024
-
-/*
  * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
  * will look to see if it needs to force writeback or throttling.
  */
@@ -64,6 +55,16 @@ static inline long sync_writeback_pages(void)
 /* The following parameters are exported via /proc/sys/vm */
 
 /*
+ * The maximum number of pages to writeout in a single bdflush/kupdate
+ * operation.  We used to limit this to 1024 pages to avoid holding
+ * I_SYNC against an inode for a long period of times, but since
+ * I_SYNC has been separated out from I_LOCK, the only time a process
+ * waits for I_SYNC is when it is calling fsync() or otherwise forcing
+ * out the inode.
+ */
+unsigned int max_writeback_pages = 32768;
+
+/*
  * Start background writeback (via pdflush) at this percentage
  */
 int dirty_background_ratio = 10;
@@ -708,10 +709,10 @@ static void background_writeout(unsigned long _min_pages)
 			break;
 		wbc.more_io = 0;
 		wbc.encountered_congestion = 0;
-		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
+		wbc.nr_to_write = max_writeback_pages;
 		wbc.pages_skipped = 0;
 		writeback_inodes(&wbc);
-		min_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
+		min_pages -= max_writeback_pages - wbc.nr_to_write;
 		if (wbc.nr_to_write > 0 || wbc.pages_skipped > 0) {
 			/* Wrote less than expected */
 			if (wbc.encountered_congestion || wbc.more_io)
@@ -783,7 +784,7 @@ static void wb_kupdate(unsigned long arg)
 	while (nr_to_write > 0) {
 		wbc.more_io = 0;
 		wbc.encountered_congestion = 0;
-		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
+		wbc.nr_to_write = max_writeback_pages;
 		writeback_inodes(&wbc);
 		if (wbc.nr_to_write > 0) {
 			if (wbc.encountered_congestion || wbc.more_io)
@@ -791,7 +792,7 @@ static void wb_kupdate(unsigned long arg)
 			else
 				break;	/* All the old data is written */
 		}
-		nr_to_write -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
+		nr_to_write -= max_writeback_pages - wbc.nr_to_write;
 	}
 	if (time_before(next_jif, jiffies + HZ))
 		next_jif = jiffies + HZ;
-- 
1.6.3.2.1.gb9f7d.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
