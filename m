Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3375B280255
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:59:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so53757108pgj.6
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:59:07 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a21si1218770pfc.135.2017.01.26.03.59.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:59:06 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 05/37] thp: try to free page's buffers before attempt split
Date: Thu, 26 Jan 2017 14:57:47 +0300
Message-Id: <20170126115819.58875-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We want page to be isolated from the rest of the system before splitting
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
index d67ab83823ad..fd4134ce9c54 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -400,6 +400,7 @@ extern int __set_page_dirty_buffers(struct page *page);
 #else /* CONFIG_BLOCK */
 
 static inline void buffer_init(void) {}
+static inline int page_has_buffers(struct page *page) { return 0; }
 static inline int try_to_free_buffers(struct page *page) { return 1; }
 static inline int inode_has_buffers(struct inode *inode) { return 0; }
 static inline void invalidate_inode_buffers(struct inode *inode) {}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 89819fe4debc..55aee62e8444 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -30,6 +30,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/page_idle.h>
 #include <linux/shmem_fs.h>
+#include <linux/buffer_head.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -2117,7 +2118,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 
 	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
 	if (PageAnon(head)) {
@@ -2146,6 +2146,23 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
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
+			if (page_has_buffers(head) && !try_to_release_page(head,
+						GFP_KERNEL)) {
+				ret = -EBUSY;
+				goto out;
+			}
+		}
+
 		/* Addidional pin from radix tree */
 		extra_pins = 1;
 		anon_vma = NULL;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
