Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id DC1796B0092
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 06:53:06 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6F8BD3EE0C1
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:53:05 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 506C545DE4E
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:53:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3023245DE52
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:53:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 240CC1DB802F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:53:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BE6251DB803E
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:53:04 +0900 (JST)
Message-ID: <4F72ED25.60307@jp.fujitsu.com>
Date: Wed, 28 Mar 2012 19:51:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 2/6] memcg: add pc_set_mem_cgroup_and_flags()
References: <4F72EB84.7080000@jp.fujitsu.com>
In-Reply-To: <4F72EB84.7080000@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Suleiman Souhlal <suleiman@google.com>

Consolidate a code for setting pc->mem_cgroup and USED bit which requires smp_wmb().
And remove a macro PCGF_NOCOPY_AT_SPLIT which isn't helpful to read code, now.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |   18 ++++++++++++++++++
 mm/memcontrol.c             |   18 ++++--------------
 2 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 92768cb..2707809 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_PAGE_CGROUP_H
 #define __LINUX_PAGE_CGROUP_H
 
+#include <linux/smp.h>
+
 enum {
 	/* flags for mem_cgroup */
 	PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
@@ -94,6 +96,22 @@ pc_set_mem_cgroup(struct page_cgroup *pc, struct mem_cgroup *memcg)
 	pc->mem_cgroup = memcg;
 }
 
+static inline void
+pc_set_mem_cgroup_and_flags(struct page_cgroup *pc, struct mem_cgroup *memcg,
+			unsigned long flags)
+{
+	pc->mem_cgroup = memcg;
+	/*
+	 * We access a page_cgroup asynchronously without lock_page_cgroup().
+	 * Especially when a page_cgroup is taken from a page, pc's mem_cgroup
+	 * is accessed after testing USED bit. To make pc's mem_cgroup visible
+	 * before USED bit, we need memory barrier here.
+	 * See mem_cgroup_add_lru_list(), etc.
+	 */
+	smp_wmb();
+	pc->flags = flags;
+}
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8077460..d366b60 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2511,16 +2511,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 		}
 	}
 
-	pc_set_mem_cgroup(pc, memcg);
-	/*
-	 * We access a page_cgroup asynchronously without lock_page_cgroup().
-	 * Especially when a page_cgroup is taken from a page, pc's mem_cgroup
-	 * is accessed after testing USED bit. To make pc's mem_cgroup visible
-	 * before USED bit, we need memory barrier here.
-	 * See mem_cgroup_add_lru_list(), etc.
- 	 */
-	smp_wmb();
-	SetPageCgroupUsed(pc);
+	pc_set_mem_cgroup_and_flags(pc, memcg, BIT(PCG_USED) | BIT(PCG_LOCK));
 
 	if (lrucare) {
 		if (was_on_lru) {
@@ -2549,7 +2540,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
-#define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | (1 << PCG_MIGRATION))
 /*
  * Because tail pages are not marked as "used", set it. We're under
  * zone->lru_lock, 'splitting on pmd' and compound_lock.
@@ -2565,11 +2555,11 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 
 	if (mem_cgroup_disabled())
 		return;
+	if (!PageCgroupUsed(head_pc))
+		return;
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		pc = head_pc + i;
-		pc_set_mem_cgroup(pc, memcg);
-		smp_wmb();/* see __commit_charge() */
-		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
+		pc_set_mem_cgroup_and_flags(pc, memcg, BIT(PCG_USED));
 	}
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
