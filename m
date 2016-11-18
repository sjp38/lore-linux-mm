Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 526E86B03CD
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:17:45 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y16so9514630wmd.6
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:17:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e200si1748205wma.2.2016.11.18.01.17.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 01:17:30 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 11/20] mm: Factor out common parts of write fault handling
Date: Fri, 18 Nov 2016 10:17:15 +0100
Message-Id: <1479460644-25076-12-git-send-email-jack@suse.cz>
In-Reply-To: <1479460644-25076-1-git-send-email-jack@suse.cz>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>

Currently we duplicate handling of shared write faults in
wp_page_reuse() and do_shared_fault(). Factor them out into a common
function.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 78 +++++++++++++++++++++++++++++--------------------------------
 1 file changed, 37 insertions(+), 41 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index e9e9224264da..139e115acf35 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2067,6 +2067,41 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
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
+	bool page_mkwrite = vma->vm_ops && vma->vm_ops->page_mkwrite;
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
@@ -2096,28 +2131,11 @@ static inline int wp_page_reuse(struct vm_fault *vmf, struct page *page,
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
@@ -3259,8 +3277,6 @@ static int do_cow_fault(struct vm_fault *vmf)
 static int do_shared_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct address_space *mapping;
-	int dirtied = 0;
 	int ret, tmp;
 
 	ret = __do_fault(vmf);
@@ -3289,27 +3305,7 @@ static int do_shared_fault(struct vm_fault *vmf)
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
