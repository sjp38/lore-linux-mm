Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 325346B0037
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 05:56:03 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so3449697pdb.5
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 02:56:02 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id qn15si11352809pab.176.2014.07.15.02.56.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 15 Jul 2014 02:56:02 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8Q00HOZZKY2290@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 15 Jul 2014 10:55:46 +0100 (BST)
Subject: [PATCH] mm: fix faulting range in do_fault_around
From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Date: Tue, 15 Jul 2014 13:55:39 +0400
Message-id: <20140715095539.2086.44482.stgit@buzz>
In-reply-to: 
 <CALYGNiM9Fu9-i7hXMQNTUP69RfydN+2NqO29wZYd+4Gn25GbCQ@mail.gmail.com>
References: <CALYGNiM9Fu9-i7hXMQNTUP69RfydN+2NqO29wZYd+4Gn25GbCQ@mail.gmail.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
Cc: Ingo Korb <ingo.korb@tu-dortmund.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ning Qu <quning@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>

From: Konstantin Khlebnikov <koct9i@gmail.com>

do_fault_around shoudn't cross pmd boundaries.

This patch does calculation in terms of addresses rather than pgoff.
It looks much cleaner in this way. Probably it's worth to replace
vmf->max_pgoff with vmf->end_address as well.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Reported-by: "Ingo Korb" <ingo.korb@tu-dortmund.de>
---
 mm/memory.c |   26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index d67fd9f..f27638a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2831,33 +2831,29 @@ late_initcall(fault_around_debugfs);
 static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 		pte_t *pte, pgoff_t pgoff, unsigned int flags)
 {
-	unsigned long start_addr;
+	unsigned long start_addr, end_addr;
 	pgoff_t max_pgoff;
 	struct vm_fault vmf;
 	int off;
 
-	start_addr = max(address & fault_around_mask(), vma->vm_start);
-	off = ((address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
+	start_addr = max3(vma->vm_start, address & PMD_MASK,
+			  address & fault_around_mask());
+
+	end_addr = min3(vma->vm_end, ALIGN(address, PMD_SIZE),
+			start_addr + PAGE_ALIGN(fault_around_bytes));
+
+	off = (address - start_addr) >> PAGE_SHIFT;
 	pte -= off;
 	pgoff -= off;
-
-	/*
-	 *  max_pgoff is either end of page table or end of vma
-	 *  or fault_around_pages() from pgoff, depending what is nearest.
-	 */
-	max_pgoff = pgoff - ((start_addr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
-		PTRS_PER_PTE - 1;
-	max_pgoff = min3(max_pgoff, vma_pages(vma) + vma->vm_pgoff - 1,
-			pgoff + fault_around_pages() - 1);
+	max_pgoff = pgoff + ((end_addr - start_addr) >> PAGE_SHIFT) - 1;
 
 	/* Check if it makes any sense to call ->map_pages */
 	while (!pte_none(*pte)) {
-		if (++pgoff > max_pgoff)
-			return;
 		start_addr += PAGE_SIZE;
-		if (start_addr >= vma->vm_end)
+		if (start_addr >= end_addr)
 			return;
 		pte++;
+		pgoff++;
 	}
 
 	vmf.virtual_address = (void __user *) start_addr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
