Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0DD6B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:47:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w13so13234285wmw.0
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:47:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tr13si35884241wjb.191.2016.11.24.01.47.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Nov 2016 01:47:01 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/6] ext2: Return BH_New buffers for zeroed blocks
Date: Thu, 24 Nov 2016 10:46:31 +0100
Message-Id: <1479980796-26161-2-git-send-email-jack@suse.cz>
In-Reply-To: <1479980796-26161-1-git-send-email-jack@suse.cz>
References: <1479980796-26161-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>

So far we did not return BH_New buffers from ext2_get_blocks() when we
allocated and zeroed-out a block for DAX inode to avoid racy zeroing in
DAX code. This zeroing is gone these days so we can remove the
workaround.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext2/inode.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 046b642f3585..e626fe892c01 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -754,9 +754,8 @@ static int ext2_get_blocks(struct inode *inode,
 			mutex_unlock(&ei->truncate_mutex);
 			goto cleanup;
 		}
-	} else {
-		*new = true;
 	}
+	*new = true;
 
 	ext2_splice_branch(inode, iblock, partial, indirect_blks, count);
 	mutex_unlock(&ei->truncate_mutex);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
