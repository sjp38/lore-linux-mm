Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4936B0025
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:44:45 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id c16so3071042pgv.8
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:44:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u83si3400439pgb.662.2018.03.21.15.44.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 15:44:44 -0700 (PDT)
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Subject: [PATCH 1/3] fs: Perform writebacks under memalloc_nofs
Date: Wed, 21 Mar 2018 17:44:27 -0500
Message-Id: <20180321224429.15860-2-rgoldwyn@suse.de>
In-Reply-To: <20180321224429.15860-1-rgoldwyn@suse.de>
References: <20180321224429.15860-1-rgoldwyn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, willy@infradead.org, david@fromorbit.com, Goldwyn Rodrigues <rgoldwyn@suse.com>

From: Goldwyn Rodrigues <rgoldwyn@suse.com>

writebacks can recurse into itself under low memory situations.
Set memalloc_nofs_save() in order to make sure it does not
recurse.

Since writeouts are performed for fdatawrites as well, set
memalloc_nofs_save while performing fdatawrites.

Signed-off-by: Goldwyn Rodrigues <rgoldwyn@suse.com>
---
 fs/fs-writeback.c | 8 ++++++++
 fs/xfs/xfs_aops.c | 7 -------
 mm/filemap.c      | 3 +++
 3 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d4d04fee568a..42f7f4c2063b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -28,6 +28,7 @@
 #include <linux/tracepoint.h>
 #include <linux/device.h>
 #include <linux/memcontrol.h>
+#include <linux/sched/mm.h>
 #include "internal.h"
 
 /*
@@ -1713,7 +1714,12 @@ static long wb_writeback(struct bdi_writeback *wb,
 	struct inode *inode;
 	long progress;
 	struct blk_plug plug;
+	unsigned flags;
 
+	if (current->flags & PF_MEMALLOC_NOFS)
+		return 0;
+
+	flags = memalloc_nofs_save();
 	oldest_jif = jiffies;
 	work->older_than_this = &oldest_jif;
 
@@ -1797,6 +1803,8 @@ static long wb_writeback(struct bdi_writeback *wb,
 	spin_unlock(&wb->list_lock);
 	blk_finish_plug(&plug);
 
+	memalloc_nofs_restore(flags);
+
 	return nr_pages - work->nr_pages;
 }
 
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 9c6a830da0ee..943ade03489a 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1086,13 +1086,6 @@ xfs_do_writepage(
 			PF_MEMALLOC))
 		goto redirty;
 
-	/*
-	 * Given that we do not allow direct reclaim to call us, we should
-	 * never be called while in a filesystem transaction.
-	 */
-	if (WARN_ON_ONCE(current->flags & PF_MEMALLOC_NOFS))
-		goto redirty;
-
 	/*
 	 * Is this page beyond the end of the file?
 	 *
diff --git a/mm/filemap.c b/mm/filemap.c
index 693f62212a59..3c9ead9a1e32 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -430,6 +430,7 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
 				loff_t end, int sync_mode)
 {
 	int ret;
+	unsigned flags;
 	struct writeback_control wbc = {
 		.sync_mode = sync_mode,
 		.nr_to_write = LONG_MAX,
@@ -440,9 +441,11 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
 	if (!mapping_cap_writeback_dirty(mapping))
 		return 0;
 
+	flags = memalloc_nofs_save();
 	wbc_attach_fdatawrite_inode(&wbc, mapping->host);
 	ret = do_writepages(mapping, &wbc);
 	wbc_detach_inode(&wbc);
+	memalloc_nofs_restore(flags);
 	return ret;
 }
 
-- 
2.16.2
