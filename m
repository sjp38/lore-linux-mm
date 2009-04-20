Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB765F0002
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 16:25:43 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3][rfc] swap: try to reuse freed slots in the allocation area
Date: Mon, 20 Apr 2009 22:24:44 +0200
Message-Id: <1240259085-25872-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org>
References: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

A swap slot for an anonymous memory page might get freed again just
after allocating it when further steps in the eviction process fail.

But the clustered slot allocation will go ahead allocating after this
now unused slot, leaving a hole at this position.  Holes waste space
and act as a boundary for optimistic swap-in.

To avoid this, check if the next page to be swapped out can sensibly
be placed at this just freed position.  And if so, point the next
cluster offset to it.

The acceptable 'look-back' distance is the number of slots swap-in
clustering uses as well so that the latter continues to get related
context when reading surrounding swap slots optimistically.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hugh@veritas.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/swapfile.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 312fafe..fc88278 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -484,6 +484,15 @@ static int swap_entry_free(struct swap_info_struct *p, swp_entry_t ent)
 				p->lowest_bit = offset;
 			if (offset > p->highest_bit)
 				p->highest_bit = offset;
+			/*
+			 * If the next allocation is only some slots
+			 * ahead, reuse this now free slot instead of
+			 * leaving a hole.
+			 */
+			if (p->cluster_next - offset <= 1 << page_cluster) {
+				p->cluster_next = offset;
+				p->cluster_nr++;
+			}
 			if (p->prio > swap_info[swap_list.next].prio)
 				swap_list.next = p - swap_info;
 			nr_swap_pages++;
-- 
1.6.2.1.135.gde769

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
