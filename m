Date: Mon, 25 Feb 2008 23:44:44 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 10/15] memcg: memcontrol uninlined and static
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252343230.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Adrian Bunk <bunk@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

More cleanup to memcontrol.c, this time changing some of the code generated.
Let the compiler decide what to inline (except for page_cgroup_locked which
is only used when CONFIG_DEBUG_VM): the __always_inline on lock_page_cgroup
etc. was quite a waste since bit_spin_lock etc. are inlines in a header file;
made mem_cgroup_force_empty and mem_cgroup_write_strategy static.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memcontrol.c |   28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

--- memcg09/mm/memcontrol.c	2008-02-25 14:06:09.000000000 +0000
+++ memcg10/mm/memcontrol.c	2008-02-25 14:06:12.000000000 +0000
@@ -168,12 +168,12 @@ struct page_cgroup {
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
 
-static inline int page_cgroup_nid(struct page_cgroup *pc)
+static int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
 }
 
-static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
+static enum zone_type page_cgroup_zid(struct page_cgroup *pc)
 {
 	return page_zonenum(pc->page);
 }
@@ -199,14 +199,13 @@ static void mem_cgroup_charge_statistics
 		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
 }
 
-static inline struct mem_cgroup_per_zone *
+static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 {
-	BUG_ON(!mem->info.nodeinfo[nid]);
 	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
 }
 
-static inline struct mem_cgroup_per_zone *
+static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {
 	struct mem_cgroup *mem = pc->mem_cgroup;
@@ -231,16 +230,14 @@ static unsigned long mem_cgroup_get_all_
 	return total;
 }
 
-static inline
-struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
+static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
 {
 	return container_of(cgroup_subsys_state(cont,
 				mem_cgroup_subsys_id), struct mem_cgroup,
 				css);
 }
 
-static inline
-struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
+static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 {
 	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
 				struct mem_cgroup, css);
@@ -276,13 +273,12 @@ struct page_cgroup *page_get_page_cgroup
 	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
 }
 
-static void __always_inline lock_page_cgroup(struct page *page)
+static void lock_page_cgroup(struct page *page)
 {
 	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-	VM_BUG_ON(!page_cgroup_locked(page));
 }
 
-static void __always_inline unlock_page_cgroup(struct page *page)
+static void unlock_page_cgroup(struct page *page)
 {
 	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
 }
@@ -741,16 +737,14 @@ void mem_cgroup_end_migration(struct pag
 void mem_cgroup_page_migration(struct page *page, struct page *newpage)
 {
 	struct page_cgroup *pc;
-	struct mem_cgroup *mem;
-	unsigned long flags;
 	struct mem_cgroup_per_zone *mz;
+	unsigned long flags;
 
 retry:
 	pc = page_get_page_cgroup(page);
 	if (!pc)
 		return;
 
-	mem = pc->mem_cgroup;
 	mz = page_cgroup_zoneinfo(pc);
 	if (clear_page_cgroup(page, pc) != pc)
 		goto retry;
@@ -822,7 +816,7 @@ retry:
  * make mem_cgroup's charge to be 0 if there is no task.
  * This enables deleting this mem_cgroup.
  */
-int mem_cgroup_force_empty(struct mem_cgroup *mem)
+static int mem_cgroup_force_empty(struct mem_cgroup *mem)
 {
 	int ret = -EBUSY;
 	int node, zid;
@@ -852,7 +846,7 @@ out:
 	return ret;
 }
 
-int mem_cgroup_write_strategy(char *buf, unsigned long long *tmp)
+static int mem_cgroup_write_strategy(char *buf, unsigned long long *tmp)
 {
 	*tmp = memparse(buf, &buf);
 	if (*buf != '\0')

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
