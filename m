Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4226B0073
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 04:08:03 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so5028379pbb.18
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 01:08:03 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id sw1si6670475pbc.222.2013.12.09.01.08.01
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 01:08:02 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 2/7] mm/migrate: correct failure handling if !hugepage_migration_support()
Date: Mon,  9 Dec 2013 18:10:43 +0900
Message-Id: <1386580248-22431-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We should remove the page from the list if we fail without ENOSYS,
since migrate_pages() consider error cases except -ENOMEM and -EAGAIN
as permanent failure and it assumes that the page would be removed from
the list. Without this patch, we could overcount number of failure.

In addition, we should put back the new hugepage if
!hugepage_migration_support(). If not, we would leak hugepage memory.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/migrate.c b/mm/migrate.c
index c6ac87a..b1cfd01 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1011,7 +1011,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 {
 	int rc = 0;
 	int *result = NULL;
-	struct page *new_hpage = get_new_page(hpage, private, &result);
+	struct page *new_hpage;
 	struct anon_vma *anon_vma = NULL;
 
 	/*
@@ -1021,9 +1021,12 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	 * tables or check whether the hugepage is pmd-based or not before
 	 * kicking migration.
 	 */
-	if (!hugepage_migration_support(page_hstate(hpage)))
+	if (!hugepage_migration_support(page_hstate(hpage))) {
+		putback_active_hugepage(hpage);
 		return -ENOSYS;
+	}
 
+	new_hpage = get_new_page(hpage, private, &result);
 	if (!new_hpage)
 		return -ENOMEM;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
