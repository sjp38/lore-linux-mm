Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E171C9C0024
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:26 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so7081228pab.6
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:26 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 45/63] mm: numa: copy cpupid on page migration
Date: Mon,  7 Oct 2013 11:29:23 +0100
Message-Id: <1381141781-10992-46-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

After page migration, the new page has the nidpid unset. This makes
every fault on a recently migrated page look like a first numa fault,
leading to another page migration.

Copying over the nidpid at page migration time should prevent erroneous
migrations of recently migrated pages.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/migrate.c b/mm/migrate.c
index c85f3fc..0626af6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -443,6 +443,8 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
  */
 void migrate_page_copy(struct page *newpage, struct page *page)
 {
+	int cpupid;
+
 	if (PageHuge(page) || PageTransHuge(page))
 		copy_huge_page(newpage, page);
 	else
@@ -479,6 +481,13 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 			__set_page_dirty_nobuffers(newpage);
  	}
 
+	/*
+	 * Copy NUMA information to the new page, to prevent over-eager
+	 * future migrations of this same page.
+	 */
+	cpupid = page_cpupid_xchg_last(page, -1);
+	page_cpupid_xchg_last(newpage, cpupid);
+
 	mlock_migrate_page(newpage, page);
 	ksm_migrate_page(newpage, page);
 	/*
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
