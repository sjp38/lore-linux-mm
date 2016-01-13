Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 983BB828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 16:52:37 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id f206so313812479wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 13:52:37 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i8si7058611wma.50.2016.01.13.13.52.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 13:52:36 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: memcontrol: do not uncharge old page in page cache replacement
Date: Wed, 13 Jan 2016 16:51:57 -0500
Message-Id: <1452721917-24614-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Changing page->mem_cgroup of a live page is tricky and fragile. In
particular, the memcg writeback code relies on that mapping being
stable and users of mem_cgroup_replace_page() not overlapping with
dirtyable inodes.

Page cache replacement doesn't have to do that, though. Instead of
being clever and transfering the charge from the old page to the new,
force-charge the new page and leave the old page alone. A temporary
overcharge won't matter in practice, and the old page is going to be
freed shortly after this anyway. And this is not performance critical.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d75028d..c26ffac 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -366,13 +366,6 @@ mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
  *
  * If memcg is bound to a traditional hierarchy, the css of root_mem_cgroup
  * is returned.
- *
- * XXX: The above description of behavior on the default hierarchy isn't
- * strictly true yet as replace_page_cache_page() can modify the
- * association before @page is released even on the default hierarchy;
- * however, the current and planned usages don't mix the the two functions
- * and replace_page_cache_page() will soon be updated to make the invariant
- * actually true.
  */
 struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
 {
@@ -5463,7 +5456,8 @@ void mem_cgroup_uncharge_list(struct list_head *page_list)
 void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 {
 	struct mem_cgroup *memcg;
-	int isolated;
+	unsigned int nr_pages;
+	bool compound;
 
 	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
@@ -5483,11 +5477,21 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 	if (!memcg)
 		return;
 
-	lock_page_lru(oldpage, &isolated);
-	oldpage->mem_cgroup = NULL;
-	unlock_page_lru(oldpage, isolated);
+	/* Force-charge the new page. The old one will be freed soon */
+	compound = PageTransHuge(newpage);
+	nr_pages = compound ? hpage_nr_pages(newpage) : 1;
+
+	page_counter_charge(&memcg->memory, nr_pages);
+	if (do_memsw_account())
+		page_counter_charge(&memcg->memsw, nr_pages);
+	css_get_many(&memcg->css, nr_pages);
 
 	commit_charge(newpage, memcg, true);
+
+	local_irq_disable();
+	mem_cgroup_charge_statistics(memcg, newpage, compound, nr_pages);
+	memcg_check_events(memcg, newpage);
+	local_irq_enable();
 }
 
 DEFINE_STATIC_KEY_FALSE(memcg_sockets_enabled_key);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
