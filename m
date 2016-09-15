Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E77C828026B
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:56:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v67so90235801pfv.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:56:37 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id bx7si3466408pac.110.2016.09.15.04.56.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:56:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 12/41] thp: handle write-protection faults for file THP
Date: Thu, 15 Sep 2016 14:54:54 +0300
Message-Id: <20160915115523.29737-13-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
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
index 83be99d9d8a1..aad8d5c6311f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3451,8 +3451,17 @@ static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
