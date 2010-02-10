Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 84ED862000B
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:53 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 13/13] NFS: Don't write out dirty pages in nfs_release_page()
Date: Wed, 10 Feb 2010 12:03:33 -0500
Message-Id: <1265821413-21618-14-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-13-git-send-email-Trond.Myklebust@netapp.com>
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
 <1265821413-21618-12-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-13-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

This causes too many commits in shrink_page_list()...

Reported-by: Steve Rago <sar@nec-labs.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 63f2071..dcba521 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -486,6 +486,13 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 {
 	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
 
+	/* See comment in shrink_page_list(): although the VM may
+	 * call this function on a dirty page, we are not expected
+	 * to initiate writeback on it.
+	 */
+	if (PageDirty(page) || !page->mapping)
+		return 0;
+
 	if (gfp & __GFP_WAIT)
 		nfs_wb_page(page->mapping->host, page);
 	/* If PagePrivate() is set, then the page is not freeable */
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
