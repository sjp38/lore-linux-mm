Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8446B025E
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:37:58 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id g49so413317962qta.0
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:37:58 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id c43si15549320qte.145.2017.02.01.15.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:37:57 -0800 (PST)
From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 1/4] mm: Fix sparse, use plain integer as NULL pointer
Date: Thu,  2 Feb 2017 10:37:17 +1100
Message-Id: <1485992240-10986-2-git-send-email-me@tobin.cc>
In-Reply-To: <1485992240-10986-1-git-send-email-me@tobin.cc>
References: <1485992240-10986-1-git-send-email-me@tobin.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Tobin C Harding <me@tobin.cc>

From: Tobin C Harding <me@tobin.cc>

Patch fixes sparse warning: Using plain integer as NULL pointer. Replaces
assignment of 0 to pointer with NULL assignment.

Signed-off-by: Tobin C Harding <me@tobin.cc>
---
 mm/memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 6bf2b47..cc5fa12 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2905,7 +2905,7 @@ static int pte_alloc_one_map(struct vm_fault *vmf)
 		atomic_long_inc(&vma->vm_mm->nr_ptes);
 		pmd_populate(vma->vm_mm, vmf->pmd, vmf->prealloc_pte);
 		spin_unlock(vmf->ptl);
-		vmf->prealloc_pte = 0;
+		vmf->prealloc_pte = NULL;
 	} else if (unlikely(pte_alloc(vma->vm_mm, vmf->pmd, vmf->address))) {
 		return VM_FAULT_OOM;
 	}
@@ -2953,7 +2953,7 @@ static void deposit_prealloc_pte(struct vm_fault *vmf)
 	 * count that as nr_ptes.
 	 */
 	atomic_long_inc(&vma->vm_mm->nr_ptes);
-	vmf->prealloc_pte = 0;
+	vmf->prealloc_pte = NULL;
 }
 
 static int do_set_pmd(struct vm_fault *vmf, struct page *page)
@@ -3359,7 +3359,7 @@ static int do_fault(struct vm_fault *vmf)
 	/* preallocated pagetable is unused: free it */
 	if (vmf->prealloc_pte) {
 		pte_free(vma->vm_mm, vmf->prealloc_pte);
-		vmf->prealloc_pte = 0;
+		vmf->prealloc_pte = NULL;
 	}
 	return ret;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
