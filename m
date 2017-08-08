Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 804096B0492
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 10:36:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k190so36271160pge.9
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 07:36:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b14si983447pfl.19.2017.08.08.07.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 07:36:27 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78EXuMs064075
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 10:36:27 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c7ce6wn66-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 10:36:26 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 15:36:24 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 14/16] x86/mm: Add support for SPF events
Date: Tue,  8 Aug 2017 16:35:47 +0200
In-Reply-To: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1502202949-8138-15-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Add support for the new speculative page faults software events.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/x86/mm/fault.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 46fb9c2a832d..17985f11b9da 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1374,8 +1374,12 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		 * requires the vma pointer to be set. So in that case,
 		 * we fall through the normal path.
 		 */
-		if (!(fault & VM_FAULT_RETRY || fault & VM_FAULT_ERROR))
+		if (!(fault & VM_FAULT_RETRY || fault & VM_FAULT_ERROR)) {
+			perf_sw_event(PERF_COUNT_SW_SPF_DONE, 1,
+				      regs, address);
 			goto done;
+		}
+		perf_sw_event(PERF_COUNT_SW_SPF_FAILED, 1, regs, address);
 	}
 
 	/*
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
