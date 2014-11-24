Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id B2BAB80110
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:20:22 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id fp1so9852492pdb.29
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 06:20:22 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id ak6si21700176pad.138.2014.11.24.06.20.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 06:20:21 -0800 (PST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 25 Nov 2014 00:20:13 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id EE00B2CE804E
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 01:20:09 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAOEK8v612714106
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 01:20:09 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAOEK82N032297
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 01:20:08 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH] mm/thp: Always allocate transparent hugepages on local node
Date: Mon, 24 Nov 2014 19:49:51 +0530
Message-Id: <1416838791-30023-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This make sure that we try to allocate hugepages from local node. If
we can't we fallback to small page allocation based on
mempolicy. This is based on the observation that allocating pages
on local node is more beneficial that allocating hugepages on remote node.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
NOTE:
I am not sure whether we want this to be per system configurable ? If not
we could possibly remove alloc_hugepage_vma.

 mm/huge_memory.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index de984159cf0b..b309705e7e96 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -775,6 +775,12 @@ static inline struct page *alloc_hugepage_vma(int defrag,
 			       HPAGE_PMD_ORDER, vma, haddr, nd);
 }
 
+static inline struct page *alloc_hugepage_exact_node(int node, int defrag)
+{
+	return alloc_pages_exact_node(node, alloc_hugepage_gfpmask(defrag, 0),
+				      HPAGE_PMD_ORDER);
+}
+
 /* Caller must hold page table lock. */
 static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
@@ -830,8 +836,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		return 0;
 	}
-	page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-			vma, haddr, numa_node_id(), 0);
+	page = alloc_hugepage_exact_node(numa_node_id(),
+					 transparent_hugepage_defrag(vma));
 	if (unlikely(!page)) {
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
@@ -1120,8 +1126,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow())
-		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-					      vma, haddr, numa_node_id(), 0);
+		new_page = alloc_hugepage_exact_node(numa_node_id(),
+					     transparent_hugepage_defrag(vma));
 	else
 		new_page = NULL;
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
