Date: Tue, 1 Apr 2008 17:33:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [-mm][PATCH 4/6] remove unnecessary page_cgroup_zoneinfo
Message-Id: <20080401173303.1a0cda04.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080401172837.2c92000d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080401172837.2c92000d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, menage@google.com
List-ID: <linux-mm.kvack.org>

page_cgroup_zoneinfo() is called twice before and after lock.
This is wasteful.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

Index: mm-2.6.25-rc5-mm1-k/mm/memcontrol.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/memcontrol.c
+++ mm-2.6.25-rc5-mm1-k/mm/memcontrol.c
@@ -230,10 +230,10 @@ void mm_free_cgroup(struct mm_struct *mm
 	css_put(&mm->mem_cgroup->css);
 }
 
-static void __mem_cgroup_remove_list(struct page_cgroup *pc)
+static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
+			struct page_cgroup *pc)
 {
 	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
-	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
 
 	if (from)
 		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) -= 1;
@@ -244,10 +244,10 @@ static void __mem_cgroup_remove_list(str
 	list_del_init(&pc->lru);
 }
 
-static void __mem_cgroup_add_list(struct page_cgroup *pc)
+static void __mem_cgroup_add_list(struct mem_cgroup_per_zone *mz,
+			struct page_cgroup *pc)
 {
 	int to = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
-	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
 
 	if (!to) {
 		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) += 1;
@@ -573,7 +573,7 @@ static int mem_cgroup_charge_common(stru
 	mz = page_cgroup_zoneinfo(pc);
 
 	spin_lock(&mz->lru_lock);
-	__mem_cgroup_add_list(pc);
+	__mem_cgroup_add_list(mz, pc);
 	spin_unlock(&mz->lru_lock);
 	spin_unlock_irqrestore(&pc->lock, flags);
 
@@ -623,10 +623,10 @@ void mem_cgroup_uncharge_page(struct pag
 			spin_unlock_irqrestore(&pc->lock, flags);
 			return;
 		}
-		mem = pc->mem_cgroup;
 		mz = page_cgroup_zoneinfo(pc);
+		mem = pc->mem_cgroup;
 		spin_lock(&mz->lru_lock);
-		__mem_cgroup_remove_list(pc);
+		__mem_cgroup_remove_list(mz, pc);
 		spin_unlock(&mz->lru_lock);
 		pc->flags = 0;
 		pc->mem_cgroup = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
