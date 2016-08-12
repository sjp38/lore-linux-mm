Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E02B88296C
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:39:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so6138992pfd.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:39:19 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id t78si10108463pfi.19.2016.08.12.11.38.59
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 11/41] thp: try to free page's buffers before attempt split
Date: Fri, 12 Aug 2016 21:37:54 +0300
Message-Id: <1471027104-115213-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We want page to be isolated from the rest of the system before spliting
it. We rely on page count to be 2 for file pages to make sure nobody
uses the page: one pin to caller, one to radix-tree.

Filesystems with backing storage can have page count increased if it has
buffers.

Let's try to free them, before attempt split. And remove one guarding
VM_BUG_ON_PAGE().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/buffer_head.h |  1 +
 mm/huge_memory.c            | 19 ++++++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index ebbacd14d450..006a8a42acfb 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -395,6 +395,7 @@ extern int __set_page_dirty_buffers(struct page *page);
 #else /* CONFIG_BLOCK */
 
 static inline void buffer_init(void) {}
+static inline int page_has_buffers(struct page *page) { return 0; }
 static inline int try_to_free_buffers(struct page *page) { return 1; }
 static inline int inode_has_buffers(struct inode *inode) { return 0; }
 static inline void invalidate_inode_buffers(struct inode *inode) {}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 73e80d49c32e..a8fcfa3010c8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -30,6 +30,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/page_idle.h>
 #include <linux/shmem_fs.h>
+#include <linux/buffer_head.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -2007,7 +2008,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 
 	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
 	if (PageAnon(head)) {
@@ -2036,6 +2036,23 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			goto out;
 		}
 
+		/* Try to free buffers before attempt split */
+		if (!PageSwapBacked(head) && PagePrivate(page)) {
+			/*
+			 * We cannot trigger writeback from here due possible
+			 * recursion if triggered from vmscan, only wait.
+			 *
+			 * Caller can trigger writeback it on its own, if safe.
+			 */
+			wait_on_page_writeback(head);
+
+			if (page_has_buffers(head) &&
+					!try_to_free_buffers(head)) {
+				ret = -EBUSY;
+				goto out;
+			}
+		}
+
 		/* Addidional pin from radix tree */
 		extra_pins = 1;
 		anon_vma = NULL;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
