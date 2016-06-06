Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id B8C648294C
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 10:08:25 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id a9so29506409pat.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 07:08:25 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 4si19998679paf.244.2016.06.06.07.08.15
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 07:08:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 13/32] thp: run vma_adjust_trans_huge() outside i_mmap_rwsem
Date: Mon,  6 Jun 2016 17:06:50 +0300
Message-Id: <1465222029-45942-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

vma_addjust_trans_huge() splits pmd if it's crossing VMA boundary.
During split we munlock the huge page which requires rmap walk.
rmap wants to take the lock on its own.

Let's move vma_adjust_trans_huge() outside i_mmap_rwsem to fix this.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index de2c1769cc68..02990e7dd70e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -675,6 +675,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
+	vma_adjust_trans_huge(vma, start, end, adjust_next);
+
 	if (file) {
 		mapping = file->f_mapping;
 		root = &mapping->i_mmap;
@@ -695,8 +697,6 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
-	vma_adjust_trans_huge(vma, start, end, adjust_next);
-
 	anon_vma = vma->anon_vma;
 	if (!anon_vma && adjust_next)
 		anon_vma = next->anon_vma;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
