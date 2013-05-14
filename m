Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D84226B009E
	for <linux-mm@kvack.org>; Tue, 14 May 2013 12:38:09 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH v4 12/20] ext4: Call ext4_jbd2_file_inode() after zeroing block
Date: Tue, 14 May 2013 18:37:26 +0200
Message-Id: <1368549454-8930-13-git-send-email-lczerner@redhat.com>
In-Reply-To: <1368549454-8930-1-git-send-email-lczerner@redhat.com>
References: <1368549454-8930-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, hughd@google.com, lczerner@redhat.com

In data=ordered mode we should call ext4_jbd2_file_inode() so that crash
after the truncate transaction has committed does not expose stall data
in the tail of the block.

Thanks Jan Kara for pointing that out.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 fs/ext4/inode.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 11c07e1..8187c3e 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3680,8 +3680,11 @@ int ext4_block_zero_page_range(handle_t *handle,
 	err = 0;
 	if (ext4_should_journal_data(inode)) {
 		err = ext4_handle_dirty_metadata(handle, inode, bh);
-	} else
+	} else {
 		mark_buffer_dirty(bh);
+		if (ext4_test_inode_state(inode, EXT4_STATE_ORDERED_MODE))
+			err = ext4_jbd2_file_inode(handle, inode);
+	}
 
 unlock:
 	unlock_page(page);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
