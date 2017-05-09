Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5F5C280414
	for <linux-mm@kvack.org>; Tue,  9 May 2017 08:18:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q91so19459518wrb.8
        for <linux-mm@kvack.org>; Tue, 09 May 2017 05:18:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w19si17702447wra.150.2017.05.09.05.18.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 05:18:57 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/4] mm: Fix data corruption due to stale mmap reads
Date: Tue,  9 May 2017 14:18:35 +0200
Message-Id: <20170509121837.26153-3-jack@suse.cz>
In-Reply-To: <20170509121837.26153-1-jack@suse.cz>
References: <20170509121837.26153-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, stable@vger.kernel.org

Currently, we didn't invalidate page tables during
invalidate_inode_pages2() for DAX. That could result in e.g. 2MiB zero
page being mapped into page tables while there were already underlying
blocks allocated and thus data seen through mmap were different from
data seen by read(2). The following sequence reproduces the problem:

- open an mmap over a 2MiB hole

- read from a 2MiB hole, faulting in a 2MiB zero page

- write to the hole with write(3p).  The write succeeds but we
  incorrectly leave the 2MiB zero page mapping intact.

- via the mmap, read the data that was just written.  Since the zero
  page mapping is still intact we read back zeroes instead of the new
  data.

Fix the problem by unconditionally calling
invalidate_inode_pages2_range() in dax_iomap_actor() for new block
allocations and by properly invalidating page tables in
invalidate_inode_pages2_range() for DAX mappings.

Fixes: c6dcf52c23d2d3fb5235cec42d7dd3f786b87d55
CC: stable@vger.kernel.org
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c      |  2 +-
 mm/truncate.c | 12 +++++++++++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 565c2ea63135..72853669a356 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1003,7 +1003,7 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 	 * into page tables. We have to tear down these mappings so that data
 	 * written by write(2) is visible in mmap.
 	 */
-	if ((iomap->flags & IOMAP_F_NEW) && inode->i_mapping->nrpages) {
+	if (iomap->flags & IOMAP_F_NEW) {
 		invalidate_inode_pages2_range(inode->i_mapping,
 					      pos >> PAGE_SHIFT,
 					      (end - 1) >> PAGE_SHIFT);
diff --git a/mm/truncate.c b/mm/truncate.c
index 706cff171a15..6479ed2afc53 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -686,7 +686,17 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 		cond_resched();
 		index++;
 	}
-
+	/*
+	 * For DAX we invalidate page tables after invalidating radix tree.  We
+	 * could invalidate page tables while invalidating each entry however
+	 * that would be expensive. And doing range unmapping before doesn't
+	 * work as we have no cheap way to find whether radix tree entry didn't
+	 * get remapped later.
+	 */
+	if (dax_mapping(mapping)) {
+		unmap_mapping_range(mapping, (loff_t)start << PAGE_SHIFT,
+				    (loff_t)(end - start + 1) << PAGE_SHIFT, 0);
+	}
 out:
 	cleancache_invalidate_inode(mapping);
 	return ret;
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
