Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BC1C76B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:44:42 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id v10so11760990pde.3
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 04:44:42 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id yr3si11940942pbb.248.2015.01.26.04.44.41
        for <linux-mm@kvack.org>;
        Mon, 26 Jan 2015 04:44:41 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] memcg: fix static checker warning
Date: Mon, 26 Jan 2015 14:44:08 +0200
Message-Id: <1422276248-40456-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch "mm: remove rest usage of VM_NONLINEAR and pte_file()" from
Jan 17, 2015, leads to the following static checker warning:

        mm/memcontrol.c:4794 mc_handle_file_pte()
        warn: passing uninitialized 'pgoff'

After the patch, the only case when mc_handle_file_pte() called is
pte_none(ptent). The 'if' check is redundant and lead to the warning.
Let's drop it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 mm/memcontrol.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cd42f14d138a..a6140c0764f4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4792,8 +4792,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 		return NULL;
 
 	mapping = vma->vm_file->f_mapping;
-	if (pte_none(ptent))
-		pgoff = linear_page_index(vma, addr);
+	pgoff = linear_page_index(vma, addr);
 
 	/* page is moved even if it's not RSS of this task(page-faulted). */
 #ifdef CONFIG_SWAP
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
