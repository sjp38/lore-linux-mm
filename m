Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BEFC6B0003
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 19:36:32 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w23-v6so3519606pgv.1
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 16:36:32 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id h130-v6si7941113pfe.119.2018.08.09.16.36.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 16:36:30 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v7 PATCH 1/4] mm: refactor do_munmap() to extract the common part
Date: Fri, 10 Aug 2018 07:36:00 +0800
Message-Id: <1533857763-43527-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Introduces three new helper functions:
  * addr_ok()
  * munmap_lookup_vma()
  * munlock_vmas()

They will be used by do_munmap() and the new do_munmap with zapping
large mapping early in the later patch.

There is no functional change, just code refactor.

Reviewed-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 100 ++++++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 71 insertions(+), 29 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 17bbf4d..2a6898b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2681,35 +2681,40 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
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
+ * returns the pointer to vma, NULL or err ptr when spilt_vma returns error.
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
 
+	/* we have  start < vma->vm_end  */
 	/* if it doesn't overlap, we have nothing.. */
-	end = start + len;
 	if (vma->vm_start >= end)
-		return 0;
+		return NULL;
+	prev = vma->vm_prev;
 
 	/*
 	 * If we need to split any vma, do it now to save pain later.
@@ -2727,11 +2732,11 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
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
 
@@ -2740,10 +2745,53 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
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
@@ -2764,13 +2812,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	 */
 	if (mm->locked_vm) {
 		struct vm_area_struct *tmp = vma;
-		while (tmp && tmp->vm_start < end) {
-			if (tmp->vm_flags & VM_LOCKED) {
-				mm->locked_vm -= vma_pages(tmp);
-				munlock_vma_pages_all(tmp);
-			}
-			tmp = tmp->vm_next;
-		}
+		munlock_vmas(tmp, end);
 	}
 
 	/*
-- 
1.8.3.1
