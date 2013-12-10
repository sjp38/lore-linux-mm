Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f173.google.com (mail-ea0-f173.google.com [209.85.215.173])
	by kanga.kvack.org (Postfix) with ESMTP id A81496B003A
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:51:40 -0500 (EST)
Received: by mail-ea0-f173.google.com with SMTP id o10so2299740eaj.18
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:51:40 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e48si14851646eeh.197.2013.12.10.07.51.39
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 07:51:40 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/18] mm: numa: Do not clear PMD during PTE update scan
Date: Tue, 10 Dec 2013 15:51:22 +0000
Message-Id: <1386690695-27380-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If the PMD is flushed then a parallel fault in handle_mm_fault() will enter
the pmd_none and do_huge_pmd_anonymous_page() path where it'll attempt
to insert a huge zero page. This is wasteful so the patch avoids clearing
the PMD when setting pmd_numa.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/huge_memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index deae592..5a5da50 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1529,7 +1529,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			 */
 			if (!is_huge_zero_page(page) &&
 			    !pmd_numa(*pmd)) {
-				entry = pmdp_get_and_clear(mm, addr, pmd);
+				entry = *pmd;
 				entry = pmd_mknuma(entry);
 				ret = HPAGE_PMD_NR;
 			}
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
