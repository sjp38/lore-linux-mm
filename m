Date: Fri, 22 Aug 2008 20:34:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 5/14]  memcg: free page_cgroup by RCU
Message-Id: <20080822203457.d62e394d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Freeing page_cgroup by RCU.

This makes access to page->page_cgroup as RCU-safe.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   44 ++++++++++++++++++++++++++++++++++++--------
 1 file changed, 36 insertions(+), 8 deletions(-)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -588,19 +588,23 @@ unsigned long mem_cgroup_isolate_pages(u
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
 
@@ -627,6 +631,26 @@ static void __free_obsolete_page_cgroup(
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
@@ -649,13 +673,17 @@ static DEFINE_MUTEX(memcg_force_drain_mu
 
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
