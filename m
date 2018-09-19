Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9568E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 13:05:24 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c5-v6so2795429plo.2
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 10:05:24 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id 59-v6si20957573plp.87.2018.09.19.10.05.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 10:05:23 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v11 PATCH 3/3] mm: unmap VM_PFNMAP mappings with optimized path
Date: Thu, 20 Sep 2018 01:03:41 +0800
Message-Id: <1537376621-51150-4-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1537376621-51150-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1537376621-51150-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org
Cc: dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When unmapping VM_PFNMAP mappings, vm flags need to be updated. Since
the vmas have been detached, so it sounds safe to update vm flags with
read mmap_sem.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 490340e..847a17d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2771,15 +2771,6 @@ static int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 				munlock_vma_pages_all(tmp);
 			}
 
-			/*
-			 * Unmapping vmas, which have VM_HUGETLB or VM_PFNMAP,
-			 * need get done with write mmap_sem held since they may
-			 * update vm_flags.
-			 */
-			if (downgrade &&
-			    (tmp->vm_flags & VM_PFNMAP))
-				downgrade = false;
-
 			tmp = tmp->vm_next;
 		}
 	}
-- 
1.8.3.1
