Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BAB0F900087
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 05:06:49 -0400 (EDT)
Message-Id: <20110413090415.511675208@intel.com>
Date: Wed, 13 Apr 2011 16:59:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/4] writeback: avoid duplicate balance_dirty_pages_ratelimited() calls
References: <20110413085937.981293444@intel.com>
Content-Disposition: inline; filename=writeback-fix-duplicate-bdp-calls.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

When dd in 512bytes, balance_dirty_pages_ratelimited() could be called 8
times for the same page, but obviously the page is only dirtied once.

Fix it with a (slightly racy) PageDirty() test.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/filemap.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/filemap.c	2011-04-13 16:46:01.000000000 +0800
+++ linux-next/mm/filemap.c	2011-04-13 16:47:26.000000000 +0800
@@ -2313,6 +2313,7 @@ static ssize_t generic_perform_write(str
 	long status = 0;
 	ssize_t written = 0;
 	unsigned int flags = 0;
+	unsigned int dirty;
 
 	/*
 	 * Copies from kernel address space cannot fail (NFSD is a big user).
@@ -2361,6 +2362,7 @@ again:
 		pagefault_enable();
 		flush_dcache_page(page);
 
+		dirty = PageDirty(page);
 		mark_page_accessed(page);
 		status = a_ops->write_end(file, mapping, pos, bytes, copied,
 						page, fsdata);
@@ -2387,7 +2389,8 @@ again:
 		pos += copied;
 		written += copied;
 
-		balance_dirty_pages_ratelimited(mapping);
+		if (!dirty)
+			balance_dirty_pages_ratelimited(mapping);
 
 	} while (iov_iter_count(i));
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
