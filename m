Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 156726B01F0
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 17:01:14 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 03/14] mm,migration: Do not try to migrate unmapped anonymous pages
Date: Tue, 20 Apr 2010 22:01:05 +0100
Message-Id: <1271797276-31358-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

rmap_walk_anon() was triggering errors in memory compaction that look like
use-after-free errors.  The problem is that between the page being
isolated from the LRU and rcu_read_lock() being taken, the mapcount of the
page dropped to 0 and the anon_vma gets freed.  This can happen during
memory compaction if pages being migrated belong to a process that exits
before migration completes.  Hence, the use-after-free race looks like

 1. Page isolated for migration
 2. Process exits
 3. page_mapcount(page) drops to zero so anon_vma was no longer reliable
 4. unmap_and_move() takes the rcu_lock but the anon_vma is already garbage
 4. call try_to_unmap, looks up tha anon_vma and "locks" it but the lock
    is garbage.

This patch checks the mapcount after the rcu lock is taken.  If the
mapcount is zero, the anon_vma is assumed to be freed and no further
action is taken.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/migrate.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 42a3d24..b114635 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -600,6 +600,17 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	if (PageAnon(page)) {
 		rcu_read_lock();
 		rcu_locked = 1;
+
+		/*
+		 * If the page has no mappings any more, just bail. An
+		 * unmapped anon page is likely to be freed soon but worse,
+		 * it's possible its anon_vma disappeared between when
+		 * the page was isolated and when we reached here while
+		 * the RCU lock was not held
+		 */
+		if (!page_mapped(page))
+			goto rcu_unlock;
+
 		anon_vma = page_anon_vma(page);
 		atomic_inc(&anon_vma->external_refcount);
 	}
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
