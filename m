Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 63D136B03E4
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:19:24 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so9393943wms.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:19:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u4si1719013wmg.111.2016.11.18.01.17.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 01:17:30 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 14/20] mm: Move part of wp_page_reuse() into the single call site
Date: Fri, 18 Nov 2016 10:17:18 +0100
Message-Id: <1479460644-25076-15-git-send-email-jack@suse.cz>
In-Reply-To: <1479460644-25076-1-git-send-email-jack@suse.cz>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>

wp_page_reuse() handles write shared faults which is needed only in
wp_page_shared(). Move the handling only into that location to make
wp_page_reuse() simpler and avoid a strange situation when we sometimes
pass in locked page, sometimes unlocked etc.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 27 ++++++++++++---------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8d08015ed44d..7fd9c2c60281 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2106,8 +2106,7 @@ static void fault_dirty_shared_page(struct vm_area_struct *vma,
  * case, all we need to do here is to mark the page as writable and update
  * any related book-keeping.
  */
-static inline int wp_page_reuse(struct vm_fault *vmf,
-				int page_mkwrite, int dirty_shared)
+static inline void wp_page_reuse(struct vm_fault *vmf)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -2127,16 +2126,6 @@ static inline int wp_page_reuse(struct vm_fault *vmf,
 	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
 		update_mmu_cache(vma, vmf->address, vmf->pte);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
-
-	if (dirty_shared) {
-		if (!page_mkwrite)
-			lock_page(page);
-
-		fault_dirty_shared_page(vma, page);
-		put_page(page);
-	}
-
-	return VM_FAULT_WRITE;
 }
 
 /*
@@ -2311,7 +2300,8 @@ static int wp_pfn_shared(struct vm_fault *vmf)
 			return 0;
 		}
 	}
-	return wp_page_reuse(vmf, 0, 0);
+	wp_page_reuse(vmf);
+	return VM_FAULT_WRITE;
 }
 
 static int wp_page_shared(struct vm_fault *vmf)
@@ -2349,7 +2339,13 @@ static int wp_page_shared(struct vm_fault *vmf)
 		page_mkwrite = 1;
 	}
 
-	return wp_page_reuse(vmf, page_mkwrite, 1);
+	wp_page_reuse(vmf);
+	if (!page_mkwrite)
+		lock_page(vmf->page);
+	fault_dirty_shared_page(vma, vmf->page);
+	put_page(vmf->page);
+
+	return VM_FAULT_WRITE;
 }
 
 /*
@@ -2424,7 +2420,8 @@ static int do_wp_page(struct vm_fault *vmf)
 				page_move_anon_rmap(vmf->page, vma);
 			}
 			unlock_page(vmf->page);
-			return wp_page_reuse(vmf, 0, 0);
+			wp_page_reuse(vmf);
+			return VM_FAULT_WRITE;
 		}
 		unlock_page(vmf->page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
