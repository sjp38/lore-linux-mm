Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 2CB136B000E
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 12:12:42 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/6] mm: numa: Take THP into account when migrating pages for NUMA balancing
Date: Tue, 22 Jan 2013 17:12:38 +0000
Message-Id: <1358874762-19717-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1358874762-19717-1-git-send-email-mgorman@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Wanpeng Li pointed out that numamigrate_isolate_page() assumes that only one
base page is being migrated when in fact it can also be checking THP. The
consequences are that a migration will be attempted when a target node
is nearly full and fail later. It's unlikely to be user-visible but it
should be fixed. While we are there, migrate_balanced_pgdat() should treat
nr_migrate_pages as an unsigned long as it is treated as a watermark.

Suggested-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index c387786..73e432d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1459,7 +1459,7 @@ int migrate_vmas(struct mm_struct *mm, const nodemask_t *to,
  * pages. Currently it only checks the watermarks which crude
  */
 static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
-				   int nr_migrate_pages)
+				   unsigned long nr_migrate_pages)
 {
 	int z;
 	for (z = pgdat->nr_zones - 1; z >= 0; z--) {
@@ -1557,8 +1557,10 @@ int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
 	int ret = 0;
 
+	VM_BUG_ON(compound_order(page) && !PageTransHuge(page));
+
 	/* Avoid migrating to a node that is nearly full */
-	if (migrate_balanced_pgdat(pgdat, 1)) {
+	if (migrate_balanced_pgdat(pgdat, 1UL << compound_order(page))) {
 		int page_lru;
 
 		if (isolate_lru_page(page)) {
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
