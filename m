Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 27BE36B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 12:58:06 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so44938912pdr.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 09:58:05 -0700 (PDT)
Received: from smtpbg63.qq.com (smtpbg63.qq.com. [103.7.29.150])
        by mx.google.com with ESMTPS id io6si23082149pbc.117.2015.08.23.09.58.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 23 Aug 2015 09:58:05 -0700 (PDT)
From: gang.chen.5i5j@gmail.com
Subject: [PATCH] mm: mmap: Check all failures before set values
Date: Mon, 24 Aug 2015 00:57:49 +0800
Message-Id: <1440349069-18253-1-git-send-email-gang.chen.5i5j@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com, mhocko@suse.cz, sasha.levin@oracle.com, gang.chen.5i5j@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Chen Gang <gang.chen.5i5j@gmail.com>

When failure occurs and return, vma->vm_pgoff is already set, which is
not a good idea.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 mm/mmap.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 8e0366e..b5a6f09 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2878,6 +2878,13 @@ int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 	struct vm_area_struct *prev;
 	struct rb_node **rb_link, *rb_parent;
 
+	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
+			   &prev, &rb_link, &rb_parent))
+		return -ENOMEM;
+	if ((vma->vm_flags & VM_ACCOUNT) &&
+	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
+		return -ENOMEM;
+
 	/*
 	 * The vm_pgoff of a purely anonymous vma should be irrelevant
 	 * until its first write fault, when page's anon_vma and index
@@ -2894,12 +2901,6 @@ int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 		BUG_ON(vma->anon_vma);
 		vma->vm_pgoff = vma->vm_start >> PAGE_SHIFT;
 	}
-	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
-			   &prev, &rb_link, &rb_parent))
-		return -ENOMEM;
-	if ((vma->vm_flags & VM_ACCOUNT) &&
-	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
-		return -ENOMEM;
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	return 0;
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
