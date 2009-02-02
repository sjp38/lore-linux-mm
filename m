Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 489015F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 09:17:44 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n12EH8W1032656
	for <linux-mm@kvack.org>; Mon, 2 Feb 2009 19:47:08 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n12EHDGG4124922
	for <linux-mm@kvack.org>; Mon, 2 Feb 2009 19:47:13 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n12EH75t029136
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 01:17:08 +1100
Date: Mon, 2 Feb 2009 19:47:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM
Message-ID: <20090202141705.GE918@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090202125240.GA918@balbir.in.ibm.com> <20090202215527.EC92.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090202215527.EC92.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-02-02 21:59:34]:

> Hi
> 
> > +void mem_cgroup_print_mem_info(struct mem_cgroup *memcg)
> > +{
> > +	printk(KERN_WARNING "Memory cgroups's name %s\n",
> > +		memcg->css.cgroup->dentry->d_name.name);
> > +	printk(KERN_WARNING "Memory cgroup RSS : usage %llu, limit %llu"
> > +		" failcnt %llu\n", res_counter_read_u64(&memcg->res, RES_USAGE),
> > +		res_counter_read_u64(&memcg->res, RES_LIMIT),
> > +		res_counter_read_u64(&memcg->res, RES_FAILCNT));
> > +	printk(KERN_WARNING "Memory cgroup swap: usage %llu, limit %llu "
> > +		"failcnt %llu\n", res_counter_read_u64(&memcg->res, RES_USAGE),
> > +		res_counter_read_u64(&memcg->res, RES_LIMIT),
> > +		res_counter_read_u64(&memcg->res, RES_FAILCNT));
>

Thanks! How does this look

Description: Add RSS and swap to OOM output from memcg

From: Balbir Singh <balbir@linux.vnet.ibm.com>

This patch displays memcg values like failcnt, usage and limit
when an OOM occurs due to memcg.

Thanks go out to Johannes Weiner <hannes@cmpxchg.org> and
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> for review.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h |    5 +++++
 mm/memcontrol.c            |   19 +++++++++++++++++++
 mm/oom_kill.c              |    1 +
 3 files changed, 25 insertions(+), 0 deletions(-)


diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 326f45c..2ce1737 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -104,6 +104,7 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone);
 struct zone_reclaim_stat*
 mem_cgroup_get_reclaim_stat_from_page(struct page *page);
+extern void mem_cgroup_print_mem_info(struct mem_cgroup *memcg);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
@@ -270,6 +271,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	return NULL;
 }
 
+void mem_cgroup_print_mem_info(struct mem_cgroup *memcg)
+{
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8e4be9c..954b0d5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -813,6 +813,25 @@ bool mem_cgroup_oom_called(struct task_struct *task)
 	rcu_read_unlock();
 	return ret;
 }
+
+void mem_cgroup_print_mem_info(struct mem_cgroup *memcg)
+{
+	if (!memcg)
+		return;
+
+	printk(KERN_WARNING "Memory cgroups's name %s\n",
+		memcg->css.cgroup->dentry->d_name.name);
+	printk(KERN_WARNING "Cgroup memory: usage %llu, limit %llu"
+		" failcnt %llu\n", res_counter_read_u64(&memcg->res, RES_USAGE),
+		res_counter_read_u64(&memcg->res, RES_LIMIT),
+		res_counter_read_u64(&memcg->res, RES_FAILCNT));
+	printk(KERN_WARNING "Cgroup memory+swap: usage %llu, limit %llu "
+		"failcnt %llu\n",
+		res_counter_read_u64(&memcg->memsw, RES_USAGE),
+		res_counter_read_u64(&memcg->memsw, RES_LIMIT),
+		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
+}
+
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d3b9bac..b8e53ae 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -392,6 +392,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			current->comm, gfp_mask, order, current->oomkilladj);
 		task_lock(current);
 		cpuset_print_task_mems_allowed(current);
+		mem_cgroup_print_mem_info(mem);
 		task_unlock(current);
 		dump_stack();
 		show_mem();

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
