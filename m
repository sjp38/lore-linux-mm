Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 03BE56B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 17:26:38 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1653506pbb.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 14:26:38 -0700 (PDT)
From: raghu.prabhu13@gmail.com
Subject: [PATCH v2] Change the check for PageReadahead into an else-if
Date: Thu, 25 Oct 2012 02:56:04 +0530
Message-Id: <05ff4f71283e84be8ab1b312864168d89535239f.1351113536.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com, fengguang.wu@intel.com, zheng.z.yan@intel.com
Cc: linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

From: Raghavendra D Prabhu <rprabhu@wnohang.net>

>From 51daa88ebd8e0d437289f589af29d4b39379ea76, page_sync_readahead coalesces
async readahead into its readahead window, so another checking for that again is
not required.

Version 2: Fixed the incorrect indentation.

Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
---
 fs/btrfs/relocation.c | 4 +---
 mm/filemap.c          | 3 +--
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/btrfs/relocation.c b/fs/btrfs/relocation.c
index 776f0aa..8cfa1ab 100644
--- a/fs/btrfs/relocation.c
+++ b/fs/btrfs/relocation.c
@@ -2996,9 +2996,7 @@ static int relocate_file_extent_cluster(struct inode *inode,
 				ret = -ENOMEM;
 				goto out;
 			}
-		}
-
-		if (PageReadahead(page)) {
+		} else if (PageReadahead(page)) {
 			page_cache_async_readahead(inode->i_mapping,
 						   ra, NULL, page, index,
 						   last_index + 1 - index);
diff --git a/mm/filemap.c b/mm/filemap.c
index 83efee7..aa440f16 100644
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
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
