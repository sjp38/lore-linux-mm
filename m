Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C46696B4467
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:27:55 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v2so10936786plg.6
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:27:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38sor2512811pld.67.2018.11.26.15.27.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 15:27:54 -0800 (PST)
Date: Mon, 26 Nov 2018 15:27:52 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 07/10] mm/khugepaged: minor reorderings in collapse_shmem()
In-Reply-To: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1811261526400.2275@eggly.anvils>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

Several cleanups in collapse_shmem(): most of which probably do not
really matter, beyond doing things in a more familiar and reassuring
order.  Simplify the failure gotos in the main loop, and on success
update stats while interrupts still disabled from the last iteration.

Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: stable@vger.kernel.org # 4.8+
---
 mm/khugepaged.c | 72 ++++++++++++++++++++++---------------------------
 1 file changed, 32 insertions(+), 40 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 1c402d33547e..9d4e9ff1af95 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1329,10 +1329,10 @@ static void collapse_shmem(struct mm_struct *mm,
 		goto out;
 	}
 
+	__SetPageLocked(new_page);
+	__SetPageSwapBacked(new_page);
 	new_page->index = start;
 	new_page->mapping = mapping;
-	__SetPageSwapBacked(new_page);
-	__SetPageLocked(new_page);
 	BUG_ON(!page_ref_freeze(new_page, 1));
 
 	/*
@@ -1366,13 +1366,13 @@ static void collapse_shmem(struct mm_struct *mm,
 			if (index == start) {
 				if (!xas_next_entry(&xas, end - 1)) {
 					result = SCAN_TRUNCATED;
-					break;
+					goto xa_locked;
 				}
 				xas_set(&xas, index);
 			}
 			if (!shmem_charge(mapping->host, 1)) {
 				result = SCAN_FAIL;
-				break;
+				goto xa_locked;
 			}
 			xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
 			nr_none++;
@@ -1387,13 +1387,12 @@ static void collapse_shmem(struct mm_struct *mm,
 				result = SCAN_FAIL;
 				goto xa_unlocked;
 			}
-			xas_lock_irq(&xas);
-			xas_set(&xas, index);
 		} else if (trylock_page(page)) {
 			get_page(page);
+			xas_unlock_irq(&xas);
 		} else {
 			result = SCAN_PAGE_LOCK;
-			break;
+			goto xa_locked;
 		}
 
 		/*
@@ -1408,11 +1407,10 @@ static void collapse_shmem(struct mm_struct *mm,
 			result = SCAN_TRUNCATED;
 			goto out_unlock;
 		}
-		xas_unlock_irq(&xas);
 
 		if (isolate_lru_page(page)) {
 			result = SCAN_DEL_PAGE_LRU;
-			goto out_isolate_failed;
+			goto out_unlock;
 		}
 
 		if (page_mapped(page))
@@ -1432,7 +1430,9 @@ static void collapse_shmem(struct mm_struct *mm,
 		 */
 		if (!page_ref_freeze(page, 3)) {
 			result = SCAN_PAGE_COUNT;
-			goto out_lru;
+			xas_unlock_irq(&xas);
+			putback_lru_page(page);
+			goto out_unlock;
 		}
 
 		/*
@@ -1444,24 +1444,26 @@ static void collapse_shmem(struct mm_struct *mm,
 		/* Finally, replace with the new page. */
 		xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
 		continue;
-out_lru:
-		xas_unlock_irq(&xas);
-		putback_lru_page(page);
-out_isolate_failed:
-		unlock_page(page);
-		put_page(page);
-		goto xa_unlocked;
 out_unlock:
 		unlock_page(page);
 		put_page(page);
-		break;
+		goto xa_unlocked;
 	}
-	xas_unlock_irq(&xas);
 
+	__inc_node_page_state(new_page, NR_SHMEM_THPS);
+	if (nr_none) {
+		struct zone *zone = page_zone(new_page);
+
+		__mod_node_page_state(zone->zone_pgdat, NR_FILE_PAGES, nr_none);
+		__mod_node_page_state(zone->zone_pgdat, NR_SHMEM, nr_none);
+	}
+
+xa_locked:
+	xas_unlock_irq(&xas);
 xa_unlocked:
+
 	if (result == SCAN_SUCCEED) {
 		struct page *page, *tmp;
-		struct zone *zone = page_zone(new_page);
 
 		/*
 		 * Replacing old pages with new one has succeeded, now we
@@ -1476,11 +1478,11 @@ static void collapse_shmem(struct mm_struct *mm,
 			copy_highpage(new_page + (page->index % HPAGE_PMD_NR),
 					page);
 			list_del(&page->lru);
-			unlock_page(page);
-			page_ref_unfreeze(page, 1);
 			page->mapping = NULL;
+			page_ref_unfreeze(page, 1);
 			ClearPageActive(page);
 			ClearPageUnevictable(page);
+			unlock_page(page);
 			put_page(page);
 			index++;
 		}
@@ -1489,28 +1491,17 @@ static void collapse_shmem(struct mm_struct *mm,
 			index++;
 		}
 
-		local_irq_disable();
-		__inc_node_page_state(new_page, NR_SHMEM_THPS);
-		if (nr_none) {
-			__mod_node_page_state(zone->zone_pgdat, NR_FILE_PAGES, nr_none);
-			__mod_node_page_state(zone->zone_pgdat, NR_SHMEM, nr_none);
-		}
-		local_irq_enable();
-
-		/*
-		 * Remove pte page tables, so we can re-fault
-		 * the page as huge.
-		 */
-		retract_page_tables(mapping, start);
-
 		/* Everything is ready, let's unfreeze the new_page */
-		set_page_dirty(new_page);
 		SetPageUptodate(new_page);
 		page_ref_unfreeze(new_page, HPAGE_PMD_NR);
+		set_page_dirty(new_page);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
 		lru_cache_add_anon(new_page);
-		unlock_page(new_page);
 
+		/*
+		 * Remove pte page tables, so we can re-fault the page as huge.
+		 */
+		retract_page_tables(mapping, start);
 		*hpage = NULL;
 
 		khugepaged_pages_collapsed++;
@@ -1543,8 +1534,8 @@ static void collapse_shmem(struct mm_struct *mm,
 			xas_store(&xas, page);
 			xas_pause(&xas);
 			xas_unlock_irq(&xas);
-			putback_lru_page(page);
 			unlock_page(page);
+			putback_lru_page(page);
 			xas_lock_irq(&xas);
 		}
 		VM_BUG_ON(nr_none);
@@ -1553,9 +1544,10 @@ static void collapse_shmem(struct mm_struct *mm,
 		/* Unfreeze new_page, caller would take care about freeing it */
 		page_ref_unfreeze(new_page, 1);
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		unlock_page(new_page);
 		new_page->mapping = NULL;
 	}
+
+	unlock_page(new_page);
 out:
 	VM_BUG_ON(!list_empty(&pagelist));
 	/* TODO: tracepoints */
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
