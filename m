Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 67E208E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 07:53:25 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m19so5894391edc.6
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 04:53:25 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o13si1491076edr.264.2018.12.21.04.53.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 04:53:23 -0800 (PST)
From: Nikolay Borisov <nborisov@suse.com>
Subject: [PATCH] mm: Define VM_(MAX|MIN)_READAHEAD via sizes.h constants
Date: Fri, 21 Dec 2018 14:53:14 +0200
Message-Id: <20181221125314.5177-1-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org, linux-fsdevel@vger.kernel.org, Nikolay Borisov <nborisov@suse.com>

All users of the aformentioned macros convert them to kbytes by
multplying. Instead, directly define the macros via the aptly named
SZ_16K/SZ_128K ones. Also remove the now redundant comments explaining
that VM_* are defined in kbytes it's obvious. No functional changes.

Signed-off-by: Nikolay Borisov <nborisov@suse.com>
---

I guess it makes sense for this to land via Andrew's mmotm tree?

 block/blk-core.c   | 3 +--
 fs/9p/vfs_super.c  | 2 +-
 fs/afs/super.c     | 2 +-
 fs/btrfs/disk-io.c | 2 +-
 fs/fuse/inode.c    | 2 +-
 include/linux/mm.h | 5 +++--
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index deb56932f8c4..d28b2eeec07e 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1031,8 +1031,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id,
 	if (!q->stats)
 		goto fail_stats;
 
-	q->backing_dev_info->ra_pages =
-			(VM_MAX_READAHEAD * 1024) / PAGE_SIZE;
+	q->backing_dev_info->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;
 	q->backing_dev_info->capabilities = BDI_CAP_CGROUP_WRITEBACK;
 	q->backing_dev_info->name = "block";
 	q->node = node_id;
diff --git a/fs/9p/vfs_super.c b/fs/9p/vfs_super.c
index 48ce50484e80..5c9f757410ae 100644
--- a/fs/9p/vfs_super.c
+++ b/fs/9p/vfs_super.c
@@ -92,7 +92,7 @@ v9fs_fill_super(struct super_block *sb, struct v9fs_session_info *v9ses,
 		return ret;
 
 	if (v9ses->cache)
-		sb->s_bdi->ra_pages = (VM_MAX_READAHEAD * 1024)/PAGE_SIZE;
+		sb->s_bdi->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;
 
 	sb->s_flags |= SB_ACTIVE | SB_DIRSYNC;
 	if (!v9ses->cache)
diff --git a/fs/afs/super.c b/fs/afs/super.c
index dcd07fe99871..d1f3af74481a 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -399,7 +399,7 @@ static int afs_fill_super(struct super_block *sb,
 	ret = super_setup_bdi(sb);
 	if (ret)
 		return ret;
-	sb->s_bdi->ra_pages	= VM_MAX_READAHEAD * 1024 / PAGE_SIZE;
+	sb->s_bdi->ra_pages	= VM_MAX_READAHEAD / PAGE_SIZE;
 
 	/* allocate the root inode and dentry */
 	if (as->dyn_root) {
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 6d776717d8b3..d84e7283d24b 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -2900,7 +2900,7 @@ int open_ctree(struct super_block *sb,
 	sb->s_bdi->congested_fn = btrfs_congested_fn;
 	sb->s_bdi->congested_data = fs_info;
 	sb->s_bdi->capabilities |= BDI_CAP_CGROUP_WRITEBACK;
-	sb->s_bdi->ra_pages = VM_MAX_READAHEAD * SZ_1K / PAGE_SIZE;
+	sb->s_bdi->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;
 	sb->s_bdi->ra_pages *= btrfs_super_num_devices(disk_super);
 	sb->s_bdi->ra_pages = max(sb->s_bdi->ra_pages, SZ_4M / PAGE_SIZE);
 
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 568abed20eb2..25766e9035b1 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -1009,7 +1009,7 @@ static int fuse_bdi_init(struct fuse_conn *fc, struct super_block *sb)
 	if (err)
 		return err;
 
-	sb->s_bdi->ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_SIZE;
+	sb->s_bdi->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;
 	/* fuse does it's own writeback accounting */
 	sb->s_bdi->capabilities = BDI_CAP_NO_ACCT_WB | BDI_CAP_STRICTLIMIT;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..e2085eaceae9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -26,6 +26,7 @@
 #include <linux/page_ref.h>
 #include <linux/memremap.h>
 #include <linux/overflow.h>
+#include <linux/sizes.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -2396,8 +2397,8 @@ int __must_check write_one_page(struct page *page);
 void task_dirty_inc(struct task_struct *tsk);
 
 /* readahead.c */
-#define VM_MAX_READAHEAD	128	/* kbytes */
-#define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
+#define VM_MAX_READAHEAD	SZ_128K
+#define VM_MIN_READAHEAD	SZ_16K	/* includes current page */
 
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read);
-- 
2.17.1
