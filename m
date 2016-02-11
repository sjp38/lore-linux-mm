Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 70E026B027E
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:29:16 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id e127so30289497pfe.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:29:16 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id rk9si12923553pab.31.2016.02.11.06.23.00
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:23:00 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 19/28] thp: run vma_adjust_trans_huge() outside i_mmap_rwsem
Date: Thu, 11 Feb 2016 17:21:47 +0300
Message-Id: <1455200516-132137-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

vma_addjust_trans_huge() splits pmd if it's crossing VMA boundary.
During split we munlock the huge page which requires rmap walk.
rmap wants to take the lock on its own.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 2f2415a7a688..c9d0c412b6dd 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -802,6 +802,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
+	vma_adjust_trans_huge(vma, start, end, adjust_next);
+
 	if (file) {
 		mapping = file->f_mapping;
 		root = &mapping->i_mmap;
@@ -822,8 +824,6 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
-	vma_adjust_trans_huge(vma, start, end, adjust_next);
-
 	anon_vma = vma->anon_vma;
 	if (!anon_vma && adjust_next)
 		anon_vma = next->anon_vma;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
