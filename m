Date: Wed, 20 Aug 2008 19:03:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH -mm 3/7] memcg: freeing page_cgroup by rcu.patch
Message-Id: <20080820190324.f723d222.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080819173014.17358c17.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, ryov@valinux.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

By delayed_batch_freeing_of_page_cgroup.patch, page_cgroup can be
freed lazily. After this patch, page_cgroup is freed by RCU and
page_cgroup is RCU safe. This is necessary for lockless page_cgroup patch

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   44 ++++++++++++++++++++++++++++++++++++--------
 1 file changed, 36 insertions(+), 8 deletions(-)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -577,19 +577,23 @@ unsigned long mem_cgroup_isolate_pages(u
  * Free obsolete page_cgroups which is linked to per-cpu drop list.
  */
 
-static void __free_obsolete_page_cgroup(void)
+struct page_cgroup_rcu_work {
+	struct rcu_head head;
+	struct page_cgroup *list;
+};
+
+static void __free_obsolete_page_cgroup_cb(struct rcu_head *head)
 {
 	struct mem_cgroup *memcg;
 	struct page_cgroup *pc, *next;
 	struct mem_cgroup_per_zone *mz, *page_mz;
-	struct mem_cgroup_sink_list *mcsl;
+	struct page_cgroup_rcu_work *work;
 	unsigned long flags;
 
-	mcsl = &get_cpu_var(memcg_sink_list);
-	next = mcsl->next;
-	mcsl->next = NULL;
-	mcsl->count = 0;
-	put_cpu_var(memcg_sink_list);
+
+	work = container_of(head, struct page_cgroup_rcu_work, head);
+	next = work->list;
+	kfree(work);
 
 	mz = NULL;
 
@@ -616,6 +620,26 @@ static void __free_obsolete_page_cgroup(
 	local_irq_restore(flags);
 }
 
+static int __free_obsolete_page_cgroup(void)
+{
+	struct page_cgroup_rcu_work *work;
+	struct mem_cgroup_sink_list *mcsl;
+
+	work = kmalloc(sizeof(*work), GFP_ATOMIC);
+	if (!work)
+		return -ENOMEM;
+	INIT_RCU_HEAD(&work->head);
+
+	mcsl = &get_cpu_var(memcg_sink_list);
+	work->list = mcsl->next;
+	mcsl->next = NULL;
+	mcsl->count = 0;
+	put_cpu_var(memcg_sink_list);
+
+	call_rcu(&work->head, __free_obsolete_page_cgroup_cb);
+	return 0;
+}
+
 static void free_obsolete_page_cgroup(struct page_cgroup *pc)
 {
 	int count;
@@ -638,13 +662,17 @@ static DEFINE_MUTEX(memcg_force_drain_mu
 
 static void mem_cgroup_local_force_drain(struct work_struct *work)
 {
-	__free_obsolete_page_cgroup();
+	int ret;
+	do {
+		ret = __free_obsolete_page_cgroup();
+	} while (ret);
 }
 
 static void mem_cgroup_all_force_drain(void)
 {
 	mutex_lock(&memcg_force_drain_mutex);
 	schedule_on_each_cpu(mem_cgroup_local_force_drain);
+	synchronize_rcu();
 	mutex_unlock(&memcg_force_drain_mutex);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
