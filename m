Date: Wed, 2 Jul 2008 21:17:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][-mm] [7/7] background job for memcg
Message-Id: <20080702211738.f2ae389b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Background relcaim for memcg.

This patch adds a daemon to do background page reclaim based on high/low
watermark for memcg. Almost all codes are rewritten from previous one.
So start from numbering v1, again.

Major changes from old one:
 i)changes the reclaim to be started based on distance to the limit.
   Not to the amount of pages.
   By this, we don't need strict check against low < high < limit.
   low and high are guaranteed to be below limit.
 ii)"A" daemon is used instead of daemons per memcg.
   maybe simpler than previous ones. (But maybe it's ok to start per-node
   thread. It's  TODO.)
 iii) Because of ii), memcg->flags is added.

Note: I tried to use work_queue but it seems it's not suitable for a work
      with loop. So, I added kthread.
      BTW, if you think of better name, please tell me.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |  201 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 196 insertions(+), 5 deletions(-)

Index: test-2.6.26-rc5-mm3++/mm/memcontrol.c
===================================================================
--- test-2.6.26-rc5-mm3++.orig/mm/memcontrol.c
+++ test-2.6.26-rc5-mm3++/mm/memcontrol.c
@@ -11,7 +11,7 @@
  * the Free Software Foundation; either version 2 of the License, or
  * (at your option) any later version.
  *
- * This program is distributed in the hope that it will be useful,
+ * This program is distributed inx the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
@@ -33,13 +33,31 @@
 #include <linux/seq_file.h>
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
-
+#include <linux/list.h>
+#include <linux/wait.h>
+#include <linux/kthread.h>
+#include <linux/freezer.h>
 #include <asm/uaccess.h>
 
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 static struct kmem_cache *page_cgroup_cache __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
+/* Background reclaim stuff */
+static LIST_HEAD(memcg_global_mswapd_list);
+static DECLARE_WAIT_QUEUE_HEAD(memcg_mswapdq);
+static DEFINE_SPINLOCK(memcg_mswapd_lock);
+struct task_struct *mswapd_daemon  __read_mostly;
+
+enum {
+	MEMCG_HWMARK = 10000,
+	MEMCG_LWMARK = 10001,
+};
+
+
+/* An interface for waiting the end of background reclaim */
+static DECLARE_WAIT_QUEUE_HEAD(memcg_destroy_waitq);
+
 /*
  * Statistics for memory cgroup.
  */
@@ -129,6 +147,11 @@ struct mem_cgroup {
 	struct mem_cgroup_lru_info info;
 
 	int	prev_priority;	/* for recording reclaim priority */
+	unsigned long		flags;
+	/* background reclaim stuff */
+	unsigned long long highwmrk_distance;
+	unsigned long long lowwmrk_distance;
+	struct list_head	mswapd_list;
 	/*
 	 * statistics.
 	 */
@@ -136,6 +159,13 @@ struct mem_cgroup {
 };
 static struct mem_cgroup init_mem_cgroup;
 
+/* Flag bit for memcg itself */
+enum {
+	MEMCG_FLAG_IN_RECLAIM,
+	MEMCG_FLAG_OBSOLETE,
+};
+
+
 /*
  * We use the lower bit of the page->page_cgroup pointer as a bit spin
  * lock.  We need to ensure that page->page_cgroup is at least two
@@ -504,6 +534,37 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
+
+static void mem_cgroup_schedule_reclaim(struct mem_cgroup *memcg)
+{
+	unsigned long flags;
+
+	if (unlikely(!mswapd_daemon))
+		return;
+
+	if (!test_and_set_bit(MEMCG_FLAG_IN_RECLAIM, &memcg->flags)) {
+		/* When OBSOLETE is marked, there is no thread in this group */
+		BUG_ON(test_bit(MEMCG_FLAG_OBSOLETE, &memcg->flags));
+
+		spin_lock_irqsave(&memcg_mswapd_lock, flags);
+		BUG_ON(!list_empty(&memcg->mswapd_list));
+		css_get(&memcg->css);
+		list_add_tail(&memcg->mswapd_list, &memcg_global_mswapd_list);
+		spin_unlock_irqrestore(&memcg_mswapd_lock, flags);
+		if (!waitqueue_active(&memcg_mswapdq))
+			return;
+		wake_up_interruptible(&memcg_mswapdq);
+	}
+}
+
+
+static void mem_cgroup_check_distance_to_limit(struct mem_cgroup *memcg,
+					unsigned long long distance)
+{
+	if (distance < memcg->highwmrk_distance)
+		mem_cgroup_schedule_reclaim(memcg);
+}
+
 /*
  * Charge the memory controller for page usage.
  * Return
@@ -518,6 +579,7 @@ static int mem_cgroup_charge_common(stru
 	struct page_cgroup *pc;
 	unsigned long flags;
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	unsigned long long distance;
 	struct mem_cgroup_per_zone *mz;
 
 	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
@@ -543,7 +605,7 @@ static int mem_cgroup_charge_common(stru
 		css_get(&memcg->css);
 	}
 
-	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
+	while (res_counter_charge_distance(&mem->res, PAGE_SIZE, &distance)) {
 		if (!(gfp_mask & __GFP_WAIT))
 			goto out;
 
@@ -596,6 +658,9 @@ static int mem_cgroup_charge_common(stru
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
 	unlock_page_cgroup(page);
+	/* O.K. we successfully charged. check thresholds...
+	   should check gfp flag ? */
+	mem_cgroup_check_distance_to_limit(mem, distance);
 done:
 	return 0;
 out:
