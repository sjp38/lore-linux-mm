Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6F16B0253
	for <linux-mm@kvack.org>; Thu, 12 May 2016 11:41:36 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id yl2so110325718pac.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 08:41:36 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vy4si18289353pab.231.2016.05.12.08.41.31
        for <linux-mm@kvack.org>;
        Thu, 12 May 2016 08:41:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv8 10/32] thp: handle file COW faults
Date: Thu, 12 May 2016 18:40:50 +0300
Message-Id: <1463067672-134698-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 23de0567db18..cba29c033702 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3388,6 +3388,11 @@ static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
