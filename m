Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 412156B0255
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 22:34:38 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id yy13so3197356pab.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:34:38 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id uv2si55489081pac.41.2016.02.16.19.34.37
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 19:34:37 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 2/6] ext2, ext4: only set S_DAX for regular inodes
Date: Tue, 16 Feb 2016 20:34:15 -0700
Message-Id: <1455680059-20126-3-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

When S_DAX is set on an inode we assume that if there are pages attached
to the mapping (mapping->nrpages != 0), those pages are clean zero pages
that were used to service reads from holes.  Any dirty data associated with
the inode should be in the form of DAX exceptional entries
(mapping->nrexceptional) that is written back via
dax_writeback_mapping_range().

With the current code, though, this isn't always true.  For example, ext2
and ext4 directory inodes can have S_DAX set, but have their dirty data
stored as dirty page cache entries.  For these types of inodes, having
S_DAX set doesn't really make sense since their I/O doesn't actually happen
through the DAX code path.

Instead, only allow S_DAX to be set for regular inodes for ext2 and ext4.
This allows us to have strict DAX vs non-DAX paths in the writeback code.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/ext2/inode.c | 2 +-
 fs/ext4/inode.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 338eefd..27e2cdd 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -1296,7 +1296,7 @@ void ext2_set_inode_flags(struct inode *inode)
 		inode->i_flags |= S_NOATIME;
 	if (flags & EXT2_DIRSYNC_FL)
 		inode->i_flags |= S_DIRSYNC;
-	if (test_opt(inode->i_sb, DAX))
+	if (test_opt(inode->i_sb, DAX) && S_ISREG(inode->i_mode))
 		inode->i_flags |= S_DAX;
 }
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 83bc8bf..7088aa5 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4127,7 +4127,7 @@ void ext4_set_inode_flags(struct inode *inode)
 		new_fl |= S_NOATIME;
 	if (flags & EXT4_DIRSYNC_FL)
 		new_fl |= S_DIRSYNC;
-	if (test_opt(inode->i_sb, DAX))
+	if (test_opt(inode->i_sb, DAX) && S_ISREG(inode->i_mode))
 		new_fl |= S_DAX;
 	inode_set_flags(inode, new_fl,
 			S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC|S_DAX);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