@@ -834,6 +899,68 @@ int mem_cgroup_shrink_usage(struct mm_st
 	return 0;
 }
 
+/*
+ * a daemon to do backgound page shrinking within memcg.
+ */
+static int memcg_mswapd(void *data)
+{
+	DEFINE_WAIT(wait);
+	int ret;
+	struct mem_cgroup *memcg;
+	unsigned long distance;
+
+	current->flags |= PF_SWAPWRITE;
+	set_user_nice(current, 0);
+	set_freezable();
+
+	while (!kthread_should_stop()) {
+		prepare_to_wait(&memcg_mswapdq, &wait, TASK_INTERRUPTIBLE);
+
+		/* Is there scheduled one ? */
+		spin_lock_irq(&memcg_mswapd_lock);
+		if (list_empty(&memcg_global_mswapd_list)) {
+			spin_unlock_irq(&memcg_mswapd_lock);
+			if (!kthread_should_stop()) {
+				schedule();
+				try_to_freeze();
+			}
+			finish_wait(&memcg_mswapdq, &wait);
+			continue;
+		}
+		memcg = container_of(memcg_global_mswapd_list.next,
+					struct mem_cgroup, mswapd_list);
+		list_del_init(&memcg->mswapd_list);
+		spin_unlock_irq(&memcg_mswapd_lock);
+
+		finish_wait(&memcg_mswapdq, &wait);
+
+		if (!test_bit(MEMCG_FLAG_OBSOLETE, &memcg->flags)) {
+			ret = try_to_free_mem_cgroup_pages(memcg,
+						  GFP_HIGHUSER_MOVABLE);
+			distance = res_counter_distance_to_limit(&memcg->res);
+		} else
+			distance = 0;
+
+		if (distance < memcg->lowwmrk_distance) {
+			/* Don't clear IN_RECLAIM flag and add to tail */
+			spin_lock_irq(&memcg_mswapd_lock);
+			list_add_tail(&memcg->mswapd_list,
+				      &memcg_global_mswapd_list);
+			spin_unlock_irq(&memcg_mswapd_lock);
+		} else {
+			css_put(&memcg->css);
+			clear_bit(MEMCG_FLAG_IN_RECLAIM, &memcg->flags);
+			wake_up_all(&memcg_destroy_waitq);
+		}
+		yield();
+	}
+	/* currently, stop this thread is not implemented, but maybe
+	   in future. */
+	BUG();
+	return 0;
+}
+
+
 int mem_cgroup_resize_limit(struct mem_cgroup *memcg, unsigned long long val)
 {
 
@@ -931,8 +1058,17 @@ out:
 
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
-	return res_counter_read_u64(&mem_cgroup_from_cont(cont)->res,
-				    cft->private);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+
+	switch (cft->private) {
+	case MEMCG_HWMARK:
+		return memcg->highwmrk_distance;
+	case MEMCG_LWMARK:
+		return memcg->lowwmrk_distance;
+	default:
+		break;
+	}
+	return res_counter_read_u64(&memcg->res, cft->private);
 }
 /*
  * The user of this function is...
@@ -952,6 +1088,24 @@ static int mem_cgroup_write(struct cgrou
 		if (!ret)
 			ret = mem_cgroup_resize_limit(memcg, val);
 		break;
+	case MEMCG_HWMARK:
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (!ret) {
+			if (val <= memcg->lowwmrk_distance)
+				memcg->highwmrk_distance = val;
+			else
+				ret = -EINVAL;
+		}
+		break;
+	case MEMCG_LWMARK:
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (!ret) {
+			if (val >= memcg->highwmrk_distance)
+				memcg->lowwmrk_distance = val;
+			else
+				ret = -EINVAL;
+		}
+		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
 		break;
@@ -1063,6 +1217,18 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+	{
+		.name = "start_reclaim_distance",
+		.private = MEMCG_HWMARK,
+		.write_string = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
+		.name = "stop_reclaim_distance",
+		.private = MEMCG_LWMARK,
+		.write_string = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read,
+	},
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
@@ -1124,6 +1290,19 @@ static void mem_cgroup_free(struct mem_c
 		vfree(mem);
 }
 
+static int mem_cgroup_start_daemon(void)
+{
+	struct task_struct *result;
+	int ret = 0;
+	result = kthread_run(memcg_mswapd, NULL, "memcontrol");
+	if (IS_ERR(result)) {
+		printk("failed to start memory controller daemon\n");
+		mswapd_daemon = NULL;
+	} else
+		mswapd_daemon = result;
+	return ret;
+}
+late_initcall(mem_cgroup_start_daemon);
 
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
@@ -1146,12 +1325,15 @@ mem_cgroup_create(struct cgroup_subsys *
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
 			goto free_out;
 
+	/* mem->flags is cleared by memset() */
+
 	return &mem->css;
 free_out:
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 	if (cont->parent != NULL)
 		mem_cgroup_free(mem);
+
 	return ERR_PTR(-ENOMEM);
 }
 
@@ -1159,7 +1341,16 @@ static void mem_cgroup_pre_destroy(struc
 					struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+
+	set_bit(MEMCG_FLAG_OBSOLETE, &mem->flags);
+	if (mswapd_daemon)
+		wake_up(mswapd_daemon);
+	/* wait for being removed from background reclaim queue */
+	wait_event_interruptible(memcg_destroy_waitq,
+			!(test_bit(MEMCG_FLAG_IN_RECLAIM, &mem->flags)));
+
 	mem_cgroup_force_empty(mem);
+
 }
 
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
