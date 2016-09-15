Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF0B6B0264
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:55:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so90193112pfv.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:55:39 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a68si39039746pfb.39.2016.09.15.04.55.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:55:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 11/41] thp: try to free page's buffers before attempt split
Date: Thu, 15 Sep 2016 14:54:53 +0300
Message-Id: <20160915115523.29737-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
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
index 020a23d6e7f8..44bf0ba3d10f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -30,6 +30,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/page_idle.h>
 #include <linux/shmem_fs.h>
+#include <linux/buffer_head.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -2012,7 +2013,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 
 	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
 	if (PageAnon(head)) {
@@ -2041,6 +2041,23 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
