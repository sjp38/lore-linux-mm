Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5E56B0038
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 10:35:31 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so72064068pad.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 07:35:30 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id pj9si33646067pbb.124.2015.10.06.07.35.30
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 07:35:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] hugetlb: clear PG_reserved before setting PG_head on gigantic pages
Date: Tue,  6 Oct 2015 17:35:24 +0300
Message-Id: <1444142124-21921-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PF_NO_COMPOUND for PG_reserved assumes we don't use PG_reserved for
compound pages. And we generally don't. But during allocation of
gigantic pages we set PG_head before clearing PG_reserved and
__ClearPageReserved() steps on the VM_BUG_ON_PAGE().

The fix is trivial: set PG_head after PG_reserved.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
---

Andrew, this patch can be folded into "page-flags: define PG_reserved behavior on compound pages".

---
 mm/hugetlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6ecf61ffa65d..bd3f3e20313b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1258,8 +1258,8 @@ static void prep_compound_gigantic_page(struct page *page, unsigned int order)
 
 	/* we rely on prep_new_huge_page to set the destructor */
 	set_compound_order(page, order);
-	__SetPageHead(page);
 	__ClearPageReserved(page);
+	__SetPageHead(page);
 	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
 		/*
 		 * For gigantic hugepages allocated through bootmem at
-- 
2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
