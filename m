Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21B366B039F
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 10:22:02 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q97so8650630wrb.14
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 07:22:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z142si1712398wmc.38.2017.06.09.07.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 07:22:00 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v59EIbxj060680
	for <linux-mm@kvack.org>; Fri, 9 Jun 2017 10:21:59 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ayvk6thty-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Jun 2017 10:21:59 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 9 Jun 2017 15:21:57 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v4 18/20] x86/mm: Update the handle_speculative_fault's path
Date: Fri,  9 Jun 2017 16:21:07 +0200
In-Reply-To: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1497018069-17790-19-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

If handle_speculative_fault failed due to a VM ERROR, we try again the
slow path to allow the signal to be delivered.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/x86/mm/fault.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 0c0b45dfda76..02c0b884ca18 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1369,10 +1369,14 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		fault = handle_speculative_fault(mm, address,
 					flags & ~FAULT_FLAG_ALLOW_RETRY);
 
-		if (fault & VM_FAULT_RETRY)
-			goto retry;
-
-		goto done;
+		/*
+		 * We also check against VM_FAULT_ERROR because we have to
+		 * raise a signal by calling later mm_fault_error() which
+		 * requires the vma pointer to be set. So in that case,
+		 * we fall through the normal path.
+		 */
+		if (!(fault & VM_FAULT_RETRY || fault & VM_FAULT_ERROR))
+			goto done;
 	}
 
 	/*
@@ -1478,20 +1482,13 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		return;
 	}
 
-	if (unlikely(fault & VM_FAULT_RETRY)) {
-		if (fatal_signal_pending(current))
-			return;
-
-		goto done;
-	}
-
 	up_read(&mm->mmap_sem);
-done:
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, vma, fault);
 		return;
 	}
 
+done:
 	/*
 	 * Major/minor page fault accounting. If any of the events
 	 * returned VM_FAULT_MAJOR, we account it as a major fault.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
