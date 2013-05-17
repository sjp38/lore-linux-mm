Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 00BFF6B005A
	for <linux-mm@kvack.org>; Fri, 17 May 2013 12:18:29 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/memory-failure.c: fix memory leak in successful soft offlining
Date: Fri, 17 May 2013 12:18:02 -0400
Message-Id: <1368807482-11153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

After a successful page migration by soft offlining, the source page is
not properly freed and it's never reusable even if we unpoison it afterward.

This is caused by the race between freeing page and setting PG_hwpoison.
In successful soft offlining, the source page is put (and the refcount
becomes 0) by putback_lru_page() in unmap_and_move(), where it's linked to
pagevec and actual freeing back to buddy is delayed. So if PG_hwpoison is
set for the page before freeing, the freeing does not functions as expected
(in such case freeing aborts in free_pages_prepare() check.)

This patch tries to make sure to free the source page before setting
PG_hwpoison on it. To avoid reallocating, the page keeps MIGRATE_ISOLATE
until after setting PG_hwpoison.

This patch also removes obsolete comments about "keeping elevated refcount"
because what they say is not true. Unlike memory_failure(), soft_offline_page()
uses no special page isolation code, and the soft-offlined pages have no
difference from buddy pages except PG_hwpoison. So no need to keep refcount
elevated.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git linux-v3.9-rc3.orig/mm/memory-failure.c linux-v3.9-rc3/mm/memory-failure.c
index 4e01082..894262d 100644
--- linux-v3.9-rc3.orig/mm/memory-failure.c
+++ linux-v3.9-rc3/mm/memory-failure.c
@@ -1410,7 +1410,8 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
 
 	/*
 	 * Isolate the page, so that it doesn't get reallocated if it
-	 * was free.
+	 * was free. This flag should be kept set until the source page
+	 * is freed and PG_hwpoison on it is set.
 	 */
 	set_migratetype_isolate(p, true);
 	/*
@@ -1433,7 +1434,6 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
 		/* Not a free page */
 		ret = 1;
 	}
-	unset_migratetype_isolate(p, MIGRATE_MOVABLE);
 	unlock_memory_hotplug();
 	return ret;
 }
@@ -1503,7 +1503,6 @@ static int soft_offline_huge_page(struct page *page, int flags)
 		atomic_long_add(1 << compound_trans_order(hpage),
 				&num_poisoned_pages);
 	}
-	/* keep elevated page count for bad page */
 	return ret;
 }
 
@@ -1568,7 +1567,7 @@ int soft_offline_page(struct page *page, int flags)
 			atomic_long_inc(&num_poisoned_pages);
 		}
 	}
-	/* keep elevated page count for bad page */
+	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
 	return ret;
 }
 
@@ -1634,7 +1633,22 @@ static int __soft_offline_page(struct page *page, int flags)
 			if (ret > 0)
 				ret = -EIO;
 		} else {
+			/*
+			 * After page migration succeeds, the source page can
+			 * be trapped in pagevec and actual freeing is delayed.
+			 * Freeing code works differently based on PG_hwpoison,
+			 * so there's a race. We need to make sure that the
+			 * source page should be freed back to buddy before
+			 * setting PG_hwpoison.
+			 */
+			if (!is_free_buddy_page(page))
+				lru_add_drain_all();
+			if (!is_free_buddy_page(page))
+				drain_all_pages();
 			SetPageHWPoison(page);
+			if (!is_free_buddy_page(page))
+				pr_info("soft offline: %#lx: page leaked\n",
+					pfn);
 			atomic_long_inc(&num_poisoned_pages);
 		}
 	} else {
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
