Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 4A16C6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 14:58:13 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so7024922pad.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 11:58:12 -0700 (PDT)
From: raghu.prabhu13@gmail.com
Subject: [PATCH] Change the check for PageReadahead into an else-if
Date: Wed, 17 Oct 2012 00:28:05 +0530
Message-Id: <08589dd39c78346ec2ed2fedfd6e3121ca38acda.1350413420.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zheng.yan@oracle.com, fengguang.wu@intel.com
Cc: linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

From: Raghavendra D Prabhu <rprabhu@wnohang.net>

>From 51daa88ebd8e0d437289f589af29d4b39379ea76, page_sync_readahead coalesces
async readahead into its readahead window, so another checking for that again is
not required.

Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
---
 fs/btrfs/relocation.c | 10 ++++------
 mm/filemap.c          |  3 +--
 2 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/fs/btrfs/relocation.c b/fs/btrfs/relocation.c
index 4da0865..6362003 100644
--- a/fs/btrfs/relocation.c
+++ b/fs/btrfs/relocation.c
@@ -2996,12 +2996,10 @@ static int relocate_file_extent_cluster(struct inode *inode,
 				ret = -ENOMEM;
 				goto out;
 			}
-		}
-
-		if (PageReadahead(page)) {
-			page_cache_async_readahead(inode->i_mapping,
-						   ra, NULL, page, index,
-						   last_index + 1 - index);
+		} else if (PageReadahead(page)) {
+				page_cache_async_readahead(inode->i_mapping,
+							ra, NULL, page, index,
+							last_index + 1 - index);
 		}
 
 		if (!PageUptodate(page)) {
diff --git a/mm/filemap.c b/mm/filemap.c
index 3843445..d703224 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1113,8 +1113,7 @@ find_page:
 			page = find_get_page(mapping, index);
 			if (unlikely(page == NULL))
 				goto no_cached_page;
-		}
-		if (PageReadahead(page)) {
+		} else if (PageReadahead(page)) {
 			page_cache_async_readahead(mapping,
 					ra, filp, page,
 					index, last_index - index);
-- 
1.7.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
