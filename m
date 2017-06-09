Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BFD546B03A0
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 10:22:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n7so8678660wrb.0
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 07:22:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q1si2237610wmd.68.2017.06.09.07.22.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 07:22:03 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v59EJQY5064612
	for <linux-mm@kvack.org>; Fri, 9 Jun 2017 10:22:02 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2aysj4m20d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Jun 2017 10:22:02 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 9 Jun 2017 15:22:00 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v4 19/20] powerpc/mm: Add speculative page fault
Date: Fri,  9 Jun 2017 16:21:08 +0200
In-Reply-To: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1497018069-17790-20-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

This patch enable the speculative page fault on the PowerPC
architecture.

This will try a speculative page fault without holding the mmap_sem,
if it returns with WM_FAULT_RETRY, the mmap_sem is acquired and the
traditional page fault processing is done.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/mm/fault.c | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 3a7d580fdc59..6dd6a50f412f 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -290,9 +290,32 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	if (!is_exec && user_mode(regs))
 		store_update_sp = store_updates_sp(regs);
 
-	if (user_mode(regs))
+	if (user_mode(regs)) {
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
+		fault = handle_speculative_fault(mm, address,
+					 flags & ~FAULT_FLAG_ALLOW_RETRY);
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
@@ -478,6 +501,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
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
