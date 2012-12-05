Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 951076B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 19:55:16 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so3280985pad.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2012 16:55:15 -0800 (PST)
Date: Tue, 4 Dec 2012 16:55:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 20/52] mm, numa: Implement migrate-on-fault lazy NUMA
 strategy for regular and THP pages
In-Reply-To: <1354473824-19229-21-git-send-email-mingo@kernel.org>
Message-ID: <alpine.DEB.2.00.1212041652240.13029@chino.kir.corp.google.com>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org> <1354473824-19229-21-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Commit "mm, numa: Implement migrate-on-fault lazy NUMA strategy for 
regular and THP pages" breaks the build because HPAGE_PMD_SHIFT and 
HPAGE_PMD_MASK defined to explode without CONFIG_TRANSPARENT_HUGEPAGE:

mm/migrate.c: In function 'migrate_misplaced_transhuge_page_put':
mm/migrate.c:1549: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
mm/migrate.c:1564: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
mm/migrate.c:1566: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
mm/migrate.c:1573: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
mm/migrate.c:1606: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
mm/migrate.c:1648: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed

CONFIG_NUMA_BALANCING allows compilation without enabling transparent 
hugepages, so define the dummy function for such a configuration and only 
define migrate_misplaced_transhuge_page_put() when transparent hugepages 
are enabled.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/migrate.h |   18 +++++++++++-------
 mm/migrate.c            |    3 +++
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -78,12 +78,6 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 #ifdef CONFIG_NUMA_BALANCING
 extern bool migrate_balanced_pgdat(struct pglist_data *pgdat, int nr_migrate_pages);
 extern int migrate_misplaced_page_put(struct page *page, int node);
-extern int migrate_misplaced_transhuge_page_put(struct mm_struct *mm,
-			struct vm_area_struct *vma,
-			pmd_t *pmd, pmd_t entry,
-			unsigned long address,
-			struct page *page, int node);
-
 #else
 static inline bool migrate_balanced_pgdat(struct pglist_data *pgdat, int nr_migrate_pages)
 {
@@ -93,6 +87,16 @@ static inline int migrate_misplaced_page_put(struct page *page, int node)
 {
 	return -EAGAIN; /* can't migrate now */
 }
+#endif /* CONFIG_NUMA_BALANCING */
+
+#if defined(CONFIG_NUMA_BALANCING) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
+extern int migrate_misplaced_transhuge_page_put(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			pmd_t *pmd, pmd_t entry,
+			unsigned long address,
+			struct page *page, int node);
+
+#else
 static inline int migrate_misplaced_transhuge_page_put(struct mm_struct *mm,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, pmd_t entry,
@@ -101,6 +105,6 @@ static inline int migrate_misplaced_transhuge_page_put(struct mm_struct *mm,
 {
 	return -EAGAIN;
 }
-#endif /* CONFIG_NUMA_BALANCING */
+#endif /* CONFIG_NUMA_BALANCING && CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_MIGRATE_H */
diff --git a/mm/migrate.c b/mm/migrate.c
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1540,6 +1540,7 @@ out:
 	return isolated;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 int migrate_misplaced_transhuge_page_put(struct mm_struct *mm,
 				struct vm_area_struct *vma,
 				pmd_t *pmd, pmd_t entry,
@@ -1653,6 +1654,8 @@ out_dropref:
 out_keep_locked:
 	return 0;
 }
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 #endif /* CONFIG_NUMA_BALANCING */
 
 #endif /* CONFIG_NUMA */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
