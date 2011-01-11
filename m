Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 96DB26B00EA
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 03:51:26 -0500 (EST)
Received: by gxk28 with SMTP id 28so3202878gxk.2
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 00:51:25 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 2/2] memcg: remove charge variable in unmap_and_move
Date: Tue, 11 Jan 2011 17:51:12 +0900
Message-Id: <f6f15f90ecf0df32586fcc103038fd7ea01acc16.1294735182.git.minchan.kim@gmail.com>
In-Reply-To: <41390917af25769cd59eb001370b80ef6520a8bb.1294735182.git.minchan.kim@gmail.com>
References: <41390917af25769cd59eb001370b80ef6520a8bb.1294735182.git.minchan.kim@gmail.com>
In-Reply-To: <41390917af25769cd59eb001370b80ef6520a8bb.1294735182.git.minchan.kim@gmail.com>
References: <41390917af25769cd59eb001370b80ef6520a8bb.1294735182.git.minchan.kim@gmail.com>
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
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/memcontrol.c |    1 +
 mm/migrate.c    |    9 +++------
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8ab8410..b1b572f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2804,6 +2804,7 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 /*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
+ * Note : Should not return -EAGAIN. unmap_and_move depends on it.
  */
 int mem_cgroup_prepare_migration(struct page *page,
 	struct page *newpage, struct mem_cgroup **ptr)
diff --git a/mm/migrate.c b/mm/migrate.c
index 8f0f131..5f2169f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -623,7 +623,6 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	struct page *newpage = get_new_page(page, private, &result);
 	int remap_swapcache = 1;
 	int rcu_locked = 0;
-	int charge = 0;
 	struct mem_cgroup *mem = NULL;
 	struct anon_vma *anon_vma = NULL;
 
@@ -638,7 +637,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		if (unlikely(split_huge_page(page)))
 			goto move_newpage;
 
-	/* prepare cgroup just returns 0 or -ENOMEM */
+	/* mem_cgroup_prepare_migration never returns -EAGAIN */
 	rc = -EAGAIN;
 
 	if (!trylock_page(page)) {
@@ -662,8 +661,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	}
 
 	/* charge against new page */
-	charge = mem_cgroup_prepare_migration(page, newpage, &mem);
-	if (charge == -ENOMEM) {
+	if (mem_cgroup_prepare_migration(page, newpage, &mem)) {
 		rc = -ENOMEM;
 		goto unlock;
 	}
@@ -759,8 +757,7 @@ rcu_unlock:
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
