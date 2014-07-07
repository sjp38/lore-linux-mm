Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 87E3E900002
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 14:52:24 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id q58so4902348wes.16
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 11:52:24 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id 13si17880173wjs.86.2014.07.07.11.52.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 11:52:23 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] mm: memcontrol: rewrite uncharge API fix - double migration
Date: Mon,  7 Jul 2014 14:52:12 -0400
Message-Id: <1404759133-29218-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1404759133-29218-1-git-send-email-hannes@cmpxchg.org>
References: <1404759133-29218-1-git-send-email-hannes@cmpxchg.org>
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

Catch pages that have already been migrated and abort migration
gracefully.

Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1e3b27f8dc2f..e4afdbdda0a7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6653,7 +6653,10 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	if (!PageCgroupUsed(pc))
 		return;
 
-	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
+	/* Already migrated */
+	if (!(pc->flags & PCG_MEM))
+		return;
+
 	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
 	pc->flags &= ~(PCG_MEM | PCG_MEMSW);
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
