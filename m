Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1CB6B03A2
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 10:22:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k30so8646602wrc.9
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 07:22:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l32si1427377wre.137.2017.06.09.07.22.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 07:22:06 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v59EIfoC062071
	for <linux-mm@kvack.org>; Fri, 9 Jun 2017 10:22:04 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2aysj4m229-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Jun 2017 10:22:04 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 9 Jun 2017 15:22:02 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v4 20/20] mm/spf: Clear FAULT_FLAG_KILLABLE in the speculative path
Date: Fri,  9 Jun 2017 16:21:09 +0200
In-Reply-To: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1497018069-17790-21-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

The flag FAULT_FLAG_KILLABLE should be unset to not allow the mmap_sem
to released in __lock_page_or_retry().

In this patch the unsetting of the flag FAULT_FLAG_ALLOW_RETRY is also
moved into handle_speculative_fault() since this has to be done for
all architectures.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/mm/fault.c | 3 +--
 arch/x86/mm/fault.c     | 3 +--
 mm/memory.c             | 6 +++++-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 6dd6a50f412f..4b6d0ed517ca 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -304,8 +304,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 		if (is_write)
 			flags |= FAULT_FLAG_WRITE;
 
-		fault = handle_speculative_fault(mm, address,
-					 flags & ~FAULT_FLAG_ALLOW_RETRY);
+		fault = handle_speculative_fault(mm, address, flags);
 		if (!(fault & VM_FAULT_RETRY || fault & VM_FAULT_ERROR))
 			goto done;
 
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 02c0b884ca18..c62a7ea5e27b 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1366,8 +1366,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		flags |= FAULT_FLAG_INSTRUCTION;
 
 	if (error_code & PF_USER) {
-		fault = handle_speculative_fault(mm, address,
-					flags & ~FAULT_FLAG_ALLOW_RETRY);
+		fault = handle_speculative_fault(mm, address, flags);
 
 		/*
 		 * We also check against VM_FAULT_ERROR because we have to
diff --git a/mm/memory.c b/mm/memory.c
index 5b158549789b..35a311b0d314 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3945,7 +3945,6 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 {
 	struct vm_fault vmf = {
 		.address = address,
-		.flags = flags | FAULT_FLAG_SPECULATIVE,
 	};
 	pgd_t *pgd;
 	p4d_t *p4d;
@@ -3954,6 +3953,10 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	int dead, seq, idx, ret = VM_FAULT_RETRY;
 	struct vm_area_struct *vma;
 
+	/* Clear flags that may lead to release the mmap_sem to retry */
+	flags &= ~(FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_KILLABLE);
+	flags |= FAULT_FLAG_SPECULATIVE;
+
 	idx = srcu_read_lock(&vma_srcu);
 	vma = find_vma_srcu(mm, address);
 	if (!vma)
@@ -4040,6 +4043,7 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	vmf.pgoff = linear_page_index(vma, address);
 	vmf.gfp_mask = __get_fault_gfp_mask(vma);
 	vmf.sequence = seq;
+	vmf.flags = flags;
 
 	local_irq_enable();
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
