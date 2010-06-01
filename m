Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D63F16B01D9
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 05:31:35 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o519VX0s030940
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Jun 2010 18:31:33 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BCDB45DE4C
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 18:31:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 10F4D45DE4E
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 18:31:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E0CB7E08001
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 18:31:32 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B68AE08002
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 18:31:32 +0900 (JST)
Date: Tue, 1 Jun 2010 18:27:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][2/3] memcg safe operaton for checking a cgroup is under move
 accounts
Message-Id: <20100601182720.f1562de6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, for checking a memcg is under task-account-moving, we do css_tryget()
against mc.to and mc.from. But this ust complicates things. This patch
makes the check easier. (And I doubt the current code has some races..)

This patch adds a spinlock to move_charge_struct and guard modification
of mc.to and mc.from. By this, we don't have to think about complicated
races around this not-critical path.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   48 ++++++++++++++++++++++++++++--------------------
 1 file changed, 28 insertions(+), 20 deletions(-)

Index: mmotm-2.6.34-May21/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-May21.orig/mm/memcontrol.c
+++ mmotm-2.6.34-May21/mm/memcontrol.c
@@ -268,6 +268,7 @@ enum move_type {
 
 /* "mc" and its members are protected by cgroup_mutex */
 static struct move_charge_struct {
+	spinlock_t	  lock; /* for from, to, moving_task */
 	struct mem_cgroup *from;
 	struct mem_cgroup *to;
 	unsigned long precharge;
@@ -276,6 +277,7 @@ static struct move_charge_struct {
 	struct task_struct *moving_task;	/* a task moving charges */
 	wait_queue_head_t waitq;		/* a waitq for other context */
 } mc = {
+	.lock = __SPIN_LOCK_UNLOCKED(mc.lock),
 	.waitq = __WAIT_QUEUE_HEAD_INITIALIZER(mc.waitq),
 };
 
@@ -1076,26 +1078,25 @@ static unsigned int get_swappiness(struc
 
 static bool mem_cgroup_under_move(struct mem_cgroup *mem)
 {
-	struct mem_cgroup *from = mc.from;
-	struct mem_cgroup *to = mc.to;
+	struct mem_cgroup *from;
+	struct mem_cgroup *to;
 	bool ret = false;
-
-	if (from == mem || to == mem)
-		return true;
-
-	if (!from || !to || !mem->use_hierarchy)
-		return false;
-
-	rcu_read_lock();
-	if (css_tryget(&from->css)) {
-		ret = css_is_ancestor(&from->css, &mem->css);
-		css_put(&from->css);
-	}
-	if (!ret && css_tryget(&to->css)) {
-		ret = css_is_ancestor(&to->css,	&mem->css);
+	/*
+	 * Unlike task_move routines, we access mc.to, mc.from not under
+	 * mutual execution by cgroup_mutex. Here, we take spinlock instead.
+	 */
+	spin_lock_irq(&mc.lock);
+	from = mc.from;
+	to = mc.to;
+	if (!from)
+		goto unlock;
+	if (from == mem || to == mem
+	    || (mem->use_hierarchy && css_is_ancestor(&from->css, &mem->css))
+	    || (mem->use_hierarchy && css_is_ancestor(&to->css,	&mem->css)))
 		css_put(&to->css);
-	}
-	rcu_read_unlock();
+		ret = true;
+unlock:
+	spin_unlock_irq(&mc.lock);
 	return ret;
 }
 
@@ -4444,11 +4445,13 @@ static int mem_cgroup_precharge_mc(struc
 
 static void mem_cgroup_clear_mc(void)
 {
+	struct mem_cgroup *from = mc.from;
+	struct mem_cgroup *to = mc.to;
+
 	/* we must uncharge all the leftover precharges from mc.to */
 	if (mc.precharge) {
 		__mem_cgroup_cancel_charge(mc.to, mc.precharge);
 		mc.precharge = 0;
-		memcg_oom_recover(mc.to);
 	}
 	/*
 	 * we didn't uncharge from mc.from at mem_cgroup_move_account(), so
@@ -4457,7 +4460,6 @@ static void mem_cgroup_clear_mc(void)
 	if (mc.moved_charge) {
 		__mem_cgroup_cancel_charge(mc.from, mc.moved_charge);
 		mc.moved_charge = 0;
-		memcg_oom_recover(mc.from);
 	}
 	/* we must fixup refcnts and charges */
 	if (mc.moved_swap) {
@@ -4482,9 +4484,13 @@ static void mem_cgroup_clear_mc(void)
 
 		mc.moved_swap = 0;
 	}
+	spin_lock_irq(&mc.lock);
 	mc.from = NULL;
 	mc.to = NULL;
 	mc.moving_task = NULL;
+	spin_unlock_irq(&mc.lock);
+	memcg_oom_recover(from);
+	memcg_oom_recover(to);
 	wake_up_all(&mc.waitq);
 }
 
@@ -4513,12 +4519,14 @@ static int mem_cgroup_can_attach(struct 
 			VM_BUG_ON(mc.moved_charge);
 			VM_BUG_ON(mc.moved_swap);
 			VM_BUG_ON(mc.moving_task);
+			spin_lock_irq(&mc.lock);
 			mc.from = from;
 			mc.to = mem;
 			mc.precharge = 0;
 			mc.moved_charge = 0;
 			mc.moved_swap = 0;
 			mc.moving_task = current;
+			spin_unlock_irq(&mc.lock);
 
 			ret = mem_cgroup_precharge_mc(mm);
 			if (ret)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
