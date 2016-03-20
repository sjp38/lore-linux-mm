Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B5BA0828DF
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:41:56 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id u190so238217626pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:41:56 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 24si2318154pfq.155.2016.03.20.11.41.42
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 10/71] drivers/misc: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:17 +0300
Message-Id: <1458499278-1516-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/misc/ibmasm/ibmasmfs.c          | 4 ++--
 drivers/misc/vmw_vmci/vmci_queue_pair.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/misc/ibmasm/ibmasmfs.c b/drivers/misc/ibmasm/ibmasmfs.c
index e8b933111e0d..9c677f3f3c26 100644
--- a/drivers/misc/ibmasm/ibmasmfs.c
+++ b/drivers/misc/ibmasm/ibmasmfs.c
@@ -116,8 +116,8 @@ static int ibmasmfs_fill_super (struct super_block *sb, void *data, int silent)
 {
 	struct inode *root;
 
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = IBMASMFS_MAGIC;
 	sb->s_op = &ibmasmfs_s_ops;
 	sb->s_time_gran = 1;
diff --git a/drivers/misc/vmw_vmci/vmci_queue_pair.c b/drivers/misc/vmw_vmci/vmci_queue_pair.c
index f42d9c4e4561..f84a4275ca29 100644
--- a/drivers/misc/vmw_vmci/vmci_queue_pair.c
+++ b/drivers/misc/vmw_vmci/vmci_queue_pair.c
@@ -728,7 +728,7 @@ static void qp_release_pages(struct page **pages,
 		if (dirty)
 			set_page_dirty(pages[i]);
 
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 		pages[i] = NULL;
 	}
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
