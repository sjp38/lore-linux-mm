Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F3E0D6B0106
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 21:04:47 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7Q14klg022760
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 26 Aug 2009 10:04:47 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AB5B745DE52
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 10:04:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8742845DE4C
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 10:04:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 71E2C1DB803F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 10:04:46 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 10BBC1DB803C
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 10:04:43 +0900 (JST)
Date: Wed, 26 Aug 2009 10:02:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][preview] memcg: reduce lock contention at uncharge by
 batching
Message-Id: <20090826100256.5f0fb2a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090825112547.c2692965.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090825112547.c2692965.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

With attached patch below, per-cpu-precharge,

I got this number,

[Before] linux-2.6.31-rc7
real    2m46.491s
user    4m47.008s
sys     3m32.954s


lock_stat version 0.3
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                              class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                          &counter->lock:       1167034        1196935           0.52       16291.34      829793.69       18742433       45050576           0.42       30788.81     9490908.36
                          --------------
                          &counter->lock         638151          [<ffffffff81090fd5>] res_counter_charge+0x45/0xe0
                          &counter->lock         558784          [<ffffffff81090f5d>] res_counter_uncharge+0x2d/0x60
                          --------------
                          &counter->lock         679567          [<ffffffff81090fd5>] res_counter_charge+0x45/0xe0
                          &counter->lock         517368          [<ffffffff81090f5d>] res_counter_uncharge+0x2d/0x60

[After] precharge+batched uncharge
real    2m46.799s
user    4m49.523s
sys     3m18.916s
                         &counter->lock:         12785          12984           0.71          34.87        6768.24
       967813        4937090           0.47       20257.57      953289.67
                          --------------
                          &counter->lock          11117          [<ffffffff81090f3d>] res_counter_uncharge+0x2d/0x60
                          &counter->lock           1867          [<ffffffff81090fb5>] res_counter_charge+0x45/0xe0
                          --------------
                          &counter->lock          10691          [<ffffffff81090f3d>] res_counter_uncharge+0x2d/0x60
                          &counter->lock           2293          [<ffffffff81090fb5>] res_counter_charge+0x45/0xe0

I think patch below is enough simple. (but I need to support flush&cpu-hotplug)
I'd like to rebase this onto mmotom. 
Main difference with percpu_counter is that this is pre-charge and never goes over limit.

--
Index: linux-2.6.31-rc7/mm/memcontrol.c
===================================================================
--- linux-2.6.31-rc7.orig/mm/memcontrol.c	2009-08-26 09:11:57.000000000 +0900
+++ linux-2.6.31-rc7/mm/memcontrol.c	2009-08-26 09:46:51.000000000 +0900
@@ -67,6 +67,7 @@
 	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 
+	MEM_CGROUP_STAT_PRECHARGE, /* # of charges pre-allocated for future */
 	MEM_CGROUP_STAT_NSTATS,
 };
 
@@ -959,6 +960,32 @@
 	unlock_page_cgroup(pc);
 }
 
+#define CHARGE_SIZE	(4 * ((NR_CPUS >> 5)+1) * PAGE_SIZE)
+
+bool use_precharge(struct mem_cgroup *mem)
+{
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu = get_cpu();
+	bool ret = true;
+
+	cstat = &mem->stat.cpustat[cpu];
+	if (cstat->count[MEM_CGROUP_STAT_PRECHARGE])
+		cstat->count[MEM_CGROUP_STAT_PRECHARGE] -= PAGE_SIZE;
+	else
+		ret = false;
+	put_cpu();
+	return ret;
+}
+
+void do_precharge(struct mem_cgroup *mem, int val)
+{
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu = get_cpu();
+	cstat = &mem->stat.cpustat[cpu];
+	__mem_cgroup_stat_add_safe(cstat, MEM_CGROUP_STAT_PRECHARGE, val);
+	put_cpu();
+}
+
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
@@ -995,20 +1022,24 @@
 
 	VM_BUG_ON(css_is_removed(&mem->css));
 
+	/* can we use precharge ? */
+	if (use_precharge(mem))
+		goto got;
+
 	while (1) {
 		int ret;
 		bool noswap = false;
 
-		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
+		ret = res_counter_charge(&mem->res, CHARGE_SIZE, &fail_res);
 		if (likely(!ret)) {
 			if (!do_swap_account)
 				break;
-			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
+			ret = res_counter_charge(&mem->memsw, CHARGE_SIZE,
 							&fail_res);
 			if (likely(!ret))
 				break;
 			/* mem+swap counter fails */
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
+			res_counter_uncharge(&mem->res, CHARGE_SIZE);
 			noswap = true;
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									memsw);
@@ -1046,6 +1077,8 @@
 			goto nomem;
 		}
 	}
+	do_precharge(mem, CHARGE_SIZE-PAGE_SIZE);
+got:
 	return 0;
 nomem:
 	css_put(&mem->css);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
