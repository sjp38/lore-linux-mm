Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3876A6B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 03:02:38 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 83so8525789pgb.1
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 00:02:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i86si1344967pfj.539.2017.09.01.00.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Sep 2017 00:02:36 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v816x334057336
	for <linux-mm@kvack.org>; Fri, 1 Sep 2017 03:02:36 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cpuva7wtu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 01 Sep 2017 03:02:35 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 1 Sep 2017 17:02:33 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v8172W5o40435730
	for <linux-mm@kvack.org>; Fri, 1 Sep 2017 17:02:32 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v8172XGc030051
	for <linux-mm@kvack.org>; Fri, 1 Sep 2017 17:02:33 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/mempolicy: Move VMA address bound checks inside mpol_misplaced()
Date: Fri,  1 Sep 2017 12:32:28 +0530
Message-Id: <20170901070228.19954-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org

The VMA address bound checks are applicable to all memory policy modes,
not just MPOL_INTERLEAVE. Hence move it to the front and make it common.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/mempolicy.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 618ab12..7ec6694 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2173,6 +2173,8 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	int ret = -1;
 
 	BUG_ON(!vma);
+	BUG_ON(addr >= vma->vm_end);
+	BUG_ON(addr < vma->vm_start);
 
 	pol = get_vma_policy(vma, addr);
 	if (!(pol->flags & MPOL_F_MOF))
@@ -2180,9 +2182,6 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 
 	switch (pol->mode) {
 	case MPOL_INTERLEAVE:
-		BUG_ON(addr >= vma->vm_end);
-		BUG_ON(addr < vma->vm_start);
-
 		pgoff = vma->vm_pgoff;
 		pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
 		polnid = offset_il_node(pol, vma, pgoff);
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
