Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 952F76B02C4
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 19:44:02 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id k69so4032541ioi.13
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 16:44:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x66sor1599108ite.147.2017.11.07.16.44.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 16:44:01 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] vfs: remove might_sleep() from clear_inode()
Date: Tue,  7 Nov 2017 16:43:54 -0800
Message-Id: <20171108004354.40308-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

Commit 7994e6f72543 ("vfs: Move waiting for inode writeback from
end_writeback() to evict_inode()") removed inode_sync_wait() from
end_writeback() and commit dbd5768f87ff ("vfs: Rename end_writeback()
to clear_inode()") renamed end_writeback() to clear_inode(). After
these patches there is no sleeping operation in clear_inode(). So,
remove might_sleep() from it.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 fs/inode.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/inode.c b/fs/inode.c
index d1e35b53bb23..528f3159b928 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -497,7 +497,6 @@ EXPORT_SYMBOL(__remove_inode_hash);
 
 void clear_inode(struct inode *inode)
 {
-	might_sleep();
 	/*
 	 * We have to cycle tree_lock here because reclaim can be still in the
 	 * process of removing the last page (in __delete_from_page_cache())
-- 
2.15.0.403.gc27cc4dac6-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
