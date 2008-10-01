Date: Wed, 1 Oct 2008 17:00:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 5/6] memcg: lazy lru freeing
Message-Id: <20081001170005.1997d7c8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Free page_cgroup from its LRU in batched manner.

When uncharge() is called, page is pushed onto per-cpu vector and
removed from LRU, later.. This routine resembles to global LRU's pagevec.
This patch is half of the whole patch and a set with following lazy LRU add
patch.

After this, a pc, which is PageCgroupLRU(pc)==true, is on LRU.
This LRU bit is guarded by lru_lock().

 PageCgroupUsed(pc) && PageCgroupLRU(pc) means "pc" is used and on LRU.
 This check makes sense only when both 2 locks, lock_page_cgroup()/lru_lock(),
 are aquired.

 PageCgroupUsed(pc) && !PageCgroupLRU(pc) means "pc" is used but not on LRU.
 !PageCgroupUsed(pc) && PageCgroupLRU(pc) means "pc" is unused but still on
 LRU. lru walk routine should avoid touching this.

Changelog (v5) => (v6):
 - Fixing race and added PCG_LRU bit

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/page_cgroup.h |    5 +
 mm/memcontrol.c             |  201 ++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 189 insertions(+), 17 deletions(-)

Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -34,6 +34,7 @@
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
+#include <linux/cpu.h>
 
 #include <asm/uaccess.h>
 
@@ -344,7 +345,7 @@ void mem_cgroup_move_lists(struct page *
 	pc = lookup_page_cgroup(page);
 	if (!trylock_page_cgroup(pc))
 		return;
-	if (pc && PageCgroupUsed(pc)) {
+	if (pc && PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock_irqsave(&mz->lru_lock, flags);
 		__mem_cgroup_move_lists(pc, lru);
@@ -470,6 +471,122 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
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
+		mz = page_cgroup_zoneinfo(pc);
+		if (prev_mz != mz) {
+			if (prev_mz)
+				spin_unlock(&prev_mz->lru_lock);
+			prev_mz = mz;
+			spin_lock(&mz->lru_lock);
+		}
+		/*
+		 * this "pc" may be charge()->uncharge() while we are waiting
+		 * for this. But charge() path check LRU bit and remove this
+		 * from LRU if necessary.
+		 */
+		if (!PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
+			ClearPageCgroupLRU(pc);
+			__mem_cgroup_remove_list(mz, pc);
+			css_put(&pc->mem_cgroup->css);
+		}
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
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
@@ -564,25 +681,46 @@ static void __mem_cgroup_commit_charge(s
 	unsigned long flags;
 
 	lock_page_cgroup(pc);
+	/*
+	 * USED bit is set after pc->mem_cgroup has valid value.
+	 */
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
 		return;
 	}
+	/*
+	 * This page_cgroup is not used but may be on LRU.
+	 */
+	if (unlikely(PageCgroupLRU(pc))) {
+		/*
+		 * pc->mem_cgroup has old information. force_empty() guarantee
+		 * that we never see stale mem_cgroup here.
+		 */
+		mz = page_cgroup_zoneinfo(pc);
+		spin_lock_irqsave(&mz->lru_lock, flags);
+		if (PageCgroupLRU(pc)) {
+			ClearPageCgroupLRU(pc);
+			__mem_cgroup_remove_list(mz, pc);
+			css_put(&pc->mem_cgroup->css);
+		}
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+	}
+	/* Here, PCG_LRU bit is cleared */
 	pc->mem_cgroup = mem;
 	/*
-	 * If a page is accounted as a page cache, insert to inactive list.
-	 * If anon, insert to active list.
+	 * below pcg_default_flags includes PCG_LOCK bit.
 	 */
 	pc->flags = pcg_default_flags[ctype];
+	unlock_page_cgroup(pc);
 
 	mz = page_cgroup_zoneinfo(pc);
 
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_add_list(mz, pc, true);
+	SetPageCgroupLRU(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	unlock_page_cgroup(pc);
 }
 
 /**
@@ -621,7 +759,7 @@ static int mem_cgroup_move_account(struc
 	if (!trylock_page_cgroup(pc))
 		return ret;
 
-	if (!PageCgroupUsed(pc))
+	if (!PageCgroupUsed(pc) || !PageCgroupLRU(pc))
 		goto out;
 
 	if (pc->mem_cgroup != from)
@@ -836,8 +974,6 @@ __mem_cgroup_uncharge_common(struct page
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem;
-	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
 
 	if (mem_cgroup_subsys.disabled)
 		return;
@@ -858,16 +994,13 @@ __mem_cgroup_uncharge_common(struct page
 	}
 	ClearPageCgroupUsed(pc);
 	mem = pc->mem_cgroup;
-
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_remove_list(mz, pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	unlock_page_cgroup(pc);
-
+	/*
+	 * We must uncharge here because "reuse" can occur just after we
+	 * unlock this.
+	 */
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
-	css_put(&mem->css);
-
+	unlock_page_cgroup(pc);
+	release_page_cgroup(pc);
 	return;
 }
 
@@ -1073,7 +1206,7 @@ move_account:
 		ret = -EBUSY;
 		if (atomic_read(&mem->css.cgroup->count) > 0)
 			goto out;
-
+		drain_page_cgroup_all();
 		ret = 0;
 		for_each_node_state(node, N_POSSIBLE) {
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
@@ -1097,6 +1230,7 @@ move_account:
 	}
 	ret = 0;
 out:
+	drain_page_cgroup_all();
 	css_put(&mem->css);
 	return ret;
 
@@ -1318,6 +1452,38 @@ static void mem_cgroup_free(struct mem_c
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
+	switch (action) {
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
@@ -1328,6 +1494,10 @@ mem_cgroup_create(struct cgroup_subsys *
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
Index: mmotm-2.6.27-rc7+/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.27-rc7+.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.27-rc7+/include/linux/page_cgroup.h
@@ -24,6 +24,7 @@ enum {
 	PCG_LOCK,  /* page cgroup is locked */
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
+	PCG_LRU, /* on LRU */
 	/* flags for LRU placement */
 	PCG_ACTIVE, /* page is active in this cgroup */
 	PCG_FILE, /* page is file system backed */
@@ -48,6 +49,10 @@ TESTPCGFLAG(Cache, CACHE)
 TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
 
+SETPCGFLAG(LRU, LRU)
+TESTPCGFLAG(LRU, LRU)
+CLEARPCGFLAG(LRU, LRU)
+
 /* LRU management flags (from global-lru definition) */
 TESTPCGFLAG(File, FILE)
 SETPCGFLAG(File, FILE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
