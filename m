Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB6AE6B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 09:01:58 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u15so276623pgb.7
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 06:01:58 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a6si131375plt.117.2017.09.01.06.01.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Sep 2017 06:01:52 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v81CxxsL087068
	for <linux-mm@kvack.org>; Fri, 1 Sep 2017 09:01:52 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cq3q5suvy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 01 Sep 2017 09:01:51 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 1 Sep 2017 23:01:48 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v81D1iT536306966
	for <linux-mm@kvack.org>; Fri, 1 Sep 2017 23:01:44 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v81D1a7n020102
	for <linux-mm@kvack.org>; Fri, 1 Sep 2017 23:01:36 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/mempolicy: Remove BUG_ON() checks for VMA inside mpol_misplaced()
Date: Fri,  1 Sep 2017 18:31:37 +0530
In-Reply-To: <b28e0081-6e10-2d55-7414-afb0574a11a1@linux.vnet.ibm.com>
References: <b28e0081-6e10-2d55-7414-afb0574a11a1@linux.vnet.ibm.com>
Message-Id: <20170901130137.7617-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz

VMA and its address bounds checks are too late in this function.
They must have been verified earlier in the page fault sequence.
Hence just remove them.

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/mempolicy.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 618ab12..3509b84 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2172,17 +2172,12 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	int polnid = -1;
 	int ret = -1;
 
-	BUG_ON(!vma);
-
 	pol = get_vma_policy(vma, addr);
 	if (!(pol->flags & MPOL_F_MOF))
 		goto out;
 
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
