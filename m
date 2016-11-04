Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 23FF56B02B2
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 00:25:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m203so8562674wma.2
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 21:25:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n8si12911313wju.259.2016.11.03.21.25.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 21:25:27 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 16/21] mm: Provide helper for finishing mkwrite faults
Date: Fri,  4 Nov 2016 05:25:12 +0100
Message-Id: <1478233517-3571-17-git-send-email-jack@suse.cz>
In-Reply-To: <1478233517-3571-1-git-send-email-jack@suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Provide a helper function for finishing write faults due to PTE being
read-only. The helper will be used by DAX to avoid the need of
complicating generic MM code with DAX locking specifics.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h |  1 +
 mm/memory.c        | 67 ++++++++++++++++++++++++++++++++----------------------
 2 files changed, 41 insertions(+), 27 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fb128beecdac..685ff1c57f2b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -615,6 +615,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page);
 int finish_fault(struct vm_fault *vmf);
+int finish_mkwrite_fault(struct vm_fault *vmf);
 #endif
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index 06aba4203104..1517ff91c743 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2270,6 +2270,38 @@ static int wp_page_copy(struct vm_fault *vmf)
 	return VM_FAULT_OOM;
 }
 
+/**
+ * finish_mkwrite_fault - finish page fault for a shared mapping, making PTE
+ *			  writeable once the page is prepared
+ *
+ * @vmf: structure describing the fault
+ *
+ * This function handles all that is needed to finish a write page fault in a
+ * shared mapping due to PTE being read-only once the mapped page is prepared.
+ * It handles locking of PTE and modifying it. The function returns
+ * VM_FAULT_WRITE on success, 0 when PTE got changed before we acquired PTE
+ * lock.
+ *
+ * The function expects the page to be locked or other protection against
+ * concurrent faults / writeback (such as DAX radix tree locks).
+ */
+int finish_mkwrite_fault(struct vm_fault *vmf)
+{
+	WARN_ON_ONCE(!(vmf->vma->vm_flags & VM_SHARED));
+	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address,
+				       &vmf->ptl);
+	/*
+	 * We might have raced with another page fault while we released the
+	 * pte_offset_map_lock.
+	 */
+	if (!pte_same(*vmf->pte, vmf->orig_pte)) {
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
+		return 0;
+	}
+	wp_page_reuse(vmf);
+	return VM_FAULT_WRITE;
+}
+
 /*
  * Handle write page faults for VM_MIXEDMAP or VM_PFNMAP for a VM_SHARED
  * mapping
@@ -2286,16 +2318,7 @@ static int wp_pfn_shared(struct vm_fault *vmf)
 		ret = vma->vm_ops->pfn_mkwrite(vma, vmf);
 		if (ret & VM_FAULT_ERROR)
 			return ret;
-		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
-				vmf->address, &vmf->ptl);
-		/*
-		 * We might have raced with another page fault while we
-		 * released the pte_offset_map_lock.
-		 */
-		if (!pte_same(*vmf->pte, vmf->orig_pte)) {
-			pte_unmap_unlock(vmf->pte, vmf->ptl);
-			return 0;
-		}
+		return finish_mkwrite_fault(vmf);
 	}
 	wp_page_reuse(vmf);
 	return VM_FAULT_WRITE;
@@ -2305,7 +2328,6 @@ static int wp_page_shared(struct vm_fault *vmf)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	int page_mkwrite = 0;
 
 	get_page(vmf->page);
 
@@ -2319,26 +2341,17 @@ static int wp_page_shared(struct vm_fault *vmf)
 			put_page(vmf->page);
 			return tmp;
 		}
-		/*
-		 * Since we dropped the lock we need to revalidate
-		 * the PTE as someone else may have changed it.  If
-		 * they did, we just return, as we can count on the
-		 * MMU to tell us if they didn't also make it writable.
-		 */
-		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
-						vmf->address, &vmf->ptl);
-		if (!pte_same(*vmf->pte, vmf->orig_pte)) {
+		tmp = finish_mkwrite_fault(vmf);
+		if (unlikely(!tmp || (tmp &
+				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
 			unlock_page(vmf->page);
-			pte_unmap_unlock(vmf->pte, vmf->ptl);
 			put_page(vmf->page);
-			return 0;
+			return tmp;
 		}
-		page_mkwrite = 1;
-	}
-
-	wp_page_reuse(vmf);
-	if (!page_mkwrite)
+	} else {
+		wp_page_reuse(vmf);
 		lock_page(vmf->page);
+	}
 	fault_dirty_shared_page(vma, vmf->page);
 	put_page(vmf->page);
 
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
