Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B04936B000A
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 14:50:23 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d12-v6so906695pgv.12
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 11:50:23 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id a18-v6si20228338plm.122.2018.08.15.11.50.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 11:50:22 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v8 PATCH 5/5] mm: unmap VM_PFNMAP mappings with optimized path
Date: Thu, 16 Aug 2018 02:49:50 +0800
Message-Id: <1534358990-85530-6-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When unmapping VM_PFNMAP mappings, vm flags need to be updated. Since
the vmas have been detached, so it sounds safe to update vm flags with
read mmap_sem.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 3b9f734..0a9960d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2811,16 +2811,13 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
 	}
 
 	/*
-	 * Unmapping vmas, which have:
-	 *   VM_PFNMAP or
-	 *   uprobes
-	 * need get done with write mmap_sem held since they may update
-	 * vm_flags. Deal with such mappings with regular do_munmap() call.
+	 * Unmapping vmas, which have uprobes need get done with write
+	 * mmap_sem held since they may update vm_flags. Deal with such
+	 * mappings with regular do_munmap() call.
 	 */
 	for (vma = start_vma; vma && vma->vm_start < end; vma = vma->vm_next) {
-		if ((vma->vm_file &&
-		    has_uprobes(vma, vma->vm_start, vma->vm_end)) ||
-		    (vma->vm_flags & VM_PFNMAP))
+		if (vma->vm_file &&
+		    has_uprobes(vma, vma->vm_start, vma->vm_end))
 			goto regular_path;
 	}
 
-- 
1.8.3.1
