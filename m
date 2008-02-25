Date: Mon, 25 Feb 2008 23:42:05 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 08/15] memcg: remove mem_cgroup_uncharge
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252341250.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nothing uses mem_cgroup_uncharge apart from mem_cgroup_uncharge_page,
(a trivial wrapper around it) and mem_cgroup_end_migration (which does
the same as mem_cgroup_uncharge_page).  And it often ends up having to
lock just to let its caller unlock.  Remove it (but leave the silly
locking until a later patch).

Moved mem_cgroup_cache_charge next to mem_cgroup_charge in memcontrol.h.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
I'd happily rename mem_cgroup_uncharge_page to mem_cgroup_uncharge later,
matching mem_cgroup_charge: that patch would touch more, what do you think?

 include/linux/memcontrol.h |   20 +++++++-------------
 mm/memcontrol.c            |   23 ++++++++---------------
 2 files changed, 15 insertions(+), 28 deletions(-)

--- memcg07/include/linux/memcontrol.h	2008-02-25 14:05:55.000000000 +0000
+++ memcg08/include/linux/memcontrol.h	2008-02-25 14:06:02.000000000 +0000
@@ -35,7 +35,8 @@ extern void mm_free_cgroup(struct mm_str
 extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
-extern void mem_cgroup_uncharge(struct page_cgroup *pc);
+extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
+					gfp_t gfp_mask);
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_move_lists(struct page *page, bool active);
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
@@ -45,8 +46,6 @@ extern unsigned long mem_cgroup_isolate_
 					struct mem_cgroup *mem_cont,
 					int active);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
-extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
-					gfp_t gfp_mask);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
 #define mm_match_cgroup(mm, cgroup)	\
@@ -92,14 +91,16 @@ static inline struct page_cgroup *page_g
 	return NULL;
 }
 
-static inline int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
-					gfp_t gfp_mask)
+static inline int mem_cgroup_charge(struct page *page,
+					struct mm_struct *mm, gfp_t gfp_mask)
 {
 	return 0;
 }
 
-static inline void mem_cgroup_uncharge(struct page_cgroup *pc)
+static inline int mem_cgroup_cache_charge(struct page *page,
+					struct mm_struct *mm, gfp_t gfp_mask)
 {
+	return 0;
 }
 
 static inline void mem_cgroup_uncharge_page(struct page *page)
@@ -110,13 +111,6 @@ static inline void mem_cgroup_move_lists
 {
 }
 
-static inline int mem_cgroup_cache_charge(struct page *page,
-						struct mm_struct *mm,
-						gfp_t gfp_mask)
-{
-	return 0;
-}
-
 static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
 {
 	return 1;
--- memcg07/mm/memcontrol.c	2008-02-25 14:05:58.000000000 +0000
+++ memcg08/mm/memcontrol.c	2008-02-25 14:06:02.000000000 +0000
@@ -697,20 +697,22 @@ int mem_cgroup_cache_charge(struct page 
 
 /*
  * Uncharging is always a welcome operation, we never complain, simply
- * uncharge. This routine should be called with lock_page_cgroup held
+ * uncharge.
  */
-void mem_cgroup_uncharge(struct page_cgroup *pc)
+void mem_cgroup_uncharge_page(struct page *page)
 {
+	struct page_cgroup *pc;
 	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
-	struct page *page;
 	unsigned long flags;
 
 	/*
 	 * Check if our page_cgroup is valid
 	 */
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
 	if (!pc)
-		return;
+		goto unlock;
 
 	if (atomic_dec_and_test(&pc->ref_cnt)) {
 		page = pc->page;
@@ -731,12 +733,8 @@ void mem_cgroup_uncharge(struct page_cgr
 		}
 		lock_page_cgroup(page);
 	}
-}
 
-void mem_cgroup_uncharge_page(struct page *page)
-{
-	lock_page_cgroup(page);
-	mem_cgroup_uncharge(page_get_page_cgroup(page));
+unlock:
 	unlock_page_cgroup(page);
 }
 
@@ -759,12 +757,7 @@ int mem_cgroup_prepare_migration(struct 
 
 void mem_cgroup_end_migration(struct page *page)
 {
-	struct page_cgroup *pc;
-
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	mem_cgroup_uncharge(pc);
-	unlock_page_cgroup(page);
+	mem_cgroup_uncharge_page(page);
 }
 /*
  * We know both *page* and *newpage* are now not-on-LRU and Pg_locked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
