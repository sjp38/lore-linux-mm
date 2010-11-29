Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 186AC6B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 02:04:47 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAT74isT017295
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 29 Nov 2010 16:04:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BF2E45DE79
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 16:04:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B22245DE4D
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 16:04:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F26ED1DB8037
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 16:04:43 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 80ADFE38005
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 16:04:40 +0900 (JST)
Date: Mon, 29 Nov 2010 15:58:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Question about cgroup hierarchy and reducing memory limit
Message-Id: <20101129155858.6af29381.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTinQ_sqpEc=-vcCQvpp98ny5HSDVvqD_R6_YE3-C@mail.gmail.com>
References: <AANLkTingzd3Pqrip1izfkLm+HCE9jRQL777nu9s3RnLv@mail.gmail.com>
	<20101124094736.3c4ba760.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimSRJ6GC3=bddNMfnVE3LmMx-9xSY2GX_XNvzCA@mail.gmail.com>
	<20101125100428.24920cd3.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinQ_sqpEc=-vcCQvpp98ny5HSDVvqD_R6_YE3-C@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Evgeniy Ivanov <lolkaantimat@gmail.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com
List-ID: <linux-mm.kvack.org>

On Thu, 25 Nov 2010 13:51:06 +0300
Evgeniy Ivanov <lolkaantimat@gmail.com> wrote:

> That would be great, thanks!
> For now we decided either to use decreasing limits in script with
> timeout or controlling the limit just by root group.
> 

I wrote a patch as below but I also found that "success" of shrkinking limit 
means easy OOM Kill because we don't have wait-for-writeback logic.

Now, -EBUSY seems to be a safe guard logic against OOM KILL.
I'd like to wait for the merge of dirty_ratio logic and test this again.
I hope it helps.

Thanks,
-Kame
==
At changing limit of memory cgroup, we see many -EBUSY when
 1. Cgroup is small.
 2. Some tasks are accessing pages very frequently.

It's not very covenient. This patch makes memcg to be in "shrinking" mode
when the limit is shrinking. This patch does,

 a) block new allocation.
 b) ignore page reference bit at shrinking.

The admin should know what he does...

Need:
 - dirty_ratio for avoid OOM.
 - Documentation update.

Note:
 - Sudden shrinking of memory limit tends to cause OOM.
   We need dirty_ratio patch before merging this.

Reported-by: Evgeniy Ivanov <lolkaantimat@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    6 +++++
 mm/memcontrol.c            |   48 +++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |    2 +
 3 files changed, 56 insertions(+)

Index: mmotm-1117/mm/memcontrol.c
===================================================================
--- mmotm-1117.orig/mm/memcontrol.c
+++ mmotm-1117/mm/memcontrol.c
@@ -239,6 +239,7 @@ struct mem_cgroup {
 	unsigned int	swappiness;
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
+	atomic_t	shrinking;
 
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
@@ -1814,6 +1815,25 @@ static int __cpuinit memcg_cpu_hotplug_c
 	return NOTIFY_OK;
 }
 
+static DECLARE_WAIT_QUEUE_HEAD(memcg_shrink_waitq);
+
+bool mem_cgroup_shrinking(struct mem_cgroup *mem)
+{
+	return atomic_read(&mem->shrinking) > 0;
+}
+
+void mem_cgroup_shrink_wait(struct mem_cgroup *mem)
+{
+	wait_queue_t wait;
+
+	init_wait(&wait);
+	prepare_to_wait(&memcg_shrink_waitq, &wait, TASK_INTERRUPTIBLE);
+	smp_rmb();
+	if (mem_cgroup_shrinking(mem))
+		schedule();
+	finish_wait(&memcg_shrink_waitq, &wait);
+}
+
 
 /* See __mem_cgroup_try_charge() for details */
 enum {
@@ -1832,6 +1852,17 @@ static int __mem_cgroup_do_charge(struct
 	unsigned long flags = 0;
 	int ret;
 
+	/*
+ 	 * If shrinking() == true, admin is now reducing limit of memcg and
+ 	 * reclaiming memory eagerly. This _new_ charge will increase usage and
+ 	 * prevents the system from setting new limit. We add delay here and
+ 	 * make reducing size easier.
+ 	 */
+	if (unlikely(mem_cgroup_shrinking(mem)) && (gfp_mask & __GFP_WAIT)) {
+		mem_cgroup_shrink_wait(mem);
+		return CHARGE_RETRY;
+	}
+
 	ret = res_counter_charge(&mem->res, csize, &fail_res);
 
 	if (likely(!ret)) {
@@ -1984,6 +2015,7 @@ again:
 			csize = PAGE_SIZE;
 			css_put(&mem->css);
 			mem = NULL;
+			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
 			goto again;
 		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
 			css_put(&mem->css);
@@ -2938,12 +2970,14 @@ static DEFINE_MUTEX(set_limit_mutex);
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 				unsigned long long val)
 {
+	struct mem_cgroup *iter;
 	int retry_count;
 	u64 memswlimit, memlimit;
 	int ret = 0;
 	int children = mem_cgroup_count_children(memcg);
 	u64 curusage, oldusage;
 	int enlarge;
+	int need_unset_shrinking = 0;
 
 	/*
 	 * For keeping hierarchical_reclaim simple, how long we should retry
@@ -2954,6 +2988,14 @@ static int mem_cgroup_resize_limit(struc
 
 	oldusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 
+	/*
+	 * At reducing limit, new charges should be delayed.
+	 */
+	if (val < res_counter_read_u64(&memcg->res, RES_LIMIT)) {
+		need_unset_shrinking = 1;
+		for_each_mem_cgroup_tree(iter, memcg)
+			atomic_inc(&iter->shrinking);
+	}
 	enlarge = 0;
 	while (retry_count) {
 		if (signal_pending(current)) {
@@ -3001,6 +3043,12 @@ static int mem_cgroup_resize_limit(struc
 	if (!ret && enlarge)
 		memcg_oom_recover(memcg);
 
+	if (need_unset_shrinking) {
+		for_each_mem_cgroup_tree(iter, memcg)
+			atomic_dec(&iter->shrinking);
+		wake_up_all(&memcg_shrink_waitq);
+	}
+
 	return ret;
 }
 
Index: mmotm-1117/include/linux/memcontrol.h
===================================================================
--- mmotm-1117.orig/include/linux/memcontrol.h
+++ mmotm-1117/include/linux/memcontrol.h
@@ -146,6 +146,8 @@ unsigned long mem_cgroup_soft_limit_recl
 						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
 
+bool mem_cgroup_shrinking(struct mem_cgroup *mem);
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -336,6 +338,10 @@ u64 mem_cgroup_get_limit(struct mem_cgro
 	return 0;
 }
 
+static inline bool mem_cgroup_shrinking(struct mem_cgroup *mem);
+{
+	return false;
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
Index: mmotm-1117/mm/vmscan.c
===================================================================
--- mmotm-1117.orig/mm/vmscan.c
+++ mmotm-1117/mm/vmscan.c
@@ -617,6 +617,8 @@ static enum page_references page_check_r
 	/* Lumpy reclaim - ignore references */
 	if (sc->lumpy_reclaim_mode != LUMPY_MODE_NONE)
 		return PAGEREF_RECLAIM;
+	if (!scanning_global_lru(sc) && mem_cgroup_shrinking(sc->mem_cgroup))
+		return PAGEREF_RECLAIM;
 
 	/*
 	 * Mlock lost the isolation race with us.  Let try_to_unmap()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
