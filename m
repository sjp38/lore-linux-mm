Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1F90B900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 02:15:50 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so107116pad.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 23:15:49 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id z1si30030476pda.165.2015.06.02.23.15.48
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 23:15:49 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 2/6] mm: keep dirty bit on anonymous page migration
Date: Wed,  3 Jun 2015 15:15:41 +0900
Message-Id: <1433312145-19386-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1433312145-19386-1-git-send-email-minchan@kernel.org>
References: <1433312145-19386-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

Currently, If VM migrates anonymous page, we lose dirty bit of
page table entry. Instead, VM translates dirty bit of page table
as PG_dirty of page flags. It was okay because dirty bit of
page table for anonymous page was no matter to swap out.
Instead, VM took care of PG_dirty.

However, with introducing MADV_FREE, it's important to keep
page table's dirty bit because It could make MADV_FREE handling
logics more straighforward without taking care of PG_dirty.

This patch aims for preparing to remove PG_dirty check for MADV_FREE.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/migrate.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/migrate.c b/mm/migrate.c
index 236ee25e79d9..add30c3aaaa9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -151,6 +151,10 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 	if (is_write_migration_entry(entry))
 		pte = maybe_mkwrite(pte, vma);
 
+	/* MADV_FREE relies on pte_dirty. */
+	if (PageAnon(new))
+		pte = pte_mkdirty(pte);
+
 #ifdef CONFIG_HUGETLB_PAGE
 	if (PageHuge(new)) {
 		pte = pte_mkhuge(pte);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
