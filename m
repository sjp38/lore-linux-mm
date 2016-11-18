Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 252CD6B03F8
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:09 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a8so137604267pfg.0
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:09:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w67si7770016pgb.145.2016.11.18.03.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 03:09:08 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAIB93cb068757
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:07 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26sytej0fs-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:07 -0500
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 18 Nov 2016 11:09:00 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 891B62190056
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:08:09 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAIB8uCN43253928
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:08:56 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAIB8u5Y020927
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:08:56 -0700
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 7/7] mm,x86: Add speculative pagefault handling
Date: Fri, 18 Nov 2016 12:08:51 +0100
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
References: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
 <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
References: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
Message-Id: <c396be948a2c726ea3018c5eb7aaab94dbdac412.1479465699.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A . Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

From: Peter Zijlstra <peterz@infradead.org>

Try a speculative fault before acquiring mmap_sem, if it returns with
VM_FAULT_RETRY continue with the mmap_sem acquisition and do the
traditional fault.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/mm/fault.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index dc8023060456..5313ec9ac57e 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1276,6 +1276,16 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	if (error_code & PF_INSTR)
 		flags |= FAULT_FLAG_INSTRUCTION;
 
+	if (error_code & PF_USER) {
+		fault = handle_speculative_fault(mm, address,
+					flags & ~FAULT_FLAG_ALLOW_RETRY);
+
+		if (fault & VM_FAULT_RETRY)
+			goto retry;
+
+		goto done;
+	}
+
 	/*
 	 * When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in
@@ -1379,7 +1389,15 @@ good_area:
 		return;
 	}
 
+	if (unlikely(fault & VM_FAULT_RETRY)) {
+		if (fatal_signal_pending(current))
+			return;
+
+		goto done;
+	}
+
 	up_read(&mm->mmap_sem);
+done:
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, vma, fault);
 		return;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
