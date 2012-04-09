Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 230E26B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:42:06 -0400 (EDT)
Received: by qcse1 with SMTP id e1so514278qcs.2
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 12:42:05 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] Revert "mm: vmscan: fix misused nr_reclaimed in shrink_mem_cgroup_zone()"
Date: Mon,  9 Apr 2012 12:42:04 -0700
Message-Id: <1334000524-23972-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org

This reverts commit c38446cc65e1f2b3eb8630c53943b94c4f65f670.

Before the commit, the code makes senses to me but not after the commit. The
"nr_reclaimed" is the number of pages reclaimed by scanning through the memcg's
lru lists. The "nr_to_reclaim" is the target value for the whole function. For
example, we like to early break the reclaim if reclaimed 32 pages under direct
reclaim (not DEF_PRIORITY).

After the reverted commit, the target "nr_to_reclaim" is decremented each time
by "nr_reclaimed" but we still use it to compare the "nr_reclaimed". It just
doesn't make sense to me...

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/vmscan.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 33c332b..1a51868 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2107,12 +2107,7 @@ restart:
 		 * with multiple processes reclaiming pages, the total
 		 * freeing target can get unreasonably large.
 		 */
-		if (nr_reclaimed >= nr_to_reclaim)
-			nr_to_reclaim = 0;
-		else
-			nr_to_reclaim -= nr_reclaimed;
-
-		if (!nr_to_reclaim && priority < DEF_PRIORITY)
+		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
 			break;
 	}
 	blk_finish_plug(&plug);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
