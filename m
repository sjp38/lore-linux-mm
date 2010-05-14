Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 71E766B01EF
	for <linux-mm@kvack.org>; Thu, 13 May 2010 22:05:49 -0400 (EDT)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH] radix-tree: fix radix_tree_prev_hole underflow case
Date: Thu, 13 May 2010 23:05:24 -0300
Message-Id: <1273802724-3414-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Cesar Eduardo Barros <cesarb@cesarb.net>
List-ID: <linux-mm.kvack.org>

radix_tree_prev_hole() used LONG_MAX to detect underflow; however,
ULONG_MAX is clearly what was intended, both here and by its only user
(count_history_pages at mm/readahead.c).

Cc: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 lib/radix-tree.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index b69031f..be40980 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -656,7 +656,7 @@ EXPORT_SYMBOL(radix_tree_next_hole);
  *
  *	Returns: the index of the hole if found, otherwise returns an index
  *	outside of the set specified (in which case 'index - return >= max_scan'
- *	will be true). In rare cases of wrap-around, LONG_MAX will be returned.
+ *	will be true). In rare cases of wrap-around, ULONG_MAX will be returned.
  *
  *	radix_tree_next_hole may be called under rcu_read_lock. However, like
  *	radix_tree_gang_lookup, this will not atomically search a snapshot of
@@ -674,7 +674,7 @@ unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
 		if (!radix_tree_lookup(root, index))
 			break;
 		index--;
-		if (index == LONG_MAX)
+		if (index == ULONG_MAX)
 			break;
 	}
 
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
