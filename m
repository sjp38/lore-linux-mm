Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 053166B0492
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 14:08:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e199so5865693pfh.3
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 11:08:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o11si1922767pfg.286.2017.09.08.11.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 11:08:25 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v88I88YF111486
	for <linux-mm@kvack.org>; Fri, 8 Sep 2017 14:08:24 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cux2teab0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 08 Sep 2017 14:08:24 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 8 Sep 2017 19:08:21 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v3 19/20] x86/mm: Add speculative pagefault handling
Date: Fri,  8 Sep 2017 20:07:03 +0200
In-Reply-To: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1504894024-2750-20-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

From: Peter Zijlstra <peterz@infradead.org>

Try a speculative fault before acquiring mmap_sem, if it returns with
VM_FAULT_RETRY continue with the mmap_sem acquisition and do the
traditional fault.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

[Clearing of FAULT_FLAG_ALLOW_RETRY is now done in
 handle_speculative_fault()]
[Retry with usual fault path in the case VM_ERROR is returned by
 handle_speculative_fault(). This allows signal to be delivered]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/x86/include/asm/pgtable_types.h |  7 +++++++
 arch/x86/mm/fault.c                  | 19 +++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index f1492473f10e..aadc8ecb91fb 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -257,6 +257,13 @@ enum page_cache_mode {
 #define PGD_IDENT_ATTR	 0x001		/* PRESENT (no other attributes) */
 #endif
 
+/*
+ * Advertise that we call the Speculative Page Fault handler.
+ */
+#ifdef CONFIG_X86_64
+#define __HAVE_ARCH_CALL_SPF
+#endif
+
 #ifdef CONFIG_X86_32
 # include <asm/pgtable_32_types.h>
 #else
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index b836a7274e12..652af5524f42 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1365,6 +1365,24 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	if (error_code & PF_INSTR)
 		flags |= FAULT_FLAG_INSTRUCTION;
 
+#ifdef __HAVE_ARCH_CALL_SPF
+	if (error_code & PF_USER) {
+		fault = handle_speculative_fault(mm, address, flags);
+
+		/*
+		 * We also check against VM_FAULT_ERROR because we have to
+		 * raise a signal by calling later mm_fault_error() which
+		 * requires the vma pointer to be set. So in that case,
+		 * we fall through the normal path.
+		 */
+		if (!(fault & VM_FAULT_RETRY || fault & VM_FAULT_ERROR)) {
+			perf_sw_event(PERF_COUNT_SW_SPF, 1,
+				      regs, address);
+			goto done;
+		}
+	}
+#endif /* __HAVE_ARCH_CALL_SPF */
+
 	/*
 	 * When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in
@@ -1474,6 +1492,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
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
