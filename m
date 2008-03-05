Date: Wed, 5 Mar 2008 20:57:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Preview] [PATCH] radix tree based page cgroup [2/6] charge and
 uncharge
Message-Id: <20080305205702.1fc8da94.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080305205137.5c744097.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080305205137.5c744097.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "taka@valinux.co.jp" <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Chagnges in Core Logic....charge and uncharge.

Because bit spin lock is removed and spinlock is added to page_cgroup.
There are some amount of changes.

This patch does
	- modified charge/uncharge
	- removed add_list/remove_list function. Just added stat functions
	- Added simple lock rule comments.

Major changes from current(rc4) version is
	- pc->refcnt is set to be "1" after the charge is done.

Changelog
  - Rebased to rc4

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 mm/memcontrol.c |  136 +++++++++++++++++++++++++-------------------------------
 1 file changed, 62 insertions(+), 74 deletions(-)

Index: linux-2.6.25-rc4/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc4.orig/mm/memcontrol.c
+++ linux-2.6.25-rc4/mm/memcontrol.c
@@ -34,6 +34,16 @@
 
 #include <asm/uaccess.h>
 
+/*
+ * Lock Rule
+ * zone->lru_lcok (global LRU)
+ *	-> pc->lock (page_cgroup's lock)
+ *		-> mz->lru_lock (mem_cgroup's per_zone lock.)
+ *
+ * At least, mz->lru_lock and pc->lock should be acquired irq off.
+ *
+ */
+
 struct cgroup_subsys mem_cgroup_subsys;
 static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
 
@@ -476,33 +486,22 @@ static int mem_cgroup_charge_common(stru
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
 
+	pc = get_page_cgroup(page, gfp_mask, true);
+	if (!pc || IS_ERR(pc))
+		return PTR_ERR(pc);
+
+	spin_lock_irqsave(&pc->lock, flags);
 	/*
-	 * Should page_cgroup's go to their own slab?
-	 * One could optimize the performance of the charging routine
-	 * by saving a bit in the page_flags and using it as a lock
-	 * to see if the cgroup page already has a page_cgroup associated
-	 * with it
-	 */
-retry:
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	/*
-	 * The page_cgroup exists and
-	 * the page has already been accounted.
+	 * Has the page already been accounted ?
 	 */
-	if (pc) {
-		VM_BUG_ON(pc->page != page);
-		VM_BUG_ON(pc->ref_cnt <= 0);
-
-		pc->ref_cnt++;
-		unlock_page_cgroup(page);
-		goto done;
+	if (pc->refcnt > 0) {
+		pc->refcnt++;
+		spin_unlock_irqrestore(&pc->lock, flags);
+		goto success;
 	}
-	unlock_page_cgroup(page);
+	spin_unlock_irqrestore(&pc->lock, flags);
 
-	pc = kzalloc(sizeof(struct page_cgroup), gfp_mask);
-	if (pc == NULL)
-		goto err;
+	/* Note: pc->refcnt is still 0 here. */
 
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
@@ -523,7 +522,7 @@ retry:
 
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		if (!(gfp_mask & __GFP_WAIT))
-			goto out;
+			goto nomem;
 
 		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
 			continue;
@@ -540,45 +539,40 @@ retry:
 
 		if (!nr_retries--) {
 			mem_cgroup_out_of_memory(mem, gfp_mask);
-			goto out;
+			goto nomem;
 		}
 		congestion_wait(WRITE, HZ/10);
 	}
-
-	pc->ref_cnt = 1;
+	/*
+ 	 * We have to acquire 2 spinlocks.
+	 */
+	spin_lock_irqsave(&pc->lock, flags);
+	if (pc->refcnt) {
+		/* Someone charged this page while we released the lock */
+		++pc->refcnt;
+		spin_unlock_irqrestore(&pc->lock, flags);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		css_put(&mem->css);
+		goto success;
+	}
+	/* Anyone doesn't touch this. */
+	VM_BUG_ON(pc->mem_cgroup);
+	VM_BUG_ON(!list_empty(&pc->lru));
+	pc->refcnt = 1;
 	pc->mem_cgroup = mem;
-	pc->page = page;
 	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
 		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
-
-	lock_page_cgroup(page);
-	if (page_get_page_cgroup(page)) {
-		unlock_page_cgroup(page);
-		/*
-		 * Another charge has been added to this page already.
-		 * We take lock_page_cgroup(page) again and read
-		 * page->cgroup, increment refcnt.... just retry is OK.
-		 */
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		css_put(&mem->css);
-		kfree(pc);
-		goto retry;
-	}
-	page_assign_page_cgroup(page, pc);
-
 	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
+	spin_lock(&mz->lru_lock);
 	__mem_cgroup_add_list(pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	spin_unlock(&mz->lru_lock);
+	spin_unlock_irqrestore(&pc->lock, flags);
 
-	unlock_page_cgroup(page);
-done:
+success:
 	return 0;
-out:
+nomem:
 	css_put(&mem->css);
-	kfree(pc);
-err:
 	return -ENOMEM;
 }
 
@@ -611,33 +605,27 @@ void mem_cgroup_uncharge_page(struct pag
 	/*
 	 * Check if our page_cgroup is valid
 	 */
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
+	pc = get_page_cgroup(page, GFP_ATOMIC, false); /* No allocation */
 	if (!pc)
-		goto unlock;
-
-	VM_BUG_ON(pc->page != page);
-	VM_BUG_ON(pc->ref_cnt <= 0);
-
-	if (--(pc->ref_cnt) == 0) {
-		mz = page_cgroup_zoneinfo(pc);
-		spin_lock_irqsave(&mz->lru_lock, flags);
-		__mem_cgroup_remove_list(pc);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
-
-		page_assign_page_cgroup(page, NULL);
-		unlock_page_cgroup(page);
-
-		mem = pc->mem_cgroup;
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		css_put(&mem->css);
-
-		kfree(pc);
+		return;
+	spin_lock_irqsave(&pc->lock, flags);
+	if (!pc->refcnt || --pc->refcnt > 0) {
+		spin_unlock_irqrestore(&pc->lock, flags);
 		return;
 	}
+	VM_BUG_ON(pc->page != page);
+	mz = page_cgroup_zoneinfo(pc);
+	mem = pc->mem_cgroup;
 
-unlock:
-	unlock_page_cgroup(page);
+	spin_lock(&mz->lru_lock);
+	__mem_cgroup_remove_list(pc);
+	spin_unlock(&mz->lru_lock);
+
+	pc->flags = 0;
+	pc->mem_cgroup = 0;
+	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	css_put(&mem->css);
+	spin_unlock_irqrestore(&pc->lock, flags);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
