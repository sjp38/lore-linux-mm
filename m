Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF6E6B0023
	for <linux-mm@kvack.org>; Wed, 11 May 2011 11:35:22 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Date: Wed, 11 May 2011 16:29:33 +0100
Message-Id: <1305127773-10570-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1305127773-10570-1-git-send-email-mgorman@suse.de>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

To avoid locking and per-cpu overhead, SLUB optimisically uses
high-order allocations up to order-3 by default and falls back to
lower allocations if they fail. While care is taken that the caller
and kswapd take no unusual steps in response to this, there are
further consequences like shrinkers who have to free more objects to
release any memory. There is anecdotal evidence that significant time
is being spent looping in shrinkers with insufficient progress being
made (https://lkml.org/lkml/2011/4/28/361) and keeping kswapd awake.

SLUB is now the default allocator and some bug reports have been
pinned down to SLUB using high orders during operations like
copying large amounts of data. SLUBs use of high-orders benefits
applications that are sized to memory appropriately but this does not
necessarily apply to large file servers or desktops.  This patch
causes SLUB to use order-0 pages like SLAB does by default.
There is further evidence that this keeps kswapd's usage lower
(https://lkml.org/lkml/2011/5/10/383).

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/vm/slub.txt |    2 +-
 mm/slub.c                 |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
index 07375e7..778e9fa 100644
--- a/Documentation/vm/slub.txt
+++ b/Documentation/vm/slub.txt
@@ -117,7 +117,7 @@ can be influenced by kernel parameters:
 
 slub_min_objects=x		(default 4)
 slub_min_order=x		(default 0)
-slub_max_order=x		(default 1)
+slub_max_order=x		(default 0)
 
 slub_min_objects allows to specify how many objects must at least fit
 into one slab in order for the allocation order to be acceptable.
diff --git a/mm/slub.c b/mm/slub.c
index 1071723..23a4789 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2198,7 +2198,7 @@ EXPORT_SYMBOL(kmem_cache_free);
  * take the list_lock.
  */
 static int slub_min_order;
-static int slub_max_order = PAGE_ALLOC_COSTLY_ORDER;
+static int slub_max_order;
 static int slub_min_objects;
 
 /*
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
