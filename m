Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3A8176B0089
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:54 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/13] NFS: Clean up nfs_sync_mapping
Date: Wed, 10 Feb 2010 12:03:31 -0500
Message-Id: <1265821413-21618-12-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-11-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-5-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-6-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-7-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-8-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-9-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-10-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-11-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

Remove the redundant call to filemap_write_and_wait().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 13fe0dc..38e79e4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -114,16 +114,12 @@ void nfs_clear_inode(struct inode *inode)
  */
 int nfs_sync_mapping(struct address_space *mapping)
 {
-	int ret;
+	int ret = 0;
 
-	if (mapping->nrpages == 0)
-		return 0;
-	unmap_mapping_range(mapping, 0, 0, 0);
-	ret = filemap_write_and_wait(mapping);
-	if (ret != 0)
-		goto out;
-	ret = nfs_wb_all(mapping->host);
-out:
+	if (mapping->nrpages != 0) {
+		unmap_mapping_range(mapping, 0, 0, 0);
+		ret = nfs_wb_all(mapping->host);
+	}
 	return ret;
 }
 
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
