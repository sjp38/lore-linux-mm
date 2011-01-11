Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A8A1B6B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 01:01:18 -0500 (EST)
Received: by gxk5 with SMTP id 5so9562247gxk.14
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 22:01:17 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] memcg: remove charge variable in unmap_and_move
Date: Tue, 11 Jan 2011 15:00:50 +0900
Message-Id: <1294725650-4732-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

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

Suggested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/migrate.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index b8a32da..e393841 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -623,7 +623,6 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	struct page *newpage = get_new_page(page, private, &result);
 	int remap_swapcache = 1;
 	int rcu_locked = 0;
-	int charge = 0;
 	struct mem_cgroup *mem = NULL;
 	struct anon_vma *anon_vma = NULL;
 
@@ -662,12 +661,10 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	}
 
 	/* charge against new page */
-	charge = mem_cgroup_prepare_migration(page, newpage, &mem);
-	if (charge == -ENOMEM) {
-		rc = -ENOMEM;
+	rc = mem_cgroup_prepare_migration(page, newpage, &mem);
+	if (rc == -ENOMEM)
 		goto unlock;
-	}
-	BUG_ON(charge);
+	BUG_ON(rc);
 
 	if (PageWriteback(page)) {
 		if (!force || !sync)
@@ -760,8 +757,7 @@ rcu_unlock:
 	if (rcu_locked)
 		rcu_read_unlock();
 uncharge:
-	if (!charge)
-		mem_cgroup_end_migration(mem, page, newpage, rc == 0);
+	mem_cgroup_end_migration(mem, page, newpage, rc == 0);
 unlock:
 	unlock_page(page);
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
