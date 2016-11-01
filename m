Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB7596B02B0
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 18:37:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p190so465498wmp.3
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 15:37:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rk19si1095025wjb.69.2016.11.01.15.37.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 15:37:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 09/21] mm: Factor out functionality to finish page faults
Date: Tue,  1 Nov 2016 23:36:18 +0100
Message-Id: <1478039794-20253-13-git-send-email-jack@suse.cz>
In-Reply-To: <1478039794-20253-1-git-send-email-jack@suse.cz>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

Introduce function finish_fault() as a helper function for finishing
page faults. It is rather thin wrapper around alloc_set_pte() but since
we'd want to call this from DAX code or filesystems, it is still useful
to avoid some boilerplate code.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h |  1 +
 mm/memory.c        | 44 +++++++++++++++++++++++++++++++++++---------
 2 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 78173d7de007..7ac2bbaab4f4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -620,6 +620,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 
 int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page);
+int finish_fault(struct vm_fault *vmf);
 #endif
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index ac901bb02398..d3fc4988f869 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3033,6 +3033,38 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
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
+ * The function expects the page to be locked and on success it consumes a
+ * reference of a page being mapped (for the PTE which maps it).
+ */
+int finish_fault(struct vm_fault *vmf)
+{
+	struct page *page;
+	int ret;
+
+	/* Did we COW the page? */
+	if ((vmf->flags & FAULT_FLAG_WRITE) &&
+	    !(vmf->vma->vm_flags & VM_SHARED))
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
 
@@ -3178,9 +3210,7 @@ static int do_read_fault(struct vm_fault *vmf)
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-	ret |= alloc_set_pte(vmf, NULL, vmf->page);
-	if (vmf->pte)
-		pte_unmap_unlock(vmf->pte, vmf->ptl);
+	ret |= finish_fault(vmf);
 	unlock_page(vmf->page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		put_page(vmf->page);
@@ -3219,9 +3249,7 @@ static int do_cow_fault(struct vm_fault *vmf)
 		copy_user_highpage(new_page, vmf->page, vmf->address, vma);
 	__SetPageUptodate(new_page);
 
-	ret |= alloc_set_pte(vmf, memcg, new_page);
-	if (vmf->pte)
-		pte_unmap_unlock(vmf->pte, vmf->ptl);
+	ret |= finish_fault(vmf);
 	if (!(ret & VM_FAULT_DAX_LOCKED)) {
 		unlock_page(vmf->page);
 		put_page(vmf->page);
@@ -3262,9 +3290,7 @@ static int do_shared_fault(struct vm_fault *vmf)
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
