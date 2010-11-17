From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 04/13] writeback: prevent duplicate balance_dirty_pages_ratelimited() calls
Date: Wed, 17 Nov 2010 11:58:25 +0800
Message-ID: <20101117035905.873681033@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PIZKB-0007lE-Lh
	for glkm-linux-mm-2@m.gmane.org; Wed, 17 Nov 2010 05:08:48 +0100
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EDCE68D00A2
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:08:11 -0500 (EST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Andrew,
References: <20101117035821.000579293@intel.com>
Content-Disposition: inline; filename=writeback-fix-duplicate-bdp-calls.patch

When dd in 512bytes, balance_dirty_pages_ratelimited() used to be called
8 times for the same page, even if the page is only dirtied once. Fix it
with a (slightly racy) PageDirty() test.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/filemap.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/filemap.c	2010-11-16 22:20:08.000000000 +0800
+++ linux-next/mm/filemap.c	2010-11-16 22:45:05.000000000 +0800
@@ -2258,6 +2258,7 @@ static ssize_t generic_perform_write(str
 	long status = 0;
 	ssize_t written = 0;
 	unsigned int flags = 0;
+	unsigned int dirty;
 
 	/*
 	 * Copies from kernel address space cannot fail (NFSD is a big user).
@@ -2306,6 +2307,7 @@ again:
 		pagefault_enable();
 		flush_dcache_page(page);
 
+		dirty = PageDirty(page);
 		mark_page_accessed(page);
 		status = a_ops->write_end(file, mapping, pos, bytes, copied,
 						page, fsdata);
@@ -2332,7 +2334,8 @@ again:
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
