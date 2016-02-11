Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4F86B0255
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:22:14 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id jp17so685389pab.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:22:14 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 64si12883266pfi.163.2016.02.11.06.22.05
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:22:05 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 01/28] thp, dax: do not try to withdraw pgtable from non-anon VMA
Date: Thu, 11 Feb 2016 17:21:29 +0300
Message-Id: <1455200516-132137-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

DAX doesn't deposit pgtables when it maps huge pages: nothing to
withdraw. It can lead to crash.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8ca1718f7df3..2057a3b7cc24 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1730,7 +1730,8 @@ bool move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		pmd = pmdp_huge_get_and_clear(mm, old_addr, old_pmd);
 		VM_BUG_ON(!pmd_none(*new_pmd));
 
-		if (pmd_move_must_withdraw(new_ptl, old_ptl)) {
+		if (pmd_move_must_withdraw(new_ptl, old_ptl) &&
+				vma_is_anonymous(vma)) {
 			pgtable_t pgtable;
 			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
 			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
