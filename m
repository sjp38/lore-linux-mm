Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 449356B0258
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 21:41:00 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id yy13so21424566pab.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 18:41:00 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rd7si9135398pab.90.2016.02.10.18.40.59
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 18:40:59 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp, dax: do not try to withdraw pgtable from non-anon VMA
Date: Thu, 11 Feb 2016 05:40:45 +0300
Message-Id: <1455158445-76664-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

DAX doesn't deposit pgtables when it maps huge pages: nothing to
withdraw. It can lead to crash.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5404f7534366..ca7f21516c3a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1706,7 +1706,8 @@ bool move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
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
