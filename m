Date: Wed, 20 Feb 2008 17:32:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Clean up force_empty (Was Re: [RFC][PATCH] Clarify mem_cgroup lock
 handling and avoid races.)
Message-Id: <20080220173222.3d376a0b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802191449490.6254@blonde.site>
	<20080220.152753.98212356.taka@valinux.co.jp>
	<20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

How about this ?
I tested Takahashi's one and added comments.
I like this but it's okay just to wait and revisit this later.
-Kame
=

Clean up force_empty.

This patch makes force_empty to be not a special function.

Old one used customized freeing loop. This one uses mem_cgroup_uncharge()
one by one. 

Signed-off-by: Hirokazu Takahashi <taka@vallinux.co.jp>
Tested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 mm/memcontrol.c |   39 +++++++++++++++++++--------------------
 1 file changed, 19 insertions(+), 20 deletions(-)

Index: linux-2.6.25-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/memcontrol.c
+++ linux-2.6.25-rc2/mm/memcontrol.c
@@ -837,7 +837,7 @@ mem_cgroup_force_empty_list(struct mem_c
 {
 	struct page_cgroup *pc;
 	struct page *page;
-	int count;
+	int count = FORCE_UNCHARGE_BATCH;
 	unsigned long flags;
 	struct list_head *list;
 
@@ -846,30 +846,29 @@ mem_cgroup_force_empty_list(struct mem_c
 	else
 		list = &mz->inactive_list;
 
-	if (list_empty(list))
-		return;
-retry:
-	count = FORCE_UNCHARGE_BATCH;
 	spin_lock_irqsave(&mz->lru_lock, flags);
-
-	while (--count && !list_empty(list)) {
+	while (!list_empty(list)) {
 		pc = list_entry(list->prev, struct page_cgroup, lru);
 		page = pc->page;
-		/* Avoid race with charge */
-		atomic_set(&pc->ref_cnt, 0);
-		if (clear_page_cgroup(page, pc) == pc) {
-			css_put(&mem->css);
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			__mem_cgroup_remove_list(pc);
-			kfree(pc);
-		} else 	/* being uncharged ? ...do relax */
-			break;
+		get_page(page);
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+
+		lock_page_cgroup(page);
+		/* Because we released lock, we have to chack the page still
+		   points this pc. */
+		if (page_get_page_cgroup(page) == pc)
+			mem_cgroup_uncharge(pc);
+		unlock_page_cgroup(page);
+
+		put_page(page);
+
+		if (--count == 0) {
+			count = FORCE_UNCHARGE_BATCH;
+			cond_resched();
+		}
+		spin_lock_irqsave(&mz->lru_lock, flags);
 	}
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	if (!list_empty(list)) {
-		cond_resched();
-		goto retry;
-	}
 	return;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
