Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B28ED6B007E
	for <linux-mm@kvack.org>; Sat,  9 Jul 2011 15:42:13 -0400 (EDT)
Received: by pvc12 with SMTP id 12so2267056pvc.14
        for <linux-mm@kvack.org>; Sat, 09 Jul 2011 12:42:11 -0700 (PDT)
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: [PATCH 3/3] mm/readahead: Move the check for ra_pages after VM_SequentialReadHint()
Date: Sun, 10 Jul 2011 01:11:20 +0530
Message-Id: <323ddfc402a7f7b94f0cb02bba15acb2acca786f.1310239575.git.rprabhu@wnohang.net>
In-Reply-To: <cover.1310239575.git.rprabhu@wnohang.net>
References: <cover.1310239575.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

page_cache_sync_readahead checks for ra->ra_pages again, so moving the check after VM_SequentialReadHint.

Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
---
 mm/filemap.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 074c23d..748f720 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1566,8 +1566,6 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 	/* If we don't want any read-ahead, don't bother */
 	if (VM_RandomReadHint(vma))
 		return;
-	if (!ra->ra_pages)
-		return;
 
 	if (VM_SequentialReadHint(vma)) {
 		page_cache_sync_readahead(mapping, ra, file, offset,
@@ -1575,6 +1573,9 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 		return;
 	}
 
+	if (!ra->ra_pages)
+		return;
+
 	/* Avoid banging the cache line if not needed */
 	if (ra->mmap_miss < MMAP_LOTSAMISS * 10)
 		ra->mmap_miss++;
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
