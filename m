Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 610ED6B00E7
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:56:30 -0500 (EST)
Message-Id: <20120228144747.523705338@intel.com>
Date: Tue, 28 Feb 2012 22:00:31 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 9/9] mm: debug vmscan waits
References: <20120228140022.614718843@intel.com>
Content-Disposition: inline; filename=mm-debugfs-vmscan-stalls.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Create /debug/vm/ and export some page reclaim wait counters.

nr_migrate_wait_writeback	wait_on_page_writeback() on migration
nr_reclaim_wait_congested	wait_iff_congested() sleeps
nr_reclaim_wait_writeback	wait_on_page_writeback() on vmscan
nr_congestion_wait		congestion_wait() sleeps
nr_reclaim_throttle_*		reclaim_wait() sleeps

/debug/vm/ might be a convenient place for kernel hackers to play with VM
variables, however this whole stuff is mainly a convenient hack...

It shows that it's now pretty hard to trigger reclaim waits.

1) zero waits on

	truncate -s 100T /fs/100T    
	dd if=/fs/100T of=/dev/null bs=4k &
	dd if=/dev/zero of=/fs/zero bs=4k &

# grep -r . /debug/vm; grep '(nr_vmscan_write|allocstall)' /proc/vmstat
/debug/vm/nr_reclaim_throttle_clean:0
/debug/vm/nr_reclaim_throttle_kswapd:0
/debug/vm/nr_reclaim_throttle_recent_write:0
/debug/vm/nr_reclaim_throttle_write:0
/debug/vm/nr_congestion_wait:0
/debug/vm/nr_reclaim_wait_congested:0
/debug/vm/nr_reclaim_wait_writeback:0
/debug/vm/nr_migrate_wait_writeback:0
nr_vmscan_write 0
allocstall 0

2) some waits on (together with 1)

	usemem 5G --sleep 1000& # mem=8GB

/debug/vm/nr_reclaim_throttle_clean:0
/debug/vm/nr_reclaim_throttle_kswapd:39
/debug/vm/nr_reclaim_throttle_recent_write:1
/debug/vm/nr_reclaim_throttle_write:288
/debug/vm/nr_congestion_wait:13
/debug/vm/nr_reclaim_wait_congested:0
/debug/vm/nr_reclaim_wait_writeback:0
/debug/vm/nr_migrate_wait_writeback:0
nr_vmscan_write 690
allocstall 267675

