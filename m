Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 58D6F828DF
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 17:59:46 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fe3so93989251pab.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:59:46 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id w13si6174544pas.67.2016.03.11.14.59.30
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 14:59:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 10/25] thp: handle file COW faults
Date: Sat, 12 Mar 2016 01:59:02 +0300
Message-Id: <1457737157-38573-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

File COW for THP is handled on pte level: just split the pmd.

It's not clear how benefitial would be allocation of huge pages on COW
faults. And it would require some code to make them work.

I think at some point we can consider teaching khugepaged to collapse
pages in COW mappings, but allocating huge on fault is probably
overkill.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index f7a73b6cabac..c0a2510b9e15 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3366,6 +3366,11 @@ static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
 	if (fe->vma->vm_ops->pmd_fault)
 		return fe->vma->vm_ops->pmd_fault(fe->vma, fe->address, fe->pmd,
 				fe->flags);
+
+	/* COW handled on pte level: split pmd */
+	VM_BUG_ON_VMA(fe->vma->vm_flags & VM_SHARED, fe->vma);
+	split_huge_pmd(fe->vma, fe->pmd, fe->address);
+
 	return VM_FAULT_FALLBACK;
 }
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
