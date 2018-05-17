Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 397226B04C9
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:49 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 190-v6so3557519qkf.16
        for <linux-mm@kvack.org>; Thu, 17 May 2018 04:07:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f12-v6si903434qke.216.2018.05.17.04.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 04:07:48 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4HB4BdS022828
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:47 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j187ph2uf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:07:47 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 17 May 2018 12:07:44 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v11 26/26] arm64/mm: add speculative page fault
Date: Thu, 17 May 2018 13:06:33 +0200
In-Reply-To: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1526555193-7242-27-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

From: Mahendran Ganesh <opensource.ganesh@gmail.com>

This patch enables the speculative page fault on the arm64
architecture.

I completed spf porting in 4.9. From the test result,
we can see app launching time improved by about 10% in average.
For the apps which have more than 50 threads, 15% or even more
improvement can be got.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>

[handle_speculative_fault() is no more returning the vma pointer]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/arm64/mm/fault.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 91c53a7d2575..fb9f840367f9 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -411,6 +411,16 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, addr);
 
 	/*
+	 * let's try a speculative page fault without grabbing the
+	 * mmap_sem.
+	 */
+	fault = handle_speculative_fault(mm, addr, mm_flags);
+	if (fault != VM_FAULT_RETRY) {
+		perf_sw_event(PERF_COUNT_SW_SPF, 1, regs, addr);
+		goto done;
+	}
+
+	/*
 	 * As per x86, we may deadlock here. However, since the kernel only
 	 * validly references user space from well defined areas of the code,
 	 * we can bug out early if this is from code which shouldn't.
@@ -460,6 +470,8 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	}
 	up_read(&mm->mmap_sem);
 
+done:
+
 	/*
 	 * Handle the "normal" (no error) case first.
 	 */
-- 
2.7.4
