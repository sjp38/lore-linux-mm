Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19C5E280254
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 09:07:59 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id j10so23406493wjb.3
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 06:07:59 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id uz2si2222302wjb.9.2016.12.15.06.07.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 06:07:57 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id g23so6721939wme.1
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 06:07:57 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 8/9] Revert "ext4: avoid deadlocks in the writeback path by using sb_getblk_gfp"
Date: Thu, 15 Dec 2016 15:07:14 +0100
Message-Id: <20161215140715.12732-9-mhocko@kernel.org>
In-Reply-To: <20161215140715.12732-1-mhocko@kernel.org>
References: <20161215140715.12732-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

This reverts commit c45653c341f5c8a0ce19c8f0ad4678640849cb86 because
sb_getblk_gfp is not really needed as
sb_getblk
  __getblk_gfp
    __getblk_slow
      grow_buffers
        grow_dev_page
	  gfp_mask = mapping_gfp_constraint(inode->i_mapping, ~__GFP_FS) | gfp

so __GFP_FS is cleared unconditionally and therefore the above commit
didn't have any real effect in fact.

This patch should not introduce any functional change. The main point
of this change is to reduce explicit GFP_NOFS usage inside ext4 code to
make the review of the remaining usage easier.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/ext4/extents.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index b1f8416923ab..ef815eb72389 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -518,7 +518,7 @@ __read_extent_tree_block(const char *function, unsigned int line,
 	struct buffer_head		*bh;
 	int				err;
 
-	bh = sb_getblk_gfp(inode->i_sb, pblk, __GFP_MOVABLE | GFP_NOFS);
+	bh = sb_getblk(inode->i_sb, pblk);
 	if (unlikely(!bh))
 		return ERR_PTR(-ENOMEM);
 
@@ -1096,7 +1096,7 @@ static int ext4_ext_split(handle_t *handle, struct inode *inode,
 		err = -EFSCORRUPTED;
 		goto cleanup;
 	}
-	bh = sb_getblk_gfp(inode->i_sb, newblock, __GFP_MOVABLE | GFP_NOFS);
+	bh = sb_getblk(inode->i_sb, newblock);
 	if (unlikely(!bh)) {
 		err = -ENOMEM;
 		goto cleanup;
@@ -1290,7 +1290,7 @@ static int ext4_ext_grow_indepth(handle_t *handle, struct inode *inode,
 	if (newblock == 0)
 		return err;
 
-	bh = sb_getblk_gfp(inode->i_sb, newblock, __GFP_MOVABLE | GFP_NOFS);
+	bh = sb_getblk(inode->i_sb, newblock);
 	if (unlikely(!bh))
 		return -ENOMEM;
 	lock_buffer(bh);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
