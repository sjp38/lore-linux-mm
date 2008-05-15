Date: Thu, 15 May 2008 18:34:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH -mm 5/5] memcg: remove a redundant check
Message-Id: <20080515183413.e2c008e6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080515182516.763967cc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080515182516.763967cc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Because of remove refcnt patch, it's very rare case to that
mem_cgroup_charge_common() is called against a page which is accounted.

mem_cgroup_charge_common() is called when.
 1. a page is added into file cache.
 2. an anon page is _newly_ mapped.

A racy case is that a newly-swapped-in anonymous page is referred from
prural threads in do_swap_page() at the same time.
(a page is not Locked when mem_cgroup_charge() is called from do_swap_page.)

Another case is shmem. It charges its page before calling add_to_page_cache().
Then, mem_cgroup_charge_cache() is called twice. This case is handled in
mem_cgroup_cache_charge(). But this check may be too hacky...

Changelog v3->v4
 - added shmem's corner case handling in mem_cgroup_charge_cache().


Signed-off-by : KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   53 +++++++++++++++++++++++++----------------------------
 1 file changed, 25 insertions(+), 28 deletions(-)

Index: mm-2.6.26-rc2-mm1/mm/memcontrol.c
===================================================================
--- mm-2.6.26-rc2-mm1.orig/mm/memcontrol.c
+++ mm-2.6.26-rc2-mm1/mm/memcontrol.c
@@ -536,28 +536,6 @@ static int mem_cgroup_charge_common(stru
 	if (mem_cgroup_subsys.disabled)
 		return 0;
 
-	/*
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
-	 */
-	if (unlikely(pc)) {
-		VM_BUG_ON(pc->page != page);
-		VM_BUG_ON(!pc->mem_cgroup);
-		unlock_page_cgroup(page);
-		goto done;
-	}
-	unlock_page_cgroup(page);
-
 	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
 	if (unlikely(pc == NULL))
 		goto err;
@@ -618,15 +596,10 @@ retry:
 	lock_page_cgroup(page);
 	if (unlikely(page_get_page_cgroup(page))) {
 		unlock_page_cgroup(page);
-		/*
-		 * Another charge has been added to this page already.
-		 * We take lock_page_cgroup(page) again and read
-		 * page->cgroup, increment refcnt.... just retry is OK.
-		 */
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
 		kmem_cache_free(page_cgroup_cache, pc);
-		goto retry;
+		goto done;
 	}
 	page_assign_page_cgroup(page, pc);
 
@@ -665,8 +638,32 @@ int mem_cgroup_charge(struct page *page,
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
+	/*
+	 * Corner case handling. This is called from add_to_page_cache()
+	 * in usual. But some FS (shmem) precharges this page before calling it
+	 * and call add_to_page_cache() with GFP_NOWAIT.
+	 *
+	 * For GFP_NOWAIT case, the page may be pre-charged before calling
+	 * add_to_page_cache(). (See shmem.c) check it here and avoid to call
+	 * charge twice. (It works but has to pay a bit larger cost.)
+	 */
+	if (!(gfp_mask & __GFP_WAIT)) {
+		struct page_cgroup *pc;
+
+		lock_page_cgroup(page);
+		pc = page_get_page_cgroup(page);
+		if (pc) {
+			VM_BUG_ON(pc->page != page);
+			VM_BUG_ON(!pc->mem_cgroup);
+			unlock_page_cgroup(page);
+			return 0;
+		}
+		unlock_page_cgroup(page);
+	}
+
 	if (unlikely(!mm))
 		mm = &init_mm;
+
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
 				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
