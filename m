Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id C85846B0073
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:22:22 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pv20so4098835lab.6
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 08:22:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l3si14761341laf.89.2014.10.20.08.22.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 08:22:21 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/4] mm: memcontrol: remove unnecessary PCG_MEMSW memory+swap charge flag
Date: Mon, 20 Oct 2014 11:22:10 -0400
Message-Id: <1413818532-11042-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
References: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Now that mem_cgroup_swapout() fully uncharges the page, every page
that is still in use when reaching mem_cgroup_uncharge() is known to
carry both the memory and the memory+swap charge.  Simplify the
uncharge path and remove the PCG_MEMSW page flag accordingly.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/page_cgroup.h |  1 -
 mm/memcontrol.c             | 34 ++++++++++++----------------------
 2 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 5c831f1eca79..da62ee2be28b 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -5,7 +5,6 @@ enum {
 	/* flags for mem_cgroup */
 	PCG_USED = 0x01,	/* This page is charged to a memcg */
 	PCG_MEM = 0x02,		/* This page holds a memory charge */
-	PCG_MEMSW = 0x04,	/* This page holds a memory+swap charge */
 };
 
 struct pglist_data;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7709f17347f3..9bab35fc3e9e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2606,7 +2606,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 	 *   have the page locked
 	 */
 	pc->mem_cgroup = memcg;
-	pc->flags = PCG_USED | PCG_MEM | (do_swap_account ? PCG_MEMSW : 0);
+	pc->flags = PCG_USED | PCG_MEM;
 
 	if (lrucare)
 		unlock_page_lru(page, isolated);
@@ -5815,7 +5815,6 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!PageCgroupUsed(pc))
 		return;
 
-	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), page);
 	memcg = pc->mem_cgroup;
 
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
@@ -6010,17 +6009,16 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg)
 }
 
 static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
-			   unsigned long nr_mem, unsigned long nr_memsw,
 			   unsigned long nr_anon, unsigned long nr_file,
 			   unsigned long nr_huge, struct page *dummy_page)
 {
+	unsigned long nr_pages = nr_anon + nr_file;
 	unsigned long flags;
 
 	if (!mem_cgroup_is_root(memcg)) {
-		if (nr_mem)
-			page_counter_uncharge(&memcg->memory, nr_mem);
-		if (nr_memsw)
-			page_counter_uncharge(&memcg->memsw, nr_memsw);
+		page_counter_uncharge(&memcg->memory, nr_pages);
+		if (do_swap_account)
+			page_counter_uncharge(&memcg->memsw, nr_pages);
 		memcg_oom_recover(memcg);
 	}
 
@@ -6029,23 +6027,21 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_CACHE], nr_file);
 	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE], nr_huge);
 	__this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT], pgpgout);
-	__this_cpu_add(memcg->stat->nr_page_events, nr_anon + nr_file);
+	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
 	memcg_check_events(memcg, dummy_page);
 	local_irq_restore(flags);
 
 	if (!mem_cgroup_is_root(memcg))
-		css_put_many(&memcg->css, max(nr_mem, nr_memsw));
+		css_put_many(&memcg->css, nr_pages);
 }
 
 static void uncharge_list(struct list_head *page_list)
 {
 	struct mem_cgroup *memcg = NULL;
-	unsigned long nr_memsw = 0;
 	unsigned long nr_anon = 0;
 	unsigned long nr_file = 0;
 	unsigned long nr_huge = 0;
 	unsigned long pgpgout = 0;
-	unsigned long nr_mem = 0;
 	struct list_head *next;
 	struct page *page;
 
@@ -6072,10 +6068,9 @@ static void uncharge_list(struct list_head *page_list)
 
 		if (memcg != pc->mem_cgroup) {
 			if (memcg) {
-				uncharge_batch(memcg, pgpgout, nr_mem, nr_memsw,
-					       nr_anon, nr_file, nr_huge, page);
-				pgpgout = nr_mem = nr_memsw = 0;
-				nr_anon = nr_file = nr_huge = 0;
+				uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
+					       nr_huge, page);
+				pgpgout = nr_anon = nr_file = nr_huge = 0;
 			}
 			memcg = pc->mem_cgroup;
 		}
@@ -6091,18 +6086,14 @@ static void uncharge_list(struct list_head *page_list)
 		else
 			nr_file += nr_pages;
 
-		if (pc->flags & PCG_MEM)
-			nr_mem += nr_pages;
-		if (pc->flags & PCG_MEMSW)
-			nr_memsw += nr_pages;
 		pc->flags = 0;
 
 		pgpgout++;
 	} while (next != page_list);
 
 	if (memcg)
-		uncharge_batch(memcg, pgpgout, nr_mem, nr_memsw,
-			       nr_anon, nr_file, nr_huge, page);
+		uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
+			       nr_huge, page);
 }
 
 /**
@@ -6187,7 +6178,6 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 		return;
 
 	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
-	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
 
 	if (lrucare)
 		lock_page_lru(oldpage, &isolated);
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
