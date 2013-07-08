Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id F1B2B6B0044
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 05:52:10 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id gw10so3664209lab.30
        for <linux-mm@kvack.org>; Mon, 08 Jul 2013 02:52:09 -0700 (PDT)
Subject: [PATCH 2/5] nfs: remove redundant cancel_dirty_page() from
 nfs_wb_page_cancel()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 08 Jul 2013 13:52:06 +0400
Message-ID: <20130708095206.13810.31538.stgit@zurg>
In-Reply-To: <20130708095202.13810.11659.stgit@zurg>
References: <20130708095202.13810.11659.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

This chunk was added by commit 1b3b4a1a2deb7d3e5d66063bd76304d840c966b3
("NFS: Fix a write request leak in nfs_invalidate_page()") in kernel 2.6.23,
as fix for problem introduced in commit 3e67c0987d7567ad666641164a153dca9a43b11d
("[PATCH] truncate: clear page dirtiness before running try_to_free_buffers()")
in v2.6.20, which has placed cancel_dirty_page() in truncate_complete_page()
before calling do_invalidatepage(). But that change in truncate_complete_page()
was reverted by commit a2b345642f530054a92b8d2b5108436225a8093e in v2.6.25
("Fix dirty page accounting leak with ext3 data=journal").

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/write.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index a2c7c28..737981f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1735,11 +1735,6 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 		if (nfs_lock_request(req)) {
 			nfs_clear_request_commit(req);
 			nfs_inode_remove_request(req);
-			/*
-			 * In case nfs_inode_remove_request has marked the
-			 * page as being dirty
-			 */
-			cancel_dirty_page(page, PAGE_CACHE_SIZE);
 			nfs_unlock_and_release_request(req);
 			break;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
