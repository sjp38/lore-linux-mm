Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA066B000A
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 14:50:23 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 33-v6so1124630plf.19
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 11:50:23 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id y16-v6si19909316plr.469.2018.08.15.11.50.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 11:50:22 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v8 PATCH 4/5] mm: unmap VM_HUGETLB mappings with optimized path
Date: Thu, 16 Aug 2018 02:49:49 +0800
Message-Id: <1534358990-85530-5-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When unmapping VM_HUGETLB mappings, vm flags need to be updated. Since
the vmas have been detached, so it sounds safe to update vm flags with
read mmap_sem.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index e92f680..3b9f734 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2812,7 +2812,6 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
 
 	/*
 	 * Unmapping vmas, which have:
-	 *   VM_HUGETLB or
 	 *   VM_PFNMAP or
 	 *   uprobes
 	 * need get done with write mmap_sem held since they may update
@@ -2821,7 +2820,7 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
 	for (vma = start_vma; vma && vma->vm_start < end; vma = vma->vm_next) {
 		if ((vma->vm_file &&
 		    has_uprobes(vma, vma->vm_start, vma->vm_end)) ||
-		    (vma->vm_flags & (VM_HUGETLB | VM_PFNMAP)))
+		    (vma->vm_flags & VM_PFNMAP))
 			goto regular_path;
 	}
 
-- 
1.8.3.1
