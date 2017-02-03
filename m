Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2247D6B0260
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 11:57:04 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id jz4so6288454wjb.5
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 08:57:04 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.74])
        by mx.google.com with ESMTPS id e191si2734577wmf.158.2017.02.03.08.57.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 08:57:02 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] fixup! userfaultfd: non-cooperative: add event for memory unmaps
Date: Fri,  3 Feb 2017 17:50:42 +0100
Message-Id: <20170203165141.3665284-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The prototypes for MMU-based machines and MMU-less builds have to be the
same, this fixes the build errors I saw:

mm/nommu.c:1201:15: error: conflicting types for 'do_mmap'
mm/nommu.c:1580:5: error: conflicting types for 'do_munmap'

Fixes: mmtom ("userfaultfd: non-cooperative: add event for memory unmaps")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 ipc/shm.c  | 2 +-
 mm/nommu.c | 7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 175158d6fb13..3a178ca12bb9 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1370,7 +1370,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 	 * given
 	 */
 	if (vma && vma->vm_start == addr && vma->vm_ops == &shm_vm_ops) {
-		do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start);
+		do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start, NULL);
 		retval = 0;
 	}
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 215c62296028..fe9f4fa4a7a7 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1205,7 +1205,8 @@ unsigned long do_mmap(struct file *file,
 			unsigned long flags,
 			vm_flags_t vm_flags,
 			unsigned long pgoff,
-			unsigned long *populate)
+			unsigned long *populate,
+			struct list_head *uf)
 {
 	struct vm_area_struct *vma;
 	struct vm_region *region;
@@ -1577,7 +1578,7 @@ static int shrink_vma(struct mm_struct *mm,
  * - under NOMMU conditions the chunk to be unmapped must be backed by a single
  *   VMA, though it need not cover the whole VMA
  */
-int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
+int do_munmap(struct mm_struct *mm, unsigned long start, size_t len, struct list_head *uf)
 {
 	struct vm_area_struct *vma;
 	unsigned long end;
@@ -1643,7 +1644,7 @@ int vm_munmap(unsigned long addr, size_t len)
 	int ret;
 
 	down_write(&mm->mmap_sem);
-	ret = do_munmap(mm, addr, len);
+	ret = do_munmap(mm, addr, len, NULL);
 	up_write(&mm->mmap_sem);
 	return ret;
 }
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
