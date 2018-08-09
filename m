Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 97A746B000D
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 19:36:54 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id j1-v6so4553675pld.23
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 16:36:54 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id g27-v6si8502766pgm.208.2018.08.09.16.36.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 16:36:53 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v7 PATCH 4/4] mm: unmap special vmas with regular do_munmap()
Date: Fri, 10 Aug 2018 07:36:03 +0800
Message-Id: <1533857763-43527-5-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Unmapping vmas, which have VM_HUGETLB | VM_PFNMAP flag set or
have uprobes set, need get done with write mmap_sem held since
they may update vm_flags.

So, it might be not safe enough to deal with these kind of special
mappings with read mmap_sem. Deal with such mappings with regular
do_munmap() call.

Michal suggested to make this as a separate patch for safer and more
bisectable sake.

Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 2234d5a..06cb83c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2766,6 +2766,16 @@ static inline void munlock_vmas(struct vm_area_struct *vma,
 	}
 }
 
+static inline bool can_zap_with_rlock(struct vm_area_struct *vma)
+{
+	if ((vma->vm_file &&
+	     vma_has_uprobes(vma, vma->vm_start, vma->vm_end)) ||
+	     (vma->vm_flags | (VM_HUGETLB | VM_PFNMAP)))
+		return false;
+
+	return true;
+}
+
 /*
  * Zap pages with read mmap_sem held
  *
@@ -2808,6 +2818,17 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
 			goto out;
 	}
 
+	/*
+	 * Unmapping vmas, which have VM_HUGETLB | VM_PFNMAP flag set or
+	 * have uprobes set, need get done with write mmap_sem held since
+	 * they may update vm_flags. Deal with such mappings with regular
+	 * do_munmap() call.
+	 */
+	for (vma = start_vma; vma && vma->vm_start < end; vma = vma->vm_next) {
+		if (!can_zap_with_rlock(vma))
+			goto regular_path;
+	}
+
 	/* Handle mlocked vmas */
 	if (mm->locked_vm) {
 		vma = start_vma;
@@ -2828,6 +2849,9 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
 
 	return 0;
 
+regular_path:
+	ret = do_munmap(mm, start, len, uf);
+
 out:
 	up_write(&mm->mmap_sem);
 	return ret;
-- 
1.8.3.1
