Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id E95906B006C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 05:15:08 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH v3 15/18] ext4: remove unused code from ext4_remove_blocks()
Date: Tue,  9 Apr 2013 11:14:24 +0200
Message-Id: <1365498867-27782-16-git-send-email-lczerner@redhat.com>
In-Reply-To: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Lukas Czerner <lczerner@redhat.com>

The "head removal" branch in the condition is never used in any code
path in ext4 since the function only caller ext4_ext_rm_leaf() will make
sure that the extent is properly split before removing blocks. Note that
there is a bug in this branch anyway.

This commit removes the unused code completely and makes use of
ext4_error() instead of printk if dubious range is provided.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 fs/ext4/extents.c |   21 ++++-----------------
 1 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index 6c5a70a..4adaa8a 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -2435,23 +2435,10 @@ static int ext4_remove_blocks(handle_t *handle, struct inode *inode,
 			*partial_cluster = EXT4_B2C(sbi, pblk);
 		else
 			*partial_cluster = 0;
-	} else if (from == le32_to_cpu(ex->ee_block)
-		   && to <= le32_to_cpu(ex->ee_block) + ee_len - 1) {
-		/* head removal */
-		ext4_lblk_t num;
-		ext4_fsblk_t start;
-
-		num = to - from;
-		start = ext4_ext_pblock(ex);
-
-		ext_debug("free first %u blocks starting %llu\n", num, start);
-		ext4_free_blocks(handle, inode, NULL, start, num, flags);
-
-	} else {
-		printk(KERN_INFO "strange request: removal(2) "
-				"%u-%u from %u:%u\n",
-				from, to, le32_to_cpu(ex->ee_block), ee_len);
-	}
+	} else
+		ext4_error(sbi->s_sb, "strange request: removal(2) "
+			   "%u-%u from %u:%u\n",
+			   from, to, le32_to_cpu(ex->ee_block), ee_len);
 	return 0;
 }
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
