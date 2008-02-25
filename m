Date: Mon, 25 Feb 2008 12:16:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] radix-tree based page_cgroup. [5/7] force_empty
Message-Id: <20080225121619.03d3f9a0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Lock page and uncharge it.
This *Lock* ensures we have no race with migration.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |   34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

Index: linux-2.6.25-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/memcontrol.c
+++ linux-2.6.25-rc2/mm/memcontrol.c
@@ -31,6 +31,7 @@
 #include <linux/fs.h>
 #include <linux/seq_file.h>
 #include <linux/page_cgroup.h>
+#include <linux/pagemap.h>
 
 #include <asm/uaccess.h>
 
@@ -730,7 +731,7 @@ mem_cgroup_force_empty_list(struct mem_c
 {
 	struct page_cgroup *pc;
 	struct page *page;
-	int count;
+	int count = FORCE_UNCHARGE_BATCH;
 	unsigned long flags;
 	struct list_head *list;
 
@@ -741,28 +742,27 @@ mem_cgroup_force_empty_list(struct mem_c
 
 	if (list_empty(list))
 		return;
-retry:
-	count = FORCE_UNCHARGE_BATCH;
+
 	spin_lock_irqsave(&mz->lru_lock, flags);
 
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
+		/* check against page migration */
+		if (TestSetPageLocked(page)) {
+			mem_cgroup_uncharge_page(page);
+			unlock_page(page);
+		}
+		put_page(page);
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
