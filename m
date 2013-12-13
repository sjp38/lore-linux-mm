Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3E06B0038
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 01:50:36 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so2017816pbc.15
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 22:50:35 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id e8si774652pac.111.2013.12.12.22.50.33
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 22:50:34 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 2/6] mm/migrate: correct failure handling if !hugepage_migration_support()
Date: Fri, 13 Dec 2013 15:53:27 +0900
Message-Id: <1386917611-11319-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386917611-11319-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386917611-11319-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We should remove the page from the list if we fail with ENOSYS,
since migrate_pages() consider error cases except -ENOMEM and -EAGAIN
as permanent failure and it assumes that the page would be removed from
the list. Without this patch, we could overcount number of failure.

In addition, we should put back the new hugepage if
!hugepage_migration_support(). If not, we would leak hugepage memory.

Acked-by: Christoph Lameter <cl@linux.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
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
