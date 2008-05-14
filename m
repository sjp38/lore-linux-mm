Date: Wed, 14 May 2008 17:10:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH 4/6] memcg: shmem reclaim helper
Message-Id: <20080514171025.2f0fb1ca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080514170236.23c9ddd7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080514170236.23c9ddd7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

A new call, mem_cgroup_shrink_usage() is added for shmem handling
and removing not usual usage of mem_cgroup_charge/uncharge.

Now, shmem calls mem_cgroup_charge() just for reclaim some pages from
mem_cgroup. In general, shmem is used by some process group and not for
global resource (like file caches). So, it's reasonable to reclaim pages from
mem_cgroup where shmem is mainly used.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

Index: linux-2.6.26-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/memcontrol.c
+++ linux-2.6.26-rc2/mm/memcontrol.c
@@ -783,6 +783,30 @@ static void mem_cgroup_drop_all_pages(st
 }
 
 /*
+ * A call to try to shrink memory usage under specified resource controller.
+ * This is typically used for page reclaiming for shmem for reducing side
+ * effect of page allocation from shmem, which is used by some mem_cgroup.
+ */
+int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask)
+{
+	struct mem_cgroup *mem;
+	int progress = 0;
+	int retry = MEM_CGROUP_RECLAIM_RETRIES;
+
+	rcu_read_lock();
+	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	css_get(&mem->css);
+	rcu_read_unlock();
+
+	while(!progress && --retry) {
+		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask);
+	}
+	if (!retry)
+		return -ENOMEM;
+	return 0;
+}
+
+/*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
Index: linux-2.6.26-rc2/mm/shmem.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/shmem.c
+++ linux-2.6.26-rc2/mm/shmem.c
@@ -1314,13 +1314,12 @@ repeat:
 			unlock_page(swappage);
 			if (error == -ENOMEM) {
 				/* allow reclaim from this memory cgroup */
-				error = mem_cgroup_cache_charge(swappage,
-					current->mm, gfp & ~__GFP_HIGHMEM);
+				error = mem_cgroup_shrink_usage(current->mm,
+					gfp & ~__GFP_HIGHMEM);
 				if (error) {
 					page_cache_release(swappage);
 					goto failed;
 				}
-				mem_cgroup_uncharge_cache_page(swappage);
 			}
 			page_cache_release(swappage);
 			goto repeat;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
