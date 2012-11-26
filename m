Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id D334B6B005A
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 05:49:50 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PATCH 5/5] Do not use cpu_to_node() to find an offlined cpu's node.
Date: Mon, 26 Nov 2012 18:20:27 +0800
Message-Id: <1353925227-1877-6-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1353925227-1877-1-git-send-email-wency@cn.fujitsu.com>
References: <1353925227-1877-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-acpi@vger.kernel.org, x86@kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <len.brown@intel.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

If a cpu is offline, its nid will be set to -1, and cpu_to_node(cpu) will
return -1. As a result, cpumask_of_node(nid) will return NULL. In this case,
find_next_bit() in for_each_cpu will get a NULL pointer and cause panic.

Here is a call trace:
[  609.824017] Call Trace:
[  609.824017]  <IRQ>
[  609.824017]  [<ffffffff810b0721>] select_fallback_rq+0x71/0x190
[  609.824017]  [<ffffffff810b086e>] ? try_to_wake_up+0x2e/0x2f0
[  609.824017]  [<ffffffff810b0b0b>] try_to_wake_up+0x2cb/0x2f0
[  609.824017]  [<ffffffff8109da08>] ? __run_hrtimer+0x78/0x320
[  609.824017]  [<ffffffff810b0b85>] wake_up_process+0x15/0x20
[  609.824017]  [<ffffffff8109ce62>] hrtimer_wakeup+0x22/0x30
[  609.824017]  [<ffffffff8109da13>] __run_hrtimer+0x83/0x320
[  609.824017]  [<ffffffff8109ce40>] ? update_rmtp+0x80/0x80
[  609.824017]  [<ffffffff8109df56>] hrtimer_interrupt+0x106/0x280
[  609.824017]  [<ffffffff810a72c8>] ? sd_free_ctl_entry+0x68/0x70
[  609.824017]  [<ffffffff8167cf39>] smp_apic_timer_interrupt+0x69/0x99
[  609.824017]  [<ffffffff8167be2f>] apic_timer_interrupt+0x6f/0x80

There is a hrtimer process sleeping, whose cpu has already been offlined.
When it is waken up, it tries to find another cpu to run, and get a -1 nid.
As a result, cpumask_of_node(-1) returns NULL, and causes ernel panic.

This patch fixes this problem by judging if the nid is -1.
If nid is not -1, a cpu on the same node will be picked.
Else, a online cpu on another node will be picked.

Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Jiang Liu <liuj97@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 kernel/sched/core.c | 28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 2d8927f..4e6404e 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1106,18 +1106,28 @@ EXPORT_SYMBOL_GPL(kick_process);
  */
 static int select_fallback_rq(int cpu, struct task_struct *p)
 {
-	const struct cpumask *nodemask = cpumask_of_node(cpu_to_node(cpu));
+	int nid = cpu_to_node(cpu);
+	const struct cpumask *nodemask = NULL;
 	enum { cpuset, possible, fail } state = cpuset;
 	int dest_cpu;
 
-	/* Look for allowed, online CPU in same node. */
-	for_each_cpu(dest_cpu, nodemask) {
-		if (!cpu_online(dest_cpu))
-			continue;
-		if (!cpu_active(dest_cpu))
-			continue;
-		if (cpumask_test_cpu(dest_cpu, tsk_cpus_allowed(p)))
-			return dest_cpu;
+	/*
+	 * If the node that the cpu is on has been offlined, cpu_to_node()
+	 * will return -1. There is no cpu on the node, and we should
+	 * select the cpu on the other node.
+	 */
+	if (nid != -1) {
+		nodemask = cpumask_of_node(nid);
+
+		/* Look for allowed, online CPU in same node. */
+		for_each_cpu(dest_cpu, nodemask) {
+			if (!cpu_online(dest_cpu))
+				continue;
+			if (!cpu_active(dest_cpu))
+				continue;
+			if (cpumask_test_cpu(dest_cpu, tsk_cpus_allowed(p)))
+				return dest_cpu;
+		}
 	}
 
 	for (;;) {
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
