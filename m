Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 53FA96B004D
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 04:02:38 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/4] fs: Remove bogus wait in write_inode_now()
Date: Fri,  9 Mar 2012 10:02:25 +0100
Message-Id: <1331283748-12959-2-git-send-email-jack@suse.cz>
In-Reply-To: <1331283748-12959-1-git-send-email-jack@suse.cz>
References: <1331283748-12959-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

inode_sync_wait() in write_inode_now() is just bogus. That function waits for
I_SYNC bit to be cleared but writeback_single_inode() clears the bit on return
so the wait is effectivelly a nop unless someone else submits the inode for
writeback again. All the waiting write_inode_now() needs is achieved by using
WB_SYNC_ALL writeback mode.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 5b4a936..f60297b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1364,8 +1364,6 @@ int write_inode_now(struct inode *inode, int sync)
 	ret = writeback_single_inode(inode, wb, &wbc);
 	spin_unlock(&inode->i_lock);
 	spin_unlock(&wb->list_lock);
-	if (sync)
-		inode_sync_wait(inode);
 	return ret;
 }
 EXPORT_SYMBOL(write_inode_now);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
