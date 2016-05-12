Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1376B0253
	for <linux-mm@kvack.org>; Thu, 12 May 2016 11:41:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 4so152093688pfw.0
        for <linux-mm@kvack.org>; Thu, 12 May 2016 08:41:38 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id m66si18095482pfm.117.2016.05.12.08.41.31
        for <linux-mm@kvack.org>;
        Thu, 12 May 2016 08:41:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv8 13/32] thp: run vma_adjust_trans_huge() outside i_mmap_rwsem
Date: Thu, 12 May 2016 18:40:53 +0300
Message-Id: <1463067672-134698-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index bd2e1a533bc1..df3976af9302 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -678,6 +678,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
+	vma_adjust_trans_huge(vma, start, end, adjust_next);
+
 	if (file) {
 		mapping = file->f_mapping;
 		root = &mapping->i_mmap;
@@ -698,8 +700,6 @@ again:			remove_next = 1 + (end > next->vm_end);
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
