Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D95EE90008E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 18:55:50 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V4 09/10] Add API to export per-memcg kswapd pid.
Date: Thu, 14 Apr 2011 15:54:28 -0700
Message-Id: <1302821669-29862-10-git-send-email-yinghan@google.com>
In-Reply-To: <1302821669-29862-1-git-send-email-yinghan@google.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This add the API which exports per-memcg kswapd thread pid. The kswapd
thread is named as "memcg_" + css_id, and the pid can be used to put
kswapd thread into cpu cgroup later.

$ mkdir /dev/cgroup/memory/A
$ cat /dev/cgroup/memory/A/memory.kswapd_pid
memcg_null 0

$ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
$ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
$ ps -ef | grep memcg
root      6727     2  0 14:32 ?        00:00:00 [memcg_3]
root      6729  6044  0 14:32 ttyS0    00:00:00 grep memcg

$ cat memory.kswapd_pid
memcg_3 6727

changelog v4..v3
1. Add the API based on KAMAZAWA's request on patch v3.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/swap.h |    2 ++
 mm/memcontrol.c      |   33 +++++++++++++++++++++++++++++++++
 mm/vmscan.c          |    2 +-
 3 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 319b800..2d3e21a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -34,6 +34,8 @@ struct kswapd {
 };
 
 int kswapd(void *p);
+extern spinlock_t kswapds_spinlock;
+
 /*
  * MAX_SWAPFILES defines the maximum number of swaptypes: things which can
  * be swapped to.  The swap type and the offset into that swap type are
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1b23ff4..606b680 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4493,6 +4493,35 @@ static int mem_cgroup_wmark_read(struct cgroup *cgrp,
 	return 0;
 }
 
+static int mem_cgroup_kswapd_pid_read(struct cgroup *cgrp,
+	struct cftype *cft,  struct cgroup_map_cb *cb)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	struct task_struct *kswapd_thr = NULL;
+	struct kswapd *kswapd_p = NULL;
+	wait_queue_head_t *wait;
+	char name[TASK_COMM_LEN];
+	pid_t pid = 0;
+
+	sprintf(name, "memcg_null");
+
+	spin_lock(&kswapds_spinlock);
+	wait = mem_cgroup_kswapd_wait(mem);
+	if (wait) {
+		kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
+		kswapd_thr = kswapd_p->kswapd_task;
+		if (kswapd_thr) {
+			get_task_comm(name, kswapd_thr);
+			pid = kswapd_thr->pid;
+		}
+	}
+	spin_unlock(&kswapds_spinlock);
+
+	cb->fill(cb, name, pid);
+
+	return 0;
+}
+
 static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
 	struct cftype *cft,  struct cgroup_map_cb *cb)
 {
@@ -4610,6 +4639,10 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "reclaim_wmarks",
 		.read_map = mem_cgroup_wmark_read,
 	},
+	{
+		.name = "kswapd_pid",
+		.read_map = mem_cgroup_kswapd_pid_read,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c081112..df4e5dd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2249,7 +2249,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
 	return balanced_pages > (present_pages >> 2);
 }
 
-static DEFINE_SPINLOCK(kswapds_spinlock);
+DEFINE_SPINLOCK(kswapds_spinlock);
 #define is_node_kswapd(kswapd_p) (!(kswapd_p)->kswapd_mem)
 
 /* is kswapd sleeping prematurely? */
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
