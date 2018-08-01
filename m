Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3CB6B0005
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 09:08:17 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j15-v6so6625246pfi.10
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 06:08:17 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j135-v6si18107384pfd.207.2018.08.01.06.08.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 06:08:16 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] ia64: Make stack VMA anonymous
Date: Wed,  1 Aug 2018 16:08:01 +0300
Message-Id: <20180801130801.30095-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

IA64 allocates stack in a custom way. Stack has to be marked as
anonymous otherwise the process will be killed with SIGBUS on the first
access to the stack.

Add missing vma_set_anonymous().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Tony Luck <tony.luck@intel.com>
Fixes: bfd40eaff5ab ("mm: fix vma_is_anonymous() false-positives")
---
 arch/ia64/mm/init.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index e6c6dfd98de2..99044db28040 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -116,6 +116,7 @@ ia64_init_addr_space (void)
 	 */
 	vma = vm_area_alloc(current->mm);
 	if (vma) {
+		vma_set_anonymous(vma);
 		vma->vm_start = current->thread.rbs_bot & PAGE_MASK;
 		vma->vm_end = vma->vm_start + PAGE_SIZE;
 		vma->vm_flags = VM_DATA_DEFAULT_FLAGS|VM_GROWSUP|VM_ACCOUNT;
-- 
2.18.0
