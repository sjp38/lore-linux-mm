Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6ADB9828DF
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 17:59:48 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id u190so63852722pfb.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:59:48 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id x72si16742916pfi.196.2016.03.11.14.59.30
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 14:59:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 13/25] thp: prepare change_huge_pmd() for file thp
Date: Sat, 12 Mar 2016 01:59:05 +0300
Message-Id: <1457737157-38573-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

change_huge_pmd() has assert which is not relvant for file page.
For shared mapping it's perfectly fine to have page table entry
writable, without explicit mkwrite.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0ef06d47bd24..93f5b50490df 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1786,7 +1786,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
