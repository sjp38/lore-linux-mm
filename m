Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 0CADE6B00A3
	for <linux-mm@kvack.org>; Tue, 14 May 2013 12:38:13 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH v4 14/20] ext4: truncate_inode_pages() in orphan cleanup path
Date: Tue, 14 May 2013 18:37:28 +0200
Message-Id: <1368549454-8930-15-git-send-email-lczerner@redhat.com>
In-Reply-To: <1368549454-8930-1-git-send-email-lczerner@redhat.com>
References: <1368549454-8930-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, hughd@google.com, lczerner@redhat.com

Currently we do not tell mm to zero out tail of the page before truncate
in orphan_cleanup(). This is ok, because the page should not be
uptodate, however this may eventually change and I might cause problems.

Call truncate_inode_pages() as precautionary measure. Thanks Jan Kara
for pointing this out.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 fs/ext4/super.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index dbc7c09..b971066 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -2173,6 +2173,7 @@ static void ext4_orphan_cleanup(struct super_block *sb,
 			jbd_debug(2, "truncating inode %lu to %lld bytes\n",
 				  inode->i_ino, inode->i_size);
 			mutex_lock(&inode->i_mutex);
+			truncate_inode_pages(inode->i_mapping, inode->i_size);
 			ext4_truncate(inode);
 			mutex_unlock(&inode->i_mutex);
 			nr_truncates++;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
