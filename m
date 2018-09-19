Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 577178E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 13:04:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d132-v6so2639189pgc.22
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 10:04:11 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id x3-v6si21452649pgo.542.2018.09.19.10.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 10:04:09 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v11 PATCH 2/3] mm: unmap VM_HUGETLB mappings with optimized path
Date: Thu, 20 Sep 2018 01:03:40 +0800
Message-Id: <1537376621-51150-3-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1537376621-51150-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1537376621-51150-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org
Cc: dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When unmapping VM_HUGETLB mappings, vm flags need to be updated. Since
the vmas have been detached, so it sounds safe to update vm flags with
read mmap_sem.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 982dd00..490340e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2777,7 +2777,7 @@ static int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 			 * update vm_flags.
 			 */
 			if (downgrade &&
-			    (tmp->vm_flags & (VM_HUGETLB | VM_PFNMAP)))
+			    (tmp->vm_flags & VM_PFNMAP))
 				downgrade = false;
 
 			tmp = tmp->vm_next;
-- 
1.8.3.1
