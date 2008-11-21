Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mALA2Zv2020805
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 21 Nov 2008 19:02:35 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8632C45DD72
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 19:02:35 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 66EE645DE4E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 19:02:35 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B59F1DB803C
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 19:02:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DF7E11DB803F
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 19:02:34 +0900 (JST)
Date: Fri, 21 Nov 2008 19:01:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] memcg: avoid unnecessary system-wide-oom-killer
Message-Id: <20081121190152.fa6843fb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081121185829.e04c8116.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>
	<20081114191949.926bf99d.kamezawa.hiroyu@jp.fujitsu.com>
	<49261F87.50209@cn.fujitsu.com>
	<20081121185829.e04c8116.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, pbadari@us.ibm.com, jblunck@suse.de, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Current mmtom has new oom function as pagefault_out_of_memory().
It's added for select bad process rathar than killing current.

When memcg hit limit and calls OOM at page_fault, this handler
called and system-wide-oom handling happens.
(means kernel panics if panic_on_oom is true....)

For avoiding overkill, check memcg's recent behavior before
starting system-wide-oom.

And this patch also fixes to guarantee "don't accnout against
process with TIF_MEMDIE". This is necessary for smooth OOM.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/memcontrol.h |    6 ++++++
 mm/memcontrol.c            |   33 +++++++++++++++++++++++++++++----
 mm/oom_kill.c              |    8 ++++++++
 3 files changed, 43 insertions(+), 4 deletions(-)

Index: mmotm-2.6.28-Nov20/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-Nov20.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-Nov20/include/linux/memcontrol.h
@@ -95,6 +95,8 @@ static inline bool mem_cgroup_disabled(v
 	return false;
 }
 
+extern bool mem_cgroup_oom_called(struct task_struct *task);
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -227,6 +229,10 @@ static inline bool mem_cgroup_disabled(v
 {
 	return true;
 }
+static inline bool mem_cgroup_oom_called(struct task_struct *task);
+{
+	return false;
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
Index: mmotm-2.6.28-Nov20/mm/oom_kill.c
===================================================================
--- mmotm-2.6.28-Nov20.orig/mm/oom_kill.c
+++ mmotm-2.6.28-Nov20/mm/oom_kill.c
@@ -560,6 +560,13 @@ void pagefault_out_of_memory(void)
 		/* Got some memory back in the last second. */
 		return;
 
+	/*
+	 * If this is from memcg, oom-killer is already invoked.
+	 * and not worth to go system-wide-oom.
+	 */
+	if (mem_cgroup_oom_called(current))
+		goto rest_and_return;
+
 	if (sysctl_panic_on_oom)
 		panic("out of memory from page fault. panic_on_oom is selected.\n");
 
@@ -571,6 +578,7 @@ void pagefault_out_of_memory(void)
 	 * Give "p" a good chance of killing itself before we
 	 * retry to allocate memory.
 	 */
+rest_and_return:
 	if (!test_thread_flag(TIF_MEMDIE))
 		schedule_timeout_uninterruptible(1);
 }
Index: mmotm-2.6.28-Nov20/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Nov20.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Nov20/mm/memcontrol.c
@@ -153,7 +153,7 @@ struct mem_cgroup {
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
 	bool use_hierarchy;
-
+	unsigned long	last_oom_jiffies;
 	int		obsolete;
 	atomic_t	refcnt;
 	/*
@@ -618,6 +618,22 @@ static int mem_cgroup_hierarchical_recla
 	return ret;
 }
 
+bool mem_cgroup_oom_called(struct task_struct *task)
+{
+	bool ret = false;
+	struct mem_cgroup *mem;
+	struct mm_struct *mm;
+
+	rcu_read_lock();
+	mm = task->mm;
+	if (!mm)
+		mm = &init_mm;
+	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
+		ret = true;
+	rcu_read_unlock();
+	return ret;
+}
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
@@ -629,6 +645,13 @@ static int __mem_cgroup_try_charge(struc
 	struct mem_cgroup *mem, *mem_over_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct res_counter *fail_res;
+
+	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
+		/* Don't account this! */
+		*memcg = NULL;
+		return 0;
+	}
+
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
@@ -699,8 +722,10 @@ static int __mem_cgroup_try_charge(struc
 			continue;
 
 		if (!nr_retries--) {
-			if (oom)
+			if (oom) {
 				mem_cgroup_out_of_memory(mem, gfp_mask);
+				mem->last_oom_jiffies = jiffies;
+			}
 			goto nomem;
 		}
 	}
@@ -837,7 +862,7 @@ static int mem_cgroup_move_parent(struct
 
 
 	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false);
-	if (ret)
+	if (ret || !parent)
 		return ret;
 
 	if (!get_page_unless_zero(page))
@@ -888,7 +913,7 @@ static int mem_cgroup_charge_common(stru
 
 	mem = memcg;
 	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);
-	if (ret)
+	if (ret || !mem)
 		return ret;
 
 	__mem_cgroup_commit_charge(mem, pc, ctype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
