Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id CC056280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 07:53:33 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so60258698pac.2
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 04:53:33 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ns8si18307621pdb.234.2015.07.17.04.53.26
        for <linux-mm@kvack.org>;
        Fri, 17 Jul 2015 04:53:26 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 5/6] mm: use vma_is_anonymous() in create_huge_pmd() and wp_huge_pmd()
Date: Fri, 17 Jul 2015 14:53:12 +0300
Message-Id: <1437133993-91885-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's use helper rather than direct check of vma->vm_ops to distinguish
anonymous VMA.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index c70252ca9ef9..1c139aa94aff 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3235,7 +3235,7 @@ out:
 static int create_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pmd_t *pmd, unsigned int flags)
 {
-	if (!vma->vm_ops)
+	if (vma_is_anonymous(vma))
 		return do_huge_pmd_anonymous_page(mm, vma, address, pmd, flags);
 	if (vma->vm_ops->pmd_fault)
 		return vma->vm_ops->pmd_fault(vma, address, pmd, flags);
@@ -3246,7 +3246,7 @@ static int wp_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pmd_t *pmd, pmd_t orig_pmd,
 			unsigned int flags)
 {
-	if (!vma->vm_ops)
+	if (vma_is_anonymous(vma))
 		return do_huge_pmd_wp_page(mm, vma, address, pmd, orig_pmd);
 	if (vma->vm_ops->pmd_fault)
 		return vma->vm_ops->pmd_fault(vma, address, pmd, flags);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
