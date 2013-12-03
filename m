Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4D76B005C
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 03:52:14 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so1258703eek.32
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 00:52:14 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e2si2247146eeg.114.2013.12.03.00.52.13
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 00:52:13 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/15] mm: numa: Avoid unnecessary disruption of NUMA hinting during migration
Date: Tue,  3 Dec 2013 08:52:00 +0000
Message-Id: <1386060721-3794-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1386060721-3794-1-git-send-email-mgorman@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

do_huge_pmd_numa_page() handles the case where there is parallel THP
migration.  However, by the time it is checked the NUMA hinting information
has already been disrupted. This patch adds an earlier check with some helpers.
It reuses the helper to warn if a huge pmd copy takes place in parallel with
THP migration as that potentially leads to corruption.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/migrate.h | 10 +++++++++-
 mm/huge_memory.c        | 22 ++++++++++++++++------
 mm/migrate.c            | 17 +++++++++++++++++
 3 files changed, 42 insertions(+), 7 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 8d3c57f..804651c 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -90,10 +90,18 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_NUMA_BALANCING
-extern int migrate_misplaced_page(struct page *page, int node);
+extern bool pmd_trans_migrating(pmd_t pmd);
+extern void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd);
 extern int migrate_misplaced_page(struct page *page, int node);
 extern bool migrate_ratelimited(int node);
 #else
+static inline bool pmd_trans_migrating(pmd_t pmd)
+{
+	return false;
+}
+static inline void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
+{
+}
 static inline int migrate_misplaced_page(struct page *page, int node)
 {
 	return -EAGAIN; /* can't migrate now */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fa277fa..4c7abd7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -884,6 +884,10 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		ret = 0;
 		goto out_unlock;
 	}
+
+	/* mmap_sem prevents this happening but warn if that changes */
+	WARN_ON(pmd_trans_migrating(pmd));
+
 	if (unlikely(pmd_trans_splitting(pmd))) {
 		/* split huge page running from under us */
 		spin_unlock(&src_mm->page_table_lock);
@@ -1294,6 +1298,17 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pmd_same(pmd, *pmdp)))
 		goto out_unlock;
 
+	/*
+	 * If there are potential migrations, wait for completion and retry
+	 * without disrupting NUMA hinting information. Do not relock and
+	 * check_same as the page may no longer be mapped.
+	 */
+	if (unlikely(pmd_trans_migrating(*pmdp))) {
+		spin_unlock(&mm->page_table_lock);
+		wait_migrate_huge_page(vma->anon_vma, pmdp);
+		goto out;
+	}
+
 	page = pmd_page(pmd);
 	page_nid = page_to_nid(page);
 	count_vm_numa_event(NUMA_HINT_FAULTS);
@@ -1312,12 +1327,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
 		spin_unlock(&mm->page_table_lock);
 		wait_on_page_locked(page);
diff --git a/mm/migrate.c b/mm/migrate.c
index e429206..5dfd552 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1645,6 +1645,23 @@ int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 	return 1;
 }
 
+bool pmd_trans_migrating(pmd_t pmd) {
+	struct page *page = pmd_page(pmd);
+	return PageLocked(page);
+}
+
+void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
+{
+	struct page *page = pmd_page(*pmd);
+	if (get_page_unless_zero(page)) {
+		wait_on_page_locked(page);
+		put_page(page);
+	}
+
+	/* Guarantee that the newly migrated PTE is visible */
+	smp_rmb();
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
