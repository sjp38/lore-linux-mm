Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 69F106B0032
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 06:24:03 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so26539402pab.1
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 03:24:03 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id dd8si35030800pdb.122.2015.06.24.03.24.02
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 03:24:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: fix status code move_pages() returns for zero page
Date: Wed, 24 Jun 2015 13:23:48 +0300
Message-Id: <1435141428-98266-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>

Man page for move_pages(2) specifies that status code for zero page is
supposed to be -EFAULT. Currently kernel return -ENOENT in this case.

follow_page() can do it for us, if we would ask for FOLL_DUMP.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Hugh Dickins <hughd@google.com>
---
 mm/migrate.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 236ee25e79d9..d3529d620a5b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1222,7 +1222,9 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		if (!vma || pp->addr < vma->vm_start || !vma_migratable(vma))
 			goto set_status;
 
-		page = follow_page(vma, pp->addr, FOLL_GET|FOLL_SPLIT);
+		/* FOLL_DUMP to ignore special (like zero) pages */
+		page = follow_page(vma, pp->addr,
+				FOLL_GET | FOLL_SPLIT | FOLL_DUMP);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
@@ -1232,10 +1234,6 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		if (!page)
 			goto set_status;
 
-		/* Use PageReserved to check for zero page */
-		if (PageReserved(page))
-			goto put_and_set;
-
 		pp->page = page;
 		err = page_to_nid(page);
 
@@ -1392,18 +1390,14 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 		if (!vma || addr < vma->vm_start)
 			goto set_status;
 
-		page = follow_page(vma, addr, 0);
+		/* FOLL_DUMP to ignore special (like zero) pages */
+		page = follow_page(vma, addr, FOLL_DUMP);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
 			goto set_status;
 
-		err = -ENOENT;
-		/* Use PageReserved to check for zero page */
-		if (!page || PageReserved(page))
-			goto set_status;
-
-		err = page_to_nid(page);
+		err = page ? page_to_nid(page) : -ENOENT;
 set_status:
 		*status = err;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
