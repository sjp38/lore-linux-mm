Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5E46B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 16:18:01 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id o185so6277051pfb.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:18:01 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 66si5294605pfs.142.2016.01.27.13.18.00
        for <linux-mm@kvack.org>;
        Wed, 27 Jan 2016 13:18:00 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 3/5] btrfs: Use radix_tree_iter_retry()
Date: Wed, 27 Jan 2016 16:17:50 -0500
Message-Id: <1453929472-25566-4-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

Even though this is a 'can't happen' situation, use the new
radix_tree_iter_retry() pattern to eliminate a goto.
---
 fs/btrfs/tests/btrfs-tests.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/btrfs/tests/btrfs-tests.c b/fs/btrfs/tests/btrfs-tests.c
index b1d920b30070..0da78c54317a 100644
--- a/fs/btrfs/tests/btrfs-tests.c
+++ b/fs/btrfs/tests/btrfs-tests.c
@@ -137,7 +137,6 @@ static void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
 	void **slot;
 
 	spin_lock(&fs_info->buffer_lock);
-restart:
 	radix_tree_for_each_slot(slot, &fs_info->buffer_radix, &iter, 0) {
 		struct extent_buffer *eb;
 
@@ -147,7 +146,7 @@ restart:
 		/* Shouldn't happen but that kind of thinking creates CVE's */
 		if (radix_tree_exception(eb)) {
 			if (radix_tree_deref_retry(eb))
-				goto restart;
+				slot = radix_tree_iter_retry(iter);
 			continue;
 		}
 		spin_unlock(&fs_info->buffer_lock);
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
