Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33CD08E0008
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 16:58:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g9-v6so12895209pgc.16
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 13:58:46 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id e21-v6si20832405pgb.131.2018.09.11.13.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 13:58:44 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v9 PATCH 4/4] mm: unmap VM_PFNMAP mappings with optimized path
Date: Wed, 12 Sep 2018 04:58:13 +0800
Message-Id: <1536699493-69195-5-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1536699493-69195-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1536699493-69195-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When unmapping VM_PFNMAP mappings, vm flags need to be updated. Since
the vmas have been detached, so it sounds safe to update vm flags with
read mmap_sem.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 086f8b5..0b6b231 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2778,7 +2778,7 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
 			       size_t len, struct list_head *uf)
 {
 	unsigned long end;
-	struct vm_area_struct *start_vma, *prev, *vma;
+	struct vm_area_struct *start_vma, *prev;
 	int ret = 0;
 
 	if (!addr_ok(start, len))
@@ -2811,16 +2811,6 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
 			goto out;
 	}
 
-	/*
-	 * Unmapping vmas, which have VM_PFNMAP
-	 * need get done with write mmap_sem held since they may update
-	 * vm_flags. Deal with such mappings with regular do_munmap() call.
-	 */
-	for (vma = start_vma; vma && vma->vm_start < end; vma = vma->vm_next) {
-		if (vma->vm_flags & VM_PFNMAP)
-			goto regular_path;
-	}
-
 	/* Handle mlocked vmas */
 	if (mm->locked_vm)
 		munlock_vmas(start_vma, end);
@@ -2844,9 +2834,6 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
 
 	return 0;
 
-regular_path:
-	ret = do_munmap(mm, start, len, uf);
-
 out:
 	up_write(&mm->mmap_sem);
 	return ret;
-- 
1.8.3.1
