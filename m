Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 689FF6B0062
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:29 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 30/30] thp: map file-backed huge pages on fault
Date: Thu, 14 Mar 2013 19:50:35 +0200
Message-Id: <1363283435-7666-31-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Look like all pieces are in place, we can map file-backed huge-pages
now.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |    4 +++-
 mm/memory.c             |    1 +
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index c6e3aef..c175c78 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -80,7 +80,9 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 	   (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG) &&			\
 	   ((__vma)->vm_flags & VM_HUGEPAGE))) &&			\
 	 !((__vma)->vm_flags & VM_NOHUGEPAGE) &&			\
-	 !is_vma_temporary_stack(__vma))
+	 !is_vma_temporary_stack(__vma) &&				\
+	 (!(__vma)->vm_ops ||						\
+		  mapping_can_have_hugepages((__vma)->vm_file->f_mapping)))
 #define transparent_hugepage_defrag(__vma)				\
 	((transparent_hugepage_flags &					\
 	  (1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)) ||			\
diff --git a/mm/memory.c b/mm/memory.c
index 52bd6cf..f3b5a11 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3738,6 +3738,7 @@ retry:
 		if (!vma->vm_ops)
 			return do_huge_pmd_anonymous_page(mm, vma, address,
 							  pmd, flags);
+		return do_huge_linear_fault(mm, vma, address, pmd, flags);
 	} else {
 		pmd_t orig_pmd = *pmd;
 		int ret;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
