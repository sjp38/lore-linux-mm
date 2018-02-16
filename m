Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6336B026B
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:27:11 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id m71-v6so1171561ybm.10
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 07:27:11 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o65si2878075qkd.280.2018.02.16.07.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 07:27:10 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1GFQ0rf091516
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:27:09 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g60v4b56c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:27:08 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Feb 2018 15:27:05 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v8 23/24] x86/mm: Add speculative pagefault handling
Date: Fri, 16 Feb 2018 16:25:37 +0100
In-Reply-To: <1518794738-4186-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1518794738-4186-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1518794738-4186-24-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>
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
[Don't build SPF call if !CONFIG_SPECULATIVE_PAGE_FAULT]
[Try speculative fault path only for multi threaded processes]
[Try to the VMA fetch during the speculative path in case of retry]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/x86/mm/fault.c | 38 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 37 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 800de815519c..d9f9236ccb9a 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1239,6 +1239,9 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		unsigned long address)
 {
 	struct vm_area_struct *vma;
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	struct vm_area_struct *spf_vma = NULL;
+#endif
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	int fault, major = 0;
@@ -1336,6 +1339,27 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	if (error_code & X86_PF_INSTR)
 		flags |= FAULT_FLAG_INSTRUCTION;
 
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	if ((error_code & X86_PF_USER) && (atomic_read(&mm->mm_users) > 1)) {
+		fault = handle_speculative_fault(mm, address, flags,
+						 &spf_vma);
+
+		if (!(fault & VM_FAULT_RETRY)) {
+			if (!(fault & VM_FAULT_ERROR)) {
+				perf_sw_event(PERF_COUNT_SW_SPF, 1,
+					      regs, address);
+				goto done;
+			}
+			/*
+			 * In case of error we need the pkey value, but
+			 * can't get it from the spf_vma as it is only returned
+			 * when VM_FAULT_RETRY is returned. So we have to
+			 * retry the page fault with the mmap_sem grabbed.
+			 */
+		}
+	}
+#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
+
 	/*
 	 * When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in
@@ -1369,7 +1393,16 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		might_sleep();
 	}
 
-	vma = find_vma(mm, address);
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	if (spf_vma) {
+		if (can_reuse_spf_vma(spf_vma, address))
+			vma = spf_vma;
+		else
+			vma = find_vma(mm, address);
+		spf_vma = NULL;
+	} else
+#endif
+		vma = find_vma(mm, address);
 	if (unlikely(!vma)) {
 		bad_area(regs, error_code, address);
 		return;
@@ -1455,6 +1488,9 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		return;
 	}
 
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+done:
+#endif
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
