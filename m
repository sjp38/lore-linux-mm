Date: Tue, 16 Sep 2008 21:19:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 11/9] lazy lru free vector for memcg
Message-Id: <20080916211934.25c36d20.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080916211355.277b625d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080911202249.df6026ae.kamezawa.hiroyu@jp.fujitsu.com>
	<48CA9500.5060309@linux.vnet.ibm.com>
	<20080916211355.277b625d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com, Dave Hansen <haveblue@us.ibm.com>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

Free page_cgroup from its LRU in batched manner.

When uncharge() is called, page is pushed ontto per-cpu vector and
removed from LRU. This is depends on increment-page-count-via-page-cgroup
patch. Because page_cgroup has refcnt to the page, we don't have to be
afraid that the page is reused while it's on vector.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |  163 +++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 155 insertions(+), 8 deletions(-)

Index: mmtom-2.6.27-rc5+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc5+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc5+/mm/memcontrol.c
@@ -35,6 +35,7 @@
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
+#include <linux/cpu.h>
 
 #include <asm/uaccess.h>
 
@@ -539,6 +540,120 @@ out:
 	return ret;
 }
 
+
+#define MEMCG_PCPVEC_SIZE	(8)
+struct memcg_percpu_vec {
+	int nr;
+	int limit;
+	struct mem_cgroup 	   *hot_memcg;
+	struct mem_cgroup_per_zone *hot_mz;
+	struct page_cgroup *vec[MEMCG_PCPVEC_SIZE];
+};
+DEFINE_PER_CPU(struct memcg_percpu_vec, memcg_free_vec);
+
+static void
+__release_page_cgroup(struct memcg_percpu_vec *mpv)
+{
+	unsigned long flags;
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup *owner;
+	struct page_cgroup *pc;
+	struct page *freed[MEMCG_PCPVEC_SIZE];
+	int i, nr;
+
+	mz = mpv->hot_mz;
+	owner = mpv->hot_memcg;
+	spin_lock_irqsave(&mz->lru_lock, flags);
+	nr = mpv->nr;
+	for (i = nr - 1; i >= 0; i--) {
+		pc = mpv->vec[i];
+		VM_BUG_ON(PageCgroupUsed(pc));
+		__mem_cgroup_remove_list(mz, pc);
+		css_put(&owner->css);
+		freed[i] = pc->page;
+		pc->mem_cgroup = NULL;
+	}
+	mpv->nr = 0;
+	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	for (i = nr - 1; i >= 0; i--)
+		put_page(freed[i]);
+}
+
+static void
+release_page_cgroup(struct mem_cgroup_per_zone *mz,struct page_cgroup *pc)
+{
+	struct memcg_percpu_vec *mpv;
+
+	mpv = &get_cpu_var(memcg_free_vec);
+	if (mpv->hot_mz != mz) {
+		if (mpv->nr > 0)
+			__release_page_cgroup(mpv);
+		mpv->hot_mz = mz;
+		mpv->hot_memcg = pc->mem_cgroup;
+	}
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
@@ -715,7 +830,6 @@ __mem_cgroup_uncharge_common(struct page
 	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
 	unsigned long pfn = page_to_pfn(page);
-	unsigned long flags;
 
 	if (!under_mem_cgroup(page))
 		return;
@@ -727,17 +841,12 @@ __mem_cgroup_uncharge_common(struct page
 	lock_page_cgroup(pc);
 	__ClearPageCgroupUsed(pc);
 	unlock_page_cgroup(pc);
+	preempt_enable();
 
 	mem = pc->mem_cgroup;
 	mz = page_cgroup_zoneinfo(pc);
 
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_remove_list(mz, pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	put_page(pc->page);
-	pc->mem_cgroup = NULL;
-	css_put(&mem->css);
-	preempt_enable();
+	release_page_cgroup(mz, pc);
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
 
 	return;
@@ -938,6 +1047,7 @@ static int mem_cgroup_force_empty(struct
 	 * So, we have to do loop here until all lists are empty.
 	 */
 	while (mem->res.usage > 0) {
+		drain_page_cgroup_all();
 		if (atomic_read(&mem->css.cgroup->count) > 0)
 			goto out;
 		for_each_node_state(node, N_POSSIBLE)
@@ -950,6 +1060,7 @@ static int mem_cgroup_force_empty(struct
 			}
 	}
 	ret = 0;
+	drain_page_cgroup_all();
 out:
 	css_put(&mem->css);
 	return ret;
@@ -1154,6 +1265,38 @@ static void mem_cgroup_free(struct mem_c
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
@@ -1164,6 +1307,10 @@ mem_cgroup_create(struct cgroup_subsys *
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
