Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 239656B0261
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 11:06:59 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id j6so122970008qkc.3
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:06:59 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id a62si15725897wmc.78.2016.08.15.08.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 08:06:56 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i5so11586498wmg.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:06:56 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable-4.4 2/3] mm: memcontrol: fix swap counter leak on swapout from offline cgroup
Date: Mon, 15 Aug 2016 17:06:45 +0200
Message-Id: <1471273606-15392-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
References: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

From: Vladimir Davydov <vdavydov@virtuozzo.com>

commit 1f47b61fb4077936465dcde872a4e5cc4fe708da upstream.

An offline memory cgroup might have anonymous memory or shmem left
charged to it and no swap.  Since only swap entries pin the id of an
offline cgroup, such a cgroup will have no id and so an attempt to
swapout its anon/shmem will not store memory cgroup info in the swap
cgroup map.  As a result, memcg->swap or memcg->memsw will never get
uncharged from it and any of its ascendants.

Fix this by always charging swapout to the first ancestor cgroup that
hasn't released its id yet.

[hannes@cmpxchg.org: add comment to mem_cgroup_swapout]
[vdavydov@virtuozzo.com: use WARN_ON_ONCE() in mem_cgroup_id_get_online()]
  Link: http://lkml.kernel.org/r/20160803123445.GJ13263@esperanza
Fixes: 73f576c04b941 ("mm: memcontrol: fix cgroup creation failure after many small jobs")
Link: http://lkml.kernel.org/r/5336daa5c9a32e776067773d9da655d2dc126491.1470219853.git.vdavydov@virtuozzo.com
Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: <stable@vger.kernel.org>	[3.19+]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 37 +++++++++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2c11422f0519..f5c74c8fcfcb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4141,6 +4141,24 @@ static void mem_cgroup_id_get(struct mem_cgroup *memcg)
 	atomic_inc(&memcg->id.ref);
 }
 
+static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
+{
+	while (!atomic_inc_not_zero(&memcg->id.ref)) {
+		/*
+		 * The root cgroup cannot be destroyed, so it's refcount must
+		 * always be >= 1.
+		 */
+		if (WARN_ON_ONCE(memcg == root_mem_cgroup)) {
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
@@ -5721,7 +5739,7 @@ subsys_initcall(mem_cgroup_init);
  */
 void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 {
-	struct mem_cgroup *memcg;
+	struct mem_cgroup *memcg, *swap_memcg;
 	unsigned short oldid;
 
 	VM_BUG_ON_PAGE(PageLRU(page), page);
@@ -5736,16 +5754,27 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!memcg)
 		return;
 
-	mem_cgroup_id_get(memcg);
-	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
+	/*
+	 * In case the memcg owning these pages has been offlined and doesn't
+	 * have an ID allocated to it anymore, charge the closest online
+	 * ancestor for the swap instead and transfer the memory+swap charge.
+	 */
+	swap_memcg = mem_cgroup_id_get_online(memcg);
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
+
 	/*
 	 * Interrupts should be disabled here because the caller holds the
 	 * mapping->tree_lock lock which is taken with interrupts-off. It is
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
