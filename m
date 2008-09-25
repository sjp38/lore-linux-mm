From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 10/12] memcg free page_cgroup from LRU in lazy
Date: Thu, 25 Sep 2008 15:33:44 +0900
Message-ID: <20080925153344.080624c0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754615AbYIYG1r@vger.kernel.org>
In-Reply-To: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-Id: linux-mm.kvack.org

Free page_cgroup from its LRU in batched manner.

When uncharge() is called, page is pushed onto per-cpu vector and
removed from LRU, later.. This routine resembles to global LRU's pagevec.
This patch is half of the whole patch and a set with following lazy LRU add
patch.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |  164 +++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 152 insertions(+), 12 deletions(-)

Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -36,6 +36,7 @@
 #include <linux/mm_inline.h>
 #include <linux/writeback.h>
 #include <linux/page_cgroup.h>
+#include <linux/cpu.h>
 
 #include <asm/uaccess.h>
 
@@ -533,6 +534,116 @@ out:
 	return ret;
 }
 
+
+#define MEMCG_PCPVEC_SIZE	(14)	/* size of pagevec */
+struct memcg_percpu_vec {
+	int nr;
+	int limit;
+	struct page_cgroup *vec[MEMCG_PCPVEC_SIZE];
+};
+static DEFINE_PER_CPU(struct memcg_percpu_vec, memcg_free_vec);
+
+static void
+__release_page_cgroup(struct memcg_percpu_vec *mpv)
+{
+	unsigned long flags;
+	struct mem_cgroup_per_zone *mz, *prev_mz;
+	struct page_cgroup *pc;
+	int i, nr;
+
+	local_irq_save(flags);
+	nr = mpv->nr;
+	mpv->nr = 0;
+	prev_mz = NULL;
+	for (i = nr - 1; i >= 0; i--) {
+		pc = mpv->vec[i];
+		VM_BUG_ON(PageCgroupUsed(pc));
+		mz = page_cgroup_zoneinfo(pc);
+		if (prev_mz != mz) {
+			if (prev_mz)
+				spin_unlock(&prev_mz->lru_lock);
+			prev_mz = mz;
+			spin_lock(&mz->lru_lock);
+		}
+		__mem_cgroup_remove_list(mz, pc);
+		css_put(&pc->mem_cgroup->css);
+		pc->mem_cgroup = NULL;
+	}
+	if (prev_mz)
+		spin_unlock(&prev_mz->lru_lock);
+	local_irq_restore(flags);
+
+}
+
+static void
+release_page_cgroup(struct page_cgroup *pc)
+{
+	struct memcg_percpu_vec *mpv;
+
+	mpv = &get_cpu_var(memcg_free_vec);
+	mpv->vec[mpv->nr++] = pc;
+	if (mpv->nr >= mpv->limit)
+		__release_page_cgroup(mpv);
+	put_cpu_var(memcg_free_vec);
+}
+
+static void page_cgroup_start_cache_cpu(int cpu)
+{
+	struct memcg_percpu_vec *mpv;
+	mpv = &per_cpu(memcg_free_vec, cpu);
+	mpv->limit = MEMCG_PCPVEC_SIZE;
+}
+
+#ifdef CONFIG_HOTPLUG_CPU
+static void page_cgroup_stop_cache_cpu(int cpu)
+{
+	struct memcg_percpu_vec *mpv;
+	mpv = &per_cpu(memcg_free_vec, cpu);
+	mpv->limit = 0;
+}
+#endif
+
+
+/*
+ * Used when freeing memory resource controller to remove all
+ * page_cgroup (in obsolete list).
+ */
+static DEFINE_MUTEX(memcg_force_drain_mutex);
+
+static void drain_page_cgroup_local(struct work_struct *work)
+{
+	struct memcg_percpu_vec *mpv;
+	mpv = &get_cpu_var(memcg_free_vec);
+	__release_page_cgroup(mpv);
+	put_cpu_var(mpv);
+}
+
+static void drain_page_cgroup_cpu(int cpu)
+{
+	int local_cpu;
+	struct work_struct work;
+
+	local_cpu = get_cpu();
+	if (local_cpu == cpu) {
+		drain_page_cgroup_local(NULL);
+		put_cpu();
+		return;
+	}
+	put_cpu();
+
+	INIT_WORK(&work, drain_page_cgroup_local);
+	schedule_work_on(cpu, &work);
+	flush_work(&work);
+}
+
+static void drain_page_cgroup_all(void)
+{
+	mutex_lock(&memcg_force_drain_mutex);
+	schedule_on_each_cpu(drain_page_cgroup_local);
+	mutex_unlock(&memcg_force_drain_mutex);
+}
+
+
 /*
  * Charge the memory controller for page usage.
  * Return
@@ -703,8 +814,6 @@ __mem_cgroup_uncharge_common(struct page
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem;
-	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
 
 	if (mem_cgroup_subsys.disabled)
 		return;
@@ -722,16 +831,10 @@ __mem_cgroup_uncharge_common(struct page
 	}
 	ClearPageCgroupUsed(pc);
 	unlock_page_cgroup(pc);
+	preempt_enable();
 
 	mem = pc->mem_cgroup;
-	mz = page_cgroup_zoneinfo(pc);
-
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_remove_list(mz, pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	pc->mem_cgroup = NULL;
-	css_put(&mem->css);
-	preempt_enable();
+	release_page_cgroup(pc);
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
 
 	return;
@@ -888,9 +991,8 @@ static void mem_cgroup_force_empty_list(
 		if (!PageCgroupUsed(pc))
 			continue;
 		/* For avoiding race with speculative page cache handling. */
