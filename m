Date: Mon, 25 Feb 2008 23:46:22 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 11/15] memcg: remove clear_page_cgroup and atomics
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252344500.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove clear_page_cgroup: it's an unhelpful helper, see for example how
mem_cgroup_uncharge_page had to unlock_page_cgroup just in order to call
it (serious races from that? I'm not sure).

Once that's gone, you can see it's pointless for page_cgroup's ref_cnt
to be atomic: it's always manipulated under lock_page_cgroup, except
where force_empty unilaterally reset it to 0 (and how does uncharge's
atomic_dec_and_test protect against that?).

Simplify this page_cgroup locking: if you've got the lock and the pc
is attached, then the ref_cnt must be positive: VM_BUG_ONs to check
that, and to check that pc->page matches page (we're on the way to
finding why sometimes it doesn't, but this patch doesn't fix that).

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memcontrol.c |  106 ++++++++++++++++++----------------------------
 1 file changed, 43 insertions(+), 63 deletions(-)

--- memcg10/mm/memcontrol.c	2008-02-25 14:06:12.000000000 +0000
+++ memcg11/mm/memcontrol.c	2008-02-25 14:06:16.000000000 +0000
@@ -161,8 +161,7 @@ struct page_cgroup {
 	struct list_head lru;		/* per cgroup LRU list */
 	struct page *page;
 	struct mem_cgroup *mem_cgroup;
-	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
-					/* mapped and cached states     */
+	int ref_cnt;			/* cached, mapped, migrating */
 	int flags;
 };
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
@@ -283,27 +282,6 @@ static void unlock_page_cgroup(struct pa
 	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
 }
 
-/*
- * Clear page->page_cgroup member under lock_page_cgroup().
- * If given "pc" value is different from one page->page_cgroup,
- * page->cgroup is not cleared.
- * Returns a value of page->page_cgroup at lock taken.
- * A can can detect failure of clearing by following
- *  clear_page_cgroup(page, pc) == pc
- */
-static struct page_cgroup *clear_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
-{
-	struct page_cgroup *ret;
-	/* lock and clear */
-	lock_page_cgroup(page);
-	ret = page_get_page_cgroup(page);
-	if (likely(ret == pc))
-		page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
-	return ret;
-}
-
 static void __mem_cgroup_remove_list(struct page_cgroup *pc)
 {
 	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
@@ -555,15 +533,12 @@ retry:
 	 * the page has already been accounted.
 	 */
 	if (pc) {
-		if (unlikely(!atomic_inc_not_zero(&pc->ref_cnt))) {
-			/* this page is under being uncharged ? */
-			unlock_page_cgroup(page);
-			cpu_relax();
-			goto retry;
-		} else {
-			unlock_page_cgroup(page);
-			goto done;
-		}
+		VM_BUG_ON(pc->page != page);
+		VM_BUG_ON(pc->ref_cnt <= 0);
+
+		pc->ref_cnt++;
+		unlock_page_cgroup(page);
+		goto done;
 	}
 	unlock_page_cgroup(page);
 
@@ -612,7 +587,7 @@ retry:
 		congestion_wait(WRITE, HZ/10);
 	}
 
-	atomic_set(&pc->ref_cnt, 1);
+	pc->ref_cnt = 1;
 	pc->mem_cgroup = mem;
 	pc->page = page;
 	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
@@ -683,24 +658,24 @@ void mem_cgroup_uncharge_page(struct pag
 	if (!pc)
 		goto unlock;
 
-	if (atomic_dec_and_test(&pc->ref_cnt)) {
-		page = pc->page;
-		mz = page_cgroup_zoneinfo(pc);
-		/*
-		 * get page->cgroup and clear it under lock.
-		 * force_empty can drop page->cgroup without checking refcnt.
-		 */
+	VM_BUG_ON(pc->page != page);
+	VM_BUG_ON(pc->ref_cnt <= 0);
+
+	if (--(pc->ref_cnt) == 0) {
+		page_assign_page_cgroup(page, NULL);
 		unlock_page_cgroup(page);
-		if (clear_page_cgroup(page, pc) == pc) {
-			mem = pc->mem_cgroup;
-			css_put(&mem->css);
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			spin_lock_irqsave(&mz->lru_lock, flags);
-			__mem_cgroup_remove_list(pc);
-			spin_unlock_irqrestore(&mz->lru_lock, flags);
-			kfree(pc);
-		}
-		lock_page_cgroup(page);
+
+		mem = pc->mem_cgroup;
+		css_put(&mem->css);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+
+		mz = page_cgroup_zoneinfo(pc);
+		spin_lock_irqsave(&mz->lru_lock, flags);
+		__mem_cgroup_remove_list(pc);
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+
+		kfree(pc);
+		return;
 	}
 
 unlock:
@@ -714,14 +689,13 @@ unlock:
 int mem_cgroup_prepare_migration(struct page *page)
 {
 	struct page_cgroup *pc;
-	int ret = 0;
 
 	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
-	if (pc && atomic_inc_not_zero(&pc->ref_cnt))
-		ret = 1;
+	if (pc)
+		pc->ref_cnt++;
 	unlock_page_cgroup(page);
-	return ret;
+	return pc != NULL;
 }
 
 void mem_cgroup_end_migration(struct page *page)
@@ -740,15 +714,17 @@ void mem_cgroup_page_migration(struct pa
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
-retry:
+	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
-	if (!pc)
+	if (!pc) {
+		unlock_page_cgroup(page);
 		return;
+	}
 
-	mz = page_cgroup_zoneinfo(pc);
-	if (clear_page_cgroup(page, pc) != pc)
-		goto retry;
+	page_assign_page_cgroup(page, NULL);
+	unlock_page_cgroup(page);
 
+	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_remove_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
@@ -794,15 +770,19 @@ retry:
 	while (--count && !list_empty(list)) {
 		pc = list_entry(list->prev, struct page_cgroup, lru);
 		page = pc->page;
-		/* Avoid race with charge */
-		atomic_set(&pc->ref_cnt, 0);
-		if (clear_page_cgroup(page, pc) == pc) {
+		lock_page_cgroup(page);
+		if (page_get_page_cgroup(page) == pc) {
+			page_assign_page_cgroup(page, NULL);
+			unlock_page_cgroup(page);
 			css_put(&mem->css);
 			res_counter_uncharge(&mem->res, PAGE_SIZE);
 			__mem_cgroup_remove_list(pc);
 			kfree(pc);
-		} else 	/* being uncharged ? ...do relax */
+		} else {
+			/* racing uncharge: let page go then retry */
+			unlock_page_cgroup(page);
 			break;
+		}
 	}
 
 	spin_unlock_irqrestore(&mz->lru_lock, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
