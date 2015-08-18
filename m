Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0839003C7
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 06:40:35 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so104655709wib.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 03:40:34 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id fq10si26529153wib.21.2015.08.18.03.40.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 03:40:33 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so96839865wic.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 03:40:33 -0700 (PDT)
Date: Tue, 18 Aug 2015 12:40:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC -v2 7/8] btrfs: Prevent from early transaction abort
Message-ID: <20150818104031.GF5033@dhcp22.suse.cz>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-8-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438768284-30927-8-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>

From: Michal Hocko <mhocko@suse.com>

Btrfs relies on GFP_NOFS allocation when commiting the transaction but
since "mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM"
those allocations are allowed to fail which can lead to a pre-mature
transaction abort:

[   55.328093] Call Trace:
[   55.328890]  [<ffffffff8154e6f0>] dump_stack+0x4f/0x7b
[   55.330518]  [<ffffffff8108fa28>] ? console_unlock+0x334/0x363
[   55.332738]  [<ffffffff8110873e>] __alloc_pages_nodemask+0x81d/0x8d4
[   55.334910]  [<ffffffff81100752>] pagecache_get_page+0x10e/0x20c
[   55.336844]  [<ffffffffa007d916>] alloc_extent_buffer+0xd0/0x350 [btrfs]
[   55.338973]  [<ffffffffa0059d8c>] btrfs_find_create_tree_block+0x15/0x17 [btrfs]
[   55.341329]  [<ffffffffa004f728>] btrfs_alloc_tree_block+0x18c/0x405 [btrfs]
[   55.343566]  [<ffffffffa003fa34>] split_leaf+0x1e4/0x6a6 [btrfs]
[   55.345577]  [<ffffffffa0040567>] btrfs_search_slot+0x671/0x831 [btrfs]
[   55.347679]  [<ffffffff810682d7>] ? get_parent_ip+0xe/0x3e
[   55.349434]  [<ffffffffa0041cb2>] btrfs_insert_empty_items+0x5d/0xa8 [btrfs]
[   55.351681]  [<ffffffffa004ecfb>] __btrfs_run_delayed_refs+0x7a6/0xf35 [btrfs]
[   55.353979]  [<ffffffffa00512ea>] btrfs_run_delayed_refs+0x6e/0x226 [btrfs]
[   55.356212]  [<ffffffffa0060e21>] ? start_transaction+0x192/0x534 [btrfs]
[   55.358378]  [<ffffffffa0060e21>] ? start_transaction+0x192/0x534 [btrfs]
[   55.360626]  [<ffffffffa0060221>] btrfs_commit_transaction+0x4c/0xaba [btrfs]
[   55.362894]  [<ffffffffa0060e21>] ? start_transaction+0x192/0x534 [btrfs]
[   55.365221]  [<ffffffffa0073428>] btrfs_sync_file+0x29c/0x310 [btrfs]
[   55.367273]  [<ffffffff81186808>] vfs_fsync_range+0x8f/0x9e
[   55.369047]  [<ffffffff81186833>] vfs_fsync+0x1c/0x1e
[   55.370654]  [<ffffffff81186869>] do_fsync+0x34/0x4e
[   55.372246]  [<ffffffff81186ab3>] SyS_fsync+0x10/0x14
[   55.373851]  [<ffffffff81554f97>] system_call_fastpath+0x12/0x6f
[   55.381070] BTRFS: error (device hdb1) in btrfs_run_delayed_refs:2821: errno=-12 Out of memory
[   55.382431] BTRFS warning (device hdb1): Skipping commit of aborted transaction.
[   55.382433] BTRFS warning (device hdb1): cleanup_transaction:1692: Aborting unused transaction(IO failure).
[   55.384280] ------------[ cut here ]------------
[   55.384312] WARNING: CPU: 0 PID: 3010 at fs/btrfs/delayed-ref.c:438 btrfs_select_ref_head+0xd9/0xfe [btrfs]()
[...]
[   55.384337] Call Trace:
[   55.384353]  [<ffffffff8154e6f0>] dump_stack+0x4f/0x7b
[   55.384357]  [<ffffffff8107f717>] ? down_trylock+0x2d/0x37
[   55.384359]  [<ffffffff81046977>] warn_slowpath_common+0xa1/0xbb
[   55.384398]  [<ffffffffa00a1d6b>] ? btrfs_select_ref_head+0xd9/0xfe [btrfs]
[   55.384400]  [<ffffffff81046a34>] warn_slowpath_null+0x1a/0x1c
[   55.384423]  [<ffffffffa00a1d6b>] btrfs_select_ref_head+0xd9/0xfe [btrfs]
[   55.384446]  [<ffffffffa004e5f7>] ? __btrfs_run_delayed_refs+0xa2/0xf35 [btrfs]
[   55.384455]  [<ffffffffa004e600>] __btrfs_run_delayed_refs+0xab/0xf35 [btrfs]
[   55.384476]  [<ffffffffa00512ea>] btrfs_run_delayed_refs+0x6e/0x226 [btrfs]
[   55.384499]  [<ffffffffa0060e21>] ? start_transaction+0x192/0x534 [btrfs]
[   55.384521]  [<ffffffffa0060e21>] ? start_transaction+0x192/0x534 [btrfs]
[   55.384543]  [<ffffffffa0060221>] btrfs_commit_transaction+0x4c/0xaba [btrfs]
[   55.384565]  [<ffffffffa0060e21>] ? start_transaction+0x192/0x534 [btrfs]
[   55.384588]  [<ffffffffa0073428>] btrfs_sync_file+0x29c/0x310 [btrfs]
[   55.384591]  [<ffffffff81186808>] vfs_fsync_range+0x8f/0x9e
[   55.384592]  [<ffffffff81186833>] vfs_fsync+0x1c/0x1e
[   55.384593]  [<ffffffff81186869>] do_fsync+0x34/0x4e
[   55.384594]  [<ffffffff81186ab3>] SyS_fsync+0x10/0x14
[   55.384595]  [<ffffffff81554f97>] system_call_fastpath+0x12/0x6f
[...]
[   55.384608] ---[ end trace c29799da1d4dd621 ]---
[   55.437323] BTRFS info (device hdb1): forced readonly
[   55.438815] BTRFS info (device hdb1): delayed_refs has NO entry

Fix this by reintroducing the no-fail behavior of this allocation path
with the explicit __GFP_NOFAIL.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/btrfs/extent_io.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index c374e1e71e5f..d855ddffd5fe 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -4607,9 +4607,7 @@ __alloc_extent_buffer(struct btrfs_fs_info *fs_info, u64 start,
 {
 	struct extent_buffer *eb = NULL;
 
-	eb = kmem_cache_zalloc(extent_buffer_cache, GFP_NOFS);
-	if (eb == NULL)
-		return NULL;
+	eb = kmem_cache_zalloc(extent_buffer_cache, GFP_NOFS|__GFP_NOFAIL);
 	eb->start = start;
 	eb->len = len;
 	eb->fs_info = fs_info;
@@ -4867,9 +4865,7 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 		return NULL;
 
 	for (i = 0; i < num_pages; i++, index++) {
-		p = find_or_create_page(mapping, index, GFP_NOFS);
-		if (!p)
-			goto free_eb;
+		p = find_or_create_page(mapping, index, GFP_NOFS|__GFP_NOFAIL);
 
 		spin_lock(&mapping->private_lock);
 		if (PagePrivate(p)) {
-- 
2.5.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