-		if (!PageLRU(page) || !get_page_unless_zero(page)) {
+		if (!PageLRU(page) || !get_page_unless_zero(page))
 			continue;
-		}
 		mem_cgroup_move_account(page, pc, mem, &init_mem_cgroup);
 		put_page(page);
 		if (atomic_read(&mem->css.cgroup->count) > 0)
@@ -927,8 +1029,10 @@ static int mem_cgroup_force_empty(struct
 		 * While walking our own LRU, we also checks LRU bit on page.
 		 * If a page is on pagevec, it's not on LRU and we cannot
 		 * grab it. Calling lru_add_drain_all() here.
+		 * memory cgroup's its own vector shold be flushed, too.
 		 */
 		lru_add_drain_all();
+		drain_page_cgroup_all();
 		for_each_node_state(node, N_HIGH_MEMORY) {
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 				mz = mem_cgroup_zoneinfo(mem, node, zid);
@@ -1152,6 +1256,38 @@ static void mem_cgroup_free(struct mem_c
 		vfree(mem);
 }
 
+static void mem_cgroup_init_pcp(int cpu)
+{
+	page_cgroup_start_cache_cpu(cpu);
+}
+
+static int cpu_memcgroup_callback(struct notifier_block *nb,
+			unsigned long action, void *hcpu)
+{
+	int cpu = (long)hcpu;
+
+	switch(action) {
+	case CPU_UP_PREPARE:
+	case CPU_UP_PREPARE_FROZEN:
+		mem_cgroup_init_pcp(cpu);
+		break;
+#ifdef CONFIG_HOTPLUG_CPU
+	case CPU_DOWN_PREPARE:
+	case CPU_DOWN_PREPARE_FROZEN:
+		page_cgroup_stop_cache_cpu(cpu);
+		drain_page_cgroup_cpu(cpu);
+		break;
+#endif
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block __refdata memcgroup_nb =
+{
+	.notifier_call = cpu_memcgroup_callback,
+};
 
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
@@ -1162,6 +1298,10 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (unlikely((cont->parent) == NULL)) {
 		page_cgroup_init();
 		mem = &init_mem_cgroup;
+		cpu_memcgroup_callback(&memcgroup_nb,
+					(unsigned long)CPU_UP_PREPARE,
+					(void *)(long)smp_processor_id());
+		register_hotcpu_notifier(&memcgroup_nb);
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
