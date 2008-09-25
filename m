From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 8/12] memcg rewrite force empty to move account to root
Date: Thu, 25 Sep 2008 15:29:28 +0900
Message-ID: <20080925152928.e88fc53a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754635AbYIYGXG@vger.kernel.org>
In-Reply-To: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-Id: linux-mm.kvack.org

Current force_empty of memory resource controller just removes page_cgroup.
This maans the page is never accounted at all and create an in-use page which
has no page_cgroup.

This patch tries to move account to "root" cgroup. By this patch, force_empty
doesn't leak an account but move account to "root" cgroup. Maybe someone can
think of other enhancements as moving account to its parent.
(But moving to the parent means we have to handle "limit" of pages.
 Need more complicated work to do that.)

For now, just moves account to root cgroup.

Note: all lock other than old mem_cgroup's lru_lock
      in this path is try_lock().

Changelog (v4) -> (5)
 - removed yield()
 - remove lock_page().
 - use list_for_each_entry_safe() instead of list_empty() loop.
 - check list is empty or not rather than see usage.
 - added lru_add_drain_all() at the start of loops.

Changelog (v2) -> (v4)
 - splitted out mem_cgroup_move_account().
 - replaced get_page() with get_page_unless_zero().
   (This is necessary for avoiding confliction with migration)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 Documentation/controllers/memory.txt |    7 ++-
 mm/memcontrol.c                      |   68 ++++++++++++++++++++---------------
 2 files changed, 43 insertions(+), 32 deletions(-)

Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -29,10 +29,12 @@
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/spinlock.h>
+#include <linux/pagemap.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
+#include <linux/writeback.h>
 
 #include <asm/uaccess.h>
 
@@ -979,45 +981,34 @@ int mem_cgroup_resize_limit(struct mem_c
 
 
 /*
- * This routine traverse page_cgroup in given list and drop them all.
- * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
+ * This routine traverse page_cgroup in given list and move them all.
  */
-#define FORCE_UNCHARGE_BATCH	(128)
 static void mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 			    struct mem_cgroup_per_zone *mz,
 			    enum lru_list lru)
 {
-	struct page_cgroup *pc;
+	struct page_cgroup *pc, *tmp;
 	struct page *page;
-	int count = FORCE_UNCHARGE_BATCH;
 	unsigned long flags;
 	struct list_head *list;
 
 	list = &mz->lists[lru];
 
 	spin_lock_irqsave(&mz->lru_lock, flags);
-	while (!list_empty(list)) {
-		pc = list_entry(list->prev, struct page_cgroup, lru);
+	list_for_each_entry_safe(pc, tmp, list, lru) {
 		page = pc->page;
-		get_page(page);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
-		/*
-		 * Check if this page is on LRU. !LRU page can be found
-		 * if it's under page migration.
-		 */
-		if (PageLRU(page)) {
-			__mem_cgroup_uncharge_common(page,
-					MEM_CGROUP_CHARGE_TYPE_FORCE);
-			put_page(page);
-			if (--count <= 0) {
-				count = FORCE_UNCHARGE_BATCH;
-				cond_resched();
-			}
-		} else
-			cond_resched();
-		spin_lock_irqsave(&mz->lru_lock, flags);
+		/* For avoiding race with speculative page cache handling. */
+		if (!PageLRU(page) || !get_page_unless_zero(page)) {
+			continue;
+		}
+		mem_cgroup_move_account(page, pc, mem, &init_mem_cgroup);
+		put_page(page);
+		if (atomic_read(&mem->css.cgroup->count) > 0)
+			break;
 	}
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
+
+	cond_resched();
 }
 
 /*
@@ -1027,7 +1018,9 @@ static void mem_cgroup_force_empty_list(
 static int mem_cgroup_force_empty(struct mem_cgroup *mem)
 {
 	int ret = -EBUSY;
-	int node, zid;
+	int node, zid, busy;
+	struct mem_cgroup_per_zone *mz;
+	enum lru_list l;
 
 	css_get(&mem->css);
 	/*
@@ -1035,17 +1028,34 @@ static int mem_cgroup_force_empty(struct
 	 * active_list <-> inactive_list while we don't take a lock.
 	 * So, we have to do loop here until all lists are empty.
 	 */
-	while (mem->res.usage > 0) {
+	busy = 1;
+
+	while (busy) {
 		if (atomic_read(&mem->css.cgroup->count) > 0)
 			goto out;
-		for_each_node_state(node, N_POSSIBLE)
+		/*
+		 * While walking our own LRU, we also checks LRU bit on page.
+		 * If a page is on pagevec, it's not on LRU and we cannot
+		 * grab it. Calling lru_add_drain_all() here.
+		 */
+		lru_add_drain_all();
+		for_each_node_state(node, N_HIGH_MEMORY) {
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-				struct mem_cgroup_per_zone *mz;
-				enum lru_list l;
 				mz = mem_cgroup_zoneinfo(mem, node, zid);
 				for_each_lru(l)
 					mem_cgroup_force_empty_list(mem, mz, l);
 			}
+		}
+		busy = 0;
+		for_each_node_state(node, N_HIGH_MEMORY) {
+			for (zid = 0; !busy && zid < MAX_NR_ZONES; zid++) {
+				mz = mem_cgroup_zoneinfo(mem, node, zid);
+				for_each_lru(l)
+					busy |= !list_empty(&mz->lists[l]);
+			}
+			if (busy)
+				break;
+		}
 	}
 	ret = 0;
 out:
Index: mmotm-2.6.27-rc7+/Documentation/controllers/memory.txt
===================================================================
--- mmotm-2.6.27-rc7+.orig/Documentation/controllers/memory.txt
+++ mmotm-2.6.27-rc7+/Documentation/controllers/memory.txt
@@ -207,7 +207,8 @@ The memory.force_empty gives an interfac
 
 # echo 1 > memory.force_empty
 
-will drop all charges in cgroup. Currently, this is maintained for test.
+will move all charges to root cgroup.
+(This policy may be modified in future.)
 
 4. Testing
 
@@ -238,8 +239,8 @@ reclaimed.
 
 A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
 cgroup might have some charge associated with it, even though all
-tasks have migrated away from it. Such charges are automatically dropped at
-rmdir() if there are no tasks.
+tasks have migrated away from it. Such charges are automatically moved to
+root cgroup at rmidr() if there are no tasks. (This policy may be changed.)
 
 5. TODO
 
