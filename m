Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30AC26B0007
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 14:50:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z18-v6so912949pfe.19
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 11:50:22 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id b1-v6si19328959pls.367.2018.08.15.11.50.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 11:50:20 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v8 PATCH 1/5] mm: refactor do_munmap() to extract the common part
Date: Thu, 16 Aug 2018 02:49:46 +0800
Message-Id: <1534358990-85530-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
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
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 106 +++++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 74 insertions(+), 32 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 17bbf4d..f05f49b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2681,35 +2681,42 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -2727,11 +2734,11 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
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
 
@@ -2740,10 +2747,53 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
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
@@ -2762,16 +2812,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
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
