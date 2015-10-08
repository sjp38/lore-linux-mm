Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 606F56B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 02:36:08 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so45290968pad.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 23:36:08 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id he4si63972645pbc.109.2015.10.07.23.36.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Oct 2015 23:36:06 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH 1/3] page: add new flags "PG_movable" and add interfaces to control these pages
Date: Thu, 8 Oct 2015 14:35:50 +0800
Message-ID: <1444286152-30175-2-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1444286152-30175-1-git-send-email-zhuhui@xiaomi.com>
References: <1444286152-30175-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey
 Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal
 Hocko <mhocko@suse.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jennifer Herbert <jennifer.herbert@citrix.com>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil
 Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Greg
 Thelen <gthelen@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

This patch add PG_movable to mark a page as movable.
And when system call migrate function, it will call the interfaces isolate,
put and migrate to control it.

There is a patch for page migrate interface in LKML.  But for zsmalloc,
it is too deep inside the file system.  So I add another one.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 include/linux/mm_types.h   |  6 ++++++
 include/linux/page-flags.h |  3 +++
 mm/compaction.c            |  6 ++++++
 mm/debug.c                 |  1 +
 mm/migrate.c               | 17 +++++++++++++----
 mm/vmscan.c                |  2 +-
 6 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3d6baa7..132afb0 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/cpumask.h>
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
+#include <linux/migrate_mode.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -196,6 +197,11 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
+
+	int (*isolate)(struct page *page);
+	void (*put)(struct page *page);
+	int (*migrate)(struct page *page, struct page *newpage, int force,
+		       enum migrate_mode mode);
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 416509e..d91e98a 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -113,6 +113,7 @@ enum pageflags {
 	PG_young,
 	PG_idle,
 #endif
+	PG_movable,		/* MOVABLE */
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -230,6 +231,8 @@ PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
 __PAGEFLAG(SlobFree, slob_free)
 
+PAGEFLAG(Movable, movable)
+
 /*
  * Private page markings that may be used by the filesystem that owns the page
  * for its own purposes.
diff --git a/mm/compaction.c b/mm/compaction.c
index c5c627a..45bf7a5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -752,6 +752,12 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		is_lru = PageLRU(page);
 		if (!is_lru) {
+			if (PageMovable(page)) {
+				if (page->isolate(page) == 0)
+					goto isolate_success;
+
+				continue;
+			}
 			if (unlikely(balloon_page_movable(page))) {
 				if (balloon_page_isolate(page)) {
 					/* Successfully isolated */
diff --git a/mm/debug.c b/mm/debug.c
index 6c1b3ea..9966c3c 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -52,6 +52,7 @@ static const struct trace_print_flags pageflag_names[] = {
 	{1UL << PG_young,		"young"		},
 	{1UL << PG_idle,		"idle"		},
 #endif
+	{1UL << PG_movable,		"movable"	},
 };
 
 static void dump_flags(unsigned long flags,
diff --git a/mm/migrate.c b/mm/migrate.c
index 842ecd7..8ff678d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -93,7 +93,9 @@ void putback_movable_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(isolated_balloon_page(page)))
+		if (PageMovable(page))
+			page->put(page);
+		else if (unlikely(isolated_balloon_page(page)))
 			balloon_page_putback(page);
 		else
 			putback_lru_page(page);
@@ -953,7 +955,10 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		if (unlikely(split_huge_page(page)))
 			goto out;
 
-	rc = __unmap_and_move(page, newpage, force, mode);
+	if (PageMovable(page))
+		rc = page->migrate(page, newpage, force, mode);
+	else
+		rc = __unmap_and_move(page, newpage, force, mode);
 
 out:
 	if (rc != -EAGAIN) {
@@ -967,7 +972,9 @@ out:
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
 		/* Soft-offlined page shouldn't go through lru cache list */
-		if (reason == MR_MEMORY_FAILURE) {
+		if (PageMovable(page))
+			page->put(page);
+		else if (reason == MR_MEMORY_FAILURE) {
 			put_page(page);
 			if (!test_set_page_hwpoison(page))
 				num_poisoned_pages_inc();
@@ -983,7 +990,9 @@ out:
 	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
 		ClearPageSwapBacked(newpage);
 		put_new_page(newpage, private);
-	} else if (unlikely(__is_movable_balloon_page(newpage))) {
+	} else if (PageMovable(newpage))
+		put_page(newpage);
+	else if (unlikely(__is_movable_balloon_page(newpage))) {
 		/* drop our reference, page already in the balloon */
 		put_page(newpage);
 	} else
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7f63a93..aad4444 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1245,7 +1245,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 
 	list_for_each_entry_safe(page, next, page_list, lru) {
 		if (page_is_file_cache(page) && !PageDirty(page) &&
-		    !isolated_balloon_page(page)) {
+		    !isolated_balloon_page(page) && !PageMovable(page)) {
 			ClearPageActive(page);
 			list_move(&page->lru, &clean_pages);
 		}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
