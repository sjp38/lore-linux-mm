Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C9FFB6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 05:50:44 -0400 (EDT)
Received: by wgck11 with SMTP id k11so4717845wgc.0
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 02:50:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8si24914829wia.75.2015.06.23.02.50.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Jun 2015 02:50:43 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] ext4: replace open coded nofail allocation
Date: Tue, 23 Jun 2015 11:50:37 +0200
Message-Id: <1435053037-1451-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

ext4_free_blocks is looping around the allocation request and mimics
__GFP_NOFAIL behavior without any allocation fallback strategy. Let's
remove the open coded loop and replace it with __GFP_NOFAIL. Without
the flag the allocator has no way to find out never-fail requirement
and cannot help in any way.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---

Hi Ted,
I am sorry for seding these changes one at the time but I haven't found
a proper way to find all of them automatically. So I am discovering
them as I check the code due to other reasons.

Thanks!

 fs/ext4/mballoc.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index 8d1e60214ef0..41260489d3bc 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -4800,18 +4800,12 @@ void ext4_free_blocks(handle_t *handle, struct inode *inode,
 		/*
 		 * blocks being freed are metadata. these blocks shouldn't
 		 * be used until this transaction is committed
+		 *
+		 * We use __GFP_NOFAIL because ext4_free_blocks() is not allowed
+		 * to fail.
 		 */
-	retry:
-		new_entry = kmem_cache_alloc(ext4_free_data_cachep, GFP_NOFS);
-		if (!new_entry) {
-			/*
-			 * We use a retry loop because
-			 * ext4_free_blocks() is not allowed to fail.
-			 */
-			cond_resched();
-			congestion_wait(BLK_RW_ASYNC, HZ/50);
-			goto retry;
-		}
+		new_entry = kmem_cache_alloc(ext4_free_data_cachep,
+				GFP_NOFS|__GFP_NOFAIL);
 		new_entry->efd_start_cluster = bit;
 		new_entry->efd_group = block_group;
 		new_entry->efd_count = count_clusters;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
