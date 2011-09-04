Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8E5286B0193
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 22:13:28 -0400 (EDT)
Message-Id: <20110904020916.722525088@intel.com>
Date: Sun, 04 Sep 2011 09:53:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 16/18] writeback: fix dirtied pages accounting on sub-page writes
References: <20110904015305.367445271@intel.com>
Content-Disposition: inline; filename=writeback-accurate-task-dirtied.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

When dd in 512bytes, generic_perform_write() calls
balance_dirty_pages_ratelimited() 8 times for the same page, but
obviously the page is only dirtied once.

Fix it by accounting nr_dirtied at page dirty time.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-08-29 19:14:32.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-29 19:14:36.000000000 +0800
@@ -1267,8 +1267,6 @@ void balance_dirty_pages_ratelimited_nr(
 	if (bdi->dirty_exceeded)
 		ratelimit = min(ratelimit, 32 >> (PAGE_SHIFT - 10));
 
-	current->nr_dirtied += nr_pages_dirtied;
-
 	preempt_disable();
 	/*
 	 * This prevents one CPU to accumulate too many dirtied pages without
@@ -1778,6 +1776,7 @@ void account_page_dirtied(struct page *p
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
+		current->nr_dirtied++;
 	}
 }
 EXPORT_SYMBOL(account_page_dirtied);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
