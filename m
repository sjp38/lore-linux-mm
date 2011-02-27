Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 45C528D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 10:49:44 -0500 (EST)
Received: by pzk33 with SMTP id 33so742881pzk.14
        for <linux-mm@kvack.org>; Sun, 27 Feb 2011 07:49:42 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] memcg: clean up migration
Date: Mon, 28 Feb 2011 00:49:25 +0900
Message-Id: <1298821765-3167-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch cleans up unncessary BUG_ON check and confusing
charge variable.

That's because memcg charge/uncharge could be handled by
mem_cgroup_[prepare/end] migration itself so charge local variable
in unmap_and_move lost the role since we introduced 01b1ae63c2.

And mem_cgroup_prepare_migratio return 0 if only it is successful.
Otherwise, it jumps to unlock label to clean up so BUG_ON(charge)
isn;t meaningless.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/memcontrol.c |    1 +
 mm/migrate.c    |   14 ++++----------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2fc97fc..6832926 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2872,6 +2872,7 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 /*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
+ * Return 0 if charge is successful. Otherwise return -errno.
  */
 int mem_cgroup_prepare_migration(struct page *page,
 	struct page *newpage, struct mem_cgroup **ptr, gfp_t gfp_mask)
diff --git a/mm/migrate.c b/mm/migrate.c
index eb083a6..737c2e5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -622,7 +622,6 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
 	int remap_swapcache = 1;
-	int charge = 0;
 	struct mem_cgroup *mem;
 	struct anon_vma *anon_vma = NULL;
 
@@ -637,9 +636,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		if (unlikely(split_huge_page(page)))
 			goto move_newpage;
 
-	/* prepare cgroup just returns 0 or -ENOMEM */
 	rc = -EAGAIN;
-
 	if (!trylock_page(page)) {
 		if (!force)
 			goto move_newpage;
@@ -678,13 +675,11 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	}
 
 	/* charge against new page */
-	charge = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
-	if (charge == -ENOMEM) {
-		rc = -ENOMEM;
+	rc = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
+	if (rc)
 		goto unlock;
-	}
-	BUG_ON(charge);
 
+	rc = -EAGAIN;
 	if (PageWriteback(page)) {
 		if (!force || !sync)
 			goto uncharge;
@@ -767,8 +762,7 @@ skip_unmap:
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
