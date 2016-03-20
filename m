Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF97828F4
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:27 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id x3so237460727pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:27 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p86si16668950pfa.161.2016.03.20.11.42.15
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:42:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 68/71] uprobes: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:15 +0300
Message-Id: <1458499278-1516-69-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>

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
Cc: Oleg Nesterov <oleg@redhat.com>
---
 kernel/events/uprobes.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 5f6ce931f1ea..9be1cba0eb11 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -321,7 +321,7 @@ retry:
 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
 
 	ret = __replace_page(vma, vaddr, old_page, new_page);
-	page_cache_release(new_page);
+	put_page(new_page);
 put_old:
 	put_page(old_page);
 
@@ -539,14 +539,14 @@ static int __copy_insn(struct address_space *mapping, struct file *filp,
 	 * see uprobe_register().
 	 */
 	if (mapping->a_ops->readpage)
-		page = read_mapping_page(mapping, offset >> PAGE_CACHE_SHIFT, filp);
+		page = read_mapping_page(mapping, offset >> PAGE_SHIFT, filp);
 	else
-		page = shmem_read_mapping_page(mapping, offset >> PAGE_CACHE_SHIFT);
+		page = shmem_read_mapping_page(mapping, offset >> PAGE_SHIFT);
 	if (IS_ERR(page))
 		return PTR_ERR(page);
 
 	copy_from_page(page, offset, insn, nbytes);
-	page_cache_release(page);
+	put_page(page);
 
 	return 0;
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
