Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id E93876B0037
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 11:03:37 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id l4so8941748lbv.30
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 08:03:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kz8si19086995lab.23.2014.09.23.08.03.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 08:03:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/2] ext4: Fix mmap data corruption when blocksize < pagesize
Date: Tue, 23 Sep 2014 17:03:23 +0200
Message-Id: <1411484603-17756-3-git-send-email-jack@suse.cz>
In-Reply-To: <1411484603-17756-1-git-send-email-jack@suse.cz>
References: <1411484603-17756-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org, Ted Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>

Use block_create_hole() when hole is being created in a file so that
->page_mkwrite() will get called for the partial tail page if it is
mmaped (see the first patch in the series for details).

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/inode.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 3aa26e9117c4..fdcb007c2c9e 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4536,8 +4536,12 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 				ext4_orphan_del(NULL, inode);
 				goto err_out;
 			}
-		} else
+		} else {
+			loff_t old_size = inode->i_size;
+
 			i_size_write(inode, attr->ia_size);
+			block_create_hole(inode, old_size, inode->i_size);
+		}
 
 		/*
 		 * Blocks are going to be removed from the inode. Wait
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
