Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8FC8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 16:35:32 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b6-v6so4831765pls.16
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 13:35:32 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id a9-v6si8184601pgj.224.2018.09.14.13.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 13:35:31 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v10 PATCH 2/3] mm: unmap VM_HUGETLB mappings with optimized path
Date: Sat, 15 Sep 2018 04:34:58 +0800
Message-Id: <1536957299-43536-3-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1536957299-43536-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1536957299-43536-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org
Cc: dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When unmapping VM_HUGETLB mappings, vm flags need to be updated. Since
the vmas have been detached, so it sounds safe to update vm flags with
read mmap_sem.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 2879b19..991e066 100644
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
