Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A7FB66B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 20:02:26 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3AAA43EE0BB
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:02:22 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1951745DE93
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:02:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 00DC545DE96
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:02:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DE2ABE78007
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:02:21 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 95F471DB803E
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:02:21 +0900 (JST)
Date: Tue, 24 May 2011 08:55:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/8] memcg: clean up, export swapiness
Message-Id: <20110524085530.6f3ff8cc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=7-xgUetav9s5fvZ8e+U986Y4Z7w@mail.gmail.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124312.5928aa92.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=7-xgUetav9s5fvZ8e+U986Y4Z7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Mon, 23 May 2011 10:26:22 -0700
Ying Han <yinghan@google.com> wrote:

> Hi Kame:
> 
> Is this patch part of the "memcg async reclaim v2" patchset?

yes, I failed to change title...

 I am
> trying to do some tests on top of that, but having hard time finding
> the [PATCH 3/8] and [PATCH 5/8].
> 
PATCH 5 is attached.

I think I can send a simplified v3 until this Friday and will not do update until
the end of LinuxCon Japan (I'm now writing slides ;). Of course, it's merge
window and I don't want to push any new feature to Andrew.

Sorry for my inconvenience.

Thanks,
-Kame

==
This patch adds a logic to keep usage margin to the limit in asynchronous way.
When the usage over some threshould (determined automatically), asynchronous
memory reclaim runs and shrink memory to limit - MEMCG_ASYNC_STOP_MARGIN.

By this, there will be no difference in total amount of usage of cpu to
scan the LRU but we'll have a chance to make use of wait time of applications
for freeing memory. For example, when an application read a file or socket,
to fill the newly alloated memory, it needs wait. Async reclaim can make use
of that time and give a chance to reduce latency by background works.

This patch only includes required hooks to trigger async reclaim. Core logics
will be in the following patches.

Changelog v1 -> v2:
  - avoid async reclaim check when num_online_cpus() < 2.
  - changed MEMCG_ASYNC_START_MARGIN to be 6 * HPAGE_SIZE.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   46 ++++++++++++++++++-
 mm/memcontrol.c                  |   94 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 139 insertions(+), 1 deletion(-)

Index: mmotm-May11/mm/memcontrol.c
===================================================================
--- mmotm-May11.orig/mm/memcontrol.c
+++ mmotm-May11/mm/memcontrol.c
@@ -115,10 +115,12 @@ enum mem_cgroup_events_index {
 enum mem_cgroup_events_target {
 	MEM_CGROUP_TARGET_THRESH,
 	MEM_CGROUP_TARGET_SOFTLIMIT,
+	MEM_CGROUP_TARGET_ASYNC,
 	MEM_CGROUP_NTARGETS,
 };
 #define THRESHOLDS_EVENTS_TARGET (128)
 #define SOFTLIMIT_EVENTS_TARGET (1024)
+#define ASYNC_EVENTS_TARGET	(512)	/* assume x86-64's hpagesize */
 
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
@@ -211,6 +213,29 @@ static void mem_cgroup_threshold(struct 
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
 /*
+ * For example, with transparent hugepages, memory reclaim scan at hitting
+ * limit can very long as to reclaim HPAGE_SIZE of memory. This increases
+ * latency of page fault and may cause fallback. At usual page allocation,
+ * we'll see some (shorter) latency, too. To reduce latency, it's appreciated
+ * to free memory in background to make margin to the limit. This consumes
+ * cpu but we'll have a chance to make use of wait time of applications
+ * (read disk etc..) by asynchronous reclaim.
+ *
+ * This async reclaim tries to reclaim HPAGE_SIZE * 2 of pages when margin
+ * to the limit is smaller than HPAGE_SIZE * 2. This will be enabled
+ * automatically when the limit is set and it's greater than the threshold.
+ */
+#if HPAGE_SIZE != PAGE_SIZE
+#define MEMCG_ASYNC_LIMIT_THRESH      (HPAGE_SIZE * 64)
+#define MEMCG_ASYNC_MARGIN	      (HPAGE_SIZE * 4)
+#else /* make the margin as 4M bytes */
+#define MEMCG_ASYNC_LIMIT_THRESH      (128 * 1024 * 1024)
+#define MEMCG_ASYNC_MARGIN            (8 * 1024 * 1024)
+#endif
+
+static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);
+
+/*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
  * statistics based on the statistics developed by Rik Van Riel for clock-pro,
@@ -278,6 +303,12 @@ struct mem_cgroup {
 	 */
 	unsigned long 	move_charge_at_immigrate;
 	/*
+ 	 * Checks for async reclaim.
+ 	 */
+	unsigned long	async_flags;
+#define AUTO_ASYNC_ENABLED	(0)
+#define USE_AUTO_ASYNC		(1)
+	/*
 	 * percpu counter.
 	 */
 	struct mem_cgroup_stat_cpu *stat;
@@ -722,6 +753,9 @@ static void __mem_cgroup_target_update(s
 	case MEM_CGROUP_TARGET_SOFTLIMIT:
 		next = val + SOFTLIMIT_EVENTS_TARGET;
 		break;
+	case MEM_CGROUP_TARGET_ASYNC:
+		next = val + ASYNC_EVENTS_TARGET;
+		break;
 	default:
 		return;
 	}
@@ -745,6 +779,11 @@ static void memcg_check_events(struct me
 			__mem_cgroup_target_update(mem,
 				MEM_CGROUP_TARGET_SOFTLIMIT);
 		}
+		if (__memcg_event_check(mem, MEM_CGROUP_TARGET_ASYNC)) {
+			mem_cgroup_may_async_reclaim(mem);
+			__mem_cgroup_target_update(mem,
+				MEM_CGROUP_TARGET_ASYNC);
+		}
 	}
 }
 
