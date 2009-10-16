Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1BAB76B005A
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 20:40:41 -0400 (EDT)
Date: Fri, 16 Oct 2009 09:32:52 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [BUGFIX][PATCH -mmotm] memcg: don't do INIT_WORK() repeatedly
 against the same work_struct
Message-Id: <20091016093252.30d78e4b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091014160237.1ac8d1b8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091009165826.59c6f6e3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091009170105.170e025f.kamezawa.hiroyu@jp.fujitsu.com>
	<20091009165002.629a91d2.akpm@linux-foundation.org>
	<72e9a96ea399491948f396dab01b4c77.squirrel@webmail-b.css.fujitsu.com>
	<20091013165719.c5781bfa.nishimura@mxp.nes.nec.co.jp>
	<20091013170545.3af1cf7b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091014154211.08f33001.nishimura@mxp.nes.nec.co.jp>
	<20091014160237.1ac8d1b8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, h-shimamoto@ct.jp.nec.com, linux-kernel@vger.kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This is a fix for memcg-coalesce-charging-via-percpu-storage.patch,
and can be applied after memcg-coalesce-charging-via-percpu-storage-fix.patch.

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Don't do INIT_WORK() repeatedly against the same work_struct.
It can actually lead to a BUG.

Just do it once in initialization.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f850941..bf02bea 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1349,8 +1349,8 @@ static void drain_all_stock_async(void)
 	/* This function is for scheduling "drain" in asynchronous way.
 	 * The result of "drain" is not directly handled by callers. Then,
 	 * if someone is calling drain, we don't have to call drain more.
-	 * Anyway, work_pending() will catch if there is a race. We just do
-	 * loose check here.
+	 * Anyway, WORK_STRUCT_PENDING check in queue_work_on() will catch if
+	 * there is a race. We just do loose check here.
 	 */
 	if (atomic_read(&memcg_drain_count))
 		return;
@@ -1359,9 +1359,6 @@ static void drain_all_stock_async(void)
 	get_online_cpus();
 	for_each_online_cpu(cpu) {
 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
-		if (work_pending(&stock->work))
-			continue;
-		INIT_WORK(&stock->work, drain_local_stock);
 		schedule_work_on(cpu, &stock->work);
 	}
  	put_online_cpus();
@@ -3327,11 +3324,17 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 
 	/* root ? */
 	if (cont->parent == NULL) {
+		int cpu;
 		enable_swap_cgroup();
 		parent = NULL;
 		root_mem_cgroup = mem;
 		if (mem_cgroup_soft_limit_tree_init())
 			goto free_out;
+		for_each_possible_cpu(cpu) {
+			struct memcg_stock_pcp *stock =
+						&per_cpu(memcg_stock, cpu);
+			INIT_WORK(&stock->work, drain_local_stock);
+		}
 		hotcpu_notifier(memcg_stock_cpu_callback, 0);
 
 	} else {
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
