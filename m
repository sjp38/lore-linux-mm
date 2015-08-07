Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 47A416B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 07:54:49 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so26689724pdr.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 04:54:49 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id tr10si17014183pbc.257.2015.08.07.04.54.48
        for <linux-mm@kvack.org>;
        Fri, 07 Aug 2015 04:54:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, dax: use i_mmap_unlock_write() in do_cow_fault()
Date: Fri,  7 Aug 2015 14:54:42 +0300
Message-Id: <1438948482-129043-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

__dax_fault() takes i_mmap_lock for write. Let's pair it with write
unlock on do_cow_fault() side.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Matthew Wilcox <willy@linux.intel.com>
---
 mm/memory.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 670cdfa9f33e..7f6a9563d5a6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3013,9 +3013,9 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		} else {
 			/*
 			 * The fault handler has no page to lock, so it holds
-			 * i_mmap_lock for read to protect against truncate.
+			 * i_mmap_lock for write to protect against truncate.
 			 */
-			i_mmap_unlock_read(vma->vm_file->f_mapping);
+			i_mmap_unlock_write(vma->vm_file->f_mapping);
 		}
 		goto uncharge_out;
 	}
@@ -3029,9 +3029,9 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else {
 		/*
 		 * The fault handler has no page to lock, so it holds
-		 * i_mmap_lock for read to protect against truncate.
+		 * i_mmap_lock for write to protect against truncate.
 		 */
-		i_mmap_unlock_read(vma->vm_file->f_mapping);
+		i_mmap_unlock_write(vma->vm_file->f_mapping);
 	}
 	return ret;
 uncharge_out:
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
