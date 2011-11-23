Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1E46B00D0
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 08:35:24 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/5] Btrfs: pass __GFP_WRITE for buffered write page allocations
Date: Wed, 23 Nov 2011 14:34:18 +0100
Message-Id: <1322055258-3254-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1322055258-3254-1-git-send-email-hannes@cmpxchg.org>
References: <1322055258-3254-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <jweiner@redhat.com>

Tell the page allocator that pages allocated for a buffered write are
expected to become dirty soon.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 fs/btrfs/file.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index dafdfa0..d673f4a 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1081,7 +1081,7 @@ static noinline int prepare_pages(struct btrfs_root *root, struct file *file,
 again:
 	for (i = 0; i < num_pages; i++) {
 		pages[i] = find_or_create_page(inode->i_mapping, index + i,
-					       mask);
+					       mask | __GFP_WRITE);
 		if (!pages[i]) {
 			faili = i - 1;
 			err = -ENOMEM;
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
