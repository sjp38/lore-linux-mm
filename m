Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 49B23900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 02:15:58 -0400 (EDT)
Received: by padj3 with SMTP id j3so188112pad.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 23:15:58 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id b5si30083057pdn.44.2015.06.02.23.15.52
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 23:15:53 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 1/6] mm: keep dirty bit on KSM page
Date: Wed,  3 Jun 2015 15:15:40 +0900
Message-Id: <1433312145-19386-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1433312145-19386-1-git-send-email-minchan@kernel.org>
References: <1433312145-19386-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

I encountered segfault of test program while I tested MADV_FREE
with KSM. By investigation,

1. A KSM page is mapped on page table of A, B processes with
   !pte_dirty(but it marked the page as PG_dirty if pte_dirty is on)

2. MADV_FREE of A process can remove the page from swap cache
   if it was in there and then clear *PG_dirty* to indicate we could
   discard it instead of swapping out.

3. So, the KSM page's status is !pte_dirty of A, B processes &&
   !PageDirty.

4. VM judges it as freeable page and discard it.

5. Process B encounters segfault even though B didn't call MADV_FREE.

Clearing PG_dirty after anonymous page is removed from swap cache
was no problem on integrity POV for private page(ie, normal anon page,
not KSM). Just worst case caused by that was unnecessary write out
which we have avoided it if same data is already on swap.

However, with introducing MADV_FREE, it could make above problem
so this patch fixes it with keeping dirty bit of the page table
when the page is replaced with KSM page.

Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/ksm.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index bc7be0ee2080..9c07346e57f2 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -901,9 +901,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 			set_pte_at(mm, addr, ptep, entry);
 			goto out_unlock;
 		}
-		if (pte_dirty(entry))
-			set_page_dirty(page);
-		entry = pte_mkclean(pte_wrprotect(entry));
+
+		entry = pte_wrprotect(entry);
 		set_pte_at_notify(mm, addr, ptep, entry);
 	}
 	*orig_pte = *ptep;
@@ -932,11 +931,13 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	struct mm_struct *mm = vma->vm_mm;
 	pmd_t *pmd;
 	pte_t *ptep;
+	pte_t entry;
 	spinlock_t *ptl;
 	unsigned long addr;
 	int err = -EFAULT;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	bool dirty;
 
 	addr = page_address_in_vma(page, vma);
 	if (addr == -EFAULT)
@@ -956,12 +957,22 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 		goto out_mn;
 	}
 
+	dirty = pte_dirty(*ptep);
 	get_page(kpage);
 	page_add_anon_rmap(kpage, vma, addr);
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush_notify(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+
+	entry = mk_pte(kpage, vma->vm_page_prot);
+	/*
+	 * Keep a dirty bit to prevent a KSM page sudden freeing
+	 * by MADV_FREE.
+	 */
+	if (dirty)
+		entry = pte_mkdirty(entry);
+
+	set_pte_at_notify(mm, addr, ptep, entry);
 
 	page_remove_rmap(page);
 	if (!page_mapped(page))
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
