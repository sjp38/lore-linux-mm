Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A37716B019A
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 22:13:28 -0400 (EDT)
Message-Id: <20110904020916.972004786@intel.com>
Date: Sun, 04 Sep 2011 09:53:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 18/18] btrfs: fix dirtied pages accounting on sub-page writes
References: <20110904015305.367445271@intel.com>
Content-Disposition: inline; filename=btrfs-account-redirty
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Chris Mason <chris.mason@oracle.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

When doing 1KB sequential writes to the same page,
balance_dirty_pages_ratelimited_nr() should be called once instead of 4
times, the latter makes the dirtier tasks be throttled much too heavy.

Fix it with proper de-accounting on clear_page_dirty_for_io().

CC: Chris Mason <chris.mason@oracle.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/btrfs/file.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-next.orig/fs/btrfs/file.c	2011-08-29 19:14:32.000000000 +0800
+++ linux-next/fs/btrfs/file.c	2011-08-29 19:14:40.000000000 +0800
@@ -1138,7 +1138,8 @@ again:
 				     GFP_NOFS);
 	}
 	for (i = 0; i < num_pages; i++) {
-		clear_page_dirty_for_io(pages[i]);
+		if (clear_page_dirty_for_io(pages[i]))
+			account_page_redirty(pages[i]);
 		set_page_extent_mapped(pages[i]);
 		WARN_ON(!PageLocked(pages[i]));
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
