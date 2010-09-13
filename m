Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7853D6B0165
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 09:08:20 -0400 (EDT)
Message-Id: <20100913130150.280659291@intel.com>
Date: Mon, 13 Sep 2010 20:31:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/4] vmscan: transfer async file writeback to the flusher
References: <20100913123110.372291929@intel.com>
Content-Disposition: inline; filename=vmscan-writeback-inode-page.patch
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This relays all ASYNC file writeback IOs to the flusher threads.
The lesser SYNC pageout()s will work as before (as a last resort).

It's a minimal prototype implementation and barely runs without panic.
It potentially requires lots of more work to go stable.

TODO: avoid OOM if the LRU list is small and/or the storage is slow, so
that the flusher cannot clean enough pages before the LRU is full
scanned.  One simple way could be to do waits on dirty/writeback pages
when priority < 3 for even order 0 allocations.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    2 +-
 mm/vmscan.c         |   13 +++++++++++++
 2 files changed, 14 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/vmscan.c	2010-09-13 19:48:16.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-09-13 20:14:42.000000000 +0800
@@ -756,6 +756,19 @@ static unsigned long shrink_page_list(st
 				}
 			}
 
+			if (page_is_file_cache(page) && mapping &&
+			    sync_writeback == PAGEOUT_IO_ASYNC) {
+				if (!bdi_start_inode_writeback(
+					mapping->backing_dev_info,
+					mapping->host, page_index(page))) {
+					SetPageReclaim(page);
+					goto keep_locked;
+				} else if (!current_is_kswapd() &&
+					   printk_ratelimit()) {
+					printk(KERN_INFO "cannot pageout\n");
+				}
+			}
+
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)
--- linux-next.orig/mm/page-writeback.c	2010-09-13 19:48:16.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-09-13 20:06:26.000000000 +0800
@@ -1232,6 +1232,7 @@ int set_page_dirty(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 
+	ClearPageReclaim(page);
 	if (likely(mapping)) {
 		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
 #ifdef CONFIG_BLOCK
@@ -1289,7 +1290,6 @@ int clear_page_dirty_for_io(struct page 
 
 	BUG_ON(!PageLocked(page));
 
-	ClearPageReclaim(page);
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		/*
 		 * Yes, Virginia, this is indeed insane.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
