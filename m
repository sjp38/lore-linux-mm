Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A38A228028C
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 12:08:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so12992866wmg.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:08:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ua11si3052033wjb.62.2016.09.27.09.08.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 09:08:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 12/20] mm: Factor out common parts of write fault handling
Date: Tue, 27 Sep 2016 18:08:16 +0200
Message-Id: <1474992504-20133-13-git-send-email-jack@suse.cz>
In-Reply-To: <1474992504-20133-1-git-send-email-jack@suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Currently we duplicate handling of shared write faults in
wp_page_reuse() and do_shared_fault(). Factor them out into a common
function.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 78 +++++++++++++++++++++++++++++--------------------------------
 1 file changed, 37 insertions(+), 41 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 63d9c1a54caf..0643b3b5a12a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2063,6 +2063,41 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 }
 
 /*
+ * Handle dirtying of a page in shared file mapping on a write fault.
+ *
+ * The function expects the page to be locked and unlocks it.
+ */
+static void fault_dirty_shared_page(struct vm_area_struct *vma,
+				    struct page *page)
+{
+	struct address_space *mapping;
+	bool dirtied;
+	bool page_mkwrite = vma->vm_ops->page_mkwrite;
+
+	dirtied = set_page_dirty(page);
+	VM_BUG_ON_PAGE(PageAnon(page), page);
+	/*
+	 * Take a local copy of the address_space - page.mapping may be zeroed
+	 * by truncate after unlock_page().   The address_space itself remains
+	 * pinned by vma->vm_file's reference.  We rely on unlock_page()'s
+	 * release semantics to prevent the compiler from undoing this copying.
+	 */
+	mapping = page_rmapping(page);
+	unlock_page(page);
+
+	if ((dirtied || page_mkwrite) && mapping) {
+		/*
+		 * Some device drivers do not set page.mapping
+		 * but still dirty their pages
+		 */
+		balance_dirty_pages_ratelimited(mapping);
+	}
+
+	if (!page_mkwrite)
+		file_update_time(vma->vm_file);
+}
+
+/*
  * Handle write page faults for pages that can be reused in the current vma
  *
  * This can happen either due to the mapping being with the VM_SHARED flag,
@@ -2092,28 +2127,11 @@ static inline int wp_page_reuse(struct vm_fault *vmf, struct page *page,
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
 
 	if (dirty_shared) {
-		struct address_space *mapping;
-		int dirtied;
-
 		if (!page_mkwrite)
 			lock_page(page);
 
-		dirtied = set_page_dirty(page);
-		VM_BUG_ON_PAGE(PageAnon(page), page);
-		mapping = page->mapping;
-		unlock_page(page);
+		fault_dirty_shared_page(vma, page);
 		put_page(page);
-
-		if ((dirtied || page_mkwrite) && mapping) {
-			/*
-			 * Some device drivers do not set page.mapping
-			 * but still dirty their pages
-			 */
-			balance_dirty_pages_ratelimited(mapping);
-		}
-
-		if (!page_mkwrite)
-			file_update_time(vma->vm_file);
 	}
 
 	return VM_FAULT_WRITE;
@@ -3256,8 +3274,6 @@ uncharge_out:
 static int do_shared_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct address_space *mapping;
-	int dirtied = 0;
 	int ret, tmp;
 
 	ret = __do_fault(vmf);
@@ -3286,27 +3302,7 @@ static int do_shared_fault(struct vm_fault *vmf)
 		return ret;
 	}
 
-	if (set_page_dirty(vmf->page))
-		dirtied = 1;
-	/*
-	 * Take a local copy of the address_space - page.mapping may be zeroed
-	 * by truncate after unlock_page().   The address_space itself remains
-	 * pinned by vma->vm_file's reference.  We rely on unlock_page()'s
-	 * release semantics to prevent the compiler from undoing this copying.
-	 */
-	mapping = page_rmapping(vmf->page);
-	unlock_page(vmf->page);
-	if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
-		/*
-		 * Some device drivers do not set page.mapping but still
-		 * dirty their pages
-		 */
-		balance_dirty_pages_ratelimited(mapping);
-	}
-
-	if (!vma->vm_ops->page_mkwrite)
-		file_update_time(vma->vm_file);
-
+	fault_dirty_shared_page(vma, vmf->page);
 	return ret;
 }
 
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
