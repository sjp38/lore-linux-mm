Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A17E6B03A1
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 10:36:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v77so36001147pgb.15
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 07:36:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l19si962670pfa.168.2017.08.08.07.36.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 07:36:21 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78EY0NQ064442
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 10:36:20 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c7ce6wmvq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 10:36:20 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 15:36:17 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 10/16] powerpc/mm: Add speculative page fault
Date: Tue,  8 Aug 2017 16:35:43 +0200
In-Reply-To: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1502202949-8138-11-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

This patch enable the speculative page fault on the PowerPC
architecture.

This will try a speculative page fault without holding the mmap_sem,
if it returns with WM_FAULT_RETRY, the mmap_sem is acquired and the
traditional page fault processing is done.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/mm/fault.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 4c422632047b..c6cd40901dd0 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -291,9 +291,31 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	if (is_write && is_user)
 		store_update_sp = store_updates_sp(regs);
 
-	if (is_user)
+	if (is_user) {
 		flags |= FAULT_FLAG_USER;
 
+		/* let's try a speculative page fault without grabbing the
+		 * mmap_sem.
+		 */
+
+		/*
+		 * flags is set later based on the VMA's flags, for the common
+		 * speculative service, we need some flags to be set.
+		 */
+		if (is_write)
+			flags |= FAULT_FLAG_WRITE;
+
+		fault = handle_speculative_fault(mm, address, flags);
+		if (!(fault & VM_FAULT_RETRY || fault & VM_FAULT_ERROR))
+			goto done;
+
+		/*
+		 * Resetting flags since the following code assumes
+		 * FAULT_FLAG_WRITE is not set.
+		 */
+		flags &= ~FAULT_FLAG_WRITE;
+	}
+
 	/* When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
 	 * kernel and should generate an OOPS.  Unfortunately, in the case of an
@@ -479,6 +501,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 			rc = 0;
 	}
 
+done:
 	/*
 	 * Major/minor page fault accounting.
 	 */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
