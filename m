Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFFB26B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 22:54:17 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id j124so41031806ith.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 19:54:17 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id h98si10205557iod.123.2016.07.27.19.54.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 19:54:16 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id f6so3997027ith.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 19:54:16 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH V2] mm/hugetlb: Avoid soft lockup in set_max_huge_pages()
Date: Thu, 28 Jul 2016 10:54:02 +0800
Message-Id: <1469674442-14848-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Jia He <hejianet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>

In powerpc servers with large memory(32TB), we watched several soft
lockups for hugepage under stress tests.
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

This patch is to fix such soft lockups. It is safe to call cond_resched() 
there because it is out of spin_lock/unlock section.

Signed-off-by: Jia He <hejianet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>

---
Changes in V2: move cond_resched to a common calling site in set_max_huge_pages

 mm/hugetlb.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index abc1c5f..9284280 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2216,6 +2216,10 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 		 * and reducing the surplus.
 		 */
 		spin_unlock(&hugetlb_lock);
+
+		/* yield cpu to avoid soft lockup */
+		cond_resched();
+
 		if (hstate_is_gigantic(h))
 			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
 		else
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
