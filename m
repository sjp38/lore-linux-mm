Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA6FA6B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 05:07:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b124so134453608pfb.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 02:07:12 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ur4si19287946pab.237.2016.05.26.02.07.11
        for <linux-mm@kvack.org>;
        Thu, 26 May 2016 02:07:11 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: thp: avoid false positive VM_BUG_ON_PAGE in page_move_anon_rmap()
Date: Thu, 26 May 2016 12:07:00 +0300
Message-Id: <1464253620-106404-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Mika Westerberg <mika.westerberg@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "[4.5]" <stable@vger.kernel.org>

If the page_move_anon_rmap() is refiling a pmd-splitted THP mapped in
a tail page from a pte, the "address" must be THP aligned in order for
the page->index bugcheck to pass in the CONFIG_DEBUG_VM=y builds.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: 6d0a07edd17c ("mm: thp: calculate the mapcount correctly for THP pages during WP faults")
Cc: <stable@vger.kernel.org>        [4.5]
Reported-and-Tested-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com
---
 mm/rmap.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/rmap.c b/mm/rmap.c
index 8a839935b18c..0ea5d9071b32 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1098,6 +1098,8 @@ void page_move_anon_rmap(struct page *page,
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_VMA(!anon_vma, vma);
+	if (IS_ENABLED(CONFIG_DEBUG_VM) && PageTransHuge(page))
+		address &= HPAGE_PMD_MASK;
 	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);
 
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
