Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 20EF46B049D
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 10:36:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r13so34183235pfd.14
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 07:36:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z21si1003526pfi.49.2017.08.08.07.36.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 07:36:31 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78EZHDu130103
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 10:36:30 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c7eqnjkmt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 10:36:29 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 15:36:27 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 15/16] powerpc/mm: Add support for SPF events
Date: Tue,  8 Aug 2017 16:35:48 +0200
In-Reply-To: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1502202949-8138-16-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Add support for the new speculative page faults software events.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/mm/fault.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index c6cd40901dd0..112c4bc9da70 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -306,8 +306,13 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 			flags |= FAULT_FLAG_WRITE;
 
 		fault = handle_speculative_fault(mm, address, flags);
-		if (!(fault & VM_FAULT_RETRY || fault & VM_FAULT_ERROR))
+		if (!(fault & VM_FAULT_RETRY || fault & VM_FAULT_ERROR)) {
+			perf_sw_event(PERF_COUNT_SW_SPF_DONE, 1,
+				      regs, address);
 			goto done;
+		}
+
+		perf_sw_event(PERF_COUNT_SW_SPF_FAILED, 1, regs, address);
 
 		/*
 		 * Resetting flags since the following code assumes
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
