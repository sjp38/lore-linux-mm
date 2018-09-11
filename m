Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9B788E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 16:58:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v9-v6so13446710pff.4
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 13:58:45 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id ca2-v6si22871796plb.305.2018.09.11.13.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 13:58:44 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v9 PATCH 3/4] mm: unmap VM_HUGETLB mappings with optimized path
Date: Wed, 12 Sep 2018 04:58:12 +0800
Message-Id: <1536699493-69195-4-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1536699493-69195-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1536699493-69195-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When unmapping VM_HUGETLB mappings, vm flags need to be updated. Since
the vmas have been detached, so it sounds safe to update vm flags with
read mmap_sem.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 937d2f2..086f8b5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2812,12 +2812,12 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
 	}
 
 	/*
-	 * Unmapping vmas, which have VM_HUGETLB or VM_PFNMAP
+	 * Unmapping vmas, which have VM_PFNMAP
 	 * need get done with write mmap_sem held since they may update
 	 * vm_flags. Deal with such mappings with regular do_munmap() call.
 	 */
 	for (vma = start_vma; vma && vma->vm_start < end; vma = vma->vm_next) {
-		if (vma->vm_flags & (VM_HUGETLB | VM_PFNMAP))
+		if (vma->vm_flags & VM_PFNMAP)
 			goto regular_path;
 	}
 
-- 
1.8.3.1
