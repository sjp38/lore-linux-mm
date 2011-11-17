Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5676F6B0072
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 20:34:17 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A848D3EE0BC
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 10:34:13 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 907F545DE54
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 10:34:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A95245DE4F
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 10:34:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5820C1DB8041
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 10:34:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 176871DB8037
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 10:34:13 +0900 (JST)
Date: Thu, 17 Nov 2011 10:33:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] fix mem_cgroup_split_huge_fixup to work efficiently.
Message-Id: <20111117103308.063f78df.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, mhocko@suse.cz, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <bsingharora@gmail.com>


I'll send this again when mm is shipped.
I sometimes see mem_cgroup_split_huge_fixup() in perf report and noticed
it's very slow. This fixes it. Any comments are welcome.

==
Subject: [PATCH] fix mem_cgroup_split_huge_fixup to work efficiently.

at split_huge_page(), mem_cgroup_split_huge_fixup() is called to
handle page_cgroup modifcations. It takes move_lock_page_cgroup()
and modify page_cgroup and LRU accounting jobs and called
HPAGE_PMD_SIZE - 1 times.

But thinking again,
  - compound_lock() is held at move_accout...then, it's not necessary
    to take move_lock_page_cgroup().
  - LRU is locked and all tail pages will go into the same LRU as
    head is now on.
  - page_cgroup is contiguous in huge page range.

This patch fixes mem_cgroup_split_huge_fixup() as to be called once per
hugepage and reduce costs for spliting.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    5 ++---
 mm/huge_memory.c           |    3 ++-
 mm/memcontrol.c            |   32 ++++++++++++++++----------------
 3 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b87068a..0a22a19 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -154,7 +154,7 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
+void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
 
 #ifdef CONFIG_DEBUG_VM
@@ -357,8 +357,7 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
 	return 0;
 }
 
-static inline void mem_cgroup_split_huge_fixup(struct page *head,
-						struct page *tail)
+static inline void mem_cgroup_split_huge_fixup(struct page *head)
 {
 }
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4298aba..aa6cdae 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1207,6 +1207,8 @@ static void __split_huge_page_refcount(struct page *page)
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
 	compound_lock(page);
+	/* complete memcg works before add pages to LRU */
+	mem_cgroup_split_huge_fixup(page);
 
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
@@ -1278,7 +1280,6 @@ static void __split_huge_page_refcount(struct page *page)
 		BUG_ON(!PageDirty(page_tail));
 		BUG_ON(!PageSwapBacked(page_tail));
 
-		mem_cgroup_split_huge_fixup(page, page_tail);
 
 		lru_add_page_tail(zone, page, page_tail);
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6aff93c..99101f1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2523,38 +2523,38 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 /*
  * Because tail pages are not marked as "used", set it. We're under
  * zone->lru_lock, 'splitting on pmd' and compund_lock.
+ * charge/uncharge will be never happen and move_account() is done under
+ * compound_lock(), so we don't have to take care of races.
  */
-void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
+void mem_cgroup_split_huge_fixup(struct page *head)
 {
 	struct page_cgroup *head_pc = lookup_page_cgroup(head);
-	struct page_cgroup *tail_pc = lookup_page_cgroup(tail);
-	unsigned long flags;
+	struct page_cgroup *pc;
+	int i;
 
 	if (mem_cgroup_disabled())
 		return;
-	/*
-	 * We have no races with charge/uncharge but will have races with
-	 * page state accounting.
-	 */
-	move_lock_page_cgroup(head_pc, &flags);
+	for (i = 1; i < HPAGE_PMD_NR; i++) {
+		pc = head_pc + i;
+		pc->mem_cgroup = head_pc->mem_cgroup;
+		smp_wmb();/* see __commit_charge() */
+		/*
+		 * LRU flags cannot be copied because we need to add tail
+		 * page to LRU by generic call and our hooks will be called.
+		 */
+		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
+	}
 
-	tail_pc->mem_cgroup = head_pc->mem_cgroup;
-	smp_wmb(); /* see __commit_charge() */
 	if (PageCgroupAcctLRU(head_pc)) {
 		enum lru_list lru;
 		struct mem_cgroup_per_zone *mz;
-
 		/*
-		 * LRU flags cannot be copied because we need to add tail
-		 *.page to LRU by generic call and our hook will be called.
 		 * We hold lru_lock, then, reduce counter directly.
 		 */
 		lru = page_lru(head);
 		mz = page_cgroup_zoneinfo(head_pc->mem_cgroup, head);
-		MEM_CGROUP_ZSTAT(mz, lru) -= 1;
+		MEM_CGROUP_ZSTAT(mz, lru) -= HPAGE_PMD_NR - 1;
 	}
-	tail_pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
-	move_unlock_page_cgroup(head_pc, &flags);
 }
 #endif
 
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
