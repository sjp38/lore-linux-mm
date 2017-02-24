Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83B9B6B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:28:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d18so37940446pgh.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 05:28:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n11si7377941plg.275.2017.02.24.05.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 05:28:18 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1ODPItL119208
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:28:18 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28t0awdfma-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:28:17 -0500
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 24 Feb 2017 08:28:16 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] mm/autonuma: Don't mark pte saved write in case of dirty_accountable.
Date: Fri, 24 Feb 2017 18:58:04 +0530
Message-Id: <1487942884-16517-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We never request for protection update with ditry_accountable set and prot_numa
set. Hence mark the pte with mkwrite instead mk_savedwrite.

Found this when running stress-ng test with debug check enabled. This trigger
the VM_BUG_ON in pte_mk_savedwrite()

Fixes: http://ozlabs.org/~akpm/mmots/broken-out/mm-autonuma-let-architecture-override-how-the-write-bit-should-be-stashed-in-a-protnone-pte.patch

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/mprotect.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 15f5c174a7c1..bccccc73080d 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -119,7 +119,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			if (dirty_accountable && pte_dirty(ptent) &&
 					(pte_soft_dirty(ptent) ||
 					 !(vma->vm_flags & VM_SOFTDIRTY))) {
-				ptent = pte_mk_savedwrite(ptent);
+				ptent = pte_mkwrite(ptent);
 			}
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
 			pages++;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
