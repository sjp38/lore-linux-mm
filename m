Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 74A8D6B003C
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 03:52:09 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so262041eek.29
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 00:52:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id s8si44312514eeh.17.2013.12.03.00.52.08
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 00:52:08 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/15] mm: numa: Do not clear PMD during PTE update scan
Date: Tue,  3 Dec 2013 08:51:54 +0000
Message-Id: <1386060721-3794-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1386060721-3794-1-git-send-email-mgorman@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If the PMD is flushed then a parallel fault in handle_mm_fault() will
enter the pmd_none and do_huge_pmd_anonymous_page() path where it'll
attempt to insert a huge zero page. This is wasteful so the patch
avoids clearing the PMD when setting pmd_numa.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 203b5bc..d6c3bf4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1474,20 +1474,24 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
 		pmd_t entry;
-		entry = pmdp_get_and_clear(mm, addr, pmd);
+
 		if (!prot_numa) {
+			entry = pmdp_get_and_clear(mm, addr, pmd);
 			entry = pmd_modify(entry, newprot);
 			BUG_ON(pmd_write(entry));
+			set_pmd_at(mm, addr, pmd, entry);
 		} else {
 			struct page *page = pmd_page(*pmd);
+			entry = *pmd;
 
 			/* only check non-shared pages */
 			if (page_mapcount(page) == 1 &&
 			    !pmd_numa(*pmd)) {
 				entry = pmd_mknuma(entry);
+				set_pmd_at(mm, addr, pmd, entry);
 			}
 		}
-		set_pmd_at(mm, addr, pmd, entry);
+
 		spin_unlock(&vma->vm_mm->page_table_lock);
 		ret = 1;
 	}
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
