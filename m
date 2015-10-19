Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id BA99682F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 01:05:34 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so82995889pac.3
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 22:05:34 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id ut11si49856926pab.37.2015.10.18.22.05.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 22:05:34 -0700 (PDT)
Received: by pasz6 with SMTP id z6so18445412pas.2
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 22:05:33 -0700 (PDT)
Date: Sun, 18 Oct 2015 22:05:28 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 10/12] mm: page migration use migration entry for swapcache
 too
In-Reply-To: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510182203200.2481@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org

Hitherto page migration has avoided using a migration entry for a
swapcache page mapped into userspace, apparently for historical reasons.
So any page blessed with swapcache would entail a minor fault when it's
next touched, which page migration otherwise tries to avoid.  Swapcache
in an mlocked area is rare, so won't often matter, but still better fixed.

Just rearrange the block in try_to_unmap_one(), to handle TTU_MIGRATION
before checking PageAnon, that's all (apart from some reindenting).

Well, no, that's not quite all: doesn't this by the way fix a soft_dirty
bug, that page migration of a file page was forgetting to transfer the
soft_dirty bit?  Probably not a serious bug: if I understand correctly,
soft_dirty afficionados usually have to handle file pages separately
anyway; but we publish the bit in /proc/<pid>/pagemap on file mappings
as well as anonymous, so page migration ought not to perturb it.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/rmap.c |   63 ++++++++++++++++++++++++----------------------------
 1 file changed, 30 insertions(+), 33 deletions(-)

--- migrat.orig/mm/rmap.c	2015-10-18 17:53:07.099317502 -0700
+++ migrat/mm/rmap.c	2015-10-18 17:53:29.244342714 -0700
@@ -1377,47 +1377,44 @@ static int try_to_unmap_one(struct page
 			dec_mm_counter(mm, MM_ANONPAGES);
 		else
 			dec_mm_counter(mm, MM_FILEPAGES);
+	} else if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION)) {
+		swp_entry_t entry;
+		pte_t swp_pte;
+		/*
+		 * Store the pfn of the page in a special migration
+		 * pte. do_swap_page() will wait until the migration
+		 * pte is removed and then restart fault handling.
+		 */
+		entry = make_migration_entry(page, pte_write(pteval));
+		swp_pte = swp_entry_to_pte(entry);
+		if (pte_soft_dirty(pteval))
+			swp_pte = pte_swp_mksoft_dirty(swp_pte);
+		set_pte_at(mm, address, pte, swp_pte);
 	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 		pte_t swp_pte;
-
-		if (PageSwapCache(page)) {
-			/*
-			 * Store the swap location in the pte.
-			 * See handle_pte_fault() ...
-			 */
-			if (swap_duplicate(entry) < 0) {
-				set_pte_at(mm, address, pte, pteval);
-				ret = SWAP_FAIL;
-				goto out_unmap;
-			}
-			if (list_empty(&mm->mmlist)) {
-				spin_lock(&mmlist_lock);
-				if (list_empty(&mm->mmlist))
-					list_add(&mm->mmlist, &init_mm.mmlist);
-				spin_unlock(&mmlist_lock);
-			}
-			dec_mm_counter(mm, MM_ANONPAGES);
-			inc_mm_counter(mm, MM_SWAPENTS);
-		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
-			/*
-			 * Store the pfn of the page in a special migration
-			 * pte. do_swap_page() will wait until the migration
-			 * pte is removed and then restart fault handling.
-			 */
-			BUG_ON(!(flags & TTU_MIGRATION));
-			entry = make_migration_entry(page, pte_write(pteval));
+		/*
+		 * Store the swap location in the pte.
+		 * See handle_pte_fault() ...
+		 */
+		VM_BUG_ON_PAGE(!PageSwapCache(page), page);
+		if (swap_duplicate(entry) < 0) {
+			set_pte_at(mm, address, pte, pteval);
+			ret = SWAP_FAIL;
+			goto out_unmap;
 		}
+		if (list_empty(&mm->mmlist)) {
+			spin_lock(&mmlist_lock);
+			if (list_empty(&mm->mmlist))
+				list_add(&mm->mmlist, &init_mm.mmlist);
+			spin_unlock(&mmlist_lock);
+		}
+		dec_mm_counter(mm, MM_ANONPAGES);
+		inc_mm_counter(mm, MM_SWAPENTS);
 		swp_pte = swp_entry_to_pte(entry);
 		if (pte_soft_dirty(pteval))
 			swp_pte = pte_swp_mksoft_dirty(swp_pte);
 		set_pte_at(mm, address, pte, swp_pte);
-	} else if (IS_ENABLED(CONFIG_MIGRATION) &&
-		   (flags & TTU_MIGRATION)) {
-		/* Establish migration entry for a file page */
-		swp_entry_t entry;
-		entry = make_migration_entry(page, pte_write(pteval));
-		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 	} else
 		dec_mm_counter(mm, MM_FILEPAGES);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
