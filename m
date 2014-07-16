Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 652846B00BA
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 12:20:16 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id k48so3035wev.26
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:20:15 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ni12si21232322wic.49.2014.07.16.09.20.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 09:20:15 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch v2] mm: memcontrol: rewrite uncharge API fix - double migration
Date: Wed, 16 Jul 2014 12:19:56 -0400
Message-Id: <1405527596-7267-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hugh reports:

VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM))
mm/memcontrol.c:6680!
page had count 1 mapcount 0 mapping anon index 0x196
flags locked uptodate reclaim swapbacked, pcflags 1, memcg not root
mem_cgroup_migrate < move_to_new_page < migrate_pages < compact_zone <
compact_zone_order < try_to_compact_pages < __alloc_pages_direct_compact <
__alloc_pages_nodemask < alloc_pages_vma < do_huge_pmd_anonymous_page <
handle_mm_fault < __do_page_fault

mem_cgroup_migrate() assumes that a page is only migrated once and
then freed immediately after.

However, putting the page back on the LRU list and dropping the
isolation refcount is not done atomically.  This allows a PFN-based
migrator like compaction to isolate the page, see the expected
anonymous page refcount of 1, and migrate the page once more.

Properly uncharge the page after it's been migrated, including the
clearing of PCG_USED, so that a subsequent charge migration attempt
will be able to detect it and bail out.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reported-by: Hugh Dickins <hughd@google.com>
---
 mm/memcontrol.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

Andrew, this replaces the patch of the same name in -mm.  As Hugh
points out, we really have to clear PCG_USED of migrated pages, as
they are no longer pinning the memcg and so their pc->mem_cgroup can
no longer be trusted.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1e3b27f8dc2f..1439537fe7c9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6655,7 +6655,6 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 
 	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
 	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
-	pc->flags &= ~(PCG_MEM | PCG_MEMSW);
 
 	if (PageTransHuge(oldpage)) {
 		nr_pages <<= compound_order(oldpage);
@@ -6663,6 +6662,13 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 		VM_BUG_ON_PAGE(!PageTransHuge(newpage), newpage);
 	}
 
+	pc->flags = 0;
+
+	local_irq_disable();
+	mem_cgroup_charge_statistics(pc->mem_cgroup, oldpage, -nr_pages);
+	memcg_check_events(pc->mem_cgroup, oldpage);
+	local_irq_enable();
+
 	commit_charge(newpage, pc->mem_cgroup, nr_pages, lrucare);
 }
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
