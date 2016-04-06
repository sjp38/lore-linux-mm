Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 480836B027A
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:51:55 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id td3so41636289pab.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:51:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id o13si7277125pfj.73.2016.04.06.15.51.32
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:32 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 13/30] thp: prepare change_huge_pmd() for file thp
Date: Thu,  7 Apr 2016 01:51:03 +0300
Message-Id: <1459983080-106718-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

change_huge_pmd() has assert which is not relvant for file page.
For shared mapping it's perfectly fine to have page table entry
writable, without explicit mkwrite.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a4163e023eb6..4c3f94a443bc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1798,7 +1798,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 				entry = pmd_mkwrite(entry);
 			ret = HPAGE_PMD_NR;
 			set_pmd_at(mm, addr, pmd, entry);
-			BUG_ON(!preserve_write && pmd_write(entry));
+			BUG_ON(vma_is_anonymous(vma) && !preserve_write &&
+					pmd_write(entry));
 		}
 		spin_unlock(ptl);
 	}
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
