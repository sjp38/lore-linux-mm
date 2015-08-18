Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3845E6B0254
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 06:38:27 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so91211076wic.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 03:38:26 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id bo9si22898818wib.114.2015.08.18.03.38.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 03:38:25 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so104372881wic.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 03:38:24 -0700 (PDT)
Date: Tue, 18 Aug 2015 12:38:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC -v2 4/8] jbd, jbd2: Do not fail journal because of
 frozen_buffer allocation failure
Message-ID: <20150818103823.GC5033@dhcp22.suse.cz>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-5-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438768284-30927-5-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>

From: Michal Hocko <mhocko@suse.com>

Journal transaction might fail prematurely because the frozen_buffer
is allocated by GFP_NOFS request:
[   72.440013] do_get_write_access: OOM for frozen_buffer
[   72.440014] EXT4-fs: ext4_reserve_inode_write:4729: aborting transaction: Out of memory in __ext4_journal_get_write_access
[   72.440015] EXT4-fs error (device sda1) in ext4_reserve_inode_write:4735: Out of memory
(...snipped....)
[   72.495559] do_get_write_access: OOM for frozen_buffer
[   72.495560] EXT4-fs: ext4_reserve_inode_write:4729: aborting transaction: Out of memory in __ext4_journal_get_write_access
[   72.496839] do_get_write_access: OOM for frozen_buffer
[   72.496841] EXT4-fs: ext4_reserve_inode_write:4729: aborting transaction: Out of memory in __ext4_journal_get_write_access
[   72.505766] Aborting journal on device sda1-8.
[   72.505851] EXT4-fs (sda1): Remounting filesystem read-only

This wasn't a problem until "mm: page_alloc: do not lock up GFP_NOFS
allocations upon OOM" because small GPF_NOFS allocations never failed.
This allocation seems essential for the journal and GFP_NOFS is too
restrictive to the memory allocator so let's use __GFP_NOFAIL here to
emulate the previous behavior.

jbd code has the very same issue so let's do the same there as well.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/jbd/transaction.c  | 11 +----------
 fs/jbd2/transaction.c | 23 ++++-------------------
 2 files changed, 5 insertions(+), 29 deletions(-)

diff --git a/fs/jbd/transaction.c b/fs/jbd/transaction.c
index 1695ba8334a2..bf7474deda2f 100644
--- a/fs/jbd/transaction.c
+++ b/fs/jbd/transaction.c
@@ -673,16 +673,7 @@ do_get_write_access(handle_t *handle, struct journal_head *jh,
 				jbd_unlock_bh_state(bh);
 				frozen_buffer =
 					jbd_alloc(jh2bh(jh)->b_size,
-							 GFP_NOFS);
-				if (!frozen_buffer) {
-					printk(KERN_ERR
-					       "%s: OOM for frozen_buffer\n",
-					       __func__);
-					JBUFFER_TRACE(jh, "oom!");
-					error = -ENOMEM;
-					jbd_lock_bh_state(bh);
-					goto done;
-				}
+							 GFP_NOFS|__GFP_NOFAIL);
 				goto repeat;
 			}
 			jh->b_frozen_data = frozen_buffer;
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index ff2f2e6ad311..4d63c5911afa 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -923,16 +923,7 @@ do_get_write_access(handle_t *handle, struct journal_head *jh,
 				jbd_unlock_bh_state(bh);
 				frozen_buffer =
 					jbd2_alloc(jh2bh(jh)->b_size,
-							 GFP_NOFS);
-				if (!frozen_buffer) {
-					printk(KERN_ERR
-					       "%s: OOM for frozen_buffer\n",
-					       __func__);
-					JBUFFER_TRACE(jh, "oom!");
-					error = -ENOMEM;
-					jbd_lock_bh_state(bh);
-					goto done;
-				}
+							 GFP_NOFS|__GFP_NOFAIL);
 				goto repeat;
 			}
 			jh->b_frozen_data = frozen_buffer;
@@ -1156,15 +1147,9 @@ int jbd2_journal_get_undo_access(handle_t *handle, struct buffer_head *bh)
 		goto out;
 
 repeat:
-	if (!jh->b_committed_data) {
-		committed_data = jbd2_alloc(jh2bh(jh)->b_size, GFP_NOFS);
-		if (!committed_data) {
-			printk(KERN_ERR "%s: No memory for committed data\n",
-				__func__);
-			err = -ENOMEM;
-			goto out;
-		}
-	}
+	if (!jh->b_committed_data)
+		committed_data = jbd2_alloc(jh2bh(jh)->b_size,
+					    GFP_NOFS|__GFP_NOFAIL);
 
 	jbd_lock_bh_state(bh);
 	if (!jh->b_committed_data) {
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
