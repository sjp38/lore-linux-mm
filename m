Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 913706B00D4
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:25:15 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 45/49] mm: numa: Add THP migration for the NUMA working set scanning fault case build fix
Date: Fri,  7 Dec 2012 10:23:48 +0000
Message-Id: <1354875832-9700-46-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Commit "Add THP migration for the NUMA working set scanning fault case"
breaks the build because HPAGE_PMD_SHIFT and HPAGE_PMD_MASK defined to
explode without CONFIG_TRANSPARENT_HUGEPAGE:

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
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/migrate.h |   16 +++++++++-------
 mm/migrate.c            |    2 ++
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ed5a6c5..6c15d4a 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -79,12 +79,6 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 extern int migrate_misplaced_page(struct page *page, int node);
 extern int migrate_misplaced_page(struct page *page, int node);
 extern bool migrate_ratelimited(int node);
-extern int migrate_misplaced_transhuge_page(struct mm_struct *mm,
-			struct vm_area_struct *vma,
-			pmd_t *pmd, pmd_t entry,
-			unsigned long address,
-			struct page *page, int node);
-
 #else
 static inline int migrate_misplaced_page(struct page *page, int node)
 {
@@ -94,7 +88,15 @@ static inline bool migrate_ratelimited(int node)
 {
 	return false;
 }
+#endif /* CONFIG_BALANCE_NUMA */
 
+#if defined(CONFIG_BALANCE_NUMA) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
+extern int migrate_misplaced_transhuge_page(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			pmd_t *pmd, pmd_t entry,
+			unsigned long address,
+			struct page *page, int node);
+#else
 static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, pmd_t entry,
@@ -103,6 +105,6 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 {
 	return -EAGAIN;
 }
-#endif /* CONFIG_BALANCE_NUMA */
+#endif /* CONFIG_BALANCE_NUMA && CONFIG_TRANSPARENT_HUGEPAGE*/
 
 #endif /* _LINUX_MIGRATE_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index 4b1b239..b6fe2d2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1602,7 +1602,9 @@ int migrate_misplaced_page(struct page *page, int node)
 out:
 	return isolated;
 }
+#endif /* CONFIG_BALANCE_NUMA */
 
+#if defined(CONFIG_BALANCE_NUMA) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
 int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 				struct vm_area_struct *vma,
 				pmd_t *pmd, pmd_t entry,
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
