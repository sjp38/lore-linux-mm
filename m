Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D810F6B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 23:36:18 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id bj1so1108271pad.27
        for <linux-mm@kvack.org>; Tue, 13 May 2014 20:36:18 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id hb8si257142pbc.411.2014.05.13.20.36.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 13 May 2014 20:36:17 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: remap_file_pages: grab file ref to prevent race while mmaping
Date: Tue, 13 May 2014 23:35:42 -0400
Message-Id: <1400038542-9705-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, davej@redhat.com, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, peterz@infradead.org, mingo@kernel.org, Sasha Levin <sasha.levin@oracle.com>

A file reference should be held while a file is mmaped, otherwise it might
be freed while being used.

Suggested-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/mmap.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 2a0e0a8..da3c212 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2593,6 +2593,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	struct vm_area_struct *vma;
 	unsigned long populate = 0;
 	unsigned long ret = -EINVAL;
+	struct file *file;
 
 	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. "
 			"See Documentation/vm/remap_file_pages.txt.\n",
@@ -2636,8 +2637,10 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 		munlock_vma_pages_range(vma, start, start + size);
 	}
 
+	file = get_file(vma->vm_file);
 	ret = do_mmap_pgoff(vma->vm_file, start, size,
 			prot, flags, pgoff, &populate);
+	fput(file);
 out:
 	up_write(&mm->mmap_sem);
 	if (populate)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
