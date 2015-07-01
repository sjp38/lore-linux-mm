Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1AFAF6B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 14:31:03 -0400 (EDT)
Received: by qkeo142 with SMTP id o142so35825411qke.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 11:31:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g13si3279279qhc.50.2015.07.01.11.31.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 11:31:02 -0700 (PDT)
Date: Wed, 1 Jul 2015 14:30:58 -0400
From: Aristeu Rozanski <aris@redhat.com>
Subject: [PATCH] mempolicy: get rid of duplicated check for vma(VM_PFNMAP) in
 queue_pages_range()
Message-ID: <20150701183058.GD32640@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Dave Hansen <dave.hansen@intel.com>, Pavel Emelyanov <xemul@parallels.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org

This check was introduced as part of
	6f4576e3687 - mempolicy: apply page table walker on queue_pages_range()
which got duplicated by
	48684a65b4e - mm: pagewalk: fix misbehavior of walk_page_range for vma(VM_PFNMAP)
by reintroducing it earlier on queue_page_test_walk()

Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Aristeu Rozanski <aris@redhat.com>

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 99d4c1d..9885d07 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -608,9 +608,6 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 
 	qp->prev = vma;
 
-	if (vma->vm_flags & VM_PFNMAP)
-		return 1;
-
 	if (flags & MPOL_MF_LAZY) {
 		/* Similar to task_numa_work, skip inaccessible VMAs */
 		if (vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
