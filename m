Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA6B8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 16:58:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d22-v6so13445272pfn.3
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 13:58:36 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id 1-v6si20025473plv.28.2018.09.11.13.58.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 13:58:34 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v9 PATCH 1/4] mm: refactor do_munmap() to extract the common part
Date: Wed, 12 Sep 2018 04:58:10 +0800
Message-Id: <1536699493-69195-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1536699493-69195-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1536699493-69195-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Introduces three new helper functions:
  * addr_ok()
  * munmap_lookup_vma()
  * munlock_vmas()

They will be used by do_munmap() and the new do_munmap with zapping
large mapping early in the later patch.

There is no functional change, just code refactor.

Reviewed-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 106 +++++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 74 insertions(+), 32 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 5f2b2b1..b7092b4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2682,35 +2682,42 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __split_vma(mm, vma, addr, new_below);
 }
 
-/* Munmap is split into 2 main parts -- this part which finds
- * what needs doing, and the areas themselves, which do the
- * work.  This now handles partial unmappings.
- * Jeremy Fitzhardinge <jeremy@goop.org>
- */
-int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
-	      struct list_head *uf)
+static inline bool addr_ok(unsigned long start, size_t len)
 {
-	unsigned long end;
-	struct vm_area_struct *vma, *prev, *last;
-
 	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE-start)
-		return -EINVAL;
+		return false;
 
-	len = PAGE_ALIGN(len);
-	if (len == 0)
-		return -EINVAL;
+	if (PAGE_ALIGN(len) == 0)
+		return false;
+
+	return true;
+}
+
+/*
+ * munmap_lookup_vma: find the first overlap vma and split overlap vmas.
+ * @mm: mm_struct
+ * @start: start address
+ * @end: end address
+ *
+ * Return: %NULL if no VMA overlaps this range.  An ERR_PTR if an
+ * overlapping VMA could not be split.  Otherwise a pointer to the first
+ * VMA which overlaps the range.
+ */
+static struct vm_area_struct *munmap_lookup_vma(struct mm_struct *mm,
+			unsigned long start, unsigned long end)
+{
+	struct vm_area_struct *vma, *prev, *last;
 
 	/* Find the first overlapping VMA */
 	vma = find_vma(mm, start);
 	if (!vma)
-		return 0;
-	prev = vma->vm_prev;
-	/* we have  start < vma->vm_end  */
+		return NULL;
 
+	/* we have start < vma->vm_end  */
 	/* if it doesn't overlap, we have nothing.. */
-	end = start + len;
 	if (vma->vm_start >= end)
-		return 0;
+		return NULL;
+	prev = vma->vm_prev;
 
 	/*
 	 * If we need to split any vma, do it now to save pain later.
@@ -2728,11 +2735,11 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 		 * its limit temporarily, to help free resources as expected.
 		 */
 		if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
-			return -ENOMEM;
+			return ERR_PTR(-ENOMEM);
 
 		error = __split_vma(mm, vma, start, 0);
 		if (error)
-			return error;
+			return ERR_PTR(error);
 		prev = vma;
 	}
 
@@ -2741,10 +2748,53 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	if (last && end > last->vm_start) {
 		int error = __split_vma(mm, last, end, 1);
 		if (error)
-			return error;
+			return ERR_PTR(error);
 	}
 	vma = prev ? prev->vm_next : mm->mmap;
 
+	return vma;
+}
+
+static inline void munlock_vmas(struct vm_area_struct *vma,
+				unsigned long end)
+{
+	struct mm_struct *mm = vma->vm_mm;
+
+	while (vma && vma->vm_start < end) {
+		if (vma->vm_flags & VM_LOCKED) {
+			mm->locked_vm -= vma_pages(vma);
+			munlock_vma_pages_all(vma);
+		}
+		vma = vma->vm_next;
+	}
+}
+
+/* Munmap is split into 2 main parts -- this part which finds
+ * what needs doing, and the areas themselves, which do the
+ * work.  This now handles partial unmappings.
+ * Jeremy Fitzhardinge <jeremy@goop.org>
+ */
+int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
+	      struct list_head *uf)
+{
+	unsigned long end;
+	struct vm_area_struct *vma, *prev;
+
+	if (!addr_ok(start, len))
+		return -EINVAL;
+
+	len = PAGE_ALIGN(len);
+
+	end = start + len;
+
+	vma = munmap_lookup_vma(mm, start, end);
+	if (!vma)
+		return 0;
+	if (IS_ERR(vma))
+		return PTR_ERR(vma);
+
+	prev = vma->vm_prev;
+
 	if (unlikely(uf)) {
 		/*
 		 * If userfaultfd_unmap_prep returns an error the vmas
@@ -2763,16 +2813,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	/*
 	 * unlock any mlock()ed ranges before detaching vmas
 	 */
-	if (mm->locked_vm) {
-		struct vm_area_struct *tmp = vma;
-		while (tmp && tmp->vm_start < end) {
-			if (tmp->vm_flags & VM_LOCKED) {
-				mm->locked_vm -= vma_pages(tmp);
-				munlock_vma_pages_all(tmp);
-			}
-			tmp = tmp->vm_next;
-		}
-	}
+	if (mm->locked_vm)
+		munlock_vmas(vma, end);
 
 	/*
 	 * Remove the vma's, and unmap the actual pages
-- 
1.8.3.1
