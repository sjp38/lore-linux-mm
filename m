Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6722C6B0262
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:22:56 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fl4so17768178pad.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:22:56 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id q74si12880319pfq.207.2016.02.11.06.22.13
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:22:13 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 18/28] thp: prepare change_huge_pmd() for file thp
Date: Thu, 11 Feb 2016 17:21:46 +0300
Message-Id: <1455200516-132137-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

change_huge_pmd() has assert which is not relvant for file page.
For shared mapping it's perfectly fine to have page table entry
writable, without explicit mkwrite.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 00f10d323039..8e2d84698c15 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1756,7 +1756,6 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 				entry = pmd_mkwrite(entry);
 			ret = HPAGE_PMD_NR;
 			set_pmd_at(mm, addr, pmd, entry);
-			BUG_ON(!preserve_write && pmd_write(entry));
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
