Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A29346B003D
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 17:46:57 -0500 (EST)
Date: Tue, 3 Feb 2009 14:46:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
Message-Id: <20090203144647.09bf9c97.akpm@linux-foundation.org>
In-Reply-To: <20090203172135.GF918@balbir.in.ibm.com>
References: <20090203172135.GF918@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009 22:51:35 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> Description: Add RSS and swap to OOM output from memcg
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Changelog v3..v2
> 1. Use static char arrays of size PATH_MAX in order to make
>    the OOM message more reliable.
> 
> Changelog v2..v1:
> 
> 1. Add more information about task's memcg and the memcg
>    over it's limit
> 2. Print data in KB
> 3. Move the print routine outside task_lock()
> 4. Use rcu_read_lock() around cgroup_path, strictly speaking it
>    is not required, but relying on the current memcg implementation
>    is not a good idea.
> 
> 
> This patch displays memcg values like failcnt, usage and limit
> when an OOM occurs due to memcg.
> 
> Thanks go out to Johannes Weiner, Li Zefan, David Rientjes,
> Kamezawa Hiroyuki, Daisuke Nishimura and KOSAKI Motohiro for
> review.
> 
> Sample output
> -------------
> 
> Task in /a/x killed as a result of limit of /a
> memory: usage 1048576kB, limit 1048576kB, failcnt 4183
> memory+swap: usage 1400964kB, limit 9007199254740991kB, failcnt 0
> 
>
> ...
>
> +/**
> + * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in
> + * read mode.
> + * @memcg: The memory cgroup that went over limit
> + * @p: Task that is going to be killed
> + *
> + * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
> + * enabled
> + */
> +void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> +{
> +	struct cgroup *task_cgrp;
> +	struct cgroup *mem_cgrp;
> +	/*
> +	 * Need a buffer on stack, can't rely on allocations. The code relies
> +	 * on the assumption that OOM is serialized for memory controller.
> +	 * If this assumption is broken, revisit this code.
> +	 */
> +	static char task_memcg_name[PATH_MAX];
> +	static char memcg_name[PATH_MAX];

I don't think we need both of these.  With a bit of shuffling we could
reuse the single buffer?

fixlets..

- kerneldoc requires that the function description be a single line

- unmunge whitespace

--- a/mm/memcontrol.c~memcg-show-memcg-information-during-oom-fix
+++ a/mm/memcontrol.c
@@ -724,8 +724,7 @@ static int mem_cgroup_count_children_cb(
 }
 
 /**
- * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in
- * read mode.
+ * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in read mode.
  * @memcg: The memory cgroup that went over limit
  * @p: Task that is going to be killed
  *
@@ -762,7 +761,7 @@ void mem_cgroup_print_oom_info(struct me
 		goto done;
 	}
 	ret = cgroup_path(mem_cgrp, memcg_name, PATH_MAX);
-	 if (ret < 0) {
+	if (ret < 0) {
 		rcu_read_unlock();
 		goto done;
 	}
diff -puN mm/oom_kill.c~memcg-show-memcg-information-during-oom-fix mm/oom_kill.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
