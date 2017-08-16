Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 776BC6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 12:09:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f23so53044907pgn.15
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 09:09:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i3si653111pgo.666.2017.08.16.09.09.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 09:09:23 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7GG8ShM113738
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 12:09:22 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ccnyfcxv6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 12:09:22 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 16 Aug 2017 17:09:20 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH] mm: Remove useless vma parameter to offset_il_node
Date: Wed, 16 Aug 2017 18:09:15 +0200
Message-Id: <1502899755-23146-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org, linux-kernel@vger.kernel.org

While reading the code I found that offset_il_node() has a vm_area_struct
pointer parameter which is unused.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/mempolicy.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d911fa5cb2a7..f2598578e63c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1688,8 +1688,7 @@ unsigned int mempolicy_slab_node(void)
  * node in pol->v.nodes (starting from n=0), wrapping around if n exceeds the
  * number of present nodes.
  */
-static unsigned offset_il_node(struct mempolicy *pol,
-			       struct vm_area_struct *vma, unsigned long n)
+static unsigned offset_il_node(struct mempolicy *pol, unsigned long n)
 {
 	unsigned nnodes = nodes_weight(pol->v.nodes);
 	unsigned target;
@@ -1722,7 +1721,7 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
 		BUG_ON(shift < PAGE_SHIFT);
 		off = vma->vm_pgoff >> (shift - PAGE_SHIFT);
 		off += (addr - vma->vm_start) >> shift;
-		return offset_il_node(pol, vma, off);
+		return offset_il_node(pol, off);
 	} else
 		return interleave_nodes(pol);
 }
@@ -2190,7 +2189,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 
 		pgoff = vma->vm_pgoff;
 		pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
-		polnid = offset_il_node(pol, vma, pgoff);
+		polnid = offset_il_node(pol, pgoff);
 		break;
 
 	case MPOL_PREFERRED:
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
