Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 69C566B0255
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 06:41:19 -0400 (EDT)
Received: by wijp15 with SMTP id p15so96777016wij.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 03:41:19 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id cv2si26532289wib.17.2015.08.18.03.41.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 03:41:18 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so96855789wic.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 03:41:17 -0700 (PDT)
Date: Tue, 18 Aug 2015 12:41:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC -v2 8/8] btrfs: use __GFP_NOFAIL in alloc_btrfs_bio
Message-ID: <20150818104116.GG5033@dhcp22.suse.cz>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-9-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438768284-30927-9-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>

From: Michal Hocko <mhocko@suse.com>

alloc_btrfs_bio is relying on GFP_NOFS to allocate a bio but since "mm:
page_alloc: do not lock up GFP_NOFS allocations upon OOM" this is
allowed to fail which can lead to
[   37.928625] kernel BUG at fs/btrfs/extent_io.c:4045

This is clearly undesirable and the nofail behavior should be explicit
if the allocation failure cannot be tolerated.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/btrfs/volumes.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
index 53af23f2c087..42b9949dd71d 100644
--- a/fs/btrfs/volumes.c
+++ b/fs/btrfs/volumes.c
@@ -4914,9 +4914,7 @@ static struct btrfs_bio *alloc_btrfs_bio(int total_stripes, int real_stripes)
 		 * and the stripes
 		 */
 		sizeof(u64) * (total_stripes),
-		GFP_NOFS);
-	if (!bbio)
-		return NULL;
+		GFP_NOFS|__GFP_NOFAIL);
 
 	atomic_set(&bbio->error, 0);
 	atomic_set(&bbio->refs, 1);
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
