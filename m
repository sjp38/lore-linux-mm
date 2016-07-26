Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A58846B0253
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 11:44:43 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id u25so36242083ioi.1
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 08:44:43 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id v72si1938803ioi.97.2016.07.26.08.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 08:44:43 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id q83so2178234iod.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 08:44:43 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH] mm/hugetlb: Avoid soft lockup in set_max_huge_pages()
Date: Tue, 26 Jul 2016 23:44:28 +0800
Message-Id: <1469547868-9814-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Jia He <hejianet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>

In large memory(32TB) powerpc servers, we watched several soft lockup under
stress tests.
The call trace are as follows:
1.
get_page_from_freelist+0x2d8/0xd50  
__alloc_pages_nodemask+0x180/0xc20  
alloc_fresh_huge_page+0xb0/0x190    
set_max_huge_pages+0x164/0x3b0      

2.
prep_new_huge_page+0x5c/0x100             
alloc_fresh_huge_page+0xc8/0x190          
set_max_huge_pages+0x164/0x3b0

This patch is to fix such soft lockup. I thouhgt it is safe to call 
cond_resched() because alloc_fresh_gigantic_page and alloc_fresh_huge_page 
are out of spin_lock/unlock section.

Signed-off-by: Jia He <hejianet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>

---
 mm/hugetlb.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index addfe4ac..d51759d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1146,6 +1146,10 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
 
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
 		page = alloc_fresh_gigantic_page_node(h, node);
+
+		/* yield cpu */
+		cond_resched();
+
 		if (page)
 			return 1;
 	}
@@ -1381,6 +1385,10 @@ static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
 
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
 		page = alloc_fresh_huge_page_node(h, node);
+
+		/* yield cpu */
+		cond_resched();
+
 		if (page) {
 			ret = 1;
 			break;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
