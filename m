Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 94A31900137
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 02:41:24 -0400 (EDT)
Subject: [patch]mm: fix a memcg warning
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 01 Aug 2011 14:41:18 +0800
Message-ID: <1312180878.15392.427.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I get below warning:
BUG: using smp_processor_id() in preemptible [00000000] code: bash/739
caller is drain_local_stock+0x1a/0x55
Pid: 739, comm: bash Tainted: G        W   3.0.0+ #255
Call Trace:
 [<ffffffff813435c6>] debug_smp_processor_id+0xc2/0xdc
 [<ffffffff8114ae9b>] drain_local_stock+0x1a/0x55
 [<ffffffff8114b076>] drain_all_stock+0x98/0x13a
 [<ffffffff8114f04c>] mem_cgroup_force_empty+0xa3/0x27a
 [<ffffffff8114ff1d>] ? sys_close+0x38/0x138
 [<ffffffff811a7631>] ? environ_read+0x1d/0x159
 [<ffffffff8114f253>] mem_cgroup_force_empty_write+0x17/0x19
 [<ffffffff810c72fb>] cgroup_file_write+0xa8/0xba
 [<ffffffff811522ce>] vfs_write+0xb3/0x138
 [<ffffffff81152416>] sys_write+0x4a/0x71
 [<ffffffff8114ffd5>] ? sys_close+0xf0/0x138
 [<ffffffff8176deab>] system_call_fastpath+0x16/0x1b

drain_local_stock() should be run with preempt disabled.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5f84d23..11d5671 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2169,13 +2169,7 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
 
 	/* Notify other cpus that system-wide "drain" is running */
 	get_online_cpus();
-	/*
-	 * Get a hint for avoiding draining charges on the current cpu,
-	 * which must be exhausted by our charging.  It is not required that
-	 * this be a precise check, so we use raw_smp_processor_id() instead of
-	 * getcpu()/putcpu().
-	 */
-	curcpu = raw_smp_processor_id();
+	curcpu = get_cpu();
 	for_each_online_cpu(cpu) {
 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
 		struct mem_cgroup *mem;
@@ -2192,6 +2186,7 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
 				schedule_work_on(cpu, &stock->work);
 		}
 	}
+	put_cpu();
 
 	if (!sync)
 		goto out;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
