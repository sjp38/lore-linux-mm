Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C83886B017D
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 03:40:44 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch] mm: memcg: close race between charge and putback
Date: Thu,  8 Sep 2011 09:40:22 +0200
Message-Id: <1315467622-9520-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is a potential race between a thread charging a page and another
thread putting it back to the LRU list:

charge:                         putback:
SetPageCgroupUsed               SetPageLRU
PageLRU && add to memcg LRU     PageCgroupUsed && add to memcg LRU

The order of setting one flag and checking the other is crucial,
otherwise the charge may observe !PageLRU while the putback observes
!PageCgroupUsed and the page is not linked to the memcg LRU at all.

Global memory pressure may fix this by trying to isolate and putback
the page for reclaim, where that putback would link it to the memcg
LRU again.  Without that, the memory cgroup is undeletable due to a
charge whose physical page can not be found and moved out.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/memcontrol.c |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d63dfb2..17708e1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -990,6 +990,16 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
 		return;
 	pc = lookup_page_cgroup(page);
 	VM_BUG_ON(PageCgroupAcctLRU(pc));
+	/*
+	 * putback:				charge:
+	 * SetPageLRU				SetPageCgroupUsed
+	 * smp_mb				smp_mb
+	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
+	 *
+	 * Ensure that one of the two sides adds the page to the memcg
+	 * LRU during a race.
+	 */
+	smp_mb();
 	if (!PageCgroupUsed(pc))
 		return;
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
@@ -1041,7 +1051,16 @@ static void mem_cgroup_lru_add_after_commit(struct page *page)
 	unsigned long flags;
 	struct zone *zone = page_zone(page);
 	struct page_cgroup *pc = lookup_page_cgroup(page);
-
+	/*
+	 * putback:				charge:
+	 * SetPageLRU				SetPageCgroupUsed
+	 * smp_mb				smp_mb
+	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
+	 *
+	 * Ensure that one of the two sides adds the page to the memcg
+	 * LRU during a race.
+	 */
+	smp_mb();
 	/* taking care of that the page is added to LRU while we commit it */
 	if (likely(!PageLRU(page)))
 		return;
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
