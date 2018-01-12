Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CBFC6B027D
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:27:39 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id 19so5433564qkk.20
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 09:27:39 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 13si10060382qtp.385.2018.01.12.09.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 09:27:38 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0CHPboW139080
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:27:37 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fevqaswje-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:27:37 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 12 Jan 2018 17:27:34 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v6 23/24] x86/mm: Add speculative pagefault handling
Date: Fri, 12 Jan 2018 18:26:07 +0100
In-Reply-To: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1515777968-867-24-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com
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
[Don't build SPF call if !CONFIG_SPF]
[Try speculative fault path only for multi threaded processes]
[Try to the VMA fetch during the speculative path in case of retry]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/x86/mm/fault.c | 38 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 37 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 06fe3d51d385..8db69a116521 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1242,6 +1242,9 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		unsigned long address)
 {
 	struct vm_area_struct *vma;
+#ifdef CONFIG_SPF
+	struct vm_area_struct *spf_vma = NULL;
+#endif
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	int fault, major = 0;
@@ -1339,6 +1342,27 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	if (error_code & X86_PF_INSTR)
 		flags |= FAULT_FLAG_INSTRUCTION;
 
+#ifdef CONFIG_SPF
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
+#endif /* CONFIG_SPF */
+
 	/*
 	 * When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in
@@ -1372,7 +1396,16 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		might_sleep();
 	}
 
-	vma = find_vma(mm, address);
+#ifdef CONFIG_SPF
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
@@ -1458,6 +1491,9 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		return;
 	}
 
+#ifdef CONFIG_SPF
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
