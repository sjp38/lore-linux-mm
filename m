Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A97AD6B0087
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:36:37 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200908051136.682859934@firstfloor.org>
In-Reply-To: <200908051136.682859934@firstfloor.org>
Subject: [PATCH] [9/19] HWPOISON: Handle hardware poisoned pages in try_to_unmap
Message-Id: <20090805093636.CDE6FB15D8@basil.firstfloor.org>
Date: Wed,  5 Aug 2009 11:36:36 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: ak@linux.intel.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>


From: Andi Kleen <ak@linux.intel.com>

When a page has the poison bit set replace the PTE with a poison entry.
This causes the right error handling to be done later when a process runs
into it.

v2: add a new flag to not do that (needed for the memory-failure handler
later) (Fengguang)
v3: remove unnecessary is_migration_entry() test (Fengguang, Minchan)

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/rmap.h |    1 +
 mm/rmap.c            |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletion(-)

Index: linux/mm/rmap.c
===================================================================
--- linux.orig/mm/rmap.c
+++ linux/mm/rmap.c
@@ -819,7 +819,14 @@ static int try_to_unmap_one(struct page
 	/* Update high watermark before we lower rss */
 	update_hiwater_rss(mm);
 
-	if (PageAnon(page)) {
+	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
+		if (PageAnon(page))
+			dec_mm_counter(mm, anon_rss);
+		else
+			dec_mm_counter(mm, file_rss);
+		set_pte_at(mm, address, pte,
+				swp_entry_to_pte(make_hwpoison_entry(page)));
+	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 
 		if (PageSwapCache(page)) {
Index: linux/include/linux/rmap.h
===================================================================
--- linux.orig/include/linux/rmap.h
+++ linux/include/linux/rmap.h
@@ -93,6 +93,7 @@ enum ttu_flags {
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
+	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
 };
 #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
