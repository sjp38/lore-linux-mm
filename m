Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C94C46B00B4
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 00:51:11 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J4p8ih017447
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 19 Oct 2010 13:51:08 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 664A845DE7B
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:51:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 38CEE45DE6E
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:51:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 158541DB803E
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:51:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B95531DB803A
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:51:07 +0900 (JST)
Date: Tue, 19 Oct 2010 13:45:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/2] memcg: move_account optimization  by reduce locks
 (Re: [PATCH v3 04/11] memcg: add lock to synchronize page accounting and
 migration
Message-Id: <20101019134541.455eeaba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101019134308.3fe81638.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-5-git-send-email-gthelen@google.com>
	<20101019094512.11eabc62.kamezawa.hiroyu@jp.fujitsu.com>
	<20101019134308.3fe81638.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

reduce lock at account moving.

a patch "memcg: add lock to synchronize page accounting and migration" add
a new lock and make locking cost twice. This patch is for reducing the cost.

At moving charges by scanning page table, we do all jobs under pte_lock.
This means we never have race with "uncharge". Because of that,
we can remove lock_page_cgroup() in some situation.

The cost of moing 8G anon process
==
[mmotm-1013]
Before:
	real    0m0.792s
	user    0m0.000s
	sys     0m0.780s
	
[dirty-limit v3 patch]
        real    0m0.854s
        user    0m0.000s
        sys     0m0.842s
[get/put optimization ]
	real    0m0.757s
	user    0m0.000s
	sys     0m0.746s

[this patch]
	real    0m0.732s
	user    0m0.000s
	sys     0m0.721s

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   23 ++++++++++++++++++++++-
 mm/memcontrol.c                  |   29 ++++++++++++++++++++++-------
 2 files changed, 44 insertions(+), 8 deletions(-)

Index: dirty_limit_new/mm/memcontrol.c
===================================================================
--- dirty_limit_new.orig/mm/memcontrol.c
+++ dirty_limit_new/mm/memcontrol.c
@@ -2386,7 +2386,6 @@ static void __mem_cgroup_move_account(st
 {
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
-	VM_BUG_ON(!PageCgroupLocked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
 	VM_BUG_ON(pc->mem_cgroup != from);
 
@@ -2424,19 +2423,32 @@ static void __mem_cgroup_move_account(st
  * __mem_cgroup_move_account()
  */
 static int mem_cgroup_move_account(struct page_cgroup *pc,
-		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
+		struct mem_cgroup *from, struct mem_cgroup *to,
+		bool uncharge, bool stable)
 {
 	int ret = -EINVAL;
 	unsigned long flags;
-
-	lock_page_cgroup(pc);
+	/*
+	 * When stable==true, some lock (page_table_lock etc.) prevents
+	 * modification of PCG_USED bit and pc->mem_cgroup never be invalid.
+	 * IOW, there will be no race with charge/uncharge. From another point
+	 * of view, there will be other races with codes which accesses
+	 * pc->mem_cgroup under lock_page_cgroup(). Considering what
+	 * pc->mem_cgroup the codes will see, they'll see old or new value and
+	 * both of values will never be invalid while they holds
+	 * lock_page_cgroup(). There is no probelm to skip lock_page_cgroup
+	 * when we can.
+	 */
+	if (!stable)
+		lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
 		move_lock_page_cgroup(pc, &flags);
 		__mem_cgroup_move_account(pc, from, to, uncharge);
 		move_unlock_page_cgroup(pc, &flags);
 		ret = 0;
 	}
-	unlock_page_cgroup(pc);
+	if (!stable)
+		unlock_page_cgroup(pc);
 	/*
 	 * check events
 	 */
@@ -2474,7 +2486,7 @@ static int mem_cgroup_move_parent(struct
 	if (ret || !parent)
 		goto put_back;
 
-	ret = mem_cgroup_move_account(pc, child, parent, true);
+	ret = mem_cgroup_move_account(pc, child, parent, true, false);
 	if (ret)
 		mem_cgroup_cancel_charge(parent);
 put_back:
@@ -5156,6 +5168,7 @@ retry:
 		struct page *page;
 		struct page_cgroup *pc;
 		swp_entry_t ent;
+		bool mapped = false;
 
 		if (!mc.precharge)
 			break;
@@ -5163,12 +5176,14 @@ retry:
 		type = is_target_pte_for_mc(vma, addr, ptent, &target);
 		switch (type) {
 		case MC_TARGET_PAGE:
+			mapped = true;
+			/* Fall Through */
 		case MC_TARGET_UNMAPPED_PAGE:
 			page = target.page;
 			if (!isolate_lru_page(page)) {
 				pc = lookup_page_cgroup(page);
 				if (!mem_cgroup_move_account(pc, mc.from,
-						mc.to, false)) {
+						mc.to, false, mapped)) {
 					mc.precharge--;
 					/* we uncharge from mc.from later. */
 					mc.moved_charge++;
Index: dirty_limit_new/Documentation/cgroups/memory.txt
===================================================================
--- dirty_limit_new.orig/Documentation/cgroups/memory.txt
+++ dirty_limit_new/Documentation/cgroups/memory.txt
@@ -637,7 +637,28 @@ memory cgroup.
       | page_mapcount(page) > 1). You must enable Swap Extension(see 2.4) to
       | enable move of swap charges.
 
-8.3 TODO
+8.3 Implemenation Detail
+
+  At moving, we need to take care of races. At first thinking, there are
+  several sources of race when we overwrite pc->mem_cgroup.
+  - charge/uncharge
+  - file stat (dirty, writeback, etc..) accounting
+  - LRU add/remove
+
+  Against charge/uncharge, we do all "move" under pte_lock. So, if we move
+  chareges of a mapped pages, we don't need extra locks. If not mapped,
+  we need to take lock_page_cgroup.
+
+  Against file-stat accouning, we need some locks. Current implementation
+  uses 2 level locking, one is light-weight, another is heavy.
+  A light-weight scheme is to use per-cpu counter. If someone moving a charge
+  from a mem_cgroup, per-cpu "caution" counter is incremented and file-stat
+  update will use heavy lock. This heavy lock is a special lock for move_charge
+  and allow mutual execution of accessing pc->mem_cgroup.
+
+  Against LRU, we do isolate_lru_page() before move_account().
+
+8.4 TODO
 
 - Implement madvise(2) to let users decide the vma to be moved or not to be
   moved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
