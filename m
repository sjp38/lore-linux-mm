Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2D12A8D003A
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 10:17:38 -0500 (EST)
Received: by mail-iy0-f169.google.com with SMTP id 13so1913106iyf.14
        for <linux-mm@kvack.org>; Sun, 20 Feb 2011 07:17:36 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 2/2] memcg: remove charge variable in unmap_and_move
Date: Mon, 21 Feb 2011 00:17:18 +0900
Message-Id: <c48df61c1186492699f18c4c6b401dcbc0db2b7f.1298214672.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1298214672.git.minchan.kim@gmail.com>
References: <cover.1298214672.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1298214672.git.minchan.kim@gmail.com>
References: <cover.1298214672.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>

memcg charge/uncharge could be handled by mem_cgroup_[prepare/end]
migration itself so charge local variable in unmap_and_move lost the role
since we introduced 01b1ae63c2.

In addition, the variable name is not good like below.

int unmap_and_move()
{
	charge = mem_cgroup_prepare_migration(xxx);
	..
		BUG_ON(charge); <-- BUG if it is charged?
		..
uncharge:
		if (!charge)    <-- why do we have to uncharge !charge?
			mem_group_end_migration(xxx);
	..
}

So let's remove unnecessary and confusing variable.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Suggested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/memcontrol.c |    1 +
 mm/migrate.c    |    9 +++------
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8a97571..3c91d5c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2873,6 +2873,7 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 /*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
+ * Note: Should not return -EAGAIN. unmap_and_move depens on it.
  */
 int mem_cgroup_prepare_migration(struct page *page,
 	struct page *newpage, struct mem_cgroup **ptr, gfp_t gfp_mask)
diff --git a/mm/migrate.c b/mm/migrate.c
index 2abc9c9..37055d0 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -622,7 +622,6 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
 	int remap_swapcache = 1;
-	int charge = 0;
 	struct mem_cgroup *mem;
 	struct anon_vma *anon_vma = NULL;
 
@@ -637,7 +636,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		if (unlikely(split_huge_page(page)))
 			goto move_newpage;
 
-	/* prepare cgroup just returns 0 or -ENOMEM */
+	/* mem_cgroup_prepage_migration never returns -EAGAIN */
 	rc = -EAGAIN;
 
 	if (!trylock_page(page)) {
@@ -678,8 +677,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	}
 
 	/* charge against new page */
-	charge = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
-	if (charge == -ENOMEM) {
+	if (mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL)) {
 		rc = -ENOMEM;
 		goto unlock;
 	}
@@ -766,8 +764,7 @@ skip_unmap:
 		drop_anon_vma(anon_vma);
 
 uncharge:
-	if (!charge)
-		mem_cgroup_end_migration(mem, page, newpage, rc == 0);
+	mem_cgroup_end_migration(mem, page, newpage, rc == 0);
 unlock:
 	unlock_page(page);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
