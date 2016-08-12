Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 542236B0262
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:38:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so6428662pfx.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:38:52 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id xm1si10113688pab.3.2016.08.12.11.38.43
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:44 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 12/41] thp: handle write-protection faults for file THP
Date: Fri, 12 Aug 2016 21:37:55 +0300
Message-Id: <1471027104-115213-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For filesystems that wants to be write-notified (has mkwrite), we will
encount write-protection faults for huge PMDs in shared mappings.

The easiest way to handle them is to clear the PMD and let it refault as
wriable.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 4425b6059339..5b7f0ce44a27 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3448,8 +3448,17 @@ static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
 		return fe->vma->vm_ops->pmd_fault(fe->vma, fe->address, fe->pmd,
 				fe->flags);
 
+	if (fe->vma->vm_flags & VM_SHARED) {
+		/* Clear PMD */
+		zap_page_range_single(fe->vma, fe->address,
+				HPAGE_PMD_SIZE, NULL);
+		VM_BUG_ON(!pmd_none(*fe->pmd));
+
+		/* Refault to establish writable PMD */
+		return 0;
+	}
+
 	/* COW handled on pte level: split pmd */
-	VM_BUG_ON_VMA(fe->vma->vm_flags & VM_SHARED, fe->vma);
 	split_huge_pmd(fe->vma, fe->pmd, fe->address);
 
 	return VM_FAULT_FALLBACK;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