@@ -3365,6 +3404,23 @@ void mem_cgroup_print_bad_page(struct pa
 
 static DEFINE_MUTEX(set_limit_mutex);
 
+/* When limit is changed, check async reclaim switch again */
+static void mem_cgroup_set_auto_async(struct mem_cgroup *mem, u64 val)
+{
+	if (!test_bit(AUTO_ASYNC_ENABLED, &mem->async_flags))
+		goto clear;
+	if (num_online_cpus() < 2)
+		goto clear;
+	if (val < MEMCG_ASYNC_LIMIT_THRESH)
+		goto clear;
+
+	set_bit(USE_AUTO_ASYNC, &mem->async_flags);
+	return;
+clear:
+	clear_bit(USE_AUTO_ASYNC, &mem->async_flags);
+	return;
+}
+
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 				unsigned long long val)
 {
@@ -3413,6 +3469,7 @@ static int mem_cgroup_resize_limit(struc
 				memcg->memsw_is_minimum = true;
 			else
 				memcg->memsw_is_minimum = false;
+			mem_cgroup_set_auto_async(memcg, val);
 		}
 		mutex_unlock(&set_limit_mutex);
 
@@ -3590,6 +3647,15 @@ unsigned long mem_cgroup_soft_limit_recl
 	return nr_reclaimed;
 }
 
+static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem)
+{
+	if (!test_bit(USE_AUTO_ASYNC, &mem->async_flags))
+		return;
+	if (res_counter_margin(&mem->res) <= MEMCG_ASYNC_MARGIN) {
+		/* Fill here */
+	}
+}
+
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
@@ -4149,6 +4215,29 @@ static int mem_control_stat_show(struct 
 	return 0;
 }
 
+static u64 mem_cgroup_async_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+
+	return mem->async_flags;
+}
+
+static int
+mem_cgroup_async_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+
+	if (val & (1 << AUTO_ASYNC_ENABLED))
+		set_bit(AUTO_ASYNC_ENABLED, &mem->async_flags);
+	else
+		clear_bit(AUTO_ASYNC_ENABLED, &mem->async_flags);
+
+	val = res_counter_read_u64(&mem->res, RES_LIMIT);
+	mem_cgroup_set_auto_async(mem, val);
+	return 0;
+}
+
+
 static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
@@ -4580,6 +4669,11 @@ static struct cftype mem_cgroup_files[] 
 		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
+	{
+		.name = "async_control",
+		.read_u64 = mem_cgroup_async_read,
+		.write_u64 = mem_cgroup_async_write,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
Index: mmotm-May11/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-May11.orig/Documentation/cgroups/memory.txt
+++ mmotm-May11/Documentation/cgroups/memory.txt
@@ -70,6 +70,7 @@ Brief summary of control files.
 				 (See sysctl's vm.swappiness)
  memory.move_charge_at_immigrate # set/show controls of moving charges
  memory.oom_control		 # set/show oom controls.
+ memory.async_control		 # set control for asynchronous memory reclaim
 
 1. History
 
@@ -664,7 +665,50 @@ At reading, current status of OOM is sho
 	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
 				 be stopped.)
 
-11. TODO
+11. Asynchronous memory reclaim
+
+In some kind of applications which uses many file caches, once memory cgroup
+hit limit, following allocation of pages will hit limit again and the
+application may see huge latency because of memory reclaim.
+
+Memory cgroup provides a method for asynchronous memory reclaim for freeing
+memory before hitting limit. By this, some class of application can avoid
+memory reclaim latency effectively and show good performance. For example,
+if an application reads data from files bigger than limit, freeing memory
+in asynchrnous will reduce latency of read. But please note, even if
+latency decreased, the amount of total usage of CPU is unchanged. So,
+asynchronous memory reclaim works effectively only when you have extra unused
+CPU, applications tend to sleep. So, this feature only works on SMP.
+
+So, if you see this feature doesn't help your application, please let it
+turned off.
+
+
+11.1 memory.async_control
+
+memory.async_control is a control for asynchronous memory reclaim and
+represented as bitmask of controls.
+
+ bit 0 ....user control of automatic asynchronous memory reclaim(see below)
+ bit 1 ....indicate automatic asynchronous memory reclaim is really used.
+
+ * Automatic asynchronous memory reclaim is a feature to free pages to
+   some extent below the limit in background. When this runs, applications
+   can reduce latency at hit limit. (but please note, background reclaim
+   use cpu.)
+
+   This feature can be enabled by
+
+   echo 1 > memory.async_control
+
+   If successfully enabled, bit 1 of memory.async_control is set. Bit 1 may
+   not be set when the number of cpu is 1 or when the limit is too small.
+
+   Note: This feature is not propageted to childrens in automatic. This
+   may be conservative but required limitation to avoid using too much
+   cpus.
+
+12. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
