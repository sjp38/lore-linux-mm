Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id DE7C66B0055
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:51:44 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id r15so2336800ead.24
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:51:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id l2si14859892een.167.2013.12.10.07.51.44
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 07:51:44 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/18] mm: numa: Avoid unnecessary disruption of NUMA hinting during migration
Date: Tue, 10 Dec 2013 15:51:28 +0000
Message-Id: <1386690695-27380-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

do_huge_pmd_numa_page() handles the case where there is parallel THP
migration.  However, by the time it is checked the NUMA hinting information
has already been disrupted. This patch adds an earlier check with some helpers.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/migrate.h |  9 +++++++++
 mm/huge_memory.c        | 22 ++++++++++++++++------
 mm/migrate.c            | 12 ++++++++++++
 3 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f5096b5..b7717d7 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -90,10 +90,19 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_NUMA_BALANCING
+extern bool pmd_trans_migrating(pmd_t pmd);
+extern void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd);
 extern int migrate_misplaced_page(struct page *page,
 				  struct vm_area_struct *vma, int node);
 extern bool migrate_ratelimited(int node);
 #else
+static inline bool pmd_trans_migrating(pmd_t pmd)
+{
+	return false;
+}
+static inline void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
+{
+}
 static inline int migrate_misplaced_page(struct page *page,
 					 struct vm_area_struct *vma, int node)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0ecaba2..e3b6a75 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -882,6 +882,10 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		ret = 0;
 		goto out_unlock;
 	}
+
+	/* mmap_sem prevents this happening but warn if that changes */
+	WARN_ON(pmd_trans_migrating(pmd));
+
 	if (unlikely(pmd_trans_splitting(pmd))) {
 		/* split huge page running from under us */
 		spin_unlock(src_ptl);
@@ -1299,6 +1303,17 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pmd_same(pmd, *pmdp)))
 		goto out_unlock;
 
+	/*
+	 * If there are potential migrations, wait for completion and retry
+	 * without disrupting NUMA hinting information. Do not relock and
+	 * check_same as the page may no longer be mapped.
+	 */
+	if (unlikely(pmd_trans_migrating(*pmdp))) {
+		spin_unlock(ptl);
+		wait_migrate_huge_page(vma->anon_vma, pmdp);
+		goto out;
+	}
+
 	page = pmd_page(pmd);
 	BUG_ON(is_huge_zero_page(page));
 	page_nid = page_to_nid(page);
@@ -1329,12 +1344,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			goto clear_pmdnuma;
 	}
 
-	/*
-	 * If there are potential migrations, wait for completion and retry. We
-	 * do not relock and check_same as the page may no longer be mapped.
-	 * Furtermore, even if the page is currently misplaced, there is no
-	 * guarantee it is still misplaced after the migration completes.
-	 */
+	/* Migration could have started since the pmd_trans_migrating check */
 	if (!page_locked) {
 		spin_unlock(ptl);
 		wait_on_page_locked(page);
diff --git a/mm/migrate.c b/mm/migrate.c
index a987525..cfb4190 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1655,6 +1655,18 @@ int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 	return 1;
 }
 
+bool pmd_trans_migrating(pmd_t pmd)
+{
+	struct page *page = pmd_page(pmd);
+	return PageLocked(page);
+}
+
+void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
+{
+	struct page *page = pmd_page(*pmd);
+	wait_on_page_locked(page);
+}
+
 /*
  * Attempt to migrate a misplaced page to the specified destination
  * node. Caller is expected to have an elevated reference count on
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
