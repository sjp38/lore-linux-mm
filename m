Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 497D08D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:26:21 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V7 4/9] Add memcg kswapd thread pool
Date: Thu, 21 Apr 2011 21:24:15 -0700
Message-Id: <1303446260-21333-5-git-send-email-yinghan@google.com>
In-Reply-To: <1303446260-21333-1-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This patch creates a thread pool for memcg-kswapd. All memcg which needs
background recalim are linked to a list and memcg-kswapd picks up a memcg
from the list and run reclaim.

The concern of using per-memcg-kswapd thread is the system overhead including
memory and cputime.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |   69 +++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c            |   82 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 151 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3ece36d..9157c4d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -84,6 +84,11 @@ extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags);
 
+bool mem_cgroup_kswapd_can_sleep(void);
+struct mem_cgroup *mem_cgroup_get_shrink_target(void);
+void mem_cgroup_put_shrink_target(struct mem_cgroup *mem);
+wait_queue_head_t *mem_cgroup_kswapd_waitq(void);
+
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
 {
@@ -355,6 +360,70 @@ static inline void mem_cgroup_split_huge_fixup(struct page *head,
 {
 }
 
+/* background reclaim stats */
+static inline void mem_cgroup_kswapd_steal(struct mem_cgroup *memcg,
+					   int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pg_steal(struct mem_cgroup *memcg,
+				       int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_kswapd_pgscan(struct mem_cgroup *memcg,
+					    int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pg_pgscan(struct mem_cgroup *memcg,
+					int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pgrefill(struct mem_cgroup *memcg,
+				       int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pg_outrun(struct mem_cgroup *memcg,
+					int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_alloc_stall(struct mem_cgroup *memcg,
+					  int val)
+{
+	return 0;
+}
+
+static inline bool mem_cgroup_kswapd_can_sleep(void)
+{
+	return false;
+}
+
+static inline
+struct mem_cgroup *mem_cgroup_get_shrink_target(void)
+{
+	return NULL;
+}
+
+static inline void mem_cgroup_put_shrink_target(struct mem_cgroup *mem)
+{
+}
+
+static inline
+wait_queue_head_t *mem_cgroup_kswapd_waitq(void)
+{
+	return NULL;
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6029f1b..527ad9a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -49,6 +49,8 @@
 #include <linux/cpu.h>
 #include <linux/oom.h>
 #include "internal.h"
+#include <linux/kthread.h>
+#include <linux/freezer.h>
 
 #include <asm/uaccess.h>
 
@@ -262,6 +264,14 @@ struct mem_cgroup {
 	 * mem_cgroup ? And what type of charges should we move ?
 	 */
 	unsigned long 	move_charge_at_immigrate;
+
+	/* !=0 if a kswapd runs */
+	atomic_t kswapd_running;
+	/* for waiting the end*/
+	wait_queue_head_t memcg_kswapd_end;
+	/* for shceduling */
+	struct list_head memcg_kswapd_wait_list;
+
 	/*
 	 * percpu counter.
 	 */
@@ -4392,6 +4402,76 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 	return 0;
 }
 
+/*
+ * Controls for background memory reclam stuff.
+ */
+struct memcg_kswapd_work {
+	spinlock_t lock;
+	struct list_head list;
+	wait_queue_head_t waitq;
+};
+
+struct memcg_kswapd_work memcg_kswapd_control;
+
+static void memcg_kswapd_wait_end(struct mem_cgroup *mem)
+{
+	DEFINE_WAIT(wait);
+
+	prepare_to_wait(&mem->memcg_kswapd_end, &wait, TASK_INTERRUPTIBLE);
+	if (atomic_read(&mem->kswapd_running))
+		schedule();
+	finish_wait(&mem->memcg_kswapd_end, &wait);
+}
+
+struct mem_cgroup *mem_cgroup_get_shrink_target(void)
+{
+	struct mem_cgroup *mem;
+
+	spin_lock(&memcg_kswapd_control.lock);
+	rcu_read_lock();
+	do {
+		mem = NULL;
+		if (!list_empty(&memcg_kswapd_control.list)) {
+			mem = list_entry(memcg_kswapd_control.list.next,
+					struct mem_cgroup,
+					memcg_kswapd_wait_list);
+			list_del_init(&mem->memcg_kswapd_wait_list);
+		}
+	} while (mem && !css_tryget(&mem->css));
+	if (mem)
+		atomic_inc(&mem->kswapd_running);
+	rcu_read_unlock();
+	spin_unlock(&memcg_kswapd_control.lock);
+	return mem;
+}
+
+void mem_cgroup_put_shrink_target(struct mem_cgroup *mem)
+{
+	if (!mem)
+		return;
+	atomic_dec(&mem->kswapd_running);
+	if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH)) {
+		spin_lock(&memcg_kswapd_control.lock);
+		if (list_empty(&mem->memcg_kswapd_wait_list)) {
+			list_add_tail(&mem->memcg_kswapd_wait_list,
+					&memcg_kswapd_control.list);
+		}
+		spin_unlock(&memcg_kswapd_control.lock);
+	}
+	wake_up_all(&mem->memcg_kswapd_end);
+	cgroup_release_and_wakeup_rmdir(&mem->css);
+}
+
+bool mem_cgroup_kswapd_can_sleep(void)
+{
+	return list_empty(&memcg_kswapd_control.list);
+}
+
+wait_queue_head_t *mem_cgroup_kswapd_waitq(void)
+{
+	return &memcg_kswapd_control.waitq;
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4755,6 +4835,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
+	init_waitqueue_head(&mem->memcg_kswapd_end);
+	INIT_LIST_HEAD(&mem->memcg_kswapd_wait_list);
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
