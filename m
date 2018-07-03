Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0127E6B0005
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 00:11:32 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id q18-v6so488438pll.3
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 21:11:32 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id u1-v6si188103pgo.114.2018.07.02.21.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 21:11:31 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 2/2] fs: xfs: use BUG_ON if writepage call comes from direct reclaim
Date: Tue,  3 Jul 2018 12:11:19 +0800
Message-Id: <1530591079-33813-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1530591079-33813-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1530591079-33813-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@techsingularity.net, tytso@mit.edu, adilger.kernel@dilger.ca, darrick.wong@oracle.com, dchinner@redhat.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

direct reclaim doesn't write out filesystem page, only kswapd could do
this. So, if it is called from direct relaim, it is definitely a bug.

And, Mel Gorman mentioned "Ultimately, this will be a BUG_ON." in commit
94054fa3fca1fd78db02cb3d68d5627120f0a1d4 ("xfs: warn if direct reclaim
tries to writeback pages"),

It has been many years since that commit, so it should be safe to
elevate WARN_ON to BUG_ON now.

Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 fs/xfs/xfs_aops.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 8eb3ba3..7efc2d2 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1080,11 +1080,9 @@ static inline int xfs_bio_add_buffer(struct bio *bio, struct buffer_head *bh)
 	 * allow reclaim from kswapd as the stack usage there is relatively low.
 	 *
 	 * This should never happen except in the case of a VM regression so
-	 * warn about it.
+	 * BUG about it.
 	 */
-	if (WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
-			PF_MEMALLOC))
-		goto redirty;
+	BUG_ON((current->flags & (PF_MEMALLOC|PF_KSWAPD)) == PF_MEMALLOC);
 
 	/*
 	 * Given that we do not allow direct reclaim to call us, we should
-- 
1.8.3.1
