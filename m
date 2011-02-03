Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 133FC8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:27:14 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/5] memcg: fold __mem_cgroup_move_account into caller
Date: Thu,  3 Feb 2011 15:26:04 +0100
Message-Id: <1296743166-9412-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It is one logical function, no need to have it split up.

Also, get rid of some checks from the inner function that ensured the
sanity of the outer function.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/page_cgroup.h |    5 ---
 mm/memcontrol.c             |   66 +++++++++++++++++++------------------------
 2 files changed, 29 insertions(+), 42 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 363bbc8..6b63679 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -99,11 +99,6 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
-static inline int page_is_cgroup_locked(struct page_cgroup *pc)
-{
-	return bit_spin_is_locked(PCG_LOCK, &pc->flags);
-}
-
 static inline void move_lock_page_cgroup(struct page_cgroup *pc,
 	unsigned long *flags)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 77a3f87..5eb0dc2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2174,33 +2174,49 @@ void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
 #endif
 
 /**
- * __mem_cgroup_move_account - move account of the page
+ * mem_cgroup_move_account - move account of the page
  * @pc:	page_cgroup of the page.
  * @from: mem_cgroup which the page is moved from.
  * @to:	mem_cgroup which the page is moved to. @from != @to.
  * @uncharge: whether we should call uncharge and css_put against @from.
+ * @charge_size: number of bytes to charge (regular or huge page)
  *
  * The caller must confirm following.
  * - page is not on LRU (isolate_page() is useful.)
- * - the pc is locked, used, and ->mem_cgroup points to @from.
+ * - compound_lock is held when charge_size > PAGE_SIZE
  *
  * This function doesn't do "charge" nor css_get to new cgroup. It should be
  * done by a caller(__mem_cgroup_try_charge would be usefull). If @uncharge is
  * true, this function does "uncharge" from old cgroup, but it doesn't if
  * @uncharge is false, so a caller should do "uncharge".
  */
-
-static void __mem_cgroup_move_account(struct page_cgroup *pc,
-	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge,
-	int charge_size)
+static int mem_cgroup_move_account(struct page_cgroup *pc,
+				   struct mem_cgroup *from, struct mem_cgroup *to,
+				   bool uncharge, int charge_size)
 {
 	int nr_pages = charge_size >> PAGE_SHIFT;
+	unsigned long flags;
+	int ret;
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
-	VM_BUG_ON(!page_is_cgroup_locked(pc));
-	VM_BUG_ON(!PageCgroupUsed(pc));
-	VM_BUG_ON(pc->mem_cgroup != from);
+	/*
+	 * The page is isolated from LRU. So, collapse function
+	 * will not handle this page. But page splitting can happen.
+	 * Do this check under compound_page_lock(). The caller should
+	 * hold it.
+	 */
+	ret = -EBUSY;
+	if (charge_size > PAGE_SIZE && !PageTransHuge(pc->page))
+		goto out;
+
+	lock_page_cgroup(pc);
+
+	ret = -EINVAL;
+	if (!PageCgroupUsed(pc) || pc->mem_cgroup != from)
+		goto unlock;
+
+	move_lock_page_cgroup(pc, &flags);
 
 	if (PageCgroupFileMapped(pc)) {
 		/* Update mapped_file data for mem_cgroup */
@@ -2224,40 +2240,16 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
 	 * garanteed that "to" is never removed. So, we don't check rmdir
 	 * status here.
 	 */
-}
-
-/*
- * check whether the @pc is valid for moving account and call
- * __mem_cgroup_move_account()
- */
-static int mem_cgroup_move_account(struct page_cgroup *pc,
-		struct mem_cgroup *from, struct mem_cgroup *to,
-		bool uncharge, int charge_size)
-{
-	int ret = -EINVAL;
-	unsigned long flags;
-	/*
-	 * The page is isolated from LRU. So, collapse function
-	 * will not handle this page. But page splitting can happen.
-	 * Do this check under compound_page_lock(). The caller should
-	 * hold it.
-	 */
-	if ((charge_size > PAGE_SIZE) && !PageTransHuge(pc->page))
-		return -EBUSY;
-
-	lock_page_cgroup(pc);
-	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
-		move_lock_page_cgroup(pc, &flags);
-		__mem_cgroup_move_account(pc, from, to, uncharge, charge_size);
-		move_unlock_page_cgroup(pc, &flags);
-		ret = 0;
-	}
+	move_unlock_page_cgroup(pc, &flags);
+	ret = 0;
+unlock:
 	unlock_page_cgroup(pc);
 	/*
 	 * check events
 	 */
 	memcg_check_events(to, pc->page);
 	memcg_check_events(from, pc->page);
+out:
 	return ret;
 }
 
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
