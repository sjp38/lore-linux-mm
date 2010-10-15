Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D13B6B0181
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 04:17:52 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9F8Hl48006352
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 15 Oct 2010 17:17:48 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 945C345DE4C
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:17:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 645761EF081
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:17:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D77D1DB8022
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:17:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E1BE41DB801A
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:17:45 +0900 (JST)
Date: Fri, 15 Oct 2010 17:12:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/2] memcg: new lock for mutual execution of
 account_move and file stats
Message-Id: <20101015171225.70d4ca8f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101015170627.e5033fa4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101015170627.e5033fa4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

When we try to enhance page's status update to support other flags,
one of problem is updating status from IRQ context.

Now, mem_cgroup_update_file_stat() takes lock_page_cgroup() to avoid
race with _account move_. IOW, there are no races with charge/uncharge
in nature. Considering an update from IRQ context, it seems better
to disable IRQ at lock_page_cgroup() to avoid deadlock.

But lock_page_cgroup() is used too widerly and adding IRQ disable
there makes the performance bad. To avoid the big hammer, this patch
adds a new lock for update_stat().

This lock is for mutual execustion of updating stat and accout moving.
This adds a new lock to move_account..so, this makes move_account slow.
But considering trade-off, I think it's acceptable.

A score of moving 8GB anon pages, 8cpu Xeon(3.1GHz) is here.

[before patch] (mmotm + optimization patch (#1 in this series)
[root@bluextal kamezawa]# time echo 2257 > /cgroup/B/tasks

real    0m0.694s
user    0m0.000s
sys     0m0.683s

[After patch]
[root@bluextal kamezawa]# time echo 2238 > /cgroup/B/tasks

real    0m0.741s
user    0m0.000s
sys     0m0.730s

This moves 8Gbytes == 2048k pages. But no bad effects to codes
other than "move".

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |   29 +++++++++++++++++++++++++++++
 mm/memcontrol.c             |   11 +++++++++--
 2 files changed, 38 insertions(+), 2 deletions(-)

Index: mmotm-1013/include/linux/page_cgroup.h
===================================================================
--- mmotm-1013.orig/include/linux/page_cgroup.h
+++ mmotm-1013/include/linux/page_cgroup.h
@@ -36,6 +36,7 @@ struct page_cgroup *lookup_page_cgroup(s
 enum {
 	/* flags for mem_cgroup */
 	PCG_LOCK,  /* page cgroup is locked */
+	PCG_LOCK_STATS, /* page cgroup's stat accounting flags are locked */
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
 	PCG_ACCT_LRU, /* page has been accounted for */
@@ -104,6 +105,34 @@ static inline void unlock_page_cgroup(st
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+/*
+ * Because page's status can be updated in IRQ context(PG_writeback)
+ * we disable IRQ at updating page's stat.
+ */
+static inline void lock_page_cgroup_stat(struct page_cgroup *pc,
+	unsigned long *flags)
+{
+	local_irq_save(*flags);
+	bit_spin_lock(PCG_LOCK_STATS, &pc->flags);
+}
+
+static inline void __lock_page_cgroup_stat(struct page_cgroup *pc)
+{
+	bit_spin_lock(PCG_LOCK_STATS, &pc->flags);
+}
+
+static inline void unlock_page_cgroup_stat(struct page_cgroup *pc,
+	unsigned long *flags)
+{
+	bit_spin_unlock(PCG_LOCK_STATS, &pc->flags);
+	local_irq_restore(*flags);
+}
+
+static inline void __unlock_page_cgroup_stat(struct page_cgroup *pc)
+{
+	bit_spin_unlock(PCG_LOCK_STATS, &pc->flags);
+}
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
Index: mmotm-1013/mm/memcontrol.c
===================================================================
--- mmotm-1013.orig/mm/memcontrol.c
+++ mmotm-1013/mm/memcontrol.c
@@ -1596,6 +1596,7 @@ static void mem_cgroup_update_file_stat(
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 	bool need_unlock = false;
+	unsigned long flags = 0;
 
 	if (unlikely(!pc))
 		return;
@@ -1607,7 +1608,7 @@ static void mem_cgroup_update_file_stat(
 	/* pc->mem_cgroup is unstable ? */
 	if (unlikely(mem_cgroup_stealed(mem))) {
 		/* take a lock against to access pc->mem_cgroup */
-		lock_page_cgroup(pc);
+		lock_page_cgroup_stat(pc, &flags);
 		need_unlock = true;
 		mem = pc->mem_cgroup;
 		if (!mem || !PageCgroupUsed(pc))
@@ -1629,7 +1630,7 @@ static void mem_cgroup_update_file_stat(
 
 out:
 	if (unlikely(need_unlock))
-		unlock_page_cgroup(pc);
+		unlock_page_cgroup_stat(pc, &flags);
 	rcu_read_unlock();
 	return;
 }
@@ -2187,12 +2188,18 @@ static int mem_cgroup_move_account(struc
 		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
 	int ret = -EINVAL;
+
+	/* Avoiding dead-lock with page stat updates via irq context */
+	local_irq_disable();
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
+		__lock_page_cgroup_stat(pc);
 		__mem_cgroup_move_account(pc, from, to, uncharge);
+		__unlock_page_cgroup_stat(pc);
 		ret = 0;
 	}
 	unlock_page_cgroup(pc);
+	local_irq_enable();
 	/*
 	 * check events
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
