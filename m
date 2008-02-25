Date: Mon, 25 Feb 2008 23:41:17 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 07/15] memcg: mem_cgroup_charge never NULL
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252340210.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

My memcgroup patch to fix hang with shmem/tmpfs added NULL page handling
to mem_cgroup_charge_common.  It seemed convenient at the time, but hard
to justify now: there's a perfectly appropriate swappage to charge and
uncharge instead, this is not on any hot path through shmem_getpage,
and no performance hit was observed from the slight extra overhead.

So revert that NULL page handling from mem_cgroup_charge_common; and
make it clearer by bringing page_cgroup_assign_new_page_cgroup into its
body - that was a helper I found more of a hindrance to understanding.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memcontrol.c |   61 +++++++++++++++-------------------------------
 mm/shmem.c      |    9 ++++--
 2 files changed, 27 insertions(+), 43 deletions(-)

--- memcg06/mm/memcontrol.c	2008-02-25 14:05:55.000000000 +0000
+++ memcg07/mm/memcontrol.c	2008-02-25 14:05:58.000000000 +0000
@@ -301,25 +301,6 @@ static void __always_inline unlock_page_
 }
 
 /*
- * Tie new page_cgroup to struct page under lock_page_cgroup()
- * This can fail if the page has been tied to a page_cgroup.
- * If success, returns 0.
- */
-static int page_cgroup_assign_new_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
-{
-	int ret = 0;
-
-	lock_page_cgroup(page);
-	if (!page_get_page_cgroup(page))
-		page_assign_page_cgroup(page, pc);
-	else /* A page is tied to other pc. */
-		ret = 1;
-	unlock_page_cgroup(page);
-	return ret;
-}
-
-/*
  * Clear page->page_cgroup member under lock_page_cgroup().
  * If given "pc" value is different from one page->page_cgroup,
  * page->cgroup is not cleared.
@@ -585,26 +566,24 @@ static int mem_cgroup_charge_common(stru
 	 * with it
 	 */
 retry:
-	if (page) {
-		lock_page_cgroup(page);
-		pc = page_get_page_cgroup(page);
-		/*
-		 * The page_cgroup exists and
-		 * the page has already been accounted.
-		 */
-		if (pc) {
-			if (unlikely(!atomic_inc_not_zero(&pc->ref_cnt))) {
-				/* this page is under being uncharged ? */
-				unlock_page_cgroup(page);
-				cpu_relax();
-				goto retry;
-			} else {
-				unlock_page_cgroup(page);
-				goto done;
-			}
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
+	/*
+	 * The page_cgroup exists and
+	 * the page has already been accounted.
+	 */
+	if (pc) {
+		if (unlikely(!atomic_inc_not_zero(&pc->ref_cnt))) {
+			/* this page is under being uncharged ? */
+			unlock_page_cgroup(page);
+			cpu_relax();
+			goto retry;
+		} else {
+			unlock_page_cgroup(page);
+			goto done;
 		}
-		unlock_page_cgroup(page);
 	}
+	unlock_page_cgroup(page);
 
 	pc = kzalloc(sizeof(struct page_cgroup), gfp_mask);
 	if (pc == NULL)
@@ -663,7 +642,9 @@ retry:
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
 		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
 
-	if (!page || page_cgroup_assign_new_page_cgroup(page, pc)) {
+	lock_page_cgroup(page);
+	if (page_get_page_cgroup(page)) {
+		unlock_page_cgroup(page);
 		/*
 		 * Another charge has been added to this page already.
 		 * We take lock_page_cgroup(page) again and read
@@ -672,10 +653,10 @@ retry:
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
 		kfree(pc);
-		if (!page)
-			goto done;
 		goto retry;
 	}
+	page_assign_page_cgroup(page, pc);
+	unlock_page_cgroup(page);
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
--- memcg06/mm/shmem.c	2008-02-11 07:18:12.000000000 +0000
+++ memcg07/mm/shmem.c	2008-02-25 14:05:58.000000000 +0000
@@ -1370,14 +1370,17 @@ repeat:
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			unlock_page(swappage);
-			page_cache_release(swappage);
 			if (error == -ENOMEM) {
 				/* allow reclaim from this memory cgroup */
-				error = mem_cgroup_cache_charge(NULL,
+				error = mem_cgroup_cache_charge(swappage,
 					current->mm, gfp & ~__GFP_HIGHMEM);
-				if (error)
+				if (error) {
+					page_cache_release(swappage);
 					goto failed;
+				}
+				mem_cgroup_uncharge_page(swappage);
 			}
+			page_cache_release(swappage);
 			goto repeat;
 		}
 	} else if (sgp == SGP_READ && !filepage) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
