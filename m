Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E201E6B0390
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i137so1537694wmf.19
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:53:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s12si3742725wma.32.2017.04.27.08.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 08:53:31 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3RFnDus045452
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:29 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a34yd5fva-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:28 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 16:53:26 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v3 15/17] mm/spf: Add check on the VMA's flags
Date: Thu, 27 Apr 2017 17:52:54 +0200
In-Reply-To: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1493308376-23851-16-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

When handling speculative page fault we should check for the VMA's
access permission as it is done in handle_mm_fault() or access_error
in x86's fault handler.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index 3b28de5838c7..4d9c6331ada1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3756,6 +3756,30 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
 	if (address < vma->vm_start || vma->vm_end <= address)
 		goto unlock;
 
+	/* XXX Could we handle huge page here ? */
+	if (unlikely(is_vm_hugetlb_page(vma)))
+		goto unlock;
+
+	/*
+	 * The three following checks are copied from access_error from
+	 * arch/x86/mm/fault.c
+	 * XXX they may not be applicable to all architectures
+	 */
+	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
+				       flags & FAULT_FLAG_INSTRUCTION,
+				       flags & FAULT_FLAG_REMOTE))
+		goto unlock;
+
+	/* This is one is required to check that the VMA has write access set */
+	if (flags & FAULT_FLAG_WRITE) {
+		if (unlikely(!(vma->vm_flags & VM_WRITE)))
+			goto unlock;
+	} else {
+		/* XXX This may not be required */
+		if (unlikely(!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))))
+			goto unlock;
+	}
+
 	/*
 	 * We need to re-validate the VMA after checking the bounds, otherwise
 	 * we might have a false positive on the bounds.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
