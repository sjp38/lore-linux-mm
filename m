Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 293C8600794
	for <linux-mm@kvack.org>; Mon,  3 May 2010 11:22:44 -0400 (EDT)
Received: by pzk28 with SMTP id 28so860606pzk.11
        for <linux-mm@kvack.org>; Mon, 03 May 2010 08:22:31 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Subject: [PATCH] Cleanup migrate case in try_to_unmap_one
Date: Mon,  3 May 2010 20:49:17 +0530
Message-Id: <1272899957-11604-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Remove duplicate handling of TTU_MIGRATE case for
anonymous and filesystem pages.

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
---
 mm/rmap.c |   17 ++++-------------
 1 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 07fc947..8ccfe4a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -946,6 +946,10 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			dec_mm_counter(mm, MM_FILEPAGES);
 		set_pte_at(mm, address, pte,
 				swp_entry_to_pte(make_hwpoison_entry(page)));
+	} else if (PAGE_MIGRATION && (TTU_ACTION(flags) == TTU_MIGRATION)) {
+		swp_entry_t entry;
+		entry = make_migration_entry(page, pte_write(pteval));
+		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 
@@ -967,22 +971,9 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			}
 			dec_mm_counter(mm, MM_ANONPAGES);
 			inc_mm_counter(mm, MM_SWAPENTS);
-		} else if (PAGE_MIGRATION) {
-			/*
-			 * Store the pfn of the page in a special migration
-			 * pte. do_swap_page() will wait until the migration
-			 * pte is removed and then restart fault handling.
-			 */
-			BUG_ON(TTU_ACTION(flags) != TTU_MIGRATION);
-			entry = make_migration_entry(page, pte_write(pteval));
 		}
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));
-	} else if (PAGE_MIGRATION && (TTU_ACTION(flags) == TTU_MIGRATION)) {
-		/* Establish migration entry for a file page */
-		swp_entry_t entry;
-		entry = make_migration_entry(page, pte_write(pteval));
-		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 	} else
 		dec_mm_counter(mm, MM_FILEPAGES);
 
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
