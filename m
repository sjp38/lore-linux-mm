Date: Mon, 28 Apr 2008 20:30:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 6/8] memcg: remove redundant initilization
Message-Id: <20080428203009.6d300ff4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

1. Remove over-killing initializations.
2. makes flag initialization clearer.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: mm-2.6.25-mm1/mm/memcontrol.c
===================================================================
--- mm-2.6.25-mm1.orig/mm/memcontrol.c
+++ mm-2.6.25-mm1/mm/memcontrol.c
@@ -287,7 +287,7 @@ static void __mem_cgroup_remove_list(str
 		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) -= 1;
 
 	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, false);
-	list_del_init(&pc->lru);
+	list_del(&pc->lru);
 }
 
 static void __mem_cgroup_add_list(struct mem_cgroup_per_zone *mz,
@@ -549,10 +549,9 @@ retry:
 	}
 	unlock_page_cgroup(page);
 
-	pc = kmem_cache_zalloc(page_cgroup_cache, gfp_mask);
+	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
 	if (unlikely(!pc))
 		goto err;
-
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
@@ -597,9 +596,10 @@ retry:
 
 	pc->mem_cgroup = mem;
 	pc->page = page;
-	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
 		pc->flags = PAGE_CGROUP_FLAG_CACHE;
+	else
+		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 
 	lock_page_cgroup(page);
 	if (unlikely(page_get_page_cgroup(page))) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
