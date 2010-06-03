Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C1E8E6B0210
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 03:05:38 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5375aSi003412
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Jun 2010 16:05:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 589CE45DE52
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 16:05:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2701045DE51
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 16:05:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1259E1DB803A
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 16:05:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B5BAFE18006
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 16:05:32 +0900 (JST)
Date: Thu, 3 Jun 2010 16:01:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg make move_task_charge check clearer
Message-Id: <20100603160119.e9ffc342.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100603154031.f80fc900.nishimura@mxp.nes.nec.co.jp>
References: <20100603114837.6e6d4d0f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100603115119.be29ec13.kamezawa.hiroyu@jp.fujitsu.com>
	<20100603154031.f80fc900.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010 15:40:31 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
		css_put(&to->css);
> I think this css_put() must be removed too.
> Except for it, this patch looks good to me.
> 
Nice catch. Thank you.

> Thank you for cleaning up my dirty code :)

no problem. create -> bugfix -> clean up is in a wheel of development.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, for checking a memcg is under task-account-moving, we do css_tryget()
against mc.to and mc.from. But this is just complicating things. This patch
makes the check easier.

This patch adds a spinlock to move_charge_struct and guard modification
of mc.to and mc.from. By this, we don't have to think about complicated
races arount this not-critical path.

Changelog:
 - removed disable/enable irq.
 - removed unnecessary css_put()

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   49 ++++++++++++++++++++++++++++---------------------
 1 file changed, 28 insertions(+), 21 deletions(-)

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
 
@@ -1076,26 +1078,24 @@ static unsigned int get_swappiness(struc
 
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
-		css_put(&to->css);
-	}
-	rcu_read_unlock();
+	/*
+	 * Unlike task_move routines, we access mc.to, mc.from not under
+	 * mutual exclusion by cgroup_mutex. Here, we take spinlock instead.
+	 */
+	spin_lock(&mc.lock);
+	from = mc.from;
+	to = mc.to;
+	if (!from)
+		goto unlock;
+	if (from == mem || to == mem
+	    || (mem->use_hierarchy && css_is_ancestor(&from->css, &mem->css))
+	    || (mem->use_hierarchy && css_is_ancestor(&to->css,	&mem->css)))
+		ret = true;
+unlock:
+	spin_unlock(&mc.lock);
 	return ret;
 }
 
@@ -4447,11 +4447,13 @@ static int mem_cgroup_precharge_mc(struc
 
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
@@ -4460,7 +4462,6 @@ static void mem_cgroup_clear_mc(void)
 	if (mc.moved_charge) {
 		__mem_cgroup_cancel_charge(mc.from, mc.moved_charge);
 		mc.moved_charge = 0;
-		memcg_oom_recover(mc.from);
 	}
 	/* we must fixup refcnts and charges */
 	if (mc.moved_swap) {
@@ -4485,9 +4486,13 @@ static void mem_cgroup_clear_mc(void)
 
 		mc.moved_swap = 0;
 	}
+	spin_lock(&mc.lock);
 	mc.from = NULL;
 	mc.to = NULL;
 	mc.moving_task = NULL;
+	spin_unlock(&mc.lock);
+	memcg_oom_recover(from);
+	memcg_oom_recover(to);
 	wake_up_all(&mc.waitq);
 }
 
@@ -4516,12 +4521,14 @@ static int mem_cgroup_can_attach(struct 
 			VM_BUG_ON(mc.moved_charge);
 			VM_BUG_ON(mc.moved_swap);
 			VM_BUG_ON(mc.moving_task);
+			spin_lock(&mc.lock);
 			mc.from = from;
 			mc.to = mem;
 			mc.precharge = 0;
 			mc.moved_charge = 0;
 			mc.moved_swap = 0;
 			mc.moving_task = current;
+			spin_unlock(&mc.lock);
 
 			ret = mem_cgroup_precharge_mc(mm);
 			if (ret)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
