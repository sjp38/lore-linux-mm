Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1A7686B0085
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 21:44:56 -0500 (EST)
Message-Id: <20101110024224.144021908@intel.com>
Date: Wed, 10 Nov 2010 10:35:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/5] writeback: check skipped pages on WB_SYNC_ALL
References: <20101110023500.404859581@intel.com>
Content-Disposition: inline; filename=writeback-warn-sync-skipped_pages.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

In WB_SYNC_ALL mode, filesystems are not expected to skip dirty pages on
temporal lock contentions or non fatal errors, otherwise sync() will
return without actually syncing the skipped pages. Add a check to
catch possible redirty_page_for_writepage() callers that violate this
expectation.

I'd recommend to keep this check in -mm tree for some time and fixup the
possible warnings before pushing it to upstream.

If some FS triggers this warning and it's non-trivial to fix the FS,
we'll have to work out a sync retry scheme for skipped pages.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |    6 ++++++
 1 file changed, 6 insertions(+)

--- linux-next.orig/fs/fs-writeback.c	2010-11-10 07:04:43.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-10 07:11:03.000000000 +0800
@@ -527,6 +527,12 @@ static int writeback_sb_inodes(struct su
 			 * buffers.  Skip this inode for now.
 			 */
 			redirty_tail(inode);
+			/*
+			 * There's no logic to retry skipped pages for sync(),
+			 * filesystems are assumed not to skip dirty pages on
+			 * temporal lock contentions or non fatal errors.
+			 */
+			WARN_ON_ONCE(wbc->sync_mode == WB_SYNC_ALL);
 		}
 		spin_unlock(&inode_lock);
 		iput(inode);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