echo 0 > /debug/vm/* # before doing 3) 

3) some waits on (together with 1,2)

	startx
	start lots of X app and switch among them in a loop

/debug/vm/nr_reclaim_throttle_clean:0
/debug/vm/nr_reclaim_throttle_kswapd:0
/debug/vm/nr_reclaim_throttle_recent_write:0
/debug/vm/nr_reclaim_throttle_write:0
/debug/vm/nr_congestion_wait:19
/debug/vm/nr_reclaim_wait_congested:0
/debug/vm/nr_reclaim_wait_writeback:0
/debug/vm/nr_migrate_wait_writeback:0
nr_vmscan_write 694
allocstall 270880

4) some waits on (together with 1,2,3)

	swapon -a

/debug/vm/nr_reclaim_throttle_clean:0
/debug/vm/nr_reclaim_throttle_kswapd:0
/debug/vm/nr_reclaim_throttle_recent_write:0
/debug/vm/nr_reclaim_throttle_write:2145
/debug/vm/nr_congestion_wait:47
/debug/vm/nr_reclaim_wait_congested:0
/debug/vm/nr_reclaim_wait_writeback:0
/debug/vm/nr_migrate_wait_writeback:0
nr_vmscan_write 42768
allocstall 416735

5) reset counters and stress it more.

	# usemem 1G --sleep 1000&
	# free
		     total       used       free     shared    buffers     cached
	Mem:          6801       6758         42          0          0        994
	-/+ buffers/cache:       5764       1036
	Swap:        51106        235      50870

It's now obviously slow, it now takes seconds or even 10+ seconds to switch to
the other windows:

  765.30    A System Monitor
  769.72    A Dictionary
  772.01    A Home
  790.79    A Desktop Help
  795.47    A *Unsaved Document 1 - gedit
  813.01    A ALC888.svg  (1/11)
  819.24    A Restore Session - Iceweasel
  827.23    A Klondike
  853.57    A urxvt
  862.49    A xeyes
  868.67    A Xpdf: /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
  869.47    A snb:/home/wfg - ZSH

And it seems that the slowness is caused by huge number of pageout()s:

/debug/vm/nr_reclaim_throttle_clean:0
/debug/vm/nr_reclaim_throttle_kswapd:0
/debug/vm/nr_reclaim_throttle_recent_write:0
/debug/vm/nr_reclaim_throttle_write:307
/debug/vm/nr_congestion_wait:0
/debug/vm/nr_reclaim_wait_congested:0
/debug/vm/nr_reclaim_wait_writeback:0
/debug/vm/nr_migrate_wait_writeback:0
nr_vmscan_write 175085
allocstall 669671

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/backing-dev.c |   10 ++++++++
 mm/internal.h    |    5 ++++
 mm/migrate.c     |    3 ++
 mm/vmscan.c      |   55 +++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 71 insertions(+), 2 deletions(-)

--- linux.orig/mm/vmscan.c	2012-02-28 18:54:57.000000000 +0800
+++ linux/mm/vmscan.c	2012-02-28 18:55:15.657047580 +0800
@@ -790,6 +790,8 @@ static enum page_references page_check_r
 	return PAGEREF_RECLAIM;
 }
 
+u32 nr_reclaim_wait_writeback;
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -861,9 +863,10 @@ static unsigned long shrink_page_list(st
 			 * for the IO to complete.
 			 */
 			if ((sc->reclaim_mode & RECLAIM_MODE_SYNC) &&
-			    may_enter_fs)
+			    may_enter_fs) {
 				wait_on_page_writeback(page);
-			else {
+				nr_reclaim_wait_writeback++;
+			} else {
 				unlock_page(page);
 				goto keep_lumpy;
 			}
@@ -1573,6 +1576,7 @@ static inline bool should_reclaim_stall(
 
 	return priority <= lumpy_stall_priority;
 }
+u32 nr_reclaim_throttle[RTT_MAX];
 
 static int reclaim_dirty_level(unsigned long dirty,
 			       unsigned long total)
@@ -1643,6 +1647,7 @@ static bool should_throttle_dirty(struct
 	wait = level >= DIRTY_LEVEL_THROTTLE_ALL;
 out:
 	if (wait) {
+		nr_reclaim_throttle[type]++;
 		trace_mm_vmscan_should_throttle_dirty(type, priority,
 						      dirty_level, wait);
 	}
@@ -3811,3 +3816,49 @@ void scan_unevictable_unregister_node(st
 	device_remove_file(&node->dev, &dev_attr_scan_unevictable_pages);
 }
 #endif
+
+#if defined(CONFIG_DEBUG_FS)
+#include <linux/debugfs.h>
+
+static struct dentry *vm_debug_root;
+
+static int __init vm_debug_init(void)
+{
+	struct dentry *dentry;
+
+	vm_debug_root = debugfs_create_dir("vm", NULL);
+	if (!vm_debug_root)
+		goto fail;
+
+#ifdef CONFIG_MIGRATION
+	dentry = debugfs_create_u32("nr_migrate_wait_writeback", 0644,
+				    vm_debug_root, &nr_migrate_wait_writeback);
+#endif
+
+	dentry = debugfs_create_u32("nr_reclaim_wait_writeback", 0644,
+				    vm_debug_root, &nr_reclaim_wait_writeback);
+
+	dentry = debugfs_create_u32("nr_reclaim_wait_congested", 0644,
+				    vm_debug_root, &nr_reclaim_wait_congested);
+
+	dentry = debugfs_create_u32("nr_congestion_wait", 0644,
+				    vm_debug_root, &nr_congestion_wait);
+
+	dentry = debugfs_create_u32("nr_reclaim_throttle_write", 0644,
+			vm_debug_root, nr_reclaim_throttle + RTT_WRITE);
+	dentry = debugfs_create_u32("nr_reclaim_throttle_recent_write", 0644,
+			vm_debug_root, nr_reclaim_throttle + RTT_RECENT_WRITE);
+	dentry = debugfs_create_u32("nr_reclaim_throttle_kswapd", 0644,
+			vm_debug_root, nr_reclaim_throttle + RTT_KSWAPD);
+	dentry = debugfs_create_u32("nr_reclaim_throttle_clean", 0644,
+			vm_debug_root, nr_reclaim_throttle + RTT_CLEAN);
+	if (!dentry)
+		goto fail;
+
+	return 0;
+fail:
+	return -ENOMEM;
+}
+
+module_init(vm_debug_init);
+#endif /* CONFIG_DEBUG_FS */
--- linux.orig/mm/migrate.c	2012-02-28 18:54:46.000000000 +0800
+++ linux/mm/migrate.c	2012-02-28 18:55:03.085047281 +0800
@@ -674,6 +674,8 @@ static int move_to_new_page(struct page
 	return rc;
 }
 
+u32 nr_migrate_wait_writeback;
+
 static int __unmap_and_move(struct page *page, struct page *newpage,
 			int force, bool offlining, enum migrate_mode mode)
 {
@@ -742,6 +744,7 @@ static int __unmap_and_move(struct page
 		if (!force)
 			goto uncharge;
 		wait_on_page_writeback(page);
+		nr_migrate_wait_writeback++;
 	}
 	/*
 	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
--- linux.orig/mm/internal.h	2012-02-28 18:54:46.000000000 +0800
+++ linux/mm/internal.h	2012-02-28 18:55:03.085047281 +0800
@@ -311,3 +311,8 @@ extern u64 hwpoison_filter_flags_mask;
 extern u64 hwpoison_filter_flags_value;
 extern u64 hwpoison_filter_memcg;
 extern u32 hwpoison_filter_enable;
+
+extern u32 nr_migrate_wait_writeback;
+extern u32 nr_reclaim_wait_congested;
+extern u32 nr_congestion_wait;
+
--- linux.orig/mm/backing-dev.c	2012-02-28 18:54:46.000000000 +0800
+++ linux/mm/backing-dev.c	2012-02-28 18:55:03.085047281 +0800
@@ -12,6 +12,8 @@
 #include <linux/device.h>
 #include <trace/events/writeback.h>
 
+#include "internal.h"
+
 static atomic_long_t bdi_seq = ATOMIC_LONG_INIT(0);
 
 struct backing_dev_info default_backing_dev_info = {
@@ -805,6 +807,9 @@ void set_bdi_congested(struct backing_de
 }
 EXPORT_SYMBOL(set_bdi_congested);
 
+u32 nr_reclaim_wait_congested;
+u32 nr_congestion_wait;
+
 /**
  * congestion_wait - wait for a backing_dev to become uncongested
  * @sync: SYNC or ASYNC IO
@@ -825,6 +830,10 @@ long congestion_wait(int sync, long time
 	ret = io_schedule_timeout(timeout);
 	finish_wait(wqh, &wait);
 
+	nr_congestion_wait++;
+	trace_printk("%pS %pS\n",
+		     __builtin_return_address(0),
+		     __builtin_return_address(1));
 	trace_writeback_congestion_wait(jiffies_to_usecs(timeout),
 					jiffies_to_usecs(jiffies - start));
 
@@ -879,6 +888,7 @@ long wait_iff_congested(struct zone *zon
 	ret = io_schedule_timeout(timeout);
 	finish_wait(wqh, &wait);
 
+	nr_reclaim_wait_congested++;
 out:
 	trace_writeback_wait_iff_congested(jiffies_to_usecs(timeout),
 					jiffies_to_usecs(jiffies - start));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
