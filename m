Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A6848E0001
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 20:47:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id v9-v6so13590155pff.4
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:47:25 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id w15-v6si3817114pgg.529.2018.09.25.17.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 17:47:23 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 1/2 -mm] mm: mremap: dwongrade mmap_sem to read when shrinking
Date: Wed, 26 Sep 2018 08:46:55 +0800
Message-Id: <1537922816-108051-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, kirill@shutemov.name, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Other than munmap, mremap might be used to shrink memory mapping too.
Use __do_munmap() to shrink mapping with downgrading mmap_sem to read.

MREMAP_FIXED and MREMAP_MAYMOVE are more complicated to adopt this
optimization since they need manipulate vmas after do_munmap(),
downgrading mmap_sem may create race window.

Simple mapping shrink is the low hanging fruit, and it may cover the
most cases of unmap with munmap.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/mm.h |  2 ++
 mm/mmap.c          |  4 ++--
 mm/mremap.c        | 16 ++++++++++++----
 3 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8..3028028 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2286,6 +2286,8 @@ extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
 	struct list_head *uf);
+extern int __do_munmap(struct mm_struct *, unsigned long, size_t,
+		       struct list_head *uf, bool downgrade);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t,
 		     struct list_head *uf);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 847a17d..017bcfa 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2687,8 +2687,8 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
  * work.  This now handles partial unmappings.
  * Jeremy Fitzhardinge <jeremy@goop.org>
  */
-static int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
-		       struct list_head *uf, bool downgrade)
+int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
+		struct list_head *uf, bool downgrade)
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
diff --git a/mm/mremap.c b/mm/mremap.c
index 5c2e185..e608e92 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -525,6 +525,7 @@ static int vma_expandable(struct vm_area_struct *vma, unsigned long delta)
 	unsigned long ret = -EINVAL;
 	unsigned long charged = 0;
 	bool locked = false;
+	bool downgrade = false;
 	struct vm_userfaultfd_ctx uf = NULL_VM_UFFD_CTX;
 	LIST_HEAD(uf_unmap_early);
 	LIST_HEAD(uf_unmap);
@@ -561,12 +562,16 @@ static int vma_expandable(struct vm_area_struct *vma, unsigned long delta)
 	/*
 	 * Always allow a shrinking remap: that just unmaps
 	 * the unnecessary pages..
-	 * do_munmap does all the needed commit accounting
+	 * __do_munmap does all the needed commit accounting
 	 */
 	if (old_len >= new_len) {
-		ret = do_munmap(mm, addr+new_len, old_len - new_len, &uf_unmap);
-		if (ret && old_len != new_len)
+		ret = __do_munmap(mm, addr+new_len, old_len - new_len,
+				  &uf_unmap, true);
+		if (ret < 0 && old_len != new_len)
 			goto out;
+		/* Returning 1 indicates mmap_sem is downgraded to read. */
+		else if (ret == 1)
+			downgrade = true;
 		ret = addr;
 		goto out;
 	}
@@ -631,7 +636,10 @@ static int vma_expandable(struct vm_area_struct *vma, unsigned long delta)
 		vm_unacct_memory(charged);
 		locked = 0;
 	}
-	up_write(&current->mm->mmap_sem);
+	if (downgrade)
+		up_read(&current->mm->mmap_sem);
+	else
+		up_write(&current->mm->mmap_sem);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
 	userfaultfd_unmap_complete(mm, &uf_unmap_early);
-- 
1.8.3.1
