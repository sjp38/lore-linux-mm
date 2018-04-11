Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB0F96B0024
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:09:42 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a6so549559pfn.3
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 01:09:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32-v6sor257536plb.6.2018.04.11.01.09.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 01:09:41 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 1/2] mm: migrate: add vm event counters thp_migrate_(success|fail)
Date: Wed, 11 Apr 2018 17:09:26 +0900
Message-Id: <1523434167-19995-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1523434167-19995-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1523434167-19995-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>, Zi Yan <zi.yan@sent.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

Currenly we have some vm event counters for page migration, but all
migration events are counted in a single value regardless of page size.
That is not good for end users who are interested in knowing whether
hugepage migration works.  So this patch is suggesting to add separate
counters for thp migration.

Note that when thp migration fails due to ENOMEM or the lack of thp
migration support, the event is not counted in thp_migrate_fail and we
transparently retry the subpages' migrations.

Another note is that the return value of migrate_pages(), which is
claimed as "the number of pages that were not migrated (positive) or an
error code (negative)," doesn't consider the page size now.  We could do
this for example by counting a single failure of thp migration event as
512, but this patch doesn't do it for simplicity.  It seems to me that
there is no migrate_pages()'s caller which cares about the number itself
of the positive return value, so this should not be critical for now.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/vm_event_item.h |  4 ++
 mm/migrate.c                  | 93 +++++++++++++++++++++++++++++++++++--------
 mm/vmstat.c                   |  4 ++
 3 files changed, 85 insertions(+), 16 deletions(-)

diff --git v4.16-mmotm-2018-04-10-17-02/include/linux/vm_event_item.h v4.16-mmotm-2018-04-10-17-02_patched/include/linux/vm_event_item.h
index 5c7f010..fa2d2e0 100644
--- v4.16-mmotm-2018-04-10-17-02/include/linux/vm_event_item.h
+++ v4.16-mmotm-2018-04-10-17-02_patched/include/linux/vm_event_item.h
@@ -88,6 +88,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 		THP_SWPOUT,
 		THP_SWPOUT_FALLBACK,
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		THP_MIGRATE_SUCCESS,
+		THP_MIGRATE_FAIL,
+#endif
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 		BALLOON_INFLATE,
diff --git v4.16-mmotm-2018-04-10-17-02/mm/migrate.c v4.16-mmotm-2018-04-10-17-02_patched/mm/migrate.c
index bb6367d..46ff23a 100644
--- v4.16-mmotm-2018-04-10-17-02/mm/migrate.c
+++ v4.16-mmotm-2018-04-10-17-02_patched/mm/migrate.c
@@ -1348,6 +1348,69 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	return rc;
 }
 
