Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 56F4B6B00E8
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 06:59:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E11D33EE0B6
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:59:00 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C69AA45DE50
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:59:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A507145DE4F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:59:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9802C1DB8037
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:59:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 408011DB803B
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:59:00 +0900 (JST)
Message-ID: <4F72EE86.9030005@jp.fujitsu.com>
Date: Wed, 28 Mar 2012 19:57:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 3/6] memcg: add PageCgroupReset()
References: <4F72EB84.7080000@jp.fujitsu.com>
In-Reply-To: <4F72EB84.7080000@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Suleiman Souhlal <suleiman@google.com>


 A commit "memcg: simplify LRU handling by new rule" removes PCG_ACCT_LRU.
 and the bug introduced by it was fixed by "memcg: fix GPF when cgroup removal
 races with last exit"

This was for reducing flags on pc->flags....Now, we have 3bits of flags.
but this patch adds a new flag, I'm sorry. (Considering alignment of
kmalloc(), we'll able to have 5 bits..)

This patch adds PCG_RESET which is similar to PCG_ACCT_LRU. This is set
when mem_cgroup_add_lru_list() finds we cannot trust the pc's mem_cgroup.

The reason why this patch adds a (renamed) flag again is for merging
pc->flags and pc->mem_cgroup. Assume pc's mem_cgroup is encoded as

	mem_cgroup = pc->flags & ~0x7

Updating multiple bits of pc->flags without talking lock_page_cgroup()
is very dangerous. And mem_cgroup_add_lru_list() updates pc->mem_cgroup
without taking lock. Then I add RESET bit. After this, pc_to_mem_cgroup()
is written as

	if (PageCgroupReset(pc))
		return root_mem_cgroup;
	return pc->mem_cgroup;

This update of Reset bit can be done in atomic by set_bit(). And
cleared when USED bit is set.

Considering kmalloc()'s alignment, having 4bits of flags will be ok....

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |   15 ++++++++-------
 mm/memcontrol.c             |    5 +++--
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 2707809..3f3b4ff 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -8,6 +8,7 @@ enum {
 	PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
 	PCG_USED, /* this object is in use. */
 	PCG_MIGRATION, /* under page migration */
+	PCG_RESET,     /* have been reset to root_mem_cgroup */
 	__NR_PCG_FLAGS,
 };
 
@@ -70,6 +71,9 @@ SETPCGFLAG(Migration, MIGRATION)
 CLEARPCGFLAG(Migration, MIGRATION)
 TESTPCGFLAG(Migration, MIGRATION)
 
+TESTPCGFLAG(Reset, RESET)
+SETPCGFLAG(Reset, RESET)
+
 static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
 	/*
@@ -84,16 +88,13 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+extern struct mem_cgroup*  root_mem_cgroup;
 
 static inline struct mem_cgroup* pc_to_mem_cgroup(struct page_cgroup *pc)
 {
-	return pc->mem_cgroup;
-}
-
-static inline void
-pc_set_mem_cgroup(struct page_cgroup *pc, struct mem_cgroup *memcg)
-{
-	pc->mem_cgroup = memcg;
+	if (likely(!PageCgroupReset(pc)))
+		return pc->mem_cgroup;
+	return root_mem_cgroup;
 }
 
 static inline void
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d366b60..622fd2e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1080,7 +1080,8 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
 	 * of pc's mem_cgroup safe.
 	 */
 	if (!PageCgroupUsed(pc) && memcg != root_mem_cgroup) {
-		pc_set_mem_cgroup(pc, root_mem_cgroup);
+		/* this reset bit is cleared when the page is charged */
+		SetPageCgroupReset(pc);
 		memcg = root_mem_cgroup;
 	}
 
@@ -2626,7 +2627,7 @@ static int mem_cgroup_move_account(struct page *page,
 		__mem_cgroup_cancel_charge(from, nr_pages);
 
 	/* caller should have done css_get */
-	pc_set_mem_cgroup(pc, to);
+	pc_set_mem_cgroup_and_flags(pc, to, BIT(PCG_USED) | BIT(PCG_LOCK));
 	mem_cgroup_charge_statistics(to, anon, nr_pages);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
