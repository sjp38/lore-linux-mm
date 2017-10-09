Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57CBC800D9
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 06:09:10 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 32so22538316qtp.3
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 03:09:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u2si45643qtd.361.2017.10.09.03.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 03:09:09 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v99A8pRs069939
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 06:09:08 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dg5xwk9tw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Oct 2017 06:09:08 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Oct 2017 11:09:05 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v4 20/20] powerpc/mm: Add speculative page fault
Date: Mon,  9 Oct 2017 12:07:52 +0200
In-Reply-To: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1507543672-25821-21-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

This patch enable the speculative page fault on the PowerPC
architecture.

This will try a speculative page fault without holding the mmap_sem,
if it returns with VM_FAULT_RETRY, the mmap_sem is acquired and the
traditional page fault processing is done.

Support is only provide for BOOK3S_64 currently because:
- require CONFIG_PPC_STD_MMU because checks done in
  set_access_flags_filter()
- require BOOK3S because we can't support for book3e_hugetlb_preload()
  called by update_mmu_cache()

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |  5 +++++
 arch/powerpc/mm/fault.c                      | 17 +++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index b9aff515b4de..e85073d0a09c 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -314,6 +314,11 @@ extern unsigned long pci_io_base;
 /* Advertise support for _PAGE_SPECIAL */
 #define __HAVE_ARCH_PTE_SPECIAL
 
+/* Advertise that we call the Speculative Page Fault handler */
+#if defined(CONFIG_PPC_BOOK3S_64) && defined(CONFIG_SMP)
+#define __HAVE_ARCH_CALL_SPF
+#endif
+
 #ifndef __ASSEMBLY__
 
 /*
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 4797d08581ce..fbd423515b54 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -442,6 +442,20 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	if (is_exec)
 		flags |= FAULT_FLAG_INSTRUCTION;
 
+#ifdef __HAVE_ARCH_CALL_SPF
+	if (is_user) {
+		/* let's try a speculative page fault without grabbing the
+		 * mmap_sem.
+		 */
+		fault = handle_speculative_fault(mm, address, flags);
+		if (!(fault & VM_FAULT_RETRY)) {
+			perf_sw_event(PERF_COUNT_SW_SPF, 1,
+				      regs, address);
+			goto done;
+		}
+	}
+#endif /* __HAVE_ARCH_CALL_SPF */
+
 	/* When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
 	 * kernel and should generate an OOPS.  Unfortunately, in the case of an
@@ -526,6 +540,9 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 
 	up_read(&current->mm->mmap_sem);
 
+#ifdef __HAVE_ARCH_CALL_SPF
+done:
+#endif
 	if (unlikely(fault & VM_FAULT_ERROR))
 		return mm_fault_error(regs, address, fault);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
