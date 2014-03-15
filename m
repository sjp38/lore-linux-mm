Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 39B4B6B005A
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 06:48:21 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so3747737pad.3
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 03:48:20 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id xj10si421487pab.163.2014.03.15.03.48.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 15 Mar 2014 03:48:20 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 15 Mar 2014 16:18:17 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id BB7D6394003E
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 16:18:14 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2FAm5bw1769832
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 16:18:06 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2FAmEsD019417
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 16:18:14 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] powerpc/mm: Make sure a local_irq_disable prevent a parallel THP split
Date: Sat, 15 Mar 2014 16:17:58 +0530
Message-Id: <1394880478-770-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, Rik van Riel <riel@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We have generic code like the one in get_futex_key that assume that
a local_irq_disable prevents a parallel THP split. Support that by
adding a dummy smp call function after setting _PAGE_SPLITTING. Code
paths like get_user_pages_fast still need to check for _PAGE_SPLITTING
after disabling IRQ which indicate that a parallel THP splitting is
ongoing. Now if they don't find _PAGE_SPLITTING set, then we can be
sure that parallel split will now block in pmdp_splitting flush
until we enables IRQ

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/pgtable_64.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 62bf5e8e78da..f6ce1f111f5b 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -647,6 +647,11 @@ void pmdp_splitting_flush(struct vm_area_struct *vma,
 		if (old & _PAGE_HASHPTE)
 			hpte_do_hugepage_flush(vma->vm_mm, address, pmdp);
 	}
+	/*
+	 * This ensures that generic code that rely on IRQ disabling
+	 * to prevent a parallel THP split work as expected.
+	 */
+	kick_all_cpus_sync();
 }
 
 /*
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
