Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4E46B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:34:44 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 51so106468695uai.3
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 08:34:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n65si11236506vkc.227.2016.12.12.08.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 08:34:43 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBCGYJju044631
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:34:41 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 279t0x7h7a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:34:41 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 12 Dec 2016 09:34:40 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm/thp/pagecache: Only withdraw page table after a successful deposit
Date: Mon, 12 Dec 2016 22:04:27 +0530
Message-Id: <20161212163428.6780-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

The current code wrongly called withdraw in the error path. But we
haven't depoisted the page table yet in the only error path in that
function. So for now remove that withdraw completely. If we take
that "out:" branch, we should have vmf->prealloc_pte already pointing
to the allocated page table.

Fixes: "mm: THP page cache support for ppc64"

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/memory.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 455c3e628d52..36c774f9259e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3008,13 +3008,6 @@ static int do_set_pmd(struct vm_fault *vmf, struct page *page)
 	ret = 0;
 	count_vm_event(THP_FILE_MAPPED);
 out:
-	/*
-	 * If we are going to fallback to pte mapping, do a
-	 * withdraw with pmd lock held.
-	 */
-	if (arch_needs_pgtable_deposit() && ret == VM_FAULT_FALLBACK)
-		vmf->prealloc_pte = pgtable_trans_huge_withdraw(vma->vm_mm,
-								vmf->pmd);
 	spin_unlock(vmf->ptl);
 	return ret;
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
