Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A640A6B015C
	for <linux-mm@kvack.org>; Wed, 29 May 2013 19:17:51 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 8/8] fs: nfs: Inform the VM about pages being committed or unstable
Date: Thu, 30 May 2013 00:17:37 +0100
Message-Id: <1369869457-22570-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1369869457-22570-1-git-send-email-mgorman@suse.de>
References: <1369869457-22570-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

VM page reclaim uses dirty and writeback page states to determine if
flushers are cleaning pages too slowly and that page reclaim should
stall waiting on flushers to catch up. Page state in NFS is a bit
more complex and a clean page can be unreclaimable due to being
unstable which is effectively "dirty" from the perspective of the
VM from reclaim context. Similarly, if the inode is currently being
committed then it's similar to being under writeback.

This patch adds a is_dirty_writeback() handled for NFS that checks
if a pages backing inode is being committed and should be accounted as
writeback and if a page has private state indicating that it is
effectively dirty.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/nfs/file.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index a87a44f..a4250a4 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -493,6 +493,35 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 	return nfs_fscache_release_page(page, gfp);
 }
 
+static void nfs_check_dirty_writeback(struct page *page,
+				bool *dirty, bool *writeback)
+{
+	struct nfs_inode *nfsi;
+	struct address_space *mapping = page_file_mapping(page);
+
+	if (!mapping || PageSwapCache(page))
+		return;
+
+	/*
+	 * Check if an unstable page is currently being committed and
+	 * if so, have the VM treat it as if the page is under writeback
+	 * so it will not block due to pages that will shortly be freeable.
+	 */
+	nfsi = NFS_I(mapping->host);
+	if (test_bit(NFS_INO_COMMIT, &nfsi->flags)) {
+		*writeback = true;
+		return;
+	}
+
+	/*
+	 * If PagePrivate() is set, then the page is not freeable and as the
+	 * inode is not being committed, it's not going to be cleaned in the
+	 * near future so treat it as dirty
+	 */
+	if (PagePrivate(page))
+		*dirty = true;
+}
+
 /*
  * Attempt to clear the private state associated with a page when an error
  * occurs that requires the cached contents of an inode to be written back or
@@ -540,6 +569,7 @@ const struct address_space_operations nfs_file_aops = {
 	.direct_IO = nfs_direct_IO,
 	.migratepage = nfs_migrate_page,
 	.launder_page = nfs_launder_page,
+	.is_dirty_writeback = nfs_check_dirty_writeback,
 	.error_remove_page = generic_error_remove_page,
 #ifdef CONFIG_NFS_SWAP
 	.swap_activate = nfs_swap_activate,
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
