Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id EAEC46B006E
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 08:55:41 -0500 (EST)
Received: by wivr20 with SMTP id r20so14982764wiv.2
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 05:55:41 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si22587147wjw.48.2015.03.02.05.55.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 05:55:35 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 2/4] jbd2: revert must-not-fail allocation loops back to GFP_NOFAIL
Date: Mon,  2 Mar 2015 14:54:41 +0100
Message-Id: <1425304483-7987-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Vipul Pandya <vipul@chelsio.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

This basically reverts 47def82672b3 (jbd2: Remove __GFP_NOFAIL from jbd2
layer). The deprecation of __GFP_NOFAIL was a bad choice because it led
to open coding the endless loop around the allocator rather than
removing the dependency on the non failing allocation. So the
deprecation was a clear failure and the reality tells us that
__GFP_NOFAIL is not even close to go away.

It is still true that __GFP_NOFAIL allocations are generally discouraged
and new uses should be evaluated and an alternative (pre-allocations or
reservations) should be considered but it doesn't make any sense to lie
the allocator about the requirements. Allocator can take steps to help
making a progress if it knows the requirements.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 fs/jbd2/journal.c     | 11 +----------
 fs/jbd2/transaction.c | 20 +++++++-------------
 2 files changed, 8 insertions(+), 23 deletions(-)

diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index b96bd8076b70..0bc333b4a594 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -371,16 +371,7 @@ int jbd2_journal_write_metadata_buffer(transaction_t *transaction,
 	 */
 	J_ASSERT_BH(bh_in, buffer_jbddirty(bh_in));
 
-retry_alloc:
-	new_bh = alloc_buffer_head(GFP_NOFS);
-	if (!new_bh) {
-		/*
-		 * Failure is not an option, but __GFP_NOFAIL is going
-		 * away; so we retry ourselves here.
-		 */
-		congestion_wait(BLK_RW_ASYNC, HZ/50);
-		goto retry_alloc;
-	}
+	new_bh = alloc_buffer_head(GFP_NOFS|__GFP_NOFAIL);
 
 	/* keep subsequent assertions sane */
 	atomic_set(&new_bh->b_count, 1);
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index 5f09370c90a8..dac4523fa142 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -278,22 +278,16 @@ static int start_this_handle(journal_t *journal, handle_t *handle,
 
 alloc_transaction:
 	if (!journal->j_running_transaction) {
+		/*
+		 * If __GFP_FS is not present, then we may be being called from
+		 * inside the fs writeback layer, so we MUST NOT fail.
+		 */
+		if ((gfp_mask & __GFP_FS) == 0)
+			gfp_mask |= __GFP_NOFAIL;
 		new_transaction = kmem_cache_zalloc(transaction_cache,
 						    gfp_mask);
-		if (!new_transaction) {
-			/*
-			 * If __GFP_FS is not present, then we may be
-			 * being called from inside the fs writeback
-			 * layer, so we MUST NOT fail.  Since
-			 * __GFP_NOFAIL is going away, we will arrange
-			 * to retry the allocation ourselves.
-			 */
-			if ((gfp_mask & __GFP_FS) == 0) {
-				congestion_wait(BLK_RW_ASYNC, HZ/50);
-				goto alloc_transaction;
-			}
+		if (!new_transaction)
 			return -ENOMEM;
-		}
 	}
 
 	jbd_debug(3, "New handle %p going live.\n", handle);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
