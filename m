Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 83A796B0256
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 22:34:39 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id q63so3313557pfb.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:34:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id uv2si55489081pac.41.2016.02.16.19.34.38
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 19:34:38 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 3/6] ext4: Online defrag not supported with DAX
Date: Tue, 16 Feb 2016 20:34:16 -0700
Message-Id: <1455680059-20126-4-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

Online defrag operations for ext4 are hard coded to use the page cache.
See ext4_ioctl() -> ext4_move_extents() -> move_extent_per_page()

When combined with DAX I/O, which circumvents the page cache, this can
result in data corruption.  This was observed with xfstests ext4/307 and
ext4/308.

Fix this by only allowing online defrag for non-DAX files.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/ext4/ioctl.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index 0f6c369..e32c86f 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -583,6 +583,11 @@ group_extend_out:
 				 "Online defrag not supported with bigalloc");
 			err = -EOPNOTSUPP;
 			goto mext_out;
+		} else if (IS_DAX(inode)) {
+			ext4_msg(sb, KERN_ERR,
+				 "Online defrag not supported with DAX");
+			err = -EOPNOTSUPP;
+			goto mext_out;
 		}
 
 		err = mnt_want_write_file(filp);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