+enum migrate_result_type {
+       MIGRATE_SUCCEED,
+       MIGRATE_FAIL,
+       MIGRATE_RETRY,
+       MIGRATE_RESULT_TYPES
+};
+
+enum migrate_page_type {
+       MIGRATE_PAGE_NORMAL,
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+       MIGRATE_PAGE_THP,
+#endif
+       MIGRATE_PAGE_TYPES
+};
+
+static struct migrate_event {
+       int succeeded;
+       int failed;
+} migrate_events[] = {
+       { PGMIGRATE_SUCCESS,    PGMIGRATE_FAIL },
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+       { THP_MIGRATE_SUCCESS,  THP_MIGRATE_FAIL },
+#endif
+};
+
+static inline enum migrate_page_type get_type(struct page *page)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (PageTransHuge(page))
+		return MIGRATE_PAGE_THP;
+#endif
+	return MIGRATE_PAGE_NORMAL;
+}
+
+static inline int get_count(int array[][MIGRATE_PAGE_TYPES], int type)
+{
+	int i, ret;
+
+	for (i = 0, ret = 0; i < MIGRATE_PAGE_TYPES; i++)
+		ret += array[type][i];
+	return ret;
+}
+
+static inline void reset_nr_retry(int array[][MIGRATE_PAGE_TYPES])
+{
+	int i;
+
+	for (i = 0; i < MIGRATE_PAGE_TYPES; i++)
+		array[MIGRATE_RETRY][i] = 0;
+}
+
+static inline void update_vm_migrate_events(int array[][MIGRATE_PAGE_TYPES])
+{
+	int i;
+
+	for (i = 0; i < MIGRATE_PAGE_TYPES; i++) {
+		count_vm_events(migrate_events[i].succeeded,
+				array[MIGRATE_SUCCEED][i]);
+		count_vm_events(migrate_events[i].failed,
+				array[MIGRATE_FAIL][i]);
+	}
+}
+
 /*
  * migrate_pages - migrate the pages specified in a list, to the free pages
  *		   supplied as the target for the page migration
@@ -1373,9 +1436,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 		free_page_t put_new_page, unsigned long private,
 		enum migrate_mode mode, int reason)
 {
-	int retry = 1;
-	int nr_failed = 0;
-	int nr_succeeded = 0;
+	int counts[MIGRATE_RESULT_TYPES][MIGRATE_PAGE_TYPES] = {0};
 	int pass = 0;
 	struct page *page;
 	struct page *page2;
@@ -1385,13 +1446,16 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;
 
-	for(pass = 0; pass < 10 && retry; pass++) {
-		retry = 0;
+	for (pass = 0; !pass || (pass < 10 && get_count(counts, MIGRATE_RETRY));
+	     pass++) {
+		reset_nr_retry(counts);
 
 		list_for_each_entry_safe(page, page2, from, lru) {
+			enum migrate_page_type mpt;
 retry:
 			cond_resched();
 
+			mpt = get_type(page);
 			if (PageHuge(page))
 				rc = unmap_and_move_huge_page(get_new_page,
 						put_new_page, private, page,
@@ -1423,13 +1487,13 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 						goto retry;
 					}
 				}
-				nr_failed++;
+				counts[MIGRATE_FAIL][mpt]++;
 				goto out;
 			case -EAGAIN:
-				retry++;
+				counts[MIGRATE_RETRY][mpt]++;
 				break;
 			case MIGRATEPAGE_SUCCESS:
-				nr_succeeded++;
+				counts[MIGRATE_SUCCEED][mpt]++;
 				break;
 			default:
 				/*
@@ -1438,19 +1502,16 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 				 * removed from migration page list and not
 				 * retried in the next outer loop.
 				 */
-				nr_failed++;
+				counts[MIGRATE_FAIL][mpt]++;
 				break;
 			}
 		}
 	}
-	nr_failed += retry;
-	rc = nr_failed;
+	rc = get_count(counts, MIGRATE_FAIL) + get_count(counts, MIGRATE_RETRY);
 out:
-	if (nr_succeeded)
-		count_vm_events(PGMIGRATE_SUCCESS, nr_succeeded);
-	if (nr_failed)
-		count_vm_events(PGMIGRATE_FAIL, nr_failed);
-	trace_mm_migrate_pages(nr_succeeded, nr_failed, mode, reason);
+	update_vm_migrate_events(counts);
+	trace_mm_migrate_pages(get_count(counts, MIGRATE_SUCCEED), rc,
+			       mode, reason);
 
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
diff --git v4.16-mmotm-2018-04-10-17-02/mm/vmstat.c v4.16-mmotm-2018-04-10-17-02_patched/mm/vmstat.c
index 536332e..57e9cc3 100644
--- v4.16-mmotm-2018-04-10-17-02/mm/vmstat.c
+++ v4.16-mmotm-2018-04-10-17-02_patched/mm/vmstat.c
@@ -1263,6 +1263,10 @@ const char * const vmstat_text[] = {
 	"thp_zero_page_alloc_failed",
 	"thp_swpout",
 	"thp_swpout_fallback",
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+	"thp_migrate_success",
+	"thp_migrate_fail",
+#endif
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 	"balloon_inflate",
-- 
2.7.0
