Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2C26B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:26:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b65so33298677wmg.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:26:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y7si621852wjd.270.2016.07.22.05.19.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:19:51 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 13/15] mm: Provide helper for finishing mkwrite faults
Date: Fri, 22 Jul 2016 14:19:39 +0200
Message-Id: <1469189981-19000-14-git-send-email-jack@suse.cz>
In-Reply-To: <1469189981-19000-1-git-send-email-jack@suse.cz>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

Provide a helper function for finishing write faults due to PTE being
read-only. The helper will be used by DAX to avoid the need of
complicating generic MM code with DAX locking specifics.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h |  1 +
 mm/memory.c        | 62 +++++++++++++++++++++++++++++++++++-------------------
 2 files changed, 41 insertions(+), 22 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index daf690fccc0c..32ff572a6e6c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -601,6 +601,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		struct page *page, pte_t *pte, bool write, bool anon);
 int finish_fault(struct vm_area_struct *vma, struct vm_fault *vmf);
+int finish_mkwrite_fault(struct vm_area_struct *vma, struct vm_fault *vmf);
 #endif
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index 1d2916c53d43..30cf7b36df48 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2262,6 +2262,41 @@ oom:
 	return VM_FAULT_OOM;
 }
 
+/**
+ * finish_mkrite_fault - finish page fault making PTE writeable once the page
+ *			 page is prepared
+ *
+ * @vma: virtual memory area
+ * @vmf: structure describing the fault
+ *
+ * This function handles all that is needed to finish a write page fault due
+ * to PTE being read-only once the mapped page is prepared. It handles locking
+ * of PTE and modifying it. The function returns 0 on success, error in case
+ * the PTE changed before we acquired PTE lock.
+ *
+ * The function expects the page to be locked or other protection against
+ * concurrent faults / writeback (such as DAX radix tree locks).
+ */
+int finish_mkwrite_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	unsigned long address = (unsigned long)vmf->virtual_address;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, address, &ptl);
+	/*
+	 * We might have raced with another page fault while we
+	 * released the pte_offset_map_lock.
+	 */
+	if (!pte_same(*pte, vmf->orig_pte)) {
+		pte_unmap_unlock(pte, ptl);
+		return -EBUSY;
+	}
+	wp_page_reuse(vma->vm_mm, vma, address, pte, ptl, vmf->orig_pte,
+		      vmf->page);
+	return 0;
+}
+
 /*
  * Handle write page faults for VM_MIXEDMAP or VM_PFNMAP for a VM_SHARED
  * mapping
@@ -2282,17 +2317,12 @@ static int wp_pfn_shared(struct mm_struct *mm,
 		ret = vma->vm_ops->pfn_mkwrite(vma, &vmf);
 		if (ret & VM_FAULT_ERROR)
 			return ret;
-		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-		/*
-		 * We might have raced with another page fault while we
-		 * released the pte_offset_map_lock.
-		 */
-		if (!pte_same(*page_table, orig_pte)) {
-			pte_unmap_unlock(page_table, ptl);
+		if (finish_mkwrite_fault(vma, &vmf) < 0)
 			return 0;
-		}
+	} else {
+		wp_page_reuse(mm, vma, address, page_table, ptl, orig_pte,
+			      NULL);
 	}
-	wp_page_reuse(mm, vma, address, page_table, ptl, orig_pte, NULL);
 	return VM_FAULT_WRITE;
 }
 
@@ -2319,28 +2349,16 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 			put_page(old_page);
 			return tmp;
 		}
-		/*
-		 * Since we dropped the lock we need to revalidate
-		 * the PTE as someone else may have changed it.  If
-		 * they did, we just return, as we can count on the
-		 * MMU to tell us if they didn't also make it writable.
-		 */
-		page_table = pte_offset_map_lock(mm, pmd, address,
-						 &ptl);
-		if (!pte_same(*page_table, orig_pte)) {
+		if (finish_mkwrite_fault(vma, &vmf) < 0) {
 			unlock_page(old_page);
-			pte_unmap_unlock(page_table, ptl);
 			put_page(old_page);
 			return 0;
 		}
-		wp_page_reuse(mm, vma, address, page_table, ptl, orig_pte,
-			      old_page);
 	} else {
 		wp_page_reuse(mm, vma, address, page_table, ptl, orig_pte,
 			      old_page);
 		lock_page(old_page);
 	}
-
 	fault_dirty_shared_page(vma, old_page);
 	put_page(old_page);
 	return VM_FAULT_WRITE;
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
