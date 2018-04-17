Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31ECA6B0006
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:33:51 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id b85so4107724ywa.2
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:33:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g10si1811424qkg.366.2018.04.17.07.33.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:33:50 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3HETX0G013595
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:33:49 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hdgav8wyj-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:33:48 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 15:33:45 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v10 01/25] mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
Date: Tue, 17 Apr 2018 16:33:07 +0200
In-Reply-To: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523975611-15978-2-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

This configuration variable will be used to build the code needed to
handle speculative page fault.

By default it is turned off, and activated depending on architecture
support, SMP and MMU.

Suggested-by: Thomas Gleixner <tglx@linutronix.de>
Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/Kconfig | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index d5004d82a1d6..5484dca11199 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -752,3 +752,25 @@ config GUP_BENCHMARK
 	  performance of get_user_pages_fast().
 
 	  See tools/testing/selftests/vm/gup_benchmark.c
+
+config ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
+       def_bool n
+
+config SPECULATIVE_PAGE_FAULT
+       bool "Speculative page faults"
+       default y
+       depends on ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
+       depends on MMU && SMP
+       help
+         Try to handle user space page faults without holding the mmap_sem.
+
+	 This should allow better concurrency for massively threaded process
+	 since the page fault handler will not wait for other threads memory
+	 layout change to be done, assuming that this change is done in another
+	 part of the process's memory space. This type of page fault is named
+	 speculative page fault.
+
+	 If the speculative page fault fails because of a concurrency is
+	 detected or because underlying PMD or PTE tables are not yet
+	 allocating, it is failing its processing and a classic page fault
+	 is then tried.
-- 
2.7.4
