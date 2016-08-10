Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2DFA6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 10:10:46 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so75468535pac.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 07:10:46 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id wv6si48682259pab.263.2016.08.10.07.10.45
        for <linux-mm@kvack.org>;
        Wed, 10 Aug 2016 07:10:45 -0700 (PDT)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH v2] rmap: Fix compound check logic in page_remove_file_rmap
Date: Wed, 10 Aug 2016 15:10:17 +0100
Message-Id: <1470838217-5889-1-git-send-email-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, shijie.huang@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, Steve Capper <steve.capper@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

In page_remove_file_rmap(.) we have the following check:
  VM_BUG_ON_PAGE(compound && !PageTransHuge(page), page);

This is meant to check for either HugeTLB pages or THP when a compound
page is passed in.

Unfortunately, if one disables CONFIG_TRANSPARENT_HUGEPAGE, then
PageTransHuge(.) will always return false, provoking BUGs when one runs
the libhugetlbfs test suite.

This patch replaces PageTransHuge(), with PageHead() which will work for
both HugeTLB and THP.

Fixes: dd78fedde4b9 ("rmap: support file thp")
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Steve Capper <steve.capper@arm.com>

---

v2 - switch to PageHead as suggested by Kirill.
---
 mm/rmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 709bc83..1180340 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1303,7 +1303,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 {
 	int i, nr = 1;
 
-	VM_BUG_ON_PAGE(compound && !PageTransHuge(page), page);
+	VM_BUG_ON_PAGE(compound && !PageHead(page), page);
 	lock_page_memcg(page);
 
 	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
