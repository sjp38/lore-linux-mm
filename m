Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C26C28D003C
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 17:31:28 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/5] mm: Remove low limit from sync_writeback_pages()
Date: Tue,  8 Mar 2011 23:31:14 +0100
Message-Id: <1299623475-5512-5-git-send-email-jack@suse.cz>
In-Reply-To: <1299623475-5512-1-git-send-email-jack@suse.cz>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>

sync_writeback_pages() limited minimal amount of pages to write
in balance_dirty_pages() to 3/2*ratelimit_pages (6 MB) to submit
reasonably sized IO. Since we do not submit any IO anymore, be more
fair and let the task wait only for 3/2*(the amount dirtied).

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>
CC: Dave Chinner <david@fromorbit.com>
CC: Wu Fengguang <fengguang.wu@intel.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/page-writeback.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 697dd8e..ff07280 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -43,16 +43,11 @@
 static long ratelimit_pages = 32;
 
 /*
- * When balance_dirty_pages decides that the caller needs to perform some
- * non-background writeback, this is how many pages it will attempt to write.
- * It should be somewhat larger than dirtied pages to ensure that reasonably
- * large amounts of I/O are submitted.
+ * When balance_dirty_pages decides that the caller needs to wait for some
+ * writeback to happen, this is how many pages it will attempt to write.
  */
 static inline long sync_writeback_pages(unsigned long dirtied)
 {
-	if (dirtied < ratelimit_pages)
-		dirtied = ratelimit_pages;
-
 	return dirtied + dirtied / 2;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
