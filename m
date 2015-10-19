Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4B082F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 01:11:21 -0400 (EDT)
Received: by obcqt19 with SMTP id qt19so52018942obc.3
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 22:11:20 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id m9si16210620oew.40.2015.10.18.22.11.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 22:11:20 -0700 (PDT)
Received: by obcqt19 with SMTP id qt19so52018857obc.3
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 22:11:20 -0700 (PDT)
Date: Sun, 18 Oct 2015 22:11:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 12/12] mm: migrate dirty page without clear_page_dirty_for_io
 etc
In-Reply-To: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510182207450.2481@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

clear_page_dirty_for_io() has accumulated writeback and memcg subtleties
since v2.6.16 first introduced page migration; and the set_page_dirty()
which completed its migration of PageDirty, later had to be moderated to
__set_page_dirty_nobuffers(); then PageSwapBacked had to skip that too.

No actual problems seen with this procedure recently, but if you look
into what the clear_page_dirty_for_io(page)+set_page_dirty(newpage) is
actually achieving, it turns out to be nothing more than moving the
PageDirty flag, and its NR_FILE_DIRTY stat from one zone to another.

It would be good to avoid a pile of irrelevant decrementations and
incrementations, and improper event counting, and unnecessary descent
of the radix_tree under tree_lock (to set the PAGECACHE_TAG_DIRTY which
radix_tree_replace_slot() left in place anyway).

Do the NR_FILE_DIRTY movement, like the other stats movements, while
interrupts still disabled in migrate_page_move_mapping(); and don't even
bother if the zone is the same.  Do the PageDirty movement there under
tree_lock too, where old page is frozen and newpage not yet visible:
bearing in mind that as soon as newpage becomes visible in radix_tree,
an un-page-locked set_page_dirty() might interfere (or perhaps that's
just not possible: anything doing so should already hold an additional
reference to the old page, preventing its migration; but play safe).

But we do still need to transfer PageDirty in migrate_page_copy(), for
those who don't go the mapping route through migrate_page_move_mapping().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/migrate.c |   51 +++++++++++++++++++++++++++++--------------------
 1 file changed, 31 insertions(+), 20 deletions(-)

--- migrat.orig/mm/migrate.c	2015-10-18 17:53:31.871345704 -0700
+++ migrat/mm/migrate.c	2015-10-18 17:53:33.899348014 -0700
@@ -30,6 +30,7 @@
 #include <linux/mempolicy.h>
 #include <linux/vmalloc.h>
 #include <linux/security.h>
+#include <linux/backing-dev.h>
 #include <linux/syscalls.h>
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
@@ -313,6 +314,8 @@ int migrate_page_move_mapping(struct add
 		struct buffer_head *head, enum migrate_mode mode,
 		int extra_count)
 {
+	struct zone *oldzone, *newzone;
+	int dirty;
 	int expected_count = 1 + extra_count;
 	void **pslot;
 
@@ -331,6 +334,9 @@ int migrate_page_move_mapping(struct add
 		return MIGRATEPAGE_SUCCESS;
 	}
 
+	oldzone = page_zone(page);
+	newzone = page_zone(newpage);
+
 	spin_lock_irq(&mapping->tree_lock);
 
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
@@ -378,6 +384,13 @@ int migrate_page_move_mapping(struct add
 		set_page_private(newpage, page_private(page));
 	}
 
+	/* Move dirty while page refs frozen and newpage not yet exposed */
+	dirty = PageDirty(page);
+	if (dirty) {
+		ClearPageDirty(page);
+		SetPageDirty(newpage);
+	}
+
 	radix_tree_replace_slot(pslot, newpage);
 
 	/*
@@ -387,6 +400,9 @@ int migrate_page_move_mapping(struct add
 	 */
 	page_unfreeze_refs(page, expected_count - 1);
 
+	spin_unlock(&mapping->tree_lock);
+	/* Leave irq disabled to prevent preemption while updating stats */
+
 	/*
 	 * If moved to a different zone then also account
 	 * the page for that zone. Other VM counters will be
@@ -397,13 +413,19 @@ int migrate_page_move_mapping(struct add
 	 * via NR_FILE_PAGES and NR_ANON_PAGES if they
 	 * are mapped to swap space.
 	 */
-	__dec_zone_page_state(page, NR_FILE_PAGES);
-	__inc_zone_page_state(newpage, NR_FILE_PAGES);
-	if (!PageSwapCache(page) && PageSwapBacked(page)) {
-		__dec_zone_page_state(page, NR_SHMEM);
-		__inc_zone_page_state(newpage, NR_SHMEM);
+	if (newzone != oldzone) {
+		__dec_zone_state(oldzone, NR_FILE_PAGES);
+		__inc_zone_state(newzone, NR_FILE_PAGES);
+		if (PageSwapBacked(page) && !PageSwapCache(page)) {
+			__dec_zone_state(oldzone, NR_SHMEM);
+			__inc_zone_state(newzone, NR_SHMEM);
+		}
+		if (dirty && mapping_cap_account_dirty(mapping)) {
+			__dec_zone_state(oldzone, NR_FILE_DIRTY);
+			__inc_zone_state(newzone, NR_FILE_DIRTY);
+		}
 	}
-	spin_unlock_irq(&mapping->tree_lock);
+	local_irq_enable();
 
 	return MIGRATEPAGE_SUCCESS;
 }
@@ -524,20 +546,9 @@ void migrate_page_copy(struct page *newp
 	if (PageMappedToDisk(page))
 		SetPageMappedToDisk(newpage);
 
-	if (PageDirty(page)) {
-		clear_page_dirty_for_io(page);
-		/*
-		 * Want to mark the page and the radix tree as dirty, and
-		 * redo the accounting that clear_page_dirty_for_io undid,
-		 * but we can't use set_page_dirty because that function
-		 * is actually a signal that all of the page has become dirty.
-		 * Whereas only part of our page may be dirty.
-		 */
-		if (PageSwapBacked(page))
-			SetPageDirty(newpage);
-		else
-			__set_page_dirty_nobuffers(newpage);
- 	}
+	/* Move dirty on pages not done by migrate_page_move_mapping() */
+	if (PageDirty(page))
+		SetPageDirty(newpage);
 
 	if (page_is_young(page))
 		set_page_young(newpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
