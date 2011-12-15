Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 9B7C16B016E
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 03:45:38 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D87483EE0C2
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 17:45:36 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B3A0F45DF4F
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 17:45:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B6D045DF07
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 17:45:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E6371DB8038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 17:45:36 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F9DC1DB802C
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 17:45:36 +0900 (JST)
Date: Thu, 15 Dec 2011 17:44:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Experimental] [PATCH 0/5] page_cgroup->flags diet.
Message-Id: <20111215174418.643890da.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>


This untested patch is for reducing size of page_cgroup to be 8 bytes.
After enough tests, we'll be ready to integrate page_cgroup as a member of
struct page (with CONFIG?)
I'll start tests when I can..

BTW, I don't consider how to track blkio owner for supporting buffered I/O
in blkio cgroup. But I wonder it's enough to add an interface to tie memcg
and blkio cgroup even if they are not bind-mounted...
Then, blkio_id can be gotten by page-> memcg -> blkio_id.
Another idea is using page->private (or some) for recording who is the writer
This info can be propageted to buffer_head or bio.

Worst idea is adding a new field to page_cgroup.

==

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index f9441ca..48be740 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -23,8 +23,7 @@ enum {
  * then the page cgroup for pfn always exists.
  */
 struct page_cgroup {
-	unsigned long flags;
-	struct mem_cgroup *mem_cgroup;
+	unsigned long _flags; /* This flag only uses lower 3bits */
 };
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
@@ -46,19 +45,19 @@ struct page *lookup_cgroup_page(struct page_cgroup *pc);
 
 #define TESTPCGFLAG(uname, lname)			\
 static inline int PageCgroup##uname(struct page_cgroup *pc)	\
-	{ return test_bit(PCG_##lname, &pc->flags); }
+	{ return test_bit(PCG_##lname, &pc->_flags); }
 
 #define SETPCGFLAG(uname, lname)			\
 static inline void SetPageCgroup##uname(struct page_cgroup *pc)\
-	{ set_bit(PCG_##lname, &pc->flags);  }
+	{ set_bit(PCG_##lname, &pc->_flags);  }
 
 #define CLEARPCGFLAG(uname, lname)			\
 static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
-	{ clear_bit(PCG_##lname, &pc->flags);  }
+	{ clear_bit(PCG_##lname, &pc->_flags);  }
 
 #define TESTCLEARPCGFLAG(uname, lname)			\
 static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
-	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
+	{ return test_and_clear_bit(PCG_##lname, &pc->_flags);  }
 
 TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
@@ -68,18 +67,33 @@ SETPCGFLAG(Migration, MIGRATION)
 CLEARPCGFLAG(Migration, MIGRATION)
 TESTPCGFLAG(Migration, MIGRATION)
 
+#define PCG_FLAG_MASK	((1 << (__NR_PCG_FLAGS)) - 1)
+
 static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
 	/*
 	 * Don't take this lock in IRQ context.
 	 * This lock is for pc->mem_cgroup, USED, CACHE, MIGRATION
 	 */
-	bit_spin_lock(PCG_LOCK, &pc->flags);
+	bit_spin_lock(PCG_LOCK, &pc->_flags);
 }
 
 static inline void unlock_page_cgroup(struct page_cgroup *pc)
 {
-	bit_spin_unlock(PCG_LOCK, &pc->flags);
+	bit_spin_unlock(PCG_LOCK, &pc->_flags);
+}
+
+static inline struct mem_cgroup *pc_to_memcg(struct page_cgroup *pc)
+{
+	return (struct mem_cgroup *)
+		((unsigned long)pc->_flags & ~PCG_FLAG_MASK);
+}
+
+static inline void
+pc_set_memcg(struct page_cgroup *pc, struct mem_cgroup *memcg)
+{
+	unsigned long val = pc->_flags & PCG_FLAG_MASK;
+	pc->_flags = (unsigned long)memcg | val;
 }
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 66e03ad..8750e5a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1103,7 +1103,7 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
 		return &zone->lruvec;
 
 	pc = lookup_page_cgroup(page);
-	memcg = pc->mem_cgroup;
+	memcg = pc_to_memcg(pc);
 	VM_BUG_ON(!memcg);
 	mz = page_cgroup_zoneinfo(memcg, page);
 	/* compound_order() is stabilized through lru_lock */
@@ -1131,7 +1131,7 @@ void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
 		return;
 
 	pc = lookup_page_cgroup(page);
-	memcg = pc->mem_cgroup;
+	memcg = pc_to_memcg(pc);
 	VM_BUG_ON(!memcg);
 	mz = page_cgroup_zoneinfo(memcg, page);
 	/* huge page split is done under lru_lock. so, we have no races. */
@@ -1268,7 +1268,7 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 		return NULL;
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
+	mz = page_cgroup_zoneinfo(pc_to_memcg(pc), page);
 	return &mz->reclaim_stat;
 }
 
@@ -1897,7 +1897,7 @@ bool __mem_cgroup_begin_update_page_stats(struct page *page, unsigned long *flag
 	bool need_unlock = false;
 
 	rcu_read_lock();
-	memcg = pc->mem_cgroup;
+	memcg = pc_to_memcg(pc);
 	if (!memcg  || !PageCgroupUsed(pc))
 		goto out;
 	if (unlikely(mem_cgroup_stealed(memcg)) || PageTransHuge(page)) {
@@ -1926,7 +1926,7 @@ void __mem_cgroup_update_page_stat(struct page *page,
 				 enum mem_cgroup_page_stat_item idx, int val)
 {
 	struct page_cgroup *pc = lookup_page_cgroup(page);
-	struct mem_cgroup *memcg = pc->mem_cgroup;
+	struct mem_cgroup *memcg = pc_to_memcg(pc);
 
 	if (!memcg || !PageCgroupUsed(pc))
 		return;
@@ -2400,7 +2400,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
+		memcg = pc_to_memcg(pc);
 		if (memcg && !css_tryget(&memcg->css))
 			memcg = NULL;
 	} else if (PageSwapCache(page)) {
@@ -2434,7 +2434,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 	 * we don't need page_cgroup_lock about tail pages, becase they are not
 	 * accessed by any other context at this point.
 	 */
-	pc->mem_cgroup = memcg;
+	pc_set_memcg(pc, memcg);
 	/*
 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
 	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
@@ -2469,7 +2469,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
-#define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | (1 << PCG_MIGRATION))
 /*
  * Because tail pages are not marked as "used", set it. We're under
  * zone->lru_lock, 'splitting on pmd' and compound_lock.
@@ -2481,23 +2480,26 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 	struct page_cgroup *head_pc = lookup_page_cgroup(head);
 	struct page_cgroup *pc;
 	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup *head_memcg;
 	enum lru_list lru;
 	int i;
 
 	if (mem_cgroup_disabled())
 		return;
+	head_memcg = pc_to_memcg(head_pc);
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		pc = head_pc + i;
-		pc->mem_cgroup = head_pc->mem_cgroup;
+		pc_set_memcg(pc, head_memcg);
 		smp_wmb();/* see __commit_charge() */
-		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
+		/* this page is never be under page migration */
+		SetPageCgroupUsed(pc);
 	}
 	/* 
 	 * Tail pages will be added to LRU.
 	 * We hold lru_lock,then,reduce counter directly.
 	 */
 	lru = page_lru(head);
-	mz = page_cgroup_zoneinfo(head_pc->mem_cgroup, head);
+	mz = page_cgroup_zoneinfo(head_memcg, head);
 	MEM_CGROUP_ZSTAT(mz, lru) -= HPAGE_PMD_NR - 1;
 }
 #endif
@@ -2545,7 +2547,7 @@ static int mem_cgroup_move_account(struct page *page,
 	lock_page_cgroup(pc);
 
 	ret = -EINVAL;
-	if (!PageCgroupUsed(pc) || pc->mem_cgroup != from)
+	if (!PageCgroupUsed(pc) || pc_to_memcg(pc) != from)
 		goto unlock;
 
 	mem_cgroup_move_account_wlock(page, &flags);
@@ -2563,7 +2565,7 @@ static int mem_cgroup_move_account(struct page *page,
 		__mem_cgroup_cancel_charge(from, nr_pages);
 
 	/* caller should have done css_get */
-	pc->mem_cgroup = to;
+	pc_set_memcg(pc, to);
 	mem_cgroup_charge_statistics(to, !PageAnon(page), nr_pages);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
@@ -2928,7 +2930,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 
 	lock_page_cgroup(pc);
 
-	memcg = pc->mem_cgroup;
+	memcg = pc_to_memcg(pc);
 
 	if (!PageCgroupUsed(pc))
 		goto unlock_out;
@@ -3109,7 +3111,7 @@ void mem_cgroup_reset_owner(struct page *newpage)
 
 	pc = lookup_page_cgroup(newpage);
 	VM_BUG_ON(PageCgroupUsed(pc));
-	pc->mem_cgroup = root_mem_cgroup;
+	pc_set_memcg(pc, root_mem_cgroup);
 }
 
 /**
@@ -3191,7 +3193,7 @@ int mem_cgroup_prepare_migration(struct page *page,
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
+		memcg = pc_to_memcg(pc);
 		css_get(&memcg->css);
 		/*
 		 * At migrating an anonymous page, its mapcount goes down
@@ -3329,7 +3331,7 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
 	pc = lookup_page_cgroup(oldpage);
 	/* fix accounting on old pages */
 	lock_page_cgroup(pc);
-	memcg = pc->mem_cgroup;
+	memcg = pc_to_memcg(pc);
 	mem_cgroup_charge_statistics(memcg, !PageAnon(oldpage), -1);
 	ClearPageCgroupUsed(pc);
 	unlock_page_cgroup(pc);
@@ -3376,14 +3378,15 @@ void mem_cgroup_print_bad_page(struct page *page)
 	if (pc) {
 		int ret = -1;
 		char *path;
+		struct mem_cgroup *memcg = pc_to_memcg(pc);
 
 		printk(KERN_ALERT "pc:%p pc->flags:%lx pc->mem_cgroup:%p",
-		       pc, pc->flags, pc->mem_cgroup);
+		       pc, pc->_flags, memcg);
 
 		path = kmalloc(PATH_MAX, GFP_KERNEL);
 		if (path) {
 			rcu_read_lock();
-			ret = cgroup_path(pc->mem_cgroup->css.cgroup,
+			ret = cgroup_path(memcg->css.cgroup,
 							path, PATH_MAX);
 			rcu_read_unlock();
 		}
@@ -5247,7 +5250,7 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
 		 * mem_cgroup_move_account() checks the pc is valid or not under
 		 * the lock.
 		 */
-		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+		if (PageCgroupUsed(pc) && pc_to_memcg(pc) == mc.from) {
 			ret = MC_TARGET_PAGE;
 			if (target)
 				target->page = page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
