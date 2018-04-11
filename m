Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB48F6B0024
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:09:44 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q6so335623pgv.12
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 01:09:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w12sor152185pfd.132.2018.04.11.01.09.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 01:09:43 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 2/2] mm: migrate: add vm event counters hugetlb_migrate_(success|fail)
Date: Wed, 11 Apr 2018 17:09:27 +0900
Message-Id: <1523434167-19995-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1523434167-19995-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1523434167-19995-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>, Zi Yan <zi.yan@sent.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

>From the same motivation as the previous patch, this patch is suggesting
to add separate counters for hugetlb migration.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/vm_event_item.h |  3 +++
 mm/migrate.c                  | 10 ++++++++++
 mm/vmstat.c                   |  4 ++++
 3 files changed, 17 insertions(+)

diff --git v4.16-mmotm-2018-04-10-17-02/include/linux/vm_event_item.h v4.16-mmotm-2018-04-10-17-02_patched/include/linux/vm_event_item.h
index fa2d2e0..24966ae 100644
--- v4.16-mmotm-2018-04-10-17-02/include/linux/vm_event_item.h
+++ v4.16-mmotm-2018-04-10-17-02_patched/include/linux/vm_event_item.h
@@ -62,6 +62,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
+#ifdef CONFIG_MIGRATION
+		HTLB_MIGRATE_SUCCESS, HTLB_MIGRATE_FAIL,
+#endif
 #endif
 		UNEVICTABLE_PGCULLED,	/* culled to noreclaim list */
 		UNEVICTABLE_PGSCANNED,	/* scanned for reclaimability */
diff --git v4.16-mmotm-2018-04-10-17-02/mm/migrate.c v4.16-mmotm-2018-04-10-17-02_patched/mm/migrate.c
index 46ff23a..279b143 100644
--- v4.16-mmotm-2018-04-10-17-02/mm/migrate.c
+++ v4.16-mmotm-2018-04-10-17-02_patched/mm/migrate.c
@@ -1357,6 +1357,9 @@ enum migrate_result_type {
 
 enum migrate_page_type {
        MIGRATE_PAGE_NORMAL,
+#ifdef CONFIG_HUGETLB_PAGE
+       MIGRATE_PAGE_HUGETLB,
+#endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
        MIGRATE_PAGE_THP,
 #endif
@@ -1368,6 +1371,9 @@ static struct migrate_event {
        int failed;
 } migrate_events[] = {
        { PGMIGRATE_SUCCESS,    PGMIGRATE_FAIL },
+#ifdef CONFIG_HUGETLB_PAGE
+       { HTLB_MIGRATE_SUCCESS, HTLB_MIGRATE_FAIL },
+#endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
        { THP_MIGRATE_SUCCESS,  THP_MIGRATE_FAIL },
 #endif
@@ -1375,6 +1381,10 @@ static struct migrate_event {
 
 static inline enum migrate_page_type get_type(struct page *page)
 {
+#ifdef CONFIG_HUGETLB_PAGE
+	if (PageHuge(page))
+		return MIGRATE_PAGE_HUGETLB;
+#endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	if (PageTransHuge(page))
 		return MIGRATE_PAGE_THP;
diff --git v4.16-mmotm-2018-04-10-17-02/mm/vmstat.c v4.16-mmotm-2018-04-10-17-02_patched/mm/vmstat.c
index 57e9cc3..27a005f 100644
--- v4.16-mmotm-2018-04-10-17-02/mm/vmstat.c
+++ v4.16-mmotm-2018-04-10-17-02_patched/mm/vmstat.c
@@ -1236,6 +1236,10 @@ const char * const vmstat_text[] = {
 #ifdef CONFIG_HUGETLB_PAGE
 	"htlb_buddy_alloc_success",
 	"htlb_buddy_alloc_fail",
+#ifdef CONFIG_MIGRATION
+	"htlb_migrate_success",
+	"htlb_migrate_fail",
+#endif
 #endif
 	"unevictable_pgs_culled",
 	"unevictable_pgs_scanned",
-- 
2.7.0
