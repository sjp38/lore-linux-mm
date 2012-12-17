Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 0CC366B0068
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 13:13:46 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 7/7] mm: reduce rmap overhead for ex-KSM page copies created on swap faults
Date: Mon, 17 Dec 2012 13:12:37 -0500
Message-Id: <1355767957-4913-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
References: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When ex-KSM pages are faulted from swap cache, the fault handler is
not capable of re-establishing anon_vma-spanning KSM pages.  In this
case, a copy of the page is created instead, just like during a COW
break.

These freshly made copies are known to be exclusive to the faulting
VMA and there is no reason to go look for this page in parent and
sibling processes during rmap operations.

Use page_add_new_anon_rmap() for these copies.  This also puts them on
the proper LRU lists and marks them SwapBacked, so we can get rid of
doing this ad-hoc in the KSM copy code.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/ksm.c    | 6 ------
 mm/memory.c | 5 ++++-
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 382d930..7275c74 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1590,13 +1590,7 @@ struct page *ksm_does_need_to_copy(struct page *page,
 
 		SetPageDirty(new_page);
 		__SetPageUptodate(new_page);
-		SetPageSwapBacked(new_page);
 		__set_page_locked(new_page);
-
-		if (!mlocked_vma_newpage(vma, new_page))
-			lru_cache_add_lru(new_page, LRU_ACTIVE_ANON);
-		else
-			add_page_to_unevictable_list(new_page);
 	}
 
 	return new_page;
diff --git a/mm/memory.c b/mm/memory.c
index db2e9e7..7e17eb0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3020,7 +3020,10 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 	flush_icache_page(vma, page);
 	set_pte_at(mm, address, page_table, pte);
-	do_page_add_anon_rmap(page, vma, address, exclusive);
+	if (swapcache) /* ksm created a completely new copy */
+		page_add_new_anon_rmap(page, vma, address);
+	else
+		do_page_add_anon_rmap(page, vma, address, exclusive);
 	/* It's better to call commit-charge after rmap is established */
 	mem_cgroup_commit_charge_swapin(page, ptr);
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
