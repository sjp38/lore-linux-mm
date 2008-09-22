Date: Mon, 22 Sep 2008 20:00:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/13] memcg: force_empty moving account
Message-Id: <20080922200025.49ea6d70.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Current force_empty of memory resource controller just removes page_cgroup.
This maans the page is never accounted at all and create an in-use page which
has no page_cgroup.

This patch tries to move account to "root" cgroup. By this patch, force_empty
doesn't leak an account but move account to "root" cgroup. Maybe someone can
think of other enhancements as moving account to its parent.
(But moving to the parent means we have to handle "limit" of pages.
 Need more complicated work to do that.")

For now, just moves account to root cgroup.

Note: all lock other than old mem_cgroup's lru_lock
      in this path is try_lock().

Changelog (v3) -> (v4)
 - no changes
Changelog (v2) -> (v3)
 - splitted out mem_cgroup_move_account().
 - replaced get_page() with get_page_unless_zero().
   (This is necessary for avoiding confliction with migration)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 Documentation/controllers/memory.txt |    7 ++--
 mm/memcontrol.c                      |   51 +++++++++++++++++++++--------------
 2 files changed, 35 insertions(+), 23 deletions(-)

Index: mmotm-2.6.27-rc6+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc6+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc6+/mm/memcontrol.c
@@ -29,6 +29,7 @@
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/spinlock.h>
+#include <linux/pagemap.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
 #include <linux/vmalloc.h>
@@ -976,17 +977,14 @@ int mem_cgroup_resize_limit(struct mem_c
 
 
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
 	struct page_cgroup *pc;
 	struct page *page;
-	int count = FORCE_UNCHARGE_BATCH;
 	unsigned long flags;
 	struct list_head *list;
 
@@ -996,23 +994,36 @@ static void mem_cgroup_force_empty_list(
 	while (!list_empty(list)) {
 		pc = list_entry(list->prev, struct page_cgroup, lru);
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
+		/* For avoiding race with speculative page cache handling. */
+		if (!PageLRU(page) || !get_page_unless_zero(page)) {
+			list_move(&pc->lru, list);
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			yield();
+			spin_lock_irqsave(&mz->lru_lock, flags);
+			continue;
+		}
+		if (!trylock_page(page)) {
+			list_move(&pc->lru, list);
 			put_page(page);
-			if (--count <= 0) {
-				count = FORCE_UNCHARGE_BATCH;
-				cond_resched();
-			}
-		} else
-			cond_resched();
-		spin_lock_irqsave(&mz->lru_lock, flags);
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			yield();
+			spin_lock_irqsave(&mz->lru_lock, flags);
+			continue;
+		}
+		if (mem_cgroup_move_account(page, pc, mem, &init_mem_cgroup)) {
+			/* some confliction */
+			list_move(&pc->lru, list);
+			unlock_page(page);
+			put_page(page);
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			yield();
+			spin_lock_irqsave(&mz->lru_lock, flags);
+		} else {
+			unlock_page(page);
+			put_page(page);
+		}
+		if (atomic_read(&mem->css.cgroup->count) > 0)
+			break;
 	}
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 }
Index: mmotm-2.6.27-rc6+/Documentation/controllers/memory.txt
===================================================================
--- mmotm-2.6.27-rc6+.orig/Documentation/controllers/memory.txt
+++ mmotm-2.6.27-rc6+/Documentation/controllers/memory.txt
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
