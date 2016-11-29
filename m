Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCE76B0260
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:23 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y71so421372591pgd.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:23 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 1si30856571plm.51.2016.11.29.03.23.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:22 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 06/36] thp: handle write-protection faults for file THP
Date: Tue, 29 Nov 2016 14:22:34 +0300
Message-Id: <20161129112304.90056-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For filesystems that wants to be write-notified (has mkwrite), we will
encount write-protection faults for huge PMDs in shared mappings.

The easiest way to handle them is to clear the PMD and let it refault as
wriable.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 455c3e628d52..e3d7cea8cc6a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3495,8 +3495,16 @@ static int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 		return vmf->vma->vm_ops->pmd_fault(vmf->vma, vmf->address,
 						   vmf->pmd, vmf->flags);
 
+	if (vmf->vma->vm_flags & VM_SHARED) {
+		/* Clear PMD */
+		zap_page_range_single(vmf->vma, vmf->address & HPAGE_PMD_MASK,
+				HPAGE_PMD_SIZE, NULL);
+
+		/* Refault to establish writable PMD */
+		return 0;
+	}
+
 	/* COW handled on pte level: split pmd */
-	VM_BUG_ON_VMA(vmf->vma->vm_flags & VM_SHARED, vmf->vma);
 	__split_huge_pmd(vmf->vma, vmf->pmd, vmf->address, false, NULL);
 
 	return VM_FAULT_FALLBACK;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
