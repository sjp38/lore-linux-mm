Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E168C6B003D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 02:01:27 -0500 (EST)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id n166xljX010151
	for <linux-mm@kvack.org>; Fri, 6 Feb 2009 17:59:47 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1671b4c1065042
	for <linux-mm@kvack.org>; Fri, 6 Feb 2009 18:01:38 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1671JpC019248
	for <linux-mm@kvack.org>; Fri, 6 Feb 2009 18:01:19 +1100
Date: Fri, 6 Feb 2009 12:31:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
Message-ID: <20090206070116.GE26688@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090203172135.GF918@balbir.in.ibm.com> <20090203144647.09bf9c97.akpm@linux-foundation.org> <20090205135554.61488ed6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090205135554.61488ed6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> [2009-02-05 13:55:54]:

> 
> ping?
>

Andrew,

This patch fixes issues reported with the OOM printing patches.

From: Balbir Singh <balbir@linux.vnet.ibm.com>

1. It reduces the static buffers from 2 to 1
2. It fixes comments that incorrectly indicate that the buffer is on stack

This patch fails checkpatch.pl, due to split of the printk message.
I could not find an easy way to fix it.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)


diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 839258e..9180702 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -736,22 +736,23 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	struct cgroup *task_cgrp;
 	struct cgroup *mem_cgrp;
 	/*
-	 * Need a buffer on stack, can't rely on allocations. The code relies
+	 * Need a buffer in BSS, can't rely on allocations. The code relies
 	 * on the assumption that OOM is serialized for memory controller.
 	 * If this assumption is broken, revisit this code.
 	 */
-	static char task_memcg_name[PATH_MAX];
 	static char memcg_name[PATH_MAX];
 	int ret;
 
 	if (!memcg)
 		return;
 
-	mem_cgrp = memcg->css.cgroup;
-	task_cgrp = mem_cgroup_from_task(p)->css.cgroup;
 
 	rcu_read_lock();
-	ret = cgroup_path(task_cgrp, task_memcg_name, PATH_MAX);
+
+	mem_cgrp = memcg->css.cgroup;
+	task_cgrp = task_cgroup(p, mem_cgroup_subsys_id);
+
+	ret = cgroup_path(task_cgrp, memcg_name, PATH_MAX);
 	if (ret < 0) {
 		/*
 		 * Unfortunately, we are unable to convert to a useful name
@@ -760,16 +761,22 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 		rcu_read_unlock();
 		goto done;
 	}
+	rcu_read_unlock();
+
+	printk(KERN_INFO "Task in %s killed", memcg_name);
+
+	rcu_read_lock();
 	ret = cgroup_path(mem_cgrp, memcg_name, PATH_MAX);
 	if (ret < 0) {
 		rcu_read_unlock();
 		goto done;
 	}
-
 	rcu_read_unlock();
 
-	printk(KERN_INFO "Task in %s killed as a result of limit of %s\n",
-			task_memcg_name, memcg_name);
+	/*
+	 * Continues from above, so we don't need an KERN_ level
+	 */
+	printk(" as a result of limit of %s\n", memcg_name);
 done:
 
 	printk(KERN_INFO "memory: usage %llukB, limit %llukB, failcnt %llu\n",
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
