Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD556B0010
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:06 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n51so16369474qta.9
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:06 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 84si2137340qkw.467.2018.04.04.12.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:05 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 20/79] fs: add struct address_space to write_cache_pages() callback argument
Date: Wed,  4 Apr 2018 15:17:57 -0400
Message-Id: <20180404191831.5378-8-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Add struct address_space to callback arguments of write_cache_pages()
Note this patch only add arguments and modify all callback functions
signature, it does not make use of the new argument and thus it should
be regression free.

One step toward dropping reliance on page->mapping.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jeff Layton <jlayton@redhat.com>
---
 fs/exofs/inode.c          | 2 +-
 fs/ext4/inode.c           | 7 +++----
 fs/fuse/file.c            | 1 +
 fs/mpage.c                | 6 +++---
 fs/nfs/write.c            | 4 +++-
 fs/xfs/xfs_aops.c         | 3 ++-
 include/linux/writeback.h | 4 ++--
 mm/page-writeback.c       | 9 ++++-----
 8 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 41f6b04cbfca..54d6b7dbd4e7 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -691,7 +691,7 @@ static int write_exec(struct page_collect *pcol)
  * previous segment and will start a new collection.
  * Eventually caller must submit the last segment if present.
  */
-static int writepage_strip(struct page *page,
+static int writepage_strip(struct page *page, struct address_space *mapping,
 			   struct writeback_control *wbc_unused, void *data)
 {
 	struct page_collect *pcol = data;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 96dcae1937c8..63bf0160c579 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2697,10 +2697,9 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 	return err;
 }
 
-static int __writepage(struct page *page, struct writeback_control *wbc,
-		       void *data)
+static int __writepage(struct page *page, struct address_space *mapping,
+		       struct writeback_control *wbc, void *data)
 {
-	struct address_space *mapping = data;
 	int ret = ext4_writepage(mapping, page, wbc);
 	mapping_set_error(mapping, ret);
 	return ret;
@@ -2746,7 +2745,7 @@ static int ext4_writepages(struct address_space *mapping,
 		struct blk_plug plug;
 
 		blk_start_plug(&plug);
-		ret = write_cache_pages(mapping, wbc, __writepage, mapping);
+		ret = write_cache_pages(mapping, wbc, __writepage, NULL);
 		blk_finish_plug(&plug);
 		goto out_writepages;
 	}
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 3c602632b33a..e0562d04d84f 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1794,6 +1794,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 }
 
 static int fuse_writepages_fill(struct page *page,
+		struct address_space *mapping,
 		struct writeback_control *wbc, void *_data)
 {
 	struct fuse_fill_wb_data *data = _data;
diff --git a/fs/mpage.c b/fs/mpage.c
index b03a82d5b908..d25f08f46090 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -479,8 +479,8 @@ void clean_page_buffers(struct page *page)
 	clean_buffers(page, ~0U);
 }
 
-static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
-		      void *data)
+static int __mpage_writepage(struct page *page, struct address_space *_mapping,
+			     struct writeback_control *wbc, void *data)
 {
 	struct mpage_data *mpd = data;
 	struct bio *bio = mpd->bio;
@@ -734,7 +734,7 @@ int mpage_writepage(struct page *page, get_block_t get_block,
 		.get_block = get_block,
 		.use_writepage = 0,
 	};
-	int ret = __mpage_writepage(page, wbc, &mpd);
+	int ret = __mpage_writepage(page, page->mapping, wbc, &mpd);
 	if (mpd.bio) {
 		int op_flags = (wbc->sync_mode == WB_SYNC_ALL ?
 			  REQ_SYNC : 0);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1f7723eff542..ffab026b9632 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -693,7 +693,9 @@ int nfs_writepage(struct address_space *mapping, struct page *page,
 	return ret;
 }
 
-static int nfs_writepages_callback(struct page *page, struct writeback_control *wbc, void *data)
+static int nfs_writepages_callback(struct page *page,
+				   struct address_space *mapping,
+				   struct writeback_control *wbc, void *data)
 {
 	int ret;
 
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 981a2a4e00e5..00922a82ede6 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1060,6 +1060,7 @@ xfs_writepage_map(
 STATIC int
 xfs_do_writepage(
 	struct page		*page,
+	struct address_space	*mapping,
 	struct writeback_control *wbc,
 	void			*data)
 {
@@ -1179,7 +1180,7 @@ xfs_vm_writepage(
 	};
 	int			ret;
 
-	ret = xfs_do_writepage(page, wbc, &wpc);
+	ret = xfs_do_writepage(page, mapping, wbc, &wpc);
 	if (wpc.ioend)
 		ret = xfs_submit_ioend(wbc, wpc.ioend, ret);
 	return ret;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index fdfd04e348f6..70361cc0ff54 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -358,8 +358,8 @@ void wb_update_bandwidth(struct bdi_writeback *wb, unsigned long start_time);
 void balance_dirty_pages_ratelimited(struct address_space *mapping);
 bool wb_over_bg_thresh(struct bdi_writeback *wb);
 
-typedef int (*writepage_t)(struct page *page, struct writeback_control *wbc,
-				void *data);
+typedef int (*writepage_t)(struct page *page, struct address_space *mapping,
+			   struct writeback_control *wbc, void *data);
 
 int generic_writepages(struct address_space *mapping,
 		       struct writeback_control *wbc);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 5bb8804967ca..67b857ee1a1c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2236,7 +2236,7 @@ int write_cache_pages(struct address_space *mapping,
 				goto continue_unlock;
 
 			trace_wbc_writepage(wbc, inode_to_bdi(mapping->host));
-			ret = (*writepage)(page, wbc, data);
+			ret = (*writepage)(page, mapping, wbc, data);
 			if (unlikely(ret)) {
 				if (ret == AOP_WRITEPAGE_ACTIVATE) {
 					unlock_page(page);
@@ -2294,10 +2294,9 @@ EXPORT_SYMBOL(write_cache_pages);
  * Function used by generic_writepages to call the real writepage
  * function and set the mapping flags on error
  */
-static int __writepage(struct page *page, struct writeback_control *wbc,
-		       void *data)
+static int __writepage(struct page *page, struct address_space *mapping,
+		       struct writeback_control *wbc, void *data)
 {
-	struct address_space *mapping = data;
 	int ret = mapping->a_ops->writepage(mapping, page, wbc);
 	mapping_set_error(mapping, ret);
 	return ret;
@@ -2322,7 +2321,7 @@ int generic_writepages(struct address_space *mapping,
 		return 0;
 
 	blk_start_plug(&plug);
-	ret = write_cache_pages(mapping, wbc, __writepage, mapping);
+	ret = write_cache_pages(mapping, wbc, __writepage, NULL);
 	blk_finish_plug(&plug);
 	return ret;
 }
-- 
2.14.3
