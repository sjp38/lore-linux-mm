Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DD5066B0261
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 11:52:56 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id fl4so17624442pad.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:52:56 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id kr9si269966pab.190.2016.03.03.08.52.38
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 08:52:38 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 14/29] thp: handle file COW faults
Date: Thu,  3 Mar 2016 19:52:04 +0300
Message-Id: <1457023939-98083-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index ab9acc4d83a2..0acdd33bfe16 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3369,6 +3369,11 @@ static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
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
