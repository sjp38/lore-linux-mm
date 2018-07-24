Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2D9E6B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 08:11:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m25-v6so2441761pgv.22
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 05:11:43 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id a1-v6si9557891pgq.387.2018.07.24.05.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 05:11:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 1/3] mm: Introduce vma_init()
Date: Tue, 24 Jul 2018 15:11:37 +0300
Message-Id: <20180724121139.62570-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
References: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Not all VMAs allocated with vm_area_alloc(). Some of them allocated on
stack or in data segment.

The new helper can be use to initialize VMA properly regardless where
it was allocated.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 6 ++++++
 kernel/fork.c      | 6 ++----
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d3a3842316b8..31540f166987 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -452,6 +452,12 @@ struct vm_operations_struct {
 					  unsigned long addr);
 };
 
+static inline void vma_init(struct vm_area_struct *vma, struct mm_struct *mm)
+{
+	vma->vm_mm = mm;
+	INIT_LIST_HEAD(&vma->anon_vma_chain);
+}
+
 struct mmu_gather;
 struct inode;
 
diff --git a/kernel/fork.c b/kernel/fork.c
index a191c05e757d..1b27babc4c78 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -312,10 +312,8 @@ struct vm_area_struct *vm_area_alloc(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 
-	if (vma) {
-		vma->vm_mm = mm;
-		INIT_LIST_HEAD(&vma->anon_vma_chain);
-	}
+	if (vma)
+		vma_init(vma, mm);
 	return vma;
 }
 
-- 
2.18.0
