Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id B9D786B0068
	for <linux-mm@kvack.org>; Sat, 22 Sep 2012 06:33:53 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so10081941pbb.14
        for <linux-mm@kvack.org>; Sat, 22 Sep 2012 03:33:53 -0700 (PDT)
From: raghu.prabhu13@gmail.com
Subject: [PATCH 4/5] Move the check for ra_pages after VM_SequentialReadHint()
Date: Sat, 22 Sep 2012 16:03:13 +0530
Message-Id: <b3c8b02fb273826f864f64d4588b36758fde2b5d.1348309711.git.rprabhu@wnohang.net>
In-Reply-To: <cover.1348290849.git.rprabhu@wnohang.net>
References: <cover.1348290849.git.rprabhu@wnohang.net>
In-Reply-To: <cover.1348309711.git.rprabhu@wnohang.net>
References: <cover.1348309711.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: fengguang.wu@intel.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

From: Raghavendra D Prabhu <rprabhu@wnohang.net>

page_cache_sync_readahead checks for ra->ra_pages again, so moving the check
after VM_SequentialReadHint.

Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
---
 mm/filemap.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 3843445..606a648 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1523,8 +1523,6 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 	/* If we don't want any read-ahead, don't bother */
 	if (VM_RandomReadHint(vma))
 		return;
-	if (!ra->ra_pages)
-		return;
 
 	if (VM_SequentialReadHint(vma)) {
 		page_cache_sync_readahead(mapping, ra, file, offset,
@@ -1532,6 +1530,9 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 		return;
 	}
 
+	if (!ra->ra_pages)
+		return;
+
 	/* Avoid banging the cache line if not needed */
 	if (ra->mmap_miss < MMAP_LOTSAMISS * 10)
 		ra->mmap_miss++;
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
