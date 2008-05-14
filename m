Date: Wed, 14 May 2008 17:04:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH 1/6] memcg: drop_pages at force_empty.
Message-Id: <20080514170459.ec03d1fd.kamezawa.hiroyu@jp.fujitsu.com>
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

This is NEW one ;)
==
Now, when we remove memcg, we call force_empty().
This call drops all page_cgroup accounting in this mem_cgroup but doesn't
drop pages. So, some page caches can be remaind as "not accounted" memory
while they are alive. (because it's accounted only when add_to_page_cache())
If they are not used by other memcg, global LRU will drop them.

This patch tries to drop pages at removing memcg. Other memcg will
reload and re-account page caches.

Consideration: should we add knob to drop pages or not?

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/res_counter.h |   11 +++++++++++
 mm/memcontrol.c             |   21 ++++++++++++++++++---
 2 files changed, 29 insertions(+), 3 deletions(-)

Index: linux-2.6.26-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/memcontrol.c
+++ linux-2.6.26-rc2/mm/memcontrol.c
@@ -763,6 +763,20 @@ void mem_cgroup_end_migration(struct pag
 	mem_cgroup_uncharge_page(newpage);
 }
 
+
+static void mem_cgroup_drop_all_page(struct mem_cgroup *mem)
+{
+	int progress;
+	while (res_counter_check_empty(&mem->res)) {
+		progress = try_to_free_mem_cgroup_pages(mem,
+					GFP_HIGHUSER_MOVABLE);
+		if (!progress) /* we did as much as possible */
+			break;
+		cond_resched();
+	}
+	return;
+}
+
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * This routine ignores page_cgroup->ref_cnt.
@@ -820,7 +834,12 @@ static int mem_cgroup_force_empty(struct
 	if (mem_cgroup_subsys.disabled)
 		return 0;
 
+	if (atomic_read(&mem->css.cgroup->count) > 0)
+		goto out;
+
 	css_get(&mem->css);
+	/* drop pages as much as possible */
+	mem_cgroup_drop_all_pages(mem);
 	/*
 	 * page reclaim code (kswapd etc..) will move pages between
 	 * active_list <-> inactive_list while we don't take a lock.
Index: linux-2.6.26-rc2/include/linux/res_counter.h
===================================================================
--- linux-2.6.26-rc2.orig/include/linux/res_counter.h
+++ linux-2.6.26-rc2/include/linux/res_counter.h
@@ -151,4 +151,15 @@ static inline void res_counter_reset_fai
 	cnt->failcnt = 0;
 	spin_unlock_irqrestore(&cnt->lock, flags);
 }
+
+static inline int res_counter_check_empty(struct res_counter *cnt)
+{
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	ret = (cnt->usage == 0);
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
