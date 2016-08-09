Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3446B025F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 08:34:47 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id pp5so21359183pac.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 05:34:47 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id wi6si42575341pab.81.2016.08.09.05.34.46
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 05:34:46 -0700 (PDT)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH] rmap: Fix compound check logic in page_remove_file_rmap
Date: Tue,  9 Aug 2016 13:34:35 +0100
Message-Id: <1470746075-20856-1-git-send-email-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, shijie.huang@arm.com, will.deacon@arm.com, catalin.marinas@arm.com

In page_remove_file_rmap(.) we have the following check:
  VM_BUG_ON_PAGE(compound && !PageTransHuge(page), page);

This is meant to check for either HugeTLB pages or THP when a compound
page is passed in.

Unfortunately, if one disables CONFIG_TRANSPARENT_HUGEPAGE, then
PageTransHuge(.) will always return false provoking BUGs when one runs
the libhugetlbfs test suite.

Changing the definition of PageTransHuge to be defined for
!CONFIG_TRANSPARENT_HUGEPAGE turned out to provoke build bugs; so this
patch instead replaces the errant check with:
  PageTransHuge(page) || PageHuge(page)

Fixes: dd78fedde4b9 ("rmap: support file thp")
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Steve Capper <steve.capper@arm.com>
---
 mm/rmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 709bc83..ad8fc51 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1303,7 +1303,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 {
 	int i, nr = 1;
 
-	VM_BUG_ON_PAGE(compound && !PageTransHuge(page), page);
+	VM_BUG_ON_PAGE(compound && !(PageTransHuge(page) || PageHuge(page)), page);
 	lock_page_memcg(page);
 
 	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
