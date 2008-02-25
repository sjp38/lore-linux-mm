Date: Mon, 25 Feb 2008 23:47:10 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 12/15] memcg: css_put after remove_list
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252346280.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mem_cgroup_uncharge_page does css_put on the mem_cgroup before uncharging
from it, and before removing page_cgroup from one of its lru lists: isn't
there a danger that struct mem_cgroup memory could be freed and reused
before completing that, so corrupting something?  Never seen it, and
for all I know there may be other constraints which make it impossible;
but let's be defensive and reverse the ordering there.

mem_cgroup_force_empty_list is safe because there's an extra css_get
around all its works; but even so, change its ordering the same way
round, to help get in the habit of doing it like this.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memcontrol.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- memcg11/mm/memcontrol.c	2008-02-25 14:06:16.000000000 +0000
+++ memcg12/mm/memcontrol.c	2008-02-25 14:06:21.000000000 +0000
@@ -665,15 +665,15 @@ void mem_cgroup_uncharge_page(struct pag
 		page_assign_page_cgroup(page, NULL);
 		unlock_page_cgroup(page);
 
-		mem = pc->mem_cgroup;
-		css_put(&mem->css);
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock_irqsave(&mz->lru_lock, flags);
 		__mem_cgroup_remove_list(pc);
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
 
+		mem = pc->mem_cgroup;
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		css_put(&mem->css);
+
 		kfree(pc);
 		return;
 	}
@@ -774,9 +774,9 @@ retry:
 		if (page_get_page_cgroup(page) == pc) {
 			page_assign_page_cgroup(page, NULL);
 			unlock_page_cgroup(page);
-			css_put(&mem->css);
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
 			__mem_cgroup_remove_list(pc);
+			res_counter_uncharge(&mem->res, PAGE_SIZE);
+			css_put(&mem->css);
 			kfree(pc);
 		} else {
 			/* racing uncharge: let page go then retry */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
