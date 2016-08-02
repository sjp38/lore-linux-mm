Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 335F16B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 11:01:04 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n69so380508960ion.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 08:01:04 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0120.outbound.protection.outlook.com. [104.47.0.120])
        by mx.google.com with ESMTPS id h197si2110350oic.68.2016.08.02.08.01.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 08:01:02 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 1/3] mm: memcontrol: fix swap counter leak on swapout from offline cgroup
Date: Tue, 2 Aug 2016 18:00:48 +0300
Message-ID: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

An offline memory cgroup might have anonymous memory or shmem left
charged to it and no swap. Since only swap entries pin the id of an
offline cgroup, such a cgroup will have no id and so an attempt to
swapout its anon/shmem will not store memory cgroup info in the swap
cgroup map. As a result, memcg->swap or memcg->memsw will never get
uncharged from it and any of its ascendants.

Fix this by always charging swapout to the first ancestor cgroup that
hasn't released its id yet.

Fixes: 73f576c04b941 ("mm: memcontrol: fix cgroup creation failure after many small jobs")
Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: <stable@vger.kernel.org>	[3.19+]
---
Changes in v2:
 - handle !use_hierarchy case properly (Michal)

 mm/memcontrol.c | 38 ++++++++++++++++++++++++++++++++------
 1 file changed, 32 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3be791afd372..4ae12effe347 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4036,6 +4036,24 @@ static void mem_cgroup_id_get(struct mem_cgroup *memcg)
 	atomic_inc(&memcg->id.ref);
 }
 
+static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
+{
+	while (!atomic_inc_not_zero(&memcg->id.ref)) {
+		/*
+		 * The root cgroup cannot be destroyed, so it's refcount must
+		 * always be >= 1.
+		 */
+		if (memcg == root_mem_cgroup) {
+			VM_BUG_ON(1);
+			break;
+		}
+		memcg = parent_mem_cgroup(memcg);
+		if (!memcg)
+			memcg = root_mem_cgroup;
+	}
+	return memcg;
+}
+
 static void mem_cgroup_id_put(struct mem_cgroup *memcg)
 {
 	if (atomic_dec_and_test(&memcg->id.ref)) {
@@ -5752,7 +5770,7 @@ subsys_initcall(mem_cgroup_init);
  */
 void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 {
-	struct mem_cgroup *memcg;
+	struct mem_cgroup *memcg, *swap_memcg;
 	unsigned short oldid;
 
 	VM_BUG_ON_PAGE(PageLRU(page), page);
@@ -5767,15 +5785,20 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!memcg)
 		return;
 
-	mem_cgroup_id_get(memcg);
-	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
+	swap_memcg = mem_cgroup_id_get_active(memcg);
+	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg));
 	VM_BUG_ON_PAGE(oldid, page);
-	mem_cgroup_swap_statistics(memcg, true);
+	mem_cgroup_swap_statistics(swap_memcg, true);
 
 	page->mem_cgroup = NULL;
 
 	if (!mem_cgroup_is_root(memcg))
 		page_counter_uncharge(&memcg->memory, 1);
+	if (memcg != swap_memcg) {
+		if (!mem_cgroup_is_root(swap_memcg))
+			page_counter_charge(&swap_memcg->memsw, 1);
+		page_counter_uncharge(&memcg->memsw, 1);
+	}
 
 	/*
 	 * Interrupts should be disabled here because the caller holds the
@@ -5815,11 +5838,14 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
 	if (!memcg)
 		return 0;
 
+	memcg = mem_cgroup_id_get_active(memcg);
+
 	if (!mem_cgroup_is_root(memcg) &&
-	    !page_counter_try_charge(&memcg->swap, 1, &counter))
+	    !page_counter_try_charge(&memcg->swap, 1, &counter)) {
+		mem_cgroup_id_put(memcg);
 		return -ENOMEM;
+	}
 
-	mem_cgroup_id_get(memcg);
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
 	VM_BUG_ON_PAGE(oldid, page);
 	mem_cgroup_swap_statistics(memcg, true);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
