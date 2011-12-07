Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 455536B004D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 05:32:54 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] memcg: drop type MEM_CGROUP_CHARGE_TYPE_DROP
Date: Wed, 7 Dec 2011 18:30:46 +0800
Message-ID: <1323253846-21245-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, jweiner@redhat.com, mhocko@suse.cz, Bob Liu <lliubbo@gmail.com>

uncharge will happen only when !page_mapped(page) no matter MEM_CGROUP_CHARGE_TYPE_DROP
or MEM_CGROUP_CHARGE_TYPE_SWAPOUT when called from mem_cgroup_uncharge_swapcache().
i think it's no difference, so drop it.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/memcontrol.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6aff93c..02a2988 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -339,7 +339,6 @@ enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
 	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
 	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,	/* for accounting swapcache */
-	MEM_CGROUP_CHARGE_TYPE_DROP,	/* a page was unused swap cache */
 	NR_CHARGE_TYPE,
 };
 
@@ -3000,7 +2999,6 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 
 	switch (ctype) {
 	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
-	case MEM_CGROUP_CHARGE_TYPE_DROP:
 		/* See mem_cgroup_prepare_migration() */
 		if (page_mapped(page) || PageCgroupMigration(pc))
 			goto unlock_out;
@@ -3121,9 +3119,6 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 	struct mem_cgroup *memcg;
 	int ctype = MEM_CGROUP_CHARGE_TYPE_SWAPOUT;
 
-	if (!swapout) /* this was a swap cache but the swap is unused ! */
-		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
-
 	memcg = __mem_cgroup_uncharge_common(page, ctype);
 
 	/*
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
