Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81BDF28024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 12:08:33 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id k17so6991644ywe.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:08:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e75si14402403wmg.2.2016.09.27.09.08.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 09:08:32 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 09/20] mm: Factor out functionality to finish page faults
Date: Tue, 27 Sep 2016 18:08:13 +0200
Message-Id: <1474992504-20133-10-git-send-email-jack@suse.cz>
In-Reply-To: <1474992504-20133-1-git-send-email-jack@suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Introduce function finish_fault() as a helper function for finishing
page faults. It is rather thin wrapper around alloc_set_pte() but since
we'd want to call this from DAX code or filesystems, it is still useful
to avoid some boilerplate code.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h |  1 +
 mm/memory.c        | 42 +++++++++++++++++++++++++++++++++---------
 2 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index faa77b15e9a6..919ebdd27f1e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -622,6 +622,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 
 int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page);
+int finish_fault(struct vm_fault *vmf);
 #endif
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index 17db88a38e8a..f54cfad7fe04 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3029,6 +3029,36 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 	return 0;
 }
 
+
+/**
+ * finish_fault - finish page fault once we have prepared the page to fault
+ *
+ * @vmf: structure describing the fault
+ *
+ * This function handles all that is needed to finish a page fault once the
+ * page to fault in is prepared. It handles locking of PTEs, inserts PTE for
+ * given page, adds reverse page mapping, handles memcg charges and LRU
+ * addition. The function returns 0 on success, VM_FAULT_ code in case of
+ * error.
+ *
+ * The function expects the page to be locked.
+ */
+int finish_fault(struct vm_fault *vmf)
+{
+	struct page *page;
+	int ret;
+
+	/* Did we COW the page? */
+	if (vmf->flags & FAULT_FLAG_WRITE && !(vmf->vma->vm_flags & VM_SHARED))
+		page = vmf->cow_page;
+	else
+		page = vmf->page;
+	ret = alloc_set_pte(vmf, vmf->memcg, page);
+	if (vmf->pte)
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
+	return ret;
+}
+
 static unsigned long fault_around_bytes __read_mostly =
 	rounddown_pow_of_two(65536);
 
@@ -3174,9 +3204,7 @@ static int do_read_fault(struct vm_fault *vmf)
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-	ret |= alloc_set_pte(vmf, NULL, vmf->page);
-	if (vmf->pte)
-		pte_unmap_unlock(vmf->pte, vmf->ptl);
+	ret |= finish_fault(vmf);
 	unlock_page(vmf->page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		put_page(vmf->page);
@@ -3215,9 +3243,7 @@ static int do_cow_fault(struct vm_fault *vmf)
 		copy_user_highpage(new_page, vmf->page, vmf->address, vma);
 	__SetPageUptodate(new_page);
 
-	ret |= alloc_set_pte(vmf, memcg, new_page);
-	if (vmf->pte)
-		pte_unmap_unlock(vmf->pte, vmf->ptl);
+	ret |= finish_fault(vmf);
 	if (!(ret & VM_FAULT_DAX_LOCKED)) {
 		unlock_page(vmf->page);
 		put_page(vmf->page);
@@ -3258,9 +3284,7 @@ static int do_shared_fault(struct vm_fault *vmf)
 		}
 	}
 
-	ret |= alloc_set_pte(vmf, NULL, vmf->page);
-	if (vmf->pte)
-		pte_unmap_unlock(vmf->pte, vmf->ptl);
+	ret |= finish_fault(vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
 					VM_FAULT_RETRY))) {
 		unlock_page(vmf->page);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
