Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 00EB06B00E9
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 05:21:31 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C852F3EE0B3
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:21:29 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ADC4E45DE53
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:21:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9419C45DE50
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:21:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 82BABEF8002
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:21:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 423EE1DB803B
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:21:29 +0900 (JST)
Date: Fri, 14 Jan 2011 19:15:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/4] [BUGFIX] fix account leak at force_empty, rmdir with
 THP
Message-Id: <20110114191535.309b634c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, hannes@cmpxchg.org, aarcange@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Now, when THP is enabled, memcg's rmdir() function is broken
because move_account() for THP page is not supported.

This will cause account leak or -EBUSY issue at rmdir().
This patch fixes the issue by supporting move_account() THP pages.

And account information will be moved to its parent at rmdir().

How to test:
   79  mount -t cgroup none /cgroup/memory/ -o memory
   80  mkdir /cgroup/A/
   81  mkdir /cgroup/memory/A
   82  mkdir /cgroup/memory/A/B
   83  cgexec -g memory:A/B ./malloc 128 &
   84  grep anon /cgroup/memory/A/B/memory.stat
   85  grep rss /cgroup/memory/A/B/memory.stat
   86  echo 1728 > /cgroup/memory/A/tasks
   87  grep rss /cgroup/memory/A/memory.stat
   88  rmdir /cgroup/memory/A/B/
   89  grep rss /cgroup/memory/A/memory.stat

- Create 2 level directory and exec a task calls malloc(big chunk).
- Move a task somewhere (its parent cgroup in above)
- rmdir /A/B
- check memory.stat in /A/B is moved to /A after rmdir. and confirm
  RSS/LRU information includes usages it was charged against /A/B.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   32 ++++++++++++++++++++++----------
 1 file changed, 22 insertions(+), 10 deletions(-)

Index: mmotm-0107/mm/memcontrol.c
===================================================================
--- mmotm-0107.orig/mm/memcontrol.c
+++ mmotm-0107/mm/memcontrol.c
@@ -2154,6 +2154,10 @@ void mem_cgroup_split_huge_fixup(struct 
 	smp_wmb(); /* see __commit_charge() */
 	SetPageCgroupUsed(tpc);
 	VM_BUG_ON(PageCgroupCache(hpc));
+	/*
+ 	 * Note: if dirty ratio etc..are supported,
+         * other flags may need to be copied.
+         */
 }
 #endif
 
@@ -2175,8 +2179,11 @@ void mem_cgroup_split_huge_fixup(struct 
  */
 
 static void __mem_cgroup_move_account(struct page_cgroup *pc,
-	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
+	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge,
+	int charge_size)
 {
+	int pagenum = charge_size >> PAGE_SHIFT;
+
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
 	VM_BUG_ON(!page_is_cgroup_locked(pc));
@@ -2190,14 +2197,14 @@ static void __mem_cgroup_move_account(st
 		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		preempt_enable();
 	}
-	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -1);
+	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -pagenum);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
-		mem_cgroup_cancel_charge(from, PAGE_SIZE);
+		mem_cgroup_cancel_charge(from, charge_size);
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
-	mem_cgroup_charge_statistics(to, PageCgroupCache(pc), 1);
+	mem_cgroup_charge_statistics(to, PageCgroupCache(pc), pagenum);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
 	 * can be under rmdir(). But in current implementation, caller of
@@ -2212,7 +2219,8 @@ static void __mem_cgroup_move_account(st
  * __mem_cgroup_move_account()
  */
 static int mem_cgroup_move_account(struct page_cgroup *pc,
-		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
+		struct mem_cgroup *from, struct mem_cgroup *to,
+		bool uncharge, int charge_size)
 {
 	int ret = -EINVAL;
 	unsigned long flags;
@@ -2220,7 +2228,7 @@ static int mem_cgroup_move_account(struc
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
 		move_lock_page_cgroup(pc, &flags);
-		__mem_cgroup_move_account(pc, from, to, uncharge);
+		__mem_cgroup_move_account(pc, from, to, uncharge, charge_size);
 		move_unlock_page_cgroup(pc, &flags);
 		ret = 0;
 	}
@@ -2245,6 +2253,7 @@ static int mem_cgroup_move_parent(struct
 	struct cgroup *cg = child->css.cgroup;
 	struct cgroup *pcg = cg->parent;
 	struct mem_cgroup *parent;
+	int charge_size = PAGE_SIZE;
 	int ret;
 
 	/* Is ROOT ? */
@@ -2256,16 +2265,19 @@ static int mem_cgroup_move_parent(struct
 		goto out;
 	if (isolate_lru_page(page))
 		goto put;
+	/* The page is isolated from LRU and we have no race with splitting */
+	if (PageTransHuge(page))
+		charge_size = PAGE_SIZE << compound_order(page);
 
 	parent = mem_cgroup_from_cont(pcg);
 	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false,
-				      PAGE_SIZE);
+				      charge_size);
 	if (ret || !parent)
 		goto put_back;
 
-	ret = mem_cgroup_move_account(pc, child, parent, true);
+	ret = mem_cgroup_move_account(pc, child, parent, true, charge_size);
 	if (ret)
-		mem_cgroup_cancel_charge(parent, PAGE_SIZE);
+		mem_cgroup_cancel_charge(parent, charge_size);
 put_back:
 	putback_lru_page(page);
 put:
@@ -4850,7 +4862,7 @@ retry:
 				goto put;
 			pc = lookup_page_cgroup(page);
 			if (!mem_cgroup_move_account(pc,
-						mc.from, mc.to, false)) {
+					mc.from, mc.to, false, PAGE_SIZE)) {
 				mc.precharge--;
 				/* we uncharge from mc.from later. */
 				mc.moved_charge++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
