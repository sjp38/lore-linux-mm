Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 146B26B0092
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 02:10:48 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1N7AkcL008118
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 23 Feb 2010 16:10:46 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4340145DE4F
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 16:10:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2118045DE4D
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 16:10:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F1732E08001
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 16:10:45 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F11A1DB8038
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 16:10:42 +0900 (JST)
Date: Tue, 23 Feb 2010 16:07:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: page fault oom improvement v2
Message-Id: <20100223160714.72520b48.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100223155543.796138fc.nishimura@mxp.nes.nec.co.jp>
References: <20100223120315.0da4d792.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223140218.0ab8ee29.nishimura@mxp.nes.nec.co.jp>
	<20100223152116.327a777e.nishimura@mxp.nes.nec.co.jp>
	<20100223152650.e8fc275d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223155543.796138fc.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010 15:55:43 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 23 Feb 2010 15:26:50 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 23 Feb 2010 15:21:16 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > On Tue, 23 Feb 2010 14:02:18 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > On Tue, 23 Feb 2010 12:03:15 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > Nishimura-san, could you review and test your extreme test case with this ?
> > > > > 
> > > > Thank you for your patch.
> > > > I don't know why, but the problem seems not so easy to cause in mmotm as in 2.6.32.8,
> > > > but I'll try more anyway.
> > > > 
> > > I can triggered the problem in mmotm.
> > > 
> > > I'll continue my test with your patch applied.
> > > 
> > 
> > Thank you. Updated one here.
> > 
> Unfortunately, we need one more fix to avoid build error: remove the declaration
> of mem_cgroup_oom_called() from memcontrol.h.
> 
Ouch, I missed to add memcontrol.h to quilt's reflesh set..
This is updated one. Anyway, I'd like to wait for the next mmotm.
We already have several changes. 

-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, because of page_fault_oom_kill, returning VM_FAULT_OOM means
random oom-killer should be called. Considering memcg, it handles
OOM-kill in its own logic, there was a problem as "oom-killer called
twice" problem.

By commit a636b327f731143ccc544b966cfd8de6cb6d72c6, I added a check
in pagefault_oom_killer shouldn't kill some (random) task if
memcg's oom-killer already killed someone.
That was done by comapring current jiffies and last oom jiffies of memcg.

I thought that easy fix was enough, but Nishimura could write a test case
where checking jiffies is not enough. This is a fix of above commit.

This new one does this.
 * memcg's try_charge() never returns -ENOMEM if oom-killer is allowed.
 * If someone is calling oom-killer, wait for it in try_charge().
 * If TIF_MEMDIE is set as a result of try_charge(), return 0 and
   allow process to make progress (and die.) 
 * removed hook in pagefault_out_of_memory.

By this, pagefult_out_of_memory will be never called if memcg's oom-killer
is called.

TODO:
 If __GFP_WAIT is not specified in gfp_mask flag, VM_FAULT_OOM will return
 anyway. We need to investigate it whether there is a case.

Changelog: 2010/02/23
 * fixed MEMDIE condition check.
 * making internal symbols to be static.

Cc: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@in.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    6 ------
 mm/memcontrol.c            |   41 +++++++++++++++++++++++------------------
 mm/oom_kill.c              |   11 +++--------
 3 files changed, 26 insertions(+), 32 deletions(-)

Index: mmotm-2.6.33-Feb11/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Feb11.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Feb11/mm/memcontrol.c
@@ -1234,21 +1234,12 @@ static int mem_cgroup_hierarchical_recla
 	return total;
 }
 
-bool mem_cgroup_oom_called(struct task_struct *task)
+static DEFINE_MUTEX(memcg_oom_mutex);
+static bool mem_cgroup_oom_called(struct mem_cgroup *mem)
 {
-	bool ret = false;
-	struct mem_cgroup *mem;
-	struct mm_struct *mm;
-
-	rcu_read_lock();
-	mm = task->mm;
-	if (!mm)
-		mm = &init_mm;
-	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
-		ret = true;
-	rcu_read_unlock();
-	return ret;
+	if (time_before(jiffies, mem->last_oom_jiffies + HZ/10))
+		return true;
+	return false;
 }
 
 static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
@@ -1549,11 +1540,25 @@ static int __mem_cgroup_try_charge(struc
 		}
 
 		if (!nr_retries--) {
-			if (oom) {
-				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
+			int oom_kill_called;
+			if (!oom)
+				goto nomem;
+			mutex_lock(&memcg_oom_mutex);
+			oom_kill_called = mem_cgroup_oom_called(mem_over_limit);
+			if (!oom_kill_called)
 				record_last_oom(mem_over_limit);
-			}
-			goto nomem;
+			mutex_unlock(&memcg_oom_mutex);
+			if (!oom_kill_called)
+				mem_cgroup_out_of_memory(mem_over_limit,
+				gfp_mask);
+			else /* give a chance to die for other tasks */
+				schedule_timeout(1);
+			nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+			/* Killed myself ? */
+			if (!test_thread_flag(TIF_MEMDIE))
+				continue;
+			/* For smooth oom-kill of current, return 0 */
+			return 0;
 		}
 	}
 	if (csize > PAGE_SIZE)
Index: mmotm-2.6.33-Feb11/mm/oom_kill.c
===================================================================
--- mmotm-2.6.33-Feb11.orig/mm/oom_kill.c
+++ mmotm-2.6.33-Feb11/mm/oom_kill.c
@@ -487,6 +487,9 @@ retry:
 		goto retry;
 out:
 	read_unlock(&tasklist_lock);
+	/* give a chance to die for selected process */
+	if (!test_thread_flag(TIF_MEMDIE))
+		schedule_timeout_uninterruptible(1);
 }
 #endif
 
@@ -601,13 +604,6 @@ void pagefault_out_of_memory(void)
 		/* Got some memory back in the last second. */
 		return;
 
-	/*
-	 * If this is from memcg, oom-killer is already invoked.
-	 * and not worth to go system-wide-oom.
-	 */
-	if (mem_cgroup_oom_called(current))
-		goto rest_and_return;
-
 	if (sysctl_panic_on_oom)
 		panic("out of memory from page fault. panic_on_oom is selected.\n");
 
@@ -619,7 +615,6 @@ void pagefault_out_of_memory(void)
 	 * Give "p" a good chance of killing itself before we
 	 * retry to allocate memory.
 	 */
-rest_and_return:
 	if (!test_thread_flag(TIF_MEMDIE))
 		schedule_timeout_uninterruptible(1);
 }
Index: mmotm-2.6.33-Feb11/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.33-Feb11.orig/include/linux/memcontrol.h
+++ mmotm-2.6.33-Feb11/include/linux/memcontrol.h
@@ -124,7 +124,6 @@ static inline bool mem_cgroup_disabled(v
 	return false;
 }
 
-extern bool mem_cgroup_oom_called(struct task_struct *task);
 void mem_cgroup_update_file_mapped(struct page *page, int val);
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask, int nid,
@@ -258,11 +257,6 @@ static inline bool mem_cgroup_disabled(v
 	return true;
 }
 
-static inline bool mem_cgroup_oom_called(struct task_struct *task)
-{
-	return false;
-}
-
 static inline int
 mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
