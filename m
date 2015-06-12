Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF896B006E
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 05:53:03 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so20147451pac.2
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 02:53:03 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id wj1si4643447pab.152.2015.06.12.02.53.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 02:53:02 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v6 3/6] memcg: zap try_get_mem_cgroup_from_page
Date: Fri, 12 Jun 2015 12:52:23 +0300
Message-ID: <b1e1f810af5c39bec3a05281fac10459f09df923.1434102076.git.vdavydov@parallels.com>
In-Reply-To: <cover.1434102076.git.vdavydov@parallels.com>
References: <cover.1434102076.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

It is only used in mem_cgroup_try_charge, so fold it in and zap it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |  6 ------
 mm/memcontrol.c            | 48 ++++++++++++----------------------------------
 2 files changed, 12 insertions(+), 42 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 50069abebc3c..635edfe06bac 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -94,7 +94,6 @@ bool mem_cgroup_is_descendant(struct mem_cgroup *memcg,
 			      struct mem_cgroup *root);
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
 
-extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
 extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
@@ -259,11 +258,6 @@ static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
 	return &zone->lruvec;
 }
 
-static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
-{
-	return NULL;
-}
-
 static inline bool mm_match_cgroup(struct mm_struct *mm,
 		struct mem_cgroup *memcg)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 894dc2169979..fa1447fcba33 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2378,40 +2378,6 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
 	css_put_many(&memcg->css, nr_pages);
 }
 
-/*
- * try_get_mem_cgroup_from_page - look up page's memcg association
- * @page: the page
- *
- * Look up, get a css reference, and return the memcg that owns @page.
- *
- * The page must be locked to prevent racing with swap-in and page
- * cache charges.  If coming from an unlocked page table, the caller
- * must ensure the page is on the LRU or this can race with charging.
- */
-struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
-{
-	struct mem_cgroup *memcg;
-	unsigned short id;
-	swp_entry_t ent;
-
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-
-	memcg = page->mem_cgroup;
-	if (memcg) {
-		if (!css_tryget_online(&memcg->css))
-			memcg = NULL;
-	} else if (PageSwapCache(page)) {
-		ent.val = page_private(page);
-		id = lookup_swap_cgroup_id(ent);
-		rcu_read_lock();
-		memcg = mem_cgroup_from_id(id);
-		if (memcg && !css_tryget_online(&memcg->css))
-			memcg = NULL;
-		rcu_read_unlock();
-	}
-	return memcg;
-}
-
 static void lock_page_lru(struct page *page, int *isolated)
 {
 	struct zone *zone = page_zone(page);
@@ -5628,8 +5594,20 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 		 * the page lock, which serializes swap cache removal, which
 		 * in turn serializes uncharging.
 		 */
+		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		if (page->mem_cgroup)
 			goto out;
+
+		if (do_swap_account) {
+			swp_entry_t ent = { .val = page_private(page), };
+			unsigned short id = lookup_swap_cgroup_id(ent);
+
+			rcu_read_lock();
+			memcg = mem_cgroup_from_id(id);
+			if (memcg && !css_tryget_online(&memcg->css))
+				memcg = NULL;
+			rcu_read_unlock();
+		}
 	}
 
 	if (PageTransHuge(page)) {
@@ -5637,8 +5615,6 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 	}
 
-	if (do_swap_account && PageSwapCache(page))
-		memcg = try_get_mem_cgroup_from_page(page);
 	if (!memcg)
 		memcg = get_mem_cgroup_from_mm(mm);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
